module mir.random.flex.internal.transformations;

import mir.random.flex.internal.types : Interval;

/**
Create a c-transformation, based on a function and it's first two derivatives

Tinflex expects the logarithm of the pdf, which means that for `c = 0`,
no transformations need to be applied.
However for `c != 0` the inverse function is needed.
We first need to apply the inverse `T_c^{-1}(x) = exp(x)` and then apply the
other `T_c` transformation:

    f(x) = exp(T_{c != 0}(x))
         = exp(sgn(c) * x^c)
         = sgn(c) * exp(x * c)

Warning:
For performance reasons the transformation is directly applied, it is thus
necessary to check before whether `c == 0` and avoid the transformation.

Params:
    f0 = PDF function
    f1 = first derivative
    f2 = second derivative

Returns: In-place code for the transformation
**/
template transform(string f0, string f1, string f2, string c)
{
    import std.array : replace;
    enum raw = `_f0 = copysign(exp(_c * _f0), _c);
                _f2 = _c * _f0 * (_c * _f1 * _f1 + _f2);
                _f1 = _c * _f0 * _f1;`;
    enum transform = raw.replace("_f0", f0).replace("_f1", f1).replace("_f2", f2).replace("_c", c);
}

/**
Transform an Interval with a c-transformation by reference.

Params:
    iv = Interval to be transformed
*/
void transformInterval(S)(ref Interval!S iv)
in
{
    import std.conv : to;
    import std.math : isNaN;
    import std.meta : AliasSeq;
    assert(!iv.c.isNaN, "c can't be NaN");
    assert(!iv.lx.isNaN, "l can't be NaN");
    assert(!iv.rx.isNaN, "r can't be NaN");
    assert(iv.lx < iv.rx, "invalid interval - right side must be larger than the left side");
}
body
{
    import mir.internal.math: pow, exp, copysign;
    with(iv)
    {
        // for c=0 no transformations are applied
        if (c)
        {
            mixin(transform!("ltx", "lt1x", "lt2x", "c"));
            mixin(transform!("rtx", "rt1x", "rt2x", "c"));
        }
    }
}

// example from Botts et al. (2013)
unittest
{
    import std.math: approxEqual;
    import std.meta : AliasSeq;
    import std.range: dropOne, lockstep, save;
    foreach (S; AliasSeq!(float, double, real))
    {
        auto f0 = (S x) => -x^^4 + 5 * x^^2 - 4;
        auto f1 = (S x) => 10 * x - 4 * x ^^ 3;
        auto f2 = (S x) => 10 - 12 * x ^^ 2;
        S l = -3, r = -1.5, c = 1.5;

        auto iv = Interval!S(l, r, c, f0(l), f1(l), f2(l), f0(r), f1(r), f2(r));
        transformInterval!S(iv);

        // magic numbers manually verified
        assert(iv.ltx.approxEqual(-8.75651e-27));
        assert(iv.lt1x.approxEqual(-1.02451e-24));
        assert(iv.lt2x.approxEqual(-1.18581e-22));
    }
}

// test for c=1
unittest
{
    import std.math: approxEqual;
    import std.meta : AliasSeq;
    import std.range: dropOne, lockstep, save;
    foreach (S; AliasSeq!(float, double, real))
    {
        auto f0 = (S x) => -x^^4 + 5 * x^^2 - 4;
        auto f1 = (S x) => 10 * x - 4 * x ^^ 3;
        auto f2 = (S x) => 10 - 12 * x ^^ 2;

        S[] points = [-3, -1.5, 0, 1.5, 3];
        S c = 1;
        S[] resT0x = [4.24835425529159e-18, 8.9129029811987373,
                      0.0183156388887342, 8.91290298119874e+00];
        S[] resT1x = [3.31371631912744e-16, -13.3693544717981059,
                      0, 1.33693544717981e+01];
        S[] resT2x = [2.54306485721755e-14, -131.4653189726813878,
                      0.1831563888873418, -1.31465318972681e+02];

        foreach (i, l, r; lockstep(points, points.save.dropOne))
        {
            auto iv = Interval!S(l, r, c, f0(l), f1(l), f2(l), f0(r), f1(r), f2(r));
            iv.transformInterval;
            assert(iv.ltx.approxEqual(resT0x[i]));
            assert(iv.lt1x.approxEqual(resT1x[i]));
            assert(iv.lt2x.approxEqual(resT2x[i]));
        }
    }
}

