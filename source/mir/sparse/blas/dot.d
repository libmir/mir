/**
License: $(LINK2 http://boost.org/LICENSE_1_0.txt, Boost License 1.0).

Authors: Ilya Yaroshenko
*/
module mir.sparse.blas.dot;

import std.traits;
import mir.ndslice.slice;
import mir.sparse;

/++
Dot product of two vectors

Params:
    x = sparse vector
    y = sparse vector
Returns:
    scalar `xᵀ × y`
+/
Unqual!(CommonType!(T1, T2)) dot(
    V1 : CompressedArray!(T1, I1),
    V2 : CompressedArray!(T2, I2),
    T1, T2, I1, I2)
(V1 x, V2 y)
{
    return dot!(typeof(return))(x, y);
}

/// ditto
D dot(
    D,
    V1 : CompressedArray!(T1, I1),
    V2 : CompressedArray!(T2, I2),
    T1, T2, I1, I2)
(V1 x, V2 y)
{

    typeof(return) s = 0;

    uint done = 2;
    Unqual!I1 ai0 = void;
    Unqual!I2 bi0 = void;

    if (x.indexes.length && y.indexes.length) for (;;)
    {
        bi0 = y.indexes[0];
        if (x.indexes[0] < bi0)
        {
            do
            {
                x.values = x.values[1 .. $];
                x.indexes = x.indexes[1 .. $];
                if (x.indexes.length == 0)
                {
                    break;
                }
            }
            while (x.indexes[0] < bi0);
            done = 2;
        }
        if (--done == 0)
        {
            goto L;
        }
        ai0 = x.indexes[0];
        if (y.indexes[0] < ai0)
        {
            do
            {
                y.values = y.values[1 .. $];
                y.indexes = y.indexes[1 .. $];
                if (y.indexes.length == 0)
                {
                    break;
                }
            }
            while (y.indexes[0] < ai0);
            done = 2;
        }
        if (--done == 0)
        {
            goto L;
        }
        continue;
        L:
        s = x.values[0] * y.values[0] + s;
        x.indexes = x.indexes[1 .. $];
        if (x.indexes.length == 0)
        {
            break;
        }
        y.indexes = y.indexes[1 .. $];
        if (y.indexes.length == 0)
        {
            break;
        }
        x.values = x.values[1 .. $];
        y.values = y.values[1 .. $];
    }

    return s;
}

///
unittest
{
    auto x = CompressedArray!(int, uint)([1, 3, 4, 9, 10], [0, 3, 5, 9, 100]);
    auto y = CompressedArray!(int, uint)([1, 10, 100, 1000], [1, 3, 4, 9]);
    // x = [1, 0, 0,  3, 0, 4, 0, 0, 0, 9, ... ,10]
    // y = [0, 1, 0, 10, 0, 0, 0, 0, 0, 1000]
    assert(dot(x, y) == 9030);
    assert(dot!double(x, y) == 9030);
}

/++
Dot product of two vectors.
Params:
    x = sparse vector
    y = dense vector
Returns:
    scalar `x × y`
+/
Unqual!(CommonType!(T1, ForeachType!V2)) dot(
    V1 : CompressedArray!(T1, I1),
    T1, I1, V2)
(V1 x, V2 y)
    if (isDynamicArray!V2 || isSlice!V2 == [1])
{
    return dot!(typeof(return))(x, y);
}

///ditto
D dot(
    D,
    V1 : CompressedArray!(T1, I1),
    T1, I1, V2)
(V1 x, V2 y)
    if (isDynamicArray!V2 || isSlice!V2 == [1])
in
{
    if (x.indexes.length)
        assert(x.indexes[$-1] < y.length);
}
body
{

    import mir.internal.utility;
    static if (isSimpleSlice!V2)
    {
        if (y.stride == 1)
        {
            return dot(x, y.toDense);
        }
    }

    alias T2 = ForeachType!V2;

    alias F = Unqual!(CommonType!(T1, T2));
    F s = 0;
    foreach (size_t i; 0 .. x.indexes.length)
    {
        s = y[x.indexes[i]] * x.values[i] + s;
    }

    return s;
}

///
unittest
{
    import std.typecons: No;
    auto x = CompressedArray!(double, uint)([1.0, 3, 4, 9, 13], [0, 3, 5, 9, 10]);
    auto y = [0.0, 1.0, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12];
    // x: [1, 0, 0, 3, 0, 4, 0, 0, 0, 9, 13,  0,  0,  0]
    // y: [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13]
    auto r = 0 + 3 * 3 + 4 * 5 + 9 * 9 + 13 * 10;
    assert(dot(x, y) == r);
    assert(dot(x, y.sliced) == r);
    assert(dot(x, y.slicedField) == r);
}
