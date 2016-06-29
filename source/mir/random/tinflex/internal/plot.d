/**
Plotting utilities.
*/

module mir.random.tinflex.internal.plot;

import mir.random.tinflex : Tinflex;

version(tinflex_plot):

/**
Generates a series of y-values of all hat or squeeze functions of an Tinflex
object. This is useful for plotting.
Points in xs need to be in the boundaries of the Tinflex algorithm, otherwise they
will be ignored.

Params:
    t = Tinflex generator
    xs = x points to be plotted
    hat = whether hat (true) or squeeze (false) should be plotted
*/
auto plot(F0, S)(Tinflex!(F0, S) t, S[] xs, bool hat = true)
{
    import mir.random.tinflex.internal.transformations : inverse;
    import std.algorithm.comparison : clamp;

    S[] ys = new S[xs.length];
    int k = 0;
    S rMin = xs[0];
    S rMax = xs[$ - 1];

    // each interval is defined in clear bounds
    // as we iterate over the points to be plotted, we have to check to use the
    // correct hat/squeeze function for the current point
    outer: foreach (i, v; t.gvs)
    {
        // calculate bounds of the current interval
        S l = clamp(v.lx, rMin, rMax);
        // ignore unmatched points at the left
        while (xs[k] < l)
            k++;

        S r = clamp(v.rx, rMin, rMax);

        // until the right bound is reached
        while (xs[k] <= r)
        {
            // reverse our T_c transformation and calculate the value
            ys[k] = inverse((hat) ? v.hat(xs[k]) : v.squeeze(xs[k]), v.c);
            if (++k >= xs.length)
                break outer;
        }
    }
    import std.stdio;
    foreach (i; 0..xs.length)
        writeln("i: ", i, ", xs: ", xs[i], ", ys: ", ys[i]);
    return ys;
}
