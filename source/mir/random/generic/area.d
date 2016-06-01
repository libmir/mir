module mir.random.generic.area;

import mir.random.generic.types : IntervalPoint;
import mir.random.generic.internal : LinearFun;
import std.traits : ReturnType;

protected:

/**
Tuple of hat and squeeze function.
*/
struct HatAndSqueeze(S)
{
    LinearFun!S hat, squeeze;
}

/**
Determines the hat and squeeze function of an interval.
Based on Theorem 1
*/
HatAndSqueeze!S determineHatAndSqueeze(F0, F1, F2, S)(in F0 f0, in F1 f1, in F2 f2, in S bl, in S br)
    if (is(ReturnType!F0 == S) && is(ReturnType!F1 == S) && is(ReturnType!F2 == S))
{
    import mir.random.generic.types: intervalPoint, determineType;

    auto s1 = intervalPoint(f0, f1, f2, bl);
    auto s2 = intervalPoint(f0, f1, f2, br);
    s1.type = determineType(s1, s2);
    return determineHatAndSqueeze(s1, s2);
}

/// ditto
HatAndSqueeze!S determineHatAndSqueeze(S)(in IntervalPoint!S l, in IntervalPoint!S r)
{
    import mir.random.generic.internal : secant, tangent;
    import mir.random.generic.types : FunType;

    // TODO: calculate only when needed
    auto sec = secant(l.x, r.x, l.tx, r.tx);
    auto t_l = tangent(l.x, l.tx, l.t1x);
    auto t_r = tangent(r.x, r.tx, r.t1x);

    LinearFun!S t_m;

    // t_m is t_l or t_r wherever larger f(x) larger
    if (l.tx > r.tx)
        t_m = t_l;
    else
        t_m = t_r;

    LinearFun!S hat;
    LinearFun!S squeeze;

    with(FunType)
    final switch(l.type)
    {
        // concave near b_l and t_r(x) <= f(x) <= t_l(x)
        case T1a:
            hat = t_l;
            squeeze = t_r;
            break;

        // convex near b_l and t_l(x) <= f(x) <= t_r(x)
        case T1b:
            hat = t_r;
            squeeze = t_l;
            break;

        // concave near b_l and r(x) <= f(x) <= t_l(x)
        case T2a:
            hat = t_l;
            squeeze = sec;
            break;

        // convex near b_l and r(x) <= f(x) <= t_r(x)
        case T2b:
            hat = t_r;
            squeeze = sec;
            break;

        // concave near b_l and t_r(x) <= f(x) <= r(x)
        case T3a:
            hat = sec;
            squeeze = t_r;
            break;

        // convex near b_l and t_l(x) <= f(x) <= r(x)
        case T3b:
            hat = sec;
            squeeze = t_l;
            break;

        // concave on [b_l, b_r] and r(x) <= f(x) <= t_m(x)
        case T4a:
            hat = t_m;
            squeeze = sec;
            break;

        // convex on [b_l, b_r] and t_m(x) <= f(x) <= r(x)
        case T4b:
            hat = sec;
            squeeze = t_m;
            break;
    }
    return HatAndSqueeze!S(hat, squeeze);
}

// TODO: add more tests
unittest
{
    import mir.random.generic.internal : linearFun;
    auto f0 = (double x) => x * x;
    auto f1 = (double x) => 2 * x;
    auto f2 = (double x) => 2.0;

    auto hs = determineHatAndSqueeze(f0, f1, f2, 1.0, 3);
    assert(hs.hat == linearFun(4.0, -3));
    assert(hs.squeeze == linearFun(6.0, -9));

    hs = determineHatAndSqueeze(f0, f1, f2, -1.0, 1);
    assert(hs.hat == linearFun(0.0, 1));
    assert(hs.squeeze == linearFun(2.0, -1));
}

