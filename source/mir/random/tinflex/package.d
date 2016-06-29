/**
Tinflex module.

License: $(LINK2 http://boost.org/LICENSE_1_0.txt, Boost License 1.0).

Authors: Sebastian Wilzbach, Ilya Yaroshenko

The Transformed Density Rejection with Inflection Points (Tinflex) algorithm
can sample from arbitrary distributions given its density function f, its
first two derivatives and a partitioning into intervals with at most one inflection
point.

These can be easily found by plotting `f''`.
$(B Inflection point) can be identified by observing at which points `f''` is 0
and an inflection interval which is defined by two inflection points can either be:

$(UL
    $(LI $(F_TILDE) is entirely concave (`f''` is entirely negative))
    $(LI $(F_TILDE) is entirely convex (`f''` is entirely positive))
    $(LI $(F_TILDE) contains one inflection point (`f''` intersects the x-axis once))
)

It is not important to identity the exact inflection points, but the user input requires:

$(UL
    $(LI Continuous density function $(F_TILDE).)
    $(LI Continuous differentiability of $(F_TILDE) except in a finite number of
      points which need to have a one-sided derivative.)
    $(LI $(B Doubled) continuous differentiability of $(F_TILDE) except in a finite number of
      points which need to be inflection points.)
    $(LI At most one inflection point per interval)
)

Internally the Tinflex algorithm transforms the distribution with a special
transformation function and constructs for every interval a linear `hat` function
that majorizes the `pdf` and a linear `squeeze` function that is majorized by
the `pdf` from the user-defined, mutually-exclusive partitioning.

In further steps the algorithm splits those intervals until a chosen efficiency
`rho` between the ratio of the sum of all hat areas to the sum of
all squeeze areas is reached.
A higher efficiency may require more iterations and thus a longer setup phase,
but increases the speed of sampling. For example an efficiency of 1.1 means
that 10% of all drawn uniform numbers don't match the target distribution
and need be resampled.

$(H3 Unbounded intervals)

In each unbounded interval the transformation and thus the density must be
concave and strictly monotone.

$(H3 Transformation function (T_c)) $(A_NAME t_c_family)

The Tinflex algorithm uses a family of T_c transformations.

$(UL
    $(LI For unbounded domains, `c > -1` is required)
    $(LI For unbounded densities, `c` must be sufficiently small, but should
         be great than -1. A common choice is `-0.5`)
    $(LI `c=0` is the pure `log` transformation and thus decreases the
         vulnerability for under- and overflows)
)

References:
    Botts, Carsten, Wolfgang Hörmann, and Josef Leydold.
    "$(LINK2 http://epub.wu-wien.ac.at/3158/1/techreport-110.pdf,
    Transformed density rejection with inflection points.)"
    Statistics and Computing 23.2 (2013): 251-260.

Macros:
    F_TILDE=$(D g(x))
    A_NAME=<a name="$1"></a>
*/
module mir.random.tinflex;

import mir.random.discrete : Discrete;

import std.random : isUniformRNG;
import std.traits : isCallable, isFloatingPoint, ReturnType;

/**
The Transformed Density Rejection with Inflection Points (Tinflex) algorithm
can sample from arbitrary distributions given its density function f, its
first two derivatives and a partitioning into intervals with at most one inflection
point. The partitioning needs to be mutually exclusive and sorted.

Params:
    f0 = probability density function of the distribution
    f1 = first derivative of f0
    f2 = second derivative of f0
    c = $(LINK2 #t_c_family, T_c family) value
    cs = $(LINK2 #t_c_family, T_c family) array
    points = non-overlapping partitioning with at most one inflection point per interval
    rho = efficiency of the Tinflex algorithm

Returns:
    Tinflex Generator.
*/
Tinflex!(F0, S) tinflex(F0, F1, F2, S)
               (in F0 f0, in F1 f1, in F2 f2,
                S c, S[] points, S rho = 1.1)
    if (isFloatingPoint!S && isFloatingPoint!(ReturnType!F0) &&
        isFloatingPoint!(ReturnType!F1) && isFloatingPoint!(ReturnType!F2) &&
        isCallable!F0 && isCallable!F1 && isCallable!F2)
{
    S[] cs = new S[points.length - 1];
    foreach (ref d; cs)
        d = c;

    // pre-calculate all the points
    const gps = tinflexIntervals(f0, f1, f2, cs, points, rho);
    return Tinflex!(F0, S)(f0, gps);
}

