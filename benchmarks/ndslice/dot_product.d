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
+/
import std.numeric : dotProduct;
import std.array;
import std.typecons;
import std.datetime;
import std.stdio;
import std.conv;
import std.range: std_zip = zip;
import std.algorithm: std_reduce = reduce;

import mir.ndslice;
import mir.utility;
import mir.ndslice.internal : fastmath;

alias F = float;

static @fastmath F fmuladd(F a, F b, F c) @safe pure nothrow @nogc
{
    return a + b * c;
}

// __gshared is used to prevent specialized optimization for input data
__gshared F result;
__gshared n = 8000;
__gshared F[] a;
__gshared F[] b;
__gshared Slice!(Contiguous, [1], F*) asl;
__gshared Slice!(Contiguous, [1], F*) bsl;

void main()
{
    a = iota(n).as!F.array;
    b = a.dup;
    asl = a.sliced;
    bsl = b.sliced;

    Duration[5] bestBench = Duration.max;

    foreach(_; 0 .. 10)
    {
        auto bench = benchmark!(
            { result = reduce!fmuladd(F(0), asl, bsl); },
            { result = dotProduct(a, b); },
            { result = dotProduct(a.sliced, b.sliced); },
            { result = std_reduce!"a + b[0] * b[1]"(F(0), std_zip(a, b)); },
        )(2000);
        foreach(i, ref b; bestBench)
            b = min(bench[i].to!Duration, b);
    }

    writefln("%26s = %s", "Mir: reduce", bestBench[1]);
    writefln("%26s = %s", "numeric.dotProduct, arrays", bestBench[2]);
    writefln("%26s = %s", "numeric.dotProduct, slices", bestBench[3]);
    writefln("%26s = %s", "zip & reduce", bestBench[4]);
}
