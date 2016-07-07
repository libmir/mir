/**
Simple plot
*/
import mir.random.flex: FlexInterval;
import std.array : array;
import std.stdio : writeln, writefln, File;
import std.algorithm : map, joiner, sum;
import std.range : iota, repeat, take;
import std.path : buildPath;
import std.conv: to;
import std.math : exp;

import pyd.pyd;
import pyd.embedded;
import pyd.extra;

alias toNumpyArray = d_to_python_numpy_ndarray;

shared static this() {
    //initializes PyD package.
    py_init();
}

// plot histogram with matplotlib
void npPlotHistogram(S)(S[] values, string fileName, string title)
{
    import std.math : isNaN;
    static immutable script = `
        import matplotlib.pyplot as plt
        n, bins, patches = plt.hist(sample, num_bins, normed=1)
        plt.title(title)
        plt.savefig(fileName, bbox_inches='tight')
        plt.close()
    `;

    auto pythonContext = new InterpContext();
    // double is needed for NumPy
    double[] npValues;
    // apply filtering due to weird output errors
    foreach (v; values)
    {
        if (!v.isNaN)
            npValues ~= v;
    }
    pythonContext.sample = npValues.toNumpyArray;
    pythonContext.num_bins = 50;
    pythonContext.fileName = fileName;
    pythonContext.title = title;
    pythonContext.py_stmts(script);
}

/**
Plots every interval as a separate line with a given stepsize.
*/
auto plotWithIntervals(S)(in FlexInterval!S[] intervals, bool isHat = true,
                          S stepSize = 0.01, bool isTransformed = false, S leftStart = -3,
                          S rightStart = 3)
in
{
    assert(intervals[0].lx <= leftStart);
    assert(rightStart <= intervals[$ - 1].rx);
}
body
{
    import mir.random.flex : flexInverse;
    import std.algorithm.comparison : max, min;
    import std.math : ceil;

    auto len = intervals.length;

    // TODO: do something smart to avoid many allocations here
    S[][] xs = new S[][len];
    S[][] ys = new S[][xs.length];

    foreach (i, iv; intervals)
    {
        S x = max(iv.lx, leftStart);
        S right = min(iv.rx, rightStart);
        size_t nrIntervals = right < x ? 0 : cast(size_t) ((right - x) / stepSize).ceil;
        nrIntervals = max(2, nrIntervals);
        xs[i] = new S[nrIntervals];
        ys[i] = new S[nrIntervals];

        foreach (k; 0..nrIntervals)
        {
            xs[i][k] = x;
            ys[i][k] = (isHat) ? iv.hat(x) : iv.squeeze(x);
            if (!isTransformed)
                ys[i][k] = (ys[i][k] * iv.c >= 0) ? flexInverse(ys[i][k], iv.c) : 0;

            x += stepSize;
        }
        if (x < iv.rx || nrIntervals == 1)
        {
            // plot last value too
            S r = min(iv.rx, right);
            xs[i][$ - 1] = r;
            ys[i][$ - 1] = (isHat) ? iv.hat(r) : iv.squeeze(r);
            if (!isTransformed)
                ys[i][$ - 1] = (ys[i][$ - 1] * iv.c >= 0) ? flexInverse(ys[i][$ - 1], iv.c) : 0;
        }
    }
    import std.typecons : tuple;
    return tuple!("xs", "ys")(xs, ys);
}

