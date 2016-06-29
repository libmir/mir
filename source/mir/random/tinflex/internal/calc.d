module mir.random.tinflex.internal.calc;

import mir.random.tinflex.internal.types : Interval;

/**
Splits an interval into two points.

Params:
    l = Left starting point of the interval
    r = Right ending point of the interval
Returns:
    Splitting point within the interval
*/
auto arcmean(S, bool sorted = false)(const S x, const S y)
{
    import std.math: atan, tan;

    S l = x;
    S r = y;
    static if (!sorted)
    {
        if (r < l)
        {
            S t = r;
            r = l;
            l = t;
        }
    }

    if (r < -S(1e3) || l > S(1e3))
        return  S(0.5) * (1 / l + 1 / r);

    immutable d = atan(l);
    immutable b = atan(r);

    if (b - d < S(1e-6))
        return S(0.5) * l + S(0.5) * r;

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
