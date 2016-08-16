#!/usr/bin/env dub
/+ dub.json:
{
    "name": "bench_flex_normal",
    "dependencies": {
        "mir": {"path":"../.."},
        "hap": "1.0.0-rc.2.1",
        "dstats": "1.0.3",
        "atmosphere": "0.1.7"
    },
    "dflags-ldc": ["-mcpu=native"]
}
+/
/+
$ ldc-git --version
LDC - the LLVM D compiler (798cda):
  based on DMD v2.071.2-b1 and LLVM 3.8.1
  built with DMD64 D Compiler v2.071.1
  Default target: x86_64-unknown-linux-gnu
  Host CPU: haswell
  http://dlang.org - http://wiki.dlang.org/LDC

$ dub run --build=release-nobounds --compiler=ldmd2-git --single benchmarks/flex/normal_dist.d

boxMueller.naive   =   850 ms, stddev: 82  ms
boxMueller.hap     =  3618 ms, stddev: 4   ms
boxMueller.dstats  =   801 ms, stddev: 2   ms
boxMueller.atmos   =   934 ms, stddev: 2   ms
flexNormal.slow    =  1406 ms, stddev: 4   ms
flexNormal.medium  =  1206 ms, stddev: 1   ms
flexNormal.fast    =  1124 ms, stddev: 0   ms
ziggurat           =   357 ms, stddev: 5   ms
+/

import mir.random.flex;

/*
$(WEB https://en.wikipedia.org/wiki/Box%E2%80%93Muller_transform, Box Muller-transform)
References:
    Butcher, J. C. "Random sampling from the normal distribution."
    The Computer Journal 3.4 (1961): 251-253.
    http://comjnl.oxfordjournals.org/content/3/4/251.full.pdf
*/
auto boxMueller(S, RNG)(S mu, S sigma, ref RNG gen)
{
    import mir.internal.math : log, cos, sin, sqrt;
    import std.math : PI;
    import std.random : uniform;

    static S epsilon = S.min_normal;
	static S two_pi = 2.0 * PI;

	static S z0, z1;
	static bool generate;
	generate = !generate;

	if (!generate)
	   return z1 * sigma + mu;

	S u1, u2;
	do
	{
	   u1 = uniform(0.0L, 1.0L, gen);
	   u2 = uniform(0.0L, 1.0L, gen);
	}
	while (u1 <= epsilon);

	z0 = sqrt(-2.0 * log(u1)) * cos(two_pi * u2);
	z1 = sqrt(-2.0 * log(u1)) * sin(two_pi * u2);
	return z0 * sigma + mu;
}

auto genNormal(S)(S rho = 1.1)
{
    import std.math : exp, log, PI, sqrt;
    S[] points = [-S.infinity, -1.5, 0, 1.5, S.infinity];
    enum S halfLog2PI = S(0.5) * log(2 * PI);
    auto f0 = (S x) => -(x * x) * S(0.5) - halfLog2PI;
    auto f1 = (S x) => -x;
    auto f2 = (S x) => S(-1);
    return flex(f0, f1, f2, -0.5, points, rho);
}

__gshared float r = 0.0;

void main()
{
    import std.datetime: benchmark, Duration, TickDuration;
    import std.stdio : writefln;
    import std.conv : to;

    alias S = double;

    int nrRuns = 20; // number of runs
    int nrSamples = 1_000_000; // number of samples

    auto flexNormalSlow = genNormal!S(1.3);
    auto flexNormalMedium = genNormal!S(1.1);
    auto flexNormalFast = genNormal!S(1.0001);

    // mir ziggurat is temporarily excluded as it hasn't been merged yet
    //auto zigguratNormal = normal!(S, uint)();

    // just pick any rng gen, it will have the same speed for all algorithms
    import std.random : Mt19937;
    auto gen = Mt19937(42);

    import hap.random.distribution : normalDistribution;
    auto hapNormal = normalDistribution(S(0), S(1), gen);

    enum names = ["boxMueller.naive", "boxMueller.hap", "boxMueller.dstats",
                  "boxMueller.atmos",
                  "flexNormal.slow", "flexNormal.medium",
                  "flexNormal.fast", "ziggurat"];

    long[][names.length] runtimes;
    foreach (i; 0..nrRuns)
    {
        auto bench = benchmark!(
            { r += boxMueller!S(0, 1, gen); },
            {
                r += hapNormal.front;
                hapNormal.popFront();
            },
            {
                import dstats.random : rNorm;
                r += rNorm(S(0), S(1), gen);
            },
            {
                import atmosphere.random : rNormal;
                r += rNormal!S(gen);
            },
            { r += flexNormalSlow(gen); },
            { r += flexNormalMedium(gen); },
            { r += flexNormalFast(gen); },
            //{ r += zigguratNormal(gen); },
        )(nrSamples);

        // log run times
        foreach (j, b; bench)
            runtimes[j] ~= b.hnsecs;
    }

    import std.stdio;
    import std.range;
    import std.datetime;
    import core.time : Duration;
    foreach(j, times;runtimes)
    {
        import std.algorithm.iteration : sum;
        import std.algorithm.searching : minPos, maxPos;
        import dstats.summary : meanStdev;
        auto report = times.meanStdev();
        writef("%-18s = %5d ms", names[j], report.mean.to!long.hnsecs.total!"msecs");

        writef(", stddev: %-3d ms", report.stdev.to!long.hnsecs.total!"msecs");
        writeln();
    }
}
