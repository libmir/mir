#!/usr/bin/env dub
/+ dub.json:
{
	"name": "gemm_bench",
	"dependencies": {"mir": {"path": "../.."}, "cblas": "~>0.1.0"},
	"dflags-ldc": ["-mcpu=native"],
	"lflags": ["-L./"]
}
+/
// dub --compiler=ldmd2 -b release --single benchmarks/glas/gemm_report.d
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

//alias C = float;
alias C = double;
//alias C = Complex!float;
//alias C = Complex!double;
alias A = C;
alias B = C;

size_t[] reportValues = [
	10, 20, 30, 40, 50, 60, 70, 80, 90, 100,
	200, 300, 500, 600, 700, 800, 900, 1000,
	1200, 1400, 1600, 1800, 2000];

void main(string[] args)
{
	auto glas = new GlasContext;
	size_t count = 6;
	auto helpInformation = 
	getopt(args,
		"count|c", "Iteration count. Default value is " ~ count.to!string, &count);
	if (helpInformation.helpWanted)
	{
		defaultGetoptPrinter("Parameters:", helpInformation.options);
		return;
	}

	writeln("m=n=k,GLAS(thread_count=1),OpenBLAS(thread_count=?)");
	foreach(m; reportValues)
	{
		auto n = m;
		auto k = m;

		auto d = slice!C(m, n);
		auto c = slice!C(m, n);
		auto a = slice!A(m, k);
		auto b = slice!B(k, n);

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
			glas.gemm(alpha, a, b, beta, c);
			sw.stop;
			auto newns = sw.peek.to!Duration.total!"nsecs".to!double;
			//writefln("_GLAS (single thread)               : %5s GFLOPS", (m * n * k * 2) / newns);
			nsecsGLAS = min(newns, nsecsGLAS);
		}
		writefln("%s,%s,%s", m, (m * n * k * 2) / nsecsGLAS, (m * n * k * 2) / nsecsBLAS);
		if(count == 1 && c != d)
		{
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
			e.re = cast(F) uniform(-100, 100);
			e.im = cast(F) uniform(-100, 100);
		}
		else
		{
			e = cast(T) uniform(-100, 100);
		}
	}
}
