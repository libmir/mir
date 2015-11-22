/**
$(SCRIPT inhibitQuickIndex = 1;)

$(H2 Iterators)

$(BOOKTABLE Subspace iterators,
$(T2 blocks, n-dimensional slice of n-dimensional blocks)
$(T2 diagonal, n-dimensional slice of diagonal)
$(T2 byElement, `100.iota.sliced(4, 5).byElement` equals `20.iota`.)
)

$(TR $(TH Function Name) $(TH Description))
$(T2 pack, Type of `1000000.iota.sliced(1,2,3,4,5,6,7,8).pack!2` is `Slice!(6, Slice!(3, typeof(1000000.iota)))`.)
$(T2 unpack, Restores common type after `pack`.)
$(T2 packEverted, `slice.pack!2.packEverted.unpack` is identical to `slice.transposed!(slice.shape.length-2, slice.shape.length-1)`.)
)

$(H2 Subspace iterators)

The destination of subspace iterators is painless generalization of other iterators.
`pack!K` creates a slice of slices `Slice!(N-K, Slice!(K+1, Range))` by packing last `K` dimensions of highest pack of dimensions,
so type of element of `slice.byElement` is `Slice!(K, Range)`.
Another way to use `pack` is transposition of packs of dimensions using `packEverted`.
Examples with subspace iterators are available for all iterators, $(SUBREF slice, Slice.shape), $(SUBREF slice, .Slice.elementsCount).

$(BOOKTABLE Subspace iterators,

$(TR $(TH Function Name) $(TH Description))
$(T2 pack, Type of `1000000.iota.sliced(1,2,3,4,5,6,7,8).pack!2` is `Slice!(6, Slice!(3, typeof(1000000.iota)))`.)
$(T2 unpack, Restores common type after `pack`.)
$(T2 packEverted, `slice.pack!2.packEverted.unpack` is identical to `slice.transposed!(slice.shape.length-2, slice.shape.length-1)`.)
)

License:   $(WEB www.boost.org/LICENSE_1_0.txt, Boost License 1.0).

Authors:   Ilya Yaroshenko

Source:    $(PHOBOSSRC std/_experimental/_ndslice/_iterators.d)

Macros:
SUBMODULE = $(LINK2 std_experimental_ndslice_$1.html, std.experimental.ndslice.$1)
SUBREF = $(LINK2 std_experimental_ndslice_$1.html#.$2, $(TT $2))$(NBSP)
T2=$(TR $(TDNW $(LREF $1)) $(TD $+))
T4=$(TR $(TDNW $(LREF $1)) $(TD $2) $(TD $3) $(TD $4))
*/
module std.experimental.ndslice.selection;

import std.experimental.ndslice.slice;
import std.experimental.ndslice.internal;
import std.traits;
import std.meta;
import std.range.primitives;

/++
Packs a slice into the composed slice, i.e. slice of slices.
Params:
    K = sizes of packs of dimensions
Returns:
    `pack!K` returns `Slice!(N-K, Slice!(K+1, Range))`;
    `slice.pack!(K1, K2, ..., Kn)` is the same as `slice.pacKed!K1.pacKed!K2. ... pacKed!Kn`.
+/
template pack(K...)
{
    auto pack(size_t N, Range)(auto ref Slice!(N, Range) slice)
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
    auto b = a.pack!(2, 3); // the same as `a.pack!2.pack!3`
    auto c = b[1, 2, 3, 4];
    auto d = c[5, 6, 7];
    auto e = d[8, 9];
    auto g = a[1, 2, 3, 4, 5, 6, 7, 8, 9];
    assert(e == g);
    assert(a == b);
    assert(c == a[1, 2, 3, 4]);
    alias R = typeof(r);
    static assert(is(typeof(b) == typeof(a.pack!2.pack!3)));
    static assert(is(typeof(b) == Slice!(4, Slice!(4, Slice!(3, R)))));
    static assert(is(typeof(c) == Slice!(3, Slice!(3, R))));
    static assert(is(typeof(d) == Slice!(2, R)));
    static assert(is(typeof(e) == ElementType!R));
}

unittest {
    import std.experimental.ndslice.selection;
    import std.range: iota;
    auto r = 100000000.iota;
    auto a = r.sliced(3, 4, 5, 6, 7, 8, 9, 10, 11);
    auto b = a.pack!(2, 3);
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
See_also: $(LREF pack), $(LREF packEverted)
+/
Slice!(N, Range).PureThis unpack(size_t N, Range)(auto ref Slice!(N, Range) slice)
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
    auto b = a.pack!(2, 3).unpack();
    static assert(is(typeof(a) == typeof(b)));
    assert(a == b);
}

/++
Inverts composition of a slice.
This function is used for transposition and in functional pipeline with $(LREF byElement).
See_also: $(LREF pack), $(LREF unpack)
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
    import std.experimental.ndslice.iteration: transposed;
    import std.range: iota;
    auto slice = 100000000.iota.sliced(3, 4, 5, 6, 7, 8, 9, 10, 11);
    assert(slice
        .pack!2
        .packEverted
        .unpack
             == slice.transposed!(
                slice.shape.length-2,
                slice.shape.length-1));
}

