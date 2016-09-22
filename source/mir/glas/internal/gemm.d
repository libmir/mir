module mir.glas.internal.gemm;

import std.traits;
import std.complex;
import std.meta;

public import mir.glas.common;
import mir.ndslice.slice : Slice;
import mir.internal.utility;
import mir.glas.internal;

import ldc.attributes : fastmath;
@fastmath:

version = PREFETCH;

pragma(inline, false)
//nothrow @nogc
void gemm_impl(A, B, C)
(
    GlasContext* ctx,
    C alpha,
        Slice!(2, A*) asl,
        Slice!(2, B*) bsl,
    C beta,
        Slice!(2, C*) csl,
    Conjugated conja,
    Conjugated conjb,
)
{
    mixin prefix3;
    import mir.ndslice.iteration: reversed, transposed;

    if (csl.anyEmpty)
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
            auto conjt = conja;
            conja = conjb;
            conjb = conjt;
        }
        else
        {
            ctx.gemm!(B, A, C)(alpha, bsl.transposed, asl.transposed, beta, csl.transposed, conjb, conja);
            return;
        }
    }

    assert(csl.stride!0 == 1);

    if (asl.empty!1 || alpha == 0)
    {
        csl = csl.transposed;
        if (beta == 0)
        {
            do {
                (cast(T[])(csl.front.toDense))[] = T(0); // memset
                csl.popFront;
            } while(csl.length);
            return;
        }
        if (beta == 1)
            return;
        do {
            csl.front.toDense[] *= beta;
            csl.popFront;
        } while(csl.length);
        return;
    }

    mixin RegisterConfig!(PA, PB, PC, T);

    Kernel!(PC, T)[nr_chain.length]
        beta_kernels = void,
        one_kernels = void;

    foreach (nri, nr; nr_chain)
        one_kernels [nri] = &gemv_reg!(BetaType.one, PA, PB, PC, nr, T);

    Kernel!(PC, T)* kernels = one_kernels.ptr;
    if (beta == 0)
    {
        foreach (nri, nr; nr_chain)
            beta_kernels[nri] = &gemv_reg!(BetaType.zero, PA, PB, PC, nr, T);
        kernels = beta_kernels.ptr;
    }
    else
    if (beta != 1)
    {
        foreach (nri, nr; nr_chain)
            beta_kernels[nri] = &gemv_reg!(BetaType.beta, PA, PB, PC, nr, T);
        kernels = beta_kernels.ptr;
    }
    auto bl = blocking!(PA, PB, PC, T)(ctx, asl.length!0, bsl.length!1, asl.length!1);
    with(bl)
    {
        sizediff_t incb;
        if (mc < asl.length!0)
            incb = kc;
        do
        {
            if (asl.length!1 < kc)
                kc = asl.length!1;
            ////////////////////////
            auto aslp = asl[0 .. $, 0 .. kc];
            auto bsl_ptr = bsl.ptr;
            auto cslm = csl;
            auto mc = mc;
            //======================
            do
            {
                if (aslp.length!0 < mc)
                    mc = aslp.length!0;
                ////////////////////////
                if (PA && conja)
                    pack_a!(PA, PB, PC, true, T, A)(aslp[0 .. mc], a);
                else
                    pack_a!(PA, PB, PC, false, T, A)(aslp[0 .. mc], a);
                //======================
                gebp!(PA, PB, PC, T)(
                    mc,
                    bsl.length!1,
                    kc,
                    alpha.castByRef,
                    a,
                    b,
                    incb,
                    bsl_ptr,
                    bsl.stride!0,
                    bsl.stride!1,
                    beta.castByRef,
                    cast(T*) cslm.ptr,
                    cslm.stride!1,
                    kernels,
                    conjb,
                    );
                ////////////////////////
                bsl_ptr = null;
                cslm.popFrontExactly!0(mc);
                aslp.popFrontExactly!0(mc);
            }
            while (aslp.length!0);
            ////////////////////////
            kernels = one_kernels.ptr;
            bsl.popFrontExactly!0(kc);
            asl.popFrontExactly!1(kc);
        }
        while (asl.length!1);
    }
}

pragma(inline, true)
void gebp(size_t PA, size_t PB, size_t PC, F, C)(
    size_t mc,
    size_t nc,
    size_t kc,
    const F[PC] alpha,
    scope const(F)* a,
    scope F* b,
    sizediff_t incb,
    const(C)* ptrb,
    sizediff_t ldb,
    sizediff_t ldbe,
    ref const F[PC] beta,
    scope F* c,
    sizediff_t ldc,
    Kernel!(PC, F)* kernels,
    Conjugated conj,
    )
{
    mixin RegisterConfig!(PA, PB, PC, F);
    foreach (nri, nr; nr_chain)
    if (nc >= nr) do
    {
        if (ptrb)
        {
            if (PB && conj)
                pack_b_nano!(nr, PB, true)(kc, ldb, ldbe, ptrb, b);
            else
                pack_b_nano!(nr, PB, false)(kc, ldb, ldbe, ptrb, b);
            ptrb += nr * ldbe;
        }
        kernels[nri](mc, kc, alpha, a, b, beta, c, ldc);
        b +=  nr * PB * incb;
        nc -= nr;
        c += nr * PC * ldc;
    }
    while (!nri && nc >= nr);
}

alias Kernel(size_t PC, F) =
    nothrow @nogc
    void function(
        size_t mc,
        size_t kc,
        ref const F[PC] alpha,
        scope const(F)* a,
        scope const(F)* b,
        ref const F[PC] beta,
        scope F* c,
        sizediff_t ldc,
    );

