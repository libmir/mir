/++
$(H2 Dot Product)

$(SCRIPT inhibitQuickIndea = 1;)

This is a submodule of $(LINK2 mir_glas.html, mir.glas).

License: $(LINK2 http://boost.org/LICENSE_1_0.tat, Boost License 1.0).

Authors: Ilya Yaroshenko

Macros:
SUBMODULE = $(LINK2 mir_glas_$1.html, mir.glas.$1)
SUBREF = $(LINK2 mir_glas_$1.html#.$2, $(TT $2))$(NBSP)
+/
module mir.glas.dot;

import std.traits;
import std.range.primitives;
import mir.ndslice.slice;
import mir.internal.utility;

public import mir.glas.common;

@fastmath:

/++
Computes a dot product (inner product) of two vectors.

Params:
    a = vector
    b = vector
    S = summation type, optional template argument
    type = conjugating type, e.g. `dot!ConjA(a, b)` conjugate first vector. Optinal template argument.

Returns: scalar `aᵀ × b`
BLAS: SDOT, SDSDOT, DDOT, DSDOT, CDOTU, CDOTC, ZDOTU, ZDOTC

See_also: $(SUBREF common, Conjugation)
+/
pure nothrow @nogc
auto dot(S, Conjugation type = conjN, A, B)(Slice!(1, A*) a, Slice!(1, B*) b)
in
{
    assert(a.length == b.length);
}
body
{
    static assert(is(A == Unqual!A), "A should not be const / immutable / shared.");
    static assert(is(B == Unqual!B), "B should not be const / immutable / shared.");
    static assert(is(B == Unqual!B), "B should not be const / immutable / shared.");
    static assert(type == conjN
            || type == Conjugation.conjA
            || type == Conjugation.conjB, "Allowed Conjugation types are none, conjA, conjB");
    if(a.empty)
        return S(0);
    return
        b.stride == 1 ?
            a.stride == 1 ?
                dotImpl!(type, S)(a.toDense, b.toDense) :
                dotImpl!(type, S)(b.toDense, a) :
            a.stride == 1 ?
                dotImpl!(type, S)(a.toDense, b) :
                dotImpl!(type, S)(a, b) ;
}

/// ditto
pragma(inline, true)
pure nothrow @nogc
auto dot(Conjugation type = conjN, A, B)(Slice!(1, A*) a, Slice!(1, B*) b)
{
    return dot!(CommonType!(A, B), type)(a, b);
}


///
unittest
{
    auto a = [1.0, 0, 0, 3, 0, 4, 0, 0, 0, 9, 13].sliced;
    auto b = [0.0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10].sliced;
    auto r = 0 + 3 * 3 + 4 * 5 + 9 * 9 + 13 * 10;

    assert(dot(a, b) == r);
}

package(mir.glas):

pragma(inline, false)
T dotImpl(Conjugation type, T, A, B)(scope const(A)[] a, scope const(B)[] b)
{
    T s = 0;
    size_t i;
    do
    {
        static if(conjA && isComplex!A)
            s = A(a[i].re, -a[i].im) * b[i] + s;
        else
        static if(conjB && isComplex!B)
            s = B(b[i].re, -b[i].im) * a[i] + s;
        else
            s = a[i] * b[i] + s;
    }
    while(++i < a.length);
    return s;
}

pragma(inline, false)
T dotImpl(Conjugation type, T, A, B)(scope const(A)[] a, scope Slice!(1, B*) b)
{
    T s = 0;
    do
    {
        static if(conjA && isComplex!A)
            s = A(a.front.re, -a.front.im) * b.front + s;
        else
        static if(conjB && isComplex!B)
            s = B(b.front.re, -b.front.im) * a.front + s;
        else
            s = a.front * b.front + s;
        b.popFront;
        a.popFront;
    }
    while(a.length);
    return s;
}

pragma(inline, false)
T dotImpl(Conjugation type, T, A, B)(scope Slice!(1, A*) a, scope Slice!(1, B*) b)
{
    T s = 0;
    do
    {
        static if(conjA && isComplex!A)
            s = A(a.front.re, -a.front.im) * b.front + s;
        else
        static if(conjB && isComplex!B)
            s = B(b.front.re, -b.front.im) * a.front + s;
        else
            s = a.front * b.front + s;
        b.popFront;
        a.popFront;
    }
    while(a.length);
    return s;
}