/**
Computes the area below a function sh inbetween l and r.
Based on table 1 and general equation (3) from the Tinflex paper

    (F_T(sh(r))- F_T(sh(l))) / sh.slope

Params:
    sh: linear function
    l: start of interval
    r: end of interval
    ly: start of interval (y-value)
    ry: end of interval (y-value)
    c:  interval type (see paper)

Returns: Computed area below sh.
*/
S area(S)(in LinearFun!S sh, in S l, in S r, in S ly, in S ry, in S c)
{
    import mir.internal.math: exp, log;
    import std.math: abs, sgn;
    import mir.random.generic.transformations : antiderivative, inverse;

    S area;
    // check difference to left and right starting point
    byte s = (l - sh._y) > (sh._y - r) ? 1 : -1;

    // sh.y is the boundary point where f obtains its maximum

    // specializations for T_c family (page 6)
    if (c == 0)
    {
        // T_c = log(x)
        // Error in table, see equation (4)
        auto z = s * sh.slope * (r - l);
        // check whether approximation is possible, page 5
        if (abs(z) < 1e-6)
        {
            area = exp(sh._y) * (r - l) * (1 + z / 2 + (z^^2) / 6);
        }
        else
        {
            // F_T = e^x
            area = (exp(sh(r)) - exp(sh(l))) / sh.slope;
        }
    }
    else
    {
        // prevent numeric errors
        if (sgn(c) * sh(r) < 0 || sgn(c) * sh(l) < 0)
        {
            return S.infinity;
        }

        auto z = s / sh.a * sh.slope * (r - l);

        if (c == 1)
        {
            // T_c^-1 = x^c
            area = 0.5  * sh._y * (r - l) * (2 + z);
        }
        else if (c == -0.5)
        {
            // T_c = -1/sqrt(x)
            if (abs(z) < 0.5)
            {
                // T_c^-1 = 1/x^2
                area = 1 / (sh._y ^^ sh._y) * (1 - z + z ^^ 2);
            }
            else
            {
                area = (-1 / sh(l)) + (1 / sh(r));
            }
        }
        else if (c == -1)
        {
            // T_C = -1 / x
            if (abs(z) < 1e-6)
            {
                // T_C^-1 = -1 / x
                area = -1 / sh._y * (r - l) * (1 - z / 2 + z^^2 / 3);
            }
            else
            {
                // F_T = -log(-x)
                area = -log(-sh(r)) + log(-sh(l));
            }
        }
        else
        {
            // T_c = -1 / x
            //area = (r - l) * c / (c + 1) * 1 / z * ((1 + z)^^((c + 1) / c) - 1);
            if (abs(sh.slope) > 1e-10)
            {
                alias ad = antiderivative;
                area = (ad(sh(r), c) - ad(sh(l), c)) / sh.slope;
            }
            else
            {
                area = inverse(sh.a, c) * (r - l);
            }
        }
    }
    return area;
}

unittest
{
    // example from Tinflex
    auto f0 = (double x) => -x^^4 + 5 * x^^2 - 4;
    auto f1 = (double x) => 10 * x - 4 * x ^^ 3;
    auto f2 = (double x) => 10 - 12 * x ^^ 2;
    auto c = 1.5;
    auto rho = 1.1;

    import mir.random.generic.types : determineType;
    import mir.random.generic.transformations : transformToInterval;
    auto intervalTransform = transformToInterval(f0, f1, f2, c);

    auto hats = [25.438585, 8.022358, 8.022358, 25.438585];
    auto sqs = [0, 0.027473, 0.027473, 0];

    // inflection points: -1.7620, -1.4012, 1.4012, 1.7620
    auto points = [-3.0, -1.5, 0.0, 1.5, 3];
    import std.range: dropOne, save, zip;
    import std.math: approxEqual;
    auto i = 0;
    foreach (p1, p2; points.zip(points.save.dropOne))
    {
        auto s1 = intervalTransform(p1);
        auto s2 = intervalTransform(p2);
        s1.type = determineType(s1, s2);
        auto sh = determineHatAndSqueeze(s1, s2);

        auto aHat = area(sh.hat, s1.x, s2.x, s1.tx, s2.tx, c);
        assert(aHat.approxEqual(hats[i]));
        auto aSqueeze = area(sh.squeeze, s1.x, s2.x, s1.tx, s2.tx, c);
        assert(aSqueeze.approxEqual(sqs[i]));
        i++;
    }
}
