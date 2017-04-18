/**
Random number generators.

Authors: Sebastian Wilzbach, Ilya Yaroshenko

License: $(LINK2 http://boost.org/LICENSE_1_0.txt, Boost License 1.0).
*/
module mir.random;

import std.random: rndGen, Random, uniform;
import mir.ndslice.slice: Slice;

/*
Checks whether a type is Slice.
/**/
template isSlice(T)
{
    import std.traits: TemplateOf;
    enum bool isSlice = __traits(compiles, __traits(isSame, TemplateOf!(T), Slice));
}

// init distribution with random method and args
auto rinit(alias Random, T, Args...)(T arr, Args args)
if (!isSlice!T)
{
    foreach (ref el; arr)
    {
        el = Random(args);
    }
    return arr;
}

// init slice distribution
auto rinit(alias Random, size_t N, Range, Args...)(auto ref Slice!(N, Range) slice, Args args)
{
    import mir.ndslice.selection: byElement;
    auto il = byElement(slice);
    rinit!Random(il, args);
    return slice;
}

// allocate and build distribution with args
auto rarray(alias Random, size_t, Args...)(size_t n, Args args)
{
    import std.traits : ReturnType;
    //alias T = ReturnType!(Random.init.front);
    alias T = uint;
    T[] arr = new T[n];
    return rinit!Random(arr, args);
}

unittest
{
    import mir.ndslice.slice: slice;
    rndGen.seed(42);

    assert(rarray!bernoulli(10, 0.5) == [1, 0, 0, 1, 0, 0, 0, 0, 1, 1]);
    assert(rarray!bernoulli(10, 0.5, rndGen) == [1, 1, 1, 1, 0, 1, 0, 1, 0, 0]);

    auto arr = new int[10];
    assert(rinit!bernoulli(arr, 0.5) == [1, 1, 1, 1, 0, 1, 0, 1, 0, 0]);
    assert(rinit!bernoulli(slice!int(2, 5), 0.5) == [[1, 1, 0, 0, 0], [0, 1, 1, 1, 0]]);
}

auto randRange(alias Random, Args...)(Args args)
{
    static struct RandRange
    {
        Args args;
        static bool empty = false;

        this(Args args)
        {
            this.args = args;
        }

        ///
        auto front() @property
        {
            return Random(args);
        }

        ///
        void popFront() @safe pure nothrow @nogc
        {
            // TODO
        }

        ///
        typeof(this) save() @safe pure nothrow @nogc
        {
            return this;
        }

        ///
        //bool opEquals()(auto ref const typeof(this) y) const pure nothrow @safe @nogc
        //{
           //return p == y.p;
        //}

        void reset()
        {

        }
    }
    return RandRange(args);
}

// support ranges
@safe unittest
{
    import std.algorithm: equal;
    import std.range: takeExactly;

    rndGen.seed(42);

    auto range = randRange!bernoulli(0.5);
    assert(range.takeExactly(10).equal([1, 0, 0, 1, 0, 0, 0, 0, 1, 1]));
}

uint bernoulli(RGen)(double p = 0.5, ref RGen gen = rndGen)
{
    assert(0 <= p && p <= 1, "Invalid probability");
    auto val = uniform(0.0L, 1.0L, gen);
    return cast(uint) (val <= p);
}

unittest
{
    import mir.stat: stat;
    import std.range: takeExactly;

    auto range = randRange!bernoulli(0.5).takeExactly(10_000);
    import std.math: approxEqual;
    assert(approxEqual(range.stat.mean, 0.5, 0.1));
    assert(approxEqual(range.stat.var, 0.25, 0.1));
}

/*
WIP - Currently only
$(WEB https://en.wikipedia.org/wiki/Box%E2%80%93Muller_transform, Box Muller-transform)
References:
    Butcher, J. C. "Random sampling from the normal distribution."
    The Computer Journal 3.4 (1961): 251-253.
    http://comjnl.oxfordjournals.org/content/3/4/251.full.pdf
*/
auto normal(RGen)(double mu, double sigma, ref RGen gen = rndGen)
{
    import std.math: PI, log, cos, sin, sqrt;
    static double epsilon = double.min_normal;
	static double two_pi = 2.0 * PI;

	static double z0, z1;
	static bool generate;
	generate = !generate;

	if (!generate)
	   return z1 * sigma + mu;

	double u1, u2;
	do
	 {
	   u1 = uniform(0.0L, 1.0L, gen);
	   u2 = uniform(0.0L, 1.0L, gen);
	 }
	while ( u1 <= epsilon );

	z0 = sqrt(-2.0 * log(u1)) * cos(two_pi * u2);
	z1 = sqrt(-2.0 * log(u1)) * sin(two_pi * u2);
	return z0 * sigma + mu;
}

unittest
{
    import std.range: takeExactly;
    import mir.stat: stat;

    auto range = randRange!normal(0, 1).takeExactly(100_000);
    import std.math: approxEqual;
    assert(range.stat.mean.approxEqual(0.0, 1e-2, 1e-2));
    assert(range.stat.var.approxEqual(1.0, 0.1));
}
