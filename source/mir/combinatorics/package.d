/**
This module contains various combinatorics algorithms.

Authors: Sebastian Wilzbach, Ilya Yaroshenko

License: $(LINK2 http://boost.org/LICENSE_1_0.txt, Boost License 1.0).
*/
module mir.combinatorics;

import std.range.primitives: isRandomAccessRange, hasLength;

///
unittest
{
    import std.algorithm.comparison: equal;

    assert([0, 1].permutations.equal!equal([[0, 1], [1, 0]]));
    assert([0, 1].cartesianPower(2).equal!equal([[0, 0], [0, 1], [1, 0], [1, 1]]));
    assert([0, 1].combinations(2).equal!equal([[0, 1]]));
    assert([0, 1].combinationsRepeat(2).equal!equal([[0, 0], [0, 1], [1, 1]]));
}

/**
Checks whether we can do basic arithmetic operations, comparisons, modulo and
assign values to the type.
*/
private template isArithmetic(R)
{
    enum bool isArithmetic = is(typeof(
    (inout int = 0)
    {
        R r = 1;
        R test = (r * r / r + r - r) % r;
        if(r < r && r > r) {}
    }));
}

/**
Checks whether we can do basic arithmetic operations, comparison and modulo
between two types. R needs to support item assignment of S (it includes S).
Both R and S need to be arithmetic types themselves.
*/
private template isArithmetic(R, S)
{
    enum bool isArithmetic = is(typeof(
    (inout int = 0)
    {
        if(isArithmetic!R && isArithmetic!S) {}
        S s = 1;
        R r = 1;
        R test = r * s + r * s;
        R test2 = r / s + r / s;
        R test3 = r - s + r - s;
        R test4 = r % s + r % s;
        if(r < s && s > r) {}
        if(s < r && r > s) {}
    }));
}

/**
Computes the $(WEB en.wikipedia.org/wiki/Binomial_coefficient, binomial coefficient)
of n and k.
It is also known as "n choose k" or more formally as `_n!/_k!(_n-_k)`.
If a fixed-length integer type is used and an overflow happens, `0` is returned.

Uses the generalized binomial coefficient for negative integers and floating
point number

Params:
    n = arbitrary arithmetic type
    k = arbitrary arithmetic type

Returns:
    Binomial coefficient
*/
R binomial(R = ulong, T)(T n, T k)
    if (isArithmetic!(R, T) &&
        ((is(typeof(T.min < 0)) && is(typeof(T.init & 1))) || !is(typeof(T.min < 0))) )
{
    R result = 1;

    enum hasMinProperty = is(typeof(T.min < 0));
    // only add negative support if possible
    static if ((hasMinProperty && T.min < 0) || !hasMinProperty)
    {
        if (n < 0)
        {
            if (k >= 0)
            {
                return (k & 1 ? -1 : 1) * binomial!(R, T)(-n + k-1, k);
            }
            else if (k <= n)
            {
                return ((n-k) & 1 ? -1 : 1) * binomial!(R, T)(-k-1, n-k);
            }
        }
        if (k < 0)
        {
            result = 0;
            return result;
        }
    }

    if (k > n)
    {
        result = 0;
        return result;
    }
    if (k > n - k)
    {
        k = n - k;
    }
    // make a copy of n (could be a custom type)
    for (T i = 1, m = n; i <= k; i++, m--)
    {
        // check whether an overflow can happen
        // hasMember!(Result, "max") doesn't work with dmd2.068 and ldc 0.17
        static if (is(typeof(0 > R.max)))
        {
            if (result / i > R.max / m) return 0;
            result = result / i * m + result % i * m / i;
        }
        else
        {
            result = result * m / i;
        }
    }
    return result;
}

///
pure unittest
{
    assert(binomial(5, 2) == 10);
    assert(binomial(6, 4) == 15);
    assert(binomial(3, 1) == 3);

    import std.bigint: BigInt;
    assert(binomial!BigInt(1000, 10) == BigInt("263409560461970212832400"));
}

pure nothrow @safe @nogc unittest
{
    assert(binomial(5, 1) == 5);
    assert(binomial(5, 0) == 1);
    assert(binomial(1, 2) == 0);
    assert(binomial(1, 0) == 1);
    assert(binomial(1, 1) == 1);
    assert(binomial(2, 1) == 2);
    assert(binomial(2, 1) == 2);

    // negative
    assert(binomial!long(-5, 3) == -35);
    assert(binomial!long(5, -3) == 0);
}

unittest
{
    import std.bigint;

    // test larger numbers
    assert(binomial(100, 10) == 17_310_309_456_440);
    assert(binomial(999, 5) == 82_09_039_793_949);
    assert(binomial(300, 10) == 1_398_320_233_241_701_770LU);
    assert(binomial(300LU, 10LU) == 1_398_320_233_241_701_770LU);

    // test overflow
    assert(binomial(500, 10) == 0);

    // all parameters as custom types
    BigInt n = 1010, k = 9;
    assert(binomial!BigInt(n, k) == BigInt("2908077120956865974260"));

    // negative
    assert(binomial!BigInt(-5, 3) == -35);
    assert(binomial!BigInt(5, -3) == 0);
    assert(binomial!BigInt(-5, -7) == 15);
}

