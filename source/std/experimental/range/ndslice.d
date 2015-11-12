/++
This module provides basic utilities for creating n-dimensional random access ranges.

License:   $(WEB www.boost.org/LICENSE_1_0.txt, Boost License 1.0).
Authors:   Ilya Yaroshenko
Source:    $(PHOBOSSRC std/_experemental/_range/_ndslice.d)
+/
module std.experimental.range.ndslice;

import std.traits;
import std.typetuple;
import std.range.primitives;
import core.exception: RangeError;


private bool opEqualsImpl
    (size_t NL, RangeL, size_t NR, RangeR)(
    auto ref Slice!(NL, RangeL) lslice,
    auto ref Slice!(NR, RangeR) rslice)
in {
    assert(lslice._lengths == rslice._lengths);
}
body {
    auto ls = lslice.save;
    auto rs = rslice.save;
    while(!ls.empty)
    {
        static if (Slice!(NL, RangeL).PureN == 1)
        {
            if (ls.front != rs.front)
                return false;
        }
        else
        {
            if (!opEqualsImpl(ls, rs))
                return false;
        }
        rs.popFront;
        ls.popFront;
    }
    return true;
}

private struct PtrShell(Range)
{
    sizediff_t _shift;
    Range _range;

    enum hasAccessByRef = isPointer!Range ||
        __traits(compiles, { auto a = &(_range[0]); } );

    //alias _range this;

    void opOpAssign(string op)(sizediff_t shift)
        if (op == "+" || op == "-")
    {
        mixin("_shift " ~ op ~ "= shift;");
    }

    auto opBinary(string op)(sizediff_t shift)
        if (op == "+" || op == "-")
    {
        mixin("return typeof(this)(_shift " ~ op ~ " shift, _range);");
    }

    auto ref opIndex(size_t index)
    in {
        assert(_shift + index >= 0);
        static if(!isInfinite!Range)
            assert(_shift + index <= _range.length);
    }
    body {
        return _range[_shift + index];
    }

    static if(!hasAccessByRef)
    {
        auto ref opIndexAssign(T)(T value, size_t index)
        in {
            assert(_shift + index >= 0);
            static if(!isInfinite!Range)
                assert(_shift + index <= _range.length);
        }
        body {
            return _range[_shift + index] = value;
        }

        auto ref opIndexOpAssign(string op, T)(T value, size_t index)
        in {
            assert(_shift + index >= 0);
            static if(!isInfinite!Range)
                assert(_shift + index <= _range.length);
        }
        body {
            mixin("return _range[_shift + index] " ~ op ~ "= value;");
        }

        auto ref opIndexUnary(string op)(size_t index)
            if (op == "++" || op == "--")
         in {
            assert(_shift + index >= 0);
            static if(!isInfinite!Range)
                assert(_shift + index <= _range.length);
        }
        body {
            mixin("return " ~ op ~ "_range[_shift + index];");
        }
    }

    static if (isForwardRange!Range)
    auto save() @property
    {
        return typeof(this)(_shift, _range.save);
    }
}

private auto ptrShell(Range)(Range range, sizediff_t shift = 0)
{
    return PtrShell!Range(shift, range);
}

