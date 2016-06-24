/**
Plotting utilities.
*/

module mir.random.tinflex.internal.plot;

import mir.random.tinflex : Tinflex;

version(tinflex_plot):

/**
Generates a series of y-values that can be used for plotting.

Params:
    t = Tinflex generator
    xs = x points to be plotted
    hat = whether hat (true) or squeeze (false) should be plotted
*/
auto plot(F0, S)(Tinflex!(F0, S) t, S[] xs, bool hat = true)
{
    import std.algorithm.comparison : clamp;
    S[] ys = new S[xs.length];
    int k = 0;
    S rMin = xs[0];
    S rMax = xs[$ - 1];
    outer: foreach (i, v; t.ips)
    {
        S l = clamp(v.x, rMin, rMax);
        S r;
        if (i < t.ips.length - 1)
        {
            r = clamp(t.ips[i + 1].x, rMin, rMax);
        }
        else
        {
            r = rMax;
        }
        while (xs[k] < r)
        {
            if (hat)
                ys[k] = v.hat(xs[k]);
            else
                ys[k] = v.squeeze(xs[k]);

            import mir.random.tinflex.internal.transformations : inverse;
            ys[k] = inverse(ys[k], v.c);
            k++;
            if (k >= ys.length)
                break outer;
        }
    }
    return ys;
}
