#!/usr/bin/env dub
/+ dub.json:
{
    "name": "dot_product",
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
       ndReduce vectorized = 3 ms, 314 μs
                  ndReduce = 14 ms, 767 μs
numeric.dotProduct, arrays = 7 ms, 260 μs
numeric.dotProduct, slices = 14 ms, 782 μs
              zip & reduce = 44 ms, 57 μs

FLOAT:
       ndReduce vectorized = 2 ms, 200 μs
                  ndReduce = 14 ms, 543 μs
numeric.dotProduct, arrays = 7 ms, 208 μs
numeric.dotProduct, slices = 14 ms, 414 μs
              zip & reduce = 43 ms, 657 μs
+/
import std.numeric : dotProduct;
import std.typecons;
import std.datetime;
import std.stdio;
import std.range;
import std.algorithm;
import std.conv;

import mir.ndslice;
import mir.ndslice.internal : fastmath;

alias F = double;

static @fastmath F fmuladd(F a, F b, F c) @safe pure nothrow @nogc
{
    return a + b * c;
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
            { result = ndReduce!(fmuladd, Yes.vectorized)(F(0), asl, bsl); },
            { result = ndReduce!(fmuladd)(F(0), asl, bsl); },
            { result = dotProduct(a, b); },
            { result = dotProduct(a.sliced, b.sliced); },
            { result = reduce!"a + b[0] * b[1]"(F(0), zip(a, b)); },
        )(2000);
        foreach(i, ref b; bestBench)
            b = min(bench[i].to!Duration, b);
    }

    writefln("%26s = %s", "ndReduce vectorized", bestBench[0]);
    writefln("%26s = %s", "ndReduce", bestBench[1]);
    writefln("%26s = %s", "numeric.dotProduct, arrays", bestBench[2]);
    writefln("%26s = %s", "numeric.dotProduct, slices", bestBench[3]);
    writefln("%26s = %s", "zip & reduce", bestBench[4]);
}
