module mir.combinatorics;

import std.range.primitives: isInputRange, hasLength;

struct IndexedRoR(Collection, Range)
if (isInputRange!Range)
{
    import std.range : indexed, isForwardRange;

    private Collection c;
    private Range r;

    this(Collection c, Range r)
    {
        this.c = c;
        this.r = r;
    }

    @property auto ref front()
    {
        return r.indexed(c.front);
    }

    void popFront()
    {
        c.popFront;
    }

    @property bool empty()
    {
        return c.empty;
    }

    static if(hasLength!Collection)
    {
        @property size_t length()
        {
            return c.length;
        }
    }

    static if(isForwardRange!Collection && isForwardRange!Range)
    {
        @property typeof(this) save()
        {
            return IndexedRoR!(Collection, Range)(c.save, r.save);
        }
    }
}

IndexedRoR!(Collection, Range) indexedRoR(Collection, Range)(Collection c, Range r)
if (isInputRange!Range)
{
    return IndexedRoR!(Collection, Range)(c, r);
}

Permutations permutations(size_t n) @safe pure nothrow
{
    assert(n, "must have at least one item");
    return Permutations(new size_t[n-1], new size_t[n]);
}

auto permutations(Range)(Range r) @safe pure nothrow
if (isInputRange!Range && hasLength!Range)
{
    auto perms = .permutations(r.length);
    return IndexedRoR!(Permutations, Range)(perms, r);
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

pure @safe nothrow unittest
{
    // is copyable?
    import std.algorithm: equal;
    import std.range: iota, dropOne;
    auto a = iota(2).permutations;
    assert(a.front.equal([0, 1]));
    assert(a.save.dropOne.front.equal([1, 0]));
    assert(a.front.equal([0, 1]));
}

Permutations makePermutations(Allocator)(auto ref Allocator alloc, size_t n)
{
    assert(n, "must have at least one item");
    import std.experimental.allocator: makeArray;
    auto state = alloc.makeArray!size_t(n - 1);
    auto indices = alloc.makeArray!size_t(n);
    return Permutations(state, indices);
}

void dispose(Allocator)(auto ref Allocator alloc, auto ref Permutations perm)
{
    import std.experimental.allocator: dispose;
    dispose(alloc, perm.state);
    dispose(alloc, perm.indices);
}

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

struct Permutations
{
    private size_t[] indices, state;
    private bool _empty;

    this(size_t[] state, size_t[] indices) @safe pure nothrow @nogc
    in
    {
        assert(state.length + 1 == indices.length);
    }
    body
    {
        // iota
        foreach(i, ref index; indices)
            index = i;
        state[] = 0;

        this.indices = indices;
        this.state = state;

        size_t indicesLength = indices.length;

        _empty = indicesLength == 0;
    }

    @property auto front()
    {
        return indices;
    }

    void popFront() @safe pure nothrow @nogc
    {
        import std.algorithm.mutation : swapAt;
        for (size_t h = 0;;h++)
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

    @property bool empty() @safe pure nothrow @nogc
    {
        return _empty;
    }

    @property typeof(this) save() @safe pure nothrow
    {
        typeof(this) c = this;
        c.indices = indices.dup;
        c.state = state.dup;
        return c;
    }
}
