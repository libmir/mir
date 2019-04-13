/++
$(H2 Sparse Tensors)

License:   $(WEB www.boost.org/LICENSE_1_0.txt, Boost License 1.0).

Authors:   Ilya Yaroshenko
+/
module mir.sparse;

import std.traits;
import std.meta;

import mir.ndslice.slice;
public import mir.ndslice.field: SparseField;
public import mir.ndslice.iterator: ChopIterator, FieldIterator;
public import mir.series: isSeries, Series, mir_series, series;
public import mir.ndslice.slice: CoordinateValue, Slice, mir_slice;
public import mir.ndslice.topology: chopped;

//TODO: replace with `static foreach`
private template Iota(size_t i, size_t j)
{
    static assert(i <= j, "Iota: i should be less than or equal to j");
    static if (i == j)
        alias Iota = AliasSeq!();
    else
        alias Iota = AliasSeq!(i, Iota!(i + 1, j));
}

/++
Sparse tensors represented in Dictionary of Keys (DOK) format.

Params:
    N = dimension count
    lengths = list of dimension lengths
Returns:
    `N`-dimensional slice composed of indeces
See_also: $(LREF Sparse)
+/
Sparse!(T, N) sparse(T, size_t N)(size_t[N] lengths...)
{
    T[size_t] table;
    table[0] = 0;
    table.remove(0);
    assert(table !is null);
    with (typeof(return)) return FieldIterator!(SparseField!T)(0, SparseField!T(table)).sliced(lengths);
}

///
pure unittest
{
    auto slice = sparse!double(2, 3);
    slice[0][] = 1;
    slice[0, 1] = 2;
    --slice[0, 0];
    slice[1, 2] += 4;

    assert(slice == [[0, 2, 1], [0, 0, 4]]);

    import std.range.primitives: isRandomAccessRange;
    static assert(isRandomAccessRange!(Sparse!(double, 2)));

    import mir.ndslice.slice: Slice, DeepElementType;
    static assert(is(Sparse!(double, 2) : Slice!(FieldIterator!(SparseField!double), 2)));
    static assert(is(DeepElementType!(Sparse!(double, 2)) == double));
}

/++
Returns unsorted forward range of (coordinate, value) pairs.

Params:
    slice = sparse slice with pure structure. Any operations on structure of a slice are not allowed.
+/
auto byCoordinateValue(size_t N, T)(Slice!(FieldIterator!(SparseField!T), N) slice)
{
    struct ByCoordinateValue
    {
        private sizediff_t[N-1] _strides;
        mixin _sparse_range_methods!(typeof(slice._iterator._field._table.byKeyValue()));

        auto front() @property
        {S:
            assert(!_range.empty);
            auto iv = _range.front;
            size_t index = iv.key;
            if (!(_l <= index && index < _r))
            {
                _range.popFront;
                goto S;
            }
            CoordinateValue!(T, N) ret;
            foreach (i; Iota!(0, N - 1))
            {
                ret.index[i] = index / _strides[i];
                index %= _strides[i];
            }
            ret.index[N - 1] = index;
            ret.value = iv.value;
            return ret;
        }
    }
    size_t l = slice._iterator._index;
    size_t r = l + slice.elementCount;
    size_t length = slice._iterator._field._table.byKey.countInInterval(l, r);
    return ByCoordinateValue(slice.strides[0..N-1], length, l, r, slice._iterator._field._table.byKeyValue);
}

///
pure unittest
{
    import mir.array.allocation: array;
    import mir.ndslice.sorting: sort;
    alias CV = CoordinateValue!(double, 2);

    auto slice = sparse!double(3, 3);
    slice[] = [[0, 2, 1], [0, 0, 4], [6, 7, 0]];
    assert(slice.byCoordinateValue.array.sort() == [
        CV([0, 1], 2),
        CV([0, 2], 1),
        CV([1, 2], 4),
        CV([2, 0], 6),
        CV([2, 1], 7)]);
}

/++
Returns unsorted forward range of coordinates.
Params:
    slice = sparse slice with pure structure. Any operations on structure of a slice are not allowed.
