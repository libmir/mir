/**
License: $(LINK2 http://boost.org/LICENSE_1_0.txt, Boost License 1.0).

Authors: Ilya Yaroshenko
*/
module mir.sparse.blas.gemv;

import std.traits;
import mir.ndslice.slice;
import mir.sparse;

/++
General matrix-vector multiplication.

Params:
    alpha = scalar
    a = sparse matrix (CSR format)
    x = dense vector
    beta = scalar
    y = dense vector
Returns:
    `y = alpha * a × x + beta * y` if beta does not equal null and `y = alpha * a × x` otherwise.
+/
void gemv(
    CR,
    CL,
    M1 : Slice!(1, V1),
    V1 : CompressedMap!(T1, I1, J1),
    T1, I1, J1, V2, V3)
(in CR alpha, M1 a, V2 x, in CL beta, V3 y)
    if ((isDynamicArray!V2 || is(V2 : Slice!(1, V2R), V2R)) &&
        (isDynamicArray!V3 || is(V3 : Slice!(1, V3R), V3R)))
in
{
    assert(a.length == y.length);
}
body
{
    import mir.internal.utility;
    static if(isSimpleSlice!V2)
    {
        if(x.stride == 1)
        {
            gemv(alpha, a, x.toDense, beta, y);
            return;
        }
    }
    if(beta)
    {
        foreach(ref e; y)
        {
            import mir.sparse.blas.dot;
            e = alpha * dot(a.front, x) + beta * e;
            a.popFront;
        }
    }
    else
    {
        foreach(ref e; y)
        {
            import mir.sparse.blas.dot;
            e = alpha * dot(a.front, x);
            a.popFront;
        }
    }
}

///
unittest
{
    auto slice = sparse!double(3, 5);
    slice[] =
        [[ 0.0, 2.0,  3.0, 0.0, 0.0],
         [ 6.0, 0.0, 30.0, 8.0, 0.0],
         [ 6.0, 0.0, 30.0, 8.0, 0.0]];
    auto alpha = 3.0;
    auto a = slice.compress;
    auto x =  [ 17.0, 19, 31, 3, 5];
    auto beta = 2.0;
    auto y = [1.0, 2, 3];
    auto t = [131.0, 1056.0, 1056.0];
    t[] *= alpha;
    t[] += y[] * beta;
    gemv(alpha, a, x, beta, y);
    assert(t == y);
}

unittest
{
    auto slice = sparse!double(3, 5);
    slice[] =
        [[ 0.0, 2.0,  3.0, 0.0, 0.0],
         [ 6.0, 0.0, 30.0, 8.0, 0.0],
         [ 6.0, 0.0, 30.0, 8.0, 0.0]];
    auto alpha = 3.0;
    auto a = slice.compress;
    auto x =  [ 17.0, 19, 31, 3, 5].sliced;
    auto beta = 2.0;
    auto y = [1.0, 2, 3];
    auto t = [131.0, 1056.0, 1056.0];
    t[] *= alpha;
    t[] += y[] * beta;
    gemv(alpha, a, x, beta, y);
    assert(t == y);
}

/++
General matrix-vector multiplication with transformation.

Params:
    alpha = scalar
    a = sparse matrix (CSR format)
    x = dense vector
    beta = scalar
    y = dense vector
Returns:
    `y = alpha * aᵀ × x + beta * y` if beta does not equal null and `y = alpha * aᵀ × x` otherwise.
+/
void gemtv(
    CR,
    CL,
    M1 : Slice!(1, V1),
    V1 : CompressedMap!(T1, I1, J1),
    T1, I1, J1, V2, V3)
(in CR alpha, M1 a, V2 x, in CL beta, V3 y)
    if ((isDynamicArray!V2 || is(V2 : Slice!(1, V2R), V2R)) &&
        (isDynamicArray!V3 || is(V3 : Slice!(1, V3R), V3R)))
in
{
    assert(a.length == x.length);
}
body
{
    import mir.internal.utility;
    alias T3 = Unqual!(ForeachType!V3);

    static if(isSimpleSlice!V3)
    {
        if(y.stride == 1)
        {
            gemtv(alpha, a, x, T3(beta), y.toDense);
            return;
        }
    }

    if (beta == 0)
    {
        y[] = 0;
    }
    if(beta == 1)
    {
    }
    else
    {
        y[] *= T3(beta);
    }
    foreach(ref t; x)
    {
        import mir.sparse.blas.axpy;
        axpy(alpha * t, a.front, y);
        a.popFront;
    }
}

