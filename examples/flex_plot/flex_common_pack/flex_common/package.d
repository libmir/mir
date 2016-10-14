module flex_common;

shared static this() {
    import pyd.pyd : py_init;
    py_init();
}

public import flex_common.hist;

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

    /// whether the reference PDF should be plotted
    bool plotReference = true;

    // which histogram type should be used
    string histType = "step";

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

        import flex_common.hist;
        import flex_common.hatsqueeze;

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

            if (plotHistogram || plotCumulativeHistogram)
            {
                HistogramConfig hc;
                hc.title = title;
                hc.numBins = numBins;
                hc.stepSize = stepSize;
                hc.plotReference = plotReference;
                hc.histType = histType;

                if (plotHistogram)
                    pdf.histogram(values, fileName ~ "_hist.pdf", hc);

                if (plotCumulativeHistogram)
                {
                    hc.cumulative = true;
                    pdf.histogram(values, fileName ~ "_hist_cum.pdf", hc);
                }
            }

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
