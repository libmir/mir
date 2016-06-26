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

import mir.random.tinflex.internal.types : GenerationPoint;
import mir.random.discrete : Discrete;

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
    // pre-calculate all the points
    import mir.random.tinflex.internal.calc : calcPoints;
    const gps = calcPoints(f0, f1, f2, c, points, 1.1);
    return Tinflex!(F0, S)(f0, gps, c);
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
    private const GenerationPoint!S[] _gps;

    // discrete density sampler
    private const Discrete!S ds;

    // global T_c family
    private const S c;

    package this(const F0 f0, const GenerationPoint!S[] gps, const S c)
    {
        _f0 = f0;
        _gps = gps;
        this.c = c;

        // pre-calculate cumulative density points
        auto cdPoints = new S[gps.length - 1];
        cdPoints[0] = gps[0].hatArea;
        foreach (i, ref cp; cdPoints[1..$])
        {
            // i starts at 0
            cp = cdPoints[i] + gps[i + 1].hatArea;
        }
        this.ds = Discrete!S(cdPoints);
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
    package const(GenerationPoint!S[]) gps() @property const
    {
        return _gps;
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
        return tinflexImpl(_f0, _gps, ds, c, rndGen);
    }

    /// ditto
    S opCall(RNG)(ref RNG rng) const
        if (isUniformRNG!RNG)
    {
        return tinflexImpl(_f0, _gps, ds, c, rng);
    }
}

/**
Sample from the distribution.
Params:
    ips = calculated inflection points
    rng = random number generator to use
*/
protected S tinflexImpl(F0, S, RNG)
          (in F0 f0, in GenerationPoint!S[] gps, in Discrete!S ds, in S c, ref RNG rng)
    if (isUniformRNG!RNG)
{
    import std.random: dice, uniform01;
    import std.math: abs;
    import mir.internal.math: exp;

    import mir.random.tinflex.internal.transformations : inverse, antiderivative, inverseAntiderivative;

    S X = void;
    // acceptance-rejection sampling
    for (;;)
    {
        auto j = ds(rng);
        S u = uniform01!S(rng);

        if (abs(gps[j].hat.slope) > 1e-10)
        {
            X = gps[j].hat._y + (inverseAntiderivative(antiderivative(gps[j].hat(gps[j].x), c)
                          + gps[j].hat.slope * u, c) - gps[j].hat.a) / gps[j].hat.slope;
        }
        else
        {
            // j: [0, |gps| - 2] (last gp is excluded)
            X = (1 - u) * gps[j].x + u * gps[j + 1].x;
        }

        auto hatX = inverse(gps[j].hat(X), c);
        auto squeezeX = gps[j].squeezeArea > 0 ? inverse(gps[j].squeeze(X), c) : 0;

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
        assert(value.approxEqual(-1.2631));
    }
    // see more examples at mir/examples
}
