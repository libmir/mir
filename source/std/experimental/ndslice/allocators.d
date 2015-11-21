/**
$(SCRIPT inhibitQuickIndex = 1;)

$(BOOKTABLE $(H2 Allocators),

$(TR $(TH Function Name) $(TH Description))
$(T2 createSlice, `createSlice(3, 4, 5)` creates an array with length equal `60` and returns `3`-dimensional slice-shell over it.)
$(T2 ndarray, `1000.iota.sliced(3, 4, 5).ndarray` returns array type of `int[][][]`.)
)

License:   $(WEB www.boost.org/LICENSE_1_0.txt, Boost License 1.0).

Authors:   Ilya Yaroshenko

Source:    $(PHOBOSSRC std/_experimental/_ndslice/_allocators.d)

Macros:
T2=$(TR $(TDNW $(LREF $1)) $(TD $+))
*/
module std.experimental.ndslice.allocators;


import std.experimental.ndslice.internal;
import std.experimental.ndslice.slice;

/++
Creates array and n-dimensional slice over it.
Params:
    lengths = list of lengths for dimensions
See_also: $(LREF sliced)
+/
auto createSlice(T, Lengths...)(Lengths lengths)
{
    return createSlice!(T, Lengths.length)(cast(size_t[Lengths.length])[lengths]);
}

///ditto
auto createSlice(T, size_t N)(auto ref size_t[N] lengths)
{
    return new T[lengths.lengthsProduct].sliced(lengths);
}

///
unittest {
    auto slice = createSlice!int(5, 6, 7);
    assert(slice.length == 5);
    assert(slice.elementsCount == 5 * 6 * 7);
    static assert(is(typeof(slice) == Slice!(3, int*)));

    auto duplicate = createSlice!int(slice.shape);
    duplicate[] = slice;
}

/// Allocators
version(Posix) //Issue 15281
unittest {
    import std.experimental.allocator;

    /++
    Allocates array and n-dimensional slice over it.
    Params:
        alloc = allocator, see also $(LINK2 std_experimental_allocator.html, std.experimental.allocator)
        lengths = list of lengths for dimensions
    Returns: `array` created with `alloc` and `slice` over it
    See_also: $(LREF sliced)
    +/

    // `theAllocator.makeSlice(3, 4)` allocates an array with length equal `12`
    // and returns this `array` and `2`-dimensional `slice`-shell over it.
    auto makeSlice(T, Allocator, Lengths...)(auto ref Allocator alloc, Lengths lengths)
    {
        enum N = Lengths.length;
        struct Result { T[] array; Slice!(N, T*) slice; }
        size_t length = lengths[0];
        foreach(len; lengths[1..N])
                length *= len;
        T[] a = alloc.makeArray!T(length);
        return Result(a, a.sliced(lengths));
    }

    auto tup = makeSlice!int(theAllocator, 2, 3, 4);

    static assert(is(typeof(tup.array) == int[]));
    static assert(is(typeof(tup.slice) == Slice!(3, int*)));

    assert(tup.array.length           == 24);
    assert(tup.slice.elementsCount    == 24);
    assert(tup.array.ptr == &tup.slice[0, 0, 0]);

    theAllocator.dispose(tup.array);
}

/++
Creates a common `n`-dimensional array.
See_also: $(LREF createSlice)
+/
auto ndarray(size_t N, Range)(auto ref Slice!(N, Range) slice)
{
    import std.array: array;
    static if (N == 1)
    {
        return slice.array;
    }
    else
    {
        import std.algorithm.iteration: map;
        return slice.map!(.ndarray).array;
    }
}

///
unittest {
    import std.range: iota;
    auto ar = 100.iota.sliced(3, 4).ndarray;
    static assert(is(typeof(ar) == int[][]));
    assert(ar == [[0,1,2,3], [4,5,6,7], [8,9,10,11]]);
}

version(none):
/++
Returns a newly allocated mutable array of all elements int a slice.
See_also: $(LREF byElement)
+/
Unqual!(ElementType!Range)[] elements(size_t N, Range)(auto ref Slice!(N, Range) slice) @property
{
    import std.array: uninitializedArray;
    with(Slice!(N, Range))
    {
        alias E = Unqual!(ElementType!Range);
        E[] ret = void;
        auto lazyElements = slice.byElement;
        //TODO: check constructors
        static if(__traits(compiles, {ret = uninitializedArray!(E[])(lazyElements.length); }))
        {
            if(__ctfe)
                ret = new E[lazyElements.length];
            else
                ret = uninitializedArray!(E[])(lazyElements.length);
        }
        else
        {
            ret = new E[lazyElements.length];
        }
        foreach(ref e; ret)
        {
            e = lazyElements.front;
            lazyElements.popFrontImpl;
        }
        return ret;
    }
}

///Common slice
unittest {
    import std.range: iota;
    assert(100.iota
        .sliced(2, 3)
        .elements == [0, 1, 2, 3, 4, 5]);
}

///Packed slice
unittest {
    import std.range: iota;
    assert(100000.iota
        .sliced(2, 2, 3)
        .packed!2
        .elements[$-1]
        .elements == [6, 7, 8, 9, 10, 11]);
}
