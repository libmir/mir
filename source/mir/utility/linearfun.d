module mir.utility.linearfun;

import std.traits : isCallable;

/**
Representation of linear function of the form:

    y = slope * x + intercept

_IMPORTANT_: we can't store the intercept directly as it will lead to
numerical errors if x and y are similar or equal.
Hence the representation of a function from the Tinflex paper is used:

    y = slope * (x - y) + a

For a detailed explanation, see https://github.com/libmir/mir/wiki/Numerical-failures
*/
struct LinearFun(S)
{
    /// direction and steepness
    S slope; // aka beta

    ///
    S y;

    ///
    S a;

    ///
    this(S slope, S y, S a)
    {
        this.slope = slope;
        this.y = y;
        this.a = a;
    }

    /// textual representation of the function
    string toString() const
    {
        import std.format: format;
        import std.math: abs, isNaN;
        char sgn = intercept > 0 ? '+' : '-';
        if (slope.isNaN)
            return "#NaN#";
        else
            return format("%.2fx %c %.2f", slope, sgn, abs(intercept));
    }

    /// call the linear function with x
    S opCall(in S x) const
    {
        return a + slope * (x - y);
    }

    // calculate intercept (for debugging)
    S intercept() @property const
    {
        return slope * -y + a;
    }
}

///
LinearFun!S linearFun(S)(S slope, S y, S a)
{
    return LinearFun!S(slope, y, a);
}

unittest
{
    import std.meta : AliasSeq;
    foreach (S; AliasSeq!(float, double, real))
    {
        auto f1 = (S x) => 2 * x;

        auto t1 = linearFun!S(f1(1), 1, 1);
        assert(t1.slope == 2);
        assert(t1.intercept == -1);

        auto t2 = linearFun!S(f1(0), 0, 0);
        assert(t2.slope == 0);
        assert(t2.intercept == 0);
    }
}

unittest
{
    import mir.internal.math : cos;
    import std.math : PI, approxEqual;
    import std.meta : AliasSeq;
    foreach (S; AliasSeq!(float, double, real))
    {
        auto f = (S x) => cos(x);
        auto buildTan = (S x, S y) => linearFun(f(x), x, y);
        auto t1 = buildTan(0, 0);
        assert(t1.slope == 1);
        assert(t1.intercept == 0);

        auto t2 = buildTan(PI / 2, 1);
        assert(t2.slope.approxEqual(0));
        assert(t2.intercept.approxEqual(1));
    }
}
