#!/usr/bin/env dub
/+ dub.json:
{
    "name": "binarization",
    "dependencies": {"mir": {"path":"../.."}},
    "dflags-ldc": ["-mcpu=native"]
}
+/
/+
Benchmark demonstrates performance superiority of using mir.ndslice.slice.assumeSameStructure over
std.range.lockstep, for multidimensional processing with ndslice package.

$ ldc2 --version
LDC - the LLVM D compiler (918073):
  based on DMD v2.071.1 and LLVM 3.8.0
  built with LDC - the LLVM D compiler (918073)
  Default target: x86_64-apple-darwin15.6.0
  Host CPU: haswell
  http://dlang.org - http://wiki.dlang.org/LDC

$ dub run --build=release-nobounds --compiler=ldmd2 --single binarization.d
+/
import std.datetime : benchmark, Duration;
import std.stdio : writefln;
import std.conv : to;
import std.algorithm.comparison : min;

import mir.ndslice;
import mir.ndslice.internal : fastmath;

alias F = float;

void binarizationLockstep(Slice!(2, F*) input, F threshold, Slice!(2, F*) output)
{
    import std.range : lockstep;
    foreach(i, ref o; lockstep(input.byElement, output.byElement))
    {
        o = (i > threshold) ? F(1) : F(0);
    }
}

void binarizationAssumeSameStructure(Slice!(2, F*) input, F threshold, Slice!(2, F*) output)
{
    import mir.ndslice.algorithm : ndEach;
    import mir.ndslice.slice : assumeSameStructure;

    assumeSameStructure!("input", "output")(input, output).ndEach!( (p) {
        p.output = (p.input > threshold) ? F(1) : F(0);
    });
}

// __gshared is used to prevent specialized optimization for input data
__gshared n = 256; // image size
__gshared Slice!(2, F*) a;
__gshared Slice!(2, F*) b;
__gshared F t; // threshold

void main()
{
    import std.random : uniform;

    a = iotaSlice(n, n).mapSlice!(v => v.to!F).slice;
    b = a.slice;
    t = uniform(F(0), F(n*n));

    Duration[2] bestBench = Duration.max;

    foreach (_; 0 .. 10)
    {
        auto bench = benchmark!(
            { binarizationLockstep(a, t, b); },
            { binarizationAssumeSameStructure(a, t, b); }
        )(1_000);
        foreach (i, ref b; bestBench)
            b = min(bench[i].to!Duration, b);
    }

    writefln("%26s = %s", "lockstep", bestBench[0]);
    writefln("%26s = %s", "assumeSameStructure", bestBench[1]);
}