+/
auto byCoordinate(T, size_t N)(Slice!(FieldIterator!(SparseField!T), N) slice)
{
    struct ByCoordinate
    {
        private sizediff_t[N-1] _strides;
        mixin _sparse_range_methods!(typeof(slice._iterator._field._table.byKey()));

        auto front() @property
        {S:
            assert(!_range.empty);
            size_t index = _range.front;
            if (!(_l <= index && index < _r))
            {
                _range.popFront;
                goto S;
            }
            size_t[N] ret;
            foreach (i; Iota!(0, N - 1))
            {
                ret[i] = index / _strides[i];
                index %= _strides[i];
            }
            ret[N - 1] = index;
            return ret;
        }
    }
    size_t l = slice._iterator._index;
    size_t r = l + slice.elementCount;
    size_t length = slice._iterator._field._table.byKey.countInInterval(l, r);
    return ByCoordinate(slice.strides[0 .. N - 1], length, l, r, slice._iterator._field._table.byKey);
}

///
pure unittest
{
    import mir.array.allocation: array;
    import mir.ndslice.sorting: sort;

    auto slice = sparse!double(3, 3);
    slice[] = [[0, 2, 1], [0, 0, 4], [6, 7, 0]];
    assert(slice.byCoordinate.array.sort() == [
        [0, 1],
        [0, 2],
        [1, 2],
        [2, 0],
        [2, 1]]);
}

/++
Returns unsorted forward range of values.
Params:
    slice = sparse slice with pure structure. Any operations on structure of a slice are not allowed.
+/
auto onlyByValue(T, size_t N)(Slice!(FieldIterator!(SparseField!T), N) slice)
{
    struct ByValue
    {
        mixin _sparse_range_methods!(typeof(slice._iterator._field._table.byKeyValue()));

        auto front() @property
        {S:
            assert(!_range.empty);
            auto iv = _range.front;
            size_t index = iv.key;
            if (!(_l <= index && index < _r))
            {
                _range.popFront;
                goto S;
            }
            return iv.value;
        }
    }
    size_t l = slice._iterator._index;
    size_t r = l + slice.elementCount;
    size_t length = slice._iterator._field._table.byKey.countInInterval(l, r);
    return ByValue(length, l, r, slice._iterator._field._table.byKeyValue);
}

///
pure unittest
{
    import mir.array.allocation: array;
    import mir.ndslice.sorting: sort;

    auto slice = sparse!double(3, 3);
    slice[] = [[0, 2, 1], [0, 0, 4], [6, 7, 0]];
    assert(slice.onlyByValue.array.sort() == [1, 2, 4, 6, 7]);
}

pragma(inline, false)
private size_t countInInterval(Range)(Range range, size_t l, size_t r)
{
    size_t count;
    foreach(ref i; range)
        if (l <= i && i < r)
            count++;
    return count;
}

private mixin template _sparse_range_methods(Range)
{
    private size_t _length, _l, _r;
    private Range _range;

    void popFront()
    {
        assert(!_range.empty);
        _range.popFront;
        _length--;
    }

    bool empty() const @property
    {
        return _length == 0;
    }

    auto save() @property
    {
        auto ret = this;
        ret._range = ret._range.save;
        return ret;
    }

    size_t length() const @property
    {
        return _length;
    }
}

/++
Returns compressed tensor.
Note: allocates using GC.
+/
auto compress(I = uint, J = size_t, SliceKind kind, size_t N, Iterator)(Slice!(Iterator, N, kind) slice)
    if (N > 1)
{
    return compressWithType!(DeepElementType!(Slice!(Iterator, N, kind)), I, J)(slice);
}

/// Sparse tensor compression
unittest
{
    auto sparse = sparse!double(5, 3);
    sparse[] =
        [[0, 2, 1],
         [0, 0, 4],
         [0, 0, 0],
         [6, 0, 9],
         [0, 0, 5]];

    auto crs = sparse.compressWithType!double;
    // assert(crs.iterator._field == CompressedField!(double, uint, uint)(
    //      3,
    //     [2, 1, 4, 6, 9, 5],
    //     [1, 2, 2, 0, 2, 2],
    //     [0, 2, 3, 3, 5, 6]));
}

