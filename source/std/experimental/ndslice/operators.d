/++
Slice operators have a very small computational cost.
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
$(T4 strided, Yes/No, `slice.strided!(1, 2)(20, 40)`, `slice.strided(1, 20).strided(2, 40)`)
$(T4 transposed, Yes, `slice.transposed!(1, 4, 3)`, `slice.transposed(1, 4, 3)`)
$(T4 reversed, Yes, `slice.reversed!(0, 2)`, `slice.reversed(0, 2)`)
)

+/
module std.experimental.ndslice.operators;

import std.meta;
import std.traits;
import std.experimental.ndslice.internal;
import std.experimental.ndslice.slice;

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
auto swapped(size_t N, Range)(auto ref Slice!(N, Range) slice, size_t dimensionA, size_t dimensionB)
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
        foreach(i, dimension; Dimensions)
        {
            mixin DimensionCTError;
            mixin(_reversedCode);
        }
        return ret;
    }
}

///ditto
auto reversed(size_t N, Range)(auto ref Slice!(N, Range) slice, size_t dimension)
in {
    mixin(DimensionRTError);
}
body {
    auto ret = slice;
    mixin(_reversedCode);
    return ret;
}

///ditto
auto reversed(size_t N, Range)(auto ref Slice!(N, Range) slice, in size_t[] dimensions...)
in {
    foreach(dimension; dimensions)
        mixin(DimensionRTError);
}
body {
    auto ret = slice;
    foreach(dimension; dimensions)
        mixin(_reversedCode);
    return ret;
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
    const rem = ret._lengths[dimension] % factor;
    ret._lengths[dimension] /= factor;
    if(ret._lengths[dimension]) //do not remove
        ret._strides[dimension] *= factor;
    if (rem)
        ret._lengths[dimension]++;
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
    auto strided(size_t N, Range)(auto ref Slice!(N, Range) slice, Repeat!(size_t, Dimensions.length) factors)
    body {
        auto ret = slice;
        foreach(i, dimension; Dimensions)
        {
            mixin DimensionCTError;
            immutable factor = factors[i];
            mixin(_stridedCode);
        }
        return ret;
    }
}

///ditto
auto strided(size_t N, Range)(auto ref Slice!(N, Range) slice, size_t dimension, size_t factor)
in {
    mixin(DimensionRTError);
}
body {
    auto ret = slice;
    mixin(_stridedCode);
    return ret;
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
See_also:  $(LREF unpacked), $(LREF packEverted),  $(LREF byElement).
+/
template packed(K...)
{
    auto packed(size_t N, Range)(Slice!(N, Range) slice)
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
        return Template!(N, Range, K)(slice._lengths, slice._strides, slice._ptr);
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
