/++
$(H2 General Matrix-Matrix Multiplication)

$(SCRIPT inhibitQuickIndex = 1;)

This is a submodule of $(LINK2 mir_glas.html, mir.glas).

License: $(LINK2 http://boost.org/LICENSE_1_0.txt, Boost License 1.0).

Authors: Ilya Yaroshenko

Macros:
SUBMODULE = $(LINK2 mir_glas_$1.html, mir.glas.$1)
SUBREF = $(LINK2 mir_glas_$1.html#.$2, $(TT $2))$(NBSP)
+/
module mir.glas.gemm;

import std.traits;
import std.meta;
import mir.ndslice.slice;
import mir.glas.context;
import mir.glas.common;
import mir.internal.utility;
import mir.glas.internal.config;

@fastmath:

alias gemm1 = gemm!(conjN, double, double, double);

/++
General matrix-vector multiplication.

Params:
    alpha = scalar
    a = matrix
    b = matrix
    c = matrix
    type = conjugation type, optional template parameter

Pseudo_code: `c += a × b`

Note:
    GLAS does not requre transposition parameters.
    Use $(LINK2 mir_ndslice_iteration.html#transposed, mir.ndslice.iteration.transposed)
    to perform zero cost `Slice` transposition.

BLAS: SGEMM, DGEMM, CGEMM, ZGEMM

See_also: $(SUBREF common, Conjugation)
+/
nothrow @nogc
void gemm(Conjugation type = conjN, C, A, B)
(
    Slice!(2, C*) csl,
    C alpha,
        Slice!(2, A*) asl,
        Slice!(2, B*) bsl,
)
    if(type == conjN || type == conjA || type == conjB || type == conjC)
in
{
    assert(asl.length!1 == bsl.length!0, "constraint: asl.length!1 == bsl.length!0");
    assert(csl.length!0 == asl.length!0, "constraint: csl.length!0 == asl.length!0");
    assert(csl.length!1 == bsl.length!1, "constraint: csl.length!1 == bsl.length!1");
    assert(csl.stride!0 == +1
        || csl.stride!0 == -1
        || csl.stride!1 == +1
        || csl.stride!0 == -1, "constraint: csl.stride!0 or csl.stride!1 must be equal to +/-1");
}
body
{
    import std.complex: Complex;
    import std.experimental.allocator.mallocator: AlignedMallocator; 
    import mir.ndslice.iteration: reversed, transposed;

    enum msg = "mir.glas does not allow slices on top of const/immutable/shared memory";
    static assert(is(Unqual!A == A), msg);
    static assert(is(Unqual!B == B), msg);
    static assert(is(Unqual!C == C), msg);

    enum CC = isComplex!C;
    enum CA = isComplex!A && (isComplex!C || isComplex!B);
    enum CB = isComplex!B && (isComplex!C || isComplex!A);

    enum PC = CC ? 2 : 1;
    enum PA = CA ? 2 : 1;
    enum PB = CB ? 2 : 1;

    static if(is(C : Complex!F, F))
        alias T = F;
    else
        alias T = C;
    static assert(!isComplex!T);

    if(asl.empty!0)
        return;
    if(asl.empty!1)
        return;
    if(bsl.empty!1)
        return;
    if(alpha == 0)
        return;

    if(csl.stride!0 < 0)
    {
        csl = csl.reversed!0;
        asl = asl.reversed!0;
    }
    if(csl.stride!1 < 0)
    {
        csl = csl.reversed!1;
        bsl = bsl.reversed!1;
    }

    // change row based to column based
    if(csl.stride!1 == 1)
    {
        static if(is(A == B))
        {
            auto tsl = asl;
            asl = bsl.transposed;
            bsl = tsl.transposed;
            csl = csl.transposed;
        }
        else
        {
            gemm!(swapConj!type, C, B, A)(csl.transposed, alpha, bsl.transposed, asl.transposed);
            return;
        }
    }
    assert(csl.stride!0 == 1);

    auto alpha_ = alpha.statComplex;

    uint pagesize = 4096;
    size_t l2size = 4096 * 1024;
    // determine kc
    size_t kc = 100;
    // compute mc
    size_t mc = 100;

    import std.stdio;

    auto _mem = AlignedMallocator.instance.alignedAllocate(l2size + T.sizeof * PB * mc * bsl.length!1, pagesize);
    auto a = cast(T*) _mem.ptr;
    auto b = cast(T[PB]*) (_mem.ptr + l2size);

    for(;;)
    {
        if(asl.length!1 < kc)
        {
            if(asl.empty!1)
                break;
            kc = asl.length!1;
            // compute mc
        }
        //writeln("#a");

        auto aslp = asl.transposed[0 .. kc].transposed;
        pack_b_nano_kernel!(PC, PA, PB, T, B)(bsl[0 .. kc].transposed, cast(T*) b);
        //writeln(b[0..bsl.elementsCount]);
        bsl.popFrontExactly!0(kc);

        auto c = cast(T[PC]*) csl.ptr;

        for(;;)
        {
        //writeln("#b");
            if(aslp.length!0 < mc)
            {
                if(aslp.empty!0)
                    break;
                mc = aslp.length!0;
            }

            pack_a_nano_kernel!(PC, PA, PB, T, A)(aslp[0 .. mc], a);
            //writeln(a[0..asl.elementsCount],);
            aslp.popFrontExactly!0(mc);

            gebp_opt1!(type, PC, PA, PB, T)(bsl.length!1, kc, mc, csl.stride!1, c, alpha_, a, b);
            c += mc;
        }

        asl.popFrontExactly!1(kc);
    }
    AlignedMallocator.instance.deallocate(a[0..0]);
}


///
unittest
{
    auto a = slice!double(3, 5);
    a[] =
        [[-5, 1, 7, 7, -4],
         [-1, -5, 6, 3, -3],
         [-5, -2, -3, 6, 0]];

    auto b = slice!double(5, 4);
    b[] =
        [[-5.0, -3, 3, 1],
         [4.0, 3, 6, 4],
         [-4.0, -2, -2, 2],
         [-1.0, 9, 4, 8],
         [9.0, 8, 3, -2]];

    auto c = slice!double(3, 4);
    c[] = 0;
    import std.stdio;
    writeln("aaaa");

    gemm(c, 1.0, a, b);

    assert(c ==
        [[-42.0, 35, -7, 77],
         [-69.0, -21, -42, 21],
         [23.0, 69, 3, 29]]);
    writeln("bbbb");
}


unittest
{
    import std.meta: AliasSeq;
    with(Conjugation)
    foreach (type; AliasSeq!(none, conjA, conjB))
    {
        enum P = type == none ? 1 : 2;
        {alias temp = gemm_micro_kernel!(type, P, P, P, 2 / P, 4 / P, float, float);}
        {alias temp = gemm_micro_kernel!(type, P, P, P, 2 / P, 4 / P, double, double);}
        version(X86_64)
        {
            {alias temp = gemm_micro_kernel!(type, P, P, P, 2 / P, 4 / P, __vector(float[4]), float);}
            {alias temp = gemm_micro_kernel!(type, P, P, P, 2 / P, 4 / P, __vector(double[2]), double);}
        }
        version(LDC)
        {
            {alias temp = gemm_micro_kernel!(type, P, P, P, 2 / P, 4 / P, __vector(float[8]), float);}
            {alias temp = gemm_micro_kernel!(type, P, P, P, 2 / P, 4 / P, __vector(double[4]), double);}
        }
    }
}

//alias gk = gemm_kernel!(D, conjN);

//alias gkInner = gk.gemm_var1!(D*, D*, D*);



//alias comp = gebp_opt1!(conjN, 2,
//  __vector(double[4])[1][2],
//  __vector(double[4])[1][2],
//  __vector(double[2])[1][2],
//  double[1][2]
//);

//alias compInner = comp!(double, D, double*, double*);

unittest
{

    import std.complex;
    alias T = real;
    alias D = real;


    import std.stdio;
    import std.random;
    import mir.ndslice;

    auto m = 111, n = 123, k = 213;

    auto a = slice!(D)(m, k);
    auto b = slice!(D)(k, n);

    auto c = slice!(D)(m, n);
    auto d = slice!(D)(m, n);
    D alpha = 3;
    import std.stdio;
    writeln(alpha);

    //writeln("AB ...");

    static if(isComplex!D)
    {

        foreach(ref e; a.byElement)
            e = complex(uniform(0, 5), uniform(0, 5));

        foreach(ref e; b.byElement)
            e = complex(uniform(0, 5), uniform(0, 5));

        foreach(ref e; c.byElement)
            e = complex(uniform(0, 5), uniform(0, 5));
    }
    else
    {
        foreach(ref e; a.byElement)
            e = uniform(ubyte(0), ubyte(5));

        foreach(ref e; b.byElement)
            e = uniform(ubyte(0), ubyte(5));

        foreach(ref e; c.byElement)
            e = uniform(ubyte(0), ubyte(5));
    }


    d[] = c[];

    writeln("D ...");

    foreach(i; 0..a.length)
        foreach(j; 0..b.length!1)
            foreach(r; 0..b.length)
                d[i, j] += alpha * a[i, r] * b[r, j];

    writeln("C ...");

    //gemm(c, 1, a, b);
    gemm(c, alpha, a, b);
    assert(c == d);
    //D alpha = 1;
    //D beta = 1;

    //gkInner(alpha.statComplex, beta.statComplex, aptr, bptr, cptr, 100, 200, a, b, c);

    //writefln("a = [\n%(\t%s,\n%)\n]", a);
    //writefln("b = [\n%(\t%s,\n%)\n]", b);
    //writefln("d = [\n%(\t%s,\n%)\n]", d);
    //writefln("c = [\n%(\t%s,\n%)\n]", c);

    //assert(c == d);

    //auto mir = gkInner();
}

package:

pragma(inline, false)
void pack_a_nano_kernel(size_t PC, size_t PA, size_t PB, T, C)(Slice!(2, C*) sl, T* a)
{
    import std.complex: Complex;
    version(LDC)
        enum LDC = true;
    else
        enum LDC = false;
    import mir.ndslice.iteration: transposed;
    alias conf = RegisterConfig!(PC, PA, PB, T);
    alias mrTypeChain = conf.simdChain;
    import std.stdio;
    import std.conv: to;
    import std.stdio;
    alias chain = conf.broadcastChain;
    foreach(mri, mrType; mrTypeChain)
    {
        enum mr = mrType.sizeof / T.sizeof;
        if(sl.length >= mr) do
        {
        //writeln("#e ", mr);
            // TODO: opitimize
            foreach(row; sl[0 .. mr].transposed)
            {
                foreach(j; Iota!mr)
                {
                    static if(PA == 2)
                    {
                        a[ 0 + j] = cast(T) row[j].re;
                        a[mr + j] = cast(T) row[j].im;
                    }
                    else
                    {
                        a[j] = cast(T) row[j];
                    }
                }
                a += mr * PA;
            }
            sl.popFrontExactly(mr);
        }
        while(!mri && sl.length >= mr);
    }
}

pragma(inline, false)
void pack_b_nano_kernel(size_t PC, size_t PA, size_t PB, T, C)(Slice!(2, C*) sl, T* b)
{
    import mir.ndslice.iteration: transposed;
    alias conf = RegisterConfig!(PC, PA, PB, T);
    import std.stdio;
    import std.conv: to;
    alias nrChain = conf.broadcastChain;
    foreach(nri; Iota!(nrChain.length))
    {
        enum nr = nrChain[nri];
        if(sl.length >= nr) do
        {
        //writeln("#f");
            // TODO: opitimize
            foreach(row; sl[0 .. nr].transposed)
            {
                foreach(j; Iota!nr)
                {
                    static if(PB == 2)
                    {
                        b[2 * j + 0] = cast(T) row[j].re;
                        b[2 * j + 1] = cast(T) row[j].im;
                    }
                    else
                    {
                        b[j] = cast(T) row[j];
                    }
                }
                b += nr * PB;
            }
            sl.popFrontExactly(nr);
        }
        while(!nri && sl.length >= nr);
    }
}

pragma(inline, false)
void gebp_opt1(Conjugation type, size_t PC, size_t PA, size_t PB, T)(
    size_t n,
    const size_t kc,
    const size_t mc_,
    const size_t ldc,
    scope T[PC]* c_,
    const T[PC] alpha,
    const(T)* a_,
    const(T[PB])* b,
    )
{
    alias conf = RegisterConfig!(PC, PA, PB, T);
    alias nrChain = conf.broadcastChain;
    alias mrTypeChain = conf.simdChain;

    import std.stdio;
    //writeln("n = ", n);
    //writeln("kc = ", kc);
    //writeln("mc_ = ", mc_);
    //writeln("ldc = ", ldc);

    foreach(nri; Iota!(nrChain.length))
    {
        enum size_t nr = nrChain[nri];
        if(n >= nr) do
        {
        //writeln("#c");
            size_t mc = mc_;
            auto a = a_;
            auto c = c_;
            foreach(mri, mrType; mrTypeChain)
            {
                enum mr = mrType.sizeof / T.sizeof;
                if(mc >= mr) do
                {
        //writeln("#d");
                    //writeln(a[0 .. 5]);
                    //writeln(b[0 .. 5]);
                    //a = 
                    a = gemm_micro_kernel!
                        (type, PC, PA, PB, mrType.length, nr, ForeachType!mrType, T)
                        (alpha, cast(mrType[PA]*)a, cast(T[PB][nr]*)b, kc, c, ldc);
                    //writeln("kc = ", kc);
                    //writeln("mr = ", mr);
                    //writeln(*c);
                    mc -= mr;
                    c += mr;
                }
                while(!mri && mc >= mr);
            }
            n -= nr;
            c_ += nr * ldc;
            b += nr * kc;
        }
        while(!nri && n >= nr);
    }
}

pragma(inline, true)
const(F)*
gemm_micro_kernel (
    Conjugation type,
    size_t PC,
    size_t PA,
    size_t PB,
    size_t N,
    size_t M,
    V,
    F,
)
(
    F[PC] alpha,
    const(V[N][PA])* a,
    const(F[PB][M])* b,
    size_t length,
    F[PC]* c,
    sizediff_t ldc,
)
    if (is(V == F) || isSIMDVector!V)
{
    //static if(!isSIMDVector!V)
    //{
    //    import std.stdio;
    //    writefln("a__= %s", a[0..length]);
    //    writefln("b__= %s", b[0..length]);
    //}
    V[N][PC][M] reg = void;
    reg.set_zero_nano_kernel;
    auto ret = gemm_nano_kernel!type(reg, a, b, length)[0];
    reg.scale_nano_kernel!(PA + PB == 2)(alpha);
    save_nano_kernel(reg, c, ldc);
    return ret;
}

pragma(inline, true)
const(F)*[2]
gemm_nano_kernel (
    Conjugation type,
    size_t PC,
    size_t PB,
    size_t PA,
    size_t N,
    size_t M,
    V,
    F,
)
(
    ref V[N][PC][M] c,
    const(V[N][PA])* a,
    const(F[PB][M])* b,
    size_t length,
)
    if (is(V == F) || isSIMDVector!V)
{
    //import std.stdio;
    //writeln("length = ", length);
    V[N][PC][M] reg = void;
    reg.load_nano_kernel(c);

    size_t i;
    do
    {
        V[N][PA] ai = void;
        V[PB][M] bi = void;

        foreach (p; Iota!PA)
        foreach (n; Iota!N)
            ai[p][n] = a[0][p][n];

        foreach (m; Iota!M)
        foreach (p; Iota!PB)
            static if (isSIMDVector!V && !isSIMDVector!F)
            {
                version(LDC)
                {
                    bi[m][p] = b[0][m][p];
                }
                else
                {
                    auto e = b[0][m][p];
                    foreach(s; Iota!(bi[m][p].array.length))
                        bi[m][p].array[s] = e;
                }
            }
            else
            {
                bi[m][p] = b[0][m][p];
            }

        enum CB = PC + PB == 4;
        enum AB = PA + PB == 4;
        enum CA = PC + PA == 4;

        foreach (m; Iota!M)
        foreach (n; Iota!N)
        {
                static if (type == conjN)
            {
                reg[m][0][n] += ai[0][n] * bi[m][0];
  static if(CB) reg[m][1][n] += ai[0][n] * bi[m][1];
  static if(AB) reg[m][0][n] -= ai[1][n] * bi[m][1];
  static if(CA) reg[m][1][n] += ai[1][n] * bi[m][0];
            }
            else static if (type == Conjugation.sub)
            {
                reg[m][0][n] -= ai[0][n] * bi[m][0];
  static if(CB) reg[m][1][n] -= ai[0][n] * bi[m][1];
  static if(AB) reg[m][0][n] += ai[1][n] * bi[m][1];
  static if(CA) reg[m][1][n] -= ai[1][n] * bi[m][0];
            }
            else static if (type == Conjugation.conjA)
            {
                reg[m][0][n] += ai[0][n] * bi[m][0];
  static if(CB) reg[m][1][n] += ai[0][n] * bi[m][1];
  static if(AB) reg[m][0][n] += ai[1][n] * bi[m][1];
  static if(CA) reg[m][1][n] -= ai[1][n] * bi[m][0];
            }
            else static if (type == Conjugation.conjB)
            {
                reg[m][0][n] += ai[0][n] * bi[m][0];
  static if(CB) reg[m][1][n] -= ai[0][n] * bi[m][1];
  static if(AB) reg[m][0][n] += ai[1][n] * bi[m][1];
  static if(CA) reg[m][1][n] += ai[1][n] * bi[m][0];
            }
            else static if (type == Conjugation.conjC)
            {
                reg[m][0][n] += ai[0][n] * bi[m][0];
  static if(CB) reg[m][1][n] -= ai[0][n] * bi[m][1];
  static if(AB) reg[m][0][n] -= ai[1][n] * bi[m][1];
  static if(CA) reg[m][1][n] -= ai[1][n] * bi[m][0];
            }
            else static assert(0);
        }

        a++;
        b++;
        length--;
    }
    while(length);
    c.load_nano_kernel(reg);
    const(F)*[2] ret = void;
    ret[0] = cast(F*) a;
    ret[1] = cast(F*) b;
    return ret;
}

pragma(inline, true)
void scale_nano_kernel (
    bool realOnly = false,
    size_t P,
    size_t M,
    size_t N,
    V,
    F,
)
(
    ref V[N][P][M] c,
    F[P] alpha,
)
{
    V[N][P][M] reg = void;
    reg.load_nano_kernel(c);

    V[P] s = void;
    s.load_nano_kernel(alpha);

    foreach (m; Iota!M)
    foreach (n; Iota!N)
    {
        static if (P == 1)
        {
            reg[m][0][n] *= s[0];
        }
        else
        {
            auto re = s[0] * reg[m][0][n];
            auto im = s[0] * reg[m][1][n];
            static if(!realOnly)
            {
                re -= s[1] * reg[m][1][n];
                im += s[1] * reg[m][0][n];
            }
            reg[m][0][n] = re;
            reg[m][1][n] = im;
        }
    }

    c.load_nano_kernel(reg);
}

pragma(inline, true)
void save_nano_kernel(size_t P, size_t N, size_t M, V, T)
    (ref V[N][P][M] reg, T[P]* c, sizediff_t ldc)
{
    foreach(m; Iota!M)
    {
        save_nano_kernel(reg[m], c);
        c += ldc;
    }
} 

pragma(inline, true)
void save_nano_kernel(size_t P, size_t N, V, T)(ref V[N][P] reg, T[P]* c)
{
    foreach(j; Iota!(N * V.sizeof / T.sizeof))
    {
        foreach(p; Iota!P)
        {
            c[j][p] += (cast(T*) &reg[p])[j];
        }
    }
}

pragma(inline, true)
void set_zero_nano_kernel(size_t A, size_t B, size_t C, V)(ref V[C][B][A] to)
{
    foreach (p; Iota!A)
    foreach (m; Iota!B)
    foreach (n; Iota!C)
        to[p][m][n] = 0;
}

pragma(inline, true)
void load_nano_kernel(size_t A, size_t B, size_t C, V)(ref V[C][B][A] to, ref V[C][B][A] from)
{
    foreach (p; Iota!A)
    foreach (m; Iota!B)
    foreach (n; Iota!C)
        to[p][m][n] = from[p][m][n];
}

pragma(inline, true)
void load_nano_kernel(size_t A, V, F)
(ref V[A] to, ref const F[A] from)
    if(!isStaticArray!F)
{
    static if (isSIMDVector!V && !isSIMDVector!F)
        version(LDC)
        foreach (p; Iota!A)
                to[p] = from[p];
        else
        foreach (p; Iota!A)
        { 
            auto e = from[p];
            foreach(s; Iota!(to[p].array.length))
                to[p].array[s] = e;
        }
    else
    foreach (p; Iota!A)
        to[p] = from[p];
}

auto statComplex(C)(C val)
{
    import std.complex: Complex;
    static if (is(C : Complex!T, T))
    {
        T[2] ret = void;
        ret[0] = val.re;
        ret[1] = val.im;
    }
    else
    {
        C[1] ret = void;
        ret[0] = val;
    }
    return ret;
}

//pragma(inline, true)
//void load_nano_kernel(size_t A, size_t C, V, F)
//(ref V[C][A] to, ref const F[C][A] from)
//    if(!isStaticArray!F)
//{
//    static if (isSIMDVector!V && !isSIMDVector!F)
//        version(LDC)
//        foreach (n; Iota!C)
//        foreach (p; Iota!A)
//                to[p][n] = from[p][n];
//        else
//        foreach (n; Iota!C)
//        foreach (p; Iota!A)
//        {
//            auto e = from[p][n];
//            foreach(s; Iota!(to[p][n].array.length))
//                to[p][n].array[s] = e;
//        }
//    else
//    foreach (n; Iota!C)
//    foreach (p; Iota!A)
//        to[p][n] = from[p][n];
//}

//pragma(inline, true)
//void load_nano_kernel(V, F)
//(ref V to, ref const F from)
//    if(!isStaticArray!F)
//{
//    static if (isSIMDVector!V && !isSIMDVector!F)
//        version(LDC)
//            to = from;
//        else
//        {
//            auto e = from;
//            foreach(s; Iota!(to.array.length))
//                to.array[s] = e;
//        }
//    else
//        to = from;
//}

//pragma(inline, true)
//void prefetch(const(void)* b, size_t length)
//{
//    version(LDC)
//    {
//        import ldc.intrinsics: llvm_prefetch;
//        size_t i;
//        auto m = length & ~size_t(0xFF);
//        for(; i < length; i += 0x100)
//        {
//            llvm_prefetch(cast(void*)b + 0x00, 0, 3, 1);
//            llvm_prefetch(cast(void*)b + 0x40, 0, 3, 1);
//            llvm_prefetch(cast(void*)b + 0x80, 0, 3, 1);
//            llvm_prefetch(cast(void*)b + 0xC0, 0, 3, 1);
//            b += 0x100;
//        }
//        m = length & 0xFF;
//        for(; i < length; i += 0x40)
//        {
//            llvm_prefetch(cast(void*)b + 0x00, 0, 3, 1);
//            b += 0x40;
//        }
//    }
//}

