/**
License: $(LINK2 http://boost.org/LICENSE_1_0.txt, Boost License 1.0).

Authors: Sebastian Wilzbach, Ilya Yaroshenko

The Transformed Density Rejection with Inflection Points (Tinflex) algorithm
can sample from arbitrary distributions given its density function f, its
first two derivatives and a partitioning into intervals with at most one inflection
point.

These can be easily found by plotting `f''`.
$(B Inflection point) can be identified by observing at which points `f''` is 0.

$(UL
    $(LI $(F_TILDE) is entirely concave (`f''` is entirely negative))
    $(LI $(F_TILDE) is entirely convex (`f''` is entirely positive))
    $(LI $(F_TILDE) contains one inflection point (`f''` intersects the x-axis once)
)

In exact terms the algorithm requires:

$(UL
    $(LI Continuous density function $(F_TILDE).)
    $(LI Continuous differentiability of $(F_TILDE) except in a finite number of
      points which need to have a one-sided derivative.)
    $(LI $(B Doubled) Continuous differentiability of $(F_TILDE) except in a finite number of
      points which need to be inflection points.)
    $(LI At most one inflection point per interval)
)

References:
    Transformed Density Rejection with Inflection Points

    Botts, Carsten, Wolfgang Hörmann, and Josef Leydold.
    "$(LINK2 http://epub.wu-wien.ac.at/3158/1/techreport-110.pdf,
    Transformed density rejection with inflection points.)"
    Statistics and Computing 23.2 (2013): 251-260.

Macros:
    F_TILDE=g(x)
*/
module mir.random.tinflex;

import mir.random.tinflex.internal.types : IntervalPoint;

import std.traits : ReturnType, isFloatingPoint;
import std.random : isUniformRNG;


/**
The Transformed Density Rejection with Inflection Points (Tinflex) algorithm
can sample from arbitrary distributions given its density function f, its
first two derivatives and a partitioning into intervals with at most one inflection
point.

Params:
    f0 = probability density function of the distribution
    f1 = first derivative of f0
    f2 = second derivative of f0
    c = T_c family
    points = non-overlapping partitioning with at most one inflection point per interval
    rho = efficiency of the Tinflex algorithm

Returns:
    Tinflex Generator.
*/
Tinflex!(F0, S) tinflex(F0, F1, F2, S)
               (in F0 f0, in F1 f1, in F2 f2,
                S c, S[] points, S rho = 1.1)
    if (isFloatingPoint!S)
{
    import mir.random.tinflex.internal.calc : calcPoints;
    // pre-calculate all the points
    auto ips = calcPoints(f0, f1, f2, c, points, 1.1);
    return Tinflex!(F0, S)(f0, ips, c);
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
    private const IntervalPoint!S[] _ips;

    // global T_c family
    private const S c;

    protected this(const F0 f0, const IntervalPoint!S[] ips, const S c)
    {
        _f0 = f0;
        _ips = ips;
        this.c = c;
    }

    /// density function of the distribution
    F0 pdf() const @property
    {
        return _f0;
    }

    /// density function of the distribution
    S pdf(S x) const @property
    {
        return _f0(x);
    }

    /// Generated partition points
    const(IntervalPoint!S[]) ips() @property const
    {
        return _ips;
    }

    /**
    Sample n times from the distribution.
    Params:
        n = number of times to samples
        rng = random number generator to use
    Returns:
        Array of length n with the samples
    */
    S opCall() const
    {
        import std.random : rndGen;
        return tfSample(_f0, _ips, c, rndGen);
    }

    /// ditto
    S opCall(RNG)(ref RNG rng) const
        if (isUniformRNG!RNG)
    {
        return tfSample(_f0, _ips, c, rng);
    }
}

/**
Sample from the distribution.
Params:
    ips = calculated inflection points
    rng = random number generator to use
*/
protected S tfSample(F0, S, RNG)
          (in F0 f0, in IntervalPoint!S[] ips, in S c, ref RNG rng)
    if (is(ReturnType!F0 == S) &&
        isUniformRNG!RNG && isFloatingPoint!S)
{
    import std.algorithm: filter, joiner, map, sum;

    // TODO: filtering not needed anymore
    auto totalAreaSum = ips[0..$-2].map!`a.hatA`.sum;
    auto areas = ips[0..$-2].map!((x) => x.hatA / totalAreaSum);

    import std.random: dice, uniform01;
    import std.math: abs;
    import mir.internal.math: exp;

    import mir.random.tinflex.internal.transformations : inverse, antiderivative, inverseAntiderivative;

    double X = void;
    // acceptance-rejection sampling
    for (;;)
    {
        import std.stdio;
        writeln(areas);
        auto j = dice(rng, areas);
        S u = uniform01!S(rng);

        if (abs(ips[j].hat.slope) > 1e-10)
        {
            X = ips[j].hat._y + (inverseAntiderivative(antiderivative(ips[j].hat(ips[j].x), c)
                          + ips[j].hat.slope * u, c) - ips[j].hat.a) / ips[j].hat.slope;
        }
        else
        {
            X = (1-u) * ips[j].x + u * ips[j + 1].x;
        }

        auto hatX = inverse(ips[j].hat(X), c);
        auto squeezeX = ips[j].squeezeA > 0 ? inverse(ips[j].squeeze(X), c) : 0;

        immutable t = u * hatX;
        if (t <= squeezeX)
        {
            break;
        }
        if (t <= exp(f0(X)))
        {
            break;
        }
    }
    return X;
}

///
unittest
{
    auto f0 = (double x) => -x^^4 + 5 * x^^2 - 4;
    auto f1 = (double x) => 10 * x - 4 * x ^^ 3;
    auto f2 = (double x) => 10 - 12 * x ^^ 2;
    auto tf = tinflex(f0, f1, f2, 1.5, [-3.0, -1.5, 0.0, 1.5, 3], 1.1);
    import std.random : rndGen;
    rndGen.seed(42);
    auto value = tf(rndGen);

    // see more examples at mir/examples
}