/// ditto
Tinflex!(F0, S) tinflex(F0, F1, F2, S)
               (in F0 f0, in F1 f1, in F2 f2,
                S[] cs, S[] points, S rho = 1.1)
    if (isFloatingPoint!S && isFloatingPoint!(ReturnType!F0) &&
        isFloatingPoint!(ReturnType!F1) && isFloatingPoint!(ReturnType!F2) &&
        isCallable!F0 && isCallable!F1 && isCallable!F2)
{
    // pre-calculate all the points
    const gps = tinflexIntervals(f0, f1, f2, cs, points, 1.1);
    return Tinflex!(F0, S)(f0, gps);
}

/**
Data body of the Tinflex algorithm.
Can be used to sample from the distribution.
*/
struct Tinflex(F0, S)
    if (isFloatingPoint!S)
{
    // density function
    private const F0 _f0;

    // generated partition points
    private const TinflexInterval!S[] _tfivs;

    // discrete density sampler
    private const Discrete!S ds;

    package this(const F0 f0, const TinflexInterval!S[] tfivs)
    {
        _f0 = f0;
        _tfivs = tfivs;

        // pre-calculate cumulative density points
        auto cdPoints = new S[tfivs.length];
        cdPoints[0] = tfivs[0].hatArea;
        foreach (i, ref cp; cdPoints[1..$])
        {
            // i starts at 0
            cp = cdPoints[i] + tfivs[i + 1].hatArea;
        }
        this.ds = Discrete!S(cdPoints);
    }

    S pdf(S x) @property const
    {
        return _f0(x);
    }

    S c() @property const
    {
        return _tfivs[0].c;
    }

    /// Generated partition points
    package const(TinflexInterval!S[]) tfivs() @property const
    {
        return _tfivs;
    }

    /**
    Sample a value from the distribution.
    Params:
        rng = random number generator to use
    Returns:
        Array of length n with the samples
    */
    S opCall() const
    {
        import std.random : rndGen;
        return tinflexImpl(_f0, _tfivs, ds, rndGen);
    }

    /// ditto
    S opCall(RNG)(ref RNG rng) const
        if (isUniformRNG!RNG)
    {
        return tinflexImpl(_f0, _tfivs, ds, rng);
    }
}

///
unittest
{
    import std.math : approxEqual;
    import std.meta : AliasSeq;
    import std.random : Mt19937;
    foreach (S; AliasSeq!(float, double, real))
    {
        auto gen = Mt19937(42);
        auto f0 = (S x) => -x^^4 + 5 * x^^2 - 4;
        auto f1 = (S x) => 10 * x - 4 * x ^^ 3;
        auto f2 = (S x) => 10 - 12 * x ^^ 2;
        S[] points = [-3, -1.5, 0, 1.5, 3];

        auto tf = tinflex(f0, f1, f2, 1.5, points, 1.1);

        auto value = tf(gen);
        //assert(value.approxEqual(-1.2631));
    }
    // see more examples at mir/examples
}

