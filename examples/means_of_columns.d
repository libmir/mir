#!/usr/bin/env dub
/+ dub.json:
{
    "name": "means_of_columns",
    "dependencies": {"mir": {"path": ".."}},
}
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

import std.datetime;
import std.conv : to;
import std.stdio;
import mir.ndslice;

enum testCount = 10_000;
__gshared Slice!(Contiguous, [1], double*) means;
Slice!(Contiguous, [2], int*) sl;

void main() {
    sl = iota!int(100, 1000).slice;
    auto r = benchmark!({
    	means = sl
        .universal
        .transposed
        .pack!1
        .map!(col => reduce!"a + b"(0L, col) / double(col.length))
        .slice;
        })(testCount)[0].to!Duration / testCount;
    r.writeln;
}