version(none)
unittest {
    import std.internal.test.dummyrange;
    foreach(RB; TypeTuple!(ReturnBy.Reference, ReturnBy.Value))
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

/++
$(D _N)-dimensional slice-shell over the $(D _Range).
See_also: $(LREF sliced), $(LREF createSlice), $(LREF ndarray)
+/
struct Slice(size_t _N, _Range)
    if (!(is(Unqual!_Range : Slice!(_N0, _Range0), size_t _N0, _Range0)
            && (isPointer!_Range
                || isInputRange!_Range 
                    && is(typeof(_Range.init[size_t.init]) == ElementType!_Range)))
        || is(_Range == Slice!(_N1, _Range1), size_t _N1, _Range1))
{

    import std.typecons: Tuple;

private:

    alias N = _N;
    alias Range = _Range;
    alias This = Slice!(N, Range);
    static if (is(Range == Slice!(N_, Range_), size_t N_, Range_))
    {
        enum size_t PureN = N + Range.PureN - 1;
        alias PureRange = Range.PureRange;
        alias NSeq = TypeTuple!(N, Range.NSeq);
    }
    else
    {
        alias PureN = N;
        alias PureRange = Range;
        alias NSeq = N;
    }
    alias PureThis = Slice!(PureN, PureRange);

    static assert(PureN < 256);

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

    size_t[PureN] _lengths;
    sizediff_t[PureN] _strides;
    static if(isPointer!PureRange)
        PureRange _ptr;
    else
        PtrShell!PureRange _ptr;

    import std.compiler: version_minor;
    static if (version_minor >= 68)
        mixin("pragma(inline, true):");

    size_t backIndex(size_t pos = 0)()
    @property @safe pure nothrow @nogc const
        if (pos < N)
    {
        return _strides[pos] * (_lengths[pos] - 1);
    }

    size_t indexStride(Indexes...)(Indexes _indexes) @safe pure
        if (isFullPureIndex!Indexes)
    {
        size_t stride;
        foreach(i, index; _indexes) //static
        {
            version(assert) if (index >= _lengths[i]) throw new RangeError();
            stride += _strides[i] * index;
        }
        return stride;
    }

    size_t elementsCount()
    @safe pure nothrow @nogc const
    {
        size_t len = 1;
        foreach(l; _lengths[0..N]) //TODO: static foreach
            len *= l;
        return len;
    }

public:

    ///
    this(ref in size_t[PureN] lengths, ref in sizediff_t[PureN] strides, PureRange range)
    {
        foreach(i; 0..PureN) //TODO: static foreach
            _lengths[i] = lengths[i];
        foreach(i; 0..PureN) //TODO: static foreach
            _strides[i] = strides[i];
        static if(isPointer!PureRange)
            _ptr = range;
        else
            _ptr._range = range;

    }

    static if(!isPointer!PureRange)
    private this(ref in size_t[PureN] lengths, ref in sizediff_t[PureN] strides, PtrShell!PureRange shell)
    {
        foreach(i; 0..PureN) //TODO: static foreach
            _lengths[i] = lengths[i];
        foreach(i; 0..PureN) //TODO: static foreach
            _strides[i] = strides[i];
        _ptr = shell;
    }

    ///
    size_t[N] shape()
    @property @safe pure nothrow @nogc const
    {
        return _lengths[0..N];
    }

    ///
    Tuple!(size_t[N], "lengths", sizediff_t[N], "strides")
    structure()
    @property @safe pure nothrow @nogc const
    {
        return typeof(return)(_lengths[0..N], _strides[0..N]);
    }

    ///
    static if (isPointer!PureRange || isForwardRange!PureRange)
    auto save() @property
    {
        static if (isPointer!PureRange)
            return typeof(this)(_lengths, _strides, _ptr);
        else
            return typeof(this)(_lengths, _strides, _ptr.save);
    }

    ///
    size_t length(size_t pos = 0)()
    @property @safe pure nothrow @nogc const
        if (pos < N)
    {
        return _lengths[pos];
    }
    alias opDollar = length;

    ///
    size_t stride(size_t pos = 0)()
    @property @safe pure nothrow @nogc const
        if (pos < N)
    {
        return _strides[pos];
    }

    static if (N == PureN)
    {
        static if (isPointer!PureRange)
        {
            ///
            inout(PureRange) ptr() @safe pure nothrow @nogc @property inout
            {
                return _ptr;
            }
        }
        static if (!isPointer!PureRange)
        {
            ///
            PureRange range() @property
            {
                return _ptr._range;
            }
        }
    }

    ///
    bool empty(size_t pos = 0)()
    @property @safe pure nothrow @nogc const
        if (pos < N)
    {
        return _lengths[pos] == 0;
    }

    ///
    auto ref front(size_t pos = 0)() @property
        if (pos < N)
    {
        version (assert) if (empty) throw new RangeError();
        static if (PureN == 1)
        {
            return _ptr[0];
        }
        else
        {
            ElemType ret = void;
            foreach(i; 0 .. pos) //TODO: static foreach
            {
                ret._lengths[i] = _lengths[i];
                ret._strides[i] = _strides[i];
            }
            foreach(i; pos .. PureN-1) //TODO: static foreach
            {
                ret._lengths[i] = _lengths[i + 1];
                ret._strides[i] = _strides[i + 1];
            }
            ret._ptr = _ptr;
            return ret;
        }
    }

    ///
    auto ref back(size_t pos = 0)() @property
        if (pos < N)
    {
        version (assert) if (empty) throw new RangeError();
        static if (PureN == 1)
        {
            return _ptr[backIndex];
        }
        else
        {
            ElemType ret = void;
            foreach(i; 0 .. pos) //TODO: static foreach
            {
                ret._lengths[i] = _lengths[i];
                ret._strides[i] = _strides[i];
            }
            foreach(i; pos .. PureN-1) //TODO: static foreach
            {
                ret._lengths[i] = _lengths[i + 1];
                ret._strides[i] = _strides[i + 1];
            }
            ret._ptr = _ptr + backIndex!pos;
            return ret;
        }
    }

    ///
    auto ref front(size_t pos = 0, T)(T value) @property
        if (PureN == 1 && rangeHasMutableElements && !hasAccessByRef && pos == 0)
    {
        version (assert) if (empty) throw new RangeError();
        return _ptr.front = value;
    }

    ///
    auto ref back(size_t pos = 0, T)(T value) @property
        if (PureN == 1 && rangeHasMutableElements && !hasAccessByRef && pos == 0)
    {
        version (assert) if (empty) throw new RangeError();
        return _ptr[backIndex] = value;
    }

    ///
    void popFront(size_t pos = 0)()
        if (pos < N)
    {
        version (assert) if (empty!pos) throw new RangeError();
        _lengths[pos]--;
        _ptr += _strides[pos];
    }

    ///
    void popFrontN(size_t pos = 0)(size_t n)
        if (pos < N)
    {
        version (assert) if (n > _lengths[pos]) throw new RangeError();
        _lengths[pos] -= n;
        _ptr += _strides[pos] * n;
    }

    ///
    void popBack(size_t pos = 0)()
        if (pos < N)
    {
        version (assert) if (empty!pos) throw new RangeError();
        _lengths[pos]--;
    }

    ///
    void popBackN(size_t pos = 0)(size_t n)
        if (pos < N)
    {
        version (assert) if (n > _lengths[pos]) throw new RangeError();
        _lengths[pos] -= n;
    }

    size_t[2] opSlice(size_t pos)(size_t i, size_t j) @safe pure
        if (pos < N)
    in   {
        if (i > j || j - i > _lengths[pos]) throw new RangeError();
    }
    body {
        return [i, j];
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
                    version(assert) if (slice >= _lengths[i]) throw new RangeError();
                    stride += _strides[i] * slice;
                }
                else
                {
                    stride += _strides[i] * slice[0];
                    ret._lengths[j!i] = slice[1] - slice[0];
                    ret._strides[j!i] = _strides[i];
                }
            }
            foreach(i; S .. PureN) //TODO: static foreach
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
                version(assert) if (sl._lengths != value._lengths) throw new RangeError();
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

        auto ref opIndexOpAssign(string op, T, Indexes...)(T value, Indexes _indexes)
            if (isFullPureIndex!Indexes)
        {
            static if (N == PureN)
                mixin("return _ptr[indexStride(_indexes)] " ~ op ~ "= value;");
            else
                mixin("return DeepElemType(_lengths[N..$], _strides[N..$], _ptr + indexStride(_indexes))[] " ~ op ~ "= value;");
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
                enum M = sl._lengths.length;
                static if (is(T : Slice!(M, _t), _t))
                    version(assert) if (sl._lengths != value._lengths) throw new RangeError();
                static if (M == 1)
                {
                    foreach(ref v; sl)
                    {
                        static if (is(T : Slice!(M, _), _))
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
                        static if (is(T : Slice!(M, _), _))
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

    import std.format: FormatSpec, formatValue; //TODO add more format options
    void toString(scope void delegate(const(char)[]) sink, FormatSpec!char fmt)
    {
        sink("[");
        if(this.length)
        {
            auto r = this.save;
            sink.formatValue(r.front, fmt);
            r.popFront;
            foreach(e; r)
            {
                sink(", ");
                sink.formatValue(e, fmt);
            }
        }
        sink("]");
    }

    ///
    T opCast(T : E[], E)()
    {
        static if (version_minor >= 68)
            mixin("pragma(inline);");
        import std.array: uninitializedArray;
        alias U = Unqual!E[];
        U ret = void;
        if (__ctfe)
            ret = new U(_lengths[0]);
        else
            ret = uninitializedArray!U(_lengths[0]);
        auto sl = this[];
        foreach(ref e; ret)
        {
            e = cast(Unqual!E) sl.front;
            sl.popFront;
        }
        return cast(T)ret;
    }

    ///
    auto byElement()
    {
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

            bool empty() const @property @safe pure nothrow
            {
                return _length == 0;
            }

            size_t length() const @property @safe pure nothrow
            {
                return _length;
            }

            void popFront()
            {
                assert(!empty);
                _length--;
                foreach_reverse(i; 0..N) with(_slice) //TODO: static foreach
                {
                    _slice._ptr += _strides[i];
                    _indexes[i]++;
                    if (_indexes[i] < _lengths[i])
                        break;
                    assert(_indexes[i] == _lengths[i]);
                    _slice._ptr -= _lengths[i] * _strides[i];
                    _indexes[i] = 0;
                }
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
        }
        return ByElement(this, this.elementsCount);
    }
}

/++
Creates $(D n)-dimensional slice-shell over the $(D range).
+/
auto sliced(Range, Lengths...)(Range range, Lengths lengths)
    if (!isStaticArray!Range && !isNarrowString!Range
        && allSatisfy!(isIndex, Lengths) && Lengths.length)
in {
    foreach(len; lengths)
        if (len <= 0) throw new RangeError();
    static if (hasLength!Range)
    {
        size_t length = 1;
        foreach(len; lengths)
            length *= len;
        if (length > range.length) throw new RangeError();
    }
}
body {
    enum N = Lengths.length;
    size_t[N] _lengths = void;
    sizediff_t[N] _strides = void;
    size_t stride = 1;
    foreach_reverse(i, length; lengths) //static
    {
        _lengths[i] = length;
        _strides[i] = stride;
        stride *= length;
    }
    static if (isDynamicArray!Range)
        return Slice!(N, typeof(range.ptr))(_lengths, _strides, range.ptr);
    else
        return Slice!(N, ImplicitlyUnqual!(typeof(range)))(_lengths, _strides, range);
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
            if (i >= 3 && i < 6 && j == 2)
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
    alias Structure = Tuple!(size_t[3], "lengths", sizediff_t[3], "strides");
    static assert(is(typeof(structure) == Structure));

    // `shape` property
    assert(tensor.shape == structure.lengths);

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

/// Iterating with $(D byElement) method.
unittest {
    import std.range: iota;
    import std.algorithm.comparison: equal;

    auto range = 100000.iota;
    auto slice0 = range.sliced(3, 4, 5, 6, 7);
    auto slice1 = slice0.transposed!(2, 1).packed!2;
    auto elems0 = slice0.byElement;
    auto elems1 = slice1.byElement;
    enum size_t L = 3 * 4 * 5 * 6 * 7;

    foreach(S; TypeTuple!(typeof(elems0), typeof(elems1)))
    {
        static assert(isForwardRange!S);
        static assert(hasLength!S);
    }

    assert(elems0.length == L);
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
    elems0.popFrontN(L - 14);
    assert(elems0.length == 13);
    assert(elems0.equal(range[L-13 .. L]));

    foreach(elem; elems0) {}
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

/// Type deduction
unittest {
    //Arrays
    foreach(T; TypeTuple!(int, const int, immutable int))
        static assert(is(typeof((T[]).init.sliced(3, 4)) == Slice!(2, T*)));

    //Container Array
    import std.container.array;
    Array!int ar;
    static assert(is(typeof(ar[].sliced(3, 4)) == Slice!(2, typeof(ar[]))));

    //An implicitly convertable types to it's unqualified type.
    import std.range: iota;
    auto      i0 = 100.iota;
    const     i1 = 100.iota;
    immutable i2 = 100.iota;
    alias S = Slice!(3, typeof(iota(0)));
    foreach(i; TypeTuple!(i0, i1, i2))
        static assert(is(typeof(i.sliced(3, 4, 5)) == S));
}


/++
Creates array and n-dimensional slice over it.
See_also: $(LREF ndarray)
+/
auto createSlice(T, Lengths...)(Lengths _lengths)
{
    size_t length = 1;
    foreach(len; _lengths)
        length *= len;
    return (new T[length]).sliced(_lengths);
}

/++
Creates a common N-dimensional array.
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
        import std.algorithm: map;
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

/++
Revers the direction of the iteration for a `Slice`.
+/
template reversed(Indexes...)
    if (Indexes.length)
{
    auto reversed(size_t N, Range)(auto ref Slice!(N, Range) slice)
    {

        auto ret = slice;
        foreach(index; Indexes) 
        {
            static assert(index < N, "reversed: index(" ~ index.stringof ~ ") should be less then N(" ~ N.stringof ~ ")");
            with(ret)  
            {
                _ptr += _strides[index] * (_lengths[index] - 1);
                _strides[index] = -_strides[index];
            }
        }
        return ret;
    }
}

///
unittest {
    import std.range: iota;
    
    auto a = 100.iota.sliced(3, 4);
    assert(a.ndarray == [[0, 1, 2, 3], [4, 5, 6, 7], [8, 9, 10, 11]]);
    
    a = a.reversed!0;
    assert(a.ndarray == [[8, 9, 10, 11], [4, 5, 6, 7], [0, 1, 2, 3]]);
    
    a = a.reversed!(0, 1);
    assert(a.ndarray == [[3, 2, 1, 0], [7, 6, 5, 4], [11, 10, 9, 8]]);
    
    a = a.reversed!(1, 1, 0, 0, 0, 0);
    assert(a.ndarray == [[3, 2, 1, 0], [7, 6, 5, 4], [11, 10, 9, 8]]);
}

/++
ditto
+/
auto reversed(size_t N, Range)(auto ref Slice!(N, Range) slice, in size_t[] indexes...)
{
    auto ret = slice;
    foreach(index; indexes) 
    {
        assert(index < N, "reversed: index should be less then N");
        with(ret)  
        {
            _ptr += _strides[index] * (_lengths[index] - 1);
            _strides[index] = -_strides[index];
        }
    }
    return ret;
}

///
unittest {
    import std.range: iota;
    
    auto a = 100.iota.sliced(3, 4);
    assert(a.ndarray == [[0, 1, 2, 3], [4, 5, 6, 7], [8, 9, 10, 11]]);
   
    a = a.reversed(0);
    assert(a.ndarray == [[8, 9, 10, 11], [4, 5, 6, 7], [0, 1, 2, 3]]);
   
    a = a.reversed(0, 1);
    assert(a.ndarray == [[3, 2, 1, 0], [7, 6, 5, 4], [11, 10, 9, 8]]);
   
    a = a.reversed(1, 1, 0, 0, 0, 0);
    assert(a.ndarray == [[3, 2, 1, 0], [7, 6, 5, 4], [11, 10, 9, 8]]);
}

/++
ditto
+/
auto allIndexesReversed(size_t N, Range)(auto ref Slice!(N, Range) slice)
{
    auto ret = slice;
    foreach(index; 0..N) //TODO static foreach 
    {
        with(ret)  
        {
            _ptr += _strides[index] * (_lengths[index] - 1);
            _strides[index] = -_strides[index];
        }
    }
    return ret;
}

///
unittest {
    import std.range: iota;

    auto a = 100.iota.sliced(3, 4);
    a = a.allIndexesReversed;
    assert(a.ndarray == [[11, 10, 9, 8], [7, 6, 5, 4], [3, 2, 1, 0]]);

    auto p = a.packed!1;
    p = p.allIndexesReversed;
    a = p.unpacked;
    assert(a.ndarray == [[3, 2, 1, 0], [7, 6, 5, 4], [11, 10, 9, 8]]);
}

/++
Iterates range r with stride n. 
+/
auto strided(size_t N, Range)(auto ref Slice!(N, Range) slice, size_t dim, size_t n)
in {
    assert(dim < N, "stride: dim should be less then N");
}
body {
    auto ret = slice;
    with(ret)
    {
        const rem =_lengths[dim] % n;
        _lengths[dim] /= n;
        _strides[dim] *= n;        
        if(rem)
            _lengths[dim]++;
    }
    return ret;
}

///
unittest {
    import std.range: iota;
    
    auto a = 100.iota.sliced(3, 4);
    assert(a.ndarray == [[0, 1, 2, 3], [4, 5, 6, 7], [8, 9, 10, 11]]);
   
    a = a.strided(0, 2);
    assert(a.ndarray == [[0, 1, 2, 3], [8, 9, 10, 11]]);
   
    a = a.strided(1, 3);
    assert(a.ndarray == [[0, 3], [8, 11]]);
}


/++
N-dimensional transpose operator.
See_also: $(LREF swapped), $(LREF everted)
+/
template transposed(Permutation...)
    if (Permutation.length)
{
    auto transposed(size_t N, Range)(auto ref Slice!(N, Range) slice)
    {
        with(slice)
        {
            This ret = void;
            enum perm = completeTranspose!N([Permutation]);
            foreach(i, p; perm) //TODO: static foreach
            {
                ret._lengths[i] = _lengths[p];
                ret._strides[i] = _strides[p];
            }
            foreach(i; N .. PureN) //TODO: static foreach
            {
                ret._lengths[i] = _lengths[i];
                ret._strides[i] = _strides[i];
            }
            ret._ptr = _ptr;
            return ret;
        }
    }
}

///ditto
auto transposed(size_t N, Range)(auto ref Slice!(N, Range) slice, in size_t[] permutation...)
{
    version (assert) if (permutation.length > N) throw new RangeError();
    with(slice)
    {
        This ret = void;
        foreach(i, p; completeTranspose!N(permutation))
        {
            ret._lengths[i] = _lengths[p];
            ret._strides[i] = _strides[p];
        }
        foreach(i; N .. PureN) //TODO: static foreach
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
    auto tensor1 = tensor0.transposed!(3, 1); // CTFE - recommended
    auto tensor2 = tensor0.transposed (1, 3); // Runtime
    assert(tensor1.shape == [6, 4, 3, 5]);
    assert(tensor2.shape == [4, 6, 3, 5]);
}

/++
2-dimenstional transpose operator.
See_also: $(LREF swapped), $(LREF everted)
+/
auto transposed(Range)(auto ref Slice!(2, Range) slice)
{
    return .transposed!(1, 0)(slice);
}

///
unittest {
    import std.range: iota;
    auto t0 = 1000.iota.sliced(3, 4);
    auto t1 = t0.transposed();
    auto t2 = t0.transposed!(1, 0);
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
    size_t j = tr.length;
    foreach(i, e; mask)
        if (e == false)
            ctr[j++] = i;
    return ctr;
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
        foreach(i; 0..N) //TODO: static foreach
        {
            ret._lengths[N-1-i] = _lengths[i];
            ret._strides[N-1-i] = _strides[i];
        }
        foreach(i; N .. PureN) //TODO: static foreach
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
    auto tensor0 = 1000.iota.sliced(3, 4, 5, 6);
    auto tensor1 = tensor0.everted;
    assert(tensor0.shape == [3, 4, 5, 6]);
    assert(tensor1.shape == [6, 5, 4, 3]);
}

private enum swappedStr = q{
    auto ret = slice;
    with(ret)
    {
        auto tl = _lengths[i];
        auto ts = _strides[i];
        _lengths[i] = _lengths[j];
        _strides[i] = _strides[j];
        _lengths[j] = tl;
        _strides[j] = ts;
    }
    return ret;
};

/++
Swaps dimensions.
See_also: $(LREF swapped), $(LREF transposed)
+/
template swapped(size_t i, size_t j)
{
    auto swapped(size_t N, Range)(auto ref Slice!(N, Range) slice)
        if (i < N && j < N)
    {
        mixin(swappedStr);
    }
}

/// ditto
auto swapped(size_t N, Range)(auto ref Slice!(N, Range) slice, size_t i, size_t j)
{
    version (assert) if (i >= N || j >= N) throw new RangeError();
    mixin(swappedStr);
}

///
unittest {
    import std.range: iota;
    auto tensor0 = 1000.iota.sliced(3, 4, 5, 6);
    auto tensor1 = tensor0.swapped!(3, 1); // CTFE
    auto tensor2 = tensor0.swapped (1, 3); // Runtime
    assert(tensor1.shape == [3, 6, 5, 4]);
    assert(tensor2.shape == [3, 6, 5, 4]);
}


/++
Packs a slice into the composed slice.
See_also:  $(LREF unpacked), $(LREF packEverted).
+/
template packed(Indexes...)
{
    auto packed(size_t N, Range)(Slice!(N, Range) slice)
    {
        template Template(size_t NInner, Range, Indexes...)
        {
            static if (Indexes.length)
            {
                static assert(NInner > Indexes[0]);
                alias Template = Template!(NInner - Indexes[0], Slice!(Indexes[0] + 1, Range), Indexes[1..$]);
            }
            else
            {
                alias Template = Slice!(NInner, Range);
            }
        }
        return Template!(N, Range, Indexes)(slice._lengths, slice._strides, slice._ptr);
    }
}

///
unittest
{
    import std.range: iota;
    import std.algorithm.comparison: equal;
    auto r = 10000000000.iota;
    auto a = r.sliced(3, 4, 5, 6, 7, 8, 9, 10, 11);
    auto b = a.packed!(2, 3);
    auto c = b[1, 2, 3, 4];
    auto d = c[5, 6, 7];
    auto e = d[8, 9];
    auto g = a[1, 2, 3, 4, 5, 6, 7, 8, 9];
    assert(e == g);
    assert(a == b);
    assert(c == a[1, 2, 3, 4]);
    alias R = typeof(r);
    static assert(is(typeof(b) == Slice!(4, Slice!(4, Slice!(3, R)))));
    static assert(is(typeof(c) == Slice!(3, Slice!(3, R))));
    static assert(is(typeof(d) == Slice!(2, R)));
    static assert(is(typeof(e) == ElementType!R));
}

unittest {
    import std.range: iota;
    auto r = 10000000000.iota;
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
Unpacks a composed $(D slice).
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
    auto r = 10000000000.iota;
    auto a = r.sliced(3, 4, 5, 6, 7, 8, 9, 10, 11);
    auto b = a.packed!(2, 3).unpacked();
    static assert(is(typeof(a) == typeof(b)));
    assert(a == b);
}

/++
Inverse composition of a $(D slice).
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
            foreach(j; 0..C[i+1] - C[i]) //TODO: static foreach
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
unittest
{
    import std.range: iota;
    import std.algorithm.comparison: equal;
    auto r = 10000000000.iota;
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

unittest {
    import std.range: iota;
    auto r = 10000000000.iota;
    auto a = r.sliced(3, 4, 5, 6, 7, 8, 9, 10, 11);
    auto b = a.packed!(2, 3).packEverted;
    static assert(b.shape.length == 2);
    static assert(b.structure.lengths.length == 2);
    static assert(b.structure.strides.length == 2);
    static assert(b
        .byElement.front
        .shape.length == 3);
    static assert(b
        .byElement.front
        .byElement.front
        .shape.length == 4);
}

private alias IncFront(Seq...) = TypeTuple!(Seq[0] + 1, Seq[1..$]);
private alias DecFront(Seq...) = TypeTuple!(Seq[0] - 1, Seq[1..$]);
private alias NSeqEvert(Seq...) = DecFront!(Reverse!(IncFront!Seq));
private alias Parts(Seq...) = DecAll!(IncFront!Seq);
private alias Snowball(Seq...) = TypeTuple!(size_t.init, SnowballImpl!(size_t.init, Seq));
private template SnowballImpl(size_t val, Seq...)
{
    static if (Seq.length == 0)
        alias SnowballImpl = TypeTuple!();
    else
        alias SnowballImpl = TypeTuple!(Seq[0]+val, SnowballImpl!(Seq[0]+val, Seq[1..$]));
}
private template DecAll(Seq...)
{
    static if (Seq.length == 0)
        alias DecAll = TypeTuple!();
    else
        alias DecAll = TypeTuple!(Seq[0] - 1, DecAll!(Seq[1..$]));
}
private template SliceFromSeq(Range, Seq...)
{
    static if(Seq.length == 0)
        alias SliceFromSeq = Range;
    else
        alias SliceFromSeq = SliceFromSeq!(Slice!(Seq[$-1], Range), Seq[0..$-1]);
}

private bool isPermutation(size_t N)(in size_t[N] perm...) @safe pure nothrow
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
private enum isIndex(I) = is(I : size_t);
private enum isReference(P) =
       isPointer!P
    || isFunctionPointer!P
    || isDelegate!P
    || isDynamicArray!P
    || is(P == interface)
    || is(P == class);
private enum hasReference(T) = anySatisfy!(isReference, RepresentationTypeTuple!T);
private alias ImplicitlyUnqual(T) = Select!(isImplicitlyConvertible!(T, Unqual!T), Unqual!T, T);
private template RepeatTypeTuple(T, size_t n)
{
    import std.typetuple: TypeTuple;
    static if (n == 0)
        alias RepeatTypeTuple = TypeTuple!();
    else
        alias RepeatTypeTuple = TypeTuple!(RepeatTypeTuple!(T, n-1), T);

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
