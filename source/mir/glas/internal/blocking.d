module mir.glas.internal.blocking;

import core.sync.mutex;
import std.meta;
import std.traits;
import mir.glas.common;
import mir.glas.internal.config;
import mir.glas.internal.context;
import mir.internal.utility;
static import cpuid.unified;

import ldc.attributes : fastmath;
@fastmath:

enum prefetchShift = 512;

struct BlockInfo(T)
{
    sizediff_t mc;
    sizediff_t kc;
    T* a;
    T* b;
}

BlockInfo!T blocking(size_t PA, size_t PB, size_t PC, T)(size_t m, size_t n, size_t k)
{
    import mir.glas.internal.context;
    mixin RegisterConfig!(PC, PA, PB, T);
    BlockInfo!T ret = void;
    sizediff_t l2 = c2 >> 1; // half cache
    ret.kc = (l2 - m * T[PC][main_nr].sizeof) / (m * T[PA].sizeof + T[PB][main_nr].sizeof);
    ret.mc = m;
    enum minKc = 320 / PC;
    auto a = 2 * (T[PC][main_nr][main_mr].sizeof + main_nr * line) + 512;
    if (ret.kc < minKc || ret.kc * (T[PA][main_mr].sizeof + T[PB][main_nr].sizeof) + a  > c1)
    {
        ret.kc = (c1 - a) / (T[PA][main_mr].sizeof + T[PB][main_nr].sizeof);
        assert(c1 > main_mr);
        assert(ret.kc > main_mr);
        ret.kc.normalizeChunkSize!main_mr(k);
        assert(ret.kc > 0);
        auto df = T[PC][main_nr].sizeof + T[PA].sizeof * ret.kc;
        ret.mc = (l2 - ret.kc * T[PB][main_nr].sizeof) / df;
        ret.mc.normalizeChunkSize!main_nr(m);
    }
    else
    {
        ret.kc.normalizeChunkSize!main_mr(k);
    }
    auto a_length = ret.kc * ret.mc * T[PA].sizeof;
    auto b_length = ret.kc * T[PB].sizeof * (ret.mc == m && false ? main_nr : n);
    auto buffLength = a_length + b_length;
    auto _mem = memory(a_length + b_length + prefetchShift);
    ret.a = cast(T*) _mem.ptr;
    ret.b = cast(T*) (_mem.ptr + a_length);
    return ret;
}

BlockInfo!T blocking_triangular(size_t PA, size_t PB, T)(size_t m, size_t n)
{
    import mir.glas.internal.context;
    mixin RegisterConfig!(PB, PA, PB, T);
    BlockInfo!T ret = void;

    sizediff_t l2 = c2; // half matrix
    //ret.kc = (c1 - 2 * (T[PB][main_nr][main_mr].sizeof + main_nr * line) - 512) / (T[PA][main_nr].sizeof + T[PB][main_mr].sizeof);

        import std.stdio;
    if (l2 >= (m * ((m + main_nr) * PA + PB * main_mr * 2)) * T.sizeof)
    {
        //ret.kc = ret.mc = ret.kc > m ? m : ret.kc;
        ret.kc = ret.mc = m;
    }
    else
    {
        sizediff_t x = l2 / T.sizeof - (main_nr * PA + PB * main_mr * 2);
        assert(x > 1);
        import mir.internal.math : sqrt;
        x = cast(size_t) sqrt(double(x));
        assert(x > 1);
        x.normalizeChunkSize!main_nr(m);
        ret.kc = ret.mc = x;
    }

    auto a_length = ret.kc * ret.mc * T[PA].sizeof;
    auto b_length = ret.kc * T[PB].sizeof * (ret.mc == m && false ? main_mr : n);
    auto buffLength = a_length + b_length;
    auto _mem = memory(a_length + b_length + prefetchShift);
    ret.b = cast(T*) _mem.ptr;
    ret.a = cast(T*) (_mem.ptr + b_length);

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
