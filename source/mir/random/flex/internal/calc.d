module mir.random.flex.internal.calc;

import mir.random.flex.internal.types : Interval;

/**
Calculate the mean between two points using the arcmean:

    tan(0.5 * (atan(l) + atan(r))

In contrast to the normal mean (`0.5 * (l + r)`) being a geometric plane,
the arcmean favors the mean region more.

Params:
    l = Left point
    r = Right point

Returns:
    Splitting point within the interval

See_Also:
    $(LINK2 http://www.wolframalpha.com/input/?i=tan(0.5+*+(ArcTan%5Bx%5D+%2B+ArcTan%5By%5D)),
    WolframAlpha visualization of the arc-mean)

References:
    Hormann, W., J. Leydold, and G. Derflinger.
    "Automatic Nonuniform Random Number Generation." (2004): Formula 4.23
*/
auto arcmean(S, bool sorted = false)(const S l, const S r)
{
    import std.math: atan, tan;

    S x = l;
    S y = r;
    static if (!sorted)
    {
        if (y < x)
        {
            S t = x;
            x = y;
            y = t;
        }
    }

    if (y < -S(1e3) || x > S(1e3))
        return 2 / (1 / x + 1 / y);

    immutable d = atan(x);
    immutable b = atan(y);

    assert(d <= b);
    if (b - d < S(1e-6))
        return S(0.5) * x + S(0.5) * y;

    return tan(S(0.5) * (d + b));
}

/**
Calculate the exponential mean between an Interval `iv`.

 \int_l^r x * (h(x) - s(x)) dx
 -----------------------------
 \int^l^r      h(x) - s(x)  dx

It can't be applied for unbounded intervals if c <= -1/2

References:
    Hormann, W., J. Leydold, and G. Derflinger.
    "Automatic Nonuniform Random Number Generation." (2004): Formula 4.22
*/
auto expmean(S)(in ref Interval!S iv)
out (result)
{
    assert(iv.lx <= result && result <= iv.rx);
}
body
{
    import mir.internal.math : pow;
    enum one_div_3 = 1 / S(3);
    auto f_upper = (S x) => S(0.5) * x * x * (iv.hat.a - iv.squeeze.a
                                              - iv.hat.slope * iv.hat.y
                                              - iv.squeeze.slope * iv.squeeze.y)
                            + one_div_3 * (iv.hat.slope + iv.squeeze.slope) * pow(x, 3);

    auto f_lower = (S x) => iv.hat.a * x - iv.squeeze.a * x
                            + (iv.hat.slope *  x * x) * S(0.5)
                            + (iv.squeeze.slope *  x * x) * S(0.5)
                            - iv.hat.slope *  x * iv.hat.y
                            - iv.squeeze.slope * x * iv.squeeze.y;

    auto upper = f_upper(iv.rx) - f_upper(iv.lx);
    auto lower = f_lower(iv.rx) - f_lower(iv.lx);

    auto res = upper / lower;
    return res;
}

unittest
{
    import mir.utility.linearfun : LinearFun;
    import std.math : approxEqual;
    import std.meta : AliasSeq;
    foreach (S; AliasSeq!(float, double, real))
    {
        alias LF = LinearFun!S;
        auto iv = Interval!S(-3, -1.36003, 1.5, 0, 0, 0, 0, 0, 0);
        iv.hat = LF(0.159263, -1.36003, 1.26786),
        iv.squeeze = LF(0.0200763, -3, 1.00667),
        assert(expmean(iv).approxEqual(-1.90669));
    }
}

/**
Calculate the parameters for an interval.
Given an interval, determine it's type and hat and squeeze function.
Given these functions, compute the area and overwrite the references data type

Params:
    iv = Interval
*/
void calcInterval(S)(ref Interval!S iv)
in
{
    assert(iv.lx < iv.rx, "invalid interval");
}
body
{
    import mir.random.flex.internal.types : determineType;
    import mir.random.flex.internal.area: determineSqueezeAndHat, hatArea, squeezeArea;
    import std.math: isFinite;

    // TODO: this is probably not needed anymore
    if (iv.lx == iv.rx)
    {
        iv.hatArea = 0;
        iv.squeezeArea = 0;
    }
    else
    {
        // calculate hat and squeeze functions
        determineSqueezeAndHat(iv);

        // update area
        hatArea!S(iv);
        squeezeArea!S(iv);

        assert(iv.hatArea.isFinite, "hat area should be lower than infinity");
        assert(iv.squeezeArea.isFinite, "squeezeArea area should be lower than infinity");
    }
}
