/**
License: $(LINK2 http://boost.org/LICENSE_1_0.txt, Boost License 1.0).

Authors: Ilya Yaroshenko
*/
module mir.sparse.blas.dot;

import std.traits;
import mir.ndslice.slice;
import mir.sparse;
import mir.series;

/++
Dot product of two vectors

Params:
    x = sparse vector
    y = sparse vector
Returns:
    scalar `xᵀ × y`
+/
Unqual!(CommonType!(T1, T2)) dot(
    V1 : Series!(I1*, T1*),
    V2 : Series!(I2*, T2*),
    T1, T2, I1, I2)
(V1 x, V2 y)
{
    return dot!(typeof(return))(x, y);
}

/// ditto
D dot(
    D,
    V1 : Series!(I1*, T1*),
    V2 : Series!(I2*, T2*),
    T1, T2, I1, I2)
(V1 x, V2 y)
{

    typeof(return) s = 0;

    uint done = 2;
    Unqual!I1 ai0 = void;
    Unqual!I2 bi0 = void;

    if (x.length && y.length) for (;;)
    {
        bi0 = y.index[0];
        if (x.index[0] < bi0)
        {
            do
            {
                x.popFront;
                if (x.length == 0)
                {
                    break;
                }
            }
            while (x.index[0] < bi0);
            done = 2;
        }
        if (--done == 0)
        {
            goto L;
        }
        ai0 = x.index[0];
        if (y.index[0] < ai0)
        {
            do
            {
                y.popFront;
                if (y.length == 0)
                {
                    break;
                }
            }
            while (y.index[0] < ai0);
            done = 2;
        }
        if (--done == 0)
        {
            goto L;
        }
        continue;
        L:
        s = x.data[0] * y.data[0] + s;
        x.popFront;
        if (x.length == 0)
        {
            break;
        }
        y.popFront;
        if (y.length == 0)
        {
            break;
        }
    }

    return s;
}

///
unittest
{
    import mir.series;

    auto x = series([0u, 3, 5, 9, 100], [1, 3, 4, 9, 10]);
    auto y = series([1u, 3, 4, 9], [1, 10, 100, 1000]);
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
    V1 : Series!(I1*, T1*),
    T1, I1, V2)
(V1 x, V2 y)
    if (isDynamicArray!V2 || isSlice!V2)
{
    return dot!(typeof(return))(x, y);
}

///ditto
D dot(
    D,
    V1 : Series!(I1*, T1*),
    T1, I1, V2)
(V1 x, V2 y)
    if (isDynamicArray!V2 || isSlice!V2)
in
{
    if (x.length)
        assert(x.index[$-1] < y.length);
}
do
{

    import mir.internal.utility;

    alias T2 = ForeachType!V2;

    alias F = Unqual!(CommonType!(T1, T2));
    F s = 0;
    foreach (size_t i; 0 .. x.index.length)
    {
        s = y[x.index[i]] * x.data[i] + s;
    }

    return s;
}

///
unittest
{
    import mir.series;

    auto x = [0u, 3, 5, 9, 10].series([1.0, 3, 4, 9, 13]);
    auto y = [0.0, 1.0, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12];
    // x: [1, 0, 0, 3, 0, 4, 0, 0, 0, 9, 13,  0,  0,  0]
    // y: [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13]
    auto r = 0 + 3 * 3 + 4 * 5 + 9 * 9 + 13 * 10;
    assert(dot(x, y) == r);
    assert(dot(x, y.sliced) == r);
    assert(dot(x, y.slicedField) == r);
}