/**
Creates a projection of a generalized `Collection` range for the numeric case
case starting from `0` onto a custom `range` of any type.

Params:
    collection = range to be projected from
    range = random access range to be projected to

Returns:
    Range with a projection to range for every element of collection

See_Also:
    $(LREF permutations), $(LREF cartesianPower), $(LREF combinations),
    $(LREF combinationsRepeat)
*/
IndexedRoR!(Collection, Range) indexedRoR(Collection, Range)(Collection c, Range r)
if (isRandomAccessRange!Range)
{
    return IndexedRoR!(Collection, Range)(c, r);
}

/// ditto
struct IndexedRoR(Collection, Range)
if (isRandomAccessRange!Range)
{
    import std.range : indexed, isForwardRange;

    private Collection c;
    private Range r;

    ///
    this(Collection collection, Range range)
    {
        this.c = collection;
        this.r = range;
    }

    ///
    auto ref front() @property
    {
        return r.indexed(c.front);
    }

    ///
    void popFront()
    {
        c.popFront;
    }

    ///
    bool empty() @property const
    {
        return c.empty;
    }

    static if(hasLength!Collection)
    {
        ///
        @property size_t length() const
        {
            return c.length;
        }
    }

    static if(isForwardRange!Collection)
    {
        ///
        typeof(this) save() @property
        {
            return IndexedRoR!(Collection, Range)(c.save, r);
        }
    }
}

///
@safe pure nothrow unittest
{
    import std.algorithm.comparison: equal;

    auto perms = 2.permutations;
    assert(perms.save.equal!equal([[0, 1], [1, 0]]));

    auto projection = perms.indexedRoR([1, 2]);
    assert(projection.equal!equal([[1, 2], [2, 1]]));
}

///
unittest
{
    import std.algorithm.comparison: equal;
    import std.range: only;

    auto projectionD = 2.permutations.indexedRoR("ab"d);
    assert(projectionD.equal!equal([['a', 'b'], ['b', 'a']]));

    auto projectionC = 2.permutations.indexedRoR(only('a', 'b'));
    assert(projectionC.equal!equal([['a', 'b'], ['b', 'a']]));
}

@safe pure nothrow unittest
{
    import std.algorithm.comparison: equal;
    import std.range: dropOne;

    auto perms = 2.permutations;
    auto projection = perms.indexedRoR([1, 2]);
    assert(projection.length == 2);

    // can save
    assert(projection.save.dropOne.front.equal([2, 1]));
    assert(projection.front.equal([1, 2]));
}

@safe nothrow @nogc unittest
{
    import std.algorithm.comparison: equal;
    static perms = 2.permutations;
    static immutable projectionArray = [1, 2];
    auto projection = perms.indexedRoR(projectionArray);

    static immutable result = [[1, 2], [2, 1]];
    assert(projection.equal!equal(result));
}

/**
Lazily computes all _permutations of `r` using $(WEB
en.wikipedia.org/wiki/Heap%27s_algorithm, Heap's algorithm).

While generating a new item is in `O(k)` (amortized `O(1)`),
the number of permutations is `|n|!`.

Params:
    n = number of elements (`|r|`)
    r = $(REF_ALTTEXT Random access range, isRandomAccessRange, std, range, primitives)
    alloc = custom Allocator

Returns:
    Forward range, which yields the permutations

See_Also:
    $(LREF Permutations)
*/
Permutations permutations(size_t n) @safe pure nothrow
{
    assert(n, "must have at least one item");
    return Permutations(new uint[n-1], new uint[n]);
}

/// ditto
IndexedRoR!(Permutations, Range) permutations(Range)(Range r) @safe pure nothrow
if (isRandomAccessRange!Range)
{
    return permutations(r.length).indexedRoR(r);
}

/// ditto
Permutations makePermutations(Allocator)(auto ref Allocator alloc, size_t n)
{
    assert(n, "must have at least one item");
    import std.experimental.allocator: makeArray;
    auto state = alloc.makeArray!uint(n - 1);
    auto indices = alloc.makeArray!uint(n);
    return Permutations(state, indices);
}

/**
Lazy Forward range of permutations using $(WEB
en.wikipedia.org/wiki/Heap%27s_algorithm, Heap's algorithm).

It always generates the permutations from 0 to `n - 1`,
use $(LREF indexedRoR) to map it to your range.

Generating a new item is in `O(k)` (amortized `O(1)`),
the total number of elements is `n^k`.

See_Also:
    $(LREF permutations), $(LREF makePermutations)
*/
struct Permutations
{
    private uint[] indices, state;
    private bool _empty;
    size_t _max_states = 1, _pos;

    /**
    state should have the length of `n - 1`,
    whereas the length of indices should be `n`
    */
    this(uint[] state, uint[] indices) @safe pure nothrow @nogc
    in
    {
        assert(state.length + 1 == indices.length);
    }
    body
    {
        // iota
        foreach(uint i, ref index; indices)
            index = i;
        state[] = 0;

        this.indices = indices;
        this.state = state;

        _empty = indices.length == 0;

        // factorial
        foreach (i; 1..indices.length + 1)
            _max_states *= i;
    }

    ///
    @property const(uint)[] front() @safe pure nothrow @nogc
    {
        return indices;
    }

    ///
    void popFront() @safe pure nothrow @nogc
    {
        import std.algorithm.mutation : swapAt;

        assert(!empty);
        _pos++;

        for (uint h = 0;;h++)
        {
            if (h+2 > indices.length)
            {
                _empty = true;
                break;
            }

            if (h & 1)
                indices.swapAt(0, h+1);
            else
                indices.swapAt(state[h], h+1);

            if (state[h] == h+1)
            {
                state[h] = 0;
                continue;
            }
            state[h]++;
            break;
        }
    }

