module mir.random.flex.internal.transformations;

import mir.random.flex.internal.types : Interval;

/**
Create a c-transformation, based on a function and it's first two derivatives

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
    foreach (S; AliasSeq!(float, double, real))
    {
        S[][] results = [
            [S.nan, S.nan, S.nan, S.nan, S.nan, S.nan, S(0),
             0.235702260395516, S(2)/S(3), 1.224744871391589,
             1.885618083164127, 2.635231383473649, 3.464101615137754],
            [S.nan, S.nan, S.nan, S.nan, S.nan, S.nan, S(0),
             0.188988157484231, 0.6, 1.179333627394003,
             1.904881262361839, 2.763023623980290, 3.744150881493428],
            [4.500, 3.125, 2, 1.125, 0.500, 0.125, S(0),
             0.125, 0.500, 1.125, 2, 3.125, 4.500],
            [S.nan, S.nan, S.nan, S.nan, S.nan, S.nan, S(0),
             0.109643058034021, 0.473684210526316, 1.114903097501321,
             2.046428978953843, 3.277815332239869, 4.81664779351],
            [S(-9), -5.2083333333333330, -2.6666666666666665, -1.125,
             -S(1)/S(3), -0.0416666666666667, S(0), 0.0416666666666667,
              S(1)/S(3), 1.125, 2.6666666666666665, 5.2083333333333330, S(9)],
            [0.0497870683678639, 0.0820849986238988, 0.1353352832366127,
             0.2231301601484298, 0.3678794411714423, 0.6065306597126334,
             S(1), 1.6487212707001282, 2.7182818284590451, 4.4816890703380645,
             7.3890560989306504, 12.1824939607034732, 20.0855369231876679],
            [S(1)/S(3), 0.4, 0.5, S(2)/S(3), 1, 2, -S.infinity,
             -2, -1, -S(2)/S(3), -0.5, -0.4, -S(1)/S(3)],
            [7.96579336864314, 8.12880963123014, 8.33287241058562,
             8.60353270580678, 9, 9.72053765003076, S.infinity,
             S.nan, S.nan, S.nan, S.nan, S.nan, S.nan],
            [-1.098612288668110, -0.916290731874155, -0.693147180559945,
             -0.405465108108164, S(0), 0.693147180559945, S.infinity,
             S.nan, S.nan, S.nan, S.nan, S.nan, S.nan],
            [-4.32674871092222, -4.07162642489236, -3.77976314968462,
             -3.43414272766, -3, -2.38110157795230, S(0),
             S.nan, S.nan, S.nan, S.nan, S.nan, S.nan],
            [-3.46410161513775, -3.16227766016838, -2.82842712474619,
             -2.44948974278318, -2, -1.41421356237310, S(0),
              S.nan, S.nan, S.nan, S.nan, S.nan, S.nan],
        ];
        S[] xs = [-3, -2.5, -2, -1.5, -1, -0.5, 0, 0.5, 1, 1.5, 2, 2.5, 3.0];
        S[] cs = [2, 1.5, 1, 0.9, 0.5, 0, -0.5, -0.9, -1, -1.5, -2];

        foreach (i, c; cs)
        {
            foreach (j, x; xs)
            {
                if (sgn(c) * x >= 0)
                {
                    S r = results[i][j];
                    S v = antiderivative!(false, S)(x, c);
                    if (r.isInfinity)
                        assert(v.isInfinity);
                    else
                        assert(v.approxEqual(r));
                }
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
    import std.range : retro;
    foreach (S; AliasSeq!(float, double, real))
    {
        S[][] results = [
            [S.nan, S.nan, S.nan, S.nan, S.nan, S.nan, 0,
             0.825481812223657, 1.310370697104448, 1.717071363829998,
             2.080083823051904, 2.413723461514074, 2.725680889248209],
            [S.nan, S.nan, S.nan, S.nan, S.nan, S.nan, 0,
             0.896378130777142, 1.358655182676538, 1.732862107887866,
             2.059336168558040, 2.354362083745639, 2.626527804403767],
            [S.nan, S.nan, S.nan, S.nan, S.nan, S.nan, 0,
             1, 1.41421356237310, 1.73205080756888,
             2, 2.23606797749979, 2.44948974278318],
            [S.nan, S.nan, S.nan, S.nan, S.nan, S.nan, 0,
             1.02594156303755, 1.42467492376796, 1.72634435580208,
             1.97837646074482, 2.19894151703704, 2.39729006223092],
            [S.nan, S.nan, S.nan, S.nan, S.nan, S.nan, 0,
             1.14471424255333, 1.44224957030741, 1.65096362444731,
             1.81712059283214, 1.95743382058443, 2.08008382305190],
            [S.nan, S.nan, S.nan, S.nan, S.nan, S.nan, -S.infinity,
             -0.693147180559945, 0, 0.405465108108164, 0.693147180559945,
             0.916290731874155, 1.098612288668110],
            [S(1)/S(3), 0.4, 0.5, S(2)/S(3), 1, 2, -S.infinity,
             -2, -1, -S(2)/S(3), -0.5, -0.4, -S(1)/S(3)],
            [S.nan, S.nan, S.nan, S.nan, S.nan, S.nan, -S.infinity,
             -1.98359290368002e+11, -3.874204893e+08, -1.00776961e+07,
             -7.56680642578129e+05, -1.01559956668417e+05, -1.96831e+04],
            [-20.0855369231876679, -12.1824939607034732, -7.3890560989306504,
             -4.4816890703380645, -2.7182818284590451, -1.6487212707001282,
             S(-1), -0.6065306597126334, -0.3678794411714423, -0.2231301601484298,
             -0.1353352832366127, -0.0820849986238988, -0.0497870683678639],
            [-1, -0.57870370370370350, -0.29629629629629622, -0.125,
             -0.03703703703703703, -0.00462962962962963, S(0),
             0.00462962962962963, 0.03703703703703703, 0.125,
             0.29629629629629622, 0.57870370370370350, 1],
            [-2.2500, -1.5625, -1, -0.5625, -0.2500, -0.0625, S(0),
             -0.0625, -0.2500, -0.5625, -1, -1.5625, -2.2500],
        ];
        S[] xs = [-3, -2.5, -2, -1.5, -1, -0.5, 0, 0.5, 1, 1.5, 2, 2.5, 3.0];
        S[] cs = [2, 1.5, 1, 0.9, 0.5, 0, -0.5, -0.9, -1, -1.5, -2];

        foreach (i, c; cs)
        {
            foreach (j, x; xs)
            {
                if (x * sgn(c + 1) >= 0)
                {
                    S r = results[i][j];
                    S v = inverseAntiderivative!S(x, c);
                    import std.conv;
                    assert(v.approxEqual(r), text(x, " ", c, " ",  v, " ", r));
                }
            }
        }
    }
}
