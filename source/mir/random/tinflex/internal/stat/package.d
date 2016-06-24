/**
Statistical tests.

License: $(LINK2 http://boost.org/LICENSE_1_0.txt, Boost License 1.0).
*/

module mir.random.tinflex.internal.stat;

import std.stdio;

/**
Chi-squared statical test.
Given a binned frequency table of a distribution, analyzes the goodness of the fit
by comparing the number of observations with the theoretical expectations
of a bin.

See_Also:
    $(LINK2 https://en.wikipedia.org/wiki/Pearson%27s_chi-squared_test, Wikipedia)
*/
auto chisq(S = double, T)(T[] obs, T[] probs, uint degreesOfFreedom = 0)
in
{
    assert(obs.length == probs.length, "Number of observations need to match hypothesis");
}
body
{
    S x = 0.0;
    foreach (i; 0..obs.length)
    {
        // TODO: use count or frequency here?
        //auto of = obs[i] / obs.length;
        auto of = obs[i];
        auto v = of - probs[i];
        x += v * v / probs[i];
    }
    //x *= obs.length;
    import std.typecons : tuple;
    import mir.random.tinflex.internal.stat.distributions : chiSqCDF;
    real p = 1 - chiSqCDF(x, obs.length - 1 - degreesOfFreedom);
    return tuple!("x", "p")(x, p);
}

auto chisq(T)(T[] obs)
{
    import std.algorithm.iteration : sum;

    T[] probs = new T[obs.length];
    probs[] = obs.sum / obs.length;
    return chisq(obs, probs);
}

///
unittest
{
    import std.math : approxEqual;
    auto res = [2.0, 3, 5, 8, 12].chisq;
    assert(res.x == 11.0);
    //assert(res.p.approxEqual(0.0265));
}

unittest
{
    import std.math : approxEqual;
    auto res = [2.0, 3, 5, 8, 12, 5].chisq([1, 4, 5, 10, 7, 8]);
    assert(res.x.approxEqual(6.34642));
    assert(res.p.approxEqual(0.27395));
}