// test for c=-1
unittest
{
    import std.math: approxEqual;
    import std.meta : AliasSeq;
    import std.range: dropOne, lockstep, save;
    foreach (S; AliasSeq!(float, double, real))
    {
        auto f0 = (S x) => -x^^4 + 5 * x^^2 - 4;
        auto f1 = (S x) => 10 * x - 4 * x ^^ 3;
        auto f2 = (S x) => 10 - 12 * x ^^ 2;

        S[] points = [-3, -1.5, 0, 1.5, 3];
        S c = -1;
        S[] resT0x = [-2.35385266837020e+17, -0.1121968905203437,
                      -54.5981500331442362, -1.12196890520344e-01,
                      -2.35385266837020e+17];
        S[] resT1x = [1.83600508132876e+19, -0.1682953357805156, 0,
                      1.68295335780516e-01, -1.83600508132876e+19];
        S[] resT2x = [-1.45515171958646e+21, -2.1597901425166168,
                      545.9815003314423620, -2.15979014251662e+00,
                      -1.45515171958646e+21];

        foreach (i, l, r; lockstep(points, points.save.dropOne))
        {
            auto iv = Interval!S(l, r, c, f0(l), f1(l), f2(l), f0(r), f1(r), f2(r));
            iv.transformInterval;
            assert(iv.ltx.approxEqual(resT0x[i]));
            assert(iv.lt1x.approxEqual(resT1x[i]));
            assert(iv.lt2x.approxEqual(resT2x[i]));
        }
    }
}

// test for c=0
unittest
{
    import std.math: approxEqual;
    import std.meta : AliasSeq;
    import std.range: dropOne, lockstep, save;
    foreach (S; AliasSeq!(float, double, real))
    {
        auto f0 = (S x) => -x^^4 + 5 * x^^2 - 4;
        auto f1 = (S x) => 10 * x - 4 * x ^^ 3;
        auto f2 = (S x) => 10 - 12 * x ^^ 2;

        S[] points = [-3, -1.5, 0, 1.5, 3];
        S c = 0;
        S[] resT0x = [-40, 2.1875, -4,  2.1875, -40];
        S[] resT1x = [78, -1.5,  0,  1.5, -78];
        S[] resT2x = [-98, -17, 10,-17, -98];

        foreach (i, l, r; lockstep(points, points.save.dropOne))
        {
            auto iv = Interval!S(l, r, c, f0(l), f1(l), f2(l), f0(r), f1(r), f2(r));
            iv.transformInterval;
            assert(iv.ltx.approxEqual(resT0x[i]));
            assert(iv.lt1x.approxEqual(resT1x[i]));
            assert(iv.lt2x.approxEqual(resT2x[i]));
        }
    }
}

/**
Compute antiderivative FT of an inverse transformation: TF_C^-1
Table 1, column 4 of Botts et al. (2013).
*/
S antiderivative(bool common = false, S)(in S x, in S c)
{
    import mir.internal.math : exp, log, pow, copysign, fabs;
    import std.math: sgn;
    assert(sgn(c) * x >= 0);
    static if (!common)
    {
        if (c == 0)
            return exp(x);
        if (c == S(-0.5))
            return -1 / x;
        if (c == -1)
            return -log(-x);
    }
    auto d = c + 1;
    return fabs(c) / d * pow(fabs(x), d / c);
}

unittest
{
    import std.math: E, approxEqual;
    import std.meta : AliasSeq;
    foreach (S; AliasSeq!(float, double, real))
    {
        assert(antiderivative!(false, S)(1, 0.0).approxEqual(E));
        assert(antiderivative!(false, S)(1, 2.0) == S(2) / 3);
    }
}

unittest
{
    import std.math;
    import std.meta : AliasSeq;

    static immutable results = [
        [1, 1.64872, 2.71828, 4.48169, 7.38906, 12.1825],
        [0, 0.00260417, 0.166667, 1.89844, 10.6667, 40.6901],
        [0, 0.0416667, 0.333333, 1.125, 2.66667, 5.20833],
        [0, 0.125, 0.5, 1.125, 2, 3.125],
        [0, 0.188988, 0.6, 1.17933, 1.90488, 2.76302],
        [0, 0.270664, 0.714286, 1.26008, 1.88501, 2.57625],
        [0, 0.297638, 0.75, 1.2878, 1.88988, 2.54477]
    ];

    foreach (S; AliasSeq!(float, double, real))
    {
        S[] xs = [0, 0.5, 1, 1.5, 2, 2.5];
        S[] cs = [0, 0.2, 0.5, 1.0, 1.5, 2.5, 3.0];

        foreach (i, c; cs)
        {
            foreach (j, x; xs)
            {
                S r = results[i][j];
                S v = antiderivative!(false, S)(x, c);
                assert(v.approxEqual(r));
            }
        }
    }
}

