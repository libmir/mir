/**
$(SCRIPT inhibitQuickIndex = 1;)

Slice operators change only strides and lengths.
A range owned by a slice remains unmodified.
Transpose operators and iteration operators preserve type of a slice. Some operators are bifacial,
i.e they have version with template parameters and version with function parameters.
Versions with template parameters are preferred because compile time checks and optimization reasons.

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
)
Drop operators:
    $(LREF dropToNCube), $(LREF dropBack),
    $(LREF drop), $(LREF dropBack),
    $(LREF dropOne), $(LREF dropBackOne),
    $(LREF dropExactly), $(LREF dropBackExactly),
    $(LREF allDrop), $(LREF allDropBack),
    $(LREF allDropOne), $(LREF allDropBackOne),
    $(LREF allDropExactly), $(LREF allDropBackExactly).

$(H2 Subspace operators)

The destination of subspace operators is iteration over subset of dimensions using $(SUBREF iterators, byElement).
`packed!K` creates a slice of slices `Slice!(N-K, Slice!(K+1, Range))` by packing last `K` dimensions of highest pack of dimensions,
so type of element of `slice.byElement` is `Slice!(K, Range)`.
Another way to use `packed` is transposition of packs of dimensions using `packEverted`.
Examples with subspace operators are available for $(SUBMODULE structure), $(SUBMODULE iterators), $(SUBREF slice, Slice.shape), $(SUBREF slice, .Slice.elementsCount).

$(BOOKTABLE Subspace operators,

$(TR $(TH Function Name) $(TH Description))
$(T2 packed, Type of `1000000.iota.sliced(1,2,3,4,5,6,7,8).packed!2` is `Slice!(6, Slice!(3, typeof(1000000.iota)))`.)
$(T2 unpacked, Restores common type after `packed`.)
$(T2 packEverted, `slice.packed!2.packEverted.unpacked` is identical to `slice.transposed!(slice.shape.length-2, slice.shape.length-1)`.)
)

$(BOOKTABLE $(H2 Bifacial operators),

$(TR $(TH Function Name) $(TH Variadic) $(TH Template) $(TH Function))
$(T4 swapped, No, `slice.swapped!(2, 3)`, `slice.swapped(2, 3)`)
$(T4 strided, Yes/No, `slice.strided!(1, 2)(20, 40)`, `slice.strided(1, 20).strided(2, 40)`)
$(T4 transposed, Yes, `slice.transposed!(1, 4, 3)`, `slice.transposed(1, 4, 3)`)
$(T4 reversed, Yes, `slice.reversed!(0, 2)`, `slice.reversed(0, 2)`)
)

License:   $(WEB www.boost.org/LICENSE_1_0.txt, Boost License 1.0).

Authors:   Ilya Yaroshenko

Source:    $(PHOBOSSRC std/_experimental/_ndslice/_operators.d)

Macros:
SUBMODULE = $(LINK2 std_experimental_ndslice_$1.html, std.experimental.ndslice.$1)
SUBREF = $(LINK2 std_experimental_ndslice_$1.html#.$2, $(TT $2))$(NBSP)
T2=$(TR $(TDNW $(LREF $1)) $(TD $+))
T4=$(TR $(TDNW $(LREF $1)) $(TD $2) $(TD $3) $(TD $4))
*/
module std.experimental.ndslice.operators;

import std.meta;
import std.traits;
import std.experimental.ndslice.internal;
import std.experimental.ndslice.slice;

private enum _swappedCode = q{
    with(slice)
    {
        auto tl = _lengths[dimensionA];
        auto ts = _strides[dimensionA];
        _lengths[dimensionA] = _lengths[dimensionB];
        _strides[dimensionA] = _strides[dimensionB];
        _lengths[dimensionB] = tl;
        _strides[dimensionB] = ts;
    }
    return slice;
};

