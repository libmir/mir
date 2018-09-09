#!/usr/bin/env dub
/+ dub.json:
{
    "name": "convolution",
    "dependencies": {"mir": {"path":"../.."}},
    "dflags-ldc": ["-mcpu=native"]
}
+/
/+
Benchmark demonstrates performance superiority of using mir.algorithm.iteration over looped code, for
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
import std.datetime.stopwatch : benchmark, Duration;
import std.stdio : writefln;
import std.conv : to;
import mir.utility : min;

import mir.ndslice;
import mir.math.common : fastmath;

alias F = double;

@fastmath void convLoop(Slice!(F*, 2) input, Slice!(F*, 2) output, Slice!(F*, 2) kernel)
{
    auto kr = kernel.length!0; // kernel row size
    auto kc = kernel.length!1; // kernel column size
    foreach (r; 0 .. output.length!0)
        foreach (c; 0 .. output.length!1)
        {
            // take window to input at given pixel coordinate
            Slice!(F*, 2, Canonical) window = input[r .. r + kr, c .. c + kc];

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

void convAlgorithm(Slice!(F*, 2) input, Slice!(F*, 2) output, Slice!(F*, 2) kernel)
{
    import mir.algorithm.iteration : reduce;
    import mir.ndslice.topology : windows, map;

    auto mapping = input
        // look at each pixel through kernel-sized window
        .windows(kernel.shape)
        // map each window to resulting pixel using convolution function
        .map!((window) { return reduce!kapply(0.0f, window, kernel); });

    // assign mapped results to the output buffer.
    output[] = mapping[];
}

// __gshared is used to prevent specialized optimization for input data
__gshared n = 256; // image size
__gshared m = 5; // kernel size
__gshared Slice!(F*, 2) a;
__gshared Slice!(F*, 2) b;
__gshared Slice!(F*, 2) k;

void main()
{
    a = iota(n, n).as!F.slice;
    b = a.slice;
    k = iota(m, m).map!(v => F(1) / F(m * m)).slice;

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
    writefln("%26s = %s", "mir.algorithm.iteration", bestBench[1]);
}
