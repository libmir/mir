///
module std.experimental.ndslice.allocators;
/++

$(BOOKTABLE $(H2 Allocators),

$(TR $(TH Function Name) $(TH Description))
$(T2 sliced, `1000.iota.sliced(3, 4, 5)` returns `3`-dimensional slice-shell with dimensions `3, 4, 5`.)
$(T2 createSlice, `createSlice(3, 4, 5)` creates an array with length equal `60` and returns `3`-dimensional slice-shell over it.)
$(T2 ndarray, `1000.iota.sliced(3, 4, 5).ndarray` returns array type of `int[][][]`.)
$(T2 elements, `100.iota.sliced(2, 3).elements` is identical to `[0, 1, 2, 3, 4, 5]`.)
)

+/

version(none):
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

///++
//Returns a newly allocated mutable array of all elements int a slice.
//See_also: $(LREF byElement)
//+/
//Unqual!(ElementType!Range)[] elements(size_t N, Range)(auto ref Slice!(N, Range) slice) @property
//{
//    import std.array: uninitializedArray;
//    with(Slice!(N, Range))
//    {
//        alias E = Unqual!(ElementType!Range);
//        E[] ret = void;
//        auto lazyElements = slice.byElement;
//        //TODO: check constructors
//        static if(__traits(compiles, {ret = uninitializedArray!(E[])(lazyElements.length); }))
//        {
//            if(__ctfe)
//                ret = new E[lazyElements.length];
//            else
//                ret = uninitializedArray!(E[])(lazyElements.length);
//        }
//        else
//        {
//            ret = new E[lazyElements.length];
//        }
//        foreach(ref e; ret)
//        {
//            e = lazyElements.front;
//            lazyElements.popFrontImpl;
//        }
//        return ret;
//    }
//}

/////Common slice
//unittest {
//    import std.range: iota;
//    assert(100.iota
//        .sliced(2, 3)
//        .elements == [0, 1, 2, 3, 4, 5]);
//}

/////Packed slice
//unittest {
//    import std.range: iota;
//    assert(100000.iota
//        .sliced(2, 2, 3)
//        .packed!2
//        .elements[$-1]
//        .elements == [6, 7, 8, 9, 10, 11]);
//}
