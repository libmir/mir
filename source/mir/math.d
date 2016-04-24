/**
License: $(LINK2 http://boost.org/LICENSE_1_0.txt, Boost License 1.0).

Authors: Ilya Yaroshenko
*/
module mir.math;

import mir.internal.math;
import mir.internal.utility;

/++
Optimized and more precise analog of `y = exp(digamma(x))`.

Returns:
    `exp(digamma(x))`
+/
F expDigamma(F)(in F x)
{
    static immutable F[7] c = [
        F(1.0 / 24),
        F(1.0L / 48),
        F(23.0L / 5760),
        F(17.0L / 3840),
        F(10_099.0L / 2_903_040),
        F(2501.0L / 1_161_216),
        F(795_697.0L / 199_065_600),
    ];

    if (!(x >= 0))
        return F.nan;
    F s = x;
    F w = 0;
    while ( s < F(10) )
    {
        w += 1 / s;
        s += 1;
    }
    F y = F(-0.5);
    F t = 1;
    foreach (i; Iota!(0, c.length))
    {
        t *= s;
        y += c[i] / t;
    }
    y += s;
    y /= exp(w);
    return y;
}

unittest
{
    import std.meta;
    import std.mathspecial;
    assert(approxEqual(expDigamma(0.001), exp(digamma(0.001))));
    assert(approxEqual(expDigamma(0.1), exp(digamma(0.1))));
    assert(approxEqual(expDigamma(1.0), exp(digamma(1.0))));
    assert(approxEqual(expDigamma(2.3), exp(digamma(2.3))));
    assert(approxEqual(expDigamma(20.0), exp(digamma(20.0))));
    assert(approxEqual(expDigamma(40.0), exp(digamma(40.0))));
    foreach (F; AliasSeq!(float, double, real))
    {
        assert(expDigamma!F(0.0) == 0);
        assert(expDigamma!F(0.0.nextUp) >= 0);
        assert(expDigamma!F(0.0.min_normal) >= 0);
        assert(expDigamma!F(0.5.nextUp) >= 0);
        assert(expDigamma!F(0.5.nextDown) >= 0);
        foreach (i; 1 .. 10)
        {
            assert(expDigamma(F(i)) >= expDigamma(F(i).nextDown));
            assert(expDigamma(F(i)) <= expDigamma(F(i).nextUp));
        }
    }
}

/++
Exponent of minus Euler–Mascheroni constant.
+/
enum real expMEuler = 0x0.8fbbcf07f2e5f2c56894d7014c3086p0;

///
unittest
{
    import std.math: approxEqual;
    assert(approxEqual(expDigamma(1.0L), expMEuler));
}
