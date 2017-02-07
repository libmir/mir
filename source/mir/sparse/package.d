/++
$(H2 Sparse Tensors)

License:   $(WEB www.boost.org/LICENSE_1_0.txt, Boost License 1.0).

Authors:   Ilya Yaroshenko
+/
module mir.sparse;

import std.traits;
import std.meta;

import mir.ndslice.slice;
import mir.ndslice.topology: universal;
import mir.ndslice.iterator: FieldIterator;

private enum isIndex(I) = is(I : size_t);

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
    `N`-dimensional slice composed of indexes
See_also: $(LREF Sparse)
+/
Sparse!(Lengths.length, T) sparse(T, Lengths...)(Lengths lengths)
    if (allSatisfy!(isIndex, Lengths))
{
    return .sparse!(T, Lengths.length)([lengths]);
}

/// ditto
Sparse!(N, T) sparse(T, size_t N)(auto ref size_t[N] lengths)
{
    T[size_t] table;
    table[0] = 0;
    table.remove(0);
    assert(table !is null);
    with (typeof(return)) return FieldIterator!(SparseField!T)(0, SparseField!T(table)).sliced(lengths).universal;
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
    static assert(isRandomAccessRange!(Sparse!(2, double)));

    import mir.ndslice.slice: Slice, DeepElementType;
    static assert(is(Sparse!(2, double) : Slice!(Universal, [2], FieldIterator!(SparseField!double))));
    static assert(is(DeepElementType!(Sparse!(2, double)) == double));
}

/++
Sparse Slice in Dictionary of Keys (DOK) format.
+/
alias Sparse(size_t N, T) = Slice!(Universal, [N], FieldIterator!(SparseField!T));

/++
`SparseField` is used internally by `Slice` type to represent $(LREF Sparse).
+/
struct SparseField(T)
{
    ///
    T[size_t] table;

    ///
    auto save() @property
    {
        return this;
    }

    ///
    T opIndex(size_t index)
    {
        static if (isScalarType!T)
            return table.get(index, cast(T)0);
        else
            return table.get(index, null);
    }

    ///
    T opIndexAssign(T value, size_t index)
    {
        static if (isScalarType!T)
        {
            if (value != 0)
            {
                table[index] = value;
            }
        }
        else
        {
            if (value !is null)
            {
                table[index] = value;
            }
        }
        return value;
    }

    ///
    T opIndexUnary(string op)(size_t index)
        if (op == `++` || op == `--`)
    {
        mixin (`auto value = ` ~ op ~ `table[index];`);
        static if (isScalarType!T)
        {
            if (value == 0)
            {
                table.remove(index);
            }
        }
        else
        {
            if (value is null)
            {
                table.remove(index);
            }
        }
        return value;
    }

    ///
    T opIndexOpAssign(string op)(T value, size_t index)
        if (op == `+` || op == `-`)
    {
        mixin (`value = table[index] ` ~ op ~ `= value;`); // this works
        static if (isScalarType!T)
        {
            if (value == 0)
            {
                table.remove(index);
            }
        }
        else
        {
            if (value is null)
            {
                table.remove(index);
            }
        }
        return value;
    }
}

/++
Combination of coordinate(s) and value.
+/
struct CoordinateValue(size_t N, T)
{
    ///
    size_t[N] index;

    ///
    T value;

    ///
    sizediff_t opCmp()(auto ref const typeof(this) rht) const
    {
        return cmpCoo(this.index, rht.index);
    }
}

private sizediff_t cmpCoo(size_t N)(const auto ref size_t[N] a, const auto ref size_t[N] b)
{
    foreach (i; Iota!(0, N))
        if (auto d = a[i] - b[i])
            return d;
    return 0;
}

/++
Returns unsorted forward range of (coordinate, value) pairs.

Params:
    slice = sparse slice with pure structure. Any operations on structure of a slice are not allowed.
