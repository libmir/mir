module mir.glas.internal.copy;

import std.traits;
import std.meta;
import mir.ndslice.slice : Slice;
import mir.internal.utility;
import mir.glas.internal.config;
import mir.glas.common;

import ldc.attributes : fastmath;
@fastmath:

pragma(inline, true)
T* pack_b_nano(size_t n, size_t P, bool conj = false, F, T)(size_t length, sizediff_t stride, sizediff_t elemStride, const(F)* from, T* to)
{
    if (elemStride == 1)
        return pack_b_dense_nano!(n, P, conj)(length, stride, from, to);
    else
        return pack_b_strided_nano!(n, P, conj)(length, stride, elemStride, from, to);
}

pragma(inline, false)
T* pack_b_sym_nano(size_t n, size_t P, bool conj = false, F, T)(size_t length, Slice!(2, const(F)*) sl, size_t j, size_t i, T* to)
{
    {
        sizediff_t diff = i - j;
        if (diff > 0)
        {
            diff++;
            if (diff > length)
                diff = length;
            to = pack_b_nano!(n, P, false, F, T)(diff, sl.stride!0, sl.stride!1, &sl[j, i], to);
            j += diff;
            length -= diff;
            if (length == 0)
                return to;
        }
    }

    auto from = &sl[i, j];
    foreach (u; sizediff_t(j - i) .. n - 1)
    {
        auto pfrom = from;
        foreach (v; 0 .. u)
        {
            static if (P == 1)
            {
                static if (isComplex!F)
                    to[0] = cast(T) pfrom[0].re;
                else
                    to[0] = cast(T) pfrom[0];
            }
            else
            {
                to[0] = cast(T) pfrom.re;
                static if (conj == false)
                    to[1] = cast(T) pfrom.im;
                else
                    to[1] = -cast(T) pfrom.im;

            }
            to += P;
            pfrom += sl.stride!0;
        }
        foreach (v; u .. n)
        {
            static if (P == 1)
            {
                static if (isComplex!F)
                    to[0] = cast(T) pfrom[0].re;
                else
                    to[0] = cast(T) pfrom[0];
            }
            else
            {
                to[0] = cast(T) pfrom.re;
                to[1] = cast(T) pfrom.im;
            }
            to += P;
            pfrom += sl.stride!1;
        }
        from += sl.stride!1;
        j++;
        length--;
        if (length == 0)
            return to;
    }
    return pack_b_nano!(n, P, conj, F, T)(length, sl.stride!1, sl.stride!0, from, to);
}

