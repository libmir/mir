/**
Discrete distributions.

License: $(LINK2 http://boost.org/LICENSE_1_0.txt, Boost License 1.0).

Authors: Ilya Yaroshenko, Sebastian Wilzbach
*/

module mir.random.discrete;

import std.math: fabs;
import std.traits;

/**
Setup a discrete distribution sampler.

Params:
    probs = probabilities of the individual, discrete values

Returns:
    A $(LREF Discrete) sampler that can be called to sample from the distribution.
*/
Discrete!T discrete(T)(const(T)[] probs)
{
    return Discrete!T(probs);
}

///
unittest
{
    import mir.random.engine.xorshift;
    auto gen = Xorshift(1);
    auto probs = [0.1, 0.2, 0.5, 0.2];
    auto ds = discrete(probs);

    // sample from the discrete distribution
    auto obs = new uint[probs.length];
    foreach (i; 0..10_000)
        obs[ds(gen)]++;
}

/**
_Discrete distribution sampler that draws random values from a _discrete
distribution given an array of the respective probabilities.

Complexity: O(1) per sampling and O(n) for the initial setup, where n is the number
            of discrete values.

References:
    Vose, Michael D. "A linear algorithm for generating random numbers with a given distribution."
    IEEE Transactions on software engineering 17.9 (1991): 972-975.
*/
struct Discrete(T)
    if (isNumeric!T)
{
    import mir.random;

    /// Array with the original column value for a discrete value and its alternative
    private static struct AltPair
    {
        T prob; /// Probability p to select it by a coin toss, if this column is randomly picked
        size_t alt; /// Alternative value if coin toss at j fails
    }

    private AltPair[] arr;

    /**
    Initialize a discrete distribution sampler
    Params:
        probs = probabilities of the individual, discrete values

    Complexity: O(n), where n is the number of discrete values
    */
    this(const(T)[] probs)
    {
        debug
        {
            import mir.sum : sum, Summation;
            import std.math : approxEqual;
            assert(probs.sum!(Summation.fast).approxEqual(1.0), "Sum of the probabilities must be 1");
        }
        initialize(probs);
    }

    /**
    Initialize procedure after [Vose91].
    Each column of the probability array is either filled or used to fill a column
    in such a order that each column has exactly two indexes - the original and
    the alias.
    This procedure is stable and guaranteed to find such columns as the probabilities
    are split at the average probability p_avg and each column is picked with
    1/n - the average probability, so larger columns that are used to fill always
    have enough capacity.
    Afterwards in the sampling step such a column is picked by rolling a fair dice (1/n),
    and whether the original or alias entry in the column should be used is picked
    by tossing a coin with the probability equal to `p_column * n`.
    A detailed proof can be found at [Vose91].
    */
    private void initialize(const(T)[] probs)
    {
        size_t n = probs.length;
        arr = new AltPair[probs.length];

        static struct ProbsIndexed
        {
            T prob; // scaled probability
            size_t index; // original column index
        }

        import std.experimental.allocator.mallocator : Mallocator;
        import std.experimental.allocator : dispose, makeArray;
        auto alloc = Mallocator.instance;

        auto stack = alloc.makeArray!ProbsIndexed(n);
        // front: columns that need to be filled
        size_t smCounter;
        // back: used to fill columns
        size_t lgCounter = n - 1;

        foreach (i, p; probs)
        {
            auto sp = p * n;

            // 1 is the average probability and depending on the ratio, we either
            // need to add values to a block or remove values
            if (sp < 1)
                stack[smCounter++] = ProbsIndexed(sp, i);
            else
                stack[lgCounter--] = ProbsIndexed(sp, i);
        }

        // as long as there are elements in both stacks
        while (smCounter > 0 && lgCounter < n - 1)
        {
            auto sm = stack[--smCounter];
            auto lg = stack[++lgCounter];

            // fill the smaller, discrete value with the larger
            arr[sm.index] = AltPair(sm.prob, lg.index);

            // update larger & reinsert
            lg.prob += sm.prob - 1;

            if (lg.prob < 1)
                stack[smCounter++] = lg;
            else
                stack[lgCounter--] = lg;
        }

        // do cleanup
        for (auto i = lgCounter + 1; i < n; i++)
        {
            arr[stack[i].index].prob = 1;
        }

        // only possible with numerical errors
        for (sizediff_t i = smCounter - 1; i >= 0; i--)
        {
            arr[stack[i].index].prob = 1;
        }

        alloc.dispose(stack);
    }

    /// Samples a value from the discrete distribution using a custom random generator
    size_t opCall(RNG)(ref RNG gen)
        if (isRandomEngine!RNG)
    {
        T u = gen.rand!T.fabs * arr.length;
        size_t j = cast(size_t) u;
        return (u - j <= arr[j].prob) ? j : arr[j].alt;
    }
}

