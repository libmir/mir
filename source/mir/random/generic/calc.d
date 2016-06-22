module mir.random.generic.calc;

import std.traits: ReturnType;
import mir.random.generic.types : IntervalPoint;

/**
Splits an interval into two points.

Params:
    l: Left starting point of the interval
    r: Right ending point of the interval
Returns:
    Splitting point within the interval
*/
private auto arcmean(S)(S l, S r)
{
    import std.math: atan, tan;
    import std.algorithm: swap;
    if (l > r)
        swap(l, r);
    return tan(0.5 * (atan(l) + atan(r)));
}

/**
Calculate the parameters for an interval.
Given an interval, determine it's type and hat and squeeze function.
Given these functions, compute the area and overwrite the references data type

Params:
    ipl: Left interval point
    ipr: Right interval point
    c: Custom T_c family
Returns
*/
private void calcInterval(S)(ref IntervalPoint!S ipl, ref IntervalPoint!S ipr, S c)
{
    import mir.random.generic.types : determineType;
    import mir.random.generic.area: area, determineHatAndSqueeze;

    ipl.type = determineType(ipl, ipr);
    auto sh = determineHatAndSqueeze(ipl, ipr);
    ipl.hat = sh.hat;
    ipl.squeeze = sh.squeeze;

    // save area with the left interval
    ipl.hatA = area(sh.hat, ipl.x, ipr.x, ipl.tx, ipr.tx, c);
    ipl.squeezeA = area(sh.squeeze, ipl.x, ipr.x, ipl.tx, ipr.tx, c);

    import std.math: isInfinity;
    if (isInfinity(ipl.squeezeA))
        ipl.squeezeA = 0;
}

/**
Calculate the intervals for the Tinflex algorithm for a T_c family given its
density function, the first two derivatives and a valid start partitioning.
The Tinflex algorithm will try to split the intervals until a chosen efficiency
rho is reached.

Params:
    f0 = probability density function of the distribution
    f1 = first derivative of f0
    f1 = second derivative of f0
    c = T_c family
    points = non-overlapping partitioning with at most one inflection point per interval
    rho = efficiency of the Tinflex algorithm
    maxIterations = maximal number of iterations before Tinflex is aborted

Returns: Array of IntervalPoints
*/
protected IntervalPoint!S[] calcPoints(F0, F1, F2, S)
                            (in F0 f0, in F1 f1, in F2 f2,
                             S c, S[] points, S rho = 1.1, int maxIterations = 10_000)
    if (is(ReturnType!F0 == S) && is(ReturnType!F1 == S) && is(ReturnType!F2 == S))
{
    import mir.random.generic.transformations : transformToInterval;

    auto intervalTransform = transformToInterval(f0, f1, f2, c);

    IntervalPoint!S[] ips = new IntervalPoint!S[points.length];
    foreach (i, p; points)
    {
        ips[i] = intervalTransform(p);
    }

    foreach (i; 0..points.length - 1)
    {
        calcInterval(ips[i], ips[i + 1], c);
        ips[i].right = i + 1;
    }

    import std.algorithm: map, sum;

    S a_h;
    S a_s;
    void updateA()
    {
        a_h = 0;
        a_s = 0;
        foreach (ref ip; ips)
        {
            if (ip.right != 0)
            {
                a_h += ip.hatA;
                a_s += ip.squeezeA;
            }
        }
    }

    updateA();

    // Tinflex is not guaranteed to converge
    for (auto i = 0; i < maxIterations; i++)
    {
        if (a_h / a_s <= rho)
            break;

        S a_avg = (a_h - a_s) / (ips.length - 1);
        // first iteration: search only (we update the list online later)
        size_t[] splits;
        foreach (j; 0..ips.length - 1)
        {
            if (ips[j].hatA - ips[j].squeezeA > a_avg)
            {
                splits ~= j;
            }
        }
        foreach (split; splits)
        {
            auto p = arcmean(ips[split].x, ips[ips[split].right].x);
            IntervalPoint!S ip = intervalTransform(p);
            calcInterval(ip, ips[ips[split].right], c);
            calcInterval(ips[split], ip, c);
            ip.right = ips[split].right;
            ips[split].right = ips.length;
            ips ~= ip;
        }
        updateA();
    }
    import std.algorithm: sort;
    ips.sort!`a.x < b.x`();
    return ips;
}

unittest
{
    auto f0 = (double x) => -x^^4 + 5 * x^^2 - 4;
    auto f1 = (double x) => 10 * x - 4 * x ^^ 3;
    auto f2 = (double x) => 10 - 12 * x ^^ 2;
    auto c = 1.5;

    import mir.random.generic.calc: calcPoints;
    auto ips = calcPoints(f0, f1, f2, c, [-3.0, -1.5, 0.0, 1.5, 3], 1.1);

    // TODO: should be 45?
    assert(ips.length == 51);
}