    ///
    @property bool empty() @safe pure nothrow @nogc const
    {
        return _empty;
    }

    ///
    @property size_t length() @safe pure nothrow @nogc const
    {
        return _max_states - _pos;
    }

    ///
    @property Permutations save() @safe pure nothrow
    {
        typeof(this) c = this;
        c.indices = indices.dup;
        c.state = state.dup;
        return c;
    }
}

///
pure @safe nothrow unittest
{
    import std.algorithm.comparison : equal;
    import std.range : iota;

    auto expectedRes = [[0, 1, 2],
         [1, 0, 2],
         [2, 0, 1],
         [0, 2, 1],
         [1, 2, 0],
         [2, 1, 0]];

    auto r = iota(3);
    auto rp = permutations(r.length).indexedRoR(r);
    assert(rp.equal!equal(expectedRes));

    // direct style
    auto rp2 = iota(3).permutations;
    assert(rp2.equal!equal(expectedRes));
}

///
static if (__VERSION__ > 2069) @nogc unittest
{
    import std.algorithm: equal;
    import std.range : iota;

    import std.experimental.allocator.mallocator;

    static immutable expected2 = [[0, 1], [1, 0]];
    auto r = iota(2);
    auto rp = makePermutations(Mallocator.instance, r.length);
    assert(rp.indexedRoR(r).equal!equal(expected2));
    dispose(Mallocator.instance, rp);
}

pure @safe nothrow unittest
{
    // is copyable?
    import std.algorithm: equal;
    import std.range: iota, dropOne;
    auto a = iota(2).permutations;
    assert(a.front.equal([0, 1]));
    assert(a.save.dropOne.front.equal([1, 0]));
    assert(a.front.equal([0, 1]));

    // length
    assert(1.permutations.length == 1);
    assert(2.permutations.length == 2);
    assert(3.permutations.length == 6);
    assert(4.permutations.length == 24);
    assert(10.permutations.length == 3628800);
}

static if (__VERSION__ > 2069) unittest
{
    // check invalid
    import std.exception: assertThrown;
    import core.exception: AssertError;
    import std.experimental.allocator.mallocator: Mallocator;

    assertThrown!AssertError(0.permutations);
    assertThrown!AssertError(Mallocator.instance.makePermutations(0));
}

/**
Disposes a Permutations object. It destroys and then deallocates the
Permutations object pointed to by a pointer.
It is assumed the respective entities had been allocated with the same allocator.

Params:
    alloc = Custom allocator
    perm = Permutations object

See_Also:
    $(LREF makePermutations)
*/
void dispose(Allocator)(auto ref Allocator alloc, auto ref Permutations perm)
{
    import std.experimental.allocator: dispose;
    dispose(alloc, perm.state);
    dispose(alloc, perm.indices);
}

/**
Lazily computes the Cartesian power of `r` with itself
for a number of repetitions `D repeat`.
If the input is sorted, the product is in lexicographic order.

While generating a new item is in `O(k)` (amortized `O(1)`),
the total number of elements is `n^k`.

Params:
    n = number of elements (`|r|`)
    r = $(REF_ALTTEXT Random access range, isRandomAccessRange, std, range, primitives)
    repeat = number of repetitions
    alloc = custom Allocator

Returns:
    Forward range, which yields the product items

See_Also:
    $(LREF CartesianPower)
*/
CartesianPower cartesianPower(size_t n, size_t repeat = 1) @safe pure nothrow
in
{
    assert(repeat >= 1, "Invalid number of repetitions");
}
body
{
    return CartesianPower(n, new uint[repeat]);
}

/// ditto
IndexedRoR!(CartesianPower, Range) cartesianPower(Range)(Range r, size_t repeat = 1)
if (isRandomAccessRange!Range)
in
{
    assert(repeat >= 1, "Invalid number of repetitions");
}
body
{
    return cartesianPower(r.length, repeat).indexedRoR(r);
}

/// ditto
CartesianPower makeCartesianPower(Allocator)(auto ref Allocator alloc, size_t n, size_t repeat)
in
{
    assert(repeat >= 1, "Invalid number of repetitions");
}
body
{
    import std.experimental.allocator: makeArray;
    return CartesianPower(n, alloc.makeArray!uint(repeat));
}

/**
Lazy Forward range of Cartesian Power.
It always generates Cartesian Power from 0 to `n - 1`,
use $(LREF indexedRoR) to map it to your range.

Generating a new item is in `O(k)` (amortized `O(1)`),
the total number of elements is `n^k`.

See_Also:
    $(LREF cartesianPower), $(LREF makeCartesianPower)
*/
struct CartesianPower
{

private:
    uint[] _state;
    uint n;
    size_t _max_states, _pos;

public:

    /// state should have the length of `repeat`
    this(size_t n, uint[] state) @safe pure nothrow @nogc
    {
        assert(state.length >= 1, "Invalid number of repetitions");

        import std.math: pow;
        this.n = cast(uint) n;
        this._state = state;

        _max_states = pow(n, state.length);
    }

    ///
    @property const(uint)[] front() @safe pure nothrow @nogc
    {
        return _state;
    }

