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

public import mir.glas.common;
import mir.ndslice.slice;
import mir.internal.utility;
import mir.glas.internal.config;


version(LDC) version = LLVM_PREFETCH;

@fastmath:

import std.complex;

private enum prefetchShift = 512;

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
    GLAS does not require transposition parameters.
    Use $(LINK2 mir_ndslice_iteration.html#transposed, mir.ndslice.iteration.transposed)
    to perform zero cost `Slice` transposition.

BLAS: SGEMM, DGEMM, CGEMM, ZGEMM

See_also: $(SUBREF common, Conjugation)
+/
//nothrow @nogc
void gemm(Conjugation type = conjN, C, A, B)
(
    GlasContext ctx,
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
    import std.stdio;
    import std.complex: Complex;
    import mir.ndslice.iteration: reversed, transposed;

    enum msg = "mir.glas does not allow slices on top of const/immutable/shared memory";
    static assert(is(Unqual!A == A), msg);
    static assert(is(Unqual!B == B), msg);
    static assert(is(Unqual!C == C), msg);

    import std.datetime, std.conv;

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

    if (sizediff_t(csl.stride!0) < 0)
    {
        csl = csl.reversed!0;
        asl = asl.reversed!0;
    }
    if (sizediff_t(csl.stride!1) < 0)
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
    alias conf = RegisterConfig!(PC, PA, PB, T);
    enum nr = conf.broadcast;
    enum mr = conf.simdChain[0].sizeof / T.sizeof;
    sizediff_t kc = (ctx.cache1Size - 2 * (T[PC][nr][mr].sizeof + nr * ctx.cacheLine) - 512) / (T[PA][mr].sizeof + T[PB][nr].sizeof);
    assert(ctx.cache1Size > mr);
    assert(kc > mr);
    kc.normalizeChunkSize!mr(asl.length!1);
    assert(kc > 0, "MIR.gemm: internal error (kc <= 0)");

SET_MC:

    auto df = T[PC][nr].sizeof + T[PA].sizeof * kc;
    sizediff_t mc = (ctx.cache2Size * 3 / 5 - kc * T[PB][nr].sizeof) / df;

    mc.normalizeChunkSize!nr(asl.length!0);

    auto a_length = kc * mc * T[PA].sizeof;
    auto b_length = kc * T[PB][nr].sizeof * bsl.length!1;
    auto buffLength = a_length + b_length;
    auto _mem = ctx.memory(a_length + b_length + prefetchShift);
    auto a = cast(T*) _mem.ptr;
    auto b = cast(T[PB]*) (_mem.ptr + a_length);
    for (;;)
    {
        if (asl.length!1 < kc)
        {
            if (asl.empty!1)
                break;
            kc = asl.length!1;
            goto SET_MC;
        }

        auto aslp = asl.transposed[0 .. kc].transposed;

        pack_b_nano_kernel!(PC, PA, PB, T, B)(bsl[0 .. kc].transposed, cast(T*) b);
        bsl.popFrontExactly!0(kc);

        auto c = cast(T[PC]*) csl.ptr;
        auto mc_ = mc;

        for (;;)
        {
            if (aslp.length!0 < mc_)
            {
                if (aslp.empty!0)
                    break;
                mc_ = aslp.length!0;
            }
            assert(kc * mc_ * T[PB].sizeof <= ctx.cache2Size);
            pack_a_nano_kernel!(PC, PA, PB, T, A)(aslp[0 .. mc_], a);
            aslp.popFrontExactly!0(mc_);

            gebp_opt1!(type, PC, PA, PB, T)(bsl.length!1, kc, mc_, csl.stride!1, c, alpha_, a, b);
            c += mc_;
        }

        asl.popFrontExactly!1(kc);
    }
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

    auto glas = new GlasContext;
    glas.gemm(c, 1.0, a, b);

    assert(c ==
        [[-42.0, 35, -7, 77],
         [-69.0, -21, -42, 21],
         [23.0, 69, 3, 29]]);
}

package:

void normalizeChunkSize(size_t subChunk)(ref sizediff_t chunk, size_t length)
{
    assert(length);
    assert(chunk > 0);
    auto ch = chunk;
    if (ch >= length)
    {
        chunk = length;
        return;
    }
    auto count = length / ch + (length % ch != 0);
    auto new_ch = length / count + (length % count != 0);
    if (auto r = new_ch % subChunk)
    {
        auto new_new_ch = new_ch + subChunk - r;
        if (new_new_ch <= ch)
        {
            chunk = new_new_ch;
            return;
        }
    }
    chunk = new_ch;
}

//pragma(inline, false)
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
    alias chain = conf.broadcastChain;
    if (sl.stride!0 == 1)
    {
        foreach (mri, mrType; mrTypeChain)
        {
            enum mr = mrType.sizeof / T.sizeof;
            if (sl.length >= mr) do
            {
                foreach (row_; sl[0 .. mr].transposed)
                {
                    auto row = row_.toDense;
                    static if (mr > 1 && !is(T == real) && LDC && (is(T == C) && PA == 1 || is(Complex!T == C) && PA == 2))
                    {
                        import ldc.simd;
                        alias V = __vector(T[mr]);
                        static if (PA == 1)
                        {
                            auto rv = loadUnaligned!V(cast(T*)row);
                            *cast(V*)a = rv;
                        }
                        else
                        {
                            auto r0 = loadUnaligned!V(cast(T*)row);
                            auto r1 = loadUnaligned!V(cast(T*)((cast(V*)row) + 1));
                            auto re = _re!V(r0, r1);
                            auto im = _im!V(r0, r1);
                            *cast(V*)a = re;
                            *((cast(V*)a) + 1) = im;
                        }
                    }
                    else
                    foreach (j; Iota!mr)
                    {
                        static if (PA == 2)
                        {
                            a[ 0 + j] = cast(T) row[j].re;
                            a[mr + j] = cast(T) row[j].im;
                        }
                        else
                        {
                            static if (isComplex!C)
                                a[j] = cast(T) row[j].re;
                            else
                                a[j] = cast(T) row[j];
                        }
                    }
                    a += mr * PA;
                }
                sl.popFrontExactly(mr);
            }
            while (!mri && sl.length >= mr);
        }

    }
    else
    {
        foreach (mri, mrType; mrTypeChain)
        {
            enum mr = mrType.sizeof / T.sizeof;
            if (sl.length >= mr) do
            {
                foreach (row; sl[0 .. mr].transposed)
                {
                    foreach (j; Iota!mr)
                    {
                        static if (PA == 2)
                        {
                            a[ 0 + j] = cast(T) row[j].re;
                            a[mr + j] = cast(T) row[j].im;
                        }
                        else
                        {
                            static if (isComplex!C)
                                a[j] = cast(T) row[j].re;
                            else
                                a[j] = cast(T) row[j];
                        }
                    }
                    a += mr * PA;
                }
                sl.popFrontExactly(mr);
            }
            while (!mri && sl.length >= mr);
        }
    }
}

