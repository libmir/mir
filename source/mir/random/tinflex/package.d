/**
License: $(LINK2 http://boost.org/LICENSE_1_0.txt, Boost License 1.0).

Authors: Sebastian Wilzbach, Ilya Yaroshenko

The Transformed Density Rejection with Inflection Points (Tinflex) algorithm
can sample from arbitrary distributions given its density function f, its
first two derivatives and a partitioning into intervals with at most one inflection
point.

These can be easily found by plotting `f''`.
$(B Inflection point) can be identified by observing at which points `f''` is 0
and an inflection interval which is defined by two inflection points can either
be:

$(UL
    $(LI $(F_TILDE) is entirely concave (`f''` is entirely negative))
    $(LI $(F_TILDE) is entirely convex (`f''` is entirely positive))
    $(LI $(F_TILDE) contains one inflection point (`f''` intersects the x-axis once))
)

It is not important to identity the exact inflection points, but the user input
requires:

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

$(H3 Transformation function (T_c))
<a name="t_c_family></a>

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
point. The partitioning needs to be mutually exclusive and sorted.

Params:
    f0 = probability density function of the distribution
    f1 = first derivative of f0
    f2 = second derivative of f0
    c = $(LINK2 #t_c_family, T_c family)
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
    Sample a value from the distribution.
    Params:
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
Sample from the distribution with generated, non-overlapping hat and squeeze functions.
Uses acceptance-rejection algorithm.

Params:
    f0 = probability density function of the distribution
    gps = calculated inflection points
    ds = discrete distribution sampler for hat areas
    c = $(LINK2 #t_c_family, T_c family)
    rng = random number generator to use
See_Also:
   $(LINK2 https://en.wikipedia.org/wiki/Rejection_sampling,
     Acceptance-rejection sampling)
*/
protected S tinflexImpl(F0, S, RNG)
          (in F0 f0, in GenerationPoint!S[] gps, in Discrete!S ds, in S c, ref RNG rng)
    if (isUniformRNG!RNG)
{
    import std.random: dice, uniform;
    import std.math: abs;
    import mir.internal.math: exp;

    import mir.random.tinflex.internal.transformations : inverse, antiderivative, inverseAntiderivative;

    S X = void;
    // acceptance-rejection sampling
    for (;;)
    {
        // sample from interval with density proportional to their hatArea
        auto rndInt = ds(rng);
        S u = uniform!("()", S, S)(0, 1, rng);

        if (abs(gps[rndInt].hat.slope) > 1e-10)
        {
            X = gps[rndInt].hat._y + (inverseAntiderivative(antiderivative(gps[rndInt].hat(gps[rndInt].x), c)
                          + gps[rndInt].hat.slope * u, c) - gps[rndInt].hat.a) / gps[rndInt].hat.slope;
        }
        else
        {
            // rndInt: [0, |gps| - 2] (last gp is excluded)
            X = (1 - u) * gps[rndInt].x + u * gps[rndInt + 1].x;
        }

        auto hatX = inverse(gps[rndInt].hat(X), c);
        auto squeezeX = gps[rndInt].squeezeArea > 0 ? inverse(gps[rndInt].squeeze(X), c) : 0;

        immutable t = u * hatX;

        // U * h(c) < s(X)
        if (t <= squeezeX)
        {
            return X;
        }
        // U * h(c) < f(X)
        if (t <= exp(f0(X)))
        {
            return X;
        }
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
        assert(value.approxEqual(-1.2631));
    }
    // see more examples at mir/examples
}
