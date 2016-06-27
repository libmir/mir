module mir.random.tinflex.internal.types;

import std.traits: ReturnType, isFloatingPoint;

/**
Major data unit of the Tinflex algorithm.
It is used to store
- (cached) values of the transformation (and its derivatives)
- area below the hat and squeeze function
- linked-list like reference to the right part of the interval (there will always
be exactly one interval with right = 0)
*/
struct IntervalPoint(S)
    if (isFloatingPoint!S)
{
    import mir.random.tinflex.internal.linearfun : LinearFun;

    /// left position of the interval
    immutable S x;

    /// T_c family of the interval
    immutable S c;

    /// transformed values
    immutable S tx, t1x, t2x;

    this (in S tx, in S t1x, in S t2x, in S x, in S c)
    {
        this.tx = tx;
        this.t1x = t1x;
        this.t2x = t2x;
        this.x = x;
        this.c = c;
    }

    LinearFun!S hat;
    LinearFun!S squeeze;

    S hatArea;
    S squeezeArea;

    // disallow NaN points
    invariant {
        import std.math : isFinite, isNaN;
        import std.meta : AliasSeq;
        //alias seq =  AliasSeq!(x, c, tx, t1x, t2x);
        alias seq =  AliasSeq!(x, c, tx);
        foreach (i, v; seq)
            assert(!v.isNaN, "variable " ~ seq[i].stringof ~ " isn't allowed to be NaN");

        if (x.isFinite)
        {
            alias tseq =  AliasSeq!(t1x, t2x);
            foreach (i, v; tseq)
                assert(!v.isNaN, "variable " ~ tseq[i].stringof ~ " isn't allowed to be NaN");
        }
    }
}

/**
Reduced version of $(LREF IntervalPoint). Contains only the necessary information
needed in the generation phase.
*/
struct GenerationPoint(S)
    if (isFloatingPoint!S)
{
    import mir.random.tinflex.internal.linearfun : LinearFun;

    /// left position of the interval
    S x;

    /// T_c family of the interval
    S c;

    LinearFun!S hat;
    LinearFun!S squeeze;

    S hatArea;
    S squeezeArea;

    // disallow NaN points
    invariant {
        import std.math : isNaN;
        import std.meta : AliasSeq;
        alias seq =  AliasSeq!(x, c, hatArea, squeezeArea);
        foreach (i, v; seq)
            assert(!v.isNaN, "variable " ~ seq[i].stringof ~ " isn't allowed to be NaN");
    }
}

/**
Notations of different function types according to the Tinflex paper.
It is based on this naming scheme:

- a: concAve
- b: convex
- Type 4 is the pure case without any inflection point
*/
enum FunType {undefined, T1a, T1b, T2a, T2b, T3a, T3b, T4a, T4b}

/**
Determine the function type of an interval.
Based on Theorem 1 of the Tinflex paper.
Params:
    bl = left side of the interval
    br = right side of the interval
*/
FunType determineType(S)(in IntervalPoint!S l, in IntervalPoint!S r)
in
{
    import std.math : isInfinity, isNaN;
    assert(l.x < r.x, "invalid interval");
    assert(!isNaN(l.tx) && !isNaN(r.tx), "Invalid interval points");
}
body
{
    // slope of the interval
    auto R = (r.tx - l.tx) / (r.x- l.x);

    with(FunType)
    {
        if (l.t1x >= R && r.t1x >= R)
            return T1a;
        if (l.t1x <= R && r.t1x <= R)
            return T1b;

        if (l.t2x <= 0 && r.t2x <= 0)
            return T4a;
        if (l.t2x >= 0 && r.t2x >= 0)
            return T4b;

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

        return undefined;
    }
}

