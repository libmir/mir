/++
This module provides basic utilities for creating n-dimensional random access ranges.

License:   $(WEB www.boost.org/LICENSE_1_0.txt, Boost License 1.0).
Authors:   Ilya Yaroshenko
Source:    $(PHOBOSSRC std/_experemental/_range_ndslice.d)
+/
module std.experimental.range.ndslice;

import std.traits;
import std.typetuple;
import std.range.primitives;
import core.exception: RangeError;


/++
N-dimensional slice-shell over the range.
+/
struct Slice(size_t N, Range)
{

    import std.typecons: Tuple;

private:

    size_t[N] lengths;
    size_t[N] strides;
    Range _range;

    import std.compiler: version_minor;
    static if (version_minor >= 68)
        mixin("pragma(inline, true):");

    enum rangeHasMutableElements = isPointer!Range ||
        __traits(compiles, { _range.front = _range.front.init; } );

    enum hasAccessByRef = isPointer!Range ||
        __traits(compiles, { auto a = &(_range.front()); } );

    enum PureIndexLength(Slices...) = Filter!(isIndex, Slices).length;

    enum isFullPureIndex(Indexes...) =
           Indexes.length == N
        && allSatisfy!(isIndex, Indexes);

    enum isPureSlice(Slices...) = 
           Slices.length <= N
        && PureIndexLength!Slices < N;

    enum isFullPureSlice(Slices...) = 
           Slices.length == 0
        || Slices.length == N
        && PureIndexLength!Slices < N;

    @property size_t backIndex(size_t pos = 0)() @safe pure nothrow const
        if (pos < N)
    {
        return strides[pos] * (lengths[pos] - 1);
    }

    size_t indexStride(Indexes...)(Indexes indexes) @safe pure
        if (isFullPureIndex!Indexes)
    {
        size_t stride;
        foreach(i, index; indexes) //static
        {
            version(assert) if(index >= lengths[i]) throw new RangeError();
            stride += strides[i] * index;
        }
        return stride;
    }

public:

    @property size_t[N]
    shape() @safe pure nothrow @nogc const
    {
        return lengths;
    }

    @property Tuple!(size_t[N], "lengths", size_t[N], "strides")
    structure() @safe pure nothrow @nogc const
    {
        return typeof(return)(lengths, strides);
    }

    @property auto save()
    {
        static if (isPointer!Range)
            return Slice!(N, Range)(strides, lengths, _range);
        else
            return Slice!(N, typeof(_range.save()))(strides, lengths, _range.save);
    }

    @property bool empty(size_t pos = 0)() @safe pure nothrow @nogc const
        if (pos < N)
    {
        return lengths[pos] == 0;
    }

    @property size_t length(size_t pos = 0)() @safe pure nothrow @nogc const
        if (pos < N)
    {
        return lengths[pos];
    }
    alias opDollar = length;

    @property size_t stride(size_t pos = 0)() @safe pure nothrow @nogc const
        if (pos < N)
    {
        return strides[pos];
    }

    auto ref opIndex(Indexes...)(Indexes indexes)
        if (isFullPureIndex!Indexes)
    {
        return _range[indexStride(indexes)];
    }

    static if(isPointer!Range)
    {
        @property inout(Range) ptr() @safe pure nothrow @nogc inout
        {
            return _range;
        }
    }
    else
    {
        @property auto range()
        {
            return _range;
        }
    }

    static if (N == 1)
    {
        @property auto ref front(size_t pos = 0)()
            if (pos == 0)
        {
            version (assert) if (empty) throw new RangeError();
            static if (isPointer!Range)
                return *_range;
            else
                return _range.front;
        }

        @property auto ref back(size_t pos = 0)()
            if (pos == 0)
        {
            version (assert) if (empty) throw new RangeError();
            return _range[backIndex];
        }
    }

    void popBack(size_t pos = 0)()
        if (pos < N)
    {
        version (assert) if (empty!pos) throw new RangeError();
        lengths[pos]--;
    }

    void popBackN(size_t pos = 0)(size_t n)
        if (pos < N)
    {
        version (assert) if (n > lengths[pos]) throw new RangeError();
        lengths[pos] -= n;
    }