unittest
{
    import std.math;
    import std.meta : AliasSeq;

    alias T = double;
    static immutable results = [
        [1, 0.606531, 0.367879, 0.22313, 0.135335, 0.082085],
        [T.infinity, 4, 0.25, 0.0493827, 0.015625, 0.0064],
        [-T.infinity, 2, 1, 0.666667, 0.5, 0.4],
        [T.infinity, 0.693147, -0, -0.405465, -0.693147, -0.916291],
        [-0, -2.3811, -3, -3.43414, -3.77976, -4.07163],
        [-0, -1.09959, -1.66667, -2.12571, -2.52619, -2.8881],
        [-0, -0.944941, -1.5, -1.96556, -2.3811, -2.76302],
    ];

    foreach (S; AliasSeq!(float, double, real))
    {
        S[] xs = [0, -0.5, -1, -1.5, -2, -2.5];
        S[] cs = [0, -0.2, -0.5, -1.0, -1.5, -2.5, -3.0];

        foreach (i, c; cs)
        {
            foreach (j, x; xs)
            {
                S r = results[i][j];
                S v = antiderivative!(false, S)(x, c);
                assert(v.approxEqual(r));
            }
        }
    }
}

/**
Compute inverse transformation of antiderivative T_c family given point x.
Table 1, column 5 of Botts et al. (2013).
*/
S inverseAntiderivative(S)(in S x, in S c)
{
    import mir.internal.math : exp, log, pow, copysign, fabs;
    import std.math: sgn;
    assert(x * sgn(c + 1) >= 0);
    if (c == 0)
        return log(x);
    if (c == S(-0.5))
        return -1 / x;
    if (c == -1)
        return -exp(-x);
    immutable d = c + 1;
    return pow(d / fabs(c) * x, c / d).copysign(c);
}

unittest
{
    import std.math: approxEqual, E, isNaN;
    import std.meta : AliasSeq;
    foreach (S; AliasSeq!(float, double, real))
    {
        assert(inverseAntiderivative!S(1, 0).approxEqual(0));
        assert(inverseAntiderivative!S(3, 0).approxEqual(1.09861));
        assert(inverseAntiderivative!S(5.5, 0).approxEqual(1.70475));

        assert(inverseAntiderivative!S(1, -0.5) == -1);
        assert(inverseAntiderivative!S(3, -0.5) == - S(1) / 3);
        assert(inverseAntiderivative!S(5.5, -0.5).approxEqual(-0.181818));

        assert(inverseAntiderivative!S(1, -1).approxEqual(-1 / E));

        assert(inverseAntiderivative!S(1, 1).approxEqual(1.41421));
        assert(inverseAntiderivative!S(3, 2).approxEqual(2.72568));
    }
}

unittest
{
    import std.math;
    import std.meta : AliasSeq;

    alias T = double;
    static immutable results = [
        [-1, -0.606531, -0.367879, -0.22313, -0.135335, -0.082085],
        [-T.infinity, -2, -1, -0.666667, -0.5, -0.4],
        [-T.infinity, -0.846098, -0.783381, -0.748872, -0.725313, -0.707551],
        [-T.infinity, -0.693147, 0, 0.405465, 0.693147, 0.916291],
        [0, 1.20094, 1.34801, 1.44225, 1.51309, 1.57042],
        [0, 1.14471, 1.44225, 1.65096, 1.81712, 1.95743],
        [0, 1, 1.41421, 1.73205, 2, 2.23607],
        [0, 0.896378, 1.35866, 1.73286, 2.05934, 2.35436],
        [0, 0.775096, 1.27168, 1.69886, 2.0864, 2.44692],
        [0, 0.737788, 1.24081, 1.68179, 2.08678, 2.46694],
    ];

    foreach (S; AliasSeq!(float, double, real))
    {
        S[] xs = [0, 0.5, 1, 1.5, 2, 2.5];
        S[] cs = [-1, -0.5, -0.1, 0, 0.2, 0.5, 1.0, 1.5, 2.5, 3.0];

        foreach (i, c; cs)
        {
            foreach (j, x; xs)
            {
                S r = results[i][j];
                S v = inverseAntiderivative!S(x, c);
                import std.conv : text;
                assert(v.approxEqual(r), text(x, " ", c, " ",  v, " ", r));
            }
        }
    }
}

unittest
{
    import std.math;
    import std.meta : AliasSeq;

    alias T = double;
    static immutable results = [
        [-1, -1.64872, -2.71828, -4.48169, -7.38906, -12.1825],
        [-0, -0.00462963, -0.037037, -0.125, -0.296296, -0.578704],
        [-0, -0.0625, -0.25, -0.5625, -1, -1.5625],
        [-0, -0.134442, -0.426827, -0.838953, -1.35509, -1.96556],
        [-0, -0.19245, -0.544331, -1, -1.5396, -2.15166],
    ];

    foreach (S; AliasSeq!(float, double, real))
    {
        S[] xs = [0, -0.5, -1, -1.5, -2, -2.5];
        S[] cs = [-1, -1.5, -2, -2.5, -3];

        foreach (i, c; cs)
        {
            foreach (j, x; xs)
            {
                S r = results[i][j];
                S v = inverseAntiderivative!S(x, c);
                import std.conv;
                assert(v.approxEqual(r), text(x, " ", c, " ",  v, " ", r));
            }
        }
    }
}
