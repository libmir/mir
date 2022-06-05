/**
License: $(LINK2 http://boost.org/LICENSE_1_0.txt, Boost License 1.0).

Authors: Ilya Yaroshenko
*/
module mir.sparse.blas.axpy;

import std.traits;
import mir.ndslice.slice;
import mir.sparse;
import mir.series;

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
    V1 : Series!(I1, T1),
    I1, T1, V2)
(in CR alpha, V1 x, V2 y)
    if (isDynamicArray!V2 || isSlice!V2)
in
{
    if (x.index.length)
        assert(x.index[$-1] < y.length);
}
do
{
    import mir.internal.utility;

    foreach (size_t i; 0 .. x.index.length)
    {
        auto j = x.index[i];
        y[j] = alpha * x.data[i] + y[j];
    }
}

///
unittest
{
    import mir.series;
    auto x = series([0, 3, 5, 9, 10], [1.0, 3, 4, 9, 13]);
    auto y = [0.0, 1.0, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12];
    axpy(2.0, x, y);
    assert(y == [2.0, 1.0, 2, 9, 4, 13, 6, 7, 8, 27, 36, 11, 12]);
}

unittest
{
    import mir.series;
    auto x = series([0, 3, 5, 9, 10], [1.0, 3, 4, 9, 13]);
    auto y = [0.0, 1.0, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12];
    axpy(2.0, x, y.sliced);
    assert(y == [2.0, 1.0, 2, 9, 4, 13, 6, 7, 8, 27, 36, 11, 12]);
}

unittest
{
    auto x = series([0, 3, 5, 9, 10], [1.0, 3, 4, 9, 13]);
    auto y = [0.0, 1.0, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12];
    axpy(2.0, x, y.slicedField);
    assert(y == [2.0, 1.0, 2, 9, 4, 13, 6, 7, 8, 27, 36, 11, 12]);
}
