module mir.glas.trmm;

import std.traits;
import std.meta;

version(none):


public import mir.glas.common;
import mir.ndslice.slice;
import mir.internal.utility;
import mir.glas.internal.config;
import mir.glas.internal.copy;
import mir.glas.internal.blocking;
import mir.glas.gemm: gemm, gemm_nano_kernel;


version = PREFETCH;

import ldc.attributes : fastmath;
@fastmath:

pragma(inline, false)
//nothrow @nogc
void trmm(Conjugation type = conjN, Diag diag = Diag.nounit, A, B)
(
    GlasContext* ctx,
    Uplo uplo,
    B alpha,
        Slice!(2, A*) asl,
        Slice!(2, B*) bsl,
)
    if (type == conjN || type == conjA)
in
{
    assert(asl.length!0 == asl.length!1, "constraint: asl.length!0 == asl.length!1");
    assert(bsl.length!0 == asl.length!0, "constraint: bsl.length!0 == asl.length!0");
    assert(bsl.stride!0 == +1
        || bsl.stride!0 == -1
        || bsl.stride!1 == +1
        || bsl.stride!1 == -1, "constraint: bsl.stride!0 or bsl.stride!1 must be equal to +/-1");
}
body
{
    import mir.ndslice.iteration: reversed, allReversed, transposed;
    enum msg = "mir.glas does not allow slices on top of const/immutable/shared memory";
    static assert(is(Unqual!A == A), msg);
    static assert(is(Unqual!B == B), msg);

    enum CA = isComplex!A;
    enum CB = isComplex!B;

    enum PA = CA ? 2 : 1;
    enum PB = CB ? 2 : 1;

    static assert (PA <= PB, "A cannot be a complex matrix if B is not complex.");

    static if (is(B : Complex!F, F))
        alias T = F;
    else
        alias T = B;
    static assert(!isComplex!T);

    if (bsl.empty!0)
        return;
    if (bsl.empty!1)
        return;
    if (alpha == 0)
    {
        bsl[] = 0;
        return;
    }

    if (bsl.stride!1 < 0)
    {
        bsl = bsl.reversed!1;
    }
    if (uplo == Uplo.lower)
    {
        asl = asl.allReversed;
        bsl = bsl.reversed!0;
    }
            import std.stdio;
        writefln("asl = \n%(%s\n%)", asl);
        writefln("bsl = \n%(%s\n%)", bsl);

    mixin RegisterConfig!(PB, PA, PB, T);
    auto bl = blocking_triangular!(PA, PB, T)(ctx, asl.length!0, bsl.length!1);
    bl.kc = bl.mc = 2;
    with(bl) for (;;)
    {
        if (asl.length < bl.kc)
        {
            if (asl.empty)
                break;
            kc = mc = asl.length;
        }
        auto bslb = bsl[0 .. kc];
        auto aslb = asl[0 .. kc, 0 .. kc];
        pack_b_triangular_micro_kernel!(Uplo.upper, false, PB, PA, PB)(aslb, a);
        foreach (mri, mrType; simd_chain)
        {
            enum mr = mrType.sizeof / T.sizeof;
            if (bslb.length!1 >= mr) do
            {
                pack_a_nano_kernel!(mr, PA)(bslb.length, bslb.stride!0, bslb.stride!1, bslb.ptr, b);
                trmm_kernel!(type, diag, PA, PB, mrType.length, typeof(mrType.init[0]), T)(
                    bslb.length,
                    bslb.stride!0,
                    bslb.stride!1,
                    cast(T[PB]*) bslb.ptr,
                    cast(const(T[PA])*) a,
                    cast(mrType[PB]*)b,
                    alpha.castByRef);
                bslb.popFrontExactly!1(mr);
            }
            while (!mri && bslb.length!1 >= mr);
        }
        auto bslp = bsl[kc .. $];
        auto aslp = asl[0 .. kc, kc .. $];
        bslb = bsl[0 .. kc];
        writefln("asl = \n%(%s\n%)", asl);
        writefln("bsl = \n%(%s\n%)", bsl);
        if (bslp.length)
        {
            writefln("c = \n%(%s\n%)", bslb);
            writefln("a = \n%(%s\n%)", aslp);
            writefln("b = \n%(%s\n%)", bslp);
            B gemm_alpha = 1;
            B gemm_beta = 1;
            gemm!type(ctx, gemm_alpha, aslp, bslp, gemm_beta, bslb);
            writefln("c = \n%(%s\n%)", bslb);
        }
        writefln("asl = \n%(%s\n%)", asl);
        writefln("bsl = \n%(%s\n%)", bsl);
        assert(asl.length!1 == asl.length);
        asl.popFrontExactly!0(kc);
        asl.popFrontExactly!1(kc);
        bsl.popFrontExactly!0(kc);
    }
}