    ///
    void popFront() @safe pure nothrow @nogc
    {
        assert(!empty);
        _pos++;

        /*
        * Bitwise increment - starting from back
        * It works like adding 1 in primary school arithmetic.
        * If a block has reached the number of elements, we reset it to
        * 0, and continue to increment, e.g. for n = 2:
        *
        * [0, 0, 0] -> [0, 0, 1]
        * [0, 1, 1] -> [1, 0, 0]
        */
        foreach_reverse (i, ref el; _state)
        {
            ++el;
            if (el < n)
                break;

            el = 0;
        }
    }

    ///
    @property size_t length() @safe pure nothrow @nogc const
    {
        return _max_states - _pos;
    }

    ///
    @property bool empty() @safe pure nothrow @nogc const
    {
        return _pos == _max_states;
    }

    ///
    @property CartesianPower save() @safe pure nothrow
    {
        typeof(this) c = this;
        c._state = _state.dup;
        return c;
    }
}

///
pure nothrow @safe unittest
{
    import std.algorithm: equal;
    import std.range: iota;
    assert(iota(2).cartesianPower.equal!equal([[0], [1]]));
    assert(iota(2).cartesianPower(2).equal!equal([[0, 0], [0, 1], [1, 0], [1, 1]]));

    auto three_nums_two_bins = [[0, 0], [0, 1], [0, 2], [1, 0], [1, 1], [1, 2], [2, 0], [2, 1], [2, 2]];
    assert(iota(3).cartesianPower(2).equal!equal(three_nums_two_bins));

    assert("AB"d.cartesianPower(2).equal!equal(["AA"d, "AB"d, "BA"d, "BB"d]));
}

///
static if (__VERSION__ > 2069) @nogc unittest
{
    import std.algorithm: equal;
    import std.range: iota;

    import std.experimental.allocator.mallocator: Mallocator;
    auto alloc = Mallocator.instance;

    static immutable expected2r2 = [[0, 0], [0, 1], [1, 0], [1, 1]];
    auto r = iota(2);
    auto rc = alloc.makeCartesianPower(r.length, 2);
    assert(rc.indexedRoR(r).equal!equal(expected2r2));
    alloc.dispose(rc);
}

pure nothrow @safe unittest
{
    import std.algorithm: equal, map;
    import std.array: array;
    import std.range: iota, dropOne;

    assert(iota(0).cartesianPower.length == 0);
    assert("AB"d.cartesianPower(3).equal!equal(["AAA"d, "AAB"d, "ABA"d, "ABB"d, "BAA"d, "BAB"d, "BBA"d, "BBB"d]));
    auto expected = ["AA"d, "AB"d, "AC"d, "AD"d,
                     "BA"d, "BB"d, "BC"d, "BD"d,
                     "CA"d, "CB"d, "CC"d, "CD"d,
                     "DA"d, "DB"d, "DC"d, "DD"d];
    assert("ABCD"d.cartesianPower(2).equal!equal(expected));
    // verify with array too
    assert("ABCD"d.cartesianPower(2).map!array.array == expected);

    assert(iota(2).cartesianPower.front.equal([0]));

    // is copyable?
    auto a = iota(2).cartesianPower;
    assert(a.front.equal([0]));
    assert(a.save.dropOne.front.equal([1]));
    assert(a.front.equal([0]));

    // test length shrinking
    auto d = iota(2).cartesianPower;
    assert(d.length == 2);
    d.popFront;
    assert(d.length == 1);
}

static if (__VERSION__ > 2069) unittest
{
    // check invalid
    import std.exception: assertThrown;
    import core.exception: AssertError;
    import std.experimental.allocator.mallocator : Mallocator;

    assertThrown!AssertError(0.cartesianPower(0));
    assertThrown!AssertError(Mallocator.instance.makeCartesianPower(0, 0));
}

// length
pure nothrow @safe unittest
{
    assert(1.cartesianPower(1).length == 1);
    assert(1.cartesianPower(2).length == 1);
    assert(2.cartesianPower(1).length == 2);
    assert(2.cartesianPower(2).length == 4);
    assert(2.cartesianPower(3).length == 8);
    assert(3.cartesianPower(1).length == 3);
    assert(3.cartesianPower(2).length == 9);
    assert(3.cartesianPower(3).length == 27);
    assert(3.cartesianPower(4).length == 81);
    assert(4.cartesianPower(10).length == 1048576);
    assert(14.cartesianPower(7).length == 105413504);
}

/**
Disposes a CartesianPower object. It destroys and then deallocates the
CartesianPower object pointed to by a pointer.
It is assumed the respective entities had been allocated with the same allocator.

Params:
    alloc = Custom allocator
    perm = CartesianPower object

See_Also:
    $(LREF makeCartesianPower)
*/
void dispose(Allocator)(auto ref Allocator alloc, auto ref CartesianPower cartesianPower)
{
    import std.experimental.allocator: dispose;
    dispose(alloc, cartesianPower._state);
}

/**
Lazily computes all k-combinations of `r`.
Imagine this as the $(LREF cartesianPower) filtered for only strictly ordered items.

While generating a new combination is in `O(k)`,
the number of combinations is `binomial(n, k)`.

Params:
    n = number of elements (`|r|`)
    r = $(REF_ALTTEXT Random access range, isRandomAccessRange, std, range, primitives)
    k = number of combinations
    alloc = custom Allocator

Returns:
    Forward range, which yields the k-combinations items

See_Also:
    $(LREF Combinations)
*/
Combinations combinations(size_t n, size_t k = 1) @safe pure nothrow
in
{
    assert(k >= 1, "Invalid number of combinations");
}
body
{
    return Combinations(n, new uint[k]);
}

