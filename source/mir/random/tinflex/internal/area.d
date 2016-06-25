module mir.random.tinflex.internal.area;

import mir.random.tinflex.internal.types : IntervalPoint;
import mir.random.tinflex.internal.linearfun : LinearFun;
import std.traits : ReturnType, isFloatingPoint;

protected:

/**
Tuple of hat and squeeze function.
*/
struct HatAndSqueeze(S)
    if (isFloatingPoint!S)
{
    LinearFun!S hat, squeeze;
}

/**
Determines the hat and squeeze function of an interval.
Based on Theorem 1
*/
HatAndSqueeze!S determineHatAndSqueeze(S)(in IntervalPoint!S l, in IntervalPoint!S r)
    if (isFloatingPoint!S)
{
    import mir.random.tinflex.internal.linearfun : secant, tangent;
    import mir.random.tinflex.internal.types : FunType;

    // TODO: calculate only when needed
    immutable sec = secant(l.x, r.x, l.tx, r.tx);
    immutable t_l = tangent(l.x, l.tx, l.t1x);
    immutable t_r = tangent(r.x, r.tx, r.t1x);

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
    import std.stdio;
    writeln("determining hat for ", l);
    writeln("type", l.type);

    return HatAndSqueeze!S(hat, squeeze);
}

/// convenience wrapper for unittests
version(unittest) HatAndSqueeze!S determineHatAndSqueeze(F0, F1, F2, S)(in F0 f0, in F1 f1, in F2 f2, in S bl, in S br)
    if (is(ReturnType!F0 == S) && is(ReturnType!F1 == S) && is(ReturnType!F2 == S) &&
        isFloatingPoint!S)
{
    import mir.random.tinflex.internal.types: determineType;
    // c is not required for this test
    auto c = 42;
    auto s1 = IntervalPoint!S(f0(bl), f1(bl), f2(bl), bl, 42);
    auto s2 = IntervalPoint!S(f0(bl), f1(br), f2(br), br, 42);
    s1.type = determineType(s1, s2);
    return determineHatAndSqueeze(s1, s2);
}

/// ditto

// TODO: add more tests
unittest
{
    import mir.random.tinflex.internal.linearfun : linearFun;
    const f0 = (double x) => x * x;
    const f1 = (double x) => 2 * x;
    const f2 = (double x) => 2.0;

    auto hs = determineHatAndSqueeze(f0, f1, f2, 1.0, 3);
    assert(hs.hat == linearFun(4.0, -3));
    assert(hs.squeeze == linearFun(6.0, -9));

    hs = determineHatAndSqueeze(f0, f1, f2, -1.0, 1);
    assert(hs.hat == linearFun(0.0, 1));
    assert(hs.squeeze == linearFun(2.0, -1));

    //hs = determineHatAndSqueeze(f0, f1, f2, -double.infinity, -1);
    //import std.stdio;
    //writeln(hs);
    //assert(hs.hat == linearFun(0.0, 1));
    //assert(hs.squeeze == linearFun(2.0, -1));
}

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
S area(S)(in LinearFun!S sh, in S l, in S r, in S ly, in S ry, in S c)
    if (isFloatingPoint!S)
out (result)
{
    import std.math : isNaN;
    import std.traits : isFloatingPoint;
    static if (isFloatingPoint!S)
        assert(!isNaN(result), "Computed area can't be NaN");
}
body
{
    import mir.internal.math: exp, log;
    import std.math: abs, sgn;
    import mir.random.tinflex.internal.transformations : antiderivative, inverse;

    S area;
    // check difference to left and right starting point
    const byte s = (l - sh._y) > (sh._y - r) ? 1 : -1;

    // sh.y is the boundary point where f obtains its maximum

    // specializations for T_c family (page 6)
    if (c == 0)
    {
        // T_c = log(x)
        // Error in table, see equation (4)
        immutable z = s * sh.slope * (r - l);
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
            assert("shouldn't happen");
            //return S.infinity;
        }

        immutable z = s / sh.a * sh.slope * (r - l);

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
            import std.stdio;
            if (abs(sh.slope) > 1e-10)
            {
                alias ad = antiderivative;
                writeln("if", sh);
                area = (ad(sh(r), c) - ad(sh(l), c)) / sh.slope;
                writeln("area", area);
            }
            else
            {
                writeln("else", sh);
                area = inverse(sh.a, c) * (r - l);
            }
        }
    }
    import std.math : isInfinity, isNaN;
    if (isInfinity(area) || isNaN(area))
        return 0.0;
    else
        return area;
}

unittest
{
    // example from Tinflex
    const f0 = (double x) => -x^^4 + 5 * x^^2 - 4;
    const f1 = (double x) => 10 * x - 4 * x ^^ 3;
    const f2 = (double x) => 10 - 12 * x ^^ 2;
    auto c = 1.5;
    auto rho = 1.1;

    import mir.random.tinflex.internal.types : determineType;
    import mir.random.tinflex.internal.transformations : transformToInterval;
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

        import std.stdio;

        auto aHat = area(sh.hat, s1.x, s2.x, s1.tx, s2.tx, c);
        assert(aHat.approxEqual(hats[i]));
        auto aSqueeze = area(sh.squeeze, s1.x, s2.x, s1.tx, s2.tx, c);
        assert(aSqueeze.approxEqual(sqs[i]));
        i++;
    }
}
