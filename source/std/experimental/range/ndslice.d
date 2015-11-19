/**
This module implements generic algorithms for creating and manipulating of n-dimensional random access ranges and arrays,
which are represented with the $(LREF Slice).

Transpose operators, iteration operators, subspace operators and $(LREF sliced) constructor have a very small computational cost.
Transpose operators and iteration operators except `byElement` preserve type of a slice. Some operators are bifacial,
i.e they have version with template parameters and version with function parameters.
Versions with template parameters are preferred because compile time checks and optimization reasons.

$(BOOKTABLE $(H2 Constructors),

$(TR $(TH Function Name) $(TH Description))
$(T2 sliced, `1000.iota.sliced(3, 4, 5)` returns `3`-dimensional slice-shell with dimensions `3, 4, 5`.)
$(T2 createSlice, `createSlice(3, 4, 5)` creates an array with length equal `60` and returns `3`-dimensional slice-shell over it.)
$(T2 makeSlice, `theAllocator.makeSlice(3, 4)` allocates an array with length equal `12` and returns this `array` and `2`-dimensional `slice`-shell over it.)
$(T2 ndarray, `1000.iota.sliced(3, 4, 5).ndarray` returns array type of `int[][][]`.)
)

$(BOOKTABLE $(H2 Transpose operators),

$(TR $(TH Function Name) $(TH Description))
$(T2 transposed, `100000.iota.sliced(3, 4, 5, 6, 7).transposed!(4, 0, 1).shape` returns `[7, 3, 4, 5, 6]`.)
$(T2 swapped, `1000.iota.sliced(3, 4, 5).swapped!(1, 2).shape` returns `[3, 5, 4]`.)
$(T2 everted, `1000.iota.sliced(3, 4, 5).everted.shape` returns `[5, 4, 3]`.)
)
See also $(LREF packEverted).

$(BOOKTABLE $(H2 Iteration operators),

$(TR $(TH Function Name) $(TH Description))
$(T2 strided, `1000.iota.sliced(13, 40).strided!0(2).strided!1(5).shape` equals `[7, 8]`.)
$(T2 reversed, `slice.reversed!(0, slice.shape.length-1)` returns slice with reversed direction of the iteration for top level and tail level dimensions.)
$(T2 allReversed, `20.iota.sliced(4, 5).allReversed` equals `20.iota.retro.sliced(4, 5)`.)
$(T2 byElement, `100.iota.sliced(4, 5).byElement` equals `20.iota`.)
)

$(H2 Subspace operators)

The destination of subspace operators is iteration over subset of dimensions using $(LREF byElement).
`packed!K` creates a slice of slices `Slice!(N-K, Slice!(K+1, Range))` by packing last `K` dimensions of highest pack of dimensions,
so type of element of `slice.byElement` is `Slice!(K, Range)`.
Another way to use `packed` is transposition of packs of dimensions using `packEverted`.
Examples with subspace operators are available for $(LREF .Slice.structure), $(LREF byElement), $(LREF .Slice.shape), $(LREF .Slice.elementsCount).

$(BOOKTABLE Subspace operators,

$(TR $(TH Function Name) $(TH Description))
$(T2 packed, Type of `1000000.iota.sliced(1,2,3,4,5,6,7,8).packed!2` is `Slice!(6, Slice!(3, typeof(1000000.iota)))`.)
$(T2 unpacked, Restores common type after `packed`.)
$(T2 packEverted, `slice.packed!2.packEverted.unpacked` is identical to `slice.transposed!(slice.shape.length-2, slice.shape.length-1)`.)
)

$(BOOKTABLE $(H2 Bifacial operators),

$(TR $(TH Function Name) $(TH Variadic) $(TH Template) $(TH Function))
$(T4 swapped, No, `slice.swapped!(2, 3)`, `slice.swapped(2, 3)`)
$(T4 strided, No, `slice.strided!2(40)`, `slice.strided(2, 40)`)
$(T4 transposed, Yes, `slice.transposed!(1, 4, 3)`, `slice.transposed(1, 4, 3)`)
$(T4 reversed, Yes, `slice.reversed!(0, 2)`, `slice.reversed(0, 2)`)
)

Example: slicing, indexing and operations
----
import std.array: array;
import std.range: iota;

auto tensor = 60.iota.array.sliced(3, 4, 5);

assert(tensor[1, 2] == tensor[1][2]);
assert(tensor[1, 2, 3] == tensor[1][2][3]);

assert( tensor[0..$, 0..$, 4] == tensor.transposed!2[4]);
assert(&tensor[0..$, 0..$, 4][1, 2] is &tensor[1, 2, 4]);

tensor[1, 2, 3]++; //`opIndex` returns reference
--tensor[1, 2, 3]; //`opUnary`

++tensor[];
tensor[] -= 1;

// `opIndexAssing` accepts only fully qualified index/slice. Use additional empty slice `[]`.
// tensor[0..2] *= 2; // Error: tensor.opIndex(tensor.opSlice(0u, 2u)) is not an lvalue

tensor[0..2][] *= 2;        //OK, empty slice
tensor[0..2, 3, 0..$] /= 2; //OK, 3 index/slice positions are defined.

//fully qualified index defined by static array
size_t[3] index = [1, 2, 3];
assert(tensor[index] == tensor[1, 2, 3]);
----

Example: operations with rvalue slices
----
auto tensor = createSlice!int(3, 4, 5);
auto matrix = createSlice!int(3, 4);
auto vector = createSlice!int(3);

foreach(i; 0..3)
    vector[i] = i;

// fill matrix columns
// transposed matrix shape is (4, 3)
//            vector shape is (   3)
matrix.transposed[] = vector;

// fill tensor with vector
// transposed tensor shape is (4, 5, 3)
//            vector shape is (      3)
tensor.transposed!(1, 2)[] = vector;


// transposed tensor shape is (5, 3, 4)
//            matrix shape is (   3, 4)
tensor.transposed!2[] += matrix;

// transposed tensor shape is (5, 4, 3)
// transposed matrix shape is (   4, 3)
tensor.everted[] ^= matrix.transposed; // XOR
----

Example: formatting, see also $(LINK2 std_format.html, std.format).
----
import std.algorithm, std.exception, std.format,
    std.functional, std.conv, std.string, std.range;

Slice!(2, int*) toMatrix(string str)
{
    string[][] data = str.lineSplitter.filter!(not!empty).map!split.array;
    size_t rows = data.length.enforce("empty input");
    size_t columns = data[0].length.enforce("empty first row");
    data.each!(a => enforce(a.length == columns, "rows have different lengths"));

    auto slice = createSlice!int(rows, columns);
    foreach(i, line; data)
        foreach(j, num; line)
            slice[i, j] = num.to!int;
    return slice;
}

auto input = "\r1 2  3\r\n 4 5 6\n";
auto ouptut = "1 2 3\n4 5 6\n";
auto fmt = "%(%(%s %)\n%)\n";
assert(format(fmt, toMatrix(input)) == ouptut);
----

License:   $(WEB www.boost.org/LICENSE_1_0.txt, Boost License 1.0).

Authors:   Ilya Yaroshenko

Source:    $(PHOBOSSRC std/_experimental/_range/_ndslice.d)

Macros:
T2=$(TR $(TDNW $(LREF $1)) $(TD $+))
T4=$(TR $(TDNW $(LREF $1)) $(TD $2) $(TD $3) $(TD $4))
*/
module std.experimental.range.ndslice;