/// ditto
IndexedRoR!(Combinations, Range) combinations(Range)(Range r, uint k = 1)
if (isRandomAccessRange!Range)
in
{
    assert(k >= 1, "Invalid number of combinations");
}
body
{
    return combinations(r.length, k).indexedRoR(r);
}

/// ditto
Combinations makeCombinations(Allocator)(auto ref Allocator alloc, size_t n, size_t repeat)
in
{
    assert(repeat >= 1, "Invalid number of repetitions");
}
body
{
    import std.experimental.allocator: makeArray;
    return Combinations(cast(uint) n, alloc.makeArray!uint(cast(uint) repeat));
}

/**
Lazy Forward range of Combinations.
It always generates combinations from 0 to `n - 1`,
use $(LREF indexedRoR) to map it to your range.

Generating a new combination is in `O(k)`,
the number of combinations is `binomial(n, k)`.

See_Also:
    $(LREF combinations), $(LREF makeCombinations)
*/
struct Combinations
{

private:
    uint[] state;
    uint n;
    size_t max_states, pos;

public:

    /// state should have the length of `repeat`
    this(size_t n, uint[] state) @safe pure nothrow @nogc
    {
        import std.range: iota;

        uint repeatLen = cast(uint) state.length;
        this.n = cast(uint) n;
        this.max_states = cast(size_t) binomial(n, repeatLen);
        this.state = state;

        // set initial state and calculate max possibilities
        if (n > 0)
        {
            // skip first duplicate
            if (n > 1 && repeatLen > 1)
            {
                auto iotaResult = iota(repeatLen);
                foreach(i, ref el; state)
                {
                    el = iotaResult[i];
                }
            }
        }
    }

    ///
    @property const(uint)[] front() @safe pure nothrow @nogc
    {
        return state;
    }

    ///
    void popFront() @safe pure nothrow @nogc
    {
        assert(!empty);
        pos++;
        // we might have bumped into the end state now
        if (empty) return;

        immutable repeat = cast(uint) state.length;

        // Behaves like: do _getNextState();  while(!_state.isStrictlySorted);
        uint i = repeat - 1;
        /* Go from the back to next settable block
        * - A must block must be lower than it's previous
        * - A state i is not settable if it's maximum height is reached
        *
        * Think of it as a backwords search on state with
        * iota(_repeat + d, _repeat + d) as search mask.
        * (d = _nrElements -_repeat)
        *
        * As an example n = 3, r = 2, iota is [1, 2] and hence:
        * [0, 1] -> i = 2
        * [0, 2] -> i = 1
        */
        while (state[i] == n - repeat + i)
        {
            i--;
        }
        state[i] = state[i] + 1;

        /* Starting from our changed block, we need to take the change back
        * to the end of the state array and update them by their new diff.
        * [0, 1, 4] -> [0, 2, 3]
        * [0, 3, 4] -> [1, 2, 3]
        */
        for (uint j = i + 1; j < repeat; j++)
        {
            state[j] = state[i] + j - i;
        }
    }

    ///
    @property size_t length() @safe pure nothrow @nogc const
    {
        return max_states - pos;
    }

    ///
    @property bool empty() @safe pure nothrow @nogc const
    {
        return pos == max_states;
    }

    ///
    @property Combinations save() @safe pure nothrow
    {
        typeof(this) c = this;
        c.state = state.dup;
        return c;
    }
}

///
pure nothrow @safe unittest
{
    import std.algorithm: equal;
    import std.range: iota;
    import std.stdio;
    assert(iota(3).combinations(2).equal!equal([[0, 1], [0, 2], [1, 2]]));
    assert("AB"d.combinations(2).equal!equal(["AB"d]));
    assert("ABC"d.combinations(2).equal!equal(["AB"d, "AC"d, "BC"d]));
}

///
static if (__VERSION__ > 2069) @nogc unittest
{
    import std.algorithm: equal;
    import std.range: iota;

    import std.experimental.allocator.mallocator;
    auto alloc = Mallocator.instance;

    static immutable expected3r2 = [[0, 1], [0, 2], [1, 2]];
    auto r = iota(3);
    auto rc = alloc.makeCombinations(r.length, 2);
    assert(rc.indexedRoR(r).equal!equal(expected3r2));
    alloc.dispose(rc);
}

pure nothrow @safe unittest
{
    import std.algorithm: equal, map;
    import std.array: array;
    import std.range: iota, dropOne;

    assert(iota(0).combinations.length == 0);
    assert(iota(2).combinations.equal!equal([[0], [1]]));

    auto expected = ["AB"d, "AC"d, "AD"d, "BC"d, "BD"d, "CD"d];
    assert("ABCD"d.combinations(2).equal!equal(expected));
    // verify with array too
    assert("ABCD"d.combinations(2).map!array.array == expected);
    assert(iota(2).combinations.front.equal([0]));

    // is copyable?
    auto a = iota(2).combinations;
    assert(a.front.equal([0]));
    assert(a.save.dropOne.front.equal([1]));
    assert(a.front.equal([0]));

    // test length shrinking
    auto d = iota(2).combinations;
    assert(d.length == 2);
    d.popFront;
    assert(d.length == 1);

    // test larger combinations
    auto expected5 = [[0, 1, 2], [0, 1, 3], [0, 1, 4],
                      [0, 2, 3], [0, 2, 4], [0, 3, 4],
                      [1, 2, 3], [1, 2, 4], [1, 3, 4],
                      [2, 3, 4]];
    assert(iota(5).combinations(3).equal!equal(expected5));
    assert(iota(4).combinations(3).equal!equal([[0, 1, 2], [0, 1, 3], [0, 2, 3], [1, 2, 3]]));
    assert(iota(3).combinations(3).equal!equal([[0, 1, 2]]));
    assert(iota(2).combinations(3).length == 0);
    assert(iota(1).combinations(3).length == 0);

    assert(iota(3).combinations(2).equal!equal([[0, 1], [0, 2], [1, 2]]));
    assert(iota(2).combinations(2).equal!equal([[0, 1]]));
    assert(iota(1).combinations(2).length == 0);

    assert(iota(1).combinations(1).equal!equal([[0]]));
}

