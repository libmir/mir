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
public import mir.ndslice.iterator: ChopIterator, FieldIterator;
public import mir.series: Series, mir_series, series;
public import mir.ndslice.slice: Slice, mir_slice;
import mir.ndslice.topology: chopped;

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
    `N`-dimensional slice composed of indeces
See_also: $(LREF Sparse)
+/
Sparse!(T, Lengths.length,) sparse(T, Lengths...)(Lengths lengths)
    if (allSatisfy!(isIndex, Lengths))
{
    return .sparse!(T, Lengths.length)([lengths]);
}

/// ditto
Sparse!(T, N) sparse(T, size_t N)(auto ref size_t[N] lengths)
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
    static assert(isRandomAccessRange!(Sparse!(double, 2)));

    import mir.ndslice.slice: Slice, DeepElementType;
    static assert(is(Sparse!(double, 2) : Slice!(FieldIterator!(SparseField!double), 2, Universal)));
    static assert(is(DeepElementType!(Sparse!(double, 2)) == double));
}

/++
Sparse Slice in Dictionary of Keys (DOK) format.
+/
alias Sparse(T, size_t N = 1) = Slice!(FieldIterator!(SparseField!T), N, Universal);

/++
`SparseField` is used internally by `Slice` type to represent $(LREF Sparse).
+/
struct SparseField(T)
{
    ///
    T[size_t] table;

    ///
    auto lightConst()() const @trusted
    {
        return SparseField!(const T)(cast(const(T)[size_t])table);
    }

    ///
    auto lightImmutable()() immutable @trusted
    {
        return SparseField!(immutable T)(cast(immutable(T)[size_t])table);
    }

    ///
    auto save()() @property
    {
        return this;
    }

    ///
    T opIndex()(size_t index)
    {
        static if (isScalarType!T)
            return table.get(index, cast(T)0);
        else
            return table.get(index, null);
    }

    ///
    T opIndexAssign()(T value, size_t index)
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
struct CoordinateValue(T, size_t N = 1)
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
auto byCoordinateValue(S : Slice!(Iterator, N, Universal), size_t N, Iterator : FieldIterator!(SparseField!T), T)(S slice)
{
    static struct CoordinateValues
    {
        static if (N > 1)
            private sizediff_t[N-1] _strides;
        mixin _sparse_range_methods!(T, N);
        private typeof(Sparse!(T, N).init.iterator._field.table.byKeyValue()) _range;

        auto front() @property
        {
            assert(!_range.empty);
            auto iv = _range.front;
            size_t index = iv.key;
            CoordinateValue!(T, N) ret = void;
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
    alias CV = CoordinateValue!(double, 2);

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
auto byCoordinate(S : Slice!(Iterator, N, Universal), size_t N, Iterator : FieldIterator!(SparseField!T), T)(S slice)
{
    static struct Coordinates
    {
        static if (N > 1)
            private sizediff_t[N-1] _strides;
        mixin _sparse_range_methods!(T, N);
        private typeof(Sparse!(T, N).init.iterator._field.table.byKey()) _range;

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
auto byValueOnly(S : Slice!(Iterator, N, Universal), size_t N, Iterator : FieldIterator!(SparseField!T), T)(S slice)
{
    static struct Values
    {
        mixin _sparse_range_methods!(T, N);
        private typeof(Sparse!(T, N).init.iterator._field.table.byValue) _range;

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

private mixin template _sparse_range_methods(T, size_t N)
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
auto compress(I = uint, J = size_t, SliceKind kind, size_t N, Iterator)(Slice!(Iterator, N, kind) slice)
    if (N > 1)
{
    return compressWithType!(DeepElementType!(Slice!(Iterator, N, kind)), I, J, Iterator, N, kind)(slice);
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
+/
Slice!(ChopIterator!(J*, Series!(I*, V*)), N - 1)
    compressWithType(V, I = uint, J = size_t, T, size_t N)
    (Slice!(FieldIterator!(SparseField!T), N) slice)
    if (is(T : V) && N > 1 && isUnsigned!I)
{
    import std.array: array;
    import mir.ndslice.sorting: sort;
    import mir.ndslice.topology: iota;
    auto compressedData = slice
        .iterator
        ._field
        .table
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
    return compressedData.chopped(pointers.ptr);
}


/// ditto
Slice!(ChopIterator!(J*, Series!(I*, V*)), N - 1)
    compressWithType(V, I = uint, J = size_t, Iterator, size_t N, SliceKind kind)
    (Slice!(Iterator, N, kind) slice)
    if (!is(Iterator : FieldIterator!(SparseField!ST), ST) && is(DeepElementType!(Slice!(Iterator, N, Universal)) : V) && N > 1 && isUnsigned!I)
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
    return iapp.data.series(vapp.data).chopped(pointers.ptr);
}


/++
Re-compresses a compressed tensor. Makes all values, indeces and pointers consequent in memory.
+/
Slice!(ChopIterator!(J*, Series!(I*, V*)), N)
    recompress
    (V, I = uint, J = size_t, SliceKind kind, size_t N, Iterator : ChopIterator!(RJ*, Series!(RI*, RV*)), RV, RI, RJ)
    (Slice!(Iterator, N, kind) slice)
{
    import mir.conv: to;
    import mir.ndslice.topology: as;
    import std.array: appender;
    import mir.ndslice. topology: pack, flattened;
    auto vapp = appender!(V[]);
    auto iapp = appender!(I[]);
    auto count = slice.elementCount;
    auto pointers = new J[count + 1];

    pointers[0] = 0;
    auto elems = slice.flattened;
    J j = 0;
    foreach (ref pointer; pointers[1 .. $])
    {
        auto row = elems.front;
        elems.popFront;
        iapp.put(row.index.as!I);
        vapp.put(row.value.as!V);
        j += cast(J) row.index.length;
        pointer = j;
    }
    auto m = CompressedField!(V, I, J)(
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
    // assert(crs.iterator._field == CompressedField!(double, uint, uint)(
    //      8,
    //     [2, 1, 4, 6, 9, 5],
    //     [1, 7, 7, 0, 7, 7],
    //     [0, 2, 3, 3, 5, 6]));

    import mir.ndslice.dynamic: reversed;
    auto rec = crs.reversed.recompress!real;
    auto rev = sl.universal.reversed.compressWithType!real;
    assert(rev.structure == rec.structure);
    assert(rev.iterator._field.values   == rec.iterator._field.values);
    assert(rev.iterator._field.indeces  == rec.iterator._field.indeces);
    assert(rev.iterator._field.pointers == rec.iterator._field.pointers);
}

/++
`CompressedTensor!(T, N, I, J)` is  `Slice!(N - 1, CompressedField!(T, I, J))`.

See_also: $(LREF CompressedField)
+/
// alias CompressedTensor(T, size_t N, I = uint, J = size_t) = Slice!(ChopIterator!(J*, Series!(I*, T*)), N - 1, Universal);

