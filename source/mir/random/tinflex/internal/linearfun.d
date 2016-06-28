module mir.random.tinflex.internal.linearfun;

import std.traits : isCallable;

/**
Representation of linear function of the form:
    y = slope * x + intercept
*/
struct LinearFun(S)
{
    /// direction and steepness
    S slope; // aka beta

    /// x-intercept
    S intercept; // aka alpha

    this(in S slope, in S intercept, S _y, S _a)
    {
        this.slope = slope;
        this.intercept = intercept;
        this._y = _y;
        this._a = _a;
    }

    /// textual representation of the function
    string toString() const
    {
        import std.format: format;
        import std.math: abs, isNaN;
        char sgn = intercept > 0 ? '+' : '-';
        if (slope.isNaN)
            return "empty#";
        else
            return format("%.2fx %c %.2f", slope, sgn, abs(intercept));
    }

    /// call the linear function with x
    S opCall(in S x) const
    {
        return slope * x + intercept;
    }

    // TODO: only internally - remove me
    // definition of function was different in paper: y = a + b * (x -y)
    S _y;

    bool opEquals()(auto ref const LinearFun!S fun) const
    {
        return slope == fun.slope && intercept == fun.intercept;
    }

    // different definition in paper
    // slope * _y + intercept;
    S _a;

    S a() @property const
    {
        return _a;
    }
}

/**
Creates a linear function given slope and intercept
*/
LinearFun!S linearFun(S)(in S slope, in S intercept)
{
    return LinearFun!S(slope, intercept, 0, 0);
}

/**
Calculate the secant between xl and xr, given their evaluated yl and yr
*/
LinearFun!S secant(S)(in S xl, in S xr, in S yl, in S yr)
{
    auto slope = (yr - yl) / (xr - xl);
    // y (aka x0) is defined to be the maximal point of the boundary
    if (yl >= yr)
        return LinearFun!S(slope, slope * (-xl) + yl, xl, yl);
    else
        return LinearFun!S(slope, slope * (-xr) + yr, xr, yr);
}

unittest
{
    import std.meta : AliasSeq;
    foreach (S; AliasSeq!(float, double, real))
    {
        auto f = (S x) => x ^^ 2;
        auto secant = (S l, S r) => secant!S(l, r, f(l), f(r));
        assert(secant(1, 3) == linearFun(S(4), S(-3)));
        assert(secant(3, 5) == linearFun(S(8), S(-15)));
    }
}

/**
Calculate tangent of any point (x, y) given it's calculated slope
*/
LinearFun!S tangent(S)(in S x, in S y, in S slope)
{
    return LinearFun!S(slope, slope * (-x) + y, x, y);
}

unittest
{
    import std.meta : AliasSeq;
    foreach (S; AliasSeq!(float, double, real))
    {
        auto f1 = (S x) => 2 * x;
        assert(tangent!S(1, 1, f1(1)) == linearFun(S(2), S(-1)));
        assert(tangent!S(0, 0, f1(0)) == linearFun(S(0), S(0)));
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
        auto buildTan = (S x, S y) => tangent(x, y, f(x));
        assert(buildTan(0, 0) == linearFun!S(S(1.0), S(0)));

        auto t = buildTan(PI / 2, 1);
        assert(t.slope.approxEqual(0));
        assert(t.intercept.approxEqual(1));
    }
}
