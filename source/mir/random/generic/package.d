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
module mir.random.generic;

import mir.random.generic.types : IntervalPoint;

import std.traits : ReturnType;
import std.random : isUniformRNG;


/**
The Transformed Density Rejection with Inflection Points (Tinflex) algorithm
can sample from arbitrary distributions given its density function f, its
first two derivatives and a partitioning into intervals with at most one inflection
point.

Params:
    f0 = probability density function of the distribution
    f1 = first derivative of f0
    f1 = second derivative of f0
    c = T_c family
    points = non-overlapping partitioning with at most one inflection point per interval
    rho = efficiency of the Tinflex algorithm

Returns:
    Tinflex Generator.
*/
Tinflex!(F0, S) tinflex(F0, F1, F2, S)
               (in F0 f0, in F1 f1, in F2 f2,
                S c, S[] points, S rho = 1.1)
{
    import mir.random.generic.calc : calcPoints;
    // pre-calculate all the points
    auto ips = calcPoints(f0, f1, f2, c, points, 1.1);
    return Tinflex!(F0, S)(f0, ips, c);
}

/**
Data body of the Tinflex algorithm.
Can be used to sample from the distribution.
*/
struct Tinflex(F0, S)
{
    // saved internal state of Tinflex:

    // density function
    private F0 _f0;

    /// density function of the distribution
    S f0(S x)
    {
        return _f0(x);
    }

    // generated partition points
    private IntervalPoint!S[] ips;

    // global T_c family
    private S c;

    private this(F0 f0, IntervalPoint!S[] ips, S c)
    {
        this._f0 = f0;
        this.ips = ips;
        this.c = c;
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
        return tfSample(_f0, ips, c, rndGen);
    }

    /// ditto
    S opCall(RNG)(ref RNG rng) const
        if (isUniformRNG!RNG)
    {
        return tfSample(_f0, ips, c, rng);
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
        isUniformRNG!RNG)
{
    import std.algorithm: filter, joiner, map, sum;

    auto s = ips.filter!`a.right != 0`.map!`a.hatA`.sum;
    auto areas = ips.filter!`a.right != 0`.map!((x) => x.hatA / s);

    import std.random: dice, uniform;
    import std.math: abs;
    import mir.internal.math: exp;

    import mir.random.generic.transformations : inverse, antiderivative, inverseAntiderivative;

    double X;
    // acceptance-rejection sampling
    while (true)
    {
        auto j = dice(rng, areas);
        auto u = uniform(0, 1, rng);

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
        double squeezeX;
        if (ips[j].squeezeA > 0)
            squeezeX = inverse(ips[j].squeeze(X), c);
        else
            squeezeX = 0;

        if (u * hatX <= squeezeX)
        {
            break;
        }
        else if (u * hatX <= exp(f0(X)))
        {
            break;
        }

    }
    return X;
}

/**
Convenience method to sample Arrays with sample r
This will be replaced with a more sophisticated version in later versions.

Params:
    r = random sampler
    n = number of times to sample
Returns: Randomly sampled Array of length n
*/
typeof(R.init())[] sample(R)(R r, int n)
{
    alias S = typeof(r());
    S[] arr = new S[n];
    foreach (ref s; arr)
        s = r();
    return arr;
}

///
unittest
{
    auto f0 = (double x) => -x^^4 + 5 * x^^2 - 4;
    auto f1 = (double x) => 10 * x - 4 * x ^^ 3;
    auto f2 = (double x) => 10 - 12 * x ^^ 2;
    auto tf = tinflex(f0, f1, f2, 1.5, [-3.0, -1.5, 0.0, 1.5, 3], 1.1);
    auto values = tf.sample(100);

    // see more examples at mir/examples
}

/**
(For testing only - will be moved)
Generates a series of y-values that can be used for plotting.

Params:
    t = Tinflex generator
    xs = x points to be plotted
    hat = whether hat (true) or squeeze (false) should be plotted
*/
auto plot(F0, S)(Tinflex!(F0, S) t, S[] xs, bool hat = true)
{
    import std.algorithm.comparison : clamp;
    S[] ys = new S[xs.length];
    int k = 0;
    S rMin = xs[0];
    S rMax = xs[$ - 1];
    outer: foreach (i, v; t.ips)
    {
        S l = clamp(v.x, rMin, rMax);
        S r;
        if (i < t.ips.length - 1)
        {
            r = clamp(t.ips[i + 1].x, rMin, rMax);
        }
        else
        {
            r = rMax;
        }
        while (xs[k] < r)
        {
            if (hat)
                ys[k] = v.hat(xs[k]);
            else
                ys[k] = v.squeeze(xs[k]);

            import mir.random.generic.transformations : inverse;
            ys[k] = inverse(ys[k], v.c);
            k++;
            if (k >= ys.length)
                break outer;
        }
    }
    return ys;
}
