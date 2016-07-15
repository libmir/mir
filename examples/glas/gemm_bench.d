#!/usr/bin/env dub
/+ dub.json:
{
	"name": "gemm_bench",
	"dependencies": {"mir": {"path": "../.."}, "cblas": "~>0.1.0"},
	"dflags-ldc": ["-mcpu=native"],
	"lflags": ["-L./"]
}
+/


import std.traits;
import std.datetime;
import std.conv;
import std.complex;
import std.algorithm;
import std.stdio;
import std.exception;
import mir.ndslice;
import mir.glas;

/// Complex!double 26 %
/// Complex!float 17 %
/// long 6.19104 vs 5.89937

/// double 36.563 vs 39.6906
/// float 76.2943 vs 80
/// real 1.41162 vs 1.04886

/// sse

// float 23.6126 vs 25.9729
// complex double 3.09874 3.06553
// complex float 5.07269 5.35169

alias C = long;
alias A = C;
alias B = C;

//2	0,16	0,0228571
//4	1,28	0,16
//8	5,12	0,930909
//16	16,384	3,90095
//32	27,3067	8,97753
//64	42,9744	18,0168
//128	61,6809	20,8672
//256	72,881	36,6475
//512	77,8322	54,4914
//1024	76,1006	67,889
//2048	76,8133	74,9434
//4096	77,5169	79,6514
//8192	77,9596	79,1658


//2	0,16	0,0228571
//4	1,28	0,16
//8	5,12	0,930909
//16	13,6533	3,15077
//32	19,2753	7,04688
//64	26,6136	7,07541
//128	32,4637	15,5057
//256	35,8794	20,5616
//512	38,8986	25,2194
//1024	38,6965	29,7032
//2048	37,611	33,947
//4096	37,0847	36,1249


void main(string[] args)
{
	foreach(pow; 1 .. 13)
	{
		size_t m = 2 ^^ pow;
		size_t n = m;
		size_t k = m;

		auto c = slice!C(m, n);
		auto a = slice!A(n, k);
		auto b = slice!B(k, n);
		auto d = slice!C(m, n);

		fillRNG(c);
		fillRNG(a);
		fillRNG(b);

		d[] = c[];

		static if(is(C : Complex!F, F))
			C alpha = C(3, 7);
		else
			C alpha = 3;

		write(m, "\t");

		C beta = 1;

		auto nsecsBLAS = double.max;

		StopWatch sw;

		foreach(_; 0..4) {
			static if(!(is(C == real) || is(C : Complex!real) || is(C : long)))
			{
				static import cblas;
			sw.reset;
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

				//foreach(i; 0..m)
				//foreach(j; 0..n)
				//foreach(e; 0..k)
				//	d[i, j] += alpha * a[i, e] * b[e, j];

				sw.stop;
				nsecsBLAS = min(sw.peek.to!Duration.total!"nsecs".to!double, nsecsBLAS);
			}

		}

			//writefln("BLAS (amount of threads is unknown): %5s GFLOPS, %s", (m * n * k * 2) / nsecsBLAS,  sw.peek.to!Duration);
			write((m * n * k * 2) / nsecsBLAS, "\t");


		auto nsecsGLAS = double.max;
		foreach(_; 0..4)
		{
			sw.reset;
			sw.start;
			c.gemm(alpha, a, b);
			sw.stop;
			nsecsGLAS = min(sw.peek.to!Duration.total!"nsecs".to!double, nsecsGLAS);
		}

		//writefln("GLAS (single thread)               : %5s GFLOPS, %s", (m * n * k * 2) /  nsecsGLAS,  sw.peek.to!Duration);
			write((m * n * k * 2) / nsecsGLAS, "\n");
	}
	//writeln("identical results = ", c == d);


	//writeln(a);
	//writeln(b);
	//writeln(c);
	//writeln(d);
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
