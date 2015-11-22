/**

License:   $(WEB www.boost.org/LICENSE_1_0.txt, Boost License 1.0).

Authors:   Ilya Yaroshenko

Source:    $(PHOBOSSRC std/_experimental/_ndslice/_sliced)

Macros:
SUBMODULE = $(LINK2 std_experimental_ndslice_$1.html, std.experimental.ndslice.$1)
SUBREF = $(LINK2 std_experimental_ndslice_$1.html#.$2, $(TT $2))$(NBSP)
T2=$(TR $(TDNW $(LREF $1)) $(TD $+))
T4=$(TR $(TDNW $(LREF $1)) $(TD $2) $(TD $3) $(TD $4))
*/
module std.experimental.ndslice.slice;

import std.traits;
import std.typecons: Tuple;
import std.meta;
import std.range.primitives;
import std.experimental.ndslice.internal;

/++
Creates `n`-dimensional slice-shell over a `range`.
Params:
    range = a random access range or an array; only index operator `auto opIndex(size_t index)` is required for ranges
    lengths = list of lengths for each dimension
    shift = number of the first element in a `range`; first `shift` elements are ignored
See_also: $(SUBREF allocators, createSlice)
+/
auto sliced(Range, Lengths...)(Range range, Lengths lengths)
    if (!isStaticArray!Range && !isNarrowString!Range
        && allSatisfy!(isIndex, Lengths) && Lengths.length)
{
    return .sliced!(Lengths.length, Range)(range, [lengths]);
}

///ditto
auto sliced(size_t N, Range)(Range range, auto ref in size_t[N] lengths, size_t shift = 0)
    if (!isStaticArray!Range && !isNarrowString!Range && N)
in {
    foreach(len; lengths)
        assert(len > 0,
            "All lengths must be positive."
            ~ tailErrorMessage!());
    static if (hasLength!Range)
        assert(lengthsProduct!N(lengths) + shift <= range.length,
            "Range length mast be greater or equal to lengths product plus shift."
            ~ tailErrorMessage!());
}
body {
    static if (isDynamicArray!Range)
    {
        Slice!(N, typeof(range.ptr)) ret = void;
        ret._ptr = range.ptr + shift;
    }
    else
    {
        Slice!(N, ImplicitlyUnqual!(typeof(range))) ret = void;
        ret._ptr._range = range;
        ret._ptr._shift = shift;
    }

    size_t stride = 1;
    foreach_reverse(i; Iota!(0, N))
    {
        ret._lengths[i] = lengths[i];
        ret._strides[i] = stride;
        stride *= lengths[i];
    }
    return ret;
}

///Arrays
unittest {
    auto slice = new int [1000].sliced(5, 6, 7);
    assert(slice.length == 5);
    assert(slice.elementsCount == 5 * 6 * 7);
    static assert(is(typeof(slice) == Slice!(3, int*)));
}

///Shift parameter
unittest {
    import std.range: iota;
    auto slice = 1000.iota.sliced([5, 6, 7], 9);
    assert(slice.length == 5);
    assert(slice.elementsCount == 5 * 6 * 7);
    assert(slice[0, 0, 0] == 9);
}

/++
Creates array and n-dimensional slice over it.
Params:
    lengths = list of lengths for dimensions
+/
unittest {

    auto createSlice(T, Lengths...)(Lengths lengths)
    {
        return createSlice2!(T, Lengths.length)(cast(size_t[Lengths.length])[lengths]);
    }

    ///ditto
    auto createSlice2(T, size_t N)(auto ref size_t[N] lengths)
    {
        return new T[lengths.lengthsProduct].sliced(lengths);
    }

    auto slice = createSlice!int(5, 6, 7);
    assert(slice.length == 5);
    assert(slice.elementsCount == 5 * 6 * 7);
    static assert(is(typeof(slice) == Slice!(3, int*)));

    auto duplicate = createSlice2!int(slice.shape);
    duplicate[] = slice;
}

/++
Creates a common `n`-dimensional array.
+/
unittest {
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
            return slice.map!(a => ndarray(a)).array;
        }
    }

    import std.range: iota;
    auto ar = ndarray(100.iota.sliced(3, 4));
    static assert(is(typeof(ar) == int[][]));
    assert(ar == [[0,1,2,3], [4,5,6,7], [8,9,10,11]]);
}

/++
Allocates array and n-dimensional slice over it.
Params:
    alloc = allocator, see also $(LINK2 std_experimental_allocator.html, std.experimental.allocator)
    lengths = list of lengths for dimensions