//example test
unittest {
    import std.array: array;
    import std.range: iota;

    auto tensor = 60.iota.array.sliced(3, 4, 5);

    assert(tensor[1, 2] == tensor[1][2]);
    assert(tensor[1, 2, 3] == tensor[1][2][3]);

    assert( tensor[0..$, 0..$, 4] == tensor.transposed!2[4]);
    assert(&tensor[0..$, 0..$, 4][1, 2] is &tensor[1, 2, 4]);

    tensor[1, 2, 3]++; //`opIndex` returns reference
    --tensor[1, 2, 3]; //`opUnary`

    ++tensor[];
    tensor[] -= 1;

    // `opIndexAssing` accepts only fully qualified index/slice. Use additional empty slice `[]`.
    static assert(!__traits(compiles), tensor[0..2] *= 2);

    tensor[0..2][] *= 2;        //OK, empty slice
    tensor[0..2, 3, 0..$] /= 2; //OK, 3 index/slice positions are defined.

    //fully qualified index defined by static array
    size_t[3] index = [1, 2, 3];
    assert(tensor[index] == tensor[1, 2, 3]);
}

//example test
unittest {
    auto tensor = createSlice!int(3, 4, 5);
    auto matrix = createSlice!int(3, 4);
    auto vector = createSlice!int(3);

    foreach(i; 0..3)
        vector[i] = i;

    // fill matrix columns
    matrix.transposed[] = vector;

    // fill tensor with vector
    // transposed tensor shape is (4, 5, 3)
    //            vector shape is (      3)
    tensor.transposed!(1, 2)[] = vector;


    // transposed tensor shape is (5, 3, 4)
    //            matrix shape is (   3, 4)
    tensor.transposed!2[] += matrix;

    // transposed tensor shape is (5, 4, 3)
    // transposed matrix shape is (   4, 3)
    tensor.everted[] ^= matrix.transposed; // XOR
}

//example test
unittest {
    import std.algorithm, std.exception, std.format,
        std.functional, std.conv, std.string, std.range;

    Slice!(2, int*) toMatrix(string str)
    {
        string[][] data = str.lineSplitter.filter!(not!empty).map!split.array;
        size_t rows = data.length.enforce("empty input");
        size_t columns = data[0].length.enforce("empty first row");
        data.each!(a => enforce(a.length == columns, "rows have different lengths"));

        auto slice = createSlice!int(rows, columns);
        foreach(i, line; data)
            foreach(j, num; line)
                slice[i, j] = num.to!int;
        return slice;
    }

    auto input = "\r1 2  3\r\n 4 5 6\n";
    auto ouptut = "1 2 3\n4 5 6\n";
    auto fmt = "%(%(%s %)\n%)\n";
    assert(format(fmt, toMatrix(input)) == ouptut);
}

import std.traits;
import std.typecons: Tuple;
import std.meta;
import std.range.primitives;
import core.exception: RangeError;

