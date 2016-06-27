module mir.random.tinflex.internal.calc;

import mir.random.tinflex.internal.types : GenerationPoint,  IntervalPoint;
import std.container.dlist : DList;

/**
Splits an interval into two points.

Params:
    l = Left starting point of the interval
    r = Right ending point of the interval
Returns:
    Splitting point within the interval
*/
auto arcmean(S, bool sorted = false)(const S x, const S y)
{
    import std.math: atan, tan;

    S l = x;
    S r = y;
    static if(!sorted)
    {
        if(r < l)
        {
            S t = r;
            r = l;
            l = t;
        }
    }

    if (r < -S(1e3) || l > S(1e3))
        return  S(0.5) * (1 / l + 1 / r);

    immutable d = atan(l);
    immutable b = atan(r);

    if (b - d < S(1e-6))
        return S(0.5) * l + S(0.5) * r;

    return tan(S(0.5) * (d + b));
}


/**
Calculate the parameters for an interval.
Given an interval, determine it's type and hat and squeeze function.
Given these functions, compute the area and overwrite the references data type

Params:
    ipl = Left interval point
    ipr = Right interval point
    c   = Custom T_c family
*/
void calcInterval(S)(ref IntervalPoint!S ipl, ref IntervalPoint!S ipr)
in
{
    assert(ipl.x <= ipr.x, "invalid interval");
}
body
{
    import mir.random.tinflex.internal.types : determineType;
    import mir.random.tinflex.internal.area: area, determineSqueezeAndHat;
    import std.math: isInfinity;

    if (ipl.x == ipr.x)
    {
        ipl.hatArea = 0;
        ipl.squeezeArea = 0;
    }
    else
    {

        // calculate hat and squeeze functions
        auto sh = determineSqueezeAndHat(ipl, ipr);
        ipl.hat = sh.hat;
        ipl.squeeze = sh.squeeze;

        // update area of the left interval in-place
        ipl.hatArea = area(sh.hat, ipl.x, ipr.x, ipl.tx, ipr.tx, ipl.c);
        ipl.squeezeArea = area(sh.squeeze, ipl.x, ipr.x, ipl.tx, ipr.tx, ipl.c);

        // squeeze may return infinity
        if (isInfinity(ipl.squeezeArea))
            ipl.squeezeArea = 0;
    }
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
    cs = T_c family (single value or array)
    points = non-overlapping partitioning with at most one inflection point per interval
    rho = efficiency of the Tinflex algorithm
    maxIterations = maximal number of iterations before Tinflex is aborted

Returns: Array of IntervalPoints
*/
GenerationPoint!S[] calcPoints(F0, F1, F2, S, CRange)
                            (in F0 f0, in F1 f1, in F2 f2,
                             CRange cs, in S[] points, in S rho = 1.1, in int maxIterations = 10_000)
in
{
    import std.algorithm.searching : all;
    import std.math : isFinite, isInfinity;
    import std.range: drop, empty, front, save;

    // check points
    assert(points.length >= 2, "two or more splitting points are required");
    assert(points[1..$-1].all!isFinite, "intermediate interval can't be indefinite");

    assert(!cs.empty, "c point range can't be empty");

    // check first c
    if (points[0].isInfinity)
        assert(cs.front > - 1,"c must be > -1 for unbounded domains");

    // check last c
    if (points[$ - 1].isInfinity)
    {
        auto lastC = cs.save.drop(points.length - 1).front;
        assert(lastC > - 1,"c must be > -1 for unbounded domains");
    }
}
body
{
    import mir.random.tinflex.internal.transformations : transformToInterval;
    import mir.sum: Summator, Summation;
    import std.range.primitives : front, empty, popFront;

    alias Sum = Summator!(S, Summation.precise);

    Sum totalHatAreaSummator = 0;
    Sum totalSqueezeAreaSummator = 0;

    auto nrIntervals = points.length;

    auto ips = DList!(IntervalPoint!S)(transformToInterval(points[0], cs.front,
                                      f0(points[0]), f1(points[1]), f2(points[2])));
    cs.popFront();

    // initialize with user given splitting points
    foreach (i, p; points[1..$])
    {
        assert(!cs.empty, "number of c values doesn't match points");
        auto iv = transformToInterval(p, cs.front, f0(p), f1(p), f2(p));

        calcInterval(ips.back, iv);
        totalHatAreaSummator += ips.back.hatArea;
        totalSqueezeAreaSummator += ips.back.squeezeArea;
        ips.insertBack(iv);
        cs.popFront;
    }

    // Tinflex is not guaranteed to converge
    foreach (i; 0..maxIterations)
    {
        immutable totalHatArea = totalHatAreaSummator.sum;
        immutable totalSqueezeArea = totalSqueezeAreaSummator.sum;

        // Tinflex aims for a user defined efficiency
        if (totalHatArea / totalSqueezeArea <= rho)
            break;

        immutable avgArea = (totalHatArea - totalSqueezeArea) / (nrIntervals - 1);
        for(auto it = ips[]; !it.empty;)
        {
            immutable curArea = it.front.hatArea - it.front.squeezeArea;
            if (curArea > avgArea)
            {
                auto left = it.save;
                it.popFront;
                auto right = it;

                // split the interval at the arcmean into two parts
                auto mid = arcmean!(S, true)(left.front.x, right.front.x);
                IntervalPoint!S midIP = transformToInterval(mid, left.front.c,
                                                    f0(mid), f1(mid), f2(mid));

                // prepare total areas for update
                totalHatAreaSummator -= left.front.hatArea;
                totalSqueezeAreaSummator -= left.front.squeezeArea;

                // recalculate intervals
                calcInterval(left.front, midIP);
                calcInterval(midIP, right.front);

                // update total areas
                totalHatAreaSummator += left.front.hatArea;
                totalHatAreaSummator += midIP.hatArea;
                totalSqueezeAreaSummator += left.front.squeezeArea;
                totalSqueezeAreaSummator += midIP.squeezeArea;

                // insert new middle part into linked list
                ips.insertBefore(it, midIP);

                nrIntervals++;
            }
            else
            {
                it.popFront;
            }
        }
    }

    // for sampling only a subset of the attributes is needed
    auto gps = new GenerationPoint!S[nrIntervals];
    size_t i = 0;
    foreach (ref ip; ips)
        gps[i++] = GenerationPoint!S(ip.x, ip.c, ip.hat, ip.squeeze, ip.hatArea, ip.squeezeArea);

    return gps;
}

unittest
{
    import mir.random.tinflex.internal.calc: calcPoints;
    import std.meta : AliasSeq;
    import std.range : repeat;
    foreach (S; AliasSeq!(float, double, real))
    {
        auto f0 = (S x) => -x^^4 + 5 * x^^2 - 4;
        auto f1 = (S x) => 10 * x - 4 * x ^^ 3;
        auto f2 = (S x) => 10 - 12 * x ^^ 2;
        S c = 1.5;
        S[] points = [-3, -1.5, 0, 1.5, 3];
        auto ips = calcPoints(f0, f1, f2, c.repeat, points, S(1.1));

        import std.stdio;
        writeln("IP points generated", ips.length);
        //assert(ips.length == 45);
    }
}

unittest
{
    import mir.random.tinflex.internal.calc: calcPoints;
    import std.meta : AliasSeq;
    foreach (S; AliasSeq!(float, double, real))
    {
        auto f0 = (S x) => -x^^4 + 5 * x^^2 - 4;
        auto f1 = (S x) => 10 * x - 4 * x ^^ 3;
        auto f2 = (S x) => 10 - 12 * x ^^ 2;
        S[] cs = [1.3, 1.4, 1.5, 1.6, 1.7];
        S[] points = [-3, -1.5, 0, 1.5, 3];
        auto ips = calcPoints(f0, f1, f2, cs, points, S(1.1));

        //assert(ips.length == 45);
    }
}

// test standard normal distribution
unittest
{
    import mir.random.tinflex.internal.calc: calcPoints;
    import mir.internal.math : exp, sqrt;
    import std.meta : AliasSeq;
    import std.range : repeat;
    import std.math : PI;
    foreach (S; AliasSeq!(float, double, real))
    {
        S sqrt2PI = sqrt(2 * PI);
        auto f0 = (S x) => 1 / (exp(x * x / 2) * sqrt2PI);
        auto f1 = (S x) => -(x/(exp(x * x/2) * sqrt2PI));
        auto f2 = (S x) => (-1 + x * x) / (exp(x * x/2) * sqrt2PI);
        S c = 1.5;
        S[] points = [-3, -1.5, 0, 1.5, 3];
        auto ips = calcPoints(f0, f1, f2, c.repeat, points, S(1.1));

        import std.stdio;
        writeln("IP points generated", ips.length);
    }
}

// test standard normal distribution
unittest
{
    import mir.random.tinflex.internal.calc: calcPoints;
    import mir.internal.math : exp, sqrt;
    import std.meta : AliasSeq;
    import std.range : repeat;
    import std.math : PI;
    foreach (S; AliasSeq!(float, double, real))
    {
        S sqrt2PI = sqrt(2 * PI);
        auto f0 = (S x) => 1 / (exp(x * x / 2) * sqrt2PI);
        auto f1 = (S x) => -(x/(exp(x * x/2) * sqrt2PI));
        auto f2 = (S x) => (-1 + x * x) / (exp(x * x/2) * sqrt2PI);
        S c = 1.5;
        S[] points = [-S.infinity, -1.5, 0, 1.5, S.infinity];
        auto ips = calcPoints(f0, f1, f2, c.repeat, points, S(1.1));

        import std.stdio;
        writeln("IP points generated", ips.length);
    }
}
