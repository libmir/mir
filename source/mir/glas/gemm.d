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
import std.complex;
import std.meta;

public import mir.glas.common;
import mir.ndslice.slice : Slice;
import mir.internal.utility;
import mir.glas.internal.config;
import mir.glas.internal.copy;
import mir.glas.internal.blocking;

//alias fff = gemm!(conjN, Complex!float, Complex!float, Complex!float);
alias fff = gemm!(conjN, float, float, float);

version(LDC) version = LLVM_PREFETCH;

@fastmath:

/++
General matrix-matrix multiplication.

Params:
    type = conjugation type, optional template parameter
    c = matrix
    alpha = scalar
    a = matrix
    b = matrix

Pseudo_code: `c += a × b`

Note:
    GLAS does not require transposition parameters.
    Use $(LINK2 mir_ndslice_iteration.html#transposed, mir.ndslice.iteration.transposed)
    to perform zero cost `Slice` transposition.

BLAS: SGEMM, DGEMM, CGEMM, ZGEMM

See_also: $(SUBREF common, Conjugation)
+/
pragma(inline, false)
nothrow @nogc
void gemm(Conjugation type = conjN, C, A, B)
(
    GlasContext* ctx,
    Slice!(2, C*) csl,
    C alpha,
        Slice!(2, A*) asl,
        Slice!(2, B*) bsl,
)
    if (type == conjN || type == conjA || type == conjB || type == conjC)
in
{
    assert(asl.length!1 == bsl.length!0, "constraint: asl.length!1 == bsl.length!0");
    assert(csl.length!0 == asl.length!0, "constraint: csl.length!0 == asl.length!0");
    assert(csl.length!1 == bsl.length!1, "constraint: csl.length!1 == bsl.length!1");
    assert(csl.stride!0 == +1
        || csl.stride!0 == -1
        || csl.stride!1 == +1
        || csl.stride!1 == -1, "constraint: csl.stride!0 or csl.stride!1 must be equal to +/-1");
}
body
{
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

    static if (is(C : Complex!F, F))
        alias T = F;
    else
        alias T = C;
    static assert(!isComplex!T);

    if (asl.empty!0)
        return;
    if (asl.empty!1)
        return;
    if (bsl.empty!1)
        return;
    if (alpha == 0)
        return;

    if (csl.stride!0 < 0)
    {
        csl = csl.reversed!0;
        asl = asl.reversed!0;
    }
    if (csl.stride!1 < 0)
    {
        csl = csl.reversed!1;
        bsl = bsl.reversed!1;
    }

    // change row based to column based
    if (csl.stride!0 != 1)
    {
        static if (is(A == B))
        {
            auto tsl = asl;
            asl = bsl.transposed;
            bsl = tsl.transposed;
            csl = csl.transposed;
        }
        else
        {
            ctx.gemm!(swapConj!type, C, B, A)(csl.transposed, alpha, bsl.transposed, asl.transposed);
            return;
        }
    }

    assert(csl.stride!0 == 1);
    auto alpha_ = alpha.statComplex;

    mixin RegisterConfig!(PC, PA, PB, T);

    auto bl = blocking!(PC, PA, PB, T)(ctx, asl.length!0, asl.length!1, bsl.length!1);
    if (bl.mc == asl.length!0)
    {
        for (;;)
        {
            if (asl.length!1 < bl.kc)
            {
                if (asl.empty!1)
                    break;
                bl.kc = asl.length!1;
            }
            auto aslp = asl.transposed[0 .. bl.kc].transposed;
            asl.popFrontExactly!1(bl.kc);

            pack_a_micro_kernel!(PC, PA, PB, T, A)(aslp, bl.a);

            //pack_b_micro_kernel!(PC, PA, PB, T, B)(bsl[0 .. bl.kc].transposed, bl.b);
            //gebp_opt1!(type, PC, PA, PB, T)(bsl.length!1, bl.mc, bl.kc, csl.stride!1, cast(T*) csl.ptr, bl.a, bl.b, alpha_);

            gebp_opt1_dot!(type, PC, PA, PB, T)(
                bsl.length!1,
                bl.mc,
                bl.kc,
                csl.stride!1,
                bsl.stride!0,
                bsl.stride!1,
                cast(T*) csl.ptr,
                bl.a,
                bl.b,
                bsl.ptr,
                alpha_);
            bsl.popFrontExactly!0(bl.kc);
        }
    }
    else
    {
        for (;;)
        {
            if (asl.length!1 < bl.kc)
            {
                if (asl.empty!1)
                    break;
                bl.kc = asl.length!1;
            }
            auto aslp = asl.transposed[0 .. bl.kc].transposed;
            asl.popFrontExactly!1(bl.kc);
            pack_b_micro_kernel!(PC, PA, PB, T, B)(bsl[0 .. bl.kc].transposed, bl.b);
            bsl.popFrontExactly!0(bl.kc);
            auto c = cast(T*) csl.ptr;
            auto mc = bl.mc;
            for (;;)
            {
                if (aslp.length!0 < mc)
                {
                    if (aslp.empty!0)
                        break;
                    mc = aslp.length!0;
                }
                pack_a_micro_kernel!(PC, PA, PB, T, A)(aslp[0 .. mc], bl.a);
                aslp.popFrontExactly!0(mc);
                gebp_opt1!(type, PC, PA, PB, T)(bsl.length!1, mc, bl.kc, csl.stride!1, c, bl.a, bl.b, alpha_);
                c += mc * PC;
            }
        }
    }
}

///
unittest
{
    import mir.ndslice;

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

    auto c = slice!double([3, 4], 0);

    auto glas = new GlasContext;
    glas.gemm(c, 1.0, a, b);

    assert(c ==
        [[-42.0, 35, -7, 77],
         [-69.0, -21, -42, 21],
         [23.0, 69, 3, 29]]);
}

package:

void gebp_opt1_dot(Conjugation type, size_t PC, size_t PA, size_t PB, T, C)(
    size_t n,
    const size_t mc,
    const size_t kc,
    const sizediff_t ldc,
    const sizediff_t ldb,
    const sizediff_t ldbe,
    scope T* c,
    scope const(T)* a,
    scope T* b,
    const(C)* slbPtr,
    const T[PC] alpha,
    )
{
    import mir.ndslice.iteration: transposed;
    import std.complex: Complex;
    version(LDC)
        enum LDC = true;
    else
        enum LDC = false;
    mixin RegisterConfig!(PC, PA, PB, T);
    if (ldbe == 1)
    {
        foreach (nri; Iota!(broadcastChain.length))
        {
            enum nr = broadcastChain[nri];
            if (n >= nr) do
            {
                pack_b_dense_nano_kernel!(nr, PB)(kc, ldb, slbPtr, b);
                slbPtr += nr * ldbe;
                gemm_kernel!
                            (type, PC, PA, PB, nr, T)
                            (mc, kc, ldc, c, a, b, alpha);
                n -= nr;
                c += nr * PC * ldc;
            }
            while (!nri && n >= nr);
        }
    }
    else
    {
        foreach (nri; Iota!(broadcastChain.length))
        {
            enum nr = broadcastChain[nri];
            if (n >= nr) do
            {
                pack_b_strided_nano_kernel!(nr, PB)(kc, ldb, ldbe, slbPtr, b);
                slbPtr += nr * ldbe;
                gemm_kernel!
                            (type, PC, PA, PB, nr, T)
                            (mc, kc, ldc, c, a, b, alpha);
                n -= nr;
                c += nr * PC * ldc;
            }
            while (!nri && n >= nr);
        }
    }
}

void gebp_opt1(Conjugation type, size_t PC, size_t PA, size_t PB, T)(
    size_t n,
    const size_t mc,
    const size_t kc,
    const sizediff_t ldc,
    scope T* c,
    scope const(T)* a,
    scope const(T)* b,
    const T[PC] alpha,
    )
{
    mixin RegisterConfig!(PC, PA, PB, T);
    foreach (nri; Iota!(broadcastChain.length))
    {
        enum size_t nr = broadcastChain[nri];
        if (n >= nr) do
        {
            gemm_kernel!
                        (type, PC, PA, PB, nr, T)
                        (mc, kc, ldc, c, a, b, alpha);
            n -= nr;
            c += nr * PC * ldc;
            b += nr * PB * kc ;
        }
        while (!nri && n >= nr);
    }
}

pragma(inline, false)
void gemm_kernel (
    Conjugation type,
    size_t PC,
    size_t PA,
    size_t PB,
    size_t M,
    F,
)
(
    size_t mc,
    size_t kc,
    sizediff_t ldc,
    scope F* c,
    scope const(F)* a,
    scope const(F)* b,
    ref const F[PC] alpha,
)
{
    mixin RegisterConfig!(PC, PA, PB, F);
    foreach (mri, mrType; simdChain)
    {
        enum mr = mrType.sizeof / F.sizeof;
        if (mc >= mr) do
        {
            enum N = mrType.length;
            alias V = typeof(mrType.init[0]);
            gemm_micro_kernel!(type, PC, PA, PB, N, M, V, F)(kc, ldc, cast(F[PC]*)c, cast(const(V[N][PA])*)a, cast(const(F[PB][M])*)b, alpha);
            a += kc * mr * PA;
            mc -= mr;
            c += mr * PC;
        }
        while (!mri && mc >= mr);
    }
}

void gemm_micro_kernel (
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
    size_t length,
    size_t ldc,
    scope F[PC]* c,
    const(V[N][PA])* a,
    const(F[PB][M])* b,
    ref const F[PC] alpha,
)
{
    version(LDC) pragma(inline, true);
    version(LLVM_PREFETCH)
    {
        import ldc.intrinsics: llvm_prefetch;

        foreach (m; Iota!M)
        foreach (pr; Iota!(V[N][PC].sizeof / 64 + bool(V[N][PC].sizeof % 64 > 0)))
            llvm_prefetch(cast(void*)c + pr * 64 + ldc * m, 1, 3, 1);
    }
    V[N][PC][M] reg = void;
    gemm_nano_kernel!type(length, reg, cast(const(V[N][PA])*) a, cast(const(F[PB][M])*)b);
    V[PC] s = void;
    s.load_nano_kernel(alpha);
    foreach (m; Iota!M)
    foreach (n; Iota!N)
    {
        static if (PC == 1)
        {
            reg[m][0][n] *= s[0];
        }
        else
        {
            auto re = s[0] * reg[m][0][n];
            auto im = s[1] * reg[m][0][n];
            static if (PA + PB > 2)
            {
                re -= s[1] * reg[m][1][n];
                im += s[0] * reg[m][1][n];
            }
            reg[m][0][n] = re;
            reg[m][1][n] = im;
        }
    }
    save_add_nano_kernel(reg, c, ldc);
}


const(F[PB][M])*
gemm_nano_kernel (
    Conjugation type,
    bool prefetchA = true,
    bool prefetchB = false,
    size_t PC,
    size_t PA,
    size_t PB,
    size_t N,
    size_t M,
    V,
    F,
)
(
    size_t length,
    ref V[N][PC][M] c,
    const(V[N][PA])* a,
    const(F[PB][M])* b,
)
    if (is(V == F) || isSIMDVector!V)
{
    version(LDC) pragma(inline, true);
    V[N][PC][M] reg = void;

    foreach (m; Iota!M)
    foreach (p; Iota!PC)
    foreach (n; Iota!N)
        reg[m][p][n] = 0;

    do
    {
        V[N][PA] ai = void;
        V[PB][M] bi = void;

        foreach (p; Iota!PA)
        foreach (n; Iota!N)
            ai[p][n] = a[0][p][n];

        static if (prefetchA)
        version(LLVM_PREFETCH) version(X86_64)
        {
            import ldc.intrinsics: llvm_prefetch;

            foreach (pr; Iota!(V[N][PA].sizeof / 64 + bool(V[N][PA].sizeof % 64 >= 16)))
                llvm_prefetch(cast(void*)a + pr * 64 + prefetchShift, 0, 3, 1);
        }

        static if (prefetchB)
        version(LLVM_PREFETCH) version(X86_64)
        {
            import ldc.intrinsics: llvm_prefetch;

            foreach (pr; Iota!(F[PB][M].sizeof / 64 + bool(F[PB][M].sizeof % 64 >= 16)))
                llvm_prefetch(cast(void*)b + pr * 64 + prefetchShift, 0, 3, 1);
        }

        enum CB = PC + PB == 4;
        enum AB = PA + PB == 4;
        enum CA = PC + PA == 4;

        foreach (u; Iota!(M/2 + M%2))
        //foreach (u; Iota!(M))
        {
            alias um = Iota!(2*u, 2*u + 2 > M ? 2*u + 1 : 2*u + 2);
            //alias um = AliasSeq!(u);
            foreach (m; um)
            foreach (p; Iota!PB)
            static if (isSIMDVector!V && !isSIMDVector!F)
                version(LDC)
                    bi[m][p] = b[0][m][p];
                else
                {
                    auto e = b[0][m][p];
                    foreach (s; Iota!(bi[m][p].array.length))
                        bi[m][p].array[s] = e;
                }
            else
                bi[m][p] = b[0][m][p];
            foreach (m; um)
            foreach (n; Iota!N)
            {
                    static if (type == conjN)
                {
                    reg[m][0][n] += ai[0][n] * bi[m][0];
     static if (CB) reg[m][1][n] += ai[0][n] * bi[m][1];
     static if (AB) reg[m][0][n] -= ai[1][n] * bi[m][1];
     static if (CA) reg[m][1][n] += ai[1][n] * bi[m][0];
                }
                else static if (type == conjA)
                {
                    reg[m][0][n] += ai[0][n] * bi[m][0];
     static if (CB) reg[m][1][n] += ai[0][n] * bi[m][1];
     static if (AB) reg[m][0][n] += ai[1][n] * bi[m][1];
     static if (CA) reg[m][1][n] -= ai[1][n] * bi[m][0];
                }
                else static if (type == conjB)
                {
                    reg[m][0][n] += ai[0][n] * bi[m][0];
     static if (CB) reg[m][1][n] -= ai[0][n] * bi[m][1];
     static if (AB) reg[m][0][n] += ai[1][n] * bi[m][1];
     static if (CA) reg[m][1][n] += ai[1][n] * bi[m][0];
                }
                else static if (type == conjC)
                {
                    reg[m][0][n] += ai[0][n] * bi[m][0];
     static if (CB) reg[m][1][n] -= ai[0][n] * bi[m][1];
     static if (AB) reg[m][0][n] -= ai[1][n] * bi[m][1];
     static if (CA) reg[m][1][n] -= ai[1][n] * bi[m][0];
                }
                else static assert(0);
            }
        }

        a++;
        b++;
        length--;
    }
    while (length);

    foreach (m; Iota!M)
    foreach (p; Iota!PC)
    foreach (n; Iota!N)
        c[m][p][n] = reg[m][p][n];

    return b;
}

version(test_glass)
unittest
{
    import std.complex;
    foreach (trans; AliasSeq!(true, false))
    foreach (T; AliasSeq!(uint, double, Complex!double))
    {
        import std.stdio;
        writeln(T.stringof, " trans = ", trans);
        alias D = T;

        import std.random;
        import mir.ndslice;

        auto m = 111, n = 123, k = 2131;

        auto a = slice!(D)(m, k);
        auto b = slice!(D)(k, n);

        auto c = slice!(D)(m, n);
        static if (trans)
            auto d = slice!(D)(n, m).transposed;
        else
            auto d = slice!(D)(m, n);
        D alpha = 3;

        static if (isComplex!D)
        {

            foreach (ref e; a.byElement)
                e = complex(uniform(0, 5), uniform(0, 5));

            foreach (ref e; b.byElement)
                e = complex(uniform(0, 5), uniform(0, 5));

            foreach (ref e; c.byElement)
                e = complex(uniform(0, 5), uniform(0, 5));
        }
        else
        {
            foreach (ref e; a.byElement)
                e = uniform(ubyte(0), ubyte(5));

            foreach (ref e; b.byElement)
                e = uniform(ubyte(0), ubyte(5));

            foreach (ref e; c.byElement)
                e = uniform(ubyte(0), ubyte(5));
        }

        d[] = c[];

        foreach (i; 0..a.length)
            foreach (j; 0..b.length!1)
                foreach (r; 0..b.length)
                    d[i, j] += alpha * a[i, r] * b[r, j];

        auto glas = new GlasContext;
        glas.gemm(c, alpha, a, b);
        assert(c == d);
    }
}
