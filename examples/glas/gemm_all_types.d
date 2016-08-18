#!/usr/bin/env dub
/+ dub.sdl:
name "gemm_all_types"
dependency "mir" path="../.."
dflags "-O" "-inline"
+/

import std.meta, std.traits, std.stdio, std.complex, std.random;
import mir.glas.gemm;
import mir.glas.common;
import mir.ndslice;

void main()
{
	//openblas_set_num_threads(1);
	size_t i;
	//foreach(C; AliasSeq!(float, std.complex.Complex!real, long))
	//foreach(A; AliasSeq!(double, std.complex.Complex!float, uint))
	//foreach(B; AliasSeq!(real, std.complex.Complex!double, byte))
	foreach(C; AliasSeq!(Complex!double))
	foreach(A; AliasSeq!(Complex!double))
	foreach(B; AliasSeq!(Complex!double))
	foreach(conjugation; AliasSeq!(conjN))
	foreach(n; [nSeq])
	foreach(m; [mSeq])
	foreach(k; [kSeq])
	foreach(strideA; [1, 3, 4])
	foreach(strideB; [1, 2, 5])
	foreach(reverseC0; [flag])
	foreach(reverseC1; [flag])
	foreach(reverseA0; [flag])
	foreach(reverseA1; [flag])
	foreach(reverseB0; [flag])
	foreach(reverseB1; [flag])
	foreach(columnMajorA; [flag])
	foreach(columnMajorB; [flag])
	foreach(columnMajorC; [flag])
	{
		//writeln(i++);

		pragma(msg, A);
		pragma(msg, B);
		pragma(msg, C);

		static if(is(C : Complex!F, F))
			auto alpha = C(3, 7);
		else
			auto alpha = C(3);

		auto a = generateMatrix!A(columnMajorA, strideA, n, k);
		auto b = generateMatrix!B(columnMajorB, strideB, k, m);
		auto c = generateMatrix!C(columnMajorC,       1, n, m);
		//c[] = 0;
		if(reverseA0) a = a.reversed!0;
		if(reverseA1) a = a.reversed!1;
		if(reverseB0) b = b.reversed!0;
		if(reverseB1) b = b.reversed!1;
		if(reverseC0) c = c.reversed!0;
		if(reverseC1) c = c.reversed!1;
		auto t = c.slice; //copy

		referenceMatrixMultiplication!(conjugation, C, A, B)(t, alpha, a, b);
		glas.gemm!(conjugation)(c, alpha, a, b);
		if(c != t)
		{
			import std.format;
			throw new Exception(format("a = %s %s %s\nb = %s %s %s\nc = %s %s %s\nt = %s %s %s\n",
				A.stringof, a.structure, a,
				B.stringof, b.structure, b,
				C.stringof, c.structure, c,
				C.stringof, t.structure, t,
				));
		}
	}
}

//mixin template main()
//{

//}

alias nSeq = AliasSeq!(1, 3, 7, 8, 9, 17, 24, 100);
alias mSeq = nSeq;
alias kSeq = nSeq;

void referenceMatrixMultiplication(Conjugation type, C, A, B)(Slice!(2, C*) c, C alpha, Slice!(2, A*) a, Slice!(2, B*) b)
{
	static if(is(C : Complex!F, F))
		alias T = F;
	else
		alias T = C;

	auto alpha_re = re(alpha);
	auto alpha_im = im(alpha);

	b = b.transposed;
	foreach(i;  0 .. a.length!0)
	foreach(j;  0 .. b.length!0)
	{
		auto rowA = a[i];
		auto colB = b[j];
		foreach(k; 0 .. a.length!1)
		{
			auto a_re = cast(T) re(rowA[k]);
			auto a_im = cast(T) im(rowA[k]);
			auto b_re = cast(T) re(colB[k]);
			auto b_im = cast(T) im(colB[k]);

			static if(type == conjA)
				a_im = -a_im;
			static if(type == conjB)
				b_im = -b_im;

			auto p_re = a_re * b_re - a_im * b_im;
			auto p_im = a_re * b_im + a_im * b_re;

			auto c_re = p_re * alpha_re - p_im * alpha_im;
			auto c_im = p_re * alpha_im + p_im * alpha_re;

			static if(type == conjC)
				c_im -= c_im;

			c[i, j] += c_re;
			static if(is(C : Complex!F, F))
				c[i, j].im += c_im;
		}
	}
}

Slice!(2, T*) generateMatrix(T)(bool columnMajor, size_t stride, size_t a, size_t b)
{
	typeof(return) sl;
	if(columnMajor)
		sl = slice!T(b, a * stride).strided!1(stride).transposed;
	else
		sl = slice!T(a, b * stride).strided!1(stride);
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
	return sl;
}

T re(T)(T a) { return a; }
T im(T)(T a) { return T(0); }
F re(T : Complex!F, F)(T a) { return a.re; }
F im(T : Complex!F, F)(T a) { return a.im; }

alias allReals = AliasSeq!(float, double, real);
alias allComplex = staticMap!(Complex, allReals);
alias allSignedIntegers = AliasSeq!(byte, short, int, long);
alias allUnsignedIntegers = staticMap!(Unsigned, allSignedIntegers);

alias allTypes = AliasSeq!(
	allReals,
	allComplex,
	allSignedIntegers,
	allUnsignedIntegers,
	);

alias flag = AliasSeq!(true, false);
