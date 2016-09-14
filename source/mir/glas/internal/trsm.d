module mir.glas.trsm;

import std.traits;
import std.complex;
import std.meta;

version(none):

public import mir.glas.common;
import mir.ndslice.slice : Slice;
import mir.internal.utility;
import mir.glas.internal.config;
import mir.glas.internal.copy;
import mir.glas.internal.blocking;
import mir.glas.gemm: gemm, gemm_nano_kernel;

version(LDC) version = LLVM_PREFETCH;

@fastmath:

pragma(inline, false)
//nothrow @nogc
void trsm(Conjugation type = conjN, Diag diag = Diag.nounit, A, B)
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
    import mir.ndslice.iteration: reversed, allReversed;
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
    if (uplo == Uplo.upper)
    {
        asl = asl.allReversed;
        bsl = bsl.reversed!0;
    }

    mixin RegisterConfig!(PB, PA, PB, T);
    auto bl = blocking_triangular!(PA, PB, T)(ctx, asl.length!0, bsl.length!1);
    bl.kc = bl.mc = 2;
    size_t k;
    with(bl) for (;;)
    {
        if (asl.length < bl.kc)
        {
            if (asl.empty)
                break;
            kc = mc = asl.length;
        }
        auto newK = k + kc;
        auto bslp = bsl[0 .. k];
        auto bslb = bsl[k .. newK];
        auto aslp = asl[0 .. kc, 0 .. k];
        auto aslb = asl[0 .. kc, k .. newK];
        k = newK;
        asl.popFrontExactly(kc);
        if (bslp.length)
        {
            B gemm_alpha = -1;
            B gemm_beta = 1;
            gemm!type(ctx, gemm_alpha, aslp, bslp, gemm_beta, bslb);
        }
        pack_b_triangular_micro_kernel!(Uplo.lower, true, PB, PA, PB)(aslb, a);
        foreach (mri, mrType; simd_chain)
        {
            enum mr = mrType.sizeof / T.sizeof;
            if (bslb.length!1 >= mr) do
            {
                pack_a_nano_kernel!(mr, PA)(bslb.length, bslb.stride!0, bslb.stride!1, bslb.ptr, b);
                trsm_kernel!(type, diag, PA, PB, mrType.length, typeof(mrType.init[0]), T)(
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
    }
}

/// Lower triangular matrix
unittest
{
    import mir.ndslice;

    import std.math: approxEqual;
    auto a = slice!double(4, 4);
    auto b = slice!double(4, 3);
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
        [[ 0.750,  0.500,  0.375],
         [ 0.125,  1.000,  0.063],
         [-0.213, -0.050, -0.056],
         [ 0.060, -1.275, -0.070]];
    auto ctx = new GlasContext;

    ctx.trsm(Uplo.lower, 1.0, a, b);

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
        [[ 1.380,  1.734,  0.766],
         [-0.896, -1.113, -0.588],
         [-0.917, -1.850, -0.550],
         [ 0.417,  0.750,  0.250]];
    auto ctx = new GlasContext;

    ctx.trsm(Uplo.upper, 1.0, a, b);

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
        [[ 0.750,  0.500,  0.375],
         [ 0.125,  1.000,  0.063],
         [-0.213, -0.050, -0.056],
         [ 0.060, -1.275, -0.070]];
    auto ctx = new GlasContext;
    ctx.trsm(Uplo.lower, 1.0, a, b);
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
        [[ 1.380,  1.734,  0.766],
         [-0.896, -1.113, -0.588],
         [-0.917, -1.850, -0.550],
         [ 0.417,  0.750,  0.250]];
    auto ctx = new GlasContext;

    ctx.trsm(Uplo.upper, 1.0, a, b);

    assert(ndEqual!approxEqual(b, r));
}

package:

pragma(inline, false)
void trsm_kernel (
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
    mixin RegisterConfig!(PB, PA, PB, F);
    size_t kc;
    foreach (nri, nr; broadcast_chain)
    if (mc >= nr) do
    {
        enum N = nr;
        version(LLVM_PREFETCH)
        {
            import ldc.intrinsics: llvm_prefetch;

            if (ldce == 1)
            foreach (m; Iota!M)
            foreach (pr; Iota!(V[M][PB].sizeof / 64 + bool(V[M][PB].sizeof % 64 > 0)))
                llvm_prefetch(cast(void*)c + pr * 64 + ldc * m, 1, 3, 1);

            //foreach (m; Iota!M)
            //foreach (pr; Iota!(V[M][PB][N].sizeof / 64 + bool(V[M][PB][N].sizeof % 64 > 0)))
            //    llvm_prefetch(cast(void*)t + pr * 64, 1, 3, 1);
        }
        V[M][PB][N] reg = void;
        if (kc)
        {
            a = cast(typeof(a)) gemm_nano_kernel!(type, true, true, false, PB, PA, PB, M, N)(kc, reg, cast(V[M][PB]*) b, cast(const(F[PB][N])*)a);
            V[PB] s = void;
            s.load_nano_kernel(alpha);
            auto t = b + kc;
            foreach (n; Iota!N)
            foreach (m; Iota!M)
            {
                foreach (p; Iota!PB)
                    reg[n][p][m] = s[0] * t[n][p][m] - reg[n][p][m];
                static if (PB == 2)
                {
                    reg[n][0][m] -= s[1] * t[n][1][m];
                    reg[n][1][m] += s[1] * t[n][0][m];
                }
            }
        }
        else
        {
            V[PB] s = void;
            s.load_nano_kernel(alpha);
            foreach (n; Iota!N)
            foreach (m; Iota!M)
            {
                foreach (p; Iota!PB)
                    reg[n][p][m] = s[0] * b[n][p][m];
                static if (PB == 2)
                {
                    reg[n][0][m] -= s[1] * b[n][1][m];
                    reg[n][1][m] += s[1] * b[n][0][m];
                }
            }
        }
        trsm_nano_kernel!(type, diag, PA, PB, M, N, F, V)(*cast(F[PA][N][N]*) a, reg);
        typeof(b) t = b + kc;
        foreach (n; Iota!N)
        foreach (p; Iota!PB)
        foreach (m; Iota!M)
            t[n][p][m] = reg[n][p][m];
        if (ldce == 1)
        {
            save_nano_kernel(reg, c, ldc);
            c += nr * ldc;
        }
        a += nr * nr;
        mc -= nr;
        kc += nr;
    }
    while (!nri && mc >= nr);
    if (ldce != 1)
    {
        save_transposed_nano_kernel(kc, ldce, ldc, b, c);
    }
}

pragma(inline, true)
void trsm_nano_kernel (
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
        foreach (i; Iota!n)
        {
            V[PA] s = void;
            s.load_nano_kernel(a[i][n]);
            foreach (m; Iota!M)
            {
                    reg[n][0][m]  -= s[0] * reg[i][0][m];
     static if (AB) reg[n][1][m]  -= s[0] * reg[i][1][m];
                static if (type == conjN)
                {
     static if (AA) reg[n][0][m]  += s[1] * reg[i][1][m];
     static if (AB) reg[n][1][m]  -= s[1] * reg[i][0][m];
                }
                else
                {
     static if (AA) reg[n][0][m]  -= s[1] * reg[i][1][m];
     static if (AB) reg[n][1][m]  += s[1] * reg[i][0][m];
                }
            }
        }
        static if (diag == Diag.nounit)
        {
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
    foreach (i; 0..a.length)
    foreach (j; 0..i)
        swap(a[i][j], a[j][i]);
    double[3][4] b =
        [[6, 4, 3],
         [2, 5, 1],
         [5, 7, 3],
         [5, 9, 3]];
    double[3][4] x =
        [[ 0.750,  0.500,  0.375],
         [ 0.125,  1.000,  0.063],
         [-0.213, -0.050, -0.056],
         [ 0.060, -1.275, -0.070]];
    foreach (i; 0 .. a.length)
            a[i][i] = 1 / a[i][i];
    alias f = trsm_nano_kernel!(conjN, Diag.nounit, 1, 1, 3, 4, double, double);
    f(*cast(double[1][4][4]*) &a, *cast(double[3][1][4]*) &b);
    import std.math: approxEqual;
    foreach (i; 0..b.length)
    foreach (j; 0..b[0].length)
        assert(b[i][j].approxEqual(x[i][j]));
}
