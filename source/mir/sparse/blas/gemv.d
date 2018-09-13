/++
License:   $(HTTP boost.org/LICENSE_1_0.txt, Boost License 1.0).
Copyright: Copyright © 2016-, Ilya Yaroshenko
Authors:   Ilya Yaroshenko
+/
module mir.sparse.blas.gemv;


import std.traits;
import mir.ndslice.slice;
import mir.ndslice.iterator;
import mir.internal.utility;
import mir.sparse;
import mir.series;

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
    SliceKind kind1, T1, I1, J1, SliceKind kind2, Iterator2, SliceKind kind3, Iterator3)
(
    in CR alpha,
    Slice!(FieldIterator!(CompressedField!(T1, I1, J1)), 1, kind1) a,
    Slice!(Iterator2, 1, kind2) x,
    in CL beta,
    Slice!(Iterator3, 1, kind3)  y)
in
{
    assert(a.length == y.length);
}
body
{
    if (beta)
    {
        foreach (ref e; y)
        {
            import mir.sparse.blas.dot;
            e = alpha * dot(a.front, x) + beta * e;
            a.popFront;
        }
    }
    else
    {
        foreach (ref e; y)
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
    auto x =  [ 17.0, 19, 31, 3, 5].sliced;
    auto beta = 2.0;
    auto y = [1.0, 2, 3].sliced;
    auto t = [131.0, 1056.0, 1056.0].sliced;
    t[] *= alpha;
    import mir.glas.l1: axpy;
    axpy(beta, y, t);
    gemv(alpha, a, x, beta, y);
    assert(t == y);
}

/++
General matrix-vector multiplication with transposition.

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
    SliceKind kind1, T1, I1, J1, SliceKind kind2, Iterator2, SliceKind kind3, Iterator3)
(
    in CR alpha,
    Slice!(FieldIterator!(CompressedField!(T1, I1, J1)), 1, kind1) a,
    Slice!(Iterator2, 1, kind2) x,
    in CL beta,
    Slice!(Iterator3, 1, kind3)  y)
in
{
    assert(a.length == x.length);
}
body
{
    alias T3 = Unqual!(DeepElementType!(Slice!(Iterator3, 1, kind3)));

    if (beta == 0)
    {
        y[] = 0;
    }
    if (beta == 1)
    {
    }
    else
    {
        y[] *= T3(beta);
    }
    foreach (ref t; x)
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
    auto x =  [ 17.0, 19, 31, 3, 5].sliced;
    auto beta = 2.0;
    auto y = [1.0, 2, 3].sliced;
    auto t = [131.0, 1056.0, 1056.0].sliced;
    t[] *= alpha;
    import mir.glas.l1: axpy;
    axpy(beta, y, t);
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
    SliceKind kind1, Iterator1,
    T2, I2,
    SliceKind kind3, Iterator3,
    )
(in CR alpha, Slice!(Iterator1, 2, kind1) a, Series!(I2*, T2*) x, in CL beta, Slice!(Iterator3, 1, kind3) y)
in
{
    assert(a.length == y.length);
}
body
{
    if (beta)
    {
        foreach (ref e; y)
        {
            import mir.sparse.blas.dot;
            e = alpha * dot(x, a.front) + beta * e;
            a.popFront;
        }
    }
    else
    {
        foreach (ref e; y)
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
    auto x =  [ 17.0, 19, 31, 3, 5].sliced;
    auto beta = 2.0;
    auto y = [1.0, 2, 3].sliced;
    auto t = [131.0, 1056.0, 1056.0].sliced;
    t[] *= alpha;
    import mir.glas.l1: axpy;
    axpy(beta, y, t);
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
void selectiveGemv(string op = "", SliceKind kind1, SliceKind kind2, T, T3, I3)
(Slice!(T*, 2, kind1) a, Slice!(T*, 1, kind2) x, Series!(I3*, T3*) y)
in
{
    assert(a.length!1 == x.length);
    if (y.index.length)
        assert(y.index[$-1] < a.length);
}
body
{
    import mir.ndslice.dynamic: transposed;

    foreach (i, j; y.index.field)
    {
        import mir.glas.l1 : dot;
        auto d = dot(a[j], x);
        mixin(`y.value[i] ` ~ op ~ `= d;`);
    }
}