//pragma(inline, false)
void pack_b_nano_kernel(size_t PC, size_t PA, size_t PB, T, C)(Slice!(2, C*) sl, T* b)
{
    import mir.ndslice.iteration: transposed;
    import std.complex: Complex;
    version(LDC)
        enum LDC = true;
    else
        enum LDC = false;
    alias conf = RegisterConfig!(PC, PA, PB, T);
    alias nrChain = conf.broadcastChain;
    if (sl.stride!0 == 1)
    {
        foreach (nri; Iota!(nrChain.length))
        {
            enum nr = nrChain[nri];
            if (sl.length >= nr) do
            {
                foreach (row_; sl[0 .. nr].transposed)
                {
                    auto row = row_.toDense;
                    static if (nr * PB > 1 && !is(T == real) && LDC && (is(T == C) && PB == 1 || is(Complex!T == C) && PB == 2))
                    {
                        import ldc.simd;
                        alias V = __vector(T[nr * PB]);
                        storeUnaligned!V(loadUnaligned!V(cast(T*)row), b);
                    }
                    else
                    foreach (j; Iota!nr)
                    {
                        static if (PB == 2)
                        {
                            b[2 * j + 0] = cast(T) row[j].re;
                            b[2 * j + 1] = cast(T) row[j].im;
                        }
                        else
                        {
                            static if (isComplex!C)
                                b[j] = cast(T) row[j].re;
                            else
                                b[j] = cast(T) row[j];
                        }
                    }
                    b += nr * PB;
                }
                sl.popFrontExactly(nr);
            }
            while (!nri && sl.length >= nr);
        }
    }
    else
    {
        foreach (nri; Iota!(nrChain.length))
        {
            enum nr = nrChain[nri];
            if (sl.length >= nr) do
            {
                foreach (row; sl[0 .. nr].transposed)
                {
                    foreach (j; Iota!nr)
                    {
                        static if (PB == 2)
                        {
                            b[2 * j + 0] = cast(T) row[j].re;
                            b[2 * j + 1] = cast(T) row[j].im;
                        }
                        else
                        {
                            static if (isComplex!C)
                                b[j] = cast(T) row[j].re;
                            else
                                b[j] = cast(T) row[j];
                        }
                    }
                    b += nr * PB;
                }
                sl.popFrontExactly(nr);
            }
            while (!nri && sl.length >= nr);
        }
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
    foreach (nri; Iota!(nrChain.length))
    {
        enum size_t nr = nrChain[nri];
        if (n >= nr) do
        {
            size_t mc = mc_;
            auto a = a_;
            auto c = c_;
            foreach (mri, mrType; mrTypeChain)
            {
                enum mr = mrType.sizeof / T.sizeof;
                if (mc >= mr) do
                {
                    a = gemm_micro_kernel!
                        (type, PC, PA, PB, mrType.length, nr, typeof(mrType.init[0]), T)
                        (alpha, cast(mrType[PA]*)a, cast(T[PB][nr]*)b, kc, c, ldc);
                    mc -= mr;
                    c += mr;
                }
                while (!mri && mc >= mr);
            }
            n -= nr;
            c_ += nr * ldc;
            b += nr * kc;
        }
        while (!nri && n >= nr);
    }
}

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
    version(LDC) pragma(inline, true);

    version(LLVM_PREFETCH)
    {
        import ldc.intrinsics: llvm_prefetch;

        foreach (m; Iota!M)
        foreach (pr; Iota!(V[N][PC].sizeof / 64 + bool(V[N][PC].sizeof % 64 > 0)))
            llvm_prefetch(cast(void*)c + pr * 64 + ldc * m, 1, 3, 1);
    }
    V[N][PC][M] reg = void;
    reg.set_zero_nano_kernel;
    auto ret = gemm_nano_kernel!type(reg, a, b, length)[0];
    reg.scale_nano_kernel!(PA + PB == 2)(alpha);
    save_nano_kernel(reg, c, ldc);
    return ret;
}

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
    version(LDC) pragma(inline, true);

    V[N][PC][M] reg = void;

    foreach (m; Iota!M)
    foreach (p; Iota!PC)
    foreach (n; Iota!N)
        reg[m][p][n] = c[m][p][n];

    do
    {
        V[N][PA] ai = void;
        V[PB][M] bi = void;

        foreach (p; Iota!PA)
        foreach (n; Iota!N)
            ai[p][n] = a[0][p][n];

        version(LLVM_PREFETCH) version(X86_64)
        {
            import ldc.intrinsics: llvm_prefetch;

            foreach (pr; Iota!(V[N][PA].sizeof / 64 + bool(V[N][PA].sizeof % 64 >= 32)))
                llvm_prefetch(cast(void*)a + pr * 64 + prefetchShift, 0, 3, 1);
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
                else static if (type == Conjugation.sub)
                {
                    reg[m][0][n] -= ai[0][n] * bi[m][0];
     static if (CB) reg[m][1][n] -= ai[0][n] * bi[m][1];
     static if (AB) reg[m][0][n] += ai[1][n] * bi[m][1];
     static if (CA) reg[m][1][n] -= ai[1][n] * bi[m][0];
                }
                else static if (type == Conjugation.conjA)
                {
                    reg[m][0][n] += ai[0][n] * bi[m][0];
     static if (CB) reg[m][1][n] += ai[0][n] * bi[m][1];
     static if (AB) reg[m][0][n] += ai[1][n] * bi[m][1];
     static if (CA) reg[m][1][n] -= ai[1][n] * bi[m][0];
                }
                else static if (type == Conjugation.conjB)
                {
                    reg[m][0][n] += ai[0][n] * bi[m][0];
     static if (CB) reg[m][1][n] -= ai[0][n] * bi[m][1];
     static if (AB) reg[m][0][n] += ai[1][n] * bi[m][1];
     static if (CA) reg[m][1][n] += ai[1][n] * bi[m][0];
                }
                else static if (type == Conjugation.conjC)
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

    const(F)*[2] ret = void;
    ret[0] = cast(F*) a;
    ret[1] = cast(F*) b;
    return ret;
}

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
    version(LDC) pragma(inline, true);

    V[N][P][M] reg = void;

    foreach (m; Iota!M)
    foreach (p; Iota!P)
    foreach (n; Iota!N)
        reg[m][p][n] = c[m][p][n];

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
            auto im = s[1] * reg[m][0][n];
            static if (!realOnly)
            {
                re -= s[1] * reg[m][1][n];
                im += s[0] * reg[m][1][n];
            }
            reg[m][0][n] = re;
            reg[m][1][n] = im;
        }
    }

    foreach (m; Iota!M)
    foreach (p; Iota!P)
    foreach (n; Iota!N)
        c[m][p][n] = reg[m][p][n];
}

