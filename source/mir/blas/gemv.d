/**
License: $(LINK2 http://boost.org/LICENSE_1_0.txt, Boost License 1.0).

Authors: Ilya Yaroshenko
*/
module mir.blas.gemv;

import std.traits;
import mir.ndslice.slice;

/++
Params:
    alpha = scalar
    a = matrix
    x = vector
    beta = scalar
    y = vector
Returns:
    `y = alpha * a × x + beta * y` if beta does not equal null and `y = alpha * a × x` otherwise.
Note:
    `gemv` implementation is naive for now.
+/
void gemv(T)
(T alpha, Slice!(2, T*) a, Slice!(1, T*) x, T beta, Slice!(1, T*) y)
in
{
    assert(a.length == y.length);
    assert(a.length!1 == x.length);
}
body
{
    while(!y.empty)
    {
        import mir.blas.dot: dot;
        y.front = alpha * dot(a.front, x) + beta * y.front;

        a.popFront;
        y.popFront;
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
    auto x =  [ 17.0, 19, 31, 3, 5].sliced;
    auto beta = 2.0;
    auto y = [1.0, 2, 3].sliced;

    // result
    auto t = [131.0, 1056.0, 1056.0];
    t[] *= alpha;
    foreach(i, ref e; t)
        e += y[i] * beta;

    gemv(alpha, a, x, beta, y);

    assert(t == y);
}