/// Lower triangular matrix
unittest
{
    import mir.ndslice;
    import std.math: approxEqual;

    auto a = slice!double(4, 4);
    auto b = slice!double(4, 3);
    import std.stdio;
    writeln(b.shape);
    auto r = slice!double(4, 3);
    a[] =
        [[8 , 0 , 0 ,  0],
         [2 , 4 , 0 ,  0],
         [9 , 3 , 10,  0],
         [12, 20, 34,  12]];
    b[] =
        [[6, 4, 3],
         [2, 5, 1],
         [5, 7, 3],
         [5, 9, 3]];
    r[] =
        [[ 48,  32,  24],
         [ 20,  28,  10],
         [110, 121,  60],
         [342, 494, 194]];
    auto ctx = new GlasContext;

    import std.stdio;

    ctx.trmm(Uplo.lower, 1.0, a, b);
    //writeln(b);
    //writeln(r);

    assert(ndEqual!approxEqual(b, r));
}


/// Upper triangular matrix
unittest
{
    import mir.ndslice;
    import std.math: approxEqual;

    auto a = slice!double(4, 4);
    auto b = slice!double(4, 3);
    auto r = slice!double(4, 3);
    a[] =
        [[8, 2,  9, 12],
         [0, 4,  3, 20],
         [0, 0, 10, 34],
         [0, 0,  0, 12]];
    b[] =
        [[6, 4, 3],
         [2, 5, 1],
         [5, 7, 3],
         [5, 9, 3]];
    r[] =
        [[157, 213,  89],
         [123, 221,  73],
         [220, 376, 132],
         [ 60, 108,  36]];
    auto ctx = new GlasContext;

    ctx.trmm(Uplo.upper, 1.0, a, b);

    assert(ndEqual!approxEqual(b, r));
}

unittest
{
    import mir.ndslice;
    import std.math: approxEqual;

    auto a = slice!double(4, 4);
    auto b = slice!double(3, 4).transposed;
    auto r = slice!double(4, 3);
    a[] =
        [[8, 2,  9, 12],
         [0, 4,  3, 20],
         [0, 0, 10, 34],
         [0, 0,  0, 12]];
    b[] =
        [[6, 4, 3],
         [2, 5, 1],
         [5, 7, 3],
         [5, 9, 3]];
    r[] =
        [[157, 213,  89],
         [123, 221,  73],
         [220, 376, 132],
         [ 60, 108,  36]];
    auto ctx = new GlasContext;

    ctx.trmm(Uplo.upper, 1.0, a, b);

    assert(ndEqual!approxEqual(b, r));
}

unittest
{
    import mir.ndslice;
    import std.math: approxEqual;

    auto a = slice!double(4, 4);
    auto b = slice!double(3, 4).transposed;
    auto r = slice!double(4, 3);
    a[] =
        [[8 , 0 , 0 ,  0],
         [2 , 4 , 0 ,  0],
         [9 , 3 , 10,  0],
         [12, 20, 34,  12]];
    b[] =
        [[6, 4, 3],
         [2, 5, 1],
         [5, 7, 3],
         [5, 9, 3]];
    r[] =
        [[ 48,  32,  24],
         [ 20,  28,  10],
         [110, 121,  60],
         [342, 494, 194]];
    auto ctx = new GlasContext;
    ctx.trmm(Uplo.lower, 1.0, a, b);
    import std.stdio;
    //writeln(b);
    //writeln(r);
    assert(ndEqual!approxEqual(b, r));
}