///
unittest
{
    import std.experimental.ndslice.iteration: transposed;
    import std.range.primitives: ElementType;
    import std.range: iota;
    import std.algorithm.comparison: equal;
    auto r = 100000000.iota;
    auto a = r.sliced(3, 4, 5, 6, 7, 8, 9, 10, 11);
    auto b = a
        .pack!(2, 3)
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
Returns 1-dimensional slice over main diagonal of n-dimensional slice.
`diagonal` can be enhance with subspace iterators.
Can be used in combination with $(LREF blocks) to get slice of diagonal blocks.
See the last example of how to get diagonal plain in a cube.
+/
Slice!(1, Range) diagonal(size_t N, Range)(auto ref Slice!(N, Range) slice)
{
    size_t[1] length = void;
    sizediff_t[1] stride = void;
    auto NewN = slice.PureN - N + 1;
    typeof(return) ret = void;
    ret._lengths[0] = slice._lengths[0];
    ret._strides[0] = slice._strides[0];
    foreach(i; Iota!(1, N))
    {
        if(ret._lengths[0] > slice._lengths[i])
            ret._lengths[0] = slice._lengths[i];
        ret._strides[0] += slice._strides[i];
    }
    foreach(i; Iota!(1, ret.PureN))
    {
        ret._lengths[i] = slice._lengths[i + N - 1];
        ret._strides[i] = slice._strides[i + N - 1];
    }
    ret._ptr = slice._ptr;
    return ret;
}

/// Matrix, main diagonal
unittest {
    import std.algorithm.comparison: equal;
    import std.range: iota;

    ///-------
    //  -------
    // | 0 1 2 |
    // | 3 4 5 |
    //  -------
    //->
    // | 0 4 |
    assert(10.iota
        .sliced(2, 3)
        .diagonal
        .equal([0, 4]));

    ///-------
    auto slice = new int[9].sliced(3, 3);
    int i;
    foreach(ref e; slice.diagonal)
        e = ++i;
    assert(cast(int[][])slice == [
        [1, 0, 0],
        [0, 2, 0],
        [0, 0, 3]]);
}

/// Matrix, subdiagonal
unittest {
    import std.algorithm.comparison: equal;
    import std.range: iota;
    import std.experimental.ndslice.iteration: dropOne;
    //  -------
    // | 0 1 2 |
    // | 3 4 5 |
    //  -------
    //->
    // | 1 5 |
    assert(10.iota
        .sliced(2, 3)
        .dropOne!1
        .diagonal
        .equal([1, 5]));
}

/// Matrix, antidiagonal
unittest {
    import std.algorithm.comparison: equal;
    import std.range: iota;
    import std.experimental.ndslice.iteration: dropToNCube, reversed;
    //  -------
    // | 0 1 2 |
    // | 3 4 5 |
    //  -------
    //->
    // | 1 3 |
    assert(10.iota
        .sliced(2, 3)
        .dropToNCube
        .reversed!1
        .diagonal
        .equal([1, 3]));
}

/// 3D, main diagonal
unittest {
    import std.algorithm.comparison: equal;
    import std.range: iota;
    //  -----------
    // |  0   1  2 |
    // |  3   4  5 |
    //  - - - - - -
    // |  6   7  8 |
    // |  9  10 11 |
    //  -----------
    //->
    // | 0 10 |
    assert(100.iota
        .sliced(2, 2, 3)
        .diagonal
        .equal([0, 10]));
}

/// 3D, subdiagonal
unittest {
    import std.algorithm.comparison: equal;
    import std.range: iota;
    import std.experimental.ndslice.iteration: dropOne;
    //  -----------
    // |  0   1  2 |
    // |  3   4  5 |
    //  - - - - - -
    // |  6   7  8 |
    // |  9  10 11 |
    //  -----------
    //->
    // | 1 11 |
    assert(100.iota
        .sliced(2, 2, 3)
        .dropOne!2
        .diagonal
        .equal([1, 11]));
}

/// 3D, diagonal plain
unittest {
    import std.algorithm.comparison: equal;
    import std.range: iota;
    import std.experimental.ndslice.iteration: dropOne;
    //  -----------
    // |  0   1  2 |
    // |  3   4  5 |
    // |  6   7  8 |
    //  - - - - - -
    // |  9  10 11 |
    // | 12  13 14 |
    // | 15  16 17 |
    //  - - - - - -
    // | 18  20 21 |
    // | 22  23 24 |
    // | 24  25 26 |
    //  -----------
    //->
    //  -----------
    // |  0   4  8 |
    // |  9  13 17 |
    // | 18  23 26 |
    //  -----------
    auto slice = 100.iota
        .sliced(3, 3, 3)
        .pack!2
        .packEverted
        .diagonal
        .packEverted;
    assert(cast(int[][])slice ==
        [[ 0,  4,  8],
         [ 9, 13, 17],
         [18, 22, 26]]);
}

/++
Returns n-dimensional slice of n-dimensional blocks.
`blocks` can be enhance with subspace iterators.
Can be used in combination with $(LREF diagonal) to get slice of diagonal blocks.
Params:
    N = dimension count
    slice = slice to split on blocks
    lengths = N dimensions for block size, residual blocks are ignored
+/
Slice!(N, Slice!(N+1, Range)) blocks(size_t N, Range)(auto ref Slice!(N, Range) slice, Repeat!(size_t, N) lengths)
in {
    foreach(i, length; lengths)
        assert(length > 0, "length for dimension = " ~ i.stringof ~ " must be positive"
            ~ tailErrorMessage!());
}
body {
    typeof(return) ret = void;
    foreach(dimension; Iota!(0, N))
    {
        ret._lengths[dimension] = slice._lengths[dimension] / lengths[dimension];
        ret._strides[dimension] = slice._strides[dimension];
        if(ret._lengths[dimension]) //do not remove `if(...)`
            ret._strides[dimension] *= lengths[dimension];
        ret._lengths[dimension+N] = lengths[dimension];
        ret._strides[dimension+N] = slice._strides[dimension];
    }
    ret._ptr = slice._ptr;
    return ret;
}

///
unittest {
    auto slice = new int[1000].sliced(5, 8);
    auto blocks = slice.blocks!(2, int*)(2, 3);
    int i;
    foreach(block; blocks.byElement)
        block[] = ++i;

    assert(cast(int[][][][]) blocks ==
        [[[[1, 1, 1], [1, 1, 1]],
          [[2, 2, 2], [2, 2, 2]]],
         [[[3, 3, 3], [3, 3, 3]],
          [[4, 4, 4], [4, 4, 4]]]]);

    assert(cast(int[][])     slice ==
        [[1, 1, 1, 2, 2, 2, 0, 0],
         [1, 1, 1, 2, 2, 2, 0, 0],
         [3, 3, 3, 4, 4, 4, 0, 0],
         [3, 3, 3, 4, 4, 4, 0, 0],
         [0, 0, 0, 0, 0, 0, 0, 0]]);
}

///Diagonal blocks
unittest {
    auto slice = new int[1000].sliced(5, 8);
    auto blocks = slice.blocks!(2, int*)(2, 3);
    auto diagonalBlocks = blocks.diagonal.unpack;

    diagonalBlocks[0][] = 1;
    diagonalBlocks[1][] = 2;

    assert(cast(int[][][])   diagonalBlocks ==
        [[[1, 1, 1],
          [1, 1, 1]],
         [[2, 2, 2],
          [2, 2, 2]]]);

    assert(cast(int[][][][]) blocks ==
        [[[[1, 1, 1], [1, 1, 1]],
          [[0, 0, 0], [0, 0, 0]]],
         [[[0, 0, 0], [0, 0, 0]],
          [[2, 2, 2], [2, 2, 2]]]]);

    assert(cast(int[][])     slice ==
        [[1, 1, 1, 0, 0, 0, 0, 0],
         [1, 1, 1, 0, 0, 0, 0, 0],
         [0, 0, 0, 2, 2, 2, 0, 0],
         [0, 0, 0, 2, 2, 2, 0, 0],
         [0, 0, 0, 0, 0, 0, 0, 0]]);
}

/++
Returns a random access range of all elements of a slice.
See_also: $(LREF elements)
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

            void popFrontExactly(size_t n)
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

            void popBackExactly(size_t n)
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
                ret.popFrontExactly(sl[0]);
                ret.popBackExactly(_length - sl[1]);
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
    import std.algorithm.comparison: equal;
    import std.range: iota;
    assert(100.iota
        .sliced(4, 5)
        .byElement
        .equal(20.iota));
}

///Packed slice
unittest {
    import std.experimental.ndslice.iteration;
    import std.range: iota, drop;
    import std.algorithm.comparison: equal;
    assert(100000.iota
        .sliced(3, 4, 5, 6, 7)
        .pack!2
        .byElement()
        .drop(1)
        .front
        .byElement
        .equal(iota(6 * 7, 6 * 7 * 2)));
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
    import std.experimental.ndslice.iteration;
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
    import std.experimental.ndslice.iteration;
    import std.range: iota;
    import std.algorithm.comparison: equal;

    auto range = 100000.iota;
    auto slice0 = range.sliced(3, 4, 5, 6, 7);
    auto slice1 = slice0.transposed!(2, 1).pack!2;
    auto elems0 = slice0.byElement;
    auto elems1 = slice1.byElement;

    import std.meta;
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
    elems0.popFrontExactly(slice0.elementsCount - 14);
    assert(elems0.length == 13);
    assert(elems0.equal(range[slice0.elementsCount-13 .. slice0.elementsCount]));

    foreach(elem; elems0) {}
}