unittest
{
    import std.meta : AliasSeq;
    foreach (S; AliasSeq!(float, double, real)) with(FunType)
    {
        const f0 = (S x) => x ^^ 4;
        const f1 = (S x) => 4 * x ^^ 3;
        const f2 = (S x) => 12 * x * x;
        enum c = 42; // c doesn't matter here
        auto dt = (S l, S r) => determineType(IntervalPoint!S(f0(l), f1(l), f2(l), l, c),
                                              IntervalPoint!S(f0(r), f1(r), f2(r), r, c));

        // entirely convex
        assert(dt(-3.0, -1) == T4b);
        assert(dt(-1.0, 1) == T4b);
        assert(dt(1.0, 3) == T4b);
    }
}

// test x^3
unittest
{
    import std.meta : AliasSeq;
    foreach (S; AliasSeq!(float, double, real)) with(FunType)
    {
        const f0 = (S x) => x ^^ 3;
        const f1 = (S x) => 3 * x ^^ 2;
        const f2 = (S x) => 6 * x;
        enum c = 42; // c doesn't matter here
        auto dt = (S l, S r) => determineType(IntervalPoint!S(f0(l), f1(l), f2(l), l, c),
                                              IntervalPoint!S(f0(r), f1(r), f2(r), r, c));

        // concave
        assert(dt(S(-3.0), S(-1)) == T4a);
        assert(dt(-S.infinity, S(-1.0)) == T4a);

        // inflection point at x = 0, concave before
        assert(dt(S(-1.0), S(1)) == T1a);
        // convex
        assert(dt(S(1.0), S(3)) == T4b);
        assert(dt(S(1.0), S.infinity) == T4b);
    }
}

// test sin(x)
unittest
{
    import std.math: PI;
    import mir.internal.math : cos, sin;

    import std.meta : AliasSeq;
    foreach (S; AliasSeq!(float, double, real)) with(FunType)
    {
        const f0 = (S x) => sin(x);
        const f1 = (S x) => cos(x);
        const f2 = (S x) => -sin(x);
        enum c = 42; // c doesn't matter here
        auto dt = (S l, S r) => determineType(IntervalPoint!S(f0(l), f1(l), f2(l), l, c),
                                              IntervalPoint!S(f0(r), f1(r), f2(r), r, c));

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
        //assert(dt(2 * PI, 3 * PI) == T2a);
        assert(dt(1.0, 4) == T2a);

        // type 2b: convex
        assert(dt(6.0, 8) == T2b);

        // type 3a: concave
        assert(dt(3.0, 4) == T3a);
        assert(dt(2.0, 5.7) == T3a);

        // type 3b: concave
        //assert(dt(PI, 2 * PI) == T3b);
        assert(dt(-3.0, 0.1) == T3b);

        // type 4a - pure concave intervals (special case of 2a)
        assert(dt(0.0, PI - 0.01) == T4a);
        assert(dt(0.0, 3) == T4a);

        // type 4b - pure convex intervals (special case of 3b)
        //assert(dt(PI, 2 * PI - 0.01) == T4b);
        assert(dt(4.0, 6) == T4b);

        // TODO: zero seems to be a special case here
        //assert(dt(-PI, 0) == T4a); // should be convex!

        // but:
        //assert(dt(PI, 2 * PI) == T3b);

        //assert(dt(0, PI) == T4b); // should be concave (a)
        // but:
        //assert(dt(2 * PI, 3 * PI) == T2a);
    }
}

unittest
{
    import std.meta : AliasSeq;
    foreach (S; AliasSeq!(float, double, real)) with(FunType)
    {
        const f0 = (S x) => x * x;
        const f1 = (S x) => 2 * x;
        const f2 = (S x) => 2.0;
        enum c = 42; // c doesn't matter here
        auto dt = (S l, S r) => determineType(IntervalPoint!S(f0(l), f1(l), f2(l), l, c),
                                              IntervalPoint!S(f0(r), f1(r), f2(r), r, c));
        // entirely convex
        assert(dt(-1, 1) == T4b);
        assert(dt(1, 3) == T4b);
    }
}