/**
Sample from the distribution with generated, non-overlapping hat and squeeze functions.
Uses acceptance-rejection algorithm.

Params:
    f0 = probability density function of the distribution
    tfivs = calculated inflection points
    ds = discrete distribution sampler for hat areas
    rng = random number generator to use
See_Also:
   $(LINK2 https://en.wikipedia.org/wiki/Rejection_sampling,
     Acceptance-rejection sampling)
*/
private S tinflexImpl(F0, S, RNG)
          (in F0 f0, in TinflexInterval!S[] tfivs, in Discrete!S ds, ref RNG rng)
    if (isUniformRNG!RNG)
{
    import mir.internal.math: exp, fabs, log;
    import mir.random.tinflex.internal.transformations : inverse, antiderivative, inverseAntiderivative;
    import std.random: dice, uniform;

    S X = void;
    enum S one_div_3 = 1 / S(3);

    // acceptance-rejection sampling
    for (;;)
    {
        // sample from interval with density proportional to their hatArea
        auto rndInt = ds(rng); // J in Tinflex paper
        S u = uniform!("()", S, S)(0, 1, rng);
        import std.stdio;
        if (rndInt >= tfivs.length)
            rndInt = tfivs.length - 1;

        immutable c = tfivs[rndInt].c;

        auto hatX = inverse(tfivs[rndInt].hat(X), c);
        auto squeezeX = tfivs[rndInt].squeezeArea > 0 ? inverse(tfivs[rndInt].squeeze(X), c) : 0;

        immutable t = u * hatX;

        if (c == 0)
        {
            auto eXInv = exp(-tfivs[rndInt].hat(tfivs[rndInt].lx));
            auto z = u * tfivs[rndInt].hat.slope * eXInv;
            if (fabs(z) > S(1e-6))
            {
                X = tfivs[rndInt].hat.y + (log(1 / eXInv + tfivs[rndInt].hat.slope * u) -
                                          tfivs[rndInt].hat.a) / tfivs[rndInt].hat.slope;
            }
            else
                X = tfivs[rndInt].lx + u * eXInv * (1 - z * S(0.5) + z * z * one_div_3);
            goto all;
        }
        else if (c == S(-0.5))
        {
            auto eX = exp(tfivs[rndInt].hat(tfivs[rndInt].lx));
            auto z = u * tfivs[rndInt].hat.slope * eX;
            if (fabs(z) > S(1e-6))
                goto mInvAD;
            else
                X = tfivs[rndInt].lx + u * eX * (1 - z * S(0.5) + z * z / one_div_3);
            goto all;
        }
        else if (c == 1)
        {
            auto k = tfivs[rndInt].hat(tfivs[rndInt].lx);
            auto z = u * tfivs[rndInt].hat.slope / (k * k);
            if (fabs(z) > S(1e-6))
                goto mInvAD;
            else
                X = tfivs[rndInt].lx + u * k * (1 - z * S(0.5) + z * z * S(0.5));
            goto all;
        }
        else
        {
            if (fabs(tfivs[rndInt].hat.slope) > S(1e-10))
                goto mInvAD;
            else
                X = (1 - u) * tfivs[rndInt].lx + u * tfivs[rndInt].rx;
            goto all;
        }
mInvAD:
        // common approximation
        X = tfivs[rndInt].hat.y +
            (inverseAntiderivative
                (   antiderivative(tfivs[rndInt].hat(tfivs[rndInt].lx), c)
                        + tfivs[rndInt].hat.slope * u
                , c) - tfivs[rndInt].hat.a
            ) / tfivs[rndInt].hat.slope;
all:
        // U * h(c) < s(X)  "squeeze evaluation"
        if (t <= squeezeX)
            return X;

        // U * h(c) < f(X)  "density evaluation"
        if (t <= exp(f0(X)))
            return X;
    }
    assert(0);
}