pure nothrow @safe unittest
{
    // test larger combinations
    import std.algorithm: equal;
    import std.range: iota;

    auto expected6r4 = [[0, 1, 2, 3], [0, 1, 2, 4], [0, 1, 2, 5],
                        [0, 1, 3, 4], [0, 1, 3, 5], [0, 1, 4, 5],
                        [0, 2, 3, 4], [0, 2, 3, 5], [0, 2, 4, 5],
                        [0, 3, 4, 5], [1, 2, 3, 4], [1, 2, 3, 5],
                        [1, 2, 4, 5], [1, 3, 4, 5], [2, 3, 4, 5]];
    assert(iota(6).combinations(4).equal!equal(expected6r4));

    auto expected6r3 = [[0, 1, 2], [0, 1, 3], [0, 1, 4], [0, 1, 5],
                        [0, 2, 3], [0, 2, 4], [0, 2, 5], [0, 3, 4],
                        [0, 3, 5], [0, 4, 5], [1, 2, 3], [1, 2, 4],
                        [1, 2, 5], [1, 3, 4], [1, 3, 5], [1, 4, 5],
                        [2, 3, 4], [2, 3, 5], [2, 4, 5], [3, 4, 5]];
    assert(iota(6).combinations(3).equal!equal(expected6r3));

    auto expected6r2 = [[0, 1], [0, 2], [0, 3], [0, 4], [0, 5],
                        [1, 2], [1, 3], [1, 4], [1, 5], [2, 3],
                        [2, 4], [2, 5], [3, 4], [3, 5], [4, 5]];
    assert(iota(6).combinations(2).equal!equal(expected6r2));

    auto expected7r5 = [[0, 1, 2, 3, 4], [0, 1, 2, 3, 5], [0, 1, 2, 3, 6],
                        [0, 1, 2, 4, 5], [0, 1, 2, 4, 6], [0, 1, 2, 5, 6],
                        [0, 1, 3, 4, 5], [0, 1, 3, 4, 6], [0, 1, 3, 5, 6],
                        [0, 1, 4, 5, 6], [0, 2, 3, 4, 5], [0, 2, 3, 4, 6],
                        [0, 2, 3, 5, 6], [0, 2, 4, 5, 6], [0, 3, 4, 5, 6],
                        [1, 2, 3, 4, 5], [1, 2, 3, 4, 6], [1, 2, 3, 5, 6],
                        [1, 2, 4, 5, 6], [1, 3, 4, 5, 6], [2, 3, 4, 5, 6]];
    assert(iota(7).combinations(5).equal!equal(expected7r5));
}

// length
pure nothrow @safe unittest
{
    assert(1.combinations(1).length == 1);
    assert(1.combinations(2).length == 0);
    assert(2.combinations(1).length == 2);
    assert(2.combinations(2).length == 1);
    assert(2.combinations(3).length == 0);
    assert(3.combinations(1).length == 3);
    assert(3.combinations(2).length == 3);
    assert(3.combinations(3).length == 1);
    assert(3.combinations(4).length == 0);
    assert(4.combinations(10).length == 0);
    assert(14.combinations(11).length == 364);
    assert(20.combinations(7).length == 77520);
    assert(30.combinations(10).length == 30045015);
    assert(30.combinations(15).length == 155117520);
}

static if (__VERSION__ > 2069) unittest
{
    // check invalid
    import std.exception: assertThrown;
    import core.exception: AssertError;
    import std.experimental.allocator.mallocator: Mallocator;

    assertThrown!AssertError(0.combinations(0));
    assertThrown!AssertError(Mallocator.instance.makeCombinations(0, 0));
}

/**
Disposes a Combinations object. It destroys and then deallocates the
Combinations object pointed to by a pointer.
It is assumed the respective entities had been allocated with the same allocator.

Params:
    alloc = Custom allocator
    perm = Combinations object

See_Also:
    $(LREF makeCombinations)
*/
void dispose(Allocator)(auto ref Allocator alloc, auto ref Combinations combs)
{
    import std.experimental.allocator: dispose;
    dispose(alloc, combs.state);
}

