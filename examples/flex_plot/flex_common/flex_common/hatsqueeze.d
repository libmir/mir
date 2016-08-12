module flex_common.hatsqueeze;

import mir.random.flex : FlexInterval;


/**
Plots every interval as a separate line with a given stepsize.

Params:
    intervals = Calculated Flex intervals
    isHat = whether hat or squeeze should be plotted
    stepSize = step size of the points in the plot
    isTransformed = whether the transformed distribution should be plotted
    left = left plotting border
    right = right plotting border
*/
private auto plotWithIntervals(S)(const(FlexInterval!S)[] intervals, bool isHat = true,
                          S stepSize = 0.01, bool isTransformed = false, S leftStart = -3,
                          S rightStart = 3)
in
{
    assert(intervals[0].lx <= leftStart);
    assert(rightStart <= intervals[$ - 1].rx);
}
body
{
    static struct PlotRange
    {
        const(FlexInterval!S)[] r;
        bool isHat;
        S stepSize;
        bool isTransformed;
        S leftStart;
        S rightStart;

        bool empty()
        {
            return r.length == 0;
        }

        auto front()
        {
            import mir.random.flex : flexInverse;
            import std.algorithm.comparison : max, min;
            import std.math : ceil;
            import std.typecons : tuple;

            FlexInterval!S iv = r[0];

            S right = min(iv.rx, rightStart);

            // we increment from the left to the right
            S x = max(iv.lx, leftStart);
            size_t nrIntervals = right < x ? 0 : cast(size_t) ((right - x) / stepSize).ceil;
            nrIntervals = max(2, nrIntervals);

            auto xs = new S[nrIntervals];
            auto ys = new S[nrIntervals];

            auto fun = (S x)
            {
                S val = (isHat) ? iv.hat(x) : iv.squeeze(x);
                if (!isTransformed)
                    val = (val * iv.c >= 0) ? flexInverse(val, iv.c) : 0;
                return val;
            };

            for (auto k = 0; k < nrIntervals; k++, x += stepSize)
            {
                xs[k] = x;
                ys[k] = fun(x);
            }

            // plot last value if not reached
            if (x < iv.rx || nrIntervals == 1)
            {
                xs[$ - 1] = right;
                ys[$ - 1] = fun(right);
            }

            return tuple!("xs", "ys")(xs, ys);
        }

        void popFront()
        {
            assert(r.length > 0, "range can't be empty");
            r = r[1..$];
        }
    }
    return PlotRange(intervals, isHat, stepSize, isTransformed, leftStart, rightStart);
}

/**
Plot PDF with hat and squeeze segments

Params:
    intervals = Calculated Flex intervals
    pdf = probability density function
    fileName = file path to which the plot should be saved
    title =  name of the plot
    stepSize = step size of the points in the plot
    left = left plotting border
    right = right plotting border
*/
auto npPlotHatAndSqueeze(S, Pdf)(in FlexInterval!S[] intervals, Pdf pdf,
                                 string fileName, string title, S stepSize = 0.01,
                                 S left = -3, S right = 3)
{
    import std.algorithm.comparison : max, min;
    import std.array : array;
    import std.range : iota;
    import pyd.embedded : InterpContext;
    import pyd.extra : d_to_python_numpy_ndarray;

    auto pythonContext = new InterpContext();
    alias T = double; // NumPy only uses double

    S l = max(left, intervals[0].lx);
    S r = min(right, intervals[$ - 1].rx);

    pythonContext.fileName = fileName;
    pythonContext.title = title;
    pythonContext.xmin = left;
    pythonContext.xmax = right;
    pythonContext.py_stmts(`
        import matplotlib.pyplot as plt
        import numpy as np
    `);
    scope(exit) pythonContext.py_stmts(`
        plt.title(title)
        plt.xlim(xmin, xmax)
        plt.savefig(fileName, bbox_inches='tight', format="pdf")
        plt.close()
    `);

    // PDF
    T[] xs = iota!(T, T, T)(l, r + stepSize, stepSize).array;
    T[] ys = new T[xs.length];
    foreach (i, ref y; ys)
        y = pdf(xs[i]);

    pythonContext.xs = xs.d_to_python_numpy_ndarray;
    pythonContext.ys = ys.d_to_python_numpy_ndarray;
    pythonContext.py_stmts(`plt.plot(xs, ys, color='black')`);

    // Hat & Squeeze
    import std.meta : AliasSeq;
    import std.typecons : Tuple;
    alias fnType = Tuple!(bool, "type", string, "color");
    foreach (fn; AliasSeq!(fnType(true, "red"), fnType(false, "green")))
        foreach (hatXs, hatYs; plotWithIntervals(intervals, fn.type, stepSize, false, l, r))
        {
            pythonContext.xs = hatXs.d_to_python_numpy_ndarray;
            pythonContext.ys = hatYs.d_to_python_numpy_ndarray;
            pythonContext.fn_color = fn.color;
            pythonContext.py_stmts(`plt.plot(xs, ys, color=fn_color)`);
        }
}
