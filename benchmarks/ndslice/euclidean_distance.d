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
+/
import std.numeric : euclideanDistance;
import std.datetime.stopwatch : benchmark, Duration;
import std.stdio;
import std.conv: to;
import std.range: std_zip = zip;
import std.algorithm: std_reduce = reduce;

import mir.array.allocation;
import mir.ndslice;
import mir.utility;
import mir.math.common : sqrt, fastmath;

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
__gshared Slice!(F*) asl;
__gshared Slice!(F*) bsl;

void main()
{
    a = iota(n).as!F.array;

    b = a.dup;
    asl = a.sliced;
    bsl = b.sliced;

    Duration[4] bestBench = Duration.max;

    foreach(_; 0 .. 10)
    {
        auto bench = benchmark!(
            { result = reduce!distKernel(F(0), asl, bsl).sqrt; },
            { result = euclideanDistance(a, b); },
            { result = euclideanDistance(asl, bsl); },
            { result = std_reduce!((a, b) => distKernel(a, b[0], b[1]))(F(0), std_zip(a, b)).sqrt; },
        )(2000);
        foreach(i, ref b; bestBench)
            b = min(bench[i].to!Duration, b);
    }

    writefln("%35s = %s", "Mir: reduce", bestBench[0]);
    writefln("%35s = %s", "numeric.euclideanDistance, arrays", bestBench[1]);
    writefln("%35s = %s", "numeric.euclideanDistance, slices", bestBench[2]);
    writefln("%35s = %s", "zip & reduce", bestBench[3]);
}
