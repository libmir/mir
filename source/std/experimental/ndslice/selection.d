/**
$(SCRIPT inhibitQuickIndex = 1;)


$(H2 Subspace selectors)

The destination of subspace selectors is painless generalization and combination of other selectors.
`pack!K` creates a slice of slices `Slice!(N-K, Slice!(K+1, Range))` by packing last `K` dimensions of highest pack of dimensions,
so type of element of `slice.byElement` is `Slice!(K, Range)`.
Another way to use `pack` is transposition of packs of dimensions using `evertPack`.
Examples with subspace selectors are available for selectors, $(SUBREF slice, Slice.shape), $(SUBREF slice, .Slice.elementsCount).

$(BOOKTABLE ,

$(TR $(TH Function Name) $(TH Description))
$(T2 pack, returns slice of slices.)
$(T2 unpack, unites all dimension packs.)
$(T2 evertPack, reverse packs of dimensions.)
)

$(BOOKTABLE $(H2 Selectors),

$(TR $(TH Function Name) $(TH Description))
$(T2 blocks, n-dimensional slice of n-dimensional non-overlapping blocks)
$(T2 windows, n-dimensional slice of n-dimensional overlapping  windows)
$(T2 diagonal, 1-dimensional slice of diagonal elements)
$(T2 reshape, returns new slice for the same data)
$(T2 byElement, a random access range of all elements)
$(T2 byElementInStandardSimplex, an input range of standard simplex in hypercube (left upper triangular matrix).)
$(T2 indexSlice, returns a slice with elements equals to initial index.)
)

License:   $(WEB www.boost.org/LICENSE_1_0.txt, Boost License 1.0).

Authors:   Ilya Yaroshenko

Source:    $(PHOBOSSRC std/_experimental/_ndslice/_selection.d)

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
See_also: $(LREF pack), $(LREF evertPack)
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
SliceFromSeq!(Slice!(N, Range).PureRange, NSeqEvert!(Slice!(N, Range).NSeq))
evertPack(size_t N, Range)(auto ref Slice!(N, Range) slice)
{
    mixin _DefineRet;
    static assert(Ret.NSeq.length > 0);
    with(slice)
    {
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
        .evertPack
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
        .evertPack;
    auto c = b[8, 9];
    auto d = c[5, 6, 7];
    auto e = d[1, 2, 3, 4];
    auto g = a[1, 2, 3, 4, 5, 6, 7, 8, 9];
    assert(e == g);
    assert(a == b.evertPack);
    assert(c == a.transposed!(7, 8, 4, 5, 6)[8, 9]);
    alias R = typeof(r);
    static assert(is(typeof(b) == Slice!(2, Slice!(4, Slice!(5, R)))));
    static assert(is(typeof(c) == Slice!(3, Slice!(5, R))));
    static assert(is(typeof(d) == Slice!(4, R)));
    static assert(is(typeof(e) == ElementType!R));
}

/++
Returns 1-dimensional slice over main diagonal of n-dimensional slice.
`diagonal` can be generalized with other selectors, for example
$(LREF blocks)(diagonal blocks) and $(LREF windows) (multi-diagonal slice).
+/
Slice!(1, Range) diagonal(size_t N, Range)(auto ref Slice!(N, Range) slice)
{
    auto NewN = slice.PureN - N + 1;
    mixin _DefineRet;
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
    import std.experimental.ndslice.iteration: dropToHypercube, reversed;
    //  -------
    // | 0 1 2 |
    // | 3 4 5 |
    //  -------
    //->
    // | 1 3 |
    assert(10.iota
        .sliced(2, 3)
        .dropToHypercube
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
        .evertPack
        .diagonal
        .evertPack;
    assert(cast(int[][])slice ==
        [[ 0,  4,  8],
         [ 9, 13, 17],
         [18, 22, 26]]);
}

/++
Returns n-dimensional slice of n-dimensional non-overlapping blocks.
`blocks` can be generalized with other selectors.
For example, `blocks` in combination with $(LREF diagonal) can be used to get slice of diagonal blocks.
Params:
    N = dimension count
    slice = slice to split on blocks
    lengths = N dimensions for block size, residual blocks are ignored
+/
Slice!(N, Slice!(N+1, Range)) blocks(size_t N, Range, Lengths...)(auto ref Slice!(N, Range) slice, Lengths lengths)
    if (allSatisfy!(isIndex, Lengths) && Lengths.length == N)
in {
    foreach(i, length; lengths)
        assert(length > 0, "length for dimension = " ~ i.stringof ~ " must be positive"
            ~ tailErrorMessage!());
}
body {
    mixin _DefineRet;
    foreach(dimension; Iota!(0, N))
    {
        ret._lengths[dimension] = slice._lengths[dimension] / lengths[dimension];
        ret._strides[dimension] = slice._strides[dimension];
        if(ret._lengths[dimension]) //do not remove `if(...)`
            ret._strides[dimension] *= lengths[dimension];
        ret._lengths[dimension+N] = lengths[dimension];
        ret._strides[dimension+N] = slice._strides[dimension];
    }
    foreach(dimension; Iota!(N, slice.PureN))
    {
        ret._lengths[dimension+N] = slice._lengths[dimension];
        ret._strides[dimension+N] = slice._strides[dimension];
    }
    ret._ptr = slice._ptr;
    return ret;
}

///
unittest {
    auto slice = new int[1000].sliced(5, 8);
    auto blocks = slice.blocks(2, 3);
    int i;
    foreach(block; blocks.byElement)
        block[] = ++i;

    assert(cast(int[][][][]) blocks ==
        [[[[1, 1, 1], [1, 1, 1]],
          [[2, 2, 2], [2, 2, 2]]],
         [[[3, 3, 3], [3, 3, 3]],
          [[4, 4, 4], [4, 4, 4]]]]);

    assert(cast(int[][])     slice ==
        [[1, 1, 1,  2, 2, 2,  0, 0],
         [1, 1, 1,  2, 2, 2,  0, 0],

         [3, 3, 3,  4, 4, 4,  0, 0],
         [3, 3, 3,  4, 4, 4,  0, 0],

         [0, 0, 0,  0, 0, 0,  0, 0]]);
}

///Diagonal blocks
unittest {
    auto slice = new int[1000].sliced(5, 8);
    auto blocks = slice.blocks(2, 3);
    auto diagonalBlocks = blocks.diagonal.unpack;

    diagonalBlocks[0][] = 1;
    diagonalBlocks[1][] = 2;

    assert(cast(int[][][])   diagonalBlocks ==
        [[[1, 1, 1], [1, 1, 1]],
         [[2, 2, 2], [2, 2, 2]]]);

    assert(cast(int[][][][]) blocks ==
        [[[[1, 1, 1], [1, 1, 1]],
          [[0, 0, 0], [0, 0, 0]]],
         [[[0, 0, 0], [0, 0, 0]],
          [[2, 2, 2], [2, 2, 2]]]]);

    assert(cast(int[][])     slice ==
        [[1, 1, 1,  0, 0, 0,  0, 0],
         [1, 1, 1,  0, 0, 0,  0, 0],

         [0, 0, 0,  2, 2, 2,  0, 0],
         [0, 0, 0,  2, 2, 2,  0, 0],

         [0, 0, 0, 0, 0, 0, 0, 0]]);
}

///Vertical blocks for matrix
unittest {
    auto slice = new int[1000].sliced(5, 13);
    auto windows = slice
        .pack!1
        .evertPack
        .blocks(3);

    int i;
    foreach(window; windows.byElement)
        window[] = ++i;

    assert(cast(int[][]) slice ==
        [[1, 1, 1,  2, 2, 2,  3, 3, 3,  4, 4, 4,  0],
         [1, 1, 1,  2, 2, 2,  3, 3, 3,  4, 4, 4,  0],
         [1, 1, 1,  2, 2, 2,  3, 3, 3,  4, 4, 4,  0],
         [1, 1, 1,  2, 2, 2,  3, 3, 3,  4, 4, 4,  0],
         [1, 1, 1,  2, 2, 2,  3, 3, 3,  4, 4, 4,  0]]);
}

/++
Returns n-dimensional slice of n-dimensional overlapping windows.
`windows` can be generalized with other selectors.
For example, `windows` in combination with $(LREF diagonal) can be used to get multi-diagonal slice.
Params:
    N = dimension count
    slice = slice to iterate
    lengths = N dimensions for size of the window
+/
Slice!(N, Slice!(N+1, Range)) windows(size_t N, Range, Lengths...)(auto ref Slice!(N, Range) slice, Lengths lengths)
    if (allSatisfy!(isIndex, Lengths) && Lengths.length == N)
in {
    foreach(i, length; lengths)
        assert(length > 0, "length for dimension = " ~ i.stringof ~ " must be positive"
            ~ tailErrorMessage!());
}
body {
    mixin _DefineRet;
    foreach(dimension; Iota!(0, N))
    {
        ret._lengths[dimension] = slice._lengths[dimension] >= lengths[dimension] ? 
                                  slice._lengths[dimension] - lengths[dimension] + 1: 0;
        ret._strides[dimension] = slice._strides[dimension];
        ret._lengths[dimension+N] = lengths[dimension];
        ret._strides[dimension+N] = slice._strides[dimension];
    }
    foreach(dimension; Iota!(N, slice.PureN))
    {
        ret._lengths[dimension+N] = slice._lengths[dimension];
        ret._strides[dimension+N] = slice._strides[dimension];
    }
    ret._ptr = slice._ptr;
    return ret;
}

///
unittest {
    auto slice = new int[1000].sliced(5, 8);
    auto windows = slice.windows(2, 3);
    foreach(window; windows.byElement)
        window[] += 1;

    assert(cast(int[][]) slice ==
        [[1,  2,  3, 3, 3, 3,  2,  1],

         [2,  4,  6, 6, 6, 6,  4,  2],
         [2,  4,  6, 6, 6, 6,  4,  2],
         [2,  4,  6, 6, 6, 6,  4,  2],

         [1,  2,  3, 3, 3, 3,  2,  1]]);
}

///
unittest {
    auto slice = new int[1000].sliced(5, 8);
    auto windows = slice.windows(2, 3);
    windows[1, 2][] = 1;
    windows[1, 2][0, 1] += 1;
    windows.unpack[1, 2, 0, 1] += 1;

    assert(cast(int[][]) slice ==
        [[0, 0,  0, 0, 0,  0, 0, 0],

         [0, 0,  1, 3, 1,  0, 0, 0],
         [0, 0,  1, 1, 1,  0, 0, 0],

         [0, 0,  0, 0, 0,  0, 0, 0],
         [0, 0,  0, 0, 0,  0, 0, 0]]);
}

///Multi-diagonal
unittest {
    auto slice = new int[1000].sliced(8, 8);
    auto windows = slice.windows(3, 3);

    auto multidiagonal = windows
        .diagonal
        .unpack;
    foreach(window; multidiagonal)
        window[] += 1;

    assert(cast(int[][]) slice ==
        [[ 1, 1, 1,  0, 0, 0, 0, 0],
         [ 1, 2, 2, 1,  0, 0, 0, 0],
         [ 1, 2, 3, 2, 1,  0, 0, 0],
         [0,  1, 2, 3, 2, 1,  0, 0],
         [0, 0,  1, 2, 3, 2, 1,  0],
         [0, 0, 0,  1, 2, 3, 2, 1],
         [0, 0, 0, 0,  1, 2, 2, 1],
         [0, 0, 0, 0, 0,  1, 1, 1]]);
}

///Vertical windows for matrix
unittest {
    auto slice = new int[1000].sliced(5, 8);
    auto windows = slice
        .pack!1
        .evertPack
        .windows(3);

    foreach(window; windows.byElement)
        window[] += 1;

    assert(cast(int[][]) slice ==
        [[1,  2,  3, 3, 3, 3,  2,  1],
         [1,  2,  3, 3, 3, 3,  2,  1],
         [1,  2,  3, 3, 3, 3,  2,  1],
         [1,  2,  3, 3, 3, 3,  2,  1],
         [1,  2,  3, 3, 3, 3,  2,  1]]);
}

/++
Returns new slice for the same data.
Params:
    slice = slice to reshape
    lengths = list of new dimensions. Single length can be set to `-1`.
        In this case, the corresponding dimension is inferred.
Throws:
    $(ReshapeException) if `slice` con not be reshaped with `lengths`.
+/
Slice!(Lengths.length, Range)
    reshape
        (         size_t N, Range       , Lengths...     )
        (auto ref Slice!(N, Range) slice, Lengths lengths)
    if ( allSatisfy!(isIndex, Lengths) && Lengths.length)
{
    mixin _DefineRet;
    foreach(i; Iota!(0, ret.N))
        ret._lengths[i] = lengths[i];

    immutable size_t eco = slice.elementsCount;
              size_t ecn = ret  .elementsCount;

    if(eco == 0)
        throw new ReshapeException(
            slice._lengths.dup,
            slice._strides.dup,
            ret.  _lengths.dup,
            "slice should be not empty");

    foreach(i; Iota!(0, ret.N))
        if(ret._lengths[i] == -1)
        {
            ecn = -ecn;
            ret._lengths[i] = eco / ecn;
            ecn *= ret._lengths[i];
            break;
        }

    if(eco != ecn)
        throw new ReshapeException(
            slice._lengths.dup,
            slice._strides.dup,
            ret.  _lengths.dup,
            "total elements count should be the same");

    for(size_t oi, ni, oj, nj; oi < slice.N && ni < ret.N; oi = oj, ni = nj)
    {
        size_t op = slice._lengths[oj++];
        size_t np = ret  ._lengths[nj++];

        for(;;)
        {
            if(op < np)
                op *= slice._lengths[oj++];
            if(op > np)
                np *= ret  ._lengths[nj++];
            if(op == np)
                break;
        }
        while(oj < slice.N && slice._lengths[oj] == 1) oj++;
        while(nj < ret  .N && ret  ._lengths[nj] == 1) nj++;

        for (size_t l = oi, r = oi+1; r < oj; r++)
            if(slice._lengths[r] != 1)
            {
                if(slice._strides[l] != slice._lengths[r] * slice._strides[r])
                    throw new ReshapeException(
                        slice._lengths.dup,
                        slice._strides.dup,
                        ret.  _lengths.dup,
                        "structure is incompatible with new shape");
                l = r;
            }

        ret._strides[nj - 1] = slice._strides[oj - 1];
        foreach_reverse(i; ni .. nj - 1)
            ret._strides[i] = ret._lengths[i+1] * ret._strides[i+1];
    assert((oi == slice.N) == (ni == ret.N));
    }
    foreach(i; Iota!(ret.N, ret.PureN))
    {
        ret._lengths[i] = slice._lengths[i + slcie.N - ret.N];
        ret._strides[i] = slice._strides[i + slcie.N - ret.N];
    }
    ret._ptr = slice._ptr;
    return ret;
}

///
unittest {
    import std.range: iota;
    import std.experimental.ndslice.iteration: allReversed;
    auto slice = 100.iota
        .sliced(3, 4)
        .allReversed
        .reshape(-1, 3);
    assert(cast(int[][]) slice ==
        [[11, 10, 9],
         [ 8,  7, 6],
         [ 5,  4, 3],
         [ 2,  1, 0]]);
}

/// Reshape with memory reallocation
unittest {
    import std.array: array;
    import std.range: iota;
    import std.experimental.ndslice.iteration: reversed;
    auto reshape2(S, L...)(S slice, L lengths)
    {
        // Try to reshape without reallocation
        try return slice.reshape(lengths);
        catch(ReshapeException e)
            //reallocate elements and slice
            //Note: -1 length is not supported by reshape2
            return slice.byElement.array.sliced(lengths);
    }
    auto slice = 100.iota
        .array //cast to array
        .sliced(3, 4)
        .reversed!0;
    assert(cast(int[][]) reshape2(slice, 4, 3) ==
        [[ 8, 9, 10],
         [11, 4,  5],
         [ 6, 7,  0],
         [ 1, 2,  3]]);
}

unittest {
    import std.stdio;
    import std.range: iota;
    import std.experimental.ndslice.iteration: allReversed;
    auto slice = 100.iota.sliced(1, 1, 3, 2, 1, 2, 1).allReversed;
    assert(cast(int[][][][][][])slice.reshape(1, -1, 1, 1, 3, 1) ==
        [[[[[[11], [10], [9]]]],
          [[[[ 8], [ 7], [6]]]],
          [[[[ 5], [ 4], [3]]]],
          [[[[ 2], [ 1], [0]]]]]]);
}

///Exception class for $(LREF reshape).
class ReshapeException: Exception
{
    /// Old lengths
    size_t[] lengths;
    /// Old strides
    sizediff_t[] strides;
    /// New lengths
    size_t[] newLengths;
    ///
    this(
        size_t[] lengths,
        sizediff_t[] strides,
        size_t[] newLengths,
        string msg,
        string file = __FILE__,
        uint line = cast(uint)__LINE__,
        Throwable next = null
        ) pure nothrow @nogc @safe
    {
        super(msg, file, line, next);
        this.lengths = lengths;
        this.strides = strides;
        this.newLengths = newLengths;
    }
}

/++
Returns a random access range of all elements of a slice.
Order of elements is preserved.
`byElement` can be generalized with other selectors.
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

            static if (isForwardRange!This)
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
                static if (NSeq.length == 1)
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
                assert(_length != 0);
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
                    debug(ndslice) assert(_indexes[i] == _lengths[i]);
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
                assert(_length != 0);
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
                debug(ndslice) assert(n < _slice._lengths[0]);
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
                    "left bound must be less then or equal right bound"
                    ~ tailErrorMessage!());
                assert(j - i <= _length,
                    "difference between right and left bounds must be less then or equal length"
                    ~ tailErrorMessage!());
            }
            body {
                return typeof(return)(i, j);
            }

            size_t[N] index() @property
            {
                return _indexes;
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

/// properties
unittest {
    import std.range: iota;
    auto elems = 12.iota.sliced(3, 4).byElement;
    elems.popFrontExactly(2);
    assert(elems.front == 2);
    assert(elems.index == [0, 2]);
    elems.popBackExactly(2);
    assert(elems.back == 9);
    assert(elems.length == 8);
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

/++
Returns an input range of all elements of a slice in standard simplex,
i.g. it is set of elements in left upper triangular matrix in case of 2D slice.
Order of elements is preserved.
`byElementInStandardSimplex` can be generalized with other selectors.
+/
auto byElementInStandardSimplex(size_t N, Range)(auto ref Slice!(N, Range) slice, size_t maxCobeLength = size_t.max)
{
    with(Slice!(N, Range))
    {
        /++
        ByElementInTopSimplex shifts range's `_ptr` without modifying strides and lengths.
        +/
        static struct ByElementInTopSimplex
        {
            This _slice;
            size_t _length;
            size_t maxCobeLength;
            size_t sum;
            size_t[N] _indexes;

            static if (isForwardRange!This)
            auto save() @property
            {
                return typeof(this)(_slice.save, _length, maxCobeLength, sum, _indexes);
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
                static if (NSeq.length == 1)
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
                assert(_length != 0);
                _length--;
                popFrontImpl;
            }

            private void popFrontImpl()
            {
                foreach_reverse(i; Iota!(0, N)) with(_slice)
                {
                    _ptr += _strides[i];
                    _indexes[i]++;
                    debug(ndslice) assert(_indexes[i] <= _lengths[i]);
                    sum++;
                    if (sum < maxCobeLength)
                        return;
                    debug(ndslice) assert(sum == maxCobeLength);
                    _ptr -= _indexes[i] * _strides[i];
                    sum -= _indexes[i];
                    _indexes[i] = 0;
                }
            }

            size_t[N] index() @property
            {
                return _indexes;
            }
        }
        foreach(i; Iota!(0, N))
            if(maxCobeLength > slice._lengths[i])
                maxCobeLength = slice._lengths[i];
        immutable size_t elementsCount = ((maxCobeLength + 1) * maxCobeLength ^^ (N-1)) / 2;
        return ByElementInTopSimplex(slice, elementsCount, maxCobeLength);
    }
}

///
unittest {
    auto slice = new int[20].sliced(4, 5);
    auto elems = slice
        .byElementInStandardSimplex;
    int i;
    foreach(ref e; elems)
        e = ++i;
    assert(cast(int[][]) slice ==
        [[ 1, 2, 3, 4, 0],
         [ 5, 6, 7, 0, 0],
         [ 8, 9, 0, 0, 0],
         [10, 0, 0, 0, 0]]);
}

///
unittest {
    import std.experimental.ndslice.iteration;
    auto slice = new int[20].sliced(4, 5);
    auto elems = slice
        .transposed
        .allReversed
        .byElementInStandardSimplex;
    int i;
    foreach(ref e; elems)
        e = ++i;
    assert(cast(int[][]) slice ==
        [[0,  0, 0, 0, 4],
         [0,  0, 0, 7, 3],
         [0,  0, 9, 6, 2],
         [0, 10, 8, 5, 1]]);
}


/// properties
unittest {
    import std.range: iota;
    auto elems = 12.iota.sliced(3, 4).byElementInStandardSimplex;
    elems.popFront;
    assert(elems.front == 1);
    assert(elems.index == [0, 1]);
    import std.range: popFrontN;
    elems.popFrontN(3);
    assert(elems.front == 5);
    assert(elems.index == [1, 1]);
    assert(elems.length == 2);
}



/++
Returns the slice with elements equals to initial index.
See_also: $(LREF IndexSlice)
+/
IndexSlice!(Lengths.length) indexSlice(Lengths...)(Lengths lengths)
    if (allSatisfy!(isIndex, Lengths))
{
    return .indexSlice!(Lengths.length)([lengths]);
}

///ditto
IndexSlice!N indexSlice(size_t N)(auto ref size_t[N] lengths)
{
    with(typeof(return)) return Range(lengths[1..$]).sliced(lengths);
}

///
unittest {
    auto im = indexSlice(7,9);

    assert(im[2, 1] == [2, 1]);

    for(auto elems = im.byElement; !elems.empty; elems.popFront)
        assert(elems.front == elems.index);

    //slicing works correctly
    auto cm = im[1..$-3, 4..$-1];
    assert(cm[2, 1] == [3, 5]);
}

/++
Slice of indexes.
See_also: $(LREF indexSlice)
+/
template IndexSlice(size_t N)
    if(N)
{
    struct IndexMap
    {
        private size_t[N-1] _lengths;

        auto save() @property const {
            return this;
        }

        size_t[N] opIndex(size_t index) const
        {
            size_t[N] indexes = void;
            foreach_reverse(i; Iota!(0, N-1))
            {
                indexes[i + 1] = index % _lengths[i];
                index /= _lengths[i];
            }
            indexes[0] = index;
            return indexes;
        }
    }
    alias IndexSlice = Slice!(N, IndexMap);
}

///
unittest {
    alias IS4 = IndexSlice!4;
    static assert(is(IS4 == Slice!(4, Range), Range));
}

unittest {
    auto r = indexSlice(1);
}

