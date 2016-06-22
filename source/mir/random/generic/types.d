module mir.random.generic.types;

import std.traits: ReturnType;

protected:

/**
Major data unit of the Tinflex algorithm.
It is used to store
- (cached) values of the transformation (and its derivatives)
- area below the hat and squeeze function
- linked-list like reference to the right part of the interval (there will always
be exactly one interval with right = 0)
*/
struct IntervalPoint(S)
{
    import mir.random.generic.internal: LinearFun;

    // left position of the interval
    S x;

    // T_c family of the interval
    S c;

    // transformed values
    S tx, t1x, t2x;

    FunType type;

    LinearFun!S hat;
    LinearFun!S squeeze;

    S hatA;
    S squeezeA;

    // save "reference" to right-side interval
    size_t right = 0;
}

/// ditto
IntervalPoint!S intervalPoint(F0, F1, F2, S)
                             (in F0 f0, in F1 f1, in F2 f2, in S x, in S c = S.init)
    if (is(ReturnType!F0 == S) && is(ReturnType!F1 == S) && is(ReturnType!F2 == S))
{
    return intervalPoint(x, f0(x), f1(x), f2(x), c);
}

/**
Create an intervalPoint given a point x and the value of a function and it's
first two derivatives
*/
IntervalPoint!S intervalPoint(S)(in S x, in S f0x, in S f1x, in S f2x, in S c = S.init)
{
    IntervalPoint!S s;
    s.x = x;
    s.tx = f0x;
    s.t1x = f1x;
    s.t2x = f2x;
    s.c = c;
    return s;
}

/**
Notations of different function types according to the Tinflex paper.
It is based on this naming scheme:

- a: concAve
- b: convex
- Type 4 is the pure case without any inflection point
*/
enum FunType {T1a, T1b, T2a, T2b, T3a, T3b, T4a, T4b}

/**
Checks whether the function type is concave
*/
bool isConcave(in FunType t) pure @safe @nogc nothrow
{
    with(FunType)
    return t == T1a || t == T2a || t == T3a || t == T4a;
}

/**
Checks whether the function type is convex
*/
bool isConvex(FunType t) pure @safe @nogc nothrow
{
    return !isConcave(t);
}

/**
Determine the function type of an interval.
Based on Theorem 1 of the Tinflex paper.
Params:
    bl = left side of the interval
    br = right side of the interval
*/
FunType determineType(F0, F1, F2, S)
                     (in F0 f0, in F1 f1, in F2 f2, in S bl, in S br)
    if (is(ReturnType!F0 == S) && is(ReturnType!F1 == S) && is(ReturnType!F2 == S))
{
    return determineType(intervalPoint(f0, f1, f2, bl), intervalPoint(f0, f1, f2, br));
}

/// ditto
FunType determineType(S)(in IntervalPoint!S l, in IntervalPoint!S r)
{
    assert(l.x < r.x, "invalid interval");

    // slope
    auto R = (r.tx - l.tx) / (r.x- l.x);

    with(FunType)
    {

        if (l.t1x >= R && r.t1x >= R)
            return T1a;
        if (l.t1x <= R && r.t1x <= R)
            return T1b;

        if (l.t1x >= R && R >= r.t1x)
        {
            if (l.t2x < 0 && r.t2x > 0)
                return T2a;
            if (l.t2x > 0 && r.t2x < 0)
                return T2b;
        }
        else if (l.t1x <= R && R <= r.t1x)
        {
            if (l.t2x < 0 && r.t2x > 0)
                return T3a;
            if (l.t2x > 0 && r.t2x < 0)
                return T3b;
        }
        if (l.t2x <= 0 && r.t2x <= 0)
            return T4a;
        if (l.t2x >= 0 && r.t2x >= 0)
            return T4b;
    }
    assert(0, "Unknown type");
}

unittest
{
    auto f0 = (int x) => x ^^ 4;
    auto f1 = (int x) => 4 * x ^^ 3;
    auto f2 = (int x) => 12 * x * x;

    with(FunType)
    {
        // entirely convex
        assert(determineType(f0, f1, f2, -3, -1) == T4b);
        assert(determineType(f0, f1, f2, -1, 1) == T4b);
        assert(determineType(f0, f1, f2, 1, 3) == T4b);
    }
}

unittest
{
    auto f0 = (double x) => x ^^ 3;
    auto f1 = (double x) => 3 * x ^^ 2;
    auto f2 = (double x) => 6 * x;

    with(FunType)
    {
        // concave
        assert(determineType(f0, f1, f2, -3.0, -1) == T4a);
        // inflection point at x = 0, concave before
        assert(determineType(f0, f1, f2, -1.0, 1) == T1a);
        // convex
        assert(determineType(f0, f1, f2, 1.0, 3) == T4b);
    }
}

unittest
{
    import std.math: PI;
    import mir.internal.math : cos, sin;
    auto dt(X)(X x, X y)
    {
        auto f0 = (X x) => sin(x);
        auto f1 = (X x) => cos(x);
        auto f2 = (X x) => -sin(x);
        return determineType(f0, f1, f2, x, y);
    }

    with(FunType)
    {
        // type 1a: concave
        assert(dt(0, 2 * PI) == T1a);
        assert(dt(2 * PI, 4 * PI) == T1a);
        assert(dt(2.0, 4) == T1a);
        assert(dt(0.0, 5) == T1a);
        assert(dt(1.0, 5) == T1a);

        // type 1b: convex
        assert(dt(-PI, PI) == T1b);
        assert(dt(PI, 3 * PI) == T1b);
        assert(dt(4.0, 8) == T1b);

        // type 2a: concave
        assert(dt(2 * PI, 3 * PI) == T2a);
        assert(dt(1.0, 4) == T2a);

        // type 2b: convex
        assert(dt(6.0, 8) == T2b);

        // type 3a: concave
        assert(dt(3.0, 4) == T3a);
        assert(dt(2.0, 5.7) == T3a);

        // type 3b: concave
        assert(dt(PI, 2 * PI) == T3b);
        assert(dt(-3.0, 0.1) == T3b);

        // type 4a - pure concave intervals (special case of 2a)
        assert(dt(0.0, PI - 0.01) == T4a);
        assert(dt(0.0, 3) == T4a);

        // type 4b - pure convex intervals (special case of 3b)
        assert(dt(PI, 2 * PI - 0.01) == T4b);
        assert(dt(4.0, 6) == T4b);

        // TODO: zero seems to be a special case here
        assert(dt(-PI, 0) == T4a); // should be convex!
        // but:
        assert(dt(PI, 2 * PI) == T3b);

        assert(dt(0, PI) == T4b); // should be concave (a)
        // but:
        assert(dt(2 * PI, 3 * PI) == T2a);
    }
}
