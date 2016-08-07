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
auto arcmean(S)(in ref Interval!S iv)
{
    import std.math: atan, tan;

    with(iv)
    {
        if (rx < -S(1e3) || lx > S(1e3))
            return 2 / (1 / lx + 1 / rx);

        immutable d = atan(lx);
        immutable b = atan(rx);

        assert(d <= b);
        if (b - d < S(1e-6))
            return S(0.5) * lx + S(0.5) * rx;

        return tan(S(0.5) * (d + b));
    }
}

/**
Calculate the parameters for an interval.
Given an interval, determine its type (e.g. purely concave, or purely convex)
and its hat and squeeze function.
Given these functions, compute the area and overwrite the references data type.

Params:
    iv = Interval which should be calculated
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

    // calculate hat and squeeze functions
    determineSqueezeAndHat(iv);

    // update area
    hatArea!S(iv);
    squeezeArea!S(iv);

    assert(iv.hatArea.isFinite, "hat area should be lower than infinity");
    assert(iv.squeezeArea.isFinite, "squeezeArea area should be lower than infinity");
}
