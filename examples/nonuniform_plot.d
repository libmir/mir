#!/usr/bin/env dub
/+ dub.sdl:
name "nonuniform_plot"
dependency "mir" path=".."
dependency "pyd" version="~>0.9.8"
subConfigurations "pyd" "python35"
+/
import pyd.embedded : py_init;

shared static this() {
    py_init();
}

// plot histogram with matplotlib
void histogram(S, Pdf)(S[] values, string fileName, string title, Pdf pdf, bool cumulative = false)
{
    import pyd.embedded : InterpContext;
    import pyd.extra : d_to_python_numpy_ndarray;
    import std.algorithm.iteration : sum;

    static immutable script = `
        import matplotlib.pyplot as plt
        import numpy as np
        n, bins, patches = plt.hist(sample, num_bins, normed=1, cumulative=cumulative)
        xmin, xmax = plt.xlim()
        plt.plot(xs, ys, color='black')
        plt.title(title)
        plt.savefig(fileName, bbox_inches='tight')
        plt.close()
    `;

    import std.algorithm.searching: minPos, maxPos;
    import std.array :array;
    import std.range : front, iota;
    double[] xs = iota(values.minPos.front, values.maxPos.front, 0.1).array;
    double[] ys = new double[xs.length];
    foreach (i, x; xs)
        ys[i] = pdf(x);

    auto total = ys.sum();
    foreach (ref y; ys)
        y /= total;

    if (cumulative)
        foreach (i, ref y; ys[1..$])
            y += ys[i];

    auto pythonContext = new InterpContext();
    pythonContext.sample = values.d_to_python_numpy_ndarray;
    pythonContext.num_bins = 200;
    pythonContext.fileName = fileName;
    pythonContext.title = title;
    pythonContext.xs = xs.d_to_python_numpy_ndarray;
    pythonContext.ys = ys.d_to_python_numpy_ndarray;
    pythonContext.cumulative = cumulative;
    pythonContext.py_stmts(script);
}

void pnormal()
{
    import std.math: exp, PI, sqrt;
    import std.random : Mt19937;
    import mir.random.nonuniform;

    auto n = 10_000;
    auto fileName = "norm";
    auto title = "NormalDist";
    auto gen = Mt19937(42);
    alias S = double;

    auto z = normal!(S, uint)();
    S[] values = new S[n];

    foreach (ref v; values)
        v = z(gen);

    double s = sqrt(2 * PI);
    auto pdf = (double x) => exp(double(-0.5) * x * x) / s;
    values.histogram(fileName ~ "_hist.pdf", title, pdf);
    values.histogram(fileName ~ "_hist_cum.pdf", title, pdf, true);
}

void pexponential()
{
    import std.math: exp;
    import std.random : Mt19937;
    import mir.random.nonuniform;

    auto n = 10_000;
    auto fileName = "expo";
    auto title = "ExponentialDist";
    auto gen = Mt19937(42);
    alias S = double;

    auto z = exponential!(S, uint)();
    S[] values = new S[n];

    foreach (ref v; values)
        v = z(gen);

    auto pdf = (double x) => exp(-x);
    values.histogram(fileName ~ "_hist.pdf", title, pdf);
    values.histogram(fileName ~ "_hist_cum.pdf", title, pdf, true);
}

void main()
{
    pnormal();
    pexponential();
}
