module mir.random.tinflex.internal.calc;

import mir.random.tinflex.internal.types : Interval;

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
*/
auto arcmean(S, bool sorted = false)(const S l, const S r)
{
    import std.math: atan, tan;

    S _l = l;
    S _r = r;
    static if (!sorted)
    {
        if (_r < _l)
        {
            S t = _r;
            _r = _l;
            _l = t;
        }
    }

    if (_r < -S(1e3) || _l > S(1e3))
        return  S(0.5) * (1 / _l + 1 / r);

    immutable d = atan(_l);
    immutable b = atan(_r);

    if (b - d < S(1e-6))
        return S(0.5) * _l + S(0.5) * r;

    return tan(S(0.5) * (d + b));
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
    import mir.random.tinflex.internal.types : determineType;
    import mir.random.tinflex.internal.area: determineSqueezeAndHat, hatArea, squeezeArea;
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