///
unittest
{
    auto slice = sparse!double(5, 3);
    slice[] =
        [[0.0,  6.0,  6.0],
         [2.0,  0.0,  0.0],
         [3.0, 30.0, 30.0],
         [0.0,  8.0,  8.0],
         [0.0,  0.0,  0.0]];
    auto alpha = 3.0;
    auto a = slice.compress;
    auto x =  [ 17.0, 19, 31, 3, 5];
    auto beta = 2.0;
    auto y = [1.0, 2, 3];
    auto t = [131.0, 1056.0, 1056.0];
    t[] *= alpha;
    t[] += y[] * beta;
    gemtv(alpha, a, x, beta, y);
    assert(t == y);
}

unittest
{
    auto slice = sparse!double(5, 3);
    slice[] =
        [[0.0,  6.0,  6.0],
         [2.0,  0.0,  0.0],
         [3.0, 30.0, 30.0],
         [0.0,  8.0,  8.0],
         [0.0,  0.0,  0.0]];
    auto alpha = 3.0;
    auto a = slice.compress;
    auto x =  [ 17.0, 19, 31, 3, 5];
    auto beta = 2.0;
    auto y = [1.0, 2, 3].sliced;
    auto t = [131.0, 1056.0, 1056.0];
    t[] *= alpha;
    foreach(i, ref e; t)
        e += y[i] * beta;
    gemtv(alpha, a, x, beta, y);
    assert(t == y);
}

/++
General matrix-vector multiplication for sparse vectors.

Params:
    alpha = scalar
    a = dense matrix
    x = sparse vector
    beta = scalar
    y = dense vector
Returns:
    `y = alpha * a × x + beta * y` if beta does not equal null and `y = alpha * a × x` otherwise.
+/
void gemv(
    CR,
    CL,
    M1 : Slice!(2, V1), V1,
    V2 : CompressedArray!(T2, I2),
    T2, I2, V3)
(in CR alpha, M1 a, V2 x, in CL beta, V3 y)
    if (isDynamicArray!V3 || is(V3 : Slice!(1, V3R), V3R))
in
{
    assert(a.length == y.length);
}
body
{
    import mir.internal.utility;
    static if(isSimpleSlice!V3)
    {
        if(y.stride == 1)
        {
            gemv(alpha, a, x, beta, y.toDense);
            return;
        }
    }
    if(beta)
    {
        foreach(ref e; y)
        {
            import mir.sparse.blas.dot;
            e = alpha * dot(x, a.front) + beta * e;
            a.popFront;
        }
    }
    else
    {
        foreach(ref e; y)
        {
            import mir.sparse.blas.dot;
            e = alpha * dot(x, a.front);
            a.popFront;
        }
    }
}

///
unittest
{
    auto slice = sparse!double(3, 5);
    slice[] =
        [[ 0.0, 2.0,  3.0, 0.0, 0.0],
         [ 6.0, 0.0, 30.0, 8.0, 0.0],
         [ 6.0, 0.0, 30.0, 8.0, 0.0]];
    auto alpha = 3.0;
    auto a = slice.compress;
    auto x =  [ 17.0, 19, 31, 3, 5];
    auto beta = 2.0;
    auto y = [1.0, 2, 3];
    auto t = [131.0, 1056.0, 1056.0];
    t[] *= alpha;
    t[] += y[] * beta;
    gemv(alpha, a, x, beta, y);
    assert(t == y);
}

/++
Selective general matrix-vector multiplication with a selector sparse vector.

Params:
    a = dense matrix
    x = dense vector
    y = sparse vector (compressed)
Returns:
    `y[available indexes] <op>= (alpha * a × x)[available indexes]`.
+/
void selectiveGemv(string op = "", T, V3 : CompressedArray!(T3, I3), T3, I3)
(Slice!(2, T*) a, Slice!(1, T*) x, V3 y)
in
{
    assert(a.length!1 == x.length);
    if(y.indexes.length)
        assert(y.indexes[$-1] < a.length);
}
body
{
    import mir.ndslice.iteration: transposed;
    import mir.blas.dot;

    foreach(i, j; y.indexes)
    {
        mixin(`y.values[i] ` ~ op ~ `= dot(a[j], x);`);
    }
}
