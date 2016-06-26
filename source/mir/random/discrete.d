/**
Discrete distributions.

License: $(LINK2 http://boost.org/LICENSE_1_0.txt, Boost License 1.0).

Authors: Ilya Yaroshenko, Sebastian Wilzbach
*/

module mir.random.discrete;

import std.traits : isNumeric;

/**
Setup a _discrete distribution sampler.
Given an array of cumulative density points `cdPoints`,
a _discrete distribution is defined.
The cumulative density points can be calculated from probabilities or counts
using `std.algorithm.iteration.cumulativeFold`. Hence `cdPoints` is assumed to be sorted.

Params:
    cdPoints = cumulative density points

Returns:
    A $(LREF Discrete) sampler that can be called to sample from the distribution.
*/
Discrete!T discrete(T)(const(T)[] cdPoints)
{
    return Discrete!T(cdPoints);
}

///
unittest
{
    // 10%, 20%, 20%, 40%, 10%
    auto cdPoints = [0.1, 0.3, 0.5, 0.9, 1];
    auto ds = discrete(cdPoints);

    // sample from the discrete distribution
    auto obs = new uint[cdPoints.length];
    foreach (i; 0..10_000)
        obs[ds()]++;
}

/**
_Discrete distribution sampler that draws random values from a _discrete
distribution given an array of the respective cumulative density points.
`cdPoints` is an array of the cummulative sum over the probabilities
or counts of a _discrete distribution without a starting zero.

Complexity: O(log n) where n is the number of `cdPoints`.
*/
struct Discrete(T)
    if (isNumeric!T)
{
    private const(T)[] cdPoints;

    /**
    The cumulative density points `cdPoints` are assumed to be sorted and given
    without a starting zero. They can be calculated with
    `std.algorithm.iteration.cumulativeFold` from probabilities or counts.

    Params:
        cdPoints = cumulative density points
    */
    this(const(T)[] cdPoints)
    {
        this.cdPoints = cdPoints;
    }

    /// samples a value from the discrete distribution
    size_t opCall() const
    {
        import std.random : rndGen;
        return opCall(rndGen);
    }

    /// samples a value from the discrete distribution using a custom random generator
    size_t opCall(RNG)(ref RNG gen) const
    {
        import std.random : uniform;
        import std.range : assumeSorted;

        T v = uniform!("[)", T, T)(0, cdPoints[$-1], gen);
        return cdPoints.length - cdPoints.assumeSorted!"a < b".upperBound(v).length;
    }
}

// test with cumulative probs
unittest
{
    import std.random : Random;
    auto gen = Random(42);

    // 10%, 20%, 20%, 40%, 10%
    auto cdPoints = [0.1, 0.3, 0.5, 0.9, 1];
    auto ds = discrete(cdPoints);

    auto obs = new uint[cdPoints.length];
    foreach (i; 0..10_000)
        obs[ds(gen)]++;

    assert(obs == [1030, 1964, 1968, 4087, 951]);
}

// test with cumulative count
unittest
{
    import std.random : Random;
    auto gen = Random(42);

    // 1, 2, 1
    auto cdPoints = [1, 3, 4];
    auto ds = discrete(cdPoints);

    auto obs = new uint[cdPoints.length];
    foreach (i; 0..10_000)
        obs[ds(gen)]++;

    assert(obs == [2536, 4963, 2501]);
}

// test with zero probabilities
unittest
{
    import std.random : Random;
    auto gen = Random(42);

    // 0, 1, 2, 0, 1
    auto cdPoints = [0, 1, 3, 3, 4];
    auto ds = discrete(cdPoints);

    auto obs = new uint[cdPoints.length];
    foreach (i; 0..10_000)
        obs[ds(gen)]++;

    assert(obs == [0, 2536, 4963, 0, 2501]);
}
