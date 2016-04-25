/**
License: $(LINK2 http://boost.org/LICENSE_1_0.txt, Boost License 1.0).

Authors: Ilya Yaroshenko
*/
module mir.blas.dot;

import mir.ndslice.slice;
import std.traits;
import mir.internal.utility: isVector;

/++
Computes a dot product (inner product) of two vectors.
Params:
    x = vector
    y = vector
Returns:
    scalar `xᵀ × y`
Note:
    `dot` implementation is naive for now.
+/
auto dot(V1, V2)(scope V1 x, scope V2 y)
    if (isVector!V1 && isVector!V2 &&
        is(Unqual!(ForeachType!V1) == Unqual!(ForeachType!V2)))
in
{
    assert(x.length == y.length);
}
body
{
    alias T = Unqual!(ForeachType!V1);
    static if(isDynamicArray!V1 && isDynamicArray!V2)
    {
        return dotImpl(x, y);
    }
    else
    static if(isDynamicArray!V1 && !isDynamicArray!V2)
    {
        import mir.internal.utility;
        return
            y.stride == 1 ?
                dotImpl(y.toDense, x) :
                dotImpl(x, y);
    }
    else
    static if(!isDynamicArray!V1 && isDynamicArray!V2)
    {
        import mir.internal.utility;
        return
            x.stride == 1 ?
                dotImpl(x.toDense, y) :
                dotImpl(y, x);
    }
    else
    {
        import mir.internal.utility;
        return
            y.stride == 1 ?
                x.stride == 1 ?
                    dotImpl(x.toDense, y.toDense) :
                    dotImpl(y.toDense, x) :
                x.stride == 1 ?
                    dotImpl(x.toDense, y) :
                    dotImpl(x, y) ;
    }
}

///
unittest
{
    import std.typecons: No;

    Slice!(1, double*) a;
    Slice!(1, const(double)*) b;
    b = cast(Slice!(1, const(double)*)) a;

    static auto foo(in Slice!(1, const(double)*) a)
    {
        Slice!(1, const(double)*) b;
        b = a;
    }

    auto x = [1.0, 0, 0, 3, 0, 4, 0, 0, 0, 9, 13];
    auto y = [0.0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
    auto r = 0 + 3 * 3 + 4 * 5 + 9 * 9 + 13 * 10;

    assert(dot(x, y) == r);
    assert(dot(x, y.sliced) == r);

    assert(dot(x.sliced, y) == r);
    assert(dot(x.sliced, y.sliced) == r);
}

pragma(inline, false) package(mir.blas)
{
    T dotImpl(T)(scope const(T)[] x, scope const(T)[] y)
    {
        //import mir.internal.math: fmuladd;
        T s = 0;
        foreach(size_t i; 0 .. x.length)
        {
            s = x[i] * y[i] + s;
        }
        return s;
    }

    T dotImpl(T)(scope const(T)[] x, scope Slice!(1, T*) y)
    {
        import mir.internal.math: fmuladd;
        T s = 0;
        foreach(ref xe; x)
        {
            s = xe * y.front + s;
            y.popFront;
        }
        return s;
    }

    T dotImpl(T)(scope Slice!(1, T*) x, scope Slice!(1, T*) y)
    {
        import mir.internal.math: fmuladd;
        T s = 0;
        foreach(ref xe; x)
        {
            s = xe * y.front + s;
            y.popFront;
        }
        return s;
    }
}