+/
auto byCoordinateValue(S : Slice!(Universal, packs, Iterator), size_t[] packs, size_t N = packs[0], Iterator : FieldIterator!(SparseField!T), T)(S slice)
{
    static struct CoordinateValues
    {
        static if (N > 1)
            private sizediff_t[N-1] _strides;
        mixin _sparse_range_methods!(N, T);
        private typeof(Sparse!(N, T).init.iterator._field.table.byKeyValue()) _range;

        auto front() @property
        {
            assert(!_range.empty);
            auto iv = _range.front;
            size_t index = iv.key;
            CoordinateValue!(N, T) ret = void;
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
    static if (N > 1)
    {
        CoordinateValues ret = void;
        ret._strides = slice.structure.strides[0..N-1];
        ret._length = slice.iterator._field.table.length;
        ret._range = slice.iterator._field.table.byKeyValue;
        return ret;
    }
    else
        return CoordinateValues(slice.iterator._field.table.byKeyValue);
}

///
pure unittest
{
    import std.array: array;
    import std.algorithm.sorting: sort;
    alias CV = CoordinateValue!(2, double);

    auto slice = sparse!double(3, 3);
    slice[] = [[0, 2, 1], [0, 0, 4], [6, 7, 0]];
    assert(slice.byCoordinateValue.array.sort().release == [
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
auto byCoordinate(S : Slice!(Universal, packs, Iterator), size_t[] packs, size_t N = packs[0], Iterator : FieldIterator!(SparseField!T), T)(S slice)
{
    static struct Coordinates
    {
        static if (N > 1)
            private sizediff_t[N-1] _strides;
        mixin _sparse_range_methods!(N, T);
        private typeof(Sparse!(N, T).init.iterator._field.table.byKey()) _range;

        auto front() @property
        {
            assert(!_range.empty);
            size_t index = _range.front;
            size_t[N] ret = void;
            foreach (i; Iota!(0, N - 1))
            {
                ret[i] = index / _strides[i];
                index %= _strides[i];
            }
            ret[N - 1] = index;
            return ret;
        }
    }
    static if (N > 1)
    {
        Coordinates ret = void;
        ret._strides = slice.structure.strides[0..N-1];
        ret._length = slice.iterator._field.table.length;
        ret._range = slice.iterator._field.table.byKey;
        return ret;
    }
    else
        return Coordinates(slice.iterator._field.table.byKey);
}

///
pure unittest
{
    import std.array: array;
    import std.algorithm.sorting: sort;

    auto slice = sparse!double(3, 3);
    slice[] = [[0, 2, 1], [0, 0, 4], [6, 7, 0]];
    assert(slice.byCoordinate.array.sort().release == [
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
auto byValueOnly(S : Slice!(Universal, packs, Iterator), size_t[] packs, size_t N = packs[0], Iterator : FieldIterator!(SparseField!T), T)(S slice)
{
    static struct Values
    {
        mixin _sparse_range_methods!(N, T);
        private typeof(Sparse!(N, T).init.iterator._field.table.byValue) _range;

        auto front() @property
        {
            assert(!_range.empty);
            return _range.front;
        }
    }
    return Values(slice.iterator._field.table.length, slice.iterator._field.table.byValue);
}

///
pure unittest
{
    import std.array: array;
    import std.algorithm.sorting: sort;

    auto slice = sparse!double(3, 3);
    slice[] = [[0, 2, 1], [0, 0, 4], [6, 7, 0]];
    assert(slice.byValueOnly.array.sort().release == [1, 2, 4, 6, 7]);
}

private mixin template _sparse_range_methods(size_t N, T)
{
    private size_t _length;

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
Returns compressed tensor
+/
auto compress(I = uint, J = uint, SliceKind kind, size_t[] packs, Iterator)(Slice!(kind, packs, Iterator) slice)
    if (packs[0] > 1)
{
    return compressWithType!(DeepElementType!(Slice!(kind, [packs[0]], Iterator)), I, J, kind, packs, Iterator)(slice);
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

    auto crs = sparse.compress;
    assert(crs.iterator._field == CompressedField!(double, uint, uint)(
         3,
        [2, 1, 4, 6, 9, 5],
        [1, 2, 2, 0, 2, 2],
        [0, 2, 3, 3, 5, 6]));
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

    auto crs = sparse.compress;
    assert(crs.iterator._field == CompressedField!(double, uint, uint)(
         8,
        [2, 1, 4, 6, 9, 5],
        [1, 7, 7, 0, 7, 7],
        [0, 2, 3, 3, 5, 6]));
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

    auto crs = sl.compress;

    assert(crs.iterator._field == CompressedField!(double, uint, uint)(
         3,
        [2, 1, 4, 6, 9, 5],
        [1, 2, 2, 0, 2, 2],
        [0, 2, 3, 3, 5, 6]));
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
    assert(crs.iterator._field == CompressedField!(double, uint, uint)(
         8,
        [2, 1, 4, 6, 9, 5],
        [1, 7, 7, 0, 7, 7],
        [0, 2, 3, 3, 5, 6]));
}

/++
Returns compressed tensor with different element type.
+/
CompressedTensor!(packs[0], V, I, J)
    compressWithType
    (V, I = uint, J = uint, SliceKind kind, size_t[] packs, Iterator : FieldIterator!(SparseField!T), T)
    (Slice!(kind, packs, Iterator) slice)
    if (is(T : V) && packs[0] > 1)
{
    import std.array: array;
    import mir.ndslice.sorting: sort;
    import mir.ndslice.topology: iota;
    auto data = slice
        .iterator
        ._field
        .table
        .byKeyValue
        .array
        .sliced
        .sort!((a, b) => a.key < b.key);
    auto inv = iota(slice.shape[0 .. packs[0] - 1]);
    auto count = inv.elementsCount;
    auto map = CompressedField!(V, I, J)(
        slice.length!(packs[0] - 1),
        new V[data.length],
        new I[data.length],
        new J[count + 1],
        );
    size_t k = 0;
    map.pointers[0] = 0;
    map.pointers[1] = 0;
    size_t t;
    foreach (e; data)
    {
        map.values[t] = cast(V) e.value;
        size_t index = e.key;
        map.indexes[t] = cast(I)(index % slice.length!(packs[0] - 1));
        auto p = index / slice.length!(packs[0] - 1);
        if (k != p)
        {
            map.pointers[k + 2 .. p + 2] = map.pointers[k + 1];
            k = p;
        }
        map.pointers[k + 1]++;
        t++;
    }
    map.pointers[k + 2 .. $] = map.pointers[k + 1];
    return map.slicedField(inv.shape).universal;
}


/// ditto
CompressedTensor!(packs[0], V, I, J)
    compressWithType
    (V, I = uint, J = uint, SliceKind kind, size_t[] packs, Iterator)
    (Slice!(kind, packs, Iterator) slice)
    if (!is(Iterator : FieldIterator!(SparseField!ST), ST) && is(DeepElementType!(Slice!(Universal, packs, Iterator)) : V) && packs[0] > 1)
{
    import std.array: appender;
    import mir.ndslice.topology: pack, flattened;
    auto vapp = appender!(V[]);
    auto iapp = appender!(I[]);
    auto psl = slice.pack!1;
    auto count = psl.elementsCount;
    auto pointers = new J[count + 1];

    pointers[0] = 0;
    auto elems = psl.flattened;
    J j = 0;
    foreach (ref pointer; pointers[1 .. $])
    {
        auto row = elems.front;
        elems.popFront;
        I i;
        foreach (e; row)
        {
            if (e)
            {
                vapp.put(e);
                iapp.put(i);
                j++;
            }
            i++;
        }
        pointer = j;
    }
    auto map = CompressedField!(V, I, J)(
        slice.length!(packs[0] - 1),
        vapp.data,
        iapp.data,
        pointers,
        );
    return map.slicedField(psl.shape).universal;
}


/++
Re-compresses a compressed tensor. Makes all values, indexes and pointers consequent in memory.
+/
CompressedTensor!(packs[0] + 1, V, I, J)
    recompress
    (V, I = uint, J = size_t, SliceKind kind, size_t[] packs, Iterator : FieldIterator!(CompressedField!(RV, RI, RJ)), RV, RI, RJ)
    (Slice!(kind, packs, Iterator) slice)
{
    import mir.conv: to;
    import mir.ndslice.topology: as;
    import std.array: appender;
    import mir.ndslice. topology: pack, flattened;
    auto vapp = appender!(V[]);
    auto iapp = appender!(I[]);
    auto count = slice.elementsCount;
    auto pointers = new J[count + 1];

    pointers[0] = 0;
    auto elems = slice.flattened;
    J j = 0;
    foreach (ref pointer; pointers[1 .. $])
    {
        auto row = elems.front;
        elems.popFront;
        vapp.put(row.values.sliced.as!V);
        iapp.put(row.indexes.sliced.as!I);
        j += cast(J) row.indexes.length;
        pointer = j;
    }
    auto m = CompressedField!(V, I, J)(
        slice.iterator._field.compressedLength,
        vapp.data,
        iapp.data,
        pointers,
        );
    return m.slicedField(slice.shape).universal;
}

///
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
    assert(crs.iterator._field == CompressedField!(double, uint, uint)(
         8,
        [2, 1, 4, 6, 9, 5],
        [1, 7, 7, 0, 7, 7],
        [0, 2, 3, 3, 5, 6]));

    import mir.ndslice.dynamic: reversed;
    auto rec = crs.reversed.recompress!real;
    auto rev = sl.universal.reversed.compressWithType!real;
    assert(rev.structure == rec.structure);
    assert(rev.iterator._field.values   == rec.iterator._field.values);
    assert(rev.iterator._field.indexes  == rec.iterator._field.indexes);
    assert(rev.iterator._field.pointers == rec.iterator._field.pointers);
}

/++
`CompressedTensor!(N, T, I, J)` is  `Slice!(N - 1, CompressedField!(T, I, J))`.

See_also: $(LREF CompressedField)
+/
alias CompressedTensor(size_t N, T, I = uint, J = size_t) = Slice!(Universal, [N - 1], FieldIterator!(CompressedField!(T, I, J)));

/++
Compressed array is just a structure of values array and indexes array.

See_also: $(LREF CompressedTensor), $(LREF CompressedField)
+/
struct CompressedArray(T, I = uint)
    if (is(I : size_t) && isUnsigned!I)
{
    /++
    +/
    T[] values;

    /++
    +/
    I[] indexes;
}

/++
`CompressedField` is used internally by `Slice` type to represent $(LREF CompressedTensor).
+/
struct CompressedField(T, I = uint, J = size_t)
    if (is(I : size_t) && isUnsigned!I && is(J : size_t) && isUnsigned!J && I.sizeof <= J.sizeof)
{
    /++
    +/
    size_t compressedLength;

    /++
    +/
    T[] values;

    /++
    +/
    I[] indexes;

    /++
    +/
    J[] pointers;

    /++
    +/
    inout(CompressedArray!(T, I)) opIndex(size_t index) inout
    in
    {
        assert(index < pointers.length - 1);
    }
    body
    {
        auto a = pointers[index];
        auto b = pointers[index + 1];
        return typeof(return)(values[a .. b], indexes[a .. b]);
    }
}
