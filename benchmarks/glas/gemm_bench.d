#!/usr/bin/env dub
/+ dub.json:
{
	"name": "gemm_bench",
	"dependencies": {"mir": {"path": "../.."}, "cblas": "~>1.0.0"},
	"dflags-ldc": ["-mcpu=native"],
	"libs": ["blas"],
	"lflags": ["-L./"]
}
+/
import std.math;
import std.traits;
import std.datetime;
import std.conv;
import std.algorithm.comparison;
import std.stdio;
import std.exception;
import std.getopt;
import mir.ndslice;
import mir.glas;
import mir.internal.utility : isComplex;

alias C = float;
//alias C = double;
//alias C = cfloat;
//alias C = cdouble;
alias A = C;
alias B = C;

void main(string[] args)
{
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

	static if(isComplex!C)
	{
		C alpha = 3 + 7i;
		C beta = 2 + 5i;
	}
	else
	{
		C alpha = 3;
		C beta = 2;
	}

	auto nsecsBLAS = double.max;

	foreach(_; 0..count) {
		StopWatch sw;
		sw.start;
		static if(!(is(C == real) || is(C == creal) || is(C : long)))
		{
			static import cblas;
			static if(isComplex!C)
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

		}
		sw.stop;

		auto newns = sw.peek.to!Duration.total!"nsecs".to!double;
		//writefln("_BLAS (amount of threads is unknown): %5s GFLOPS", (m * n * k * 2) / newns);

		nsecsBLAS = min(newns, nsecsBLAS);

	}
	auto nsecsGLAS = double.max;
	foreach(_; 0..count)
	{
		StopWatch sw;
		sw.start;
		gemm(alpha, a, b, beta, c);
		sw.stop;
		auto newns = sw.peek.to!Duration.total!"nsecs".to!double;
		//writefln("_GLAS (single thread)               : %5s GFLOPS", (m * n * k * 2) / newns);
		nsecsGLAS = min(newns, nsecsGLAS);
	}
	writefln("BLAS (amount of threads is unknown): %5s GFLOPS", (m * n * k * 2) / nsecsBLAS,);
	writefln("GLAS (single thread)               : %5s GFLOPS", (m * n * k * 2) / nsecsGLAS,);
	if(count == 1 && c != d)
	{
		writeln("results are very different");
	}
}

void fillRNG(T)(Slice!(2, T*) sl)
{
	import std.random;
	foreach(ref e; sl.byElement)
	{
		static if(isComplex!T)
		{
			e = uniform(-100, 100) + uniform(-100, 100) * 1i;
		}
		else
		{
			e = cast(T) uniform(-100, 100);
		}
	}
}
