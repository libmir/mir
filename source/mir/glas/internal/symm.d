module mir.glas.internal.symm;

import std.traits;
import std.complex;
import std.meta;

public import mir.glas.common;
import mir.ndslice.slice : Slice;
import mir.internal.utility;
import mir.glas.internal;
import mir.glas.internal.gemm;

import ldc.attributes : fastmath;
@fastmath:

pragma(inline, false)
//nothrow @nogc
void symm_impl(A, B, C)
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

    if (asl.empty!0)
        return;
    if (bsl.empty!1)
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

    if (asl.empty!1 || alpha == 0)
    {
        if (beta == 0)
        {
            foreach (row; csl)
                row.toDense[] = C(0);
            return;
        }
        if (beta == 1)
            return;
        foreach (row; csl)
            row.toDense[] *= beta;
        return;
    }

    mixin RegisterConfig!(PA, PB, PC, T);

    Kernel!(PC, T)[nr_chain.length]
        beta_kernels = void,
        one_kernels = void;

    static if (PA == PB)
    {
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
    }
    if (csl.stride!0 == 1)
    {
        static if (PA != PB)
        {
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
        }

        auto bl = blocking!(PA, PB, PC, T)(ctx, asl.length!0, bsl.length!1, asl.length!0);
        size_t j;
        sizediff_t incb;
        if (bl.mc  < asl.length!0)
            incb = bl.kc;
        with(bl) do
        {
            if (asl.length!0 - j < kc)
                kc = asl.length!0 - j;
            ////////////////////////
            size_t i;
            auto bsl_ptr = bsl.ptr;
            auto cslm = csl;
            auto mc = mc;
            //======================
            do
            {
                if (asl.length!0 - i < mc)
                    mc = asl.length!0 - i;

                if (PA && conja)
                    pack_a_sym!(PA, PB, PC, true, T, A)(asl, i, j, mc, kc, a);
                else
                    pack_a_sym!(PA, PB, PC, false, T, A)(asl, i, j, mc, kc, a);
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
                    conjb
                    );
                ////////////////////////
                bsl_ptr = null;
                cslm.popFrontExactly!0(mc);
                i += mc;
            }
            while (i < asl.length!0);
            ////////////////////////
            kernels = one_kernels.ptr;
            bsl.popFrontExactly!0(kc);
            j += kc;
        }
        while (j < asl.length!0);
    }
    else
    {
        static if (PA != PB)
        {
            foreach (nri, nr; nr_chain)
                one_kernels [nri] = &gemv_reg!(BetaType.one, PB, PA, PC, nr, T);

            Kernel!(PC, T)* kernels = one_kernels.ptr;
            if (beta == 0)
            {
                foreach (nri, nr; nr_chain)
                    beta_kernels[nri] = &gemv_reg!(BetaType.zero, PB, PA, PC, nr, T);
                kernels = beta_kernels.ptr;
            }
            else
            if (beta != 1)
            {
                foreach (nri, nr; nr_chain)
                    beta_kernels[nri] = &gemv_reg!(BetaType.beta, PB, PA, PC, nr, T);
                kernels = beta_kernels.ptr;
            }
        }
        asl = asl.transposed;
        bsl = bsl.transposed;
        csl = csl.transposed;
        assert(csl.stride!0 == 1);
        auto bl = blocking!(PB, PA, PC, T)(ctx, bsl.length!0, asl.length!0, bsl.length!1);
        sizediff_t incb;
        if (bl.mc < bsl.length!0)
            incb = bl.kc;
        size_t j;
        with(bl) do
        {
            if (bsl.length!1 < kc)
                kc = bsl.length!1;
            ////////////////////////
            auto bslp = bsl[0 .. $, 0 .. kc];
            auto copy = true;
            auto cslm = csl;
            auto mc = mc;
            //======================
            do
            {
                if (bslp.length!0 < mc)
                    mc = bslp.length!0;
                ////////////////////////
                if (conjb)
                    pack_a!(PB, PA, PC, true, T, B)(bslp[0 .. mc], a);
                else
                    pack_a!(PB, PA, PC, false, T, B)(bslp[0 .. mc], a);
                //======================
                sybp!(PB, PA, PC, T, A)(
                    mc,
                    asl.length!0,
                    kc,
                    alpha.castByRef,
                    a,
                    b,
                    incb,
                    asl,
                    j,
                    copy,
                    beta.castByRef,
                    cast(T*) cslm.ptr,
                    cslm.stride!1,
                    kernels,
                    conja,
                    );
                ////////////////////////
                copy = false;
                cslm.popFrontExactly!0(mc);
                bslp.popFrontExactly!0(mc);
            }
            while (bslp.length!0);
            ////////////////////////
            j += kc;
            kernels = one_kernels.ptr;
            bsl.popFrontExactly!1(kc);
        }
        while (bsl.length!1);
    }
}

pragma(inline, true)
void sybp(size_t PA, size_t PB, size_t PC, F, B, C)(
    size_t mc,
    size_t nc,
    size_t kc,
    const F[PC] alpha,
    scope const(F)* a,
    scope F* b,
    sizediff_t incb,
    Slice!(2, C*) bsl,
    size_t j,
    bool copy,
    ref const F[PC] beta,
    scope F* c,
    sizediff_t ldc,
    Kernel!(PC, F)* kernels,
    Conjugated conj,
    )
{
    mixin RegisterConfig!(PA, PB, PC, F);
    size_t i;
    foreach (nri, nr; nr_chain)
    if (nc >= nr) do
    {
        if (copy)
        {
            if (PB && conj)
                pack_b_sym_nano!(nr, PB, true)(kc, bsl, j, i, b);
            else
                pack_b_sym_nano!(nr, PB, false)(kc, bsl, j, i, b);
            i += nr;
        }
        kernels[nri](mc, kc, alpha, a, b, beta, c, ldc);
        b +=  nr * PB * incb;
        nc -= nr;
        c += nr * PC * ldc;
    }
    while (!nri && nc >= nr);
}
