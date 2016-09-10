module mir.glas.internal.test;

import std.traits;
import std.meta;
import std.complex;
import std.algorithm: min, max;
import mir.ndslice;
import mir.glas;
import mir.internal.utility;

version(none):

unittest
{
    auto glas = new GlasContext;
    foreach (T; AliasSeq!(uint, double, Complex!double))
    foreach (trans; [true, false])
    {
        alias D = T;
        auto m = 111, n = 123, k = 2131;
        auto a = slice!(D)(m, k);
        auto b = slice!(D)(k, n);
        auto c = slice!(D)(m, n);
        auto d = slice!(D)(m, n);

        if (trans)
            c = c.reshape(n, m).transposed;

        static if (isComplex!D)
        {
            D alpha = D(3, 7);
            D beta = D(2, 5);
        }
        else
        {
            D alpha = 3;
            D beta = 2;
        }

        fillRNG(a);
        fillRNG(b);
        fillRNG(c);

        d[] = c[];

        d[] *= beta;
        foreach (i; 0..a.length)
            foreach (j; 0..b.length!1)
                foreach (r; 0..b.length)
                    d[i, j] += alpha * a[i, r] * b[r, j];

        glas.gemm(alpha, a, b, beta, c);
        assert(c == d);
    }
}

//version(test_glas)
unittest
{
    auto glas = new GlasContext;
    foreach (T; AliasSeq!(uint, double, Complex!double))
    foreach (trans; [false, true])
    {
        alias D = T;
        auto m = 113, n = 1211;
        auto a = slice!(D)(m, m);
        auto b = slice!(D)(m, n);
        auto c = slice!(D)(m, n);
        auto d = slice!(D)(m, n);

        if (trans)
            c = c.reshape(n, m).transposed;

        static if (isComplex!D)
        {
            D alpha = D(3, 7);
            D beta = D(2, 5);
        }
        else
        {
            D alpha = 3;
            D beta = 2;
        }

        fillRNG(a);
        fillRNG(b);
        fillRNG(c);

        d[] = c[];

        d[] *= beta;
        foreach (i; 0..a.length)
            foreach (j; 0..b.length!1)
                foreach (r; 0..b.length)
                    if (i < r)
                        d[i, j] += alpha * a[r, i] * b[r, j];
                    else
                        d[i, j] += alpha * a[i, r] * b[r, j];

        glas.symm(alpha, a, b, beta, c);
        assert(c == d);
    }
}

void fillRNG(T)(Slice!(2, T*) sl)
{
    import std.random;
    foreach (ref e; sl.byElement)
    {
        static if (is(T : Complex!F, F))
        {
            e.re = cast(F) uniform(-100, 100);
            e.im = cast(F) uniform(-100, 100);
        }
        else
        {
            e = cast(T) uniform(-100, 100);
        }
    }
}
