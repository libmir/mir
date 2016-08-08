/**
Utilities for linear functions.

Authors: Sebastian Wilzbach, Ilya Yaroshenko

License: $(LINK2 http://boost.org/LICENSE_1_0.txt, Boost License 1.0).
*/
module mir.utility.linearfun;

import std.traits : isCallable;

/**
Representation of linear function of the form:

    y = slope * (x - y) + a

This representation allows a bit higher precision than the
typical representation `y = slope * x + a`.
*/
struct LinearFun(S)
{
    import std.format : FormatSpec;

    /// direction and steepness (aka beta)
    S slope;

    /// boundary point where f obtains it's maximum
    S y;

    /// constant intercept
    S a;

    /**
    Params:
        slope = direction and steepness
        y = boundary point, often f(x)
        a = constant intercept
    */
    this(S slope, S y, S a)
    {
        this.slope = slope;
        this.y = y;
        this.a = a;
    }

    /// textual representation of the function
    void toString(scope void delegate(const(char)[]) sink,
                  FormatSpec!char fmt) const
    {
        import std.range : put;
        import std.format: formatValue, singleSpec;
        switch(fmt.spec)
        {
            case 'l':
                import std.math: abs, approxEqual, isNaN;
                if (slope.isNaN)
                    sink.put("#NaN#");
                else
                {
                    auto spec2g = singleSpec("%.2g");
                    if (!slope.approxEqual(0))
                    {
                        sink.formatValue(slope, spec2g);
                        sink.put("x");
                        if (!intercept.approxEqual(0))
                        {
                            sink.put(" ");
                            char sgn = intercept > 0 ? '+' : '-';
                            sink.put(sgn);
                            sink.put(" ");
                            sink.formatValue(abs(intercept), spec2g);
                        }
                    }
                    else
                    {
                        sink.formatValue(intercept, spec2g);
                    }
            }
                break;
            case 's':
            default:
                import std.traits : Unqual;
                sink.put(Unqual!(typeof(this)).stringof);
                auto spec2g = singleSpec("%.6g");
                sink.put("(");
                sink.formatValue(slope, spec2g);
                sink.put(", ");
                sink.formatValue(y, spec2g);
                sink.put(", ");
                sink.formatValue(a, spec2g);
                sink.put(")");
                break;
        }
    }

    /// call the linear function with x
    S opCall(in S x) const
    {
        S val = slope * (x - y);
        val += a;
        return val;
    }

    /// calculate inverse of x
    S inverse(S x) const
    {
        return y + (x - a) / slope;
    }

    // calculate intercept (for debugging)
    S intercept() @property const
    {
        return slope * -y + a;
    }

    ///
    version(Flex_logging) string logHex()
    {
        import std.format : format;
        return "LinearFun!%s(%a, %a, %a)".format(S.stringof, slope, y, a);
    }
}

/**
Constructs a linear function of the form `y = slope * (x - y) + a`.

Params:
    slope = direction and steepness
    y = boundary point, often f(x)
    a = constant intercept
Returns:
    A linear function constructed with the given parameters.
*/
LinearFun!S linearFun(S)(S slope, S y, S a)
{
    return LinearFun!S(slope, y, a);
}

/// tangent of a point
unittest
{
    import std.format : format;
    auto f = (double x) => x * x + 1;
    auto df = (double x) => 2 * x;
    auto buildTan = (double x) => linearFun(df(x), x, f(x));

    auto t0 = buildTan(0);
    assert("%l".format(t0)== "1");
    assert(t0(0) == 1);
    assert(t0(42) == 1);

    auto t1 = buildTan(1);
    assert("%l".format(t1) == "2x");
    assert(t1(1) == 2);
    assert(t1(2) == 4);

    auto t2 = buildTan(2);
    assert("%l".format(t2) == "4x - 3");
    assert(t2(1) == 1);
    assert(t2(2) == 5);
}

/// secant of two points
unittest
{
    import std.format : format;
    auto f = (double x) => x * x + 1;
    auto lx = 1, rx = 3;
    // compute the slope between lx and rx
    auto lf = linearFun((f(rx) - f(lx)) / (rx - lx), lx, f(lx));

    assert("%l".format(lf) == "4x - 2");
    assert(lf(1) == 2); // f(1)
    assert(lf(3) == 10); // f(3)
}

/// construct an arbitrary linear function
unittest
{
    import std.format : format;

    // 2 * x + 1
    auto t = linearFun!double(2, 0, 1);
    assert("%l".format(t) == "2x + 1");
    assert(t(1) == 3);
    assert(t(-2) == -3);
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

// test default toString
unittest
{
    import std.format : format;
    auto t = linearFun!double(2, 0, 1);
    assert("%s".format(t) == "LinearFun!double(2, 0, 1)");
}

// test NaN behavior
unittest
{
    import std.format : format;
    auto t = linearFun!double(double.nan, 0, 1);
    assert("%s".format(t) == "LinearFun!double(nan, 0, 1)");
    assert("%l".format(t) == "#NaN#");
}