auto npPlotHatAndSqueeze(S, Pdf)(in FlexInterval!S[] intervals, Pdf pdf,
                                 string fileName, string title, S stepSize = 0.01,
                                 S left = -3, S right = 3)
{
    import std.algorithm.comparison : max, min;
    import std.array : array;

    static immutable script = `
        import matplotlib.pyplot as plt
        import numpy as np
        plt.plot(xs, ys, color='black')
        for i, h in enumerate(hats[0: len(hats) - 1]):
            if not np.isnan(h).any():
                plt.plot(xsHS[i], h, color='red')
        for i, s in enumerate(squeezes):
            plt.plot(xsHS[i], s, color='green')
        plt.title(title)
        plt.savefig(fileName, bbox_inches='tight', format="pdf")
        plt.close()
    `;

    auto pythonContext = new InterpContext();
    alias T = double;

    S l = max(left, intervals[0].lx);
    S r = min(right, intervals[$ - 1].rx);

    // PDF
    T[] xs = iota!(T, T, T)(l, r + stepSize, stepSize).array;
    T[] ys = new T[xs.length];
    foreach (i, ref y; ys)
        y = pdf(xs[i]);

    pythonContext.xs = xs.toNumpyArray;
    pythonContext.ys = ys.toNumpyArray;

    auto hats = plotWithIntervals(intervals, true, stepSize, false, l, r);
    // TODO: this allocates the xs array twice
    auto squeezes = plotWithIntervals(intervals, false, stepSize, false, l, r);

    // TODO: do something smart to convert hat.xs to list of numpy arrays
    pythonContext.xsHS = hats.xs.d_to_python;
    pythonContext.hats = hats.ys.d_to_python;
    pythonContext.squeezes = squeezes.ys.d_to_python;

    pythonContext.fileName = fileName;
    pythonContext.title = title;
    pythonContext.py_stmts(script);
}

/// Plotting helper
struct CFlex(S)
{
    int n;
    string plotDir;
    S rho;
    bool plotHistogram;
    S stepSize = 0.005;

    /// @@@BUG@@@ template injection doesn't work with opCall
    auto plot(string name, in S function(S) f0, in S function(S) f1, in S function(S) f2,
         S c, S[] points, S left = -3, S right = 3) const
    {
        auto cs = new S[points.length - 1];
        foreach (ref d; cs)
            d = c;
        return plot(name, f0, f1, f2, cs, points, left, right);
    }

    auto plot(string name, in S function(S) f0, in S function(S) f1, in S function(S) f2,
         S[] cs, S[] points, S left = -3, S right = 3) const
    {
        import mir.random.flex : flex;
        import std.format : format;
        import std.math : exp;
        import std.random : Mt19937;

        auto tf = flex(f0, f1, f2, cs, points, rho);
        auto pdf = (S x) => exp(f0(x));

        string fileName = plotDir.buildPath(name);
        string title = "%s, c=%g, rho=%g".format(name, tf.intervals[0].c, rho);

        // first plot hat/squeeze in case we crash during sampling
        tf.intervals.npPlotHatAndSqueeze(pdf, fileName ~ "_hs.pdf", title,
            stepSize, left, right);

        if (plotHistogram)
        {
            auto gen = Mt19937(42);
            S[] values = new S[n];
            foreach (ref v; values)
                v = tf(gen);

            values.npPlotHistogram(fileName ~ "_hist.pdf", title);
        }

        // save values to file for further processing
        //auto f = File(fileName ~ "_values.csv", "w");
        //f.writeln(values.map!`a.to!string`.joiner(","));
        return true;
    }
}

// default flex testing distribution
void test1(S, F)(in ref F test)
{
    import std.math : pow;
    auto f0 = (S x) => -pow(x, 4) + 5 * x * x - 4;
    auto f1 = (S x) => 10 * x - 4 * pow(x, 3);
    auto f2 = (S x) => 10 - 12 * x * x;

    foreach (c; [0.1, 0.5, 1])
    {
        test.plot("dist1_a" ~ c.to!string, f0, f1, f2, c, [-3.0, -1.5, 0.0, 1.5, 3]);
    }

    foreach (c; [-0.9, -0.5, -0.2, 0])
    {
        test.plot("dist1_b" ~ c.to!string, f0, f1, f2, c,
            [-S.infinity, -2.1, -1.05, 0.1, 1.2, 2, S.infinity]);
        test.plot("dist1_c" ~ c.to!string, f0, f1, f2, c, [-S.infinity, -1, 0, 1, S.infinity]);
        test.plot("dist1_d" ~ c.to!string, f0, f1, f2, c, [-2, 0, 1.5], -4, 6);
    }

    foreach (c; [-2, -1.5, -1])
    {
        test.plot("dist1_e" ~ c.to!string, f0, f1, f2, c, [-3.0, -2.1, -1.05, 0.1, 1.2, 3]);
    }
}

