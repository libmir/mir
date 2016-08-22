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
import mir.ndslice.slice;
import mir.internal.utility;
import mir.glas.internal.config;

alias fff = gemm!(conjN, Complex!float, Complex!float, Complex!float);

version(LDC) version = LLVM_PREFETCH;

@fastmath:


private enum prefetchShift = 512;

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
//nothrow @nogc
pragma(inline, false)
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

struct BlockInfo(T)
{
    sizediff_t mc;
    sizediff_t kc;
    T* a;
    T* b;
}

BlockInfo!T blocking(size_t PC, size_t PA, size_t PB, T)(GlasContext* ctx, size_t m, size_t k, size_t n)
{
    import mir.glas.internal.context;
    mixin RegisterConfig!(PC, PA, PB, T);
    BlockInfo!T ret = void;

    sizediff_t l2 = (c2.size << 10) / 2;

    ret.kc = (l2 - m * T[PC][nr].sizeof) / (m * T[PA].sizeof + T[PB][nr].sizeof);
    ret.mc = m;
    enum minKc = 320 / PC;

    import std.stdio;

    if (ret.kc < minKc)
    {
        ret.kc = ((c1.size << 10) - 2 * (T[PC][nr][mr].sizeof + nr * c1.line) - 512) / (T[PA][mr].sizeof + T[PB][nr].sizeof);
        assert(c1.size << 10 > mr);
        assert(ret.kc > mr);
        ret.kc.normalizeChunkSize!mr(k);
        assert(ret.kc > 0);
        auto df = T[PC][nr].sizeof + T[PA].sizeof * ret.kc;
        ret.mc = (l2 - ret.kc * T[PB][nr].sizeof) / df;
        ret.mc.normalizeChunkSize!nr(m);
    }
    else
    {
        ret.kc.normalizeChunkSize!mr(k);
    }

    auto a_length = ret.kc * ret.mc * T[PA].sizeof;
    auto b_length = ret.kc * T[PB][nr].sizeof * (ret.mc == m && false ? nr : n);
    auto buffLength = a_length + b_length;
    auto _mem = ctx.memory(a_length + b_length + prefetchShift);
    ret.a = cast(T*) _mem.ptr;
    ret.b = cast(T*) (_mem.ptr + a_length);

    return ret;
}

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

void pack_dense_a_nano_kernel(bool llvmDense, size_t n, size_t P, F, T)(size_t length, in F* from, T* to)
{
    enum s = n * P;
    do
    {
        static if (llvmDense)
        {
            import ldc.simd;
            alias V = __vector(T[n]);
            static if (P == 1)
            {
                auto rv = loadUnaligned!V(cast(T*)from);
                *cast(V*)to = rv;
            }
            else
            {
                auto r0 = loadUnaligned!V(cast(T*)from);
                auto r1 = loadUnaligned!V(cast(T*)((cast(V*)from) + 1));
                auto re = _re!V(r0, r1);
                auto im = _im!V(r0, r1);
                *cast(V*)to = re;
                *((cast(V*)to) + 1) = im;
            }
        }
        else
        {
            foreach (i; Iota!n)
            {
                static if (P == 2)
                {
                    a[0 + i] = cast(T) row[i].re;
                    a[n + i] = cast(T) row[i].im;
                }
                else
                {
                    static if (isComplex!C)
                        a[i] = cast(T) row[i].re;
                    else
                        a[i] = cast(T) row[i];
                }
            }
        }
        from += n;
        to += s;
    }
    while (--length);
}

T* pack_dense_b_nano_kernel(bool llvmDense, size_t n, size_t P, F, T)(size_t length, size_t stride, F* from, T* to)
{
    enum s = n * P;
    do
    {
        static if (llvmDense)
        {
            import ldc.simd;
            alias V = __vector(T[s]);
            storeUnaligned!V(loadUnaligned!V(cast(T*)from), to);
            from += s;
            to += s;
        }
        else
        {
            foreach (i; Iota!n)
            {
                static if (P == 2)
                {
                    to[2 * i + 0] = cast(T) from[i].re;
                    to[2 * i + 1] = cast(T) from[i].im;
                }
                else
                {
                    static if (isComplex!F)
                        to[i] = cast(T) from[i].re;
                    else
                        to[i] = cast(T) from[i];
                }
            }
        }
        from += stride;
        to += s;
    }
    while (--length);
    return to;
}

