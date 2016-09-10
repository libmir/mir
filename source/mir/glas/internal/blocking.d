module mir.glas.internal.blocking;

import std.traits;
import std.meta;
import std.complex : Complex;
import mir.internal.utility;
import mir.glas.internal.config;
import mir.glas.common;

enum prefetchShift = 512;

<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD

=======
>>>>>>> origin/example
=======
>>>>>>> origin/example
=======
>>>>>>> origin/example
@fastmath:

struct BlockInfo(T)
{
    sizediff_t mc;
    sizediff_t kc;
    T* a;
    T* b;
}

<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
BlockInfo!T blocking(size_t PA, size_t PB, size_t PC, T)(GlasContext* ctx, size_t m, size_t n, size_t k)
=======
BlockInfo!T blocking(size_t PC, size_t PA, size_t PB, T)(GlasContext* ctx, size_t m, size_t k, size_t n)
>>>>>>> origin/example
=======
BlockInfo!T blocking(size_t PC, size_t PA, size_t PB, T)(GlasContext* ctx, size_t m, size_t k, size_t n)
>>>>>>> origin/example
=======
BlockInfo!T blocking(size_t PC, size_t PA, size_t PB, T)(GlasContext* ctx, size_t m, size_t k, size_t n)
>>>>>>> origin/example
{
    import mir.glas.internal.context;
    mixin RegisterConfig!(PC, PA, PB, T);
    BlockInfo!T ret = void;

    sizediff_t l2 = c2.size << 9; // half cache

<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
    ret.kc = (l2 - m * T[PC][main_nr].sizeof) / (m * T[PA].sizeof + T[PB][main_nr].sizeof);
=======
    ret.kc = (l2 - m * T[PC][nr].sizeof) / (m * T[PA].sizeof + T[PB][nr].sizeof);
>>>>>>> origin/example
=======
    ret.kc = (l2 - m * T[PC][nr].sizeof) / (m * T[PA].sizeof + T[PB][nr].sizeof);
>>>>>>> origin/example
=======
    ret.kc = (l2 - m * T[PC][nr].sizeof) / (m * T[PA].sizeof + T[PB][nr].sizeof);
>>>>>>> origin/example
    ret.mc = m;
    enum minKc = 320 / PC;

    if (ret.kc < minKc)
    {
<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
        ret.kc = ((c1.size << 10) - 2 * (T[PC][main_nr][main_mr].sizeof + main_nr * c1.line) - 512) / (T[PA][main_mr].sizeof + T[PB][main_nr].sizeof);
        assert(c1.size << 10 > main_mr);
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
    auto _mem = ctx.memory(a_length + b_length + prefetchShift);
    ret.a = cast(T*) _mem.ptr;
    ret.b = cast(T*) (_mem.ptr + a_length);

    return ret;
}

BlockInfo!T blocking_sym(size_t PA, size_t PB, size_t PC, T)(GlasContext* ctx, size_t m, size_t n)
{
    import mir.glas.internal.context;
    mixin RegisterConfig!(PB, PA, PB, T);
    BlockInfo!T ret = void;

        import std.stdio;

    sizediff_t l2 = c2.size << 9; // half cache
    ret.kc = ((c1.size << 10) - 2 * (T[PC][main_nr][main_mr].sizeof + main_nr * c1.line) - 512) / (T[PA][main_mr].sizeof + T[PB][main_nr].sizeof);
    writeln("kc l1 = ", ret.kc);

    if (l2 >= m * ((m + main_nr) * PA + PC * main_mr) * T.sizeof)
    {
        writeln("opt1");
        ret.kc = ret.mc = ret.kc > m ? m : ret.kc;
    }
    else
    {
        sizediff_t x = l2 / T.sizeof - (main_nr * PA + main_mr * PB);
        assert(x > 1);
        import mir.internal.math : sqrt;
        x = cast(size_t) sqrt(double(x));
        assert(x > 1);
        writeln("x = ",  x);
        x.normalizeChunkSize!main_nr(m);
        ret.kc = ret.mc = ret.kc > x ? x : ret.kc;
    }
    writeln("kc l2 = ", ret.kc);

    auto a_length = ret.kc * ret.kc * T[PA].sizeof;
    auto b_length = ret.kc * T[PB].sizeof * (ret.kc == m && false ? main_nr : n);
=======
=======
>>>>>>> origin/example
=======
>>>>>>> origin/example
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
    auto b_length = ret.kc * T[PB].sizeof * (ret.mc == m && false ? nr : n);
<<<<<<< HEAD
<<<<<<< HEAD
>>>>>>> origin/example
=======
>>>>>>> origin/example
=======
>>>>>>> origin/example
    auto buffLength = a_length + b_length;
    auto _mem = ctx.memory(a_length + b_length + prefetchShift);
    ret.a = cast(T*) _mem.ptr;
    ret.b = cast(T*) (_mem.ptr + a_length);

    return ret;
}

BlockInfo!T blocking_triangular(size_t PA, size_t PB, T)(GlasContext* ctx, size_t m, size_t n)
{
    import mir.glas.internal.context;
    mixin RegisterConfig!(PB, PA, PB, T);
    BlockInfo!T ret = void;

    sizediff_t l2 = c2.size << 10; // half matrix
<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
    //ret.kc = ((c1.size << 10) - 2 * (T[PB][main_nr][main_mr].sizeof + main_nr * c1.line) - 512) / (T[PA][main_nr].sizeof + T[PB][main_mr].sizeof);

        import std.stdio;
    if (l2 >= (m * ((m + main_nr) * PA + PB * main_mr * 2)) * T.sizeof)
=======
=======
>>>>>>> origin/example
=======
>>>>>>> origin/example
    //ret.kc = ((c1.size << 10) - 2 * (T[PB][nr][mr].sizeof + nr * c1.line) - 512) / (T[PA][nr].sizeof + T[PB][mr].sizeof);

        import std.stdio;
    if (l2 >= (m * ((m + nr) * PA + PB * mr * 2)) * T.sizeof)
<<<<<<< HEAD
<<<<<<< HEAD
>>>>>>> origin/example
=======
>>>>>>> origin/example
=======
>>>>>>> origin/example
    {
        //ret.kc = ret.mc = ret.kc > m ? m : ret.kc;
        ret.kc = ret.mc = m;
    }
    else
    {
<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
        sizediff_t x = l2 / T.sizeof - (main_nr * PA + PB * main_mr * 2);
=======
        sizediff_t x = l2 / T.sizeof - (nr * PA + PB * mr * 2);
>>>>>>> origin/example
=======
        sizediff_t x = l2 / T.sizeof - (nr * PA + PB * mr * 2);
>>>>>>> origin/example
=======
        sizediff_t x = l2 / T.sizeof - (nr * PA + PB * mr * 2);
>>>>>>> origin/example
        assert(x > 1);
        import mir.internal.math : sqrt;
        x = cast(size_t) sqrt(double(x));
        assert(x > 1);
<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
        x.normalizeChunkSize!main_nr(m);
=======
        x.normalizeChunkSize!nr(m);
>>>>>>> origin/example
=======
        x.normalizeChunkSize!nr(m);
>>>>>>> origin/example
=======
        x.normalizeChunkSize!nr(m);
>>>>>>> origin/example
        //ret.kc = ret.mc = ret.kc > x ? x : ret.kc;
        ret.kc = ret.mc = x;
    }

    auto a_length = ret.kc * ret.mc * T[PA].sizeof;
<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
    auto b_length = ret.kc * T[PB].sizeof * (ret.mc == m && false ? main_mr : n);
=======
    auto b_length = ret.kc * T[PB].sizeof * (ret.mc == m && false ? mr : n);
>>>>>>> origin/example
=======
    auto b_length = ret.kc * T[PB].sizeof * (ret.mc == m && false ? mr : n);
>>>>>>> origin/example
=======
    auto b_length = ret.kc * T[PB].sizeof * (ret.mc == m && false ? mr : n);
>>>>>>> origin/example
    auto buffLength = a_length + b_length;
    auto _mem = ctx.memory(a_length + b_length + prefetchShift);
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
