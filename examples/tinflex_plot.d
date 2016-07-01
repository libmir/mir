/**
Simple plot
*/
import mir.random.tinflex: tinflex, Tinflex, TinflexInterval;
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

/**
Convenience method to sample Arrays with sample r
This will be replaced with a more sophisticated version in later versions.

Params:
    r = random sampler
    n = number of times to sample
Returns: Randomly sampled Array of length n
*/
typeof(R.init())[] sample(R, RNG)(R r, int n, RNG rnd)
{
    alias S = typeof(r());
    S[] arr = new S[n];
    foreach (ref s; arr)
        s = r(rnd);
    return arr;
}

/// ditto
typeof(R.init())[] sample(R)(R r, int n)
{
    import std.random : rndGen;
    return sample(r, n, rndGen);
}

// plot histogram with matplotlib
void npPlotHistogram(S)(S[] values, string fileName)
{
    import std.math : isNaN;
    static immutable script = `
        import matplotlib.pyplot as plt
        n, bins, patches = plt.hist(sample, num_bins, normed=1)
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
    pythonContext.py_stmts(script);
}

/**
Generates a series of y-values of all hat or squeeze functions of an Tinflex
object. This is useful for plotting.
Points in xs need to be in the boundaries of the Tinflex algorithm, otherwise they
will be ignored.

Params:
    t = Tinflex generator
    xs = x points to be plotted
    isHat = whether hat (true) or squeeze (false) should be plotted
    isTransformed = whether to plot the transformed functions
*/
auto plotArea(S, T)(in TinflexInterval!S[] intervals, T[] xs, bool isHat = true, bool isTransformed = false)
{
    import mir.random.tinflex : inverse;
    import std.algorithm.comparison : clamp;

    T[] ys = new T[xs.length];
    int k = 0;
    T rMin = xs[0];
    T rMax = xs[$ - 1];

    // each interval is defined in clear bounds
    // as we iterate over the points to be plotted, we have to check to use the
    // correct hat/squeeze function for the current point
    outer: foreach (i, v; intervals)
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
            ys[k] = (isHat) ? v.hat(xs[k]) : v.squeeze(xs[k]);
            if (!isTransformed)
                ys[k] = inverse(ys[k], v.c);
            if (++k >= xs.length)
                break outer;
        }
    }
    return ys;
}

auto npPlotHatAndSqueezeArea(S, Pdf)(in TinflexInterval!S[] intervals, Pdf pdf, string fileName,
                              S stepSize = 0.1, S left = -3, S right = 3)
{
    import std.array : array;
    import std.traits : ReturnType;

    static immutable script = `
        import matplotlib.pyplot as plt
        plt.plot(xs, ys, color='black')
        plt.plot(xs, hat, color='blue')
        plt.plot(xs, squeeze, color='red')
        plt.savefig(fileName, bbox_inches='tight')
        plt.close()
    `;

    auto pythonContext = new InterpContext();
    alias T = double;
    T[] xs = iota!(T, T, T)(left, right + stepSize, stepSize).array;
    pythonContext.xs = xs.toNumpyArray;

    // PDF
    T[] ys = new T[xs.length];
    foreach (i, ref y; ys)
        y = pdf(xs[i]);

    pythonContext.ys = ys.toNumpyArray;

    bool isTransformed = false;

    // hat
    auto hats = cast(T[]) intervals.plotArea(xs, true, isTransformed);
    pythonContext.hat = hats.toNumpyArray;

    // squeeze
    auto squeeze = cast(T[]) intervals.plotArea(xs, false, isTransformed);
    pythonContext.squeeze = squeeze.toNumpyArray;

    pythonContext.fileName = fileName;
    pythonContext.py_stmts(script);
}

/**
Plots every interval as a separate line with a given stepsize.
*/
auto plotWithIntervals(S)(in TinflexInterval!S[] intervals, bool isHat = true, S stepSize = 0.01, bool isTransformed = false)
{
    import mir.random.tinflex : inverse;
    import std.math : ceil;
    import std.algorithm.comparison : max;

    auto len = intervals.length;

    // TODO: do something smart to avoid many allocations here
    S[][] xs = new S[][len];
    S[][] ys = new S[][xs.length];

    foreach (i, iv; intervals)
    {
        size_t nrIntervals = cast(size_t) ((iv.rx - iv.lx) / stepSize).ceil;
        xs[i] = new S[max(nrIntervals, 2)];
        ys[i] = new S[max(nrIntervals, 2)];
        S x = iv.lx;
        foreach (k; 0..nrIntervals)
        {
            xs[i][k] = x;
            ys[i][k] = (isHat) ? iv.hat(x) : iv.squeeze(x);
            if (!isTransformed)
                ys[i][k] = inverse(ys[i][k], iv.c);

            x += stepSize;
        }
        if (x < iv.rx || nrIntervals == 1)
        {
            // plot last value too
            xs[i][$ - 1] = iv.rx;
            ys[i][$ - 1] = (isHat) ? iv.hat(iv.rx) : iv.squeeze(iv.rx);
        }
    }
    import std.typecons : tuple;
    return tuple!("xs", "ys")(xs, ys);
}

auto npPlotHatAndSqueeze(S, Pdf)(in TinflexInterval!S[] intervals, Pdf pdf, string fileName,
                              S stepSize = 0.1, S left = -3, S right = 3)
{
    static immutable script = `
        import matplotlib.pyplot as plt
        plt.plot(xs, ys, color='black')
        for i, h in enumerate(hats):
            plt.plot(xsHS[i], h, color='blue')
        for i, s in enumerate(squeezes):
            plt.plot(xsHS[i], s, color='red')
        plt.savefig(fileName, bbox_inches='tight')
        plt.close()
    `;

    auto pythonContext = new InterpContext();
    alias T = double;
    import std.array : array;
    T[] xs = iota!(T, T, T)(left, right + stepSize, stepSize).array;
    auto hats = plotWithIntervals(intervals, true);
    // TODO: this allocates the xs array twice
    auto squeezes = plotWithIntervals(intervals, false);

    T[] ys = new T[xs.length];
    foreach (i, ref y; ys)
        y = pdf(xs[i]);

    pythonContext.xs = xs.toNumpyArray;
    pythonContext.ys = ys.toNumpyArray;

    // TODO: do something smart to convert hat.xs to list of numpy arrays
    pythonContext.xsHS = hats.xs.d_to_python;
    pythonContext.hats = hats.ys.d_to_python;
    pythonContext.squeezes = squeezes.ys.d_to_python;

    pythonContext.fileName = fileName;
    pythonContext.py_stmts(script);
}

/**
Simple plotting
*/
void test(F0, S, Pdf)(Tinflex!(F0, S) tf, Pdf f0, string fileName, int left = -3, int right = 3)
{
    import std.math : exp;
    auto pdf = (S x) => exp(f0(x));
    // first plot hat/squeeze in case we crash during sampling
    tf.intervals.npPlotHatAndSqueeze(pdf, fileName ~ "_hs.pdf");
    tf.intervals.npPlotHatAndSqueezeArea(pdf, fileName ~ "_hs_area.pdf");

    import std.random : rndGen;
    rndGen.seed(42);
    auto values = tf.sample(2_000, rndGen);

    values.npPlotHistogram(fileName ~ "_hist.pdf");

    // save values to file for further processing
    //auto f = File(fileName ~ "_values.csv", "w");
    //f.writeln(values.map!`a.to!string`.joiner(","));
}

void test0(string folderName)
{
    auto f0 = (double x) => -x^^4 + 5 * x^^2 - 4;
    auto f1 = (double x) => 10 * x - 4 * x ^^ 3;
    auto f2 = (double x) => 10 - 12 * x ^^ 2;
    auto tf = tinflex(f0, f1, f2, 1.5, [-3.0, -1.5, 0.0, 1.5, 3]);
    tf.test(f0, folderName.buildPath("dist0"));
}

// default tinflex testing distribution
void test1(string folderName)
{
    auto f0 = (double x) => -x^^4 + 5 * x^^2 - 4;
    auto f1 = (double x) => 10 * x - 4 * x ^^ 3;
    auto f2 = (double x) => 10 - 12 * x ^^ 2;
    auto tinflex = (double c,  double[] ips) => tinflex(f0, f1, f2, c, ips);
    import std.conv : to;

    foreach (c; [0.1, 0.5, 1])
    {
        tinflex(c, [-3.0, -1.5, 0.0, 1.5, 3]).test(f0, folderName.buildPath("dist1_a" ~ c.to!string));
    }

    foreach (c; [-0.9, -0.5, -0.2, 0])
    {
        tinflex(c, [-double.infinity, -2.1, -1.05, 0.1, 1.2, 2, double.infinity]).test(f0, folderName.buildPath("dist1_b" ~ c.to!string));
        tinflex(c, [-double.infinity, -1, 0, 1, double.infinity]).test(f0, folderName.buildPath("dist1_c" ~ c.to!string));
        tinflex(c, [-2, 0, 1.5]).test(f0, folderName.buildPath("dist1_d" ~ c.to!string), -4, 6);
    }

    foreach (c; [-2, -1.5, -1])
    {
        tinflex(c, [-3.0, -2.1, -1.05, 0.1, 1.2, 3]).test(f0, folderName.buildPath("dist1_e" ~ c.to!string));
    }
}

// test at and near extrema
void test2(string folderName)
{
    auto f0 = (double x) => -2 *  x^^4 + 4 * x^^2;
    auto f1 = (double x) => -8 *  x^^3 + 8 * x;
    auto f2 = (double x) => -24 * x^^2 + 8;
    auto tinflex = (double c,  double[] ips) => tinflex(f0, f1, f2, c, ips);

    import std.conv : to;

    foreach (c; [-2, -1.1, -1, 0.5, 1, 1.5, 2])
    {
        tinflex(c, [-3, -1, 0, 1, 3]).test(f0, folderName.buildPath("dist2_c_" ~ c.to!string));
        tinflex(c, [-3, -1 + (cast(real) 2) ^^-52, 1e-20, 1 - (cast(real) 2)^^(-53), 3]).test(f0, folderName.buildPath("dist2_d_" ~ c.to!string));
    }

    foreach (c; [-0.9, -0.5, -0.2, 0])
    {
        tinflex(c, [-double.infinity, -2, -1, 0, 1, 2, double.infinity]).test(f0, folderName.buildPath("dist2_a" ~ c.to!string));
        tinflex(c, [-double.infinity, -2, -1 + (cast(real)2)^^-52, 1e-20, 1-(cast(real)2)^^(-53), 2, double.infinity]).test(f0, folderName.buildPath("dist2_" ~ c.to!string));
    }
}

// density vanishes at boundaries
void test3(string folderName)
{
    import std.math : log;
    auto f0 = (double x) => log(1 - x^^4);
    auto f1 = (double x) => -4 * x^^3 / (1 - x^^4);
    auto f2 = (double x) => -(4 * x^^6 + 12 * x^^2) / (x^^8 - 2 * x^^4 + 1);
    auto tinflex = (double c,  double[] ips) => tinflex(f0, f1, f2, c, ips, 1.01);

    import std.conv : to;
    foreach (c; [1.5, 2])
        tinflex(c, [-1, -0.9, -0.5, 0.5, 0.9, 1])
        .test(f0, folderName.buildPath("dist3_a_" ~ c.to!string), -1, 1);

    foreach (c; [-2, -1.5, -1, -0.9,  -0.5, -0.2, 0, 0.1, 0.5, 1])
        tinflex(c, [-1, -0.5, 0.5, 1]).test(f0, folderName.buildPath("dist3_b_" ~ c.to!string));
}

// density with pole
void test4(string folderName)
{
    import std.math : abs, log;
    auto f0 = (real x) => - log(abs(x)) / 2;
    auto f1 = (real x) => -1 / (2 * x);
    auto f2 = (real x) => 1 / (2 * x^^2);

    tinflex(f0, f1, f2, 1.5, [-1.0, 0, 1]).test(f0, folderName.buildPath("dist4"));
}

// different values for c
void test5(string folderName)
{
    auto f0 = (double x) => -2 * x^^4 + 4 * x^^2;
    auto f1 = (double x) => -8 * x^^3 + 8 * x;
    auto f2 = (double x) => -24 * x^^2 + 8;

    tinflex(f0, f1, f2, [-0.5, 2, -2, 0.5, -1, 0], [-double.infinity, -2, -1, 0, 1, 2, double.infinity])
    .test(f0, folderName.buildPath("dist5_b"));

    tinflex(f0, f1, f2, [-0.5, 2, -2, 0.5, -1, 0], [-3, -2, -1, 0, 1, 2, 3])
    .test(f0, folderName.buildPath("dist5_b"));
}

// inflection point at boundary
void test6(string folderName)
{
    auto f0 = (double x) => -x^^4 + 6 * x^^2;
    auto f1 = (double x) => 12 * x - 4 * x^^3;
    auto f2 = (double x) => 12 - 12 * x^^2;

    tinflex(f0, f1, f2, 0, [-double.infinity, -2, -1, 0, 1, 2, double.infinity])
    .test(f0, folderName.buildPath("dist6"));
}


void test_normal(string folderName)
{
    import std.math : exp, log, PI, sqrt;
    alias S = real;
    //S[] points = [-S.infinity, -1.5, 0, 1.5, S.infinity];
    S[] points = [-3, -1.5, 0, 1.5, 3];
    S sqrt2PI = sqrt(2 * PI);
    //auto f0 = (S x) => 1 / (exp(x * x / 2) * sqrt2PI);
    //auto f1 = (S x) => -(x/(exp(x * x/2) * sqrt2PI));
    //auto f2 = (S x) => (-1 + x * x) / (exp(x * x/2) * sqrt2PI);
    auto f0 = (S x) => log(1 / (exp(x * x / 2) * sqrt2PI));
    auto f1 = (S x) => -x;
    auto f2 = (S x) => -1.0;
    tinflex(f0, f1, f2, 1.5, points)
    .test(f0, folderName.buildPath("dist_normal"));
}

void main(string[] args)
{
    bool runAll = args.length <= 1;

    import std.file : exists, mkdir;
    string folderName = "plots";

    if (!folderName.exists)
        folderName.mkdir;

    import std.meta : AliasSeq;
    import std.traits : fullyQualifiedName;
    import std.algorithm.searching : canFind;

    alias funs = AliasSeq!(test0, test1, test2, test3, test4, test5, test6, test_normal);
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
            f(folderName);
        }
    }
}
