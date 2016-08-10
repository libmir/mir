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

boxMueller.naive   = 12 secs, 36 ms, and 998 μs
boxMueller.hap     = 40 secs, 844 ms, 230 μs, and 6 hnsecs
boxMueller.dstats  = 8 secs, 4 ms, 556 μs, and 4 hnsecs
flexNormal.slow    = 14 secs, 54 ms, 592 μs, and 4 hnsecs
flexNormal.medium  = 12 secs, 13 ms, 252 μs, and 9 hnsecs
flexNormal.fast    = 11 secs, 174 ms, 573 μs, and 5 hnsecs
ziggurat           = 3 secs, 538 ms, 75 μs, and 9 hnsecs
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
    import std.datetime: benchmark, Duration;
    import std.stdio : writefln;
    import std.conv : to;

    alias S = double;

    auto flexNormalSlow = genNormal!S(1.3);
    auto flexNormalMedium = genNormal!S(1.1);
    auto flexNormalFast = genNormal!S(1.0001);

    auto zigguratNormal = normal!(S, uint)();

    // just pick any rng gen, it will have the same speed for all algorithms
    import std.random : Mt19937;
    auto gen = Mt19937(42);


    auto bench = benchmark!(
        { r += boxMueller!S(0, 1, gen); },
        {
            import hap.random.distribution : normal;
            r += normal(0, 1, gen);
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
        { r += zigguratNormal(gen); },
    )(1_000_000);

    string[] names = ["boxMueller.naive", "boxMueller.hap", "boxMueller.dstats",
                      "boxMueller.atmos",
                      "flexNormal.slow", "flexNormal.medium",
                      "flexNormal.fast", "ziggurat"];

    foreach(j,r;bench)
        writefln("%-18s = %s", names[j], r.to!Duration);
}



// the ziggurat implementation is WIP, as dub doesn't support pure git modules yet,
// it was just copied over here




import std.traits : isNumeric;

/**
Setup a _normal distribution sampler.

Params:
    T = floating-point type that should be sampled
    UIntType = unsigned UIntType of the random generator

Returns:
    A $(LREF Ziggurat) sampler that can be called to sample from the distribution.
*/
auto normal(T, UIntType = uint)()
{
    import mir.internal.math : exp, log, sqrt;

    auto pdf    = (T x) => cast(T) exp(T(-0.5) * x * x);
    auto invPdf = (T x) => cast(T) sqrt(T(-2) * log(x));

    // values from [Marsaglia00]
    T rightEnd = 3.442619855899;

    /// generate x for the last block (aka tail-block)
    enum fallback = q{
        T fallback(RNG)(bool isPositive, ref RNG gen) const
        {
            import std.random : uniform;
            import std.math : log;
            T x, y, u;
            do
            {
                u = uniform!("[]", T, T)(0, 1, gen);
                x = -log(u) / fs[$ - 1];
                u = uniform!("[]", T, T)(0, 1, gen);
                y = -log(u);
            }
            while (y + y < x * x);
            return isPositive ? rightEnd + x : -rightEnd - x;
        }
    };

    return Ziggurat!(T, fallback, UIntType, 128, true)(pdf, invPdf, rightEnd, T(9.91256303526217e-3));
}

/**
Ziggurat algorithm for generating a random variable from a montone, decreasing density.

Complexity: O_avg: O(1)

References:
    Marsaglia, George, and Wai Wan Tsang. "The ziggurat method for generating random variables."
    Journal of statistical software 5.8 (2000): 1-7.
*/
struct Ziggurat(T, string _fallback, UIntType, size_t numberOfBlocks, bool bothSides)
    if (isNumeric!T)
{

private:

    /// monotone decreasing probability density function
    /// constants don't matter
    T function(T x) pdf;
    T function(T x) invPdf;

    /// precalculate difference x_i / x_{i+1}
    T[numberOfBlocks] xDiv;
    /// precalculate scaling to R.max for x_i
    T[numberOfBlocks] xScaled;
    /// precalculate pdf value for x_i
    T[numberOfBlocks] fs;

    // mask to use to get the first log_2 k bits (=k - 1)
    enum size_t kMask = numberOfBlocks - 1;

    /// left-point of the right-most block
    T rightEnd;

    /// area of every column
    T blockArea;

public:
    /**
    Params:
        pdf = probability density function
        invPdf = inverse probability density function
        rightEnd = left point of the right-most block
        blockArea =  area of every column
    */
    this(T function(T x) pdf, T function(T x) invPdf, T rightEnd, T blockArea)
    {
        this.pdf = pdf;
        this.invPdf = invPdf;
        this.rightEnd = rightEnd;
        this.blockArea = blockArea;

        // scale factor to the range of UIntType
        T maxT = bothSides ? UIntType.max / 2 : UIntType.max;

        auto xn = rightEnd; // Next x_{i+1}
        auto xc = xn; // Current x_i
        auto fn = pdf(xn);

        // k_i = floor(2^32 (x_{i-1} / x_i))
        xDiv[0] = (xn * fn / blockArea) * maxT;
        xDiv[1] = 0;

        // w_i = 0.5^32 * x_i
        xScaled[0]     = (blockArea / fn) / maxT;
        xScaled[$ - 1] = xn / maxT;

        // f_i = f(x_i)
        fs[0]     = T(1);
        fs[$ - 1] = fn;

        for (auto i = xScaled.length - 2; i >= 1; i--)
        {
            xn = invPdf(blockArea / xn + fn);
            xDiv[i + 1] = (xn / xc) * maxT;
            fn = fs[i] = pdf(xn);
            xScaled[i] = xn / maxT;
            xc = xn;
        }
    }

    /// samples a value from the discrete distribution
    T opCall() const
    {
        import std.random : rndGen;
        return opCall(rndGen);
    }

    /// samples a value from the discrete distribution using a custom random generator
    T opCall(RNG)(ref RNG gen) const
        if (typeof(gen.front).sizeof == UIntType.sizeof)
    {
        import std.random : uniform;
        import std.traits : Signed;
        import std.range : ElementType;
        import std.math : abs;

        // TODO: option for inlining
        for (;;)
        {
            static if (bothSides)
                Signed!(ElementType!RNG) u = gen.front;
            else
                auto u = gen.front;

            gen.popFront();

            // TODO: this is a bit biased
            size_t i = u & kMask;
            //size_t i = uniform!("[)", size_t, size_t)(0, kMask, gen);

            // U * x_i < x_{i+1}
            static if (bothSides)
            {
                if (abs(u) < xDiv[i])
                    return u * xScaled[i];
            }
            else
            {
                if (u < xDiv[i])
                    return u * xScaled[i];
            }

            if (i == 0)
            {
                // generate x from tail block
                static if (bothSides)
                    return fallback(u > 0, gen);
                else
                    return fallback(gen);
            }
            else
            {
                auto x = u * xScaled[i];
                if (fs[i] + u * (fs[i - 1] - fs[i]) < pdf(x))
                    return x;
            }
        }
    }

private:
    mixin(_fallback);
}
