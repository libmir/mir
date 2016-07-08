#!/usr/bin/env dub
/+ dub.sdl:
name "means_of_columns"
dependency "mir" path=".."
+/

/**
* This code uses std.experimental.ndslice to take the mean of the columns in
* a 2d 100x1000 array and creates a benchmark of that code. Running on a 2015
* MacBook Pro with a 2.9 GHz Intel Core Broadwell i5, the mean running time
* of this code is 40 µs when compiled with LDC v0.17.0-alpha1.
*
* If we compare this code to the Numpy equivalent,
*
*     import numpy
*     data = numpy.arange(100000).reshape((100, 1000))
*     means = numpy.mean(data, axis=0)
*
* and we benchmark the numpy.mean line using the following Python command,
*
*    python -m timeit \
*         -s 'import numpy; data = numpy.arange(100000).reshape((100, 1000))' \
*         'means = numpy.mean(data, axis=0)'
*
* then we get a mean running time of 145 µs. That means the version D is 3.625x
* faster than the numpy version.
*/

import std.range : iota;
import std.array : array;
import std.algorithm;
import std.datetime;
import std.conv : to;
import std.stdio;
import mir.ndslice;

enum testCount = 10_000;
double[] means;
int[] data;

void f0() {
    means = data
        .sliced(100, 1000)
        .transposed
        .map!(r => sum(r, 0L) / cast(double) r.length)
        .array;
}

void main() {
    data = 100_000.iota.array;
    auto r = benchmark!(f0)(testCount);
    auto f0Result = to!Duration(r[0] / testCount);
    f0Result.writeln;
}