unittest
{
    import mir.random.engine.xorshift;
    auto gen = Xorshift(42);

    auto probs = [1.0];
    auto ds = discrete(probs);

    // sample from the discrete distribution
    auto obs = new uint[probs.length];
    foreach (i; 0..100)
        obs[ds(gen)]++;

    assert(obs[0] == 100);
}

unittest
{
    import mir.random.engine.xorshift : Xorshift;
    auto gen = Xorshift(42);

    auto probs = [0.2, 0.2, 0.2, 0.2, 0.2];
    auto ds = discrete(probs);

    // sample from the discrete distribution
    auto obs = new uint[probs.length];
    foreach (i; 0..10_000)
        obs[ds(gen)]++;

    //assert(obs == [2001, 1991, 2015, 2012, 1981]);
}

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
NaiveDiscrete!T naiveDiscrete(T)(const(T)[] cdPoints)
{
    return NaiveDiscrete!T(cdPoints);
}

///
unittest
{
    import mir.random.engine.xorshift;
    auto gen = Xorshift(1);
    // 10%, 20%, 20%, 40%, 10%
    auto cdPoints = [0.1, 0.3, 0.5, 0.9, 1];
    auto ds = naiveDiscrete(cdPoints);

    // sample from the discrete distribution
    auto obs = new uint[cdPoints.length];
    foreach (i; 0..10_000)
        obs[ds(gen)]++;
}

/**
_Discrete distribution sampler that draws random values from a _discrete
distribution given an array of the respective cumulative density points.
`cdPoints` is an array of the cummulative sum over the probabilities
or counts of a _discrete distribution without a starting zero.

Complexity: O(log n) where n is the number of `cdPoints`.
*/
struct NaiveDiscrete(T)
    if (isNumeric!T)
{
    import mir.random;

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

    /// Samples a value from the discrete distribution using a custom random generator
    size_t opCall(RNG)(ref RNG gen)
        if (isRandomEngine!RNG)
    {
        import std.range : assumeSorted;
        static if (isFloatingPoint!T)
            T v = gen.rand!T.fabs * cdPoints[$-1];
        else
            T v = gen.randIndex!(Unsigned!T)(cdPoints[$-1]);
        return cdPoints.length - cdPoints.assumeSorted!"a < b".upperBound(v).length;
    }
}

// test with cumulative probs
unittest
{
    import mir.random.engine.xorshift : Xorshift;
    auto gen = Xorshift(42);

    // 10%, 20%, 20%, 40%, 10%
    auto cdPoints = [0.1, 0.3, 0.5, 0.9, 1];
    auto ds = naiveDiscrete(cdPoints);

    auto obs = new uint[cdPoints.length];
    foreach (i; 0..10_000)
        obs[ds(gen)]++;

    //assert(obs == [1030, 1964, 1968, 4087, 951]);
}

// test with cumulative count
unittest
{
    import mir.random.engine.xorshift : Xorshift;
    auto gen = Xorshift(42);

    // 1, 2, 1
    auto cdPoints = [1, 3, 4];
    auto ds = naiveDiscrete(cdPoints);

    auto obs = new uint[cdPoints.length];
    foreach (i; 0..10_000)
        obs[ds(gen)]++;

    //assert(obs == [2536, 4963, 2501]);
}

// test with zero probabilities
unittest
{
    import mir.random.engine.xorshift : Xorshift;
    auto gen = Xorshift(42);

    // 0, 1, 2, 0, 1
    auto cdPoints = [0, 1, 3, 3, 4];
    auto ds = naiveDiscrete(cdPoints);

    auto obs = new uint[cdPoints.length];
    foreach (i; 0..10_000)
        obs[ds(gen)]++;

    assert(obs[3] == 0);
}
