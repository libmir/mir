module mir.random.tinflex.internal.linearfun;

import std.traits : isCallable;

protected:

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

    this(in S slope, in S intercept, S _y)
    {
        this.slope = slope;
        this.intercept = intercept;
        this._y = _y;
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

    /// calc a from paper
    // TODO: cache?
    @property S a() const
    {
        return slope * _y + intercept;
    }
}

/**
Creates a linear function given slope and intercept
*/
LinearFun!S linearFun(S)(in S slope, in S intercept)
{
    return LinearFun!S(slope, intercept, 0);
}

/**
Calculate the secant between two points xl and xr
*/
LinearFun!S secant(F, S)(in F f, in S xl, in S xr)
    if (isCallable!F)
{
    return secant(xl, xr, f(xl), f(xr));
}

/**
Calculate the secant between xl and xr, given their evaluated yl and yr
*/
LinearFun!S secant(S)(in S xl, in S xr, in S yl, in S yr)
{
    auto slope = (yr - yl) / (xr - xl);
    // y (aka x0) is defined to be the maximal point of the boundary
    if (yl >= yr)
        return LinearFun!S(slope, slope * (-xl) + yl, xl);
    else
        return LinearFun!S(slope, slope * (-xr) + yr, xr);
}

unittest
{
    import std.meta : AliasSeq;
    foreach (S; AliasSeq!(float, double, real))
    {
        assert(secant((S x) => x ^^ 2, S(1), S(3)) == linearFun(S(4), S(-3)));
        assert(secant((S x) => x ^^ 2, S(3), S(5)) == linearFun(S(8), S(-15)));
    }
}

/**
Calculate tangent of any point (x, y) given it's derivate f1
*/
LinearFun!S tangent(F1, S)(in F1 f1, in S x, in S y)
    if (isCallable!F1)
{
    return tangent(x, y, f1(x));
}

/**
Calculate tangent of any point (x, y) given it's calculated slope
*/
LinearFun!S tangent(S)(in S x, in S y, in S slope)
{
    return LinearFun!S(slope, slope * (-x) + y, x);
}

unittest
{
    import std.meta : AliasSeq;
    foreach (S; AliasSeq!(float, double, real))
    {
        assert(tangent((S x) => 2 * x, S(1), S(1)) == linearFun(S(2), S(-1)));
        assert(tangent((S x) => 2 * x, S(0), S(0)) == linearFun(S(0), S(0)));
    }
}

unittest
{
    import mir.internal.math : cos;
    import std.math : PI, approxEqual;
    import std.meta : AliasSeq;
    foreach (S; AliasSeq!(float, double, real))
    {
        assert(tangent((S x) => cos(x), S(0.0), S(0)) == linearFun!S(S(1.0), S(0)));

        auto t = tangent((S x) => cos(x), S(PI / 2), S(1));
        assert(t.slope.approxEqual(0));
        assert(t.intercept.approxEqual(1));
    }
}