/**
Lazily computes all k-combinations of `r` with repetitions.
A k-combination with repetitions, or k-multicombination,
or multisubset of size k from a set S is given by a sequence of k
not necessarily distinct elements of S, where order is not taken into account.
Imagine this as the cartesianPower filtered for only ordered items.

While generating a new combination with repeats is in `O(k)`,
the number of combinations with repeats is `binomial(n + k - 1, k)`.

Params:
    n = number of elements (`|r|`)
    r = $(REF_ALTTEXT Random access range, isRandomAccessRange, std, range, primitives)
    k = number of combinations
    alloc = custom Allocator

Returns:
    Forward range, which yields the k-multicombinations items

See_Also:
    $(LREF CombinationsRepeat)
*/
CombinationsRepeat combinationsRepeat(size_t n, size_t k = 1) @safe pure nothrow
in
{
    assert(k >= 1, "Invalid number of combinations");
}
body
{
    return CombinationsRepeat(n, new uint[k]);
}

/// ditto
IndexedRoR!(CombinationsRepeat, Range) combinationsRepeat(Range)(Range r, size_t k = 1)
if (isRandomAccessRange!Range)
in
{
    assert(k >= 1, "Invalid number of combinations");
}
body
{
    return combinationsRepeat(r.length, k).indexedRoR(r);
}

/// ditto
CombinationsRepeat makeCombinationsRepeat(Allocator)(auto ref Allocator alloc, size_t n, size_t repeat)
in
{
    assert(repeat >= 1, "Invalid number of repetitions");
}
body
{
    import std.experimental.allocator: makeArray;
    return CombinationsRepeat(n, alloc.makeArray!uint(repeat));
}

/**
Lazy Forward range of combinations with repeats.
It always generates combinations with repeats from 0 to `n - 1`,
use $(LREF indexedRoR) to map it to your range.

Generating a new combination with repeats is in `O(k)`,
the number of combinations with repeats is `binomial(n, k)`.

See_Also:
    $(LREF combinationsRepeat), $(LREF makeCombinationsRepeat)
*/
struct CombinationsRepeat
{

private:
    uint[] state;
    uint n;

    size_t max_states, pos;

public:

    /// state should have the length of `repeat`
    this(size_t n, uint[] state) @safe pure nothrow @nogc
    {
        this.n = cast(uint) n;
        this.state = state;
        size_t repeatLen = state.length;

        // set initial state and calculate max possibilities
        if (n > 0)
        {
            max_states = cast(size_t) binomial(n + repeatLen - 1, repeatLen);
        }
    }

    ///
    @property const(uint)[] front() @safe pure nothrow @nogc
    {
        return state;
    }

    ///
    void popFront() @safe pure nothrow @nogc
    {
        assert(!empty);
        pos++;

        immutable repeat = state.length;

        // behaves like: do _getNextState();  while(!_state.isSorted);
        size_t i = repeat - 1;
        // go to next settable block
        // a block is settable if its not in the end state (=nrElements - 1)
        while (state[i] == n - 1 && i != 0)
        {
            i--;
        }
        state[i] = state[i] + 1;

        // if we aren't at the last block, we need to set all blocks
        // to equal the current one
        // e.g. [0, 2] -> (upper block: [1, 2]) -> [1, 1]
        if (i != repeat - 1)
        {
            for (size_t j = i + 1; j < repeat; j++)
                state[j] = state[i];
        }
    }

    ///
    @property size_t length() @safe pure nothrow @nogc const
    {
        return max_states - pos;
    }

    ///
    @property bool empty() @safe pure nothrow @nogc const
    {
        return pos == max_states;
    }

    ///
    @property CombinationsRepeat save() @safe pure nothrow
    {
        typeof(this) c = this;
        c.state = state.dup;
        return c;
    }
}

///
pure nothrow @safe unittest
{
    import std.algorithm: equal;
    import std.range: iota;

    assert(iota(2).combinationsRepeat.equal!equal([[0], [1]]));
    assert(iota(2).combinationsRepeat(2).equal!equal([[0, 0], [0, 1], [1, 1]]));
    assert(iota(3).combinationsRepeat(2).equal!equal([[0, 0], [0, 1], [0, 2], [1, 1], [1, 2], [2, 2]]));
    assert("AB"d.combinationsRepeat(2).equal!equal(["AA"d, "AB"d,  "BB"d]));
}

///
static if (__VERSION__ > 2069) @nogc unittest
{
    import std.algorithm: equal;
    import std.range: iota;

    import std.experimental.allocator.mallocator;
    auto alloc = Mallocator.instance;

    static immutable expected3r1 = [[0], [1], [2]];
    auto r = iota(3);
    auto rc = alloc.makeCombinationsRepeat(r.length, 1);
    assert(rc.indexedRoR(r).equal!equal(expected3r1));
    alloc.dispose(rc);
}

unittest
{
    import std.algorithm: equal, map;
    import std.array: array;
    import std.range: iota, dropOne;

    assert(iota(0).combinationsRepeat.length == 0);
    assert("AB"d.combinationsRepeat(3).equal!equal(["AAA"d, "AAB"d, "ABB"d,"BBB"d]));

    auto expected = ["AA"d, "AB"d, "AC"d, "AD"d, "BB"d, "BC"d, "BD"d, "CC"d, "CD"d, "DD"d];
    assert("ABCD"d.combinationsRepeat(2).equal!equal(expected));
    // verify with array too
    assert("ABCD"d.combinationsRepeat(2).map!array.array == expected);

    assert(iota(2).combinationsRepeat.front.equal([0]));

    // is copyable?
    auto a = iota(2).combinationsRepeat;
    assert(a.front.equal([0]));
    assert(a.save.dropOne.front.equal([1]));
    assert(a.front.equal([0]));

    // test length shrinking
    auto d = iota(2).combinationsRepeat;
    assert(d.length == 2);
    d.popFront;
    assert(d.length == 1);
}

