module mir.random.tinflex.internal.area;

import mir.random.tinflex.internal.types : Interval;
import mir.random.tinflex.internal.linearfun : LinearFun;
import std.traits : ReturnType;

/**
Determines the hat and squeeze function of an interval.
Based on Theorem 1
*/
void determineSqueezeAndHat(S)(ref Interval!S iv)
in
{
    assert(iv.lx < iv.rx, "invalid interval");
}
body
{
    import mir.random.tinflex.internal.linearfun : secant, tangent;
    import mir.random.tinflex.internal.types : determineType, FunType;

    enum sec = "secant(iv.lx, iv.rx, iv.ltx, iv.rtx)";
    enum t_l = "tangent(iv.lx, iv.ltx, iv.lt1x)";
    enum t_r = "tangent(iv.rx, iv.rtx, iv.rt1x)";

    // could potentially be saved for subsequent calls
    FunType type = determineType(iv);
    with(FunType) with(iv)
    switch(type)
    {
        case T1a:
            squeeze = mixin(t_r);
            hat = mixin(t_l);
            break;
        case T1b:
            squeeze = mixin(t_l);
            hat = mixin(t_r);
            break;
        case T2a:
            squeeze = mixin(sec);
            hat = mixin(t_l);
            break;
        case T2b:
            squeeze = mixin(sec);
            hat = mixin(t_r);
            break;
        case T3a:
            squeeze = mixin(t_r);
            hat = mixin(sec);
            break;
        case T3b:
            squeeze = mixin(t_l);
            hat = mixin(sec);
            break;
        case T4a:
            if (iv.lx == -S.infinity)
            {
                squeeze = squeeze.init;
                hat = mixin(t_r);
                break;
            }
            if (iv.rx == +S.infinity)
            {
                squeeze = squeeze.init;
                hat = mixin(t_l);
                break;
            }
            squeeze = mixin(sec);
            hat = iv.ltx > iv.rtx ? mixin(t_l) : mixin(t_r);
            break;
        case T4b:
            squeeze = iv.ltx < iv.rtx ? mixin(t_l) : mixin(t_r);
            hat = mixin(sec);
            break;
        default:
            //ret = ret.init;
    }
}

// TODO: add more tests
unittest
{
    import std.meta : AliasSeq;
    import mir.random.tinflex.internal.types: determineType;
    import mir.random.tinflex.internal.linearfun : linearFun;
    foreach (S; AliasSeq!(float, double, real))
    {
        const f0 = (S x) => x * x;
        const f1 = (S x) => 2 * x;
        const f2 = (S x) => 2.0;
        auto c = 42; // not required for this test
        auto dhs = (S l, S r) {
            auto iv = Interval!S(l, r, c, f0(l), f1(l), f2(l),
                                          f0(r), f1(r), f2(r));
            determineSqueezeAndHat(iv);
            return iv;
        };

        // test left side
        auto hs1 = dhs(-1, 1);
        assert(hs1.hat == linearFun!S(0.0, 1));
        assert(hs1.squeeze == linearFun!S(2.0, -1));

        // test right side
        auto hs2 = dhs(1, 3);
        assert(hs2.hat == linearFun!S(4.0, -3));
        assert(hs2.squeeze == linearFun!S(2, -1));
    }
}

unittest
{
    alias S = double;
    auto iv = Interval!float(-S.infinity, -1.5, 1.5, 1, 0.291415, -0.513491, 1.21443, 0.353903, 0.398052);
    import std.stdio;
    determineSqueezeAndHat(iv);
    writeln(iv);
}

alias hatArea(S) = area!(true, S);
alias squeezeArea(S) = area!(false, S);