void save_nano_kernel(size_t P, size_t N, size_t M, V, T)
    (ref V[N][P][M] reg, T[P]* c, sizediff_t ldc)
{
    version(LDC) pragma(inline, true);
    foreach (m; Iota!M)
    {
        save_nano_kernel_impl(reg[m], c + ldc * m);
    }
}
version(LDC)
{
    pragma(inline, true)
    void save_nano_kernel_impl(size_t P, size_t N, V, T)(ref V[N][P] reg, T[P]* c)
    {
        import ldc.simd;
        foreach (j; Iota!(N))
        {
            static if (P == 1)
            {
                static if (isSIMDVector!V)
                {
                    auto cj = loadUnaligned!V(cast(T*)(c + j * V.length));
                    cj += reg[0][j];
                    storeUnaligned!V(cj, cast(T*)(c + j * V.length));
                }
                else
                {
                    c[j][0] += reg[0][j];
                }
            }
            else
            {
                static if (isSIMDVector!V)
                {
                    auto cj0 = loadUnaligned!V(cast(T*)(c + j * V.length));
                    auto cj1 = loadUnaligned!V(cast(T*)((cast(V*)(c + j * V.length)) + 1));
                    auto re = reg[0][j];
                    auto im = reg[1][j];
                    auto r0 = _mix0!V(re, im);
                    auto r1 = _mix1!V(re, im);
                    cj0 += r0;
                    cj1 += r1;
                    storeUnaligned!V(cj0, cast(T*)(c + j * V.length));
                    storeUnaligned!V(cj1, cast(T*)((cast(V*)(c + j * V.length)) + 1));
                }
                else
                {
                    c[j][0] += reg[0][j];
                    c[j][1] += reg[1][j];
                }
            }
        }
    }
}
else
{
    void save_nano_kernel_impl(size_t P, size_t N, V, T)(ref V[N][P] reg, T[P]* c)
    {
        foreach (j; Iota!(N * V.sizeof / T.sizeof))
        {
            foreach (p; Iota!P)
            {
                c[j][p] += (cast(T*) &reg[p])[j];
            }
        }
    }
}