/++
Swaps two dimensions.
See_also: $(LREF everted), $(LREF transposed)
+/
template swapped(size_t dimensionA, size_t dimensionB)
{
    auto swapped(size_t N, Range)(Slice!(N, Range) slice)
    {
        {
            enum i = 0;
            alias dimension = dimensionA;
            mixin DimensionCTError;
        }
        {
            enum i = 1;
            alias dimension = dimensionB;
            mixin DimensionCTError;
        }
        mixin(_swappedCode);
    }
}

/// ditto
auto swapped(size_t N, Range)(Slice!(N, Range) slice, size_t dimensionA, size_t dimensionB)
in{
    {
        alias dimension = dimensionA;
        mixin(DimensionRTError);
    }
    {
        alias dimension = dimensionB;
        mixin(DimensionRTError);
    }
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

private size_t[N] completeTranspose(size_t N)(in size_t[] dimensions)
{
    assert(dimensions.length <= N);
    size_t[N] ctr;
    uint[N] mask;
    foreach(i, ref dimension; dimensions)
    {
        mask[dimension] = true;
        ctr[i] = dimension;
    }
    size_t j = dimensions.length;
    foreach(i, e; mask)
        if (e == false)
            ctr[j++] = i;
    return ctr;
}

/++
N-dimensional transpose operator.
Brings selected dimensions on top.
Params:
    Dimensions = indexes of dimensions to bring on top
    dimensions = indexes of dimensions to bring on top
    dimension = indexes of dimension to bring on top
See_also: $(LREF swapped), $(LREF everted)
+/
template transposed(Dimensions...)
    if (Dimensions.length)
{
    auto transposed(size_t N, Range)(auto ref Slice!(N, Range) slice)
    {
        mixin DimensionsCountCTError;
        foreach(i, dimension; Dimensions)
            mixin DimensionCTError;
        static assert(isValidPartialPermutation!N([Dimensions]),
            "Failed to complete permutation of dimensions " ~ Dimensions.stringof
            ~ tailErrorMessage!());
        enum perm = completeTranspose!N([Dimensions]);
        static assert(perm.isPermutation, __PRETTY_FUNCTION__ ~ ": internal error.");
        mixin(_transposedCode);
    }
}

///ditto
auto transposed(size_t N, Range)(auto ref Slice!(N, Range) slice, size_t dimension)
in {
    mixin(DimensionRTError);
}
body {
    size_t[1] permutation = void;
    permutation[0] = dimension;
    immutable perm = completeTranspose!N(permutation);
    assert(perm.isPermutation, __PRETTY_FUNCTION__  ~ ": internal error.");
    mixin(_transposedCode);
}

///ditto
auto transposed(size_t N, Range)(auto ref Slice!(N, Range) slice, in size_t[] dimensions...)
in {
    mixin(DimensionsCountRTError);
    foreach(dimension; dimensions)
        mixin(DimensionRTError);
}
body {
    assert(dimensions.isValidPartialPermutation!N,
        "Failed to complete permutation of dimensions."
        ~ tailErrorMessage!());
    immutable perm = completeTranspose!N(dimensions);
    assert(perm.isPermutation, __PRETTY_FUNCTION__ ~ ": internal error.");
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
    with(slice)
    {
        _ptr += _strides[dimension] * (_lengths[dimension] - 1);
        _strides[dimension] = -_strides[dimension];
    }
};

/++
Reverses direction of iteration for all dimensions.
+/
auto allReversed(size_t N, Range)(Slice!(N, Range) slice)
{
    foreach(dimension; Iota!(0, N))
    {
        mixin(_reversedCode);
    }
    return slice;
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
    auto reversed(size_t N, Range)(Slice!(N, Range) slice)
    {
        foreach(i, dimension; Dimensions)
        {
            mixin DimensionCTError;
            mixin(_reversedCode);
        }
        return slice;
    }
}

///ditto
auto reversed(size_t N, Range)(Slice!(N, Range) slice, size_t dimension)
in {
    mixin(DimensionRTError);
}
body {
    mixin(_reversedCode);
    return slice;
}

///ditto
auto reversed(size_t N, Range)(Slice!(N, Range) slice, in size_t[] dimensions...)
in {
    foreach(dimension; dimensions)
        mixin(DimensionRTError);
}
body {
    foreach(dimension; dimensions)
        mixin(_reversedCode);
    return slice;
}

///
unittest {
    import std.experimental.ndslice.iterators;
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
    assert(factor > 0, "factor must be positive"
        ~ tailErrorMessage!());
    immutable rem = slice._lengths[dimension] % factor;
    slice._lengths[dimension] /= factor;
    if(slice._lengths[dimension]) //do not remove `if(...)`
        slice._strides[dimension] *= factor;
    if (rem)
        slice._lengths[dimension]++;
};

/++
Multiplies a stride of selected dimension by the factor.
Params:
    Dimensions = list of dimension numbers
    dimension = dimension number
    factor = step extension factor
+/
template strided(Dimensions...)
    if (Dimensions.length)
{
    auto strided(size_t N, Range)(Slice!(N, Range) slice, Repeat!(size_t, Dimensions.length) factors)
    body {
        foreach(i, dimension; Dimensions)
        {
            mixin DimensionCTError;
            immutable factor = factors[i];
            mixin(_stridedCode);
        }
        return slice;
    }
}

///ditto
auto strided(size_t N, Range)(Slice!(N, Range) slice, size_t dimension, size_t factor)
in {
    mixin(DimensionRTError);
}
body {
    mixin(_stridedCode);
    return slice;
}

///
unittest {
    import std.experimental.ndslice.iterators;
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
    assert(slice.strided!(0, 1)(2, 3).byElement.equal(chain(s0, s2)));
    // Function
    assert(slice.strided(0, 2).byElement.equal(chain(i0, i2)));
    assert(slice.strided(1, 3).byElement.equal(chain(s0, s1, s2)));
    assert(slice.strided(0, 2).strided(1, 3).byElement.equal(chain(s0, s2)));

    static assert(1000.iota.sliced(13, 40).strided!(0, 1)(2, 5).shape == [7, 8]);
    static assert(100.iota.sliced(93).strided!(0, 0)(7, 3).shape == [5]);
}


/++
Packs a slice into the composed slice, i.e. slice of slices.
Params:
    K = sizes of packs of dimensions
Returns:
    `packed!K` returns `Slice!(N-K, Slice!(K+1, Range))`;
    `slice.packed!(K1, K2, ..., Kn)` is the same as `slice.pacKed!K1.pacKed!K2. ... pacKed!Kn`.
See_also:  $(LREF unpacked), $(LREF packEverted),  $(SUBREF iterators, byElement).
+/
template packed(K...)
{
    auto packed(size_t N, Range)(auto ref Slice!(N, Range) slice)
    {
        template Template(size_t NInner, Range, R...)
        {
            static if (R.length > 0)
            {
                static if(NInner > R[0])
                    alias Template = Template!(NInner - R[0], Slice!(R[0] + 1, Range), R[1..$]);
                else
                static assert(0,
                    "Sum of all lengths of packs " ~ K.stringof
                    ~ " should be less then N = "~ N.stringof
                    ~ tailErrorMessage!());

            }
            else
            {
                alias Template = Slice!(NInner, Range);
            }
        }
        with(slice) return Template!(N, Range, K)(_lengths, _strides, _ptr);
    }
}

///
unittest
{
    import std.range.primitives: ElementType;
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
    import std.experimental.ndslice.iterators;
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
    import std.range.primitives: ElementType;
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
Convenience function which calls `slice.popFront!dimension()` for each dimension and returns `slice`.

`allDropBackOne` provides the same functionality but instead calls `slice.popBack!dimension()`.
+/
auto allDropOne(size_t N, Range)(Slice!(N, Range) slice)
{
    foreach(dimension; Iota!(0, N))
        slice.popFront!dimension;
    return slice;
}

///ditto
auto allDropBackOne(size_t N, Range)(Slice!(N, Range) slice)
{
    foreach(dimension; Iota!(0, N))
        slice.popBack!dimension;
    return slice;
}

///
unittest {
    import std.range: iota, retro;
    auto a = 20.iota.sliced(4, 5);

    assert(a.allDropOne[0, 0] == 6);
    assert(a.allDropOne.shape == [3, 4]);
    assert(a.allDropBackOne[$-1, $-1] == 13);
    assert(a.allDropBackOne.shape == [3, 4]);
}

/++
Similar to `allDrop` and `allDropBack` but they call
`slice.popFrontExactly!dimension(n)` and `slice.popBackExactly!dimension(n)` instead.

Note:
Unlike `allDrop`, `allDropExactly` will assume that the slice holds at least n-dimensional cube.
This makes `allDropExactly` faster than `allDrop`.
Only use `allDropExactly` when it is guaranteed that slice
holds at least n-dimensional cube.
+/
auto allDropExactly(size_t N, Range)(Slice!(N, Range) slice, size_t n)
{
    foreach(dimension; Iota!(0, N))
        slice.popFrontExactly!dimension(n);
    return slice;
}

///ditto
auto allDropBackExactly(size_t N, Range)(Slice!(N, Range) slice, size_t n)
{
    foreach(dimension; Iota!(0, N))
        slice.popBackExactly!dimension(n);
    return slice;
}

///
unittest {
    import std.range: iota, retro;
    auto a = 20.iota.sliced(4, 5);

    assert(a.allDropExactly(2)[0, 0] == 12);
    assert(a.allDropExactly(2).shape == [2, 3]);
    assert(a.allDropBackExactly(2)[$-1, $-1] == 7);
    assert(a.allDropBackExactly(2).shape == [2, 3]);
}

/++
Convenience function which calls `slice.popFrontN!dimension(n)` for each dimension and returns slice.

`allDropBack` provides the same functionality but instead calls `slice.popBackN!dimension(n)`.

Note:
`allDrop` and `allDropBack` will only pop up to n elements but will stop if the slice is empty first.
+/
auto allDrop(size_t N, Range)(Slice!(N, Range) slice, size_t n)
{
    foreach(dimension; Iota!(0, N))
        slice.popFrontN!dimension(n);
    return slice;
}

///ditto
auto allDropBack(size_t N, Range)(Slice!(N, Range) slice, size_t n)
{
    foreach(dimension; Iota!(0, N))
        slice.popBackN!dimension(n);
    return slice;
}

///
unittest {
    import std.range: iota, retro;
    auto a = 20.iota.sliced(4, 5);

    assert(a.allDrop(2)[0, 0] == 12);
    assert(a.allDrop(2).shape == [2, 3]);
    assert(a.allDropBack(2)[$-1, $-1] == 7);
    assert(a.allDropBack(2).shape == [2, 3]);

    assert(a.allDrop    (5).shape == [0, 0]);
    assert(a.allDropBack(5).shape == [0, 0]);
}

/++
Convenience function which calls `slice.popFront!dimension()` for selected dimensions and returns `slice`.

`dropBackOne` provides the same functionality but instead calls `slice.popBack!dimension()`.
+/
template dropOne(Dimensions...)
    if (Dimensions.length)
{
    auto dropOne(size_t N, Range)(Slice!(N, Range) slice)
    {
        foreach(i, dimension; Dimensions)
        {
            mixin DimensionCTError;
            slice.popFront!dimension;
        }
        return slice;
    }
}

///ditto
auto dropOne(size_t N, Range)(Slice!(N, Range) slice, size_t dimension)
in {
    mixin(DimensionRTError);
}
body {
    slice.popFront(dimension);
    return slice;
}

///ditto
auto dropOne(size_t N, Range)(Slice!(N, Range) slice, in size_t[] dimensions...)
in {
    foreach(dimension; dimensions)
        mixin(DimensionRTError);
}
body {
    foreach(dimension; dimensions)
        slice.popFront(dimension);
    return slice;
}

///ditto
template dropBackOne(Dimensions...)
    if (Dimensions.length)
{
    auto dropBackOne(size_t N, Range)(Slice!(N, Range) slice)
    {
        foreach(i, dimension; Dimensions)
        {
            mixin DimensionCTError;
            slice.popBack!dimension;
        }
        return slice;
    }
}

///ditto
auto dropBackOne(size_t N, Range)(Slice!(N, Range) slice, size_t dimension)
in {
    mixin(DimensionRTError);
}
body {
    slice.popBack(dimension);
    return slice;
}

///ditto
auto dropBackOne(size_t N, Range)(Slice!(N, Range) slice, in size_t[] dimensions...)
in {
    foreach(dimension; dimensions)
        mixin(DimensionRTError);
}
body {
    foreach(dimension; dimensions)
        slice.popBack(dimension);
    return slice;
}


///
unittest {
    import std.range: iota, retro;
    auto a = 20.iota.sliced(4, 5);

    assert(a.dropOne!(1, 0)[0, 0] == 6);
    assert(a.dropOne (1, 0)[0, 0] == 6);
    assert(a.dropOne!(1, 0).shape == [3, 4]);
    assert(a.dropOne (1, 0).shape == [3, 4]);
    assert(a.dropBackOne!(1, 0)[$-1, $-1] == 13);
    assert(a.dropBackOne (1, 0)[$-1, $-1] == 13);
    assert(a.dropBackOne!(1, 0).shape == [3, 4]);
    assert(a.dropBackOne (1, 0).shape == [3, 4]);

    assert(a.dropOne!(0, 0)[0, 0] == 10);
    assert(a.dropOne (0, 0)[0, 0] == 10);
    assert(a.dropOne!(0, 0).shape == [2, 5]);
    assert(a.dropOne (0, 0).shape == [2, 5]);
    assert(a.dropBackOne!(1, 1)[$-1, $-1] == 17);
    assert(a.dropBackOne (1, 1)[$-1, $-1] == 17);
    assert(a.dropBackOne!(1, 1).shape == [4, 3]);
    assert(a.dropBackOne (1, 1).shape == [4, 3]);
}

unittest {
    import std.range: iota, retro;
    auto a = 20.iota.sliced(4, 5);

    assert(a.dropOne(0).dropOne(0)[0, 0] == 10);
    assert(a.dropOne(0).dropOne(0).shape == [2, 5]);
    assert(a.dropBackOne(1).dropBackOne(1)[$-1, $-1] == 17);
    assert(a.dropBackOne(1).dropBackOne(1).shape == [4, 3]);
}


/++
Similar to `drop` and `dropBack` but they call
`slice.popFrontExactly!dimension(n)` and `slice.popBackExactly!dimension(n)` instead.

Note:
Unlike `drop`, `dropExactly` will assume that the slice holds enough elements in
selected dimension.
This makes `dropExactly` faster than `drop`.
+/
template dropExactly(Dimensions...)
    if (Dimensions.length)
{
    auto dropExactly(size_t N, Range)(Slice!(N, Range) slice, Repeat!(size_t, Dimensions.length) ns)
    body {
        foreach(i, dimension; Dimensions)
        {
            mixin DimensionCTError;
            slice.popFrontExactly!dimension(ns[i]);
        }
        return slice;
    }
}

///ditto
auto dropExactly(size_t N, Range)(Slice!(N, Range) slice, size_t dimension, size_t n)
in {
    mixin(DimensionRTError);
}
body {
    slice.popFrontExactly(dimension, n);
    return slice;
}

///ditto
template dropBackExactly(Dimensions...)
    if (Dimensions.length)
{
    auto dropBackExactly(size_t N, Range)(Slice!(N, Range) slice, Repeat!(size_t, Dimensions.length) ns)
    body {
        foreach(i, dimension; Dimensions)
        {
            mixin DimensionCTError;
            slice.popBackExactly!dimension(ns[i]);
        }
        return slice;
    }
}

///ditto
auto dropBackExactly(size_t N, Range)(Slice!(N, Range) slice, size_t dimension, size_t n)
in {
    mixin(DimensionRTError);
}
body {
    slice.popBackExactly(dimension, n);
    return slice;
}

///
unittest {
    import std.range: iota, retro;
    auto a = 20.iota.sliced(4, 5);

    assert(a.dropExactly    !(1, 0)(2, 3)[0, 0] == 17);
    assert(a.dropExactly    !(1, 0)(2, 3).shape == [1, 3]);
    assert(a.dropBackExactly!(0, 1)(2, 3)[$-1, $-1] == 6);
    assert(a.dropBackExactly!(0, 1)(2, 3).shape == [2, 2]);

    assert(a.dropExactly(1, 2).dropExactly(0, 3)[0, 0] == 17);
    assert(a.dropExactly(1, 2).dropExactly(0, 3).shape == [1, 3]);
    assert(a.dropBackExactly(0, 2).dropBackExactly(1, 3)[$-1, $-1] == 6);
    assert(a.dropBackExactly(0, 2).dropBackExactly(1, 3).shape == [2, 2]);
}

/++
Convenience function which calls `slice.popFrontN!dimension(n)` for each dimension and returns slice.

`dropBack` provides the same functionality but instead calls `slice.popBackN!dimension(n)`.

Note:
`drop` and `dropBack` will only pop up to n elements but will stop if the slice is empty first.
+/
template drop(Dimensions...)
    if (Dimensions.length)
{
    auto drop(size_t N, Range)(Slice!(N, Range) slice, Repeat!(size_t, Dimensions.length) ns)
    body {
        foreach(i, dimension; Dimensions)
        {
            mixin DimensionCTError;
            slice.popFrontN!dimension(ns[i]);
        }
        return slice;
    }
}

///ditto
auto drop(size_t N, Range)(Slice!(N, Range) slice, size_t dimension, size_t n)
in {
    mixin(DimensionRTError);
}
body {
    slice.popFrontN(dimension, n);
    return slice;
}

///ditto
template dropBack(Dimensions...)
    if (Dimensions.length)
{
    auto dropBack(size_t N, Range)(Slice!(N, Range) slice, Repeat!(size_t, Dimensions.length) ns)
    body {
        foreach(i, dimension; Dimensions)
        {
            mixin DimensionCTError;
            slice.popBackN!dimension(ns[i]);
        }
        return slice;
    }
}

///ditto
auto dropBack(size_t N, Range)(Slice!(N, Range) slice, size_t dimension, size_t n)
in {
    mixin(DimensionRTError);
}
body {
    slice.popBackN(dimension, n);
    return slice;
}


///
unittest {
    import std.range: iota, retro;
    auto a = 20.iota.sliced(4, 5);

    assert(a.drop    !(1, 0)(2, 3)[0, 0] == 17);
    assert(a.drop    !(1, 0)(2, 3).shape == [1, 3]);
    assert(a.dropBack!(0, 1)(2, 3)[$-1, $-1] == 6);
    assert(a.dropBack!(0, 1)(2, 3).shape == [2, 2]);
    assert(a.dropBack!(0, 1)(5, 5).shape == [0, 0]);


    assert(a.drop(1, 2).drop(0, 3)[0, 0] == 17);
    assert(a.drop(1, 2).drop(0, 3).shape == [1, 3]);
    assert(a.dropBack(0, 2).dropBack(1, 3)[$-1, $-1] == 6);
    assert(a.dropBack(0, 2).dropBack(1, 3).shape == [2, 2]);
    assert(a.dropBack(0, 5).dropBack(1, 5).shape == [0, 0]);
}

/++
Returns maximal multidimensional cube.
+/
Slice!(N, Range) dropToNCube(size_t N, Range)(Slice!(N, Range) slice)
body {
    size_t length = slice._lengths[0];
    foreach(i; Iota!(1, N))
        if(length > slice._lengths[i])
            length = slice._lengths[i];
    foreach(i; Iota!(0, N))
        slice._lengths[i] = length;
    return slice;
}

///
unittest {
    import std.range: iota, retro;
    assert(1000.iota
        .sliced(5, 4, 6, 7)
        .dropToNCube
        .shape == [4, 4, 4, 4]);
}