// test at and near extrema
void test2(S, F)(in ref F test)
{
    import std.math : pow;
    auto f0 = (S x) => -2 *  pow(x, 4) + 4 * x * x;
    auto f1 = (S x) => -8 *  pow(x, 3) + 8 * x;
    auto f2 = (S x) => -24 * x * x + 8;

    foreach (c; [-2, -1.1, -1, 0.5, 1, 1.5, 2])
    {
        test.plot("dist2_c_" ~ c.to!string, f0, f1, f2, c, [-3, -1, 0, 1, 3]);
        test.plot("dist2_d_" ~ c.to!string, f0, f1, f2, c,
            [-3, -1 + (cast(S) 2) ^^-52, 1e-20, 1 - (cast(S) 2)^^(-53), 3]);
    }

    foreach (c; [-0.9, -0.5, -0.2, 0])
    {
        test.plot("dist2_a" ~ c.to!string, f0, f1, f2, c,
            [-S.infinity, -2, -1, 0, 1, 2, S.infinity]);
        test.plot("dist2_" ~ c.to!string, f0, f1, f2, c,
            [-S.infinity, -2, -1 + (cast(S)2)^^-52, 1e-20, 1-(cast(S)2)^^(-53), 2, S.infinity]);
    }
}

// density vanishes at boundaries
void test3(S, F)(in ref F test)
{
    import std.math : log, pow;
    auto f0 = (S x) => cast(S) log(1 - pow(x, 4));
    auto f1 = (S x) => -4 * pow(x, 3) / (1 - pow(x, 4));
    auto f2 = (S x) => -(4 * pow(x, 6) + 12 * x * x) / (pow(x, 8) - 2 * pow(x, 4) + 1);

    foreach (c; [1.5, 2])
        test.plot("dist3_a_" ~ c.to!string, f0, f1, f2, c, [-1, -0.9, -0.5, 0.5, 0.9, 1], -1, 1);

    foreach (c; [-2, -1.5, -1, -0.9,  -0.5, -0.2, 0, 0.1, 0.5, 1])
        test.plot("dist3_b_" ~ c.to!string, f0, f1, f2, c, [-1, -0.5, 0.5, 1]);
}

// density with pole
void test4(S, F)(in ref F test)
{
    import std.math : abs, log;
    auto f0 = (S x) => - cast(S) log(abs(x)) * S(0.5);
    auto f1 = (S x) => -1 / (2 * x);
    auto f2 = (S x) => S(0.5) / (x * x);

    test.plot("dist4", f0, f1, f2, -1.5, [-1.0, 0, 1]);
}

// different values for c
void test5(S, F)(in ref F test)
{
    import std.math : pow;
    auto f0 = (S x) => -2 * pow(x, 4)  + 4 * x * x;
    auto f1 = (S x) => -8 * pow(x, 3) + 8 * x;
    auto f2 = (S x) => -24 * x * x + 8;

    test.plot("dist5_a", f0, f1, f2, [-0.5, 2, -2, 0.5, -1, 0],
        [-S.infinity, -2, -1, 0, 1, 2, S.infinity]);

    test.plot("dist5_b", f0, f1, f2, [-0.5, 2, -2, 0.5, -1, 0], [-3, -2, -1, 0, 1, 2, 3]);
}

// inflection point at boundary
void test6(S, F)(in ref F test)
{
    import std.math : pow;
    auto f0 = (S x) => -pow(x, 4) + 6 * x * x;
    auto f1 = (S x) => 12 * x - 4 * pow(x, 3);
    auto f2 = (S x) => 12 - 12 * x * x;

    test.plot("dist6", f0, f1, f2, 0, [-S.infinity, -2, -1, 0, 1, 2, S.infinity], -5, 5);
}