pragma(inline, false)
//nothrow @nogc
void gemv_reg (
    BetaType beta_type,
    size_t PA,
    size_t PB,
    size_t PC,
    size_t N,
    F,
)
(
    size_t mc,
    size_t kc,
    ref const F[PC] alpha,
    scope const(F)* a,
    scope const(F)* b,
    ref const F[PC] beta,
    scope F* c,
    sizediff_t ldc,
)
{
    mixin RegisterConfig!(PA, PB, PC, F);
    foreach (mri, mr; mr_chain)
    if (mc >= mr) do
    {
        enum M = Mi!(mri);
        alias V = Vi!(mri);
        auto as = a;
        a = cast(typeof(a)) dot_reg!beta_type(alpha, cast(const(V[M][PA])*)a, cast(const(F[PB][N])*)b, kc, beta, cast(F[PC]*)c, ldc);
        mc -= mr;
        c += mr * PC;
    }
    while (!mri && mc >= mr);
}

enum BetaType
{
    zero,
    one,
    beta,
}

pragma(inline, true)
//nothrow @nogc
const(V[M][PA])* dot_reg (
    BetaType beta_type,
    size_t PA,
    size_t PB,
    size_t PC,
    size_t M,
    size_t N,
    V,
    F,
)
(
    ref const F[PC] alpha,
    const(V[M][PA])* a,
    const(F[PB][N])* b,
    size_t length,
    ref const F[PC] beta,
    scope F[PC]* c,
    sizediff_t ldc,
)
{
    prefetch_w!(V[M][PC].sizeof, N, 1)(c, ldc * c[0].sizeof);
    V[M][PC][N] reg = void;
    a = dot_reg_basic(a, b, length, reg);
    scale_nano(alpha, reg);
    static if (beta_type == BetaType.zero)
        save_nano(reg, c, ldc);
    else
    static if (beta_type == BetaType.one)
        save_add_nano(reg, c, ldc);
    else
        save_madd_nano(reg, beta, c, ldc);
    return a;
}

pragma(inline, true)
//nothrow @nogc
const(V[M][PA])*
dot_reg_basic (
    size_t PA,
    size_t PB,
    size_t PC,
    size_t M,
    size_t N,
    V,
    F,
)
(
    const(V[M][PA])* a,
    const(F[PB][N])* b,
    size_t length,
    ref V[M][PC][N] c,
)
    if (is(V == F) || isSIMDVector!V)
{
    V[M][PC][N] reg = void;

    foreach (n; Iota!N)
    foreach (p; Iota!PC)
    foreach (m; Iota!M)
        reg[n][p][m] = 0;
    do
    {
        V[M][PA] ai = void;
        V[PB][N] bi = void;

        prefetch_r!(V[M][PA].sizeof, 1, 8, prefetchShift)(cast(void*)a, 0);

        foreach (p; Iota!PA)
        foreach (m; Iota!M)
            ai[p][m] = a[0][p][m];

        enum AB = PA + PB == 4;
        enum CA = PC + PA == 4;
        enum CB = PC + PB == 4;

        foreach (u; Iota!(N/2 + N%2))
        //foreach (u; Iota!(N))
        {
            alias um = Iota!(2*u, 2*u + 2 > N ? 2*u + 1 : 2*u + 2);
            //alias um = AliasSeq!(u);
            foreach (n; um)
            foreach (p; Iota!PB)
                bi[n][p] = b[0][n][p];
            foreach (n; um)
            foreach (m; Iota!M)
            {
                reg[n][0][m] += ai[0][m] * bi[n][0];
 static if (CB) reg[n][1][m] += ai[0][m] * bi[n][1];
 static if (AB) reg[n][0][m] -= ai[1][m] * bi[n][1];
 static if (CA) reg[n][1][m] += ai[1][m] * bi[n][0];
            }
        }
        a++;
        b++;
    }
    while (--length);
    load_nano(c, reg);
    return a;
}


pragma(inline, true)
void prefetch_w(size_t M, size_t N, size_t rem = 1)(void* ptr, sizediff_t ld)
{
    version(PREFETCH)
    {
        import ldc.intrinsics: llvm_prefetch;
        foreach (n; Iota!N)
        {
            foreach (m; Iota!(M / 64 + bool(M % 64 >= rem)))
                llvm_prefetch(ptr + m * 64, 1, 3, 1);
            ptr += ld;
        }
    }
}

pragma(inline, true)
void prefetch_r(size_t M, size_t N, size_t rem, size_t shift)(void* ptr, sizediff_t ld)
{
    version(PREFETCH)
    {
        import ldc.intrinsics: llvm_prefetch;
        foreach (n; Iota!N)
        {
            foreach (m; Iota!(M / 64 + bool(M % 64 >= rem)))
            {
                llvm_prefetch(ptr + m * 64 + shift + ld * n, 0, 3, 1);
            }
        }
    }
}

pragma(inline, true)
void scale_nano(size_t M, size_t P, size_t N, V, F)(ref const F[P] alpha, ref V[M][P][N] c)
{
    V[P] s = void;
    V[M][P][N] reg = void;
    load_nano(s, alpha);
    load_nano(reg, c);
    foreach (n; Iota!N)
    foreach (m; Iota!M)
    {
        static if (P == 1)
        {
            reg[n][0][m] *= s[0];
        }
        else
        {
            auto re = s[0] * reg[n][0][m];
            auto im = s[0] * reg[n][1][m];
            re -= s[1] * reg[n][1][m];
            im += s[1] * reg[n][0][m];
            reg[n][0][m] = re;
            reg[n][1][m] = im;
        }
    }
    load_nano(c, reg);
}

pragma(inline, true)
ref auto castByRef(C)(return ref C val)
{
    import std.complex: Complex;
    static if (is(C : Complex!T, T))
        alias R = T[2];
    else
        alias R = C[1];
    return *cast(R*) &val;
}
