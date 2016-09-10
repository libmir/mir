#!/usr/bin/env dub
/+ dub.json:
{
	"name": "trmm_bench",
	"dependencies": {"mir": {"path": "../.."}, "cblas": "~>0.1.0"},
	"dflags-ldc": ["-mcpu=native"],
	"lflags": ["-L./"]
}
+/
import std.math;
import std.traits;
import std.datetime;
import std.conv;
import std.complex;
import std.algorithm.comparison;
import std.stdio;
import std.exception;
import std.getopt;
import mir.ndslice;
import mir.glas;

alias B = float;
//alias B = double;
//alias B = Complex!float;
//alias B = Complex!double;
alias A = B;

void main(string[] args)
{
	auto glas = new GlasContext;
	size_t m = 1000;
	size_t k = size_t.max;
	size_t count = 6;
	auto helpInformation = 
	getopt(args,
		"size_m|m", "Default value is " ~ m.to!string, &m, 
		"size_k|k", "Default value equals to m", &k, 
		"count|c", "Iteration count. Default value is " ~ count.to!string, &count);
	if (helpInformation.helpWanted)
	{
		defaultGetoptPrinter("Parameters:", helpInformation.options);
		return;
	}
	if(k == k.max)
		k = m;

	auto a = slice!A(k, k);
	auto b = slice!B(k, m);
	auto d = slice!B(k, m);

	fillRNG(a);
	fillRNG(b);

	auto s = b.slice;
	d[] = b[];

	static if(is(B : Complex!F, F))
		B alpha = B(3, 7);
	else
		B alpha = 1;

	auto nsecsBLAS = double.max;


	foreach(_; 0..count) {
		StopWatch sw;
		sw.start;
		static if(!(is(B == real) || is(B : Complex!real) || is(B : long)))
		{
			static import cblas;
			static if(is(B : Complex!E, E))
			cblas.trmm(
				cblas.Order.RowMajor,
				cblas.Side.Left,
				cblas.Uplo.Upper,
				cblas.Transpose.NoTrans,
				cblas.Diag.NonUnit,
				cast(cblas.blasint) k,
				cast(cblas.blasint) m,
				& alpha,
				a.ptr,
				cast(cblas.blasint) k,
				d.ptr,
				cast(cblas.blasint) m);
			else
			cblas.trmm(
				cblas.Order.RowMajor,
				cblas.Side.Left,
				cblas.Uplo.Upper,
				cblas.Transpose.NoTrans,
				cblas.Diag.NonUnit,
				cast(cblas.blasint) k,
				cast(cblas.blasint) m,
				alpha,
				a.ptr,
				cast(cblas.blasint) k,
				d.ptr,
				cast(cblas.blasint) m);
		}
		sw.stop;

		auto newns = sw.peek.to!Duration.total!"nsecs".to!double;
		//writefln("_BLAS (amount of threads is unknown): %5s GFLOPS", (m * m * k * 2) / newns);

		nsecsBLAS = min(newns, nsecsBLAS);

	}
	import std.stdio;
	writeln(b);
	auto nsecsGLAS = double.max;
	foreach(_; 0..count)
	{
		StopWatch sw;
		sw.start;
		glas.trmm(Uplo.upper, alpha, a, b);
		sw.stop;
		auto newns = sw.peek.to!Duration.total!"nsecs".to!double;
		//writefln("_GLAS (single thread)               : %5s GFLOPS", (m * m * k * 2) / newns);
		nsecsGLAS = min(newns, nsecsGLAS);
	}
	writefln("BLAS (amount of threads is unknown): %5s GFLOPS", (m * k * k + k) / nsecsBLAS,);
	writefln("GLAS (single thread)               : %5s GFLOPS", (m * k * k + k) / nsecsGLAS,);
	if(count == 1)
	{
		static if(is(B : Complex!E, E))
			auto equal = ndAll!((a, b) => approxEqual(a.re, b.re) && approxEqual(a.im, b.im))(b, d);
		else
			auto equal = ndAll!approxEqual(b, d);
		if(!equal)
		{
			import std.stdio;
			writeln(b);
			writeln(d);
			writeln("results are very different");
		}
	}
}

void fillRNG(T)(Slice!(2, T*) sl)
{
	import std.random;
	foreach(ref e; sl.byElement)
	{
		static if(is(T : Complex!F, F))
		{
			e.re = cast(F) uniform(1, 10);
			e.im = cast(F) uniform(1, 10);
		}
		else
		{
			e = cast(T) uniform(1, 10);
		}
	}
}
