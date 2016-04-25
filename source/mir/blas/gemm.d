/**
License: $(LINK2 http://boost.org/LICENSE_1_0.txt, Boost License 1.0).

Authors: Ilya Yaroshenko
*/
module mir.blas.gemm;

import std.traits;
import mir.ndslice.slice;

/++
General matrix-matrix multiplication.

Params:
    alpha = scalar
    a = matrix
    b = matrix
    beta = scalar
    c = matrix
Returns:
    `c = alpha * a × x + beta * c`
Note:
    `gemm` implementation is naive for now.
+/
void gemm(T)
(T alpha, Slice!(2, T*) a, Slice!(2, T*) b, T beta, Slice!(2, T*) c)
in
{
    assert(a.length!1 == b.length!0);
    assert(c.length!0 == a.length!0);
    assert(c.length!1 == b.length!1);
}
body
{
    import mir.ndslice.iteration: transposed;
    import mir.blas.gemv: gemv;

    if (b.stride == 1)
    {
        b = b.transposed;
        c = c.transposed;

        while (!c.empty)
        {
            gemv(alpha, a, b.front, beta, c.front);

            b.popFront;
            c.popFront;
        }
    }
    else
    {
        b = b.transposed;

        while (!c.empty)
        {
            gemv(alpha, b, a.front, beta, c.front);

            a.popFront;
            c.popFront;
        }
    }
}

///
unittest
{
    auto a = slice!double(3, 5);
    a[] =
        [[-5, 1, 7, 7, -4],
         [-1, -5, 6, 3, -3],
         [-5, -2, -3, 6, 0]];

    auto b = slice!double(5, 4);
    b[] =
        [[-5.0, -3, 3, 1],
         [4.0, 3, 6, 4],
         [-4.0, -2, -2, 2],
         [-1.0, 9, 4, 8],
         [9.0, 8, 3, -2]];

    auto c = slice!double(3, 4);
    c[] = 0;

    gemm(1.0, a, b, 0.0, c);

    assert(c ==
        [[-42.0, 35, -7, 77],
         [-69.0, -21, -42, 21],
         [23.0, 69, 3, 29]]);
}
