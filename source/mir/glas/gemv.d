/++
$(H2 General Matrix-Vector Multiplication)

$(SCRIPT inhibitQuickIndex = 1;)

This is a submodule of $(LINK2 mir_glas.html, mir.glas).

License: $(LINK2 http://boost.org/LICENSE_1_0.txt, Boost License 1.0).

Authors: Ilya Yaroshenko

Macros:
SUBMODULE = $(LINK2 mir_glas_$1.html, mir.glas.$1)
SUBREF = $(LINK2 mir_glas_$1.html#.$2, $(TT $2))$(NBSP)
+/
module mir.glas.gemv;

import std.traits;
import mir.ndslice.slice;
import mir.internal.utility;

public import mir.glas.common;

@fastmath:

/++
General matrix-vector multiplication.

Params:
    alpha = scalar
    a = matrix
    b = vector
    beta = scalar
    c = vector
    type = conjugating type, Optinal template argument

Pseudo_code:
    `y = alpha * a × x + beta * y` if beta does not equal zero and `y = alpha * a × x` otherwise.

Note:
    GLAS does not requre transposition parameters.
    Use $(LINK2 mir_ndslice_iteration.html#transposed, mir.ndslice.iteration.transposed)
    to perform zero cost `Slice` transposition.

BLAS: SGEMV, DGEMV, CGEMV, ZGEMV

See_also: $(SUBREF common, Conjugation)
+/
pure nothrow @nogc
void gemv(Conjugation type = conjN, A, B, C)
(C alpha, Slice!(2, A*) a, Slice!(1, B*) b, C beta, Slice!(1, C*) y)
    if(type == conjN || type == conjA || type == conjB)
in
{
    assert(a.length == y.length);
    assert(a.length!1 == b.length);
}
body
{
    import mir.glas.dot: dotImpl;
    alias F = CommonType!(A, B);
    if(b.empty)
        return;
    if(y.empty)
        return;
    if(b.stride == 1)
    {
        auto bd = b.toDense;
        if(a.stride!1 == 1)
        {
            if(beta != 0)
            {
                do
                {
                    y.front = alpha * dotImpl!(swapConj!type, F)(bd, a.front) + beta * y.front;
                    a.popFront;
                    y.popFront;
                }
                while (y.length);
            }
            else
            {
                do
                {
                    y.front = alpha * dotImpl!(swapConj!type, F)(bd, a.front);
                    a.popFront;
                    y.popFront;
                }
                while (y.length);
            }
        }
        else
        {
            if(beta != 0)
            {
                do
                {
                    y.front = alpha * dotImpl!(swapConj!type, F)(bd, a.front) + beta * y.front;
                    a.popFront;
                    y.popFront;
                }
                while (y.length);
            }
            else
            {
                do
                {
                    y.front = alpha * dotImpl!(swapConj!type, F)(bd, a.front);
                    a.popFront;
                    y.popFront;
                }
                while (y.length);
            }
        }
    }
    else
    {
        if(a.stride!1 == 1)
        {
            if(beta != 0)
            {
                do
                {
                    y.front = alpha * dotImpl!(type, F)(a.front.toDense, b) + beta * y.front;
                    a.popFront;
                    y.popFront;
                }
                while (y.length);
            }
            else
            {
                do
                {
                    y.front = alpha * dotImpl!(type, F)(a.front.toDense, b);
                    a.popFront;
                    y.popFront;
                }
                while (y.length);
            }
        }
        else
        {
            if(beta != 0)
            {
                do
                {
                    y.front = alpha * dotImpl!(type, F)(a.front, b) + beta * y.front;
                    a.popFront;
                    y.popFront;
                }
                while (y.length);
            }
            else
            {
                do
                {
                    y.front = alpha * dotImpl!(type, F)(a.front, b);
                    a.popFront;
                    y.popFront;
                }
                while (y.length);
            }
        }
    }
}

///
unittest
{
    auto alpha = 3.0;
    auto a = slice!double(3, 5);
    a[] =
        [[ 0.0, 2.0,  3.0, 0.0, 0.0],
         [ 6.0, 0.0, 30.0, 8.0, 0.0],
         [ 6.0, 0.0, 30.0, 8.0, 0.0]];
    auto b =  [ 17.0, 19, 31, 3, 5].sliced;
    auto beta = 2.0;
    auto c = [1.0, 2, 3].sliced;

    gemv(alpha, a, b, beta, c);


    // naive implementation for test
    auto t = [1.0, 2, 3].sliced;
    import mir.glas.dot;
    foreach(i; 0..c.length)
        t[i] = alpha * dot(a[i], b) + beta * t[i];

    assert(t == c);
}
