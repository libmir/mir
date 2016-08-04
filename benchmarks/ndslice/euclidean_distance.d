#!/usr/bin/env dub
/+ dub.json:
{
    "name": "euclidean_distance",
    "dependencies": {"mir": {"path":"../.."}},
    "dflags-ldc": ["-mcpu=native"]
}
+/
/+
$ ldc2 --version
LDC - the LLVM D compiler (918073):
  based on DMD v2.071.1 and LLVM 3.8.0
  built with LDC - the LLVM D compiler (918073)
  Default target: x86_64-apple-darwin15.6.0
  Host CPU: haswell
  http://dlang.org - http://wiki.dlang.org/LDC

$ dub run --build=release-nobounds --compiler=ldmd2 --single dot_product.d

DOUBLE:
                ndReduce vectorized = 3 ms, 668 μs
                           ndReduce = 14 ms, 595 μs
  numeric.euclideanDistance, arrays = 14 ms, 463 μs
  numeric.euclideanDistance, slices = 14 ms, 465 μs
                       zip & reduce = 44 ms, 646 μs


FLOAT:
                ndReduce vectorized = 2 ms, 226 μs
                           ndReduce = 14 ms, 661 μs
  numeric.euclideanDistance, arrays = 14 ms, 597 μs
  numeric.euclideanDistance, slices = 14 ms, 581 μs
                       zip & reduce = 46 ms, 759 μs
+/
import std.numeric : euclideanDistance;
import std.typecons;
import std.datetime;
import std.stdio;
import std.range;
import std.algorithm;
import std.conv;
import std.math : sqrt;

import mir.ndslice;
import mir.ndslice.internal : fastmath;

alias F = double;

static @fastmath F distKernel(F a, F b, F c) @safe pure nothrow @nogc
{
    auto d = b - c;
    return a + d * d;
}

// __gshared is used to prevent specialized optimization for input data
__gshared F result;
__gshared n = 8000;
__gshared F[] a;
__gshared F[] b;
__gshared Slice!(1, F*) asl;
__gshared Slice!(1, F*) bsl;

void main()
{
    a = iota(n).map!(to!F).array;
    b = a.dup;
    asl = a.sliced;
    bsl = b.sliced;

    Duration[5] bestBench = Duration.max;

    foreach(_; 0 .. 10)
    {
        auto bench = benchmark!(
            { result = ndReduce!(distKernel, Yes.vectorized)(F(0), asl, bsl).sqrt; },
            { result = ndReduce!distKernel(F(0), asl, bsl).sqrt; },
            { result = euclideanDistance(a, b); },
            { result = euclideanDistance(a.sliced, b.sliced); },
            { result = reduce!((a, b) => distKernel(a, b[0], b[1]))(F(0), zip(a, b)).sqrt; },
        )(2000);
        foreach(i, ref b; bestBench)
            b = min(bench[i].to!Duration, b);
    }

    writefln("%35s = %s", "ndReduce vectorized", bestBench[0]);
    writefln("%35s = %s", "ndReduce", bestBench[1]);
    writefln("%35s = %s", "numeric.euclideanDistance, arrays", bestBench[2]);
    writefln("%35s = %s", "numeric.euclideanDistance, slices", bestBench[3]);
    writefln("%35s = %s", "zip & reduce", bestBench[4]);
}