/// Sparse tensor compression
unittest
{
    auto sparse = sparse!double(5, 8);
    sparse[] =
        [[0, 2, 0, 0, 0, 0, 0, 1],
         [0, 0, 0, 0, 0, 0, 0, 4],
         [0, 0, 0, 0, 0, 0, 0, 0],
         [6, 0, 0, 0, 0, 0, 0, 9],
         [0, 0, 0, 0, 0, 0, 0, 5]];

    auto crs = sparse.compressWithType!double;
    // assert(crs.iterator._field == CompressedField!(double, uint, uint)(
    //      8,
    //     [2, 1, 4, 6, 9, 5],
    //     [1, 7, 7, 0, 7, 7],
    //     [0, 2, 3, 3, 5, 6]));
}

/// Dense tensor compression
unittest
{
    import mir.ndslice.allocation: slice;

    auto sl = slice!double(5, 3);
    sl[] =
        [[0, 2, 1],
         [0, 0, 4],
         [0, 0, 0],
         [6, 0, 9],
         [0, 0, 5]];

    auto crs = sl.compressWithType!double;

    // assert(crs.iterator._field == CompressedField!(double, uint, uint)(
    //      3,
    //     [2, 1, 4, 6, 9, 5],
    //     [1, 2, 2, 0, 2, 2],
    //     [0, 2, 3, 3, 5, 6]));
}

/// Dense tensor compression
unittest
{
    import mir.ndslice.allocation: slice;

    auto sl = slice!double(5, 8);
    sl[] =
        [[0, 2, 0, 0, 0, 0, 0, 1],
         [0, 0, 0, 0, 0, 0, 0, 4],
         [0, 0, 0, 0, 0, 0, 0, 0],
         [6, 0, 0, 0, 0, 0, 0, 9],
         [0, 0, 0, 0, 0, 0, 0, 5]];

    auto crs = sl.compress;
    // assert(crs.iterator._field == CompressedField!(double, uint, uint)(
    //      8,
    //     [2, 1, 4, 6, 9, 5],
    //     [1, 7, 7, 0, 7, 7],
    //     [0, 2, 3, 3, 5, 6]));
}

/++
Returns compressed tensor with different element type.
Note: allocates using GC.
+/
Slice!(ChopIterator!(J*, Series!(I*, V*)), N - 1)
    compressWithType(V, I = uint, J = size_t, T, size_t N)
    (Slice!(FieldIterator!(SparseField!T), N) slice)
    if (is(T : V) && N > 1 && isUnsigned!I)
{
    import mir.array.allocation: array;
    import mir.ndslice.sorting: sort;
    import mir.ndslice.topology: iota;
    auto compressedData = slice
        .iterator
        ._field
        ._table
        .series!(size_t, T, I, V);
    auto pointers = new J[slice.shape[0 .. N - 1].iota.elementCount + 1];
    size_t k = 1, shift;
    pointers[0] = 0;
    pointers[1] = 0;
    const rowLength = slice.length!(N - 1);
    if(rowLength) foreach (ref index; compressedData.index.field)
    {
        for(;;)
        {
            sizediff_t newIndex = index - shift;
            if (newIndex >= rowLength)
            {
                pointers[k + 1] = pointers[k];
                shift += rowLength;
                k++;
                continue;
            }
            index = cast(I)newIndex;
            pointers[k] = cast(J) (pointers[k] + 1);
            break;
        }

    }
    pointers[k + 1 .. $] = pointers[k];
    return compressedData.chopped(pointers);
}