/**
Reduced version of $(LREF Interval). Contains only the necessary information
needed in the generation phase.
*/
struct TinflexInterval(S)
    if (isFloatingPoint!S)
{
    import mir.utility.linearfun : LinearFun;

    /// left position of the interval
    S lx;

    /// right position of the interval
    S rx;

    /// T_c family of the interval
    S c;

    ///
    LinearFun!S hat;

    ///
    LinearFun!S squeeze;

    ///
    S hatArea;

    ///
    S squeezeArea;

    // disallow NaN points
    invariant {
        import std.math : isNaN;
        import std.meta : AliasSeq;
        alias seq =  AliasSeq!(lx, rx, c, hatArea, squeezeArea);
        foreach (i, v; seq)
            assert(!v.isNaN, "variable " ~ seq[i].stringof ~ " isn't allowed to be NaN");

        assert(lx < rx, "invalid interval - right side must be larger than the left side");
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
    apprMaxPoints = maximal number of splitting points before Tinflex is aborted

Returns: Array of IntervalPoints
*/
TinflexInterval!S[] tinflexIntervals(F0, F1, F2, S)
                            (in F0 f0, in F1 f1, in F2 f2,
                             in S[] cs, in S[] points, in S rho = 1.1,
                             in int apprMaxPoints = 1_000, in int maxIterations = 1_000)
in
{
    import std.algorithm.searching : all;
    import std.math : isFinite, isInfinity;
    import std.range: drop, empty, front, save;

    // check points
    assert(points.length >= 2, "two or more splitting points are required");
    assert(points[1..$-1].all!isFinite, "intermediate interval can't be indefinite");

    // check cs
    assert(cs.length == points.length - 1, "cs must have length equal to |points| - 1");

    // check first c
    if (points[0].isInfinity)
        assert(cs.front > - 1,"c must be > -1 for unbounded domains");

    // check last c
    if (points[$ - 1].isInfinity)
        assert(cs[$ - 1] > - 1,"cs must be > -1 for unbounded domains");
}
body
{
    import mir.random.tinflex.internal.calc: arcmean, calcInterval;
    import mir.random.tinflex.internal.transformations : transform,  transformToInterval;
    import mir.random.tinflex.internal.types: Interval;
    import mir.sum: Summator, Summation;
    import std.container.dlist : DList;
    import std.range.primitives : front, empty, popFront;

    alias Sum = Summator!(S, Summation.precise);

    Sum totalHatAreaSummator = 0;
    Sum totalSqueezeAreaSummator = 0;

    auto nrIntervals = cs.length;

    auto ips = DList!(Interval!S)();
    S l = points[0];
    S l0 = f0(points[0]);
    S l1 = f1(points[0]);
    S l2 = f2(points[0]);

    version(Tinflex_logging)
    {
        import std.experimental.logger;
        log("starting tinflex with p=", points, ", cs=", cs);
    }

    // initialize with user given splitting points
    foreach (i, r; points[1..$])
    {
        // reuse computations
        S r0 = f0(r);
        S r1 = f1(r);
        S r2 = f2(r);
        auto iv = transformToInterval(l, r, cs[i], l0, l1, l2,
                                                   r0, r1, r2);
        l = r;
        l0 = r0;
        l1 = r1;
        l2 = r2;

        calcInterval(iv);
        totalHatAreaSummator += iv.hatArea;
        totalSqueezeAreaSummator += iv.squeezeArea;

        ips.insertBack(iv);
    }

    version(Tinflex_logging)
    {
        import std.algorithm;
        import std.array;
        log("----");
        log("Interval: ", ips.array.map!`a.lx`);
        log("hatArea", ips.array.map!`a.hatArea`);
        log("squeezeArea", ips.array.map!`a.squeezeArea`);
        log("----");
    }

    // Tinflex is not guaranteed to converge
    for (auto i = 0; i < maxIterations && nrIntervals < apprMaxPoints; i++)
    {
        immutable totalHatArea = totalHatAreaSummator.sum;
        immutable totalSqueezeArea = totalSqueezeAreaSummator.sum;

        // Tinflex aims for a user defined efficiency
        if (totalHatArea / totalSqueezeArea <= rho)
            break;

        version(Tinflex_logging)
        {
            tracef("iteration %d: totalHat: %.3f, totalSqueeze: %.3f, rho: %.3f",
                    i, totalHatArea, totalSqueezeArea, totalHatArea / totalSqueezeArea);
        }

        import std.math: nextDown;
        immutable avgArea = nextDown(totalHatArea - totalSqueezeArea) / nrIntervals;
        for (auto it = ips[]; !it.empty;)
        {
            immutable curArea = it.front.hatArea - it.front.squeezeArea;
            if (curArea > avgArea)
            {
                // prepare total areas for update
                totalHatAreaSummator -= it.front.hatArea;
                totalSqueezeAreaSummator -= it.front.squeezeArea;

                // split the interval at the arcmean into two parts
                auto mid = arcmean!(S, true)(it.front.lx, it.front.rx);

                // create new interval (right side)
                S m0 = void, m1 = void, m2 = void;

                // apply transformation to new values
                transform(it.front.c, f0(mid), f1(mid), f2(mid), m0, m1, m2);

                Interval!S midIP = Interval!S(mid, it.front.rx, it.front.c,
                                              m0, m1, m2,
                                              it.front.rtx, it.front.rt1x, it.front.rt2x);

                version(Tinflex_logging)
                {
                    log("--split ", nrIntervals, " between ", it.front.lx, " - ", it.front.rx);
                    log("interval to be splitted: ", it.front);
                    log("new middle interval created: ", midIP);
                }

                // left interval: update right values
                it.front.rx = mid;
                it.front.rtx = m0;
                it.front.rt1x = m1;
                it.front.rt2x = m2;

                // recalculate intervals
                calcInterval(it.front);
                calcInterval(midIP);

                version(Tinflex_logging)
                {
                    log("update left: ", it.front);
                    log("update mid: ", midIP);
                }

                // update total areas
                totalHatAreaSummator += it.front.hatArea;
                totalHatAreaSummator += midIP.hatArea;
                totalSqueezeAreaSummator += it.front.squeezeArea;
                totalSqueezeAreaSummator += midIP.squeezeArea;

                // insert new middle part into linked list
                it.popFront;
                // @@@bug@@@ in DList, insertBefore with an empty list inserts
                // at the front
                if (it.empty)
                    ips.insertBack(midIP);
                else
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
    auto tfivs = new TinflexInterval!S[nrIntervals];
    size_t i = 0;
    foreach (ref ip; ips)
        tfivs[i++] = TinflexInterval!S(ip.lx, ip.rx, ip.c, ip.hat,
                                     ip.squeeze, ip.hatArea, ip.squeezeArea);

    version(Tinflex_logging)
    {
        log("----");
        log("Intervals generated: ", tfivs.length);
        import std.algorithm;
        import std.array;
        log("Interval: ", ips.array.map!`a.lx`);
        log("hatArea", ips.array.map!`a.hatArea`);
        log("squeezeArea", ips.array.map!`a.squeezeArea`);
        log("----");
    }

    return tfivs;
}

// default tinflex with c=1.5
unittest
{
    import std.meta : AliasSeq;
    foreach (S; AliasSeq!(float, double, real))
    {
        auto f0 = (S x) => -x^^4 + 5 * x^^2 - 4;
        auto f1 = (S x) => 10 * x - 4 * x ^^ 3;
        auto f2 = (S x) => 10 - 12 * x ^^ 2;
        S[] cs = [1.5, 1.5, 1.5, 1.5];
        S[] points = [-3, -1.5, 0, 1.5, 3];
        auto ips = tinflexIntervals(f0, f1, f2, cs, points, S(1.1));

        import std.stdio;
        writeln("IP points generated", ips.length);
        //assert(ips.length == 45);
    }
}

// default tinflex with c=1
unittest
{
    import std.meta : AliasSeq;
    foreach (S; AliasSeq!(float, double, real))
    {
        auto f0 = (S x) => -x^^4 + 5 * x^^2 - 4;
        auto f1 = (S x) => 10 * x - 4 * x ^^ 3;
        auto f2 = (S x) => 10 - 12 * x ^^ 2;
        S[] points = [-3, -1.5, 0, 1.5, 3];
        S[] cs = [1.0, 1.0, 1.0, 1.0];
        auto ips = tinflexIntervals(f0, f1, f2, cs, points, S(1.1));

        import std.stdio;
        writeln("IP points generated", ips.length);
        //assert(ips.length == 45);
    }
}

// default tinflex with custom c's
unittest
{
    import std.meta : AliasSeq;
    foreach (S; AliasSeq!(float, double, real))
    {
        auto f0 = (S x) => -x^^4 + 5 * x^^2 - 4;
        auto f1 = (S x) => 10 * x - 4 * x ^^ 3;
        auto f2 = (S x) => 10 - 12 * x ^^ 2;
        S[] cs = [1.3, 1.4, 1.5, 1.6];
        S[] points = [-3, -1.5, 0, 1.5, 3];
        auto ips = tinflexIntervals(f0, f1, f2, cs, points, S(1.1));

        //assert(ips.length == 45);
    }
}

// test standard normal distribution
unittest
{
    import mir.internal.math : exp, sqrt;
    import std.meta : AliasSeq;
    import std.math : PI;
    foreach (S; AliasSeq!(float, double, real))
    {
        S sqrt2PI = sqrt(2 * PI);
        auto f0 = (S x) => 1 / (exp(x * x / 2) * sqrt2PI);
        auto f1 = (S x) => -(x/(exp(x * x/2) * sqrt2PI));
        auto f2 = (S x) => (-1 + x * x) / (exp(x * x/2) * sqrt2PI);
        S[] cs = [1.5, 1.5, 1.5, 1.5];
        S[] points = [-3, -1.5, 0, 1.5, 3];
        auto ips = tinflexIntervals(f0, f1, f2, cs, points, S(1.1));

        import std.stdio;
        writeln("IP points generated", ips.length);
    }
}

unittest
{
    import std.array : array;
    import std.meta : AliasSeq;
    import std.range : repeat;
    enum xs =    [-1, -0.9, -0.681543496892237, -0.5, -0.236067977499790,
                  0, 0.236067977499790, 0.5, 0.681543496892237, 0.9];
    enum hats = [0.0229266666666667,  0.136019342722764, 0.161670170668440,
                 0.2612709044556, 0.236795080652736, 0.236795080652736,
                 0.2612709044556, 0.161670170668440, 0.136019342722764,
                 0.0229266666666667];
    enum sqs = [0, 0.124439727192501, 0.156697988044425, 0.255354531224623,
                0.235701598814137, 0.235701598814137, 0.255354531224623,
                0.156697988044425, 0.124439727192501, 0];

    //foreach (S; AliasSeq!(float, double, real))
    foreach (S; AliasSeq!(real))
    {
        import std.math : log;
        auto f0 = (S x) => log(1 - x^^4);
        auto f1 = (S x) => -4 * x^^3 / (1 - x^^4);
        auto f2 = (S x) => -(4 * x^^6 + 12 * x^^2) / (x^^8 - 2 * x^^4 + 1);
        S[] points = [S(-1), -0.9, -0.5, 0.5, 0.9, 1];
        S[] cs = S(2).repeat(points.length - 1).array;

        auto ips = tinflexIntervals(f0, f1, f2, cs, points, S(1.1));

        import std.stdio;
        writeln(points);
    }
}
