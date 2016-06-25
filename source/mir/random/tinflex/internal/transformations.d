module mir.random.tinflex.internal.transformations;

import std.traits: ReturnType;

/**
Create a c-transformation, based on a function and it's first two derivatives
*/
auto transformToInterval(F0, F1, F2, S)(in F0 f0, in F1 f1, in F2 f2, in S c)
    if (is(ReturnType!F0 == S) && is(ReturnType!F1 == S) && is(ReturnType!F2 == S))
{
    import std.math: sgn;
    import mir.internal.math: pow, exp;
    import mir.random.tinflex.internal.types : intervalPoint, IntervalPoint;

    // TODO: use caching
    struct IP
    {
        IntervalPoint!S opCall(S x)
        {
            return intervalPoint(t0(x), t1(x), t2(x), x, c);
        }
        auto t0 (S)(S x) const
        {
            if (c == 0)
                return f0(x);
            else
                return sgn(c) * exp(c * f0(x));
        }
        auto t1 (S)(S x) const
        {
            if (c == 0)
                return f1(x);
            else
                return c * t0(x) * f1(x);
        }
        auto t2 (S)(S x) const
        {
            if (c == 0)
                return f2(x);
            else
                return c * t0(x) * (c * pow(f1(x), 2) + f2(x));
        }
    }
    IP ip;
    return ip;
}

// TODO: test for c=0
unittest
{
    // example from Tinflex
    auto f0 = (double x) => -x^^4 + 5 * x^^2 - 4;
    auto f1 = (double x) => 10 * x - 4 * x ^^ 3;
    auto f2 = (double x) => 10 - 12 * x ^^ 2;
    auto c = 1.5;

    auto t = transformToInterval(f0, f1, f2, c);

    import std.math: approxEqual;
    // magic numbers manually verified
    assert(t.t0(-3).approxEqual(-8.75651e-27));
    assert(t.t1(-3).approxEqual(-1.02451e-24));
    assert(t.t2(-3).approxEqual(-1.18581e-22));
}

/**
Compute antiderivative FT of an inverse transformation: TF_C^-1
Table 1, column 5
*/
S antiderivative(S)(in S x, in S c)
{
    import std.math : sgn;
    import mir.internal.math : exp, log;
    if (c == 0)
        return exp(x);
    else if (c == -0.5)
        return -1 / x;
    else if (c == -1)
        return -log(-x);
    return sgn(c) * c / (c + 1) * (sgn(c) * x)^^ ((c + 1) / c);
}

unittest
{
    import std.math: E, approxEqual;

    assert(antiderivative(1, 0.0).approxEqual(E));
    assert(antiderivative(1, -0.5) == -1);
    assert(antiderivative(1, -0.5) == -1);
    assert(antiderivative(-1, -1.0) == 0);

    assert(antiderivative(1, 2.0) == 2.0 / 3);
}

/**
Compute inverse transformation of a T_c family given point x.
From: Table 1, column 3
*/
S inverse(S)(in S x, in S c)
{
    import mir.internal.math : exp, pow;
    import std.math : fabs;
    if (c == 0)
        return exp(x);
    else if (c == -0.5)
        return pow(1 / x, x);
    else if (c == 1)
        return x;
    return pow(x, 1 / fabs(c));
}

unittest
{
    import std.math: E, approxEqual;

    assert(inverse(1.0, 0).approxEqual(E));

    assert(inverse(2, -0.5) == 0.25);
    assert(inverse(8, -0.5).approxEqual(5.960464477539e-8));

    assert(inverse(2.0, 1) == 2);
    assert(inverse(8.0, 1) == 8);

    assert(inverse(1, 1.5) == 1);
    assert(inverse(2, 1.5).approxEqual(1.58740));
}


/**
Compute inverse transformation of antiderivative T_c family given point x.
Table 1, column 5
*/
S inverseAntiderivative(S)(in S x, in S c)
{
    import mir.internal.math : exp, log;
    import std.math : sgn;
    if (c == 0)
        return log(x);
    else if (c == -0.5)
        return -1 / x;
    else if (c == -1)
        return exp(x);
    return sgn(c) * (sgn(c) * (c + 1) / c * x) ^^ (c / (c + 1));
}
