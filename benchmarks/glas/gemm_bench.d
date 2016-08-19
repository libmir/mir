#!/usr/bin/env dub
/+ dub.json:
{
	"name": "gemm_bench",
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
import std.algorithm;
import std.stdio;
import std.exception;
import std.getopt;
import mir.ndslice;
import mir.glas;

//alias C = Complex!float;
//alias C = Complex!double;
alias C = float;
//alias C = double;
alias A = C;
alias B = C;


void main(string[] args)
{
	auto glas = new GlasContext;
	size_t m = 1000;
	size_t n = size_t.max;
	size_t k = size_t.max;
	size_t count = 6;
	auto helpInformation = 
	getopt(args,
		"size_m|m", "Default value is " ~ m.to!string, &m, 
		"size_n|n", "Default value equals to m", &n,
		"size_k|k", "Default value equals to m", &k, 
		"count|c", "Iteration count. Default value is " ~ count.to!string, &count);
	if (helpInformation.helpWanted)
	{
		defaultGetoptPrinter("Parameters:", helpInformation.options);
		return;
	}
	if(n == n.max)
		n = m;
	if(k == k.max)
		k = m;

	auto d = slice!C(m, n);
	auto c = slice!C(m, n);
	auto a = slice!A(m, k);
	auto b = slice!B(k, n);

	fillRNG(c);
	fillRNG(a);
	fillRNG(b);

	d[] = c[];

	static if(is(C : Complex!F, F))
		C alpha = C(3, 7);
	else
		C alpha = 3;

	C beta = 1;

	auto nsecsBLAS = double.max;

	foreach(_; 0..count) {
		static if(!(is(C == real) || is(C : Complex!real) || is(C : long)))
		{
			static import cblas;
		StopWatch sw;
		sw.start;

			static if(is(C : Complex!E, E))
			cblas.gemm(
				cblas.Order.RowMajor,
				cblas.Transpose.NoTrans,
				cblas.Transpose.NoTrans,
				cast(cblas.blasint) m,
				cast(cblas.blasint) n,
				cast(cblas.blasint) k,
				& alpha,
				a.ptr,
				cast(cblas.blasint) a.stride,
				b.ptr,
				cast(cblas.blasint) b.stride,
				& beta,
				d.ptr,
				cast(cblas.blasint) d.stride);
			else
			cblas.gemm(
				cblas.Order.RowMajor,
				cblas.Transpose.NoTrans,
				cblas.Transpose.NoTrans,
				cast(cblas.blasint) m,
				cast(cblas.blasint) n,
				cast(cblas.blasint) k,
				alpha,
				a.ptr,
				cast(cblas.blasint) a.stride,
				b.ptr,
				cast(cblas.blasint) b.stride,
				beta,
				d.ptr,
				cast(cblas.blasint) d.stride);

			sw.stop;
			nsecsBLAS = min(sw.peek.to!Duration.total!"nsecs".to!double, nsecsBLAS);
		}

	}
	auto nsecsGLAS = double.max;
	foreach(_; 0..count)
	{
		StopWatch sw;
		sw.start;
		glas.gemm(c, alpha, a, b);
		sw.stop;
		nsecsGLAS = min(sw.peek.to!Duration.total!"nsecs".to!double, nsecsGLAS);
	}
	writefln("BLAS (amount of threads is unknown): %5s GFLOPS", (m * n * k * 2) / nsecsBLAS,);
	writefln("GLAS (single thread)               : %5s GFLOPS", (m * n * k * 2) / nsecsGLAS,);
	static if(is(C : Complex!E, E))
		auto equal = ndAll!((a, b) => approxEqual(a.re, b.re) && approxEqual(a.im, b.im))(c, d);
	else
		auto equal = ndAll!approxEqual(c, d);
	if(!equal)
	{
		writeln("results are very different");
	}
}

void fillRNG(T)(Slice!(2, T*) sl)
{
	import std.random;
	foreach(ref e; sl.byElement)
	{
		static if(is(T : Complex!F, F))
		{
			e.re = cast(F) uniform(0, 10);
			e.im = cast(F) uniform(0, 10);
		}
		else
		{
			e = cast(T) uniform(0, 10);
		}
	}
}
