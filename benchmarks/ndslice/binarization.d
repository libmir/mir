#!/usr/bin/env dub
/+ dub.json:
{
    "name": "binarization",
    "dependencies": {"mir": {"path":"../.."}},
    "dflags-ldc": ["-mcpu=native"]
}
+/
/+
Benchmark demonstrates performance superiority of using mir.ndslice.topology.zip over
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

alias F = double;

void binarizationLockstep(Slice!(Contiguous, [2], F*) input, F threshold, Slice!(Contiguous, [2], F*) output)
{
    import std.range : lockstep;
    foreach(i, ref o; lockstep(input.flattened, output.flattened))
    {
        o = (i > threshold) ? F(1) : F(0);
    }
}

void binarizationAssumeSameStructure(Slice!(Contiguous, [2], F*) input, F threshold, Slice!(Contiguous, [2], F*) output)
{
    import mir.ndslice.algorithm : each;
    import mir.ndslice.topology : zip;

    zip(input, output).each!( (p) {
        p.b = (p.a > threshold) ? F(1) : F(0);
    });
}

// __gshared is used to prevent specialized optimization for input data
__gshared n = 256; // image size
__gshared Slice!(Contiguous, [2], F*) a;
__gshared Slice!(Contiguous, [2], F*) b;
__gshared F t; // threshold

void main()
{
    a = iota(n, n).as!F.slice;
    b = a.slice;
    t = n * n / 2;

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
    writefln("%26s = %s", "zip", bestBench[1]);
}