    static if (rangeHasMutableElements)
    {
        auto ref opIndexAssign(T, Indexes...)(T value, Indexes indexes)
            if (isFullPureIndex!Indexes)
        {
            return _range[indexStride(indexes)] = value;
        }

        auto ref opIndexOpAssign(string op, T, Indexes...)(T value, Indexes indexes)
            if (isFullPureIndex!Indexes)
        {
            mixin("return _range[indexStride(indexes)] " ~ op ~ "= value;");
        }

        static if (!hasAccessByRef && N == 1)
        {
            @property void front(size_t pos = 0, T)(T value)
                if (pos == 0)
            {
                version (assert) if (empty) throw new RangeError();
                _range.front = value;
            }

            @property void back(size_t pos = 0, T)(T value)
                if (pos == 0)
            {
                version (assert) if (empty) throw new RangeError();
                _range[backIndex] = value;
            }
        }
    }


    T opCast(T : E[], E)()
    {
        static if (version_minor >= 68)
            mixin("pragma(inline);");

        import std.array: uninitializedArray;
        alias U = Unqual!E[];
        U ret = void;
        if(__ctfe)
            ret = new U(lengths[0]);
        else
            ret = uninitializedArray!U(lengths[0]);
        auto sl = this[];
        foreach(ref e; ret)
        {
            e = cast(Unqual!E) sl.front;
            sl.popFront;
        }
        return cast(T)ret;
    }


    static if (isPointer!Range || is(Range == typeof(_range[0..$])))
    {
        auto byElement() @property
        {
            static struct ByElementRange
            {
                static if (isPointer!Range)
                    Slice!(N, Range) slice;
                else
                    Slice!(N, typeof(range)) slice;
            }
        }

        void popFront(size_t pos = 0)()
            if (pos < N)
        {
            version (assert) if (empty!pos) throw new RangeError();
            lengths[pos]--;
            static if (isPointer!Range)
                _range += strides[pos];
            else
                _range.popFrontN(strides[pos]);
        }

        void popFrontN(size_t pos = 0)(size_t n)
            if (pos < N)
        {
            version (assert) if (n > lengths[pos]) throw new RangeError();
            lengths[pos] -= n;
            static if (isPointer!Range)
                _range += strides[pos] * n;
            else
                _range.popFrontN(strides[pos] * n);
        }

        static if (N > 1)
        {
            private enum sideStr = 
            q{
                size_t[N-1] slLengths = void;
                size_t[N-1] slStrides = void;
                foreach(i; 0 .. pos) //TODO: static foreach
                {
                    slLengths[i] = lengths[i];
                    slStrides[i] = strides[i];
                }
                foreach(i; pos .. N-1) //TODO: static foreach
                {
                    slLengths[i] = lengths[i + 1];
                    slStrides[i] = strides[i + 1];
                }
            };

            @property Slice!(N-1, Range) front(size_t pos = 0)()
                if (pos < N)
            {
                version (assert) if (empty!pos) throw new RangeError();
                mixin(sideStr);
                return typeof(return)(slLengths, slStrides, _range);
            }

            @property Slice!(N-1, Range) back(size_t pos = 0)()
                if (pos < N)
            {
                version (assert) if (empty!pos) throw new RangeError();
                mixin(sideStr);
                static if (isPointer!Range)
                    return typeof(return)(slLengths, slStrides, _range + backIndex!pos);
                else
                    return typeof(return)(slLengths, slStrides, _range[backIndex!pos..$]);
            }
        }

        size_t[2] opSlice(size_t pos)(size_t i, size_t j) @safe pure
            if (pos < N)
        in   { 
            if (i > j || j - i > lengths[pos]) throw new RangeError();
        }
        body { 
            return [i, j]; 
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
                size_t[N-F] slLengths = void;
                size_t[N-F] slStrides = void;
                foreach(i, slice; slices) //static
                {
                    static if (isIndex!(Slices[i]))
                    {
                        version(assert) if(slice >= lengths[i]) throw new RangeError();
                        stride += strides[i] * slice;
                    }
                    else
                    {
                        stride += strides[i] * slice[0];
                        slLengths[j!i] = slice[1] - slice[0];
                        slStrides[j!i] = strides[i];
                    }
                }
                foreach(i; S .. N) //TODO: static foreach
                {
                    slLengths[i-F] = lengths[i];
                    slStrides[i-F] = strides[i];
                }        
                static if (isPointer!Range)
                    return Slice!(N-F, Range)(slLengths, slStrides, _range + stride);
                else
                    return Slice!(N-F, Range)(slLengths, slStrides, _range[stride .. $]);
            }
            else
            {
                static if(isPointer!Range)
                    return cast(Slice!(N, Range)) this;
                else
                    return Slice!(N, Range)(lengths, strides, _range[]);
            }
        }