// https://en.wikipedia.org/wiki/Normal_distribution
void test_normal(S, F)(in ref F test)
{
    import std.math : exp, log, PI, sqrt;
    //S[] points = [-S.infinity, -1.5, 0, 1.5, S.infinity];
    S[] points = [-3, -1.5, 0, 1.5, 3];
    enum S sqrt2PI = sqrt(2 * PI);
    //auto f0 = (S x) => 1 / (exp(x * x / 2) * sqrt2PI);
    //auto f1 = (S x) => -(x/(exp(x * x/2) * sqrt2PI));
    //auto f2 = (S x) => (-1 + x * x) / (exp(x * x/2) * sqrt2PI);
    auto f0 = (S x) => cast(S) log(1 / (exp(x * x / 2) * sqrt2PI));
    auto f1 = (S x) => -x;
    auto f2 = (S x) => S(-1);
    test.plot("dist_normal", f0, f1, f2, 1.5, points);
}

// a=2, b=5
// https://en.wikipedia.org/wiki/Beta_distribution
void test_beta(S, F)(in ref F test)
{
    import std.math : log, pow;
    auto f0 = (S x) => cast(S) log(30 * (1 - x).pow(x));
    auto f1 = (S x) => (1 - 5 * x)/(x - x * x);
    auto f2 = (S x) => (-1 + 2 * x - 5 * x * x) / (pow(-1 + x, 2) * x * x);
    S[] points = [0,  1];
    test.plot("dist_beta", f0, f1, f2, 1.5, points);
}

// https://en.wikipedia.org/wiki/Arcsine_distribution
void test_arcsine(S, F)(in ref F test)
{
    import std.math : log, pow, PI, sqrt;
    auto f0 = (S x) => cast(S) (-S(0.5) * log(-(x-1) * x) - log(PI));
    auto f1 = (S x) => (1 - 2 * x)/(2 * (-1 + x) * x);
    auto f2 = (S x) => (1 - 2 * x + 2 * x * x) / (2 * pow(1 - x, 2) * x * x);
    S[] points = [0.01, 0.99];
    test.plot("dist_arcsine", f0, f1, f2, 1.5, points);
}

// https://en.wikipedia.org/wiki/Gamma_distribution
// a = 4, b = 3
void test_gamma(S, F)(in ref F test)
{
    import std.math : log, pow, PI, sqrt;
    enum one_div_3 = S(1) / 3;
    auto f0 = (S x) => cast(S) (-x / 3 + 3 * log(x) - log(486));
    auto f1 = (S x) => - one_div_3 + 3/x;
    auto f2 = (S x) => -3 / (x * x);
    S[] points = [0,  5, 30];
    test.plot("dist_gamma", f0, f1, f2, 1.5, points, 0, 30);
}

void main(string[] args)
{
    import std.file : exists, mkdir;
    import std.getopt: getopt, defaultGetoptPrinter;

    alias T = double;
    string plotDir = "plots";
    int n = 5_000;
    T rho = 1.1;
    bool plotHistogram = true;

    auto flags = getopt(
        args,
        "plotDir",  "Plot directory", &plotDir,
        "n|num_samples", "Number of samples", &n,
        "p|plot_histogram", "Plot histogram", &plotHistogram,
        "r|rho", "Efficiency rho", &rho);

    if (flags.helpWanted)
        defaultGetoptPrinter("Some information about the program.", flags.options);

    if (!plotDir.exists)
        plotDir.mkdir;

    import std.meta : AliasSeq;
    import std.traits : fullyQualifiedName;
    import std.algorithm.searching : canFind;

    //alias funs = AliasSeq!(test1, test2, test3, test4, test5, test6,
                          //test_normal, test_beta, test_arcsine, test_gamma);

    alias funs = AliasSeq!(test1, test2, test3, test4, test5, test6,
                          test_normal, test_arcsine, test_gamma);

    bool runAll = args.length <= 1;

    auto cf = CFlex!T(n, plotDir, rho, plotHistogram);
    foreach (i, f; funs)
    {
        bool isSelected = runAll;
        enum funName = fullyQualifiedName!(funs[i]);
        if (!runAll)
        {
            // not very elegant, will be rewritten soon
            foreach (arg; args[1..$])
            {
                if (funName.canFind(arg))
                {
                    isSelected = true;
                    break;
                }
            }
        }
        if (isSelected)
        {
            writefln("=== Running: %s", funName);
            f!(T, typeof(cf))(cf);
        }
    }
}