version(LDC)
{
    template _mix0(V)
    {
        import ldc.simd;
        enum _pred(size_t a) = (a & 1) == 0 ? a / 2 : a / 2 + V.length;
        alias _mix0 = shufflevector!(V, staticMap!(_pred, Iota!(V.length)));
    }

    template _mix1(V)
    {
        import ldc.simd;
        enum _pred(size_t a) = ((a & 1) == 0 ? a / 2 : a / 2 + V.length) + V.length / 2;
        alias _mix1 = shufflevector!(V, staticMap!(_pred, Iota!(V.length)));
    }

    template _re(V)
    {
        import ldc.simd;
        enum _pred(size_t a) = (a & 1) == 0;
        alias _re = shufflevector!(V, Filter!(_pred, Iota!(V.length * 2)));
    }

    template _im(V)
    {
        import ldc.simd;
        enum _pred(size_t a) = (a & 1) != 0;
        alias _im = shufflevector!(V, Filter!(_pred, Iota!(V.length * 2)));
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
void load_nano_kernel(size_t A, V, F)
(ref V[A] to, ref const F[A] from)
    if (!isStaticArray!F)
{
    version(LDC) pragma(inline, true);
    static if (isSIMDVector!V && !isSIMDVector!F)
        version(LDC)
        foreach (p; Iota!A)
                to[p] = from[p];
        else
        foreach (p; Iota!A)
        {
            auto e = from[p];
            foreach (s; Iota!(to[p].array.length))
                to[p].array[s] = e;
        }
    else
    foreach (p; Iota!A)
        to[p] = from[p];
}

pragma(inline, true)
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

unittest
{
    import std.complex;
    foreach (trans; AliasSeq!(true, false))
    foreach (T; AliasSeq!(uint, double, Complex!double))
    {
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