package:

pragma(inline, false)
void trmm_kernel (
    Conjugation type,
    Diag diag,
    size_t PA,
    size_t PB,
    size_t M,
    V,
    F,
)
(
    size_t mc,
    sizediff_t ldc,
    sizediff_t ldce,
    scope F[PB]* c,
    scope const(F[PB])* a,
    scope V[M][PB]* b,
    ref F[PB] alpha,
)
    if ((is(V == F) || isSIMDVector!V) && PA <= PB)
{
    import std.stdio;
    //writeln("mc = ", mc);
    mixin RegisterConfig!(PB, PA, PB, F);
    size_t kc = mc;
    auto bs = b;
    foreach (nri, nr; broadcast_chain)
    if (mc >= nr) do
    {
        enum N = nr;
        version(PREFETCH)
        {
            import ldc.intrinsics: llvm_prefetch;

            if (ldce == 1)
            foreach (m; Iota!M)
            foreach (pr; Iota!(V[M][PB].sizeof / 64 + bool(V[M][PB].sizeof % 64 > 0)))
                llvm_prefetch(cast(void*)c + pr * 64 + ldc * m, 1, 3, 1);

            //foreach (m; Iota!M)
            //foreach (pr; Iota!(V[M][PB][N].sizeof / 64 + bool(V[M][PB][N].sizeof % 64 > 0)))
            //    llvm_prefetch(cast(void*)b + pr * 64, 1, 3, 1);
        }
        V[M][PB][N] reg = void;
        foreach (n; Iota!N)
        foreach (p; Iota!PB)
        foreach (m; Iota!M)
            reg[n][p][m] = b[n][p][m];
        //foreach (n; Iota!N)
        //foreach (p; Iota!PB)
        //foreach (m; Iota!M)
            //static if (isSIMDVector!V)
            //writefln("reg[%s][%s][%s] = %s", n,p,m, reg[n][p][m].array);
            //else
            //writefln("reg[%s][%s][%s] = %s", n,p,m, reg[n][p][m]);

        trmm_nano_kernel!(type, diag, PA, PB, M, N, F, V)(*cast(F[PA][N][N]*) a, reg);
        //foreach (n; Iota!N)
        //foreach (p; Iota!PB)
        //foreach (m; Iota!M)
            //static if (isSIMDVector!V)
            //writefln("reg[%s][%s][%s] = %s", n,p,m, reg[n][p][m].array);
            //else
            //writefln("reg[%s][%s][%s] = %s", n,p,m, reg[n][p][m]);

        a += nr * nr;
        mc -= nr;
        if (mc)
            a = cast(typeof(a)) gemm_nano_kernel!(type, true, true, true, PB, PA, PB, M, N)(mc, reg, b + nr, cast(const(F[PB][N])*)a);
        V[PB] s = void;
        s.load_nano_kernel(alpha);
        foreach (n; Iota!N)
        foreach (m; Iota!M)
        {
            static if (PB == 1)
            {
                reg[n][0][m] *= s[0];
            }
            else
            {
                auto re = s[0] * reg[n][0][m];
                auto im = s[0] * reg[n][1][m];
                static if (PA == 2)
                {
                    re -= s[1] * reg[n][1][m];
                    im += s[1] * reg[n][0][m];
                }
                reg[n][0][m] = re;
                reg[n][1][m] = im;
            }
        }
        //foreach (n; Iota!N)
        //foreach (p; Iota!PB)
        //foreach (m; Iota!M)
            //static if (isSIMDVector!V)
            //writefln("reg[%s][%s][%s] = %s", n,p,m, reg[n][p][m].array);
            //else
            //writefln("reg[%s][%s][%s] = %s", n,p,m, reg[n][p][m]);
        foreach (n; Iota!N)
        foreach (p; Iota!PB)
        foreach (m; Iota!M)
            b[n][p][m] = reg[n][p][m];
        b += nr;
        if (ldce == 1)
        {
            save_nano_kernel(reg, c, ldc);
            c += nr * ldc;
        }
    }
    while (!nri && mc >= nr);
    if (ldce != 1)
    {
        save_transposed_nano_kernel(kc, ldce, ldc, bs, c);
    }
}

