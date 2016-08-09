module flex_common;

import mir.random.flex : FlexInterval;

shared static this() {
    import pyd.pyd : py_init;
    py_init();
}

/**
CFlex glues the Flex algorithm to plotting code and allows to visualize
the resulting distribution and its hat and squeeze plots.
This is only intended for testing and visualizing the Flex algorithm.
*/
struct CFlex(S)
{
    /// number of samples
    int numSamples = 5_000;

    /// root directory for all plots
    string plotDir = "plots";

    /// efficiency of the Flex algorithm
    S rho = 1.1;

    /// whether a histogram should be plotted
    bool plotHistogram = false;

    /// whether a cumulative histogram should be plotted
    bool plotCumulativeHistogram = false;

    /// step size of the points in the plot
    S stepSize = 0.005;

    /// how many bins should be used
    int numBins = 100;

    /// whether a CSV of the sampled values should be saved
    bool saveCSV = false;

    // optional suffix that should be appended to all files
    string suffixName = "";

    // @@@BUG@@@ template injection doesn't work with opCall
    /**
    Creates a Flex instance given the input parameter and plots it.
    Refer to the Flex documentation for the parameters.

    Params:
        name = name of the plot
        f0 = log-density distribution
        f1 = first derivative of f0
        f1 = first derivative of f1
        c = T_c family to use for the transformation
        cs = T_c families to use for the transformation
        points = non-overlapping partitioning with at most one inflection point per interval
        left = left plotting border
        right = right plotting border
    */
    auto plot(string name, in S function(S) f0, in S function(S) f1, in S function(S) f2,
         S c, S[] points, S left = -3, S right = 3) const
    {
        auto cs = new S[points.length - 1];
        foreach (ref d; cs)
            d = c;
        return plot(name, f0, f1, f2, cs, points, left, right);
    }

    /// ditto
    auto plot(string name, in S function(S) f0, in S function(S) f1, in S function(S) f2,
         S[] cs, S[] points, S left = -3, S right = 3) const
    {
        import mir.random.flex : flex;
        import std.algorithm.iteration : map;
        import std.format : format;
        import std.math : exp;
        import std.path : buildPath;
        import std.random : Mt19937;
        import std.file : exists, mkdir;

        if (!plotDir.exists)
            plotDir.mkdir;

        auto tf = flex(f0, f1, f2, cs, points, rho);
        auto pdf = (S x) => exp(f0(x));

        string fileName = plotDir.buildPath(name) ~ suffixName;

        // the title should contain all relevant information
        string title = name ~ ", ";
        if (tf.intervals[0].c == tf.intervals[1].c)
          title ~= "c = %g".format(tf.intervals[0].c);
        else
          title ~= "c = %(%g %)".format(tf.intervals.map!`a.c`);

        title ~= ", rho=%g, points=[%(%g, %)]".format(rho, points);

        // first plot hat/squeeze in case we crash during sampling
        tf.intervals.npPlotHatAndSqueeze(pdf, fileName ~ "_hs.pdf", title,
            stepSize, left, right);

        bool needsSamples = plotHistogram || plotCumulativeHistogram || saveCSV;

        if (needsSamples)
        {
            auto gen = Mt19937(42);
            S[] values = new S[numSamples];
            foreach (ref v; values)
                v = tf(gen);

            if (plotHistogram)
                pdf.npPlotHistogram(values, fileName ~ "_hist.pdf", title,
                                       numBins, stepSize);

            if (plotCumulativeHistogram)
                pdf.npPlotHistogram(values, fileName ~ "_hist_cum.pdf", title,
                                       numBins, stepSize, true);

            if (saveCSV)
            {
                import std.stdio : File;
                import std.algorithm : map, joiner;
                // save values to file for further processing
                auto f = File(fileName ~ "_values.csv", "w");
                f.writeln(values.map!`a.to!string`.joiner(","));
            }
        }
    }
}

/**
Plot distribution histogram

Params:
    pdf = probability density function
    values = sampled values from a distribution
    fileName = path where the file should be saved
    title = title of the plot
    numBins = number of bins
    cumulative = whether the histogram should be plotted with cumulative probabilities
*/

void npPlotHistogram(S, Pdf)(Pdf pdf, S[] values, string fileName, string title,
                             int numBins = 100, S stepSize = 0.005, bool cumulative = false)
{
    import pyd.embedded : InterpContext;
    import pyd.extra : d_to_python_numpy_ndarray;
    import std.algorithm.searching : maxPos, minPos;
    import std.algorithm.iteration : sum;
    import std.array : array;
    import std.math : isFinite;
    import std.range : front, iota;

    import std.stdio;
    writeln("starting python hist plot");

    auto pythonContext = new InterpContext();
    pythonContext.num_bins = numBins;
    pythonContext.fileName = fileName;
    pythonContext.title = title;
    pythonContext.py_stmts(`
        import matplotlib.pyplot as plt
        import numpy as np
    `);

    // double is needed for NumPy
    double[] npValues;
    // apply filtering due to weird output errors
    foreach (v; values)
    {
        if (v.isFinite)
            npValues ~= v;
    }
    pythonContext.sample = npValues.d_to_python_numpy_ndarray;
    pythonContext.cumulative = cumulative;
    pythonContext.py_stmts(`
        n, bins, patches = plt.hist(sample, num_bins, normed=1, cumulative=cumulative)
    `);

    // plot actual density function
    double[] xs = iota(values.minPos.front, values.maxPos.front, stepSize).array;
    double[] ys = new double[xs.length];
    foreach (i, x; xs)
        ys[i] = pdf(x);

    if (cumulative)
    {
        // normalize
        auto total = ys.sum();
        foreach (ref y; ys)
            y /= total;
        foreach (i, ref y; ys[1..$])
            y += ys[i];
    }

    pythonContext.xs = xs.d_to_python_numpy_ndarray;
    pythonContext.ys = ys.d_to_python_numpy_ndarray;
    pythonContext.py_stmts(`plt.plot(xs, ys, color='black')`);

    // save file
    pythonContext.py_stmts(`
        plt.title(title)
        plt.savefig(fileName, bbox_inches='tight')
        plt.close()
    `);
}

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
    pythonContext.py_stmts(`
        import matplotlib.pyplot as plt
        import numpy as np
    `);
    scope(exit) pythonContext.py_stmts(`
        plt.title(title)
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
