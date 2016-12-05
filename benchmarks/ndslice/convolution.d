#!/usr/bin/env dub
/+ dub.json:
{
    "name": "convolution",
    "dependencies": {"mir": {"path":"../.."}},
    "dflags-ldc": ["-mcpu=native"]
}
+/
/+
Benchmark demonstrates performance superiority of using mir.ndslice.algorithm over looped code, for
multidimensional processing with ndslice package.

$ ldc2 --version
LDC - the LLVM D compiler (918073):
  based on DMD v2.071.1 and LLVM 3.8.0
  built with LDC - the LLVM D compiler (918073)
  Default target: x86_64-apple-darwin15.6.0
  Host CPU: haswell
  http://dlang.org - http://wiki.dlang.org/LDC

$ dub run --build=release-nobounds --compiler=ldmd2 --single convolution.d
+/
import std.datetime : benchmark, Duration;
import std.stdio : writefln;
import std.conv : to;
import std.algorithm.comparison : min;

import mir.ndslice;
import mir.ndslice.internal : fastmath;

alias F = float;

@fastmath void convLoop(Slice!(2, F*) input, Slice!(2, F*) output, Slice!(2, F*) kernel)
{
    auto kr = kernel.length!0; // kernel row size
    auto kc = kernel.length!1; // kernel column size
    foreach (r; 0 .. output.length!0)
        foreach (c; 0 .. output.length!1)
        {
            // take window to input at given pixel coordinate
            Slice!(2, F*) window = input[r .. r + kr, c .. c + kc];

            // calculate result for current pixel
            F v = 0.0f;
            foreach (cr; 0 .. kr)
                foreach (cc; 0 .. kc)
                    v += window[cr, cc] * kernel[cr, cc];
            output[r, c] = v;
        }
}

static @fastmath F kapply(F v, F e, F k) @safe @nogc nothrow pure
{
    return v + (e * k);
}

void convAlgorithm(Slice!(2, F*) input, Slice!(2, F*) output, Slice!(2, F*) kernel)
{
    import mir.ndslice.algorithm : ndReduce, Yes;
    import mir.ndslice.selection : windows, mapSlice;

    auto mapping = input
        // look at each pixel through kernel-sized window
        .windows(kernel.shape)
        // map each window to resulting pixel using convolution function
        .mapSlice!((window) { return ndReduce!(kapply, Yes.vectorized)(0.0f, window, kernel); });

    // assign mapped results to the output buffer.
    output[] = mapping[];
}

// __gshared is used to prevent specialized optimization for input data
__gshared n = 256; // image size
__gshared m = 5; // kernel size
__gshared Slice!(2, F*) a;
__gshared Slice!(2, F*) b;
__gshared Slice!(2, F*) k;

void main()
{
    a = iotaSlice(n, n).mapSlice!(v => v.to!F).slice;
    b = a.slice;
    k = iotaSlice(m, m).mapSlice!(v => F(1) / F(m * m)).slice;

    Duration[2] bestBench = Duration.max;

    foreach (_; 0 .. 10)
    {
        auto bench = benchmark!(
            { convLoop(a, b, k); },
            { convAlgorithm(a, b, k); }
        )(100);
        foreach (i, ref b; bestBench)
            b = min(bench[i].to!Duration, b);
    }

    writefln("%26s = %s", "loops", bestBench[0]);
    writefln("%26s = %s", "mir.ndslice.algorithm", bestBench[1]);
}