        static if (rangeHasMutableElements)
        {
            void opIndexAssign(T, Slices...)(T value, Slices slices)
                if (isFullPureSlice!Slices)
            {
                auto sl = this[slices];
                enum M = sl.lengths.length;
                static if(is(T : Slice!(M, _t), _t))
                    version(assert) if (sl.lengths != value.lengths) throw new RangeError();
                static if (M == 1)
                {
                    for(; sl.length; sl.popFront)
                    {
                        static if(is(T : Slice!(M, _), _))
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
                        static if(is(T : Slice!(M, _), _))
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

            static if (hasAccessByRef)
            {
                void opIndexUnary(string op, Slices...)(Slices slices)
                    if (isFullPureSlice!Slices && op == "++" || op == "--")
                {
                    static if (N - PureIndexLength!Slices == 1)
                        foreach(ref v; this[slices])
                            mixin(op ~ "v;");
                    else
                        foreach(v; this[slices])
                            mixin(op ~ "v[];");
                }

                void opIndexOpAssign(string op, T, Slices...)(T value, Slices slices)
                    if (isFullPureSlice!Slices)
                {
                    auto sl = this[slices];
                    enum M = sl.lengths.length;
                    static if(is(T : Slice!(M, _t), _t))
                        version(assert) if (sl.lengths != value.lengths) throw new RangeError();
                    static if (M == 1)
                    {
                        foreach(ref v; sl)
                        {
                            static if(is(T : Slice!(M, _), _))
                            {
                                mixin("v " ~ op ~ "= value.front;");
                                value.popFront;
                            }
                            else
                            {
                                mixin("v " ~ op ~ "= value;");
                            }
                        }
                    }
                    else
                    {
                        foreach(v; sl)
                        {
                            static if(is(T : Slice!(M, _), _))
                            {
                                mixin("v[] " ~ op ~ "= value.front;");
                                value.popFront;
                            }
                            else
                            {
                                mixin("v[] " ~ op ~ "= value;");
                            }
                        }
                    }
                }
            }
        }
    }
}

/++
Creates n-dimensional slice-shell over the `range`.
+/
auto sliced(Range, Lengths...)(Range range, Lengths lengths)
    if (!isStaticArray!Range && !isNarrowString!Range
        && (isPointer!Range
            || hasSlicing!(ImplicitlyUnqual!Range)
            && isRandomAccessRange!(ImplicitlyUnqual!Range))
        && allSatisfy!(isIndex, Lengths) && Lengths.length)
in {
    foreach(len; lengths)
        if(len <= 0) throw new RangeError();
    static if (hasLength!Range)
    {
        size_t length = 1;
        foreach(len; lengths)
            length *= len;
        if(length > range.length) throw new RangeError();
    }
}
body {
    enum N = Lengths.length;
    size_t[N] _lengths = void;
    size_t[N] strides = void;
    size_t stride = 1;
    foreach_reverse(i, length; lengths) //static
    {
        _lengths[i] = length;
        strides[i] = stride;
        stride *= length;
    }
    static if (isDynamicArray!Range)
        return Slice!(N, typeof(range.ptr))(_lengths, strides, range.ptr);
    else
        return Slice!(N, ImplicitlyUnqual!(typeof(range)))(_lengths, strides, range);
}

/// Slicing
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

/// Operator overloading. # 1
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

/// Operator overloading. # 2
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
            if(i >= 3 && i < 6 && j == 2)
                assert(matrix[i, j] >= 100);
            else
                assert(matrix[i, j] < 100);
}

/// Operator overloading. # 3
unittest {
    import std.algorithm.comparison: equal;
    import std.algorithm.iteration: map;
    import std.array: array;
    import std.range;

    auto matrix = 100
        .iota
        .array
        .sliced(8, 9);
    assert(matrix.equal(matrix));

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

/// Properties and methods
unittest {
    import std.range: iota;
    auto tensor = 100.iota.sliced(3, 4, 5);
    static assert(isRandomAccessRange!(typeof(tensor)));

    // `save` method
    // Calls `range.save`
    auto a = tensor.save;
    static assert(is(typeof(a) == typeof(tensor)));

    // `length` property
    assert(tensor.length   == 3);
    assert(tensor.length!0 == 3);
    assert(tensor.length!1 == 4);
    assert(tensor.length!2 == 5);

    // `front` and `back` properties
    // and `popFront`, `popBack`, 
    // `popFrontN` and `popBackN` methods
    auto matrix = tensor.back;
    matrix.popBack!1;
    auto column = matrix.back!1;
    column.popFrontN(3);
    auto elem = column.front!0;
    assert(elem == tensor[$-1, 3, $-2]);

    // `stride` property
    assert(tensor.stride   == 20);
    assert(tensor.stride!0 == 20);
    assert(tensor.stride!1 ==  5);
    assert(tensor.stride!2 ==  1);

    assert(matrix.stride   ==  5);
    assert(matrix.stride!1 ==  1);
    
    matrix = tensor.back!2;
    assert(matrix.stride   == 20);
    assert(matrix.stride!1 ==  5);

    // `structure` property
    auto structure = tensor.structure;
    assert(tensor.length!2 == structure.lengths[2]);
    assert(tensor.stride!1 == structure.strides[1]);
    import std.typecons: Tuple;
    alias Structure = Tuple!(size_t[3], "lengths", size_t[3], "strides");
    static assert(is(typeof(structure) == Structure));

    // `shape` property
    assert(tensor.shape == structure.lengths);

    // `range` method
    auto theIota0 = tensor.range;
    assert(theIota0.front == 0);
    tensor.popFront;
    auto theIota1 = tensor.range;
    assert(theIota1.front == 20);

    // `ptr` property
    import std.array: array;
    auto ar = 100.iota.array;
    auto ts = ar.sliced(3, 4, 5)[1..$, 2..$, 3..$];
    assert(ts.ptr is ar.ptr + 1*20+2*5+3*1);
}

/// Conversion
unittest {
    import std.range: iota;
    auto matrix = 4.iota.sliced(2, 2);
    auto arrays = cast(float[][]) matrix;
    assert(arrays == [[0f, 1f], [2f, 3f]]);

    import std.conv;
    auto ars = matrix.to!(immutable double[][]); //calls opCast
}

/// Type conversion
unittest {
    foreach(T; TypeTuple!(int, const int, immutable int))
        static assert(is(typeof((T[]).init.sliced(3, 4)) == Slice!(2, T*)));
    
    import std.container.array;
    Array!int ar;
    static assert(is(typeof(ar[].sliced(3, 4)) == Slice!(2, typeof(ar[]))));

    import std.range: iota;
    auto      i0 = 100.iota;
    const     i1 = 100.iota; 
    immutable i2 = 100.iota;
    alias S = Slice!(3, typeof(iota(0))); //unqualified range
    // const/immutable Iota is implicitly convertable to unqualified type
    foreach(i; TypeTuple!(i0, i1, i2))
        static assert(is(typeof(i.sliced(3, 4, 5)) == S));
}

/++
Creates D array and n-dimensional slice over it.
+/
auto createSlice(T, Lengths...)(Lengths lengths)
{
    size_t length = 1;
    foreach(len; lengths)
        length *= len;
    return (new T[length]).sliced(lengths);
}


/++
N-dimenstional transpose operator.
+/
template transposed(Permutation...)
    if (Permutation.length)
{
    auto transposed(size_t N, Range)(auto ref Slice!(N, Range) slice)
    {
        //import std.compiler;
        //static if (version_minor >= 68)
        //    mixin("pragma(inline, true);");
        
        size_t[N] tLengths = void;
        size_t[N] tStrides  = void;
        with(slice) foreach(i, p; completeTranspose!N([Permutation])) //TODO: static foreach
        {
            tLengths[i] = lengths[p];
            tStrides[i] = strides[p];
        }
        return Slice!(N, Range)(tLengths, tStrides, slice._range);
    }
}

///ditto
auto transposed(size_t N, Range)(auto ref Slice!(N, Range) slice, in size_t[] permutation...)
{
    version (assert) if(permutation.length > N) throw new RangeError();
    size_t[N] tLengths = void;
    size_t[N] tStrides  = void;
    with(slice) foreach(i, p; completeTranspose!N(permutation))
    {
        tLengths[i] = lengths[p];
        tStrides[i] = strides[p];
    }
    return Slice!(N, Range)(tLengths, tStrides, slice._range);
}

///
unittest {
    import std.range: iota;
    auto t0 = 1000.iota.sliced(3, 4, 5);
    auto t1 = t0.transposed!(2, 0, 1); //CTFE - recommended
    auto t2 = t0.transposed (2, 0, 1); //Runtime
    assert(t0[1, 2, 3] == t1[3, 1, 2]);
    assert(t0[1, 2, 3] == t2[3, 1, 2]);
    static assert(is(typeof(t0) == typeof(t1)));
    static assert(is(typeof(t0) == typeof(t2)));
}

/// Partially defined transpose
unittest {
    import std.range: iota;
    auto tensor0 = 1000.iota.sliced(3, 4, 5, 6);
    auto tensor1 = tensor0.transposed!(3, 1); // CTFE
    auto tensor2 = tensor0.transposed (1, 3); // Runtime
    assert(tensor1.shape == [6, 4, 3, 5]);
    assert(tensor2.shape == [4, 6, 3, 5]);
}

/++
2-dimenstional transpose operator.
+/
auto transposed(Range)(auto ref Slice!(2, Range) slice)
{
    import std.compiler;
    //static if (version_minor >= 68)
    //    mixin("pragma(inline, true);");
    return .transposed!(1, 0)(slice);
}

///
unittest {
    import std.range: iota;
    auto t0 = 1000.iota.sliced(3, 4);
    auto t1 = t0.transposed();      //CTFE
    auto t2 = t0.transposed!(1, 0); //CTFE
    assert(t0[1, 2] == t1[2, 1]);
    assert(t0[1, 2] == t2[2, 1]);
    static assert(is(typeof(t0) == typeof(t1)));
    static assert(is(typeof(t0) == typeof(t2)));
}

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
    size_t j = ctr.length - tr.length;
    foreach(i, e; mask)
        if(e == false)
            ctr[j++] = i;
    return ctr;
}


private enum swappedStr = q{
    auto ret = slice;
    with(ret)
    {
        auto tl = lengths[i];
        auto ts = strides[i];
        lengths[i] = lengths[j];    
        strides[i] = strides[j];
        lengths[j] = tl;
        strides[j] = ts;
    }
    return ret;
};

/// Swap dimensions
template swapped(size_t i, size_t j)
{
    auto swapped(size_t N, Range)(auto ref Slice!(N, Range) slice)
    {
        mixin(swappedStr);
    }
}

/// ditto
auto swapped(size_t N, Range)(auto ref Slice!(N, Range) slice, size_t i, size_t j)
{
    mixin(swappedStr);
}


/// Creates common N-dimensional array
auto ndarray(size_t N, Range)(auto ref Slice!(N, Range) slice)
{
    import std.array: array;
    static if(N == 1)
        return slice.array;
    else
    {
        import std.algorithm: map;
        return slice.map!(.ndarray).array;
    }
}

///
unittest {
    import std.range: iota;
    auto ar = 1000.iota.sliced(3, 4).ndarray;
    static assert(is(typeof(ar) == int[][]));
    assert(ar == [[0,1,2,3], [4,5,6,7], [8,9,10,11]]);
}

private bool isPermutation(size_t N)(in size_t[N] perm...) @safe pure nothrow
{
    if(perm.empty)
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
        if(e == false)
            return false;
    return true;
}
private enum isIndex(I) = is(I : size_t);
private alias ImplicitlyUnqual(T) = Select!(isImplicitlyConvertible!(T, Unqual!T), Unqual!T, T);


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
    import std.algorithm.comparison: equal;
    import std.array: array;
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
    auto tensor = createSlice!int(3, 4, 8);
    assert(&(tensor.back.back.back()) is &tensor[2, 3, 7]);
    assert(&(tensor.front.front.front()) is &tensor[0, 0, 0]);
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