pragma(inline, false)
T* pack_b_strided_nano(size_t n, size_t P, bool conj = false, F, T)(size_t length, sizediff_t stride, sizediff_t elemStride, const(F)* from, T* to)
{
    enum s = n * P;
    do
    {
        foreach (i; Iota!n)
        {
            static if (P == 2)
            {
                to[2 * i + 0] = cast(T) from[elemStride * i].re;
                static if (conj == false)
                    to[2 * i + 1] = cast(T) from[elemStride * i].im;
                else
                    to[2 * i + 1] = -cast(T) from[elemStride * i].im;
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
T* pack_b_dense_nano(size_t n, size_t P, bool conj = false, F, T)(size_t length, sizediff_t stride, const(F)* from, T* to)
{
    enum s = n * P;
    do
    {
        static if (conj == false && n * P > 1 && !is(T == real) && (is(T == F) && P == 1 || is(Complex!T == F) && P == 2))
        {
            import ldc.simd;
            alias V = __vector(T[s]);
            static if (conj == false)
                storeUnaligned!V(loadUnaligned!V(cast(T*)from), to);
            else
                storeUnaligned!V(-loadUnaligned!V(cast(T*)from), to);
        }
        else
        {
            foreach (i; Iota!n)
            {
                static if (P == 2)
                {
                    to[2 * i + 0] = cast(T) from[i].re;
                    static if (conj == false)
                        to[2 * i + 1] = cast(T) from[i].im;
                    else
                        to[2 * i + 1] = -cast(T) from[i].im;
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

pragma(inline, true)
T* pack_a_nano(size_t n, size_t P, bool conj = false, F, T)(size_t length, sizediff_t stride, sizediff_t elemStride, const(F)* from, T* to)
{
    if (elemStride == 1)
        return pack_a_dense_nano!(n, P, conj)(length, stride, from, to);
    else
        return pack_a_strided_nano!(n, P, conj)(length, stride, elemStride, from, to);
}

//pragma(inline, false)
T* pack_a_strided_nano(size_t n, size_t P, bool conj = false, F, T)(size_t length, sizediff_t stride, sizediff_t elemStride, const(F)* from, T* to)
{
    static if (P == 1)
    {
        return pack_b_strided_nano!(n, P, conj, F, T)(length, stride, elemStride, from, to);
    }
    else
    {
        enum s = n * P;
        do
        {
            foreach (i; Iota!n)
            {
                to[i + 0] = cast(T) from[elemStride * i].re;
                static if (conj == false)
                    to[i + n] = cast(T) from[elemStride * i].im;
                else
                    to[i + n] = -cast(T) from[elemStride * i].im;
            }
            from += stride;
            to += s;
        }
        while (--length);
        return to;
    }
}

//pragma(inline, false)
T* pack_a_dense_nano(size_t mr, size_t P, bool conj = false, T, F)(size_t length, sizediff_t stride, const(F)* from, T* to)
{
    do
    {
        static if (mr > 1 && !is(T == real) && (is(T == F) && P == 1 || is(Complex!T == F) && P == 2))
        {
            import ldc.simd;
            alias V = __vector(T[mr]);
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
                static if (conj == false)
                    *((cast(V*)to) + 1) = im;
                else
                    *((cast(V*)to) + 1) = -im;
            }
        }
        else
        foreach (j; Iota!mr)
        {
            static if (P == 2)
            {
                to[ 0 + j] = cast(T) from[j].re;
                static if (conj == false)
                    to[mr + j] = cast(T) from[j].im;
                else
                    to[mr + j] = -cast(T) from[j].im;
            }
            else
            {
                static if (isComplex!F)
                    to[j] = cast(T) from[j].re;
                else
                    to[j] = cast(T) from[j];
            }
        }
        from += stride;
        to += mr * P;
    }
    while (--length);
    return to;
}

pragma(inline, false)
void pack_a(size_t PA, size_t PB, size_t PC, bool conj = false, T, C)(Slice!(2, const(C)*) sl, T* a)
{
    import mir.ndslice.iteration: transposed;
    mixin RegisterConfig!(PC, PA, PB, T);
    if (sl.stride!0 == 1)
    {
        foreach (mri, mr; mr_chain)
        if (sl.length >= mr) do
        {
            a = pack_a_dense_nano!(mr, PA, conj, T, C)(sl.length!1, sl.stride!1, sl.ptr, a);
            sl.popFrontExactly(mr);
        }
        while (!mri && sl.length >= mr);
    }
    else
    {
        foreach (mri, mr; mr_chain)
        if (sl.length >= mr) do
        {
            a = pack_a_strided_nano!(mr, PA, conj, C, T)(sl.length!1, sl.stride!1, sl.stride!0, sl.ptr, a);
            sl.popFrontExactly(mr);
        }
        while (!mri && sl.length >= mr);
    }
}

pragma(inline, false)
void pack_a_sym(size_t PA, size_t PB, size_t PC, bool conj = false, T, F)(Slice!(2, const(F)*) sl, size_t i, size_t t, size_t mc, size_t kc, T* to)
{
    import mir.ndslice.iteration: transposed, reversed;
    mixin RegisterConfig!(PC, PA, PB, T);
    foreach (mri, mr; mr_chain)
    if (mc >= mr) do
    {
        size_t j = t;
        size_t length = kc;
        {
            sizediff_t diff = i - j;
            if (diff > 0)
            {
                diff++;
                if (diff > length)
                    diff = length;
                to = pack_a_nano!(mr, PA, false, F, T)(diff, sl.stride!1, sl.stride!0, &sl[i, j], to);
                j += diff;
                length -= diff;
                if (length == 0)
                {
                    mc -= mr;
                    i += mr;
                    continue;
                }
            }
        }
        auto tos = to;
        auto from = &sl[j, i];
        foreach (u; sizediff_t(j - i) .. mr - 1)
        {
            auto pfrom = from;
            foreach (v; 0 .. u)
            {
                static if (PA == 1)
                {
                    static if (isComplex!F)
                        to[0] = cast(T) pfrom[0].re;
                    else
                        to[0] = cast(T) pfrom[0];
                }
                else
                {
                    to[ 0] = cast(T) pfrom.re;
                    //to[mr] = cast(T) pfrom.im;
                    static if (conj == false)
                        to[mr] = cast(T) pfrom.im;
                    else
                        to[mr] = -cast(T) pfrom.im;

                }
                to++;
                pfrom += sl.stride!1;
            }
            foreach (v; u .. mr)
            {
                static if (PA == 1)
                {
                    static if (isComplex!F)
                        to[0] = cast(T) pfrom[0].re;
                    else
                        to[0] = cast(T) pfrom[0];
                }
                else
                {
                    to[ 0] = cast(T) pfrom.re;
                    to[mr] = cast(T) pfrom.im;
                    //static if (conj == false)
                    //    to[mr] = cast(T) pfrom.im;
                    //else
                    //    to[mr] = -cast(T) pfrom.im;
                }
                to++;
                pfrom += sl.stride!0;
            }
            static if (PA == 2)
                to += mr;
            from += sl.stride!0;
            j++;
            length--;
            if (length == 0)
                break;
        }
        tos = to;
        if (length)
            to = pack_a_nano!(mr, PA, conj, F, T)(length, sl.stride!0, sl.stride!1, from, to);
        mc -= mr;
        i += mr;
    }
    while (!mri && mc >= mr);
}


//pragma(inline, false)
void pack_b_triangular(Uplo uplo, bool inverseDiagonal, size_t PA, size_t PB, size_t PC, T, C)(Slice!(2, const(C)*) sl, T* b)
{
    assert(sl.length!0 == sl.length!1);
    import mir.ndslice.iteration: transposed;

    mixin RegisterConfig!(PC, PA, PB, T);
    static if (uplo == Uplo.lower)
        size_t length;
    foreach (nri, nr; nr_chain)
    if (sl.length >= nr) do
    {
        static if (uplo == Uplo.lower)
            length += nr;
        else
            size_t length = sl.length;
        if (sl.stride!0 == 1)
            b = pack_b_dense_nano!(nr, PB)(length, sl.stride!1, sl.ptr, b);
        else
            b = pack_b_strided_nano!(nr, PB)(length, sl.stride!1, sl.stride!0, sl.ptr, b);
        static if (inverseDiagonal)
        {
            auto a = cast(T[PB]*) b;
            foreach (i; Iota!nr)
            {
                enum sizediff_t j = i + i * nr - sizediff_t(nr * nr);
                static if (PB == 1)
                {
                    a[j][0] = 1 / a[j][0];
                }
                else
                {
                    auto re = a[j][0];
                    auto im = a[j][1];
                    auto d = re * re + im * im;
                    re /= d;
                    im /= d;
                    im = -im;
                    a[j][0] = re;
                    a[j][1] = im;
                }
            }
        }
        sl.popFrontExactly(nr);
        static if (uplo == Uplo.upper)
            sl.popFrontExactly!1(nr);
    }
    while (!nri && sl.length >= nr);
}

void load_simd(size_t mr, size_t P, T)(T* to, const(T[P])* from)
{
    static if (mr > 1 && !is(T == real))
    {
        import ldc.simd;
        alias V = __vector(T[mr]);
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
    foreach (j; Iota!mr)
    foreach (p; Iota!P)
        to[mr * p + j] = cast(T) from[j * P][p];
}

//pragma(inline, false)
//void pack_b(size_t PA, size_t PB, size_t PC, T, C)(Slice!(2, C*) sl, T* b)
//{
//    import mir.ndslice.iteration: transposed;
//    mixin RegisterConfig!(PC, PA, PB, T);
//    if (sl.stride!0 == 1)
//    {
//        foreach (nri, nr; nr_chain)
//        if (sl.length >= nr) do
//        {
//            b = pack_b_dense_nano!(nr, PB)(sl.length!1, sl.stride!1, sl.ptr, b);
//            sl.popFrontExactly(nr);
//        }
//        while (!nri && sl.length >= nr);
//    }
//    else
//    {
//        foreach (nri, nr; nr_chain)
//        if (sl.length >= nr) do
//        {
//            b = pack_b_strided_nano!(nr, PB)(sl.length!1, sl.stride!1, sl.stride!0, sl.ptr, b);
//            sl.popFrontExactly(nr);
//        }
//        while (!nri && sl.length >= nr);
//    }
//}

//pragma(inline, false)
//void save_transposed_nano(size_t P, size_t N, V, T)
//    (size_t length, sizediff_t stride, sizediff_t elemStride, V[N][P]* from, T[P]* to)
//{
//    enum M = N * V.sizeof / T.sizeof;
//    size_t j = M;
//    auto f = cast(T*)from;
//    do
//    {
//        auto len = length;
//        auto t = to;
//        auto ff = f;
//        do
//        {
//            foreach (p; Iota!P)
//            {
//                enum i = (P-1) * M;
//                t[p][0] = ff[i];
//            }
//            t += elemStride;
//            ff += P * M;
//        }
//        while (--len);
//        to += stride;
//        f += P;
//    }
//    while (--j);
//}

//pragma(inline, false)
//void save_transposed_nano(size_t P, size_t N, V, T)

pragma(inline, true)
void save_nano(size_t P, size_t N, size_t M, V, T)
    (ref V[N][P][M] reg, T[P]* c, sizediff_t ldc)
{
    foreach (m; Iota!M)
    {
        save_nano_impl(reg[m], c + ldc * m);
    }
}

pragma(inline, true)
void save_nano_kernel(size_t P, size_t N, size_t M, V, T)
    (ref V[N][P][M] reg, T[P]* c)
{
    foreach (m; Iota!M)
    {
        save_nano_impl(reg[m], c + m * V[N].sizeof / T.sizeof);
    }
}

pragma(inline, true);
void save_nano_impl(size_t P, size_t N, V, T)(ref V[N][P] reg, T[P]* c)
{
    import ldc.simd;
    foreach (j; Iota!(N))
    {
        static if (P == 1)
        {
            static if (isSIMDVector!V)
            {
                storeUnaligned!V(reg[0][j], cast(T*)(c + j * V.length));
            }
            else
            {
                c[j][0] = reg[0][j];
            }
        }
        else
        {
            static if (isSIMDVector!V)
            {
                auto re = reg[0][j];
                auto im = reg[1][j];
                auto r0 = _mix0!V(re, im);
                auto r1 = _mix1!V(re, im);
                storeUnaligned!V(r0, cast(T*)(c + j * V.length));
                storeUnaligned!V(r1, cast(T*)((cast(V*)(c + j * V.length)) + 1));
            }
            else
            {
                c[j][0] = reg[0][j];
                c[j][1] = reg[1][j];
            }
        }
    }
}

pragma(inline, true)
void save_add_nano(size_t P, size_t N, size_t M, V, T)
    (ref V[N][P][M] reg, T[P]* c, sizediff_t ldc)
{
    foreach (m; Iota!M)
    {
        save_add_nano_impl(reg[m], c + ldc * m);
    }
}

pragma(inline, true)
void save_add_nano_kernel(size_t P, size_t N, size_t M, V, T)
    (ref V[N][P][M] reg, T[P]* c)
{
    foreach (m; Iota!M)
    {
        save_add_nano_impl(reg[m], c + m * V[N].sizeof / T.sizeof);
    }
}

pragma(inline, true)
void save_add_nano_impl(size_t P, size_t N, V, T)(ref V[N][P] reg, T[P]* c)
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

pragma(inline, true)
void save_madd_nano(size_t P, size_t N, size_t M, V, T)(ref V[N][P][M] reg, ref const T[P] beta, T[P]* c_, sizediff_t ldc)
{
    V[P] s = void;
    s.load_nano(beta);
    foreach (m; Iota!M)
    {
        auto c = c_ + m * ldc;
        import ldc.simd;
        foreach (j; Iota!(N))
        {
            static if (P == 1)
            {
                static if (isSIMDVector!V)
                {
                    auto cj = loadUnaligned!V(cast(T*)(c + j * V.length));
                    cj = reg[m][0][j] + s[0] * cj;
                    storeUnaligned!V(cj, cast(T*)(c + j * V.length));
                }
                else
                {
                    c[j][0] = reg[m][0][j] + s[0] * c[j][0];
                }
            }
            else
            {
                static if (isSIMDVector!V)
                {
                    auto cj0 = loadUnaligned!V(cast(T*)(c + j * V.length));
                    auto cj1 = loadUnaligned!V(cast(T*)((cast(V*)(c + j * V.length)) + 1));

                    auto cre = _re!V(cj0, cj1);
                    auto cim = _im!V(cj0, cj1);

                    auto re = reg[m][0][j] + cre * s[0];
                    auto im = reg[m][1][j] + cim * s[0];

                    re -= cim * s[1];
                    im += cre * s[1];

                    auto r0 = _mix0!V(re, im);
                    auto r1 = _mix1!V(re, im);

                    storeUnaligned!V(r0, cast(T*)(c + j * V.length));
                    storeUnaligned!V(r1, cast(T*)((cast(V*)(c + j * V.length)) + 1));
                }
                else
                {
                    auto cre = c[j][0];
                    auto cim = c[j][1];

                    auto re = reg[m][0][j] + cre * s[0];
                    auto im = reg[m][1][j] + cim * s[0];

                    re -= cim * s[1];
                    im += cre * s[1];

                    c[j][0] = re;
                    c[j][1] = im;
                }
            }
        }
    }
}

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

void load_nano(size_t M, size_t PC, size_t N, V, W)(ref V[M][PC][N] to, ref W[M][PC][N] from)
{
    foreach (n; Iota!N)
    foreach (p; Iota!PC)
    foreach (m; Iota!M)
        to[n][p][m] = from[n][p][m];
}

pragma(inline, true)
void load_nano(size_t A, V, F)
(ref V[A] to, ref const F[A] from)
    if (!isStaticArray!F)
{
    foreach (p; Iota!A)
        to[p] = from[p];
}