/++
Creates `n`-dimensional slice-shell over a `range`.
Params:
    range = a random access range or an array; only index operator `auto opIndex(size_t index)` is required for ranges
    lengths = list of lengths for each dimension
    shift = number of the first element in a `range`; first `shift` elements are ignored
See_also: $(LREF createSlice)
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
        assert(len > 0, "sliced: all length must be positive.");
    static if (hasLength!Range)
        assert(lengthsProduct!N(lengths) + shift <= range.length,
            "sliced: range length mast be greater or equal lengths product plus shift");
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

/// Allocators
version(Posix) //Issue 15281
unittest {
    /++
    Allocates array and n-dimensional slice over it.
    Params:
        alloc = allocator, see also $(LINK2 std_experimental_allocator.html, std.experimental.allocator)
        lengths = list of lengths for dimensions
    Returns: `array` created with `alloc` and `slice` over it
    See_also: $(LREF sliced)
    +/

    import std.experimental.allocator;

    auto makeSlice(T, Allocator, Lengths...)(auto ref Allocator alloc, Lengths lengths)
    {
        enum N = Lengths.length;
        struct Result { T[] array; Slice!(N, int*) slice; }
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


private enum _swappedCode = q{
    auto ret = slice;
    with(ret)
    {
        auto tl = _lengths[dimensionA];
        auto ts = _strides[dimensionA];
        _lengths[dimensionA] = _lengths[dimensionB];
        _strides[dimensionA] = _strides[dimensionB];
        _lengths[dimensionB] = tl;
        _strides[dimensionB] = ts;
    }
    return ret;
};

/++
Swaps two dimensions.
See_also: $(LREF everted), $(LREF transposed)
+/
template swapped(size_t dimensionA, size_t dimensionB)
{
    auto swapped(size_t N, Range)(auto ref Slice!(N, Range) slice)
        if (dimensionA < N && dimensionB < N)
    {
        mixin(_swappedCode);
    }
}

/// ditto
auto swapped(size_t N, Range)(auto ref Slice!(N, Range) slice, size_t dimensionA, size_t dimensionB)
in{
    assert(dimensionA < N, "swapped: dimensionA must be less then N");
    assert(dimensionB < N, "swapped: dimensionB must be less then N");
}
body {
    mixin(_swappedCode);
}

/// Template
unittest {
    import std.range: iota;
    assert(10000.iota
        .sliced(3, 4, 5, 6)
        .swapped!(3, 1)
        .shape == [3, 6, 5, 4]);
}

/// Function
unittest {
    import std.range: iota;
    assert(10000.iota
        .sliced(3, 4, 5, 6)
        .swapped(1, 3)
        .shape == [3, 6, 5, 4]);
}

/++
Everts dimensions in the reverse order.
See_also: $(LREF swapped), $(LREF transposed)
+/
auto everted(size_t N, Range)(auto ref Slice!(N, Range) slice)
{
    with(slice)
    {
        This ret = void;
        foreach(i; Iota!(0, N))
        {
            ret._lengths[N-1-i] = _lengths[i];
            ret._strides[N-1-i] = _strides[i];
        }
        foreach(i; Iota!(N, PureN))
        {
            ret._lengths[i] = _lengths[i];
            ret._strides[i] = _strides[i];
        }
        ret._ptr = _ptr;
        return ret;
    }
}

///
unittest {
    import std.range: iota;
    assert(1000.iota
        .sliced(3, 4, 5)
        .everted
        .shape == [5, 4, 3]);
}

private enum _transposedCode = q{
    with(slice)
    {
        This ret = void;
        foreach(i; Iota!(0, N))
        {
            ret._lengths[i] = _lengths[perm[i]];
            ret._strides[i] = _strides[perm[i]];
        }
        foreach(i; Iota!(N, PureN))
        {
            ret._lengths[i] = _lengths[i];
            ret._strides[i] = _strides[i];
        }
        ret._ptr = _ptr;
        return ret;
    }
};

private size_t[N] completeTranspose(size_t N)(in size_t[] tr)
out(res){
    assert(isPermutation(res));
}
body {
    assert(tr.length <= N);
    size_t[N] ctr = void;
    bool[N] mask;
    foreach(i, ref e; tr)
    {
        mask[e] = true;
        ctr[i] = e;
    }
    size_t j = tr.length;
    foreach(i, e; mask)
        if (e == false)
            ctr[j++] = i;
    return ctr;
}

/++
N-dimensional transpose operator.
Brings selected dimensions on top.
Params:
    FrontDimensions = indexes of dimensions
    frontDimensions = indexes of dimensions
    frontDimension = indexes of dimension to bring on top
See_also: $(LREF swapped), $(LREF everted)
+/
template transposed(FrontDimensions...)
    if (FrontDimensions.length)
{
    auto transposed(size_t N, Range)(auto ref Slice!(N, Range) slice)
        if (FrontDimensions.length <= N)
    {
        enum perm = completeTranspose!N([FrontDimensions]);
        mixin(_transposedCode);
    }
}

///ditto
auto transposed(size_t N, Range)(auto ref Slice!(N, Range) slice, size_t frontDimension)
{
    size_t[1] permutation = void;
    permutation[0] = frontDimension;
    immutable perm = completeTranspose!N(permutation);
    mixin(_transposedCode);
}

///ditto
auto transposed(size_t N, Range)(auto ref Slice!(N, Range) slice, in size_t[] frontDimensions...)
{
    assert(frontDimensions.length <= N);
    immutable perm = completeTranspose!N(frontDimensions);
    mixin(_transposedCode);
}

///ditto
auto transposed(Range)(auto ref Slice!(2, Range) slice)
{
    return .transposed!(1, 0)(slice);
}

/// Template
unittest {
    import std.range: iota;
    assert(100000.iota
        .sliced(3, 4, 5, 6, 7)
        .transposed!(4, 1, 0)
        .shape == [7, 4, 3, 5, 6]);
}

/// Function
unittest {
    import std.range: iota;
    assert(100000.iota
        .sliced(3, 4, 5, 6, 7)
        .transposed(4, 1, 0)
        .shape == [7, 4, 3, 5, 6]);
}

/// Function with single argument
unittest {
    import std.range: iota;
    assert(100000.iota
        .sliced(3, 4, 5, 6, 7)
        .transposed(4)
        .shape == [7, 3, 4, 5, 6]);
}

/// `2`-dimensional transpose
unittest {
    import std.range: iota;
    assert(100.iota
        .sliced(3, 4)
        .transposed
        .shape == [4, 3]);
}

private enum _reversedCode = q{
    with(ret)
    {
        _ptr += _strides[dimension] * (_lengths[dimension] - 1);
        _strides[dimension] = -_strides[dimension];
    }
};

/++
Reverses direction of iteration for all dimensions.
+/
auto allReversed(size_t N, Range)(auto ref Slice!(N, Range) slice)
{
    auto ret = slice;
    foreach(dimension; Iota!(0, N))
    {
        mixin(_reversedCode);
    }
    return ret;
}

///
unittest {
    import std.range: iota, retro;
    auto a = 20.iota.sliced(4, 5).allReversed;
    auto b = 20.iota.retro.sliced(4, 5);
    assert(a == b);
}

/++
Reverses direction of the iteration for selected dimensions.
+/
template reversed(Dimensions...)
    if (Dimensions.length)
{
    auto reversed(size_t N, Range)(auto ref Slice!(N, Range) slice)
    {
        auto ret = slice;
        foreach(dimension; Dimensions)
        {
            static assert(dimension < N, "reversed: dimension(" ~ dimension.stringof ~ ") should be less then N(" ~ N.stringof ~ ")");
            mixin(_reversedCode);
        }
        return ret;
    }
}

///ditto
auto reversed(size_t N, Range)(auto ref Slice!(N, Range) slice, size_t dimension)
{
    auto ret = slice;
    assert(dimension < N, "reversed: dimension should be less then N");
    mixin(_reversedCode);
    return ret;
}

///ditto
auto reversed(size_t N, Range)(auto ref Slice!(N, Range) slice, in size_t[] dimensions...)
{
    auto ret = slice;
    foreach(dimension; dimensions)
    {
        assert(dimension < N, "reversed: dimension should be less then N");
        mixin(_reversedCode);
    }
    return ret;
}

///
unittest {
    import std.algorithm.comparison: equal;
    import std.range: iota, retro, chain;
    auto i0 = iota(0,  4); auto r0 = i0.retro;
    auto i1 = iota(4,  8); auto r1 = i1.retro;
    auto i2 = iota(8, 12); auto r2 = i2.retro;
    auto slice = 100.iota.sliced(3, 4);
    assert(slice                   .byElement.equal(chain(i0, i1, i2)));
    // Template
    assert(slice.reversed!(0)      .byElement.equal(chain(i2, i1, i0)));
    assert(slice.reversed!(1)      .byElement.equal(chain(r0, r1, r2)));
    assert(slice.reversed!(0, 1)   .byElement.equal(chain(r2, r1, r0)));
    assert(slice.reversed!(1, 0)   .byElement.equal(chain(r2, r1, r0)));
    assert(slice.reversed!(1, 1)   .byElement.equal(chain(i0, i1, i2)));
    assert(slice.reversed!(0, 0, 0).byElement.equal(chain(i2, i1, i0)));
    // Function
    assert(slice.reversed (0)      .byElement.equal(chain(i2, i1, i0)));
    assert(slice.reversed (1)      .byElement.equal(chain(r0, r1, r2)));
    assert(slice.reversed (0, 1)   .byElement.equal(chain(r2, r1, r0)));
    assert(slice.reversed (1, 0)   .byElement.equal(chain(r2, r1, r0)));
    assert(slice.reversed (1, 1)   .byElement.equal(chain(i0, i1, i2)));
    assert(slice.reversed (0, 0, 0).byElement.equal(chain(i2, i1, i0)));

}

private enum _stridedCode = q{
    assert(factor > 0, "strided: factor must be positive");
    auto ret = slice;
    const rem = ret._lengths[dimension] % factor;
    ret._lengths[dimension] /= factor;
    ret._strides[dimension] *= factor;
    if (rem)
        ret._lengths[dimension]++;
    return ret;
};

/++
Multiplies a stride of selected dimension by the factor.
Params:
    dimension = dimension number
    factor = step extension factor
+/
template strided(size_t dimension)
{
    auto strided(size_t N, Range)(auto ref Slice!(N, Range) slice, size_t factor)
        if (dimension < N)
    body {
        mixin(_stridedCode);
    }
}

///ditto
auto strided(size_t N, Range)(auto ref Slice!(N, Range) slice, size_t dimension, size_t factor)
in {
    assert(dimension < N, "stride: dimension should be less then N");
}
body {
    mixin(_stridedCode);
}

///
unittest {
    import std.algorithm.comparison: equal;
    import std.range: iota, stride, chain;
    auto i0 = iota(0,  4); auto s0 = i0.stride(3);
    auto i1 = iota(4,  8); auto s1 = i1.stride(3);
    auto i2 = iota(8, 12); auto s2 = i2.stride(3);
    auto slice = 100.iota.sliced(3, 4);
    assert(slice              .byElement.equal(chain(i0, i1, i2)));
    // Template
    assert(slice.strided!0(2) .byElement.equal(chain(i0, i2)));
    assert(slice.strided!1(3) .byElement.equal(chain(s0, s1, s2)));
    // Function
    assert(slice.strided(0, 2).byElement.equal(chain(i0, i2)));
    assert(slice.strided(1, 3).byElement.equal(chain(s0, s1, s2)));

    assert(1000.iota.sliced(13, 40).strided!0(2).strided!1(5).shape == [7, 8]);
}

/++
Returns a random access range of all elements of a slice.
+/
auto byElement(size_t N, Range)(auto ref Slice!(N, Range) slice)
{
    with(Slice!(N, Range))
    {
        /++
        ByElement shifts range's `_ptr` without modifying strides and lengths.
        +/
        static struct ByElement
        {

            This _slice;
            size_t _length;
            size_t[N] _indexes;

            static if (isPointer!PureRange || isForwardRange!PureRange)
            auto save() @property
            {
                return typeof(this)(_slice.save, _length, _indexes);
            }

            bool empty() const @property
            {
                return _length == 0;
            }

            size_t length() const @property
            {
                return _length;
            }

            auto ref front() @property
            {
                assert(!this.empty);
                static if (N == PureN)
                    return _slice._ptr[0];
                else with(_slice)
                {
                    alias M = DeepElemType.PureN;
                    return DeepElemType(_lengths[$-M .. $], _strides[$-M .. $], _ptr);
                }
            }

            static if (PureN == 1 && rangeHasMutableElements && !hasAccessByRef)
            auto front(DeepElemType elem) @property
            {
                assert(!this.empty);
                return _slice._ptr[0] = elem;
            }

            void popFront()
            {
                assert(!empty);
                _length--;
                popFrontImpl;
            }

            private void popFrontImpl()
            {
                foreach_reverse(i; Iota!(0, N)) with(_slice)
                {
                    _ptr += _strides[i];
                    _indexes[i]++;
                    if (_indexes[i] < _lengths[i])
                        return;
                    assert(_indexes[i] == _lengths[i]);
                    _ptr -= _lengths[i] * _strides[i];
                    _indexes[i] = 0;
                }
            }

            auto ref back() @property
            {
                assert(!this.empty);
                return opIndex(_length - 1);
            }

            static if (PureN == 1 && rangeHasMutableElements && !hasAccessByRef)
            auto back(DeepElemType elem) @property
            {
                assert(!this.empty);
                return opIndexAssign(_length - 1, elem);
            }

            void popBack()
            {
                assert(!empty);
                _length--;
            }

            void popFrontN(size_t n)
            in {
                assert(n <= _length);
            }
            body {
                _length -= n;
                //calculate shift and new indexes
                sizediff_t _shift;
                n += _indexes[N-1];
                foreach_reverse(i; Iota!(1, N)) with(_slice)
                {
                    immutable v = n / _lengths[i];
                    n %= _lengths[i];
                    _shift += (n - _indexes[i]) * _strides[i];
                    _indexes[i] = n;
                    n = _indexes[i-1] + v;
                }
                assert(n < _slice._lengths[0]);
                with(_slice)
                {
                    _shift += (n - _indexes[0]) * _strides[0];
                    _indexes[0] = n;
                }
                _slice._ptr += _shift;
            }

            void popBackN(size_t n)
            in {
                assert(n <= _length);
            }
            body {
                _length -= n;
            }

            //calculate shift for index n
            private sizediff_t getShift(size_t n)
            in {
                assert(n < _length);
            }
            body {
                sizediff_t _shift;
                n += _indexes[N-1];
                foreach_reverse(i; Iota!(1, N)) with(_slice)
                {
                    immutable v = n / _lengths[i];
                    n %= _lengths[i];
                    _shift += (n - _indexes[i]) * _strides[i];
                    n = _indexes[i-1] + v;
                }
                assert(n < _slice._lengths[0]);
                with(_slice)
                    _shift += (n - _indexes[0]) * _strides[0];
                return _shift;
            }

            auto ref opIndex(size_t index)
            {
                return _slice._ptr[getShift(index)];
            }

            static if (PureN == 1 && rangeHasMutableElements && !hasAccessByRef)
            auto opIndexAssign(DeepElemType elem, size_t index)
            {
                return _slice[getShift(index)] = elem;
            }

            auto opIndex(Tuple!(size_t, size_t) sl)
            {
                auto ret = this;
                ret.popFrontN(sl[0]);
                ret.popBackN(_length - sl[1]);
                return ret;
            }

            alias opDollar = length;

            Tuple!(size_t, size_t) opSlice(size_t pos : 0)(size_t i, size_t j)
            in   {
                assert(i <= j,
                    "ByElement.opSlice: left bound must be less then or equal right bound");
                assert(j - i <= _length,
                    "ByElement.opSlice: difference between right and left bounds must be less then or equal length");
            }
            body {
                return typeof(return)(i, j);
            }
        }
        return ByElement(slice, slice.elementsCount);
    }
}

///Common slice
unittest {
    import std.range: iota;
    import std.algorithm.comparison: equal;
    assert(100.iota
        .sliced(4, 5)
        .byElement
        .equal(20.iota));
}

///Packed slice
unittest {
    import std.range: iota, drop;
    import std.algorithm.comparison: equal;
    assert(100000.iota
        .sliced(3, 4, 5, 6, 7)
        .packed!2
        .byElement()
        .drop(1)
        .front
        .byElement
        .equal(iota(6 * 7, 6 * 7 * 2)));
}

/++
Returns a newly allocated mutable array of all elements int a slice.
+/
Unqual!(ElementType!Range)[] elements(size_t N, Range)(auto ref Slice!(N, Range) slice) @property
{
    import std.array: uninitializedArray;
    with(Slice!(N, Range))
    {
        alias E = Unqual!(ElementType!Range);
        E[] ret = void;
        auto lazyElements = slice.byElement;
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
    import std.algorithm.comparison: equal;
    assert(100.iota
        .sliced(2, 3)
        .elements == [0, 1, 2, 3, 4, 5]);
}

///Packed slice
unittest {
    import std.range: iota, drop;
    import std.algorithm.comparison: equal;
    assert(100000.iota
        .sliced(2, 2, 3)
        .packed!2
        .elements[$-1]
        .elements == [6, 7, 8, 9, 10, 11]);
}

/++
Random access and slicing.
Random access is more expensive comparing with iteration with input range primitives.
+/
unittest {
    import std.range: iota;
    auto elems = 100.iota.sliced(4, 5).byElement;

    elems = elems[11 .. $-2];

    assert(elems.length == 7);
    assert(elems.front == 11);
    assert(elems.back == 17);

    foreach(i; 0..7)
        assert(elems[i] == i+11);
}

unittest {
    import std.range: iota;
    auto elems = 100.iota.sliced(4, 5).byElement;
    static assert(isRandomAccessRange!(typeof(elems)));
    static assert(hasSlicing!(typeof(elems)));
}

// Check strides
unittest {
    import std.range: iota;
    auto elems = 100.iota.sliced(4, 5).everted.byElement;
    static assert(isRandomAccessRange!(typeof(elems)));

    elems = elems[11 .. $-2];
    auto elems2 = elems;
    foreach(i; 0..7)
    {
        assert(elems[i] == elems2.front);
        elems2.popFront;
    }
}

unittest {
    import std.range: iota;
    import std.algorithm.comparison: equal;

    auto range = 100000.iota;
    auto slice0 = range.sliced(3, 4, 5, 6, 7);
    auto slice1 = slice0.transposed!(2, 1).packed!2;
    auto elems0 = slice0.byElement;
    auto elems1 = slice1.byElement;

    foreach(S; AliasSeq!(typeof(elems0), typeof(elems1)))
    {
        static assert(isForwardRange!S);
        static assert(hasLength!S);
    }

    assert(elems0.length == slice0.elementsCount);
    assert(elems1.length == 5 * 4 * 3);

    auto elems2 = elems1;
    foreach(q; slice1)
        foreach(w; q)
            foreach(e; w)
            {
                assert(!elems2.empty);
                assert(e == elems2.front);
                elems2.popFront;
            }
    assert(elems2.empty);

    elems0.popFront();
    elems0.popFrontN(slice0.elementsCount - 14);
    assert(elems0.length == 13);
    assert(elems0.equal(range[slice0.elementsCount-13 .. slice0.elementsCount]));

    foreach(elem; elems0) {}
}

/++
Packs a slice into the composed slice, i.e. slice of slices.
Params:
    K = sizes of packs of dimensions
Returns:
    `packed!K` returns `Slice!(N-K, Slice!(K+1, Range))`;
    `slice.packed!(K1, K2, ..., Kn)` is the same as `slice.pacKed!K1.pacKed!K2. ... pacKed!Kn`.
See_also:  $(LREF unpacked), $(LREF packEverted),  $(LREF byElement).
+/
template packed(K...)
{
    auto packed(size_t N, Range)(Slice!(N, Range) slice)
    {
        template Template(size_t NInner, Range, K...)
        {
            static if (K.length)
            {
                static assert(NInner > K[0]);
                alias Template = Template!(NInner - K[0], Slice!(K[0] + 1, Range), K[1..$]);
            }
            else
            {
                alias Template = Slice!(NInner, Range);
            }
        }
        return Template!(N, Range, K)(slice._lengths, slice._strides, slice._ptr);
    }
}

///
unittest
{
    import std.range: iota;
    import std.algorithm.comparison: equal;
    auto r = 100000000.iota;
    auto a = r.sliced(3, 4, 5, 6, 7, 8, 9, 10, 11);
    auto b = a.packed!(2, 3); // the same as `a.packed!2.packed!3`
    auto c = b[1, 2, 3, 4];
    auto d = c[5, 6, 7];
    auto e = d[8, 9];
    auto g = a[1, 2, 3, 4, 5, 6, 7, 8, 9];
    assert(e == g);
    assert(a == b);
    assert(c == a[1, 2, 3, 4]);
    alias R = typeof(r);
    static assert(is(typeof(b) == typeof(a.packed!2.packed!3)));
    static assert(is(typeof(b) == Slice!(4, Slice!(4, Slice!(3, R)))));
    static assert(is(typeof(c) == Slice!(3, Slice!(3, R))));
    static assert(is(typeof(d) == Slice!(2, R)));
    static assert(is(typeof(e) == ElementType!R));
}

unittest {
    import std.range: iota;
    auto r = 100000000.iota;
    auto a = r.sliced(3, 4, 5, 6, 7, 8, 9, 10, 11);
    auto b = a.packed!(2, 3);
    static assert(b.shape.length == 4);
    static assert(b.structure.lengths.length == 4);
    static assert(b.structure.strides.length == 4);
    static assert(b
        .byElement.front
        .shape.length == 3);
    static assert(b
        .byElement.front
        .byElement.front
        .shape.length == 2);
}

/++
Unpacks a composed slice.
See_also: $(LREF packed), $(LREF packEverted)
+/
auto unpacked(size_t N, Range)(auto ref Slice!(N, Range) slice)
{
    with(slice) return PureThis(_lengths, _strides, _ptr);
}

///
unittest
{
    import std.range: iota;
    import std.algorithm.comparison: equal;
    auto r = 100000000.iota;
    auto a = r.sliced(3, 4, 5, 6, 7, 8, 9, 10, 11);
    auto b = a.packed!(2, 3).unpacked();
    static assert(is(typeof(a) == typeof(b)));
    assert(a == b);
}

/++
Inverts composition of a slice.
This function is used for transposition and in functional pipeline with $(LREF byElement).
See_also: $(LREF packed), $(LREF unpacked)
+/
auto packEverted(size_t N, Range)(auto ref Slice!(N, Range) slice)
{
    with(slice)
    {
        static assert(NSeq.length > 0);
        SliceFromSeq!(PureRange, NSeqEvert!(NSeq)) ret = void;
        alias C = Snowball!(Parts!NSeq);
        alias D = Reverse!(Snowball!(Reverse!(Parts!NSeq)));
        foreach(i, _; NSeq)
        {
            foreach(j; Iota!(0, C[i+1] - C[i]))
            {
                ret._lengths[j+D[i+1]] = _lengths[j+C[i]];
                ret._strides[j+D[i+1]] = _strides[j+C[i]];
            }
        }
        ret._ptr = _ptr;
        return ret;
    }
}

///
unittest {
    import std.range: iota;
    auto slice = 100000000.iota.sliced(3, 4, 5, 6, 7, 8, 9, 10, 11);
    assert(slice
        .packed!2
        .packEverted
        .unpacked
             == slice.transposed!(
                slice.shape.length-2,
                slice.shape.length-1));
}

///
unittest
{
    import std.range: iota;
    import std.algorithm.comparison: equal;
    auto r = 100000000.iota;
    auto a = r.sliced(3, 4, 5, 6, 7, 8, 9, 10, 11);
    auto b = a
        .packed!(2, 3)
        .packEverted;
    auto c = b[8, 9];
    auto d = c[5, 6, 7];
    auto e = d[1, 2, 3, 4];
    auto g = a[1, 2, 3, 4, 5, 6, 7, 8, 9];
    assert(e == g);
    assert(a == b.packEverted);
    assert(c == a.transposed!(7, 8, 4, 5, 6)[8, 9]);
    alias R = typeof(r);
    static assert(is(typeof(b) == Slice!(2, Slice!(4, Slice!(5, R)))));
    static assert(is(typeof(c) == Slice!(3, Slice!(5, R))));
    static assert(is(typeof(d) == Slice!(4, R)));
    static assert(is(typeof(e) == ElementType!R));
}

/++
$(D _N)-dimensional slice-shell over a range.
See_also: $(LREF sliced), $(LREF createSlice), $(LREF ndarray)
+/
struct Slice(size_t _N, _Range)
    if ((!is(Unqual!_Range : Slice!(N0, Range0), size_t N0, Range0)
                 && (isPointer!_Range || is(typeof(_Range.init[size_t.init]) == ElementType!_Range)))
                || is(_Range == Slice!(N1, Range1), size_t N1, Range1))
{
private:

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
        import std.range: iota;
        assert(10000.iota
            .sliced(3, 4, 5, 6, 7)
            .packed!2
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
        import std.typecons: tuple;
        import std.range: iota;
        assert(10000.iota
            .sliced(3, 4, 5, 6, 7)
            .packed!2
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
         auto slice = createSlice!int(2, 3).save;
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
        assert(!empty!dimension);
        _lengths[dimension]--;
        _ptr += _strides[dimension];
    }


    ///ditto
    void popBack(size_t dimension = 0)()
        if (dimension < N)
    {
        assert(!empty!dimension);
        _lengths[dimension]--;
    }

    ///ditto
    void popFrontN(size_t dimension = 0)(size_t n)
        if (dimension < N)
    {
        assert(n <= _lengths[dimension]);
        _lengths[dimension] -= n;
        _ptr += _strides[dimension] * n;
    }

    ///ditto
    void popBackN(size_t dimension = 0)(size_t n)
        if (dimension < N)
    {
        assert(n <= _lengths[dimension]);
        _lengths[dimension] -= n;
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
        slice.popBackN!2(4);
        assert(slice.shape == [9, 19, 26]);

        auto matrix = slice.front!1;
        assert(matrix.shape == [9, 26]);

        auto column = matrix.back!1;
        assert(column.shape == [9]);

        slice.popFrontN!1(slice.length!1);
        assert(slice.empty   == false);
        assert(slice.empty!1 == true);
        assert(slice.empty!2 == false);
        assert(slice.shape == [9, 0, 26]);

        assert(slice.back.front!1.empty);
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
        import std.range: iota;
        auto slice = 50000.iota.sliced(3, 4, 5, 6, 7, 8);
        auto packed = slice.packed!2;
        assert(packed.elementsCount == 360);
        assert(packed[0, 0, 0, 0].elementsCount == 56);
        assert(packed.packEverted.elementsCount == 56);
    }

    Tuple!(size_t, size_t) opSlice(size_t dimension)(size_t i, size_t j)
        if (dimension < N)
    in   {
        assert(i <= j,
            "Slice.opSlice!" ~ dimension.stringof ~ ": left bound must be less then or equal right bound");
        assert(j - i <= _lengths[dimension],
            "Slice.opSlice!" ~ dimension.stringof ~ ": difference between right and left bounds must be less then or equal length");
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
        import std.array: uninitializedArray;
        alias U = Unqual!E[];
        U ret = void;
        static if (__traits(compiles, ret = uninitializedArray!U(_lengths[0])))
        {
            if (__ctfe)
                ret = new U(_lengths[0]);
            else
                ret = uninitializedArray!U(_lengths[0]);
        }
        else
        {
            ret = uninitializedArray!U(_lengths[0]);
        }
        auto sl = this[];
        foreach(ref e; ret)
        {
            e = cast(Unqual!E) sl.front;
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

private:

alias IncFront(Seq...) = AliasSeq!(Seq[0] + 1, Seq[1..$]);
alias DecFront(Seq...) = AliasSeq!(Seq[0] - 1, Seq[1..$]);
alias NSeqEvert(Seq...) = DecFront!(Reverse!(IncFront!Seq));
alias Parts(Seq...) = DecAll!(IncFront!Seq);
alias Snowball(Seq...) = AliasSeq!(size_t.init, SnowballImpl!(size_t.init, Seq));
template SnowballImpl(size_t val, Seq...)
{
    static if (Seq.length == 0)
        alias SnowballImpl = AliasSeq!();
    else
        alias SnowballImpl = AliasSeq!(Seq[0]+val, SnowballImpl!(Seq[0]+val, Seq[1..$]));
}
template DecAll(Seq...)
{
    static if (Seq.length == 0)
        alias DecAll = AliasSeq!();
    else
        alias DecAll = AliasSeq!(Seq[0] - 1, DecAll!(Seq[1..$]));
}
template SliceFromSeq(Range, Seq...)
{
    static if (Seq.length == 0)
        alias SliceFromSeq = Range;
    else
        alias SliceFromSeq = SliceFromSeq!(Slice!(Seq[$-1], Range), Seq[0..$-1]);
}

bool isPermutation(size_t N)(in size_t[N] perm)
{
    if (perm.empty)
        return false;
    immutable n = perm.length;
    bool[N] mask;
    foreach(j; perm)
    {
        if (j >= n)
            return false;
        mask[j] = true;
    }
    foreach(e; mask)
        if (e == false)
            return false;
    return true;
}

enum isIndex(I) = is(I : size_t);
enum isReference(P) =
       isPointer!P
    || isFunctionPointer!P
    || isDelegate!P
    || isDynamicArray!P
    || is(P == interface)
    || is(P == class);
enum hasReference(T) = anySatisfy!(isReference, RepresentationTypeTuple!T);
alias ImplicitlyUnqual(T) = Select!(isImplicitlyConvertible!(T, Unqual!T), Unqual!T, T);

//TODO: replace with static foreach
template Iota(size_t i, size_t j)
{
    static assert(i <= j, "Iota: i>j");
    static if (i == j)
        alias Iota = AliasSeq!();
    else
        alias Iota = AliasSeq!(i, Iota!(i+1, j));
}

private size_t lengthsProduct(size_t N)(auto ref in size_t[N] lengths)
{
    size_t length = lengths[0];
    foreach(i; Iota!(1, N))
            length *= lengths[i];
    return length;
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
    auto tensor = createSlice!int(3, 4, 8);
    assert(&(tensor.back.back.back()) is &tensor[2, 3, 7]);
    assert(&(tensor.front.front.front()) is &tensor[0, 0, 0]);
}

unittest {
    auto slice = createSlice!int(2, 3, 4);
    auto r0 = slice.packed!1[1, 2];
    slice.packed!1[1, 2] = 4;
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
