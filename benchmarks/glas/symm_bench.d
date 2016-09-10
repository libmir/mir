#!/usr/bin/env dub
/+ dub.json:
{
	"name": "symm_bench",
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

alias C = float;
//alias C = double;
//alias C = Complex!float;
//alias C = Complex!double;
alias A = C;
alias B = C;

void main(string[] args)
{
	auto glas = new GlasContext;
	size_t m = 1000;
	size_t n = size_t.max;
	size_t k = size_t.max;
	size_t count = 6;
	bool trans;
	auto helpInformation = 
	getopt(args,
		"cm", "C is column major", &trans, 
		"size_m|m", "Default value is " ~ m.to!string, &m, 
		"size_n|n", "Default value equals to m", &n,
		"count|c", "Iteration count. Default value is " ~ count.to!string, &count);
	if (helpInformation.helpWanted)
	{
		defaultGetoptPrinter("Parameters:", helpInformation.options);
		return;
	}
	if(n == n.max)
		n = m;

	auto c = trans ? slice!C(m, n) : slice!C(n, m).transposed;
	auto d = slice!C(m, n);
	auto a = slice!A(m, m);
	auto b = slice!B(m, n);

	fillRNG(c);
	fillRNG(a);
	fillRNG(b);

	d[] = c[];

	static if(is(C : Complex!F, F))
	{
		C alpha = C(3, 7);
		C beta = C(2, 5);
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
		static if(!(is(C == real) || is(C : Complex!real) || is(C : long)))
		{
			static import cblas;
			static if(is(C : Complex!E, E))
			cblas.symm(
				cblas.Order.RowMajor,
				cblas.Side.Left,
				cblas.Uplo.Lower,
				cast(cblas.blasint) m,
				cast(cblas.blasint) n,
				& alpha,
				a.ptr,
				cast(cblas.blasint) a.stride,
				b.ptr,
				cast(cblas.blasint) b.stride,
				& beta,
				d.ptr,
				cast(cblas.blasint) d.stride);
			else
			cblas.symm(
				cblas.Order.RowMajor,
				cblas.Side.Left,
				cblas.Uplo.Lower,
				cast(cblas.blasint) m,
				cast(cblas.blasint) n,
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
		//writefln("_BLAS (amount of threads is unknown): %5s GFLOPS", (m * n * m * 2) / newns);

		nsecsBLAS = min(newns, nsecsBLAS);

	}
	auto nsecsGLAS = double.max;
	foreach(_; 0..count)
	{
		StopWatch sw;
		sw.start;
		glas.symm(Side.left, Uplo.lower, alpha, a, b, beta, c);
		sw.stop;
		auto newns = sw.peek.to!Duration.total!"nsecs".to!double;
		//writefln("_GLAS (single thread)               : %5s GFLOPS", (m * n * m * 2) / newns);
		nsecsGLAS = min(newns, nsecsGLAS);
	}
	writefln("BLAS (amount of threads is unknown): %5s GFLOPS", (m * n * m * 2) / nsecsBLAS,);
	writefln("GLAS (single thread)               : %5s GFLOPS", (m * n * m * 2) / nsecsGLAS,);
	if(count == 1 && c != d)
	{
		//writefln("a =\n%(%(%4s %)\n%)\n", a);
		//writefln("b =\n%(%(%4s %)\n%)\n", b);
		//writefln("c =\n%(%(%4s %)\n%)\n", c);
		//writefln("d =\n%(%(%4s %)\n%)\n", d);
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
			e.re = cast(F) uniform(-100, 100);
			e.im = cast(F) uniform(-100, 100);
		}
		else
		{
			e = cast(T) uniform(-100, 100);
		}
	}
}
