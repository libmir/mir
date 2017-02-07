/**
License: $(LINK2 http://boost.org/LICENSE_1_0.txt, Boost License 1.0).

Authors: Ilya Yaroshenko
*/
module mir.sparse.blas.axpy;

import std.traits;
import mir.ndslice.slice;
import mir.sparse;

/++
Constant times a vector plus a vector.

Params:
    x = sparse vector
    y = dense vector
    alpha = scalar
Returns:
    `y = alpha * x + y`
+/
void axpy(
    CR,
    V1 : CompressedArray!(T1, I1),
    T1, I1, V2)
(in CR alpha, V1 x, V2 y)
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
            axpy(alpha, x, y.toDense);
            return;
        }
    }

    foreach (size_t i; 0 .. x.indexes.length)
    {
        auto j = x.indexes[i];
        y[j] = alpha * x.values[i] + y[j];
    }
}

///
unittest
{
    auto x = CompressedArray!(double, uint)([1.0, 3, 4, 9, 13], [0, 3, 5, 9, 10]);
    auto y = [0.0, 1.0, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12];
    axpy(2.0, x, y);
    assert(y == [2.0, 1.0, 2, 9, 4, 13, 6, 7, 8, 27, 36, 11, 12]);
}

unittest
{
    auto x = CompressedArray!(double, uint)([1.0, 3, 4, 9, 13], [0, 3, 5, 9, 10]);
    auto y = [0.0, 1.0, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12];
    axpy(2.0, x, y.sliced);
    assert(y == [2.0, 1.0, 2, 9, 4, 13, 6, 7, 8, 27, 36, 11, 12]);
}

unittest
{
    import std.typecons: No;
    auto x = CompressedArray!(double, uint)([1.0, 3, 4, 9, 13], [0, 3, 5, 9, 10]);
    auto y = [0.0, 1.0, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12];
    axpy(2.0, x, y.slicedField);
    assert(y == [2.0, 1.0, 2, 9, 4, 13, 6, 7, 8, 27, 36, 11, 12]);
}