/**
Computes the area below a function sh in-between l and r.
Based on table 1 and general equation (3) from the Tinflex paper

    (F_T(sh(r))- F_T(sh(l))) / sh.slope

Params:
    sh = linear function
    l  = start of interval
    r  = end of interval
    ly = start of interval (y-value)
    ry = end of interval (y-value)
    c  =  interval type (see paper)

Returns: Computed area below sh.
*/
S area(bool isHat, S)(in ref Interval!S iv)
in
{
    assert(iv.lx < iv.rx, "invalid interval");
}
out (result)
{
    import std.math : isNaN;
    assert(!isNaN(result), "Computed area can't be NaN");
}
body
{
    import mir.internal.math: copysign, exp, log;
    import std.math: abs, sgn;
    import mir.random.tinflex.internal.transformations : antiderivative, inverse;

    S area = void;

    static if (isHat)
        auto sh = iv.hat;
    else
        auto sh = iv.squeeze;

    // check difference to left and right starting point
    const byte leftOrRight = (iv.lx - sh._y) > (sh._y - iv.rx) ? 1 : -1; // sigma in the paper

    // sh.y is the boundary point where f obtains its maximum

    // specializations for T_c family (page 6)
    if (iv.c == 0)
    {
        // T_c = log(x)
        // Error in table, see equation (4)
        immutable z = leftOrRight * sh.slope * (iv.rx - iv.lx);
        // check whether approximation is possible, page 5
        if (abs(z) < S(1e-6))
        {
            area = exp(sh._y) * (iv.rx - iv.lx) * (1 + z / 2 + (z^^2) / 6);
        }
        else
        {
            // F_T = e^x
            area = (exp(sh(iv.rx)) - exp(sh(iv.lx))) / sh.slope;
        }
    }
    else
    {
        // for c < 0, the tangent result must result in a valid (bounded) hat function
        if (iv.c * sh(iv.rx) < 0 || iv.c * sh(iv.lx) < 0)
        {
            // returning infinity will yield a split on this interval.
            return S.infinity;
        }

        immutable intLength = iv.rx - iv.lx;
        immutable z = leftOrRight / sh.a * sh.slope * intLength;

        if (iv.c == 1)
        {
            // T_c^-1 = x^c
            area = S(0.5) * sh._y * intLength * (2 + z);
        }
        else if (iv.c == S(-0.5))
        {
            // T_c = -1/sqrt(x)
            if (abs(z) < S(0.5))
            {
                // T_c^-1 = 1/x^2
                area = 1 / (sh._y * sh._y) * (1 - z + z * z);
            }
            else
            {
                area = (-1 / sh(iv.lx)) + (1 / sh(iv.rx));
            }
        }
        else if (iv.c == -1)
        {
            // T_C = -1 / x
            if (abs(z) < S(1e-6))
            {
                // T_C^-1 = -1 / x
                area = -1 / sh._y * intLength * (1 - z / 2 + z * z / 3);
            }
            else
            {
                // F_T = -log(-x)
                area = -log(-sh(iv.rx)) + log(-sh(iv.lx));
            }
        }
        else
        {
            // T_c = -1 / x
            //area = (r - l) * c / (c + 1) * 1 / z * ((1 + z)^^((c + 1) / c) - 1);
            if (abs(sh.slope) > S(1e-10))
            {
                alias ad = antiderivative;
                area = (ad(sh(iv.rx), iv.c) - ad(sh(iv.lx), iv.c)) / sh.slope;
            }
            else
            {
                area = inverse(sh.a, iv.c) * intLength;
            }
        }
    }
    // if we receive an invalid value, we require the interval to be split
    import std.math : isFinite;
    if (!isFinite(area))
        area = S.infinity;
    else if (area < 0)
        area = S.infinity;
    return area;
}

// example from Tinflex
unittest
{
    import mir.random.tinflex.internal.transformations : transformToInterval;
    import mir.random.tinflex.internal.types : determineType;
    import std.math: approxEqual;
    import std.meta : AliasSeq;
    import std.range: dropOne, lockstep, save;

    enum rho = 1.1;

    // inflection points: -1.7620, -1.4012, 1.4012, 1.7620
    enum points = [-3.0, -1.5, 0.0, 1.5, 3];
    enum hats = [25.438585, 8.022358, 8.022358, 25.438585];
    enum sqs = [0, 0.027473, 0.027473, 0];

    foreach (S; AliasSeq!(float, double, real))
    {
        const f0 = (S x) => -x^^4 + 5 * x^^2 - 4;
        const f1 = (S x) => 10 * x - 4 * x ^^ 3;
        const f2 = (S x) => 10 - 12 * x ^^ 2;
        S c = 1.5;

        auto it = (S l, S r, S c) => transformToInterval(r, l, c, f0(l), f1(l), f2(l),
                                                                  f0(r), f1(r), f2(r));

        // calculate the area of all intervals
        foreach (i, p1, p2; points.lockstep(points.save.dropOne))
        {
            auto iv = it(p1, p2, c);
            determineSqueezeAndHat(iv);

            auto aHat = hatArea!S(iv);
            assert(aHat.approxEqual(hats[i]));

            auto aSqueeze = squeezeArea!S(iv);
            assert(aSqueeze.approxEqual(sqs[i]));
        }
    }
}