// length
pure nothrow @safe unittest
{
    assert(1.combinationsRepeat(1).length == 1);
    assert(1.combinationsRepeat(2).length == 1);
    assert(2.combinationsRepeat(1).length == 2);
    assert(2.combinationsRepeat(2).length == 3);
    assert(2.combinationsRepeat(3).length == 4);
    assert(3.combinationsRepeat(1).length == 3);
    assert(3.combinationsRepeat(2).length == 6);
    assert(3.combinationsRepeat(3).length == 10);
    assert(3.combinationsRepeat(4).length == 15);
    assert(4.combinationsRepeat(10).length == 286);
    assert(11.combinationsRepeat(14).length == 1961256);
    assert(20.combinationsRepeat(7).length == 657800);
    assert(20.combinationsRepeat(10).length == 20030010);
    assert(30.combinationsRepeat(10).length == 635745396);
}

pure nothrow @safe unittest
{
    // test larger combinations
    import std.algorithm: equal;
    import std.range: iota;

    auto expected3r1 = [[0], [1], [2]];
    assert(iota(3).combinationsRepeat(1).equal!equal(expected3r1));

    auto expected3r2 = [[0, 0], [0, 1], [0, 2], [1, 1], [1, 2], [2, 2]];
    assert(iota(3).combinationsRepeat(2).equal!equal(expected3r2));

    auto expected3r3 = [[0, 0, 0], [0, 0, 1], [0, 0, 2], [0, 1, 1],
                        [0, 1, 2], [0, 2, 2], [1, 1, 1], [1, 1, 2],
                        [1, 2, 2], [2, 2, 2]];
    assert(iota(3).combinationsRepeat(3).equal!equal(expected3r3));

    auto expected3r4 = [[0, 0, 0, 0], [0, 0, 0, 1], [0, 0, 0, 2],
                        [0, 0, 1, 1], [0, 0, 1, 2], [0, 0, 2, 2],
                        [0, 1, 1, 1], [0, 1, 1, 2], [0, 1, 2, 2],
                        [0, 2, 2, 2], [1, 1, 1, 1], [1, 1, 1, 2],
                        [1, 1, 2, 2], [1, 2, 2, 2], [2, 2, 2, 2]];
    assert(iota(3).combinationsRepeat(4).equal!equal(expected3r4));

    auto expected4r3 = [[0, 0, 0], [0, 0, 1], [0, 0, 2],
                        [0, 0, 3], [0, 1, 1], [0, 1, 2],
                        [0, 1, 3], [0, 2, 2], [0, 2, 3],
                        [0, 3, 3], [1, 1, 1], [1, 1, 2],
                        [1, 1, 3], [1, 2, 2], [1, 2, 3],
                        [1, 3, 3], [2, 2, 2], [2, 2, 3],
                        [2, 3, 3], [3, 3, 3]];
    assert(iota(4).combinationsRepeat(3).equal!equal(expected4r3));

    auto expected4r2 = [[0, 0], [0, 1], [0, 2], [0, 3],
                         [1, 1], [1, 2], [1, 3], [2, 2],
                         [2, 3], [3, 3]];
    assert(iota(4).combinationsRepeat(2).equal!equal(expected4r2));

    auto expected5r3 = [[0, 0, 0], [0, 0, 1], [0, 0, 2], [0, 0, 3], [0, 0, 4],
                        [0, 1, 1], [0, 1, 2], [0, 1, 3], [0, 1, 4], [0, 2, 2],
                        [0, 2, 3], [0, 2, 4], [0, 3, 3], [0, 3, 4], [0, 4, 4],
                        [1, 1, 1], [1, 1, 2], [1, 1, 3], [1, 1, 4], [1, 2, 2],
                        [1, 2, 3], [1, 2, 4], [1, 3, 3], [1, 3, 4], [1, 4, 4],
                        [2, 2, 2], [2, 2, 3], [2, 2, 4], [2, 3, 3], [2, 3, 4],
                        [2, 4, 4], [3, 3, 3], [3, 3, 4], [3, 4, 4], [4, 4, 4]];
    assert(iota(5).combinationsRepeat(3).equal!equal(expected5r3));

    auto expected5r2 = [[0, 0], [0, 1], [0, 2], [0, 3], [0, 4],
                        [1, 1], [1, 2], [1, 3], [1, 4], [2, 2],
                        [2, 3], [2, 4], [3, 3], [3, 4], [4, 4]];
    assert(iota(5).combinationsRepeat(2).equal!equal(expected5r2));
}

static if (__VERSION__ > 2069) unittest
{
    // check invalid
    import std.exception: assertThrown;
    import core.exception: AssertError;
    import std.experimental.allocator.mallocator: Mallocator;

    assertThrown!AssertError(0.combinationsRepeat(0));
    assertThrown!AssertError(Mallocator.instance.makeCombinationsRepeat(0, 0));
}

/**
Disposes a CombinationsRepeat object. It destroys and then deallocates the
CombinationsRepeat object pointed to by a pointer.
It is assumed the respective entities had been allocated with the same allocator.

Params:
    alloc = Custom allocator
    perm = CombinationsRepeat object

See_Also:
    $(LREF makeCombinationsRepeat)
*/
void dispose(Allocator)(auto ref Allocator alloc, auto ref CombinationsRepeat combs)
{
    import std.experimental.allocator: dispose;
    dispose(alloc, combs.state);
}