Returns: `array` created with `alloc` and `slice` over it
+/
version(Posix) //Issue 15281
unittest {
    import std.experimental.allocator;


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
$(D _N)-dimensional slice-shell over a range.
See_also: $(LREF sliced), $(SUBREF allocators, createSlice), $(SUBREF allocators, ndarray)
+/
struct Slice(size_t _N, _Range)
    if (_N && _N < 256LU && ((!is(Unqual!_Range : Slice!(N0, Range0), size_t N0, Range0)
                     && (isPointer!_Range || is(typeof(_Range.init[size_t.init]) == ElementType!_Range)))
                    || is(_Range == Slice!(N1, Range1), size_t N1, Range1)))
{
package:

    enum doUnittest = is(_Range == int*);

    alias N = _N;
    alias Range = _Range;

    alias This = Slice!(N, Range);
    static if (is(Range == Slice!(N_, Range_), size_t N_, Range_))
    {
        enum size_t PureN = N + Range.PureN - 1;
        alias PureRange = Range.PureRange;
        alias NSeq = AliasSeq!(N, Range.NSeq);
    }
    else
    {
        alias PureN = N;
        alias PureRange = Range;
        alias NSeq = N;
    }
    alias PureThis = Slice!(PureN, PureRange);

    static assert(PureN < 256, "Slice: Pure N should be less then 256");

    static if (N == 1)
        static if (isPointer!Range)
            alias ElemType = PointerTarget!Range;
        else
            alias ElemType = ElementType!Range;
    else
        alias ElemType = Slice!(N-1, Range);

    static if (PureN == N)
        alias DeepElemType = ElemType;
    else
    static if (Range.N == 1)
        alias DeepElemType = Range.DeepElemType;
    else
        alias DeepElemType = Slice!(Range.N - 1, Range.Range);

    enum rangeHasMutableElements = isPointer!PureRange ||
        __traits(compiles, { _ptr[0] = _ptr[0].init; } );

    enum hasAccessByRef = isPointer!PureRange ||
        __traits(compiles, { auto a = &(_ptr[0]); } );

    enum PureIndexLength(Slices...) = Filter!(isIndex, Slices).length;
    template isFullPureIndex(Indexes...)
    {
        static if (allSatisfy!(isIndex, Indexes))
            enum isFullPureIndex  = Indexes.length == N;
        else
        static if (Indexes.length == 1 && isStaticArray!(Indexes[0]))
            enum isFullPureIndex = Indexes[0].length == N && isIndex!(ForeachType!(Indexes[0]));
        else
            enum isFullPureIndex = false;
    }
    enum isPureSlice(Slices...) =
           Slices.length <= N
        && PureIndexLength!Slices < N
        && Filter!(isStaticArray, Slices).length == 0;

    enum isFullPureSlice(Slices...) =
           Slices.length == 0
        || Slices.length == N
        && PureIndexLength!Slices < N
        && Filter!(isStaticArray, Slices).length == 0;

    size_t[PureN] _lengths;
    sizediff_t[PureN] _strides;
    static if (isPointer!PureRange)
        PureRange _ptr;
    else
        PtrShell!PureRange _ptr;

    sizediff_t backIndex(size_t dimension = 0)() @property const
        if (dimension < N)
    {
        return _strides[dimension] * (_lengths[dimension] - 1);
    }

    size_t indexStride(Indexes...)(Indexes _indexes)
        if (isFullPureIndex!Indexes)
    {
        static if(isStaticArray!(Indexes[0]))
        {
            size_t stride;
            foreach(i; Iota!(0, N)) //static
            {
                assert(_indexes[0][i] < _lengths[i], "indexStride: index must be less then lengths");
                stride += _strides[i] * _indexes[0][i];
            }
            return stride;
        }
        else
        {
            size_t stride;
            foreach(i, index; _indexes) //static
            {
                assert(index < _lengths[i], "indexStride: index must be less then lengths");
                stride += _strides[i] * index;
            }
            return stride;
        }
    }

    this(ref in size_t[PureN] lengths, ref in sizediff_t[PureN] strides, PureRange range)
    {
        foreach(i; Iota!(0, PureN))
            _lengths[i] = lengths[i];
        foreach(i; Iota!(0, PureN))
            _strides[i] = strides[i];
        static if (isPointer!PureRange)
            _ptr = range;
        else
            _ptr._range = range;

    }

    static if (!isPointer!PureRange)
    this(ref in size_t[PureN] lengths, ref in sizediff_t[PureN] strides, PtrShell!PureRange shell)
    {
        foreach(i; Iota!(0, PureN))
            _lengths[i] = lengths[i];
        foreach(i; Iota!(0, PureN))
            _strides[i] = strides[i];
        _ptr = shell;
    }

public:

    /++
    Returns: fixed size array of lengths
    See_also: $(LREF .Slice.structure)
    +/
    size_t[N] shape() @property const
    {
        return _lengths[0..N];
    }

    static if(doUnittest)
    ///Normal slice
    unittest {
        import std.range: iota;
        assert(100.iota
            .sliced(3, 4, 5)
            .shape == [3, 4, 5]);
    }

    static if(doUnittest)
    ///Packed slice
    unittest {
        import std.experimental.ndslice.selection;
        import std.range: iota;
        assert(10000.iota
            .sliced(3, 4, 5, 6, 7)
            .pack!2
            .shape == [3, 4, 5]);
    }

    /++
    Returns: fixed size array of lengths and fixed size array of strides
    See_also: $(LREF .Slice.shape)
   +/
    Tuple!(size_t[N], `lengths`, sizediff_t[N], `strides`)
    structure() @property const
    {
        return typeof(return)(_lengths[0..N], _strides[0..N]);
    }

    static if(doUnittest)
    ///Normal slice
    unittest {
        import std.typecons: tuple;
        import std.range: iota;
        assert(100.iota
            .sliced(3, 4, 5)
            .structure == tuple([3, 4, 5], [20, 5, 1]));
    }

    static if(doUnittest)
    ///Normal modified slice
    unittest {
        import std.experimental.ndslice.selection: pack;
        import std.experimental.ndslice.iteration: reversed, strided, transposed;
        import std.typecons: tuple;
        import std.range: iota;
        assert(1000.iota
            .sliced(3, 4, 50)
            .reversed!2      //makes stride negative
            .strided!2(6)    //multiplies stride by 6, and changes length
            .transposed!2    //brings dimension `2` on top
            .structure == tuple([9, 3, 4], [-6, 200, 50]));
    }

    static if(doUnittest)
    ///Packed slice
    unittest {
        import std.experimental.ndslice.slice;
        import std.experimental.ndslice.selection: pack;
        import std.typecons: tuple;
        import std.range: iota;
        assert(10000.iota
            .sliced(3, 4, 5, 6, 7)
            .pack!2
            .structure == tuple([3, 4, 5], [20 * 42, 5 * 42, 1 * 42]));
    }

    /++
    `save` range primitive.
    Defined if `Range` is forward range or pointer type.
    +/
    static if (isPointer!PureRange || isForwardRange!PureRange)
    auto save() @property
    {
        static if (isPointer!PureRange)
            return typeof(this)(_lengths, _strides, _ptr);
        else
            return typeof(this)(_lengths, _strides, _ptr.save);
    }

    static if(doUnittest)
    ///Forward range
    unittest {
        import std.range: iota;
        auto slice = 100.iota.sliced(2, 3).save;
    }

    static if(doUnittest)
    ///Pointer type.
    unittest {
         //slice has type `Slice!(2, int*)`
         auto slice = new int[6].sliced(2, 3).save;
    }


    /++
        Multidimensional `length` property.
        Returns: length of corresponding dimension.
        See_also: $(LREF .Slice.shape), $(LREF .Slice.structure)
    +/
    size_t length(size_t dimension = 0)() @property const
        if (dimension < N)
    {
        return _lengths[dimension];
    }

    static if(doUnittest)
    ///
    unittest {
        import std.range: iota;
        auto slice = 100.iota.sliced(3, 4, 5);
        assert(slice.length   == 3);
        assert(slice.length!0 == 3);
        assert(slice.length!1 == 4);
        assert(slice.length!2 == 5);
    }

    alias opDollar = length;

    /++
        Multidimensional `stride` property.
        Returns: stride of corresponding dimension.
        See_also: $(LREF .Slice.structure)
    +/
    size_t stride(size_t dimension = 0)() @property const
        if (dimension < N)
    {
        return _strides[dimension];
    }

    static if(doUnittest)
    ///Normal slice
    unittest {
        import std.typecons: tuple;
        import std.range: iota;
        import std.range: iota;
        auto slice = 100.iota.sliced(3, 4, 5);
        assert(slice.stride   == 20);
        assert(slice.stride!0 == 20);
        assert(slice.stride!1 == 5);
        assert(slice.stride!2 == 1);
    }

    static if(doUnittest)
    ///Normal modified slice
    unittest {
        import std.experimental.ndslice.iteration;
        import std.typecons: tuple;
        import std.range: iota;
        assert(1000.iota
            .sliced(3, 4, 50)
            .reversed!2      //makes stride negative
            .strided!2(6)    //multiplies stride by 6, and changes length
            .swapped!(1, 2)  //swaps dimensions `1` and `2`
            .stride!1 == -6);
    }

    static if (N == PureN)
    {
        static if (isPointer!PureRange)
        {
            package(std) inout(PureRange) ptr() @property inout
            {
                return _ptr;
            }
        }
        static if (!isPointer!PureRange)
        {
            package(std) PureRange range() @property
            {
                return _ptr._range;
            }

            package(std) sizediff_t shift()
            {
                return _ptr._shift;
            }
        }
    }

    /++
    Multidimensional input range primitive.
    +/
    bool empty(size_t dimension = 0)()
    @property const
        if (dimension < N)
    {
        return _lengths[dimension] == 0;
    }

    ///ditto
    auto ref front(size_t dimension = 0)() @property
        if (dimension < N)
    {
        assert(!empty!dimension);
        static if (PureN == 1)
        {
            return _ptr[0];
        }
        else
        {
            ElemType ret = void;
            foreach(i; Iota!(0, dimension))
            {
                ret._lengths[i] = _lengths[i];
                ret._strides[i] = _strides[i];
            }
            foreach(i; Iota!(dimension, PureN-1))
            {
                ret._lengths[i] = _lengths[i + 1];
                ret._strides[i] = _strides[i + 1];
            }
            ret._ptr = _ptr;
            return ret;
        }
    }

    static if (PureN == 1 && rangeHasMutableElements && !hasAccessByRef)
    {
        ///ditto
        auto front(size_t dimension = 0, T)(T value) @property
            if (dimension == 0)
        {
            assert(!empty!dimension);
            return _ptr.front = value;
        }
    }

    ///ditto
    auto ref back(size_t dimension = 0)() @property
        if (dimension < N)
    {
        assert(!empty!dimension);
        static if (PureN == 1)
        {
            return _ptr[backIndex];
        }
        else
        {
            ElemType ret = void;
            foreach(i; Iota!(0, dimension))
            {
                ret._lengths[i] = _lengths[i];
                ret._strides[i] = _strides[i];
            }
            foreach(i; Iota!(dimension, PureN-1))
            {
                ret._lengths[i] = _lengths[i + 1];
                ret._strides[i] = _strides[i + 1];
            }
            ret._ptr = _ptr + backIndex!dimension;
            return ret;
        }
    }

    static if (PureN == 1 && rangeHasMutableElements && !hasAccessByRef)
    {
        ///ditto
        auto back(size_t dimension = 0, T)(T value) @property
            if (dimension == 0)
        {
            assert(!empty!dimension);
            return _ptr[backIndex] = value;
        }
    }


    ///ditto
    void popFront(size_t dimension = 0)()
        if (dimension < N)
    {
        assert(_lengths[dimension], __FUNCTION__ ~ ": length!" ~ dimension.stringof ~ " should be greater then 0.");
        _lengths[dimension]--;
        _ptr += _strides[dimension];
    }

    package void popFront(size_t dimension)
    {
        assert(dimension < N, __FUNCTION__ ~ ": dimension should be less then N = " ~ N.stringof);
        assert(_lengths[dimension], ": length!dim should be greater then 0.");
        _lengths[dimension]--;
        _ptr += _strides[dimension];
    }

    ///ditto
    void popBack(size_t dimension = 0)()
        if (dimension < N)
    {
        assert(_lengths[dimension], __FUNCTION__ ~ ": length!" ~ dimension.stringof ~ " should be greater then 0.");
        _lengths[dimension]--;
    }

    package void popBack(size_t dimension)
    {
        assert(dimension < N, __FUNCTION__ ~ ": dimension should be less then N = " ~ N.stringof);
        assert(_lengths[dimension], ": length!dim should be greater then 0.");
        _lengths[dimension]--;
    }

    ///ditto
    void popFrontExactly(size_t dimension = 0)(size_t n)
        if (dimension < N)
    {
        assert(n <= _lengths[dimension], __FUNCTION__ ~ ": n should be less or equal to length!" ~ dimension.stringof);
        _lengths[dimension] -= n;
        _ptr += _strides[dimension] * n;
    }

    package void popFrontExactly(size_t dimension, size_t n)
    {
        assert(dimension < N, __FUNCTION__ ~ ": dimension should be less then N = " ~ N.stringof);
        assert(n <= _lengths[dimension], __FUNCTION__ ~ ": n should be less or equal to length!dim");
        _lengths[dimension] -= n;
        _ptr += _strides[dimension] * n;
    }

    ///ditto
    void popBackExactly(size_t dimension = 0)(size_t n)
        if (dimension < N)
    {
        assert(n <= _lengths[dimension], __FUNCTION__ ~ ": n should be less or equal to length!" ~ dimension.stringof);
        _lengths[dimension] -= n;
    }

    package void popBackExactly(size_t dimension, size_t n)
    {
        assert(dimension < N, __FUNCTION__ ~ ": dimension should be less then N = " ~ N.stringof);
        assert(n <= _lengths[dimension], __FUNCTION__ ~ ": n should be less or equal to length!dim");
        _lengths[dimension] -= n;
    }

    ///ditto
    void popFrontN(size_t dimension = 0)(size_t n)
        if (dimension < N)
    {
        import std.algorithm.comparison: min;
        popFrontExactly!dimension(min(n, _lengths[dimension]));
    }

    package void popFrontN(size_t dimension, size_t n)
    {
        assert(dimension < N, __FUNCTION__ ~ ": dimension should be less then N = " ~ N.stringof);
        import std.algorithm.comparison: min;
        popFrontExactly(dimension, min(n, _lengths[dimension]));
    }

    ///ditto
    void popBackN(size_t dimension = 0)(size_t n)
        if (dimension < N)
    {
        import std.algorithm.comparison: min;
        popBackExactly!dimension(min(n, _lengths[dimension]));
    }

    package void popBackN(size_t dimension, size_t n)
    {
        assert(dimension < N, __FUNCTION__ ~ ": dimension should be less then N = " ~ N.stringof);
        import std.algorithm.comparison: min;
        popBackExactly(dimension, min(n, _lengths[dimension]));
    }

    static if(doUnittest)
    ///
    unittest {
        import std.range: iota;
        auto slice = 10000.iota.sliced(10, 20, 30);

        static assert(isRandomAccessRange!(typeof(slice)));
        static assert(hasSlicing!(typeof(slice)));
        static assert(hasLength!(typeof(slice)));

        assert(slice.shape == [10, 20, 30]);
        slice.popFront;
        slice.popFront!1;
        slice.popBackExactly!2(4);
        assert(slice.shape == [9, 19, 26]);

        auto matrix = slice.front!1;
        assert(matrix.shape == [9, 26]);

        auto column = matrix.back!1;
        assert(column.shape == [9]);

        slice.popFrontExactly!1(slice.length!1);
        assert(slice.empty   == false);
        assert(slice.empty!1 == true);
        assert(slice.empty!2 == false);
        assert(slice.shape == [9, 0, 26]);

        assert(slice.back.front!1.empty);

        slice.popFrontN!0(40);
        slice.popFrontN!2(40);
        assert(slice.shape == [0, 0, 0]);
    }

    /++
    Returns: count of all elements a in slice
    +/
    size_t elementsCount() const
    {
        size_t len = 1;
        foreach(i; Iota!(0, N))
            len *= _lengths[i];
        return len;
    }

    static if(doUnittest)
    ///Normal slice
    unittest {
        import std.range: iota;
        assert(100.iota.sliced(3, 4, 5).elementsCount == 60);
    }


    static if(doUnittest)
    ///Packed slice
    unittest {
        import std.experimental.ndslice.selection: pack, packEverted;
        import std.range: iota;
        auto slice = 50000.iota.sliced(3, 4, 5, 6, 7, 8);
        auto p = slice.pack!2;
        assert(p.elementsCount == 360);
        assert(p[0, 0, 0, 0].elementsCount == 56);
        assert(p.packEverted.elementsCount == 56);
    }

    Tuple!(size_t, size_t) opSlice(size_t dimension)(size_t i, size_t j)
        if (dimension < N)
    in   {
        assert(i <= j,
            "Slice.opSlice!" ~ dimension.stringof ~ ": left bound must be less then or equal to right bound");
        assert(j - i <= _lengths[dimension],
            "Slice.opSlice!" ~ dimension.stringof ~ ": difference between right and left bounds must be less then or equal to length");
    }
    body {
        return typeof(return)(i, j);
    }

    auto ref opIndex(Indexes...)(Indexes _indexes)
        if (isFullPureIndex!Indexes)
    {
        static if (N == PureN)
            return _ptr[indexStride(_indexes)];
        else
            return DeepElemType(_lengths[N..$], _strides[N..$], _ptr + indexStride(_indexes));
    }

    auto opIndex(Slices...)(Slices slices)
        if (isPureSlice!Slices)
    {
        static if (Slices.length)
        {

            enum size_t j(size_t n) = n - Filter!(isIndex, Slices[0..n+1]).length;
            enum size_t F = PureIndexLength!Slices;
            enum size_t S = Slices.length;
            static assert(N-F > 0);
            size_t stride;
            Slice!(N-F, Range) ret = void;
            foreach(i, slice; slices) //static
            {
                static if (isIndex!(Slices[i]))
                {
                    assert(slice < _lengths[i], "Slice.opIndex: index must be less then length");
                    stride += _strides[i] * slice;
                }
                else
                {
                    stride += _strides[i] * slice[0];
                    ret._lengths[j!i] = slice[1] - slice[0];
                    ret._strides[j!i] = _strides[i];
                }
            }
            foreach(i; Iota!(S, PureN))
            {
                ret._lengths[i-F] = _lengths[i];
                ret._strides[i-F] = _strides[i];
            }
            ret._ptr = _ptr + stride;
            return ret;
        }
        else
        {
            return this;
        }
    }

    static if (rangeHasMutableElements)
    {
        void opIndexAssign(T, Slices...)(T value, Slices slices)
            if (isFullPureSlice!Slices)
        {
            auto sl = this[slices];
            enum M = sl._lengths.length;
            static if (is(T : Slice!(M, _t), _t))
                assert(sl._lengths == value._lengths, "opIndexAssign: Slices must have the same shapes.");
            static if (M == 1)
            {
                for(; sl.length; sl.popFront)
                {
                    static if (is(T : Slice!(M, _), _))
                    {
                        sl.front = value.front;
                        value.popFront;
                    }
                    else
                    {
                         sl.front = value;
                    }
                }
            }
            else
            {
                foreach(v; sl)
                {
                    static if (is(T : Slice!(M, _), _))
                    {
                        v[] = value.front;
                        value.popFront;
                    }
                    else
                    {
                        v[] = value;
                    }
                }
            }
        }

        auto ref opIndexAssign(T, Indexes...)(T value, Indexes _indexes)
            if (isFullPureIndex!Indexes)
        {
            static if (N == PureN)
                return _ptr[indexStride(_indexes)] = value;
            else
                return DeepElemType(_lengths[N..$], _strides[N..$], _ptr + indexStride(_indexes))[] = value;
        }

        auto opIndexUnary(string op, Indexes...)(Indexes _indexes)
            if (isFullPureIndex!Indexes && (op == `++` || op == `--`))
        {
            static if (N == PureN)
                mixin(`return ` ~ op ~ `_ptr[indexStride(_indexes)];`);
            else
                mixin(`return ` ~ op ~ `DeepElemType(_lengths[N..$], _strides[N..$], _ptr + indexStride(_indexes))[];`);
        }

        auto ref opIndexOpAssign(string op, T, Indexes...)(T value, Indexes _indexes)
            if (isFullPureIndex!Indexes)
        {
            static if (N == PureN)
                mixin(`return _ptr[indexStride(_indexes)] ` ~ op ~ `= value;`);
            else
                mixin(`return DeepElemType(_lengths[N..$], _strides[N..$], _ptr + indexStride(_indexes))[] ` ~ op ~ `= value;`);
        }

        static if (hasAccessByRef)
        {
            void opIndexUnary(string op, Slices...)(Slices slices)
                if (isFullPureSlice!Slices && (op == `++` || op == `--`))
            {
                static if (N - PureIndexLength!Slices == 1)
                    foreach(ref v; this[slices])
                        mixin(op ~ `v;`);
                else
                    foreach(v; this[slices])
                        mixin(op ~ `v[];`);
            }

            void opIndexOpAssign(string op, T, Slices...)(T value, Slices slices)
                if (isFullPureSlice!Slices)
            {
                auto sl = this[slices];
                enum M = sl._lengths.length;
                static if (is(T : Slice!(M, _t), _t))
                    assert(sl._lengths == value._lengths, "opIndexOpAssign: Slices must have the same shapes.");
                static if (M == 1)
                {
                    foreach(ref v; sl)
                    {
                        static if (is(T : Slice!(M, _), _))
                        {
                            mixin(`v ` ~ op ~ `= value.front;`);
                            value.popFront;
                        }
                        else
                        {
                            mixin(`v ` ~ op ~ `= value;`);
                        }
                    }
                }
                else
                {
                    foreach(v; sl)
                    {
                        static if (is(T : Slice!(M, _), _))
                        {
                            mixin(`v[] ` ~ op ~ `= value.front;`);
                            value.popFront;
                        }
                        else
                        {
                            mixin(`v[] ` ~ op ~ `= value;`);
                        }
                    }
                }
            }
        }
    }

    bool opEquals(size_t NR, RangeR)(auto ref Slice!(NR, RangeR) rslice)
        if (Slice!(NR, RangeR).PureN == PureN)
    {
        if (this._lengths != rslice._lengths)
            return false;
        static if (
               !hasReference!(typeof(this))
            && !hasReference!(typeof(rslice))
            && __traits(compiles, this._ptr == rslice._ptr)
            )
        {
            if (this._strides == rslice._strides && this._ptr == rslice._ptr)
                return true;
        }
        return opEqualsImpl(this, rslice);
    }

    /++
    `cast` operator overload.
    +/
    T opCast(T : E[], E)()
    {
        if(empty)
            return null;
        alias U = Unqual!E;
        auto ret = new U[_lengths[0]];
        auto sl = this[];
        foreach(ref e; ret)
        {
            e = cast(U) sl.front;
            sl.popFront;
        }
        return cast(T)ret;
    }

    static if(doUnittest)
    ///
    unittest {
        import std.range: iota;
        auto matrix = 4.iota.sliced(2, 2);
        auto arrays = cast(float[][]) matrix;
        assert(arrays == [[0f, 1f], [2f, 3f]]);

        import std.conv;
        auto ars = matrix.to!(immutable double[][]); //calls opCast
    }
}

// Properties and methods: package(std)
unittest {
    import std.range: iota;
    auto tensor = 100.iota.sliced(3, 4, 5);

    // `range` method
    auto theIota0 = tensor.range;
    assert(theIota0.front == 0);
    tensor.popFront;
    auto theIota1 = tensor.range;
    assert(theIota1.front == 0);

    // `ptr` property
    import std.array: array;
    auto ar = 100.iota.array;
    auto ts = ar.sliced(3, 4, 5)[1..$, 2..$, 3..$];
    assert(ts.ptr is ar.ptr + 1*20+2*5+3*1);
}

// Slicing
unittest {
    import std.range: iota;
    auto a = 1000000.iota.sliced(10, 20, 30, 40);
    auto b = a[0..$, 10, 4..27, 4];
    auto c = b[2..9, 5..10];
    auto d = b[3..$, $-2];
    assert(b[4, 17] == a[4, 10, 21, 4]);
    assert(c[1, 2] == a[3, 10, 11, 4]);
    assert(d[3] == a[6, 10, 25, 4]);
}

// Operator overloading. # 1
unittest {
    import std.range: iota;
    import std.array: array;
    auto fun(ref int x) { x *= 3; }

    auto tensor = 1000
        .iota
        .array
        .sliced(8, 9, 10);

    ++tensor[];
    fun(tensor[0, 0, 0]);

    assert(tensor[0, 0, 0] == 3);

    tensor[0, 0, 0] *= 4;
    tensor[0, 0, 0]--;
    assert(tensor[0, 0, 0] == 11);
}

// Operator overloading. # 2
unittest {
    import std.algorithm.iteration: map;
    import std.array: array;
    import std.bigint;
    import std.range: iota;

    auto matrix = 100
        .iota
        .map!(i => BigInt(i))
        .array
        .sliced(8, 9);

    matrix[3..6, 2] += 100;
    foreach(i; 0..8)
        foreach(j; 0..9)
            if (i >= 3 && i < 6 && j == 2)
                assert(matrix[i, j] >= 100);
            else
                assert(matrix[i, j] < 100);
}

// Operator overloading. # 3
unittest {
    import std.algorithm.comparison: equal;
    import std.algorithm.iteration: map;
    import std.array: array;
    import std.range;

    auto matrix = 100
        .iota
        .array
        .sliced(8, 9);

    matrix[] = matrix;
    matrix[] += matrix;
    assert(matrix[2, 3] == (2 * 9 + 3) * 2);

    auto vec = iota(100, 200).sliced(9);
    matrix[] = vec;
    foreach(v; matrix)
        assert(v.equal(vec));

    matrix[] += vec;
    foreach(vector; matrix)
        foreach(elem; vector)
            assert(elem >= 200);
}

// Type deduction
unittest {
    //Arrays
    foreach(T; AliasSeq!(int, const int, immutable int))
        static assert(is(typeof((T[]).init.sliced(3, 4)) == Slice!(2, T*)));

    //Container Array
    import std.container.array;
    Array!int ar;
    static assert(is(typeof(ar[].sliced(3, 4)) == Slice!(2, typeof(ar[]))));

    //An implicitly convertible types to it's unqualified type.
    import std.range: iota;
    auto      i0 = 100.iota;
    const     i1 = 100.iota;
    immutable i2 = 100.iota;
    alias S = Slice!(3, typeof(iota(0)));
    foreach(i; AliasSeq!(i0, i1, i2))
        static assert(is(typeof(i.sliced(3, 4, 5)) == S));
}


unittest {
    const size_t[3] lengths = [3, 4, 5];
    assert(lengthsProduct(lengths) == 60);
    assert(lengthsProduct([3, 4, 5]) == 60);
}

bool opEqualsImpl
    (size_t NL, RangeL, size_t NR, RangeR)(
    auto ref Slice!(NL, RangeL) lslice,
    auto ref Slice!(NR, RangeR) rslice)
in {
    assert(lslice._lengths == rslice._lengths);
}
body {
    auto ls = lslice;
    auto rs = rslice;
    while(!ls.empty)
    {
        static if (Slice!(NL, RangeL).PureN == 1)
        {
            if (ls.front != rs.front)
                return false;
        }
        else
        {
            if (!opEqualsImpl(ls.front, rs.front))
                return false;
        }
        rs.popFront;
        ls.popFront;
    }
    return true;
}

struct PtrShell(Range)
{
    sizediff_t _shift;
    Range _range;

    enum hasAccessByRef = isPointer!Range ||
        __traits(compiles, { auto a = &(_range[0]); } );

    void opOpAssign(string op)(sizediff_t shift)
        if (op == `+` || op == `-`)
    {
        mixin(`_shift ` ~ op ~ `= shift;`);
    }

    auto opBinary(string op)(sizediff_t shift)
        if (op == `+` || op == `-`)
    {
        mixin(`return typeof(this)(_shift ` ~ op ~ ` shift, _range);`);
    }

    auto ref opIndex(sizediff_t index)
    in {
        assert(_shift + index >= 0);
        static if (!isInfinite!Range)
            assert(_shift + index <= _range.length);
    }
    body {
        return _range[_shift + index];
    }

    static if (!hasAccessByRef)
    {
        auto ref opIndexAssign(T)(T value, sizediff_t index)
        in {
            assert(_shift + index >= 0);
            static if (!isInfinite!Range)
                assert(_shift + index <= _range.length);
        }
        body {
            return _range[_shift + index] = value;
        }

        auto ref opIndexOpAssign(string op, T)(T value, sizediff_t index)
        in {
            assert(_shift + index >= 0);
            static if (!isInfinite!Range)
                assert(_shift + index <= _range.length);
        }
        body {
            mixin(`return _range[_shift + index] ` ~ op ~ `= value;`);
        }

        auto ref opIndexUnary(string op)(sizediff_t index)
            if (op == `++` || op == `--`)
         in {
            assert(_shift + index >= 0);
            static if (!isInfinite!Range)
                assert(_shift + index <= _range.length);
        }
        body {
            mixin(`return ` ~ op ~ `_range[_shift + index];`);
        }
    }

    static if (isForwardRange!Range)
    auto save() @property
    {
        return typeof(this)(_shift, _range.save);
    }
}

auto ptrShell(Range)(Range range, sizediff_t shift = 0)
{
    return PtrShell!Range(shift, range);
}

version(none)
unittest {
    import std.internal.test.dummyrange;
    foreach(RB; AliasSeq!(ReturnBy.Reference, ReturnBy.Value))
    {
        DummyRange!(RB, Length.Yes, RangeType.Random) range;
        assert(range.length >= 10);
        auto ptr = range.ptrShell;
        assert(ptr[0] == range[0]);
        auto save0 = range[0];
        ptr[0] += 10;
        ++ptr[0];
        assert(ptr[0] == save0 + 11);
        (ptr + 5)[2] = 333;
        assert(range[7] == 333);
    }
}


unittest
{
    import std.algorithm.comparison: equal;
    import std.range: iota;
    immutable r = 1_000_000.iota;

    auto t0 = r.sliced(1000);
    assert(t0.front == 0);
    assert(t0.back == 999);
    assert(t0[9] == 9);

    auto t1 = t0[10..20];
    assert(t1.front == 10);
    assert(t1.back == 19);
    assert(t1[9] == 19);

    t1.popFront();
    assert(t1.front == 11);
    t1.popFront();
    assert(t1.front == 12);

    t1.popBack();
    assert(t1.back == 18);
    t1.popBack();
    assert(t1.back == 17);

    assert(t1.equal(iota(12, 18)));
}

unittest
{
    import std.algorithm.comparison: equal;
    import std.array: array;
    import std.range: iota;
    auto r = 1_000.iota.array;

    auto t0 = r.sliced(1000);
    assert(t0.length == 1000);
    assert(t0.front == 0);
    assert(t0.back == 999);
    assert(t0[9] == 9);

    auto t1 = t0[10..20];
    assert(t1.front == 10);
    assert(t1.back == 19);
    assert(t1[9] == 19);

    t1.popFront();
    assert(t1.front == 11);
    t1.popFront();
    assert(t1.front == 12);

    t1.popBack();
    assert(t1.back == 18);
    t1.popBack();
    assert(t1.back == 17);

    assert(t1.equal(iota(12, 18)));

    t1.front = 13;
    assert(t1.front == 13);
    t1.front++;
    assert(t1.front == 14);
    t1.front += 2;
    assert(t1.front == 16);
    t1.front = 12;
    assert((t1.front = 12) == 12);

    t1.back = 13;
    assert(t1.back == 13);
    t1.back++;
    assert(t1.back == 14);
    t1.back += 2;
    assert(t1.back == 16);
    t1.back = 12;
    assert((t1.back = 12) == 12);

    t1[3] = 13;
    assert(t1[3] == 13);
    t1[3]++;
    assert(t1[3] == 14);
    t1[3] += 2;
    assert(t1[3] == 16);
    t1[3] = 12;
    assert((t1[3] = 12) == 12);

    t1[3..5] = 100;
    assert(t1[2] != 100);
    assert(t1[3] == 100);
    assert(t1[4] == 100);
    assert(t1[5] != 100);

    t1[3..5] += 100;
    assert(t1[2] <  100);
    assert(t1[3] == 200);
    assert(t1[4] == 200);
    assert(t1[5] <  100);

    --t1[3..5];

    assert(t1[2] <  100);
    assert(t1[3] == 199);
    assert(t1[4] == 199);
    assert(t1[5] <  100);

    --t1[];
    assert(t1[3] == 198);
    assert(t1[4] == 198);

    t1[] += 2;
    assert(t1[3] == 200);
    assert(t1[4] == 200);

    t1[] *= t1[];
    assert(t1[3] == 40000);
    assert(t1[4] == 40000);


    assert(&t1[$-1] is &(t1.back()));
}

unittest
{
    import std.range: iota;
    auto r = (10_000L * 2 * 3 * 4).iota;

    auto t0 = r.sliced(10, 20, 30, 40);
    assert(t0.length == 10);
    assert(t0.length!0 == 10);
    assert(t0.length!1 == 20);
    assert(t0.length!2 == 30);
    assert(t0.length!3 == 40);
}

unittest {
    import std.range: iota;
    foreach(R; AliasSeq!(
        int*, int[], typeof(1.iota),
        const(int)*, const(int)[],
        immutable(int)*, immutable(int)[],
        double*, double[], typeof(10.0.iota),
        Tuple!(double, int[string])*, Tuple!(double, int[string])[]))
    foreach(n; Iota!(1, 4))
    {
        alias S = Slice!(n, R);
        static assert(isRandomAccessRange!S);
        static assert(hasSlicing!S);
        static assert(hasLength!S);
    }

    immutable int[] im = [1,2,3,4,5,6];
    auto slice = im.sliced(2, 3);
}

unittest {
    auto tensor = new int[100].sliced(3, 4, 8);
    assert(&(tensor.back.back.back()) is &tensor[2, 3, 7]);
    assert(&(tensor.front.front.front()) is &tensor[0, 0, 0]);
}

unittest {
    import std.experimental.ndslice.selection: pack;
    auto slice = new int[24].sliced(2, 3, 4);
    auto r0 = slice.pack!1[1, 2];
    slice.pack!1[1, 2] = 4;
    auto r1 = slice[1, 2];
    assert(slice[1, 2, 3] == 4);
}

unittest {
    auto ar = new int[3 * 8 * 9];

    auto tensor = ar.sliced(3, 8, 9);
    tensor[0, 1, 2] = 4;
    tensor[0, 1, 2]++;
    assert(tensor[0, 1, 2] == 5);
    tensor[0, 1, 2]--;
    assert(tensor[0, 1, 2] == 4);
    tensor[0, 1, 2] += 2;
    assert(tensor[0, 1, 2] == 6);

    auto matrix = tensor[0..$, 1, 0..$];
    matrix[] = 10;
    assert(tensor[0, 1, 2] == 10);
    assert(matrix[0, 2] == tensor[0, 1, 2]);
    assert(&matrix[0, 2] is &tensor[0, 1, 2]);
}
