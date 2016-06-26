module mir.random.tinflex.internal.calc;

import std.traits: ReturnType;
import mir.random.tinflex.internal.types : GenerationPoint,  IntervalPoint;

/**
Splits an interval into two points.

Params:
    l = Left starting point of the interval
    r = Right ending point of the interval
Returns:
    Splitting point within the interval
*/
private auto arcmean(S)(S l, S r)
{
    import std.math: atan, tan;
    return tan(S(0.5) * (atan(l) + atan(r)));
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
private void calcInterval(S)(ref IntervalPoint!S ipl, ref IntervalPoint!S ipr, in S c)
{
    import mir.random.tinflex.internal.types : determineType;
    import mir.random.tinflex.internal.area: area, determineHatAndSqueeze;

    auto sh = determineHatAndSqueeze(ipl, ipr);
    ipl.hat = sh.hat;
    ipl.squeeze = sh.squeeze;

    // save area with the left interval
    ipl.hatArea = area(sh.hat, ipl.x, ipr.x, ipl.tx, ipr.tx, c);
    ipl.squeezeArea = area(sh.squeeze, ipl.x, ipr.x, ipl.tx, ipr.tx, c);

    import std.math: isInfinity;
    if (isInfinity(ipl.squeezeArea))
        ipl.squeezeArea = 0;
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
protected GenerationPoint!S[] calcPoints(F0, F1, F2, S)
                            (in F0 f0, in F1 f1, in F2 f2,
                             in S c, in S[] points, in S rho = 1.1, int maxIterations = 10_000)
{
    import std.container.dlist : DList;
    import mir.random.tinflex.internal.transformations : transformToInterval;
    import std.range : dropOne;

    S totalHatArea = 0;
    S totalSqueezeArea = 0;
    auto nrIntervals = points.length;

    auto intervalTransform = transformToInterval(f0, f1, f2, c);
    auto ips = DList!(IntervalPoint!S)(intervalTransform(points[0]));

    // initialize with user given splitting points
    foreach (i, p; points[1..$])
    {
        auto iv = intervalTransform(p);
        calcInterval(ips.back, iv, c);
        totalHatArea += ips.back.hatArea;
        totalSqueezeArea += ips.back.squeezeArea;
        ips.insertBack(iv);
    }

    // Tinflex is not guaranteed to converge
    foreach (i; 0..maxIterations)
    {
        // Tinflex aims for a user defined efficiency
        if (totalHatArea / totalSqueezeArea <= rho)
            break;

        S a_avg = (totalHatArea - totalSqueezeArea) / (nrIntervals - 1);
        // first iteration: search only (we update the list online later)
        auto it = ips[];
        foreach (j; 0..nrIntervals - 1)
        {
            if (it.front.hatArea - it.front.squeezeArea > a_avg)
            {
                // prepare total areas for update
                totalHatArea -= it.front.hatArea;
                totalSqueezeArea -= it.front.squeezeArea;

                auto nextView = it.save.dropOne;

                // split the interval at the arcmean into two parts
                auto mid = arcmean(it.front.x, nextView.front.x);
                IntervalPoint!S midIP = intervalTransform(mid);

                // recalculate intervals
                calcInterval(midIP, nextView.front, c);
                calcInterval(it.front, midIP, c);

                // insert new middle part into linked list
                auto itNext = it.save;
                itNext.popFront();
                ips.insertBefore(itNext, midIP);

                // update total areas
                totalHatArea += it.front.hatArea + midIP.hatArea;
                totalSqueezeArea += it.front.squeezeArea + midIP.squeezeArea;

                nrIntervals++;
            }
            it.popFront();
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
    foreach (S; AliasSeq!(float, double, real))
    {
        auto f0 = (S x) => -x^^4 + 5 * x^^2 - 4;
        auto f1 = (S x) => 10 * x - 4 * x ^^ 3;
        auto f2 = (S x) => 10 - 12 * x ^^ 2;
        S c = 1.5;
        S[] points = [-3, -1.5, 0, 1.5, 3];
        auto ips = calcPoints(f0, f1, f2, c, points, S(1.1));

        // TODO: should be 45?
        assert(ips.length == 50);
    }
}