/// ditto
Slice!(ChopIterator!(J*, Series!(I*, V*)), N - 1)
    compressWithType(V, I = uint, J = size_t, Iterator, size_t N, SliceKind kind)
    (Slice!(Iterator, N, kind) slice)
    if (!is(Iterator : FieldIterator!(SparseField!ST), ST) && is(DeepElementType!(Slice!(Iterator, N, kind)) : V) && N > 1 && isUnsigned!I)
{
    import std.array: appender;
    import mir.ndslice.topology: pack, flattened;
    auto vapp = appender!(V[]);
    auto iapp = appender!(I[]);
    auto psl = slice.pack!1;
    auto count = psl.elementCount;
    auto pointers = new J[count + 1];

    pointers[0] = 0;
    auto elems = psl.flattened;
    size_t j = 0;
    foreach (ref pointer; pointers[1 .. $])
    {
        auto row = elems.front;
        elems.popFront;
        size_t i;
        foreach (e; row)
        {
            if (e)
            {
                vapp.put(e);
                iapp.put(cast(I)i);
                j++;
            }
            i++;
        }
        pointer = cast(J)j;
    }
    return iapp.data.series(vapp.data).chopped(pointers);
}


/++
Re-compresses a compressed tensor. Makes all values, indeces and pointers consequent in memory.

Sparse slice is iterated twice. The first tine it is iterated to get length of each sparse row, the second time - to copy the data.

Note: allocates using GC.
+/
Slice!(ChopIterator!(J*, Series!(I*, V*)), N)
    recompress
    (V, I = uint, J = size_t, Iterator, size_t N, SliceKind kind)
    (Slice!(Iterator, N, kind) sparseSlice)
    if (isSeries!(DeepElementType!(Slice!(Iterator, N, kind))))
{
    import mir.algorithm.iteration: each;
    import mir.conv: to, emplaceRef;
    import mir.ndslice.allocation: uninitSlice;
    import mir.ndslice.topology: pack, flattened, as, member, zip;
    
    size_t count = sparseSlice.elementCount;
    size_t length;
    auto pointers = uninitSlice!J(count + 1);
    pointers.front = 0;
    sparseSlice
        .member!"data"
        .member!"elementCount"
        .each!((len, ref ptr) {ptr = length += len;})(pointers[1 .. $]);

    auto i = uninitSlice!I(length);
    auto v = uninitSlice!V(length);

    auto ret = i.series(v).chopped(pointers);

    sparseSlice
        .each!((a, b) {
            b.index[] = a.index.as!I;
            b.value.each!(emplaceRef!V)(a.value.as!V);
        })(ret);

    return ret;
}

///
unittest
{
    import mir.ndslice.topology: universal;
    import mir.ndslice.allocation: slice;

    auto sl = slice!double(5, 8);
    sl[] =
        [[0, 2, 0, 0, 0, 0, 0, 1],
         [0, 0, 0, 0, 0, 0, 0, 4],
         [0, 0, 0, 0, 0, 0, 0, 0],
         [6, 0, 0, 0, 0, 0, 0, 9],
         [0, 0, 0, 0, 0, 0, 0, 5]];

    auto crs = sl.compress;
    // assert(crs.iterator._field == CompressedField!(double, uint, uint)(
    //      8,
    //     [2, 1, 4, 6, 9, 5],
    //     [1, 7, 7, 0, 7, 7],
    //     [0, 2, 3, 3, 5, 6]));

    import mir.ndslice.dynamic: reversed;
    auto rec = crs.reversed.recompress!real;
    auto rev = sl.universal.reversed.compressWithType!real;
    assert(rev.structure == rec.structure);
    // assert(rev.iterator._field.values   == rec.iterator._field.values);
    // assert(rev.iterator._field.indeces  == rec.iterator._field.indeces);
    // assert(rev.iterator._field.pointers == rec.iterator._field.pointers);
}

/++
Sparse Slice in Dictionary of Keys (DOK) format.
+/
alias Sparse(T, size_t N = 1) = Slice!(FieldIterator!(SparseField!T), N);

///
alias CompressedVector(T, I = uint) = Series!(T*, I*);

///
alias CompressedMatrix(T, I = uint) = Slice!(ChopIterator!(J*, Series!(T*, I*)));

///
alias CompressedTensor(T, size_t N, I = uint, J = size_t) = Slice!(ChopIterator!(J*, Series!(T*, I*)), N - 1);

///ditto
alias CompressedTensor(T, size_t N : 1, I = uint) = Series!(I*, T*);