//pragma(inline, false)
T* pack_strided_b_nano_kernel(size_t n, size_t P, F, T)(size_t length, size_t stride, size_t elemStride, F* from, T* to)
{
    enum s = n * P;
    do
    {
        foreach (i; Iota!n)
        {
            static if (P == 2)
            {
                to[2 * i + 0] = cast(T) from[elemStride * i].re;
                to[2 * i + 1] = cast(T) from[elemStride * i].im;
            }
            else
            {
                static if (isComplex!F)
                    to[i] = cast(T) from[elemStride * i].re;
                else
                    to[i] = cast(T) from[elemStride * i];
            }
        }
        from += stride;
        to += s;
    }
    while (--length);
    return to;
}


//pragma(inline, false)
void pack_a_micro_kernel(size_t PC, size_t PA, size_t PB, T, C)(Slice!(2, C*) sl, T* a)
{
    import std.complex: Complex;
    version(LDC)
        enum LDC = true;
    else
        enum LDC = false;
    import mir.ndslice.iteration: transposed;
    mixin RegisterConfig!(PC, PA, PB, T);
    if (sl.stride!0 == 1)
    {
        foreach (mri, mrType; simdChain)
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
        foreach (mri, mrType; simdChain)
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
void pack_b_micro_kernel(size_t PC, size_t PA, size_t PB, T, C)(Slice!(2, C*) sl, T* b)
{
    import mir.ndslice.iteration: transposed;
    import std.complex: Complex;
    version(LDC)
        enum LDC = true;
    else
        enum LDC = false;
    mixin RegisterConfig!(PC, PA, PB, T);
    if (sl.stride!0 == 1)
    {
        foreach (nri; Iota!(broadcastChain.length))
        {
            enum nr = broadcastChain[nri];
            if (sl.length >= nr) do
            {
                enum llvm = nr * PB > 1 && !is(T == real) && LDC && (is(T == C) && PB == 1 || is(Complex!T == C) && PB == 2);
                b = pack_dense_b_nano_kernel!(llvm, nr, PB)(sl.length!1, sl.stride!1, sl.ptr, b);
                sl.popFrontExactly(nr);
            }
            while (!nri && sl.length >= nr);
        }
    }
    else
    {
        foreach (nri; Iota!(broadcastChain.length))
        {
            enum nr = broadcastChain[nri];
            if (sl.length >= nr) do
            {
                b = pack_strided_b_nano_kernel!(nr, PB)(sl.length!1, sl.stride!1, sl.stride!0, sl.ptr, b);
                sl.popFrontExactly(nr);
            }
            while (!nri && sl.length >= nr);
        }
    }
}

void gebp_opt1_dot(Conjugation type, size_t PC, size_t PA, size_t PB, T, C)(
    size_t n,
    const size_t mc,
    const size_t kc,
    const sizediff_t ldc,
    const sizediff_t ldb,
    const sizediff_t ldeb,
    scope T* c,
    const(T)* a,
    T* b,
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
    if (ldeb == 1)
    {
        foreach (nri; Iota!(broadcastChain.length))
        {
            enum nr = broadcastChain[nri];
            if (n >= nr) do
            {
                enum llvm = nr * PB > 1 && !is(T == real) && LDC && (is(T == C) && PB == 1 || is(Complex!T == C) && PB == 2);
                pack_dense_b_nano_kernel!(llvm, nr, PB)(kc, ldb, slbPtr, b);
                slbPtr += nr * ldeb;
                gemm_micro_kernel!
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
                pack_strided_b_nano_kernel!(nr, PB)(kc, ldb, ldeb, slbPtr, b);
                slbPtr += nr * ldeb;
                gemm_micro_kernel!
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
    const(T)* a,
    const(T)* b,
    const T[PC] alpha,
    )
{
    mixin RegisterConfig!(PC, PA, PB, T);
    foreach (nri; Iota!(broadcastChain.length))
    {
        enum size_t nr = broadcastChain[nri];
        if (n >= nr) do
        {
            gemm_micro_kernel!
                        (type, PC, PA, PB, nr, T)
                        (mc, kc, ldc, c, a, b, alpha);
            n -= nr;
            c += nr * PC * ldc;
            b += nr * PB * kc ;
        }
        while (!nri && n >= nr);
    }
}

pragma(inline, true)
void gemm_micro_kernel (
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
    F* c,
    const(F)* a,
    const(F)* b,
    F[PC] alpha,
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
            version(LLVM_PREFETCH)
            {
                import ldc.intrinsics: llvm_prefetch;

                foreach (m; Iota!M)
                foreach (pr; Iota!(V[N][PC].sizeof / 64 + bool(V[N][PC].sizeof % 64 > 0)))
                    llvm_prefetch(cast(void*)c + pr * 64 + ldc * m, 1, 3, 1);
            }
            V[N][PC][M] reg = void;
            a = gemm_nano_kernel!type(reg, cast(const(V[N][PA])*) a, cast(const(F[PB][M])*)b, kc)[0];
            reg.scale_nano_kernel!(PA + PB == 2)(alpha);
            save_nano_kernel(reg, cast(F[PC]*)c, ldc);
            mc -= mr;
            c += mr * PC;
        }
        while (!mri && mc >= mr);
    }
}

pragma(inline, true)
const(F)*[2]
gemm_nano_kernel (
    Conjugation type,
    bool sub = false,
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
                    static if (type == conjN && !sub)
                {
                    reg[m][0][n] += ai[0][n] * bi[m][0];
     static if (CB) reg[m][1][n] += ai[0][n] * bi[m][1];
     static if (AB) reg[m][0][n] -= ai[1][n] * bi[m][1];
     static if (CA) reg[m][1][n] += ai[1][n] * bi[m][0];
                }
                else static if (type == conjN &&  sub)
                {
                    reg[m][0][n] -= ai[0][n] * bi[m][0];
     static if (CB) reg[m][1][n] -= ai[0][n] * bi[m][1];
     static if (AB) reg[m][0][n] += ai[1][n] * bi[m][1];
     static if (CA) reg[m][1][n] -= ai[1][n] * bi[m][0];
                }
                else static if (type == conjA && !sub)
                {
                    reg[m][0][n] += ai[0][n] * bi[m][0];
     static if (CB) reg[m][1][n] += ai[0][n] * bi[m][1];
     static if (AB) reg[m][0][n] += ai[1][n] * bi[m][1];
     static if (CA) reg[m][1][n] -= ai[1][n] * bi[m][0];
                }
                else static if (type == conjA &&  sub)
                {
                    reg[m][0][n] -= ai[0][n] * bi[m][0];
     static if (CB) reg[m][1][n] -= ai[0][n] * bi[m][1];
     static if (AB) reg[m][0][n] -= ai[1][n] * bi[m][1];
     static if (CA) reg[m][1][n] += ai[1][n] * bi[m][0];
                }
                else static if (type == conjB && !sub)
                {
                    reg[m][0][n] += ai[0][n] * bi[m][0];
     static if (CB) reg[m][1][n] -= ai[0][n] * bi[m][1];
     static if (AB) reg[m][0][n] += ai[1][n] * bi[m][1];
     static if (CA) reg[m][1][n] += ai[1][n] * bi[m][0];
                }
                else static if (type == conjB &&  sub)
                {
                    reg[m][0][n] -= ai[0][n] * bi[m][0];
     static if (CB) reg[m][1][n] += ai[0][n] * bi[m][1];
     static if (AB) reg[m][0][n] -= ai[1][n] * bi[m][1];
     static if (CA) reg[m][1][n] -= ai[1][n] * bi[m][0];
                }
                else static if (type == conjC && !sub)
                {
                    reg[m][0][n] += ai[0][n] * bi[m][0];
     static if (CB) reg[m][1][n] -= ai[0][n] * bi[m][1];
     static if (AB) reg[m][0][n] -= ai[1][n] * bi[m][1];
     static if (CA) reg[m][1][n] -= ai[1][n] * bi[m][0];
                }
                else static if (type == conjC &&  sub)
                {
                    reg[m][0][n] -= ai[0][n] * bi[m][0];
     static if (CB) reg[m][1][n] += ai[0][n] * bi[m][1];
     static if (AB) reg[m][0][n] += ai[1][n] * bi[m][1];
     static if (CA) reg[m][1][n] += ai[1][n] * bi[m][0];
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

pragma(inline, true)
void save_nano_kernel(size_t P, size_t N, size_t M, V, T)
    (ref V[N][P][M] reg, T[P]* c, sizediff_t ldc)
{
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
    pragma(inline, true)
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