pragma(inline, true)
void trmm_nano_kernel (
    Conjugation type,
    Diag diag,
    size_t PA,
    size_t PB,
    size_t M,
    size_t N,
    F,
    V,
)
(
    ref const F[PA][N][N] a,
    ref V[M][PB][N] b,
)
     if (type == conjN || type == conjA)
{
    enum AA = PA == 2;
    enum AB = PA == 2 && AA;
    V[M][PB][N] reg = void;
    foreach (n; Iota!N)
    foreach (p; Iota!PB)
    foreach (m; Iota!M)
        reg[n][p][m] = b[n][p][m];
    foreach (n; Iota!N)
    {
        static if (diag == Diag.nounit)
        {{
            V[PA] s = void;
            s.load_nano_kernel(a[n][n]);
            foreach (m; Iota!M)
            {
                auto re  = s[0] * reg[n][0][m];
 static if (AA) auto im  = s[0] * reg[n][1][m];
                static if (type == conjN)
                {
 static if (AB)      re -= s[1] * reg[n][1][m];
 static if (AB)      im += s[1] * reg[n][0][m];
                }
                else
                {
 static if (AB)      re += s[1] * reg[n][1][m];
 static if (AB)      im -= s[1] * reg[n][0][m];
                }
                reg[n][0][m] = re;
 static if (AA) reg[n][1][m] = im;
            }
        }}
        foreach (i; Iota!(n + 1, N))
        {
            V[PA] s = void;
            s.load_nano_kernel(a[i][n]);
            import std.stdio;
            //writeln(a[i][n]);
            foreach (m; Iota!M)
            {
                    reg[n][0][m]  += s[0] * reg[i][0][m];
     static if (AB) reg[n][1][m]  += s[0] * reg[i][1][m];
                static if (type == conjN)
                {
     static if (AA) reg[n][0][m]  -= s[1] * reg[i][1][m];
     static if (AB) reg[n][1][m]  += s[1] * reg[i][0][m];
                }
                else
                {
     static if (AA) reg[n][0][m]  += s[1] * reg[i][1][m];
     static if (AB) reg[n][1][m]  -= s[1] * reg[i][0][m];
                }
            }
        }
    }
    foreach (n; Iota!N)
    foreach (p; Iota!PB)
    foreach (m; Iota!M)
        b[n][p][m] = reg[n][p][m];
}

unittest
{
    import std.algorithm.mutation;
    double[4][4] a =
        [[8 , 0 , 0 ,  0],
         [2 , 4 , 0 ,  0],
         [9 , 3 , 10,  0],
         [12, 20, 34,  12]];
    double[3][4] b =
        [[6, 4, 3],
         [2, 5, 1],
         [5, 7, 3],
         [5, 9, 3]];
    double[3][4] x =
        [[157, 213,  89],
         [123, 221,  73],
         [220, 376, 132],
         [ 60, 108,  36]];
    alias f = trmm_nano_kernel!(conjN, Diag.nounit, 1, 1, 3, 4, double, double);
    f(*cast(double[1][4][4]*) &a, *cast(double[3][1][4]*) &b);
    import std.stdio;
    //writeln(b);
    //writeln(x);
    import std.math: approxEqual;
    foreach (i; 0..b.length)
    foreach (j; 0..b[0].length)
        assert(b[i][j].approxEqual(x[i][j]));
}
