module flex_common.hist;

struct HistogramConfig
{
    /// title of the plot
    string title;

    /// number of bins
    int numBins = 100;

    /// step size of the points in the plot
    double stepSize = 0.005;

    /// whether the histogram should be plotted with cumulative probabilities
    bool cumulative = false;

    /// histogram type to plot ('bar', 'step', 'stepfilled')
    string histType = "bar";

    /// color of the histogram lines
    string color = "blue";

    /// whether the reference pdf should be plotted
    bool plotReference = true;
}

/**
Plot distribution histogram

Params:
    pdf = probability density function
    values = sampled values from a distribution
    fileName = path where the file should be saved
*/

void histogram(S, Pdf)(Pdf pdf, S[] values, string fileName, HistogramConfig config = HistogramConfig())
in
{
    with(config)
    assert(histType == "bar" || histType == "step" || histType == "stepfilled",
                "Invalid histogram type");
}
body
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
    pythonContext.num_bins = config.numBins;
    pythonContext.fileName = fileName;
    pythonContext.title = config.title;
    pythonContext.histType = config.histType;
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
    pythonContext.cumulative = config.cumulative;
    pythonContext.nMax = 0;
    pythonContext.color = config.color;
    pythonContext.py_stmts(`
        n, bins, patches = plt.hist(sample, num_bins, normed=1,
            cumulative=cumulative, histtype=histType, color=color)
        nMax = np.max(n)
    `);

    static if (!is(Pdf == typeof(null)))
    {
        if (config.plotReference)
        {

            // plot actual density function
            double[] xs = iota(values.minPos.front, values.maxPos.front, config.stepSize).array;
            double[] ys = new double[xs.length];
            foreach (i, x; xs)
                ys[i] = pdf(x);

            if (config.cumulative)
            {
                // normalize
                auto total = ys.sum();
                foreach (ref y; ys)
                    y /= total;
                foreach (i, ref y; ys[1..$])
                    y += ys[i];
            }
            else
            {
                // we try to scale the pdf according to highest bar of the histogram
                // this is not a 100% perfect solution
                auto nMax = pythonContext.nMax.to_d!double;
                auto factor = nMax / ys.maxPos.front;
                foreach (ref y; ys)
                    y *= factor;
            }

            pythonContext.xs = xs.d_to_python_numpy_ndarray;
            pythonContext.ys = ys.d_to_python_numpy_ndarray;
            pythonContext.py_stmts(`plt.plot(xs, ys, color='black')`);
        }
    }

    // save file
    pythonContext.py_stmts(`
        plt.title(title)
        plt.savefig(fileName, bbox_inches='tight')
        plt.close()
    `);
}

/// ditto
void histogram(S)(S[] values, string fileName, HistogramConfig config = HistogramConfig())
{
    histogram(null, values, fileName, config);
}
