/**
Simple plot
*/
import mir.random.tinflex: tinflex, Tinflex;
import std.array : array;
import std.stdio : writeln, writefln, File;
import std.algorithm : map, joiner, sum;
import std.range : iota, repeat, take;
import std.path : buildPath;
import std.conv: to;
import std.math : exp;
import ggplotd.ggplotd;
import ggplotd.aes;
import ggplotd.geom;
import ggplotd.stat : statHist;

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
auto plot(F0, S)(Tinflex!(F0, S) t, S[] xs, bool isHat = true, bool isTransformed = false)
{
    import mir.random.tinflex : inverse;
    import std.algorithm.comparison : clamp;

    S[] ys = new S[xs.length];
    int k = 0;
    S rMin = xs[0];
    S rMax = xs[$ - 1];

    // each interval is defined in clear bounds
    // as we iterate over the points to be plotted, we have to check to use the
    // correct hat/squeeze function for the current point
    outer: foreach (i, v; t.intervals)
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

/**
Simple plotting
*/
void test(F0, S)(Tinflex!(F0, S) tf, string fileName, int left = -3, int right = 3)
{
    import std.random : rndGen;
    rndGen.seed(42);
    auto values = tf.sample(1_000, rndGen);

    // plot histogram
    auto aes = Aes!(typeof(values), "x")(values);

    // normalize histogram
    auto rect = statHist(aes, 50);
    auto rTotal =  rect.map!`a.height`.sum;
    auto k = rect.map!((r) {
        r.height = r.height / rTotal;
        r.y = r.y / rTotal;
        return r;
    });
    auto gg = GGPlotD().put(geomRectangle(k));

    // plot histogram
    auto xs = iota!S(left, right, 0.01).array;

    gg.save(fileName ~ "_hist.pdf");

    // plot hat, squeeze
    bool isTransformed = false;
    //foreach (isTransformed; [false, true])
    //{
        // hat
        auto ys = tf.plot(xs, true, isTransformed);
        auto ggHS = GGPlotD().put(geomLine(Aes!(typeof(xs), "x", typeof(ys),
            "y", string[], "colour")(xs, ys, "blue".repeat.take(xs.length).array)));

        // squeeze
        ys = tf.plot(xs, false, isTransformed);
        ggHS.put( geomLine( Aes!(typeof(xs), "x", typeof(ys),
            "y", string[], "colour")( xs, ys, "red".repeat.take(xs.length).array)));

        auto c = tf.intervals[0].c;
        import std.math : sgn;
        S delegate(S x) g;
        if (isTransformed)
            g = (S x) => sgn(c) * exp(c * tf.pdf(x));
        else
            g = (S x) => exp(x);
        auto ysPDF = xs.map!((x) => g(tf.pdf(x))).array;

        //ggHS.put(geomLine(Aes!(typeof(xs), "x", typeof(ysPDF), "y")(xs, ysPDF)));
        //auto suffix = isTransformed ? "_transformed" : "";
        enum suffix = "";
        ggHS.save(fileName ~ suffix ~ "_hs.pdf");
    //}

    // chi-square test
    //import std.range.primitives : ElementType;
    //import mir.random.tinflex.internal.stat.analysis : FreqTable;
    //auto ft = FreqTable!(ElementType!(typeof(values)))(100, values);
    //auto bps = ft.binPoints((double x) => tf.pdf(x));
    //import mir.random.tinflex.internal.stat : chisq;
    //writeln(ft.bins.chisq);
    //writeln(ft.bins);
    //writeln(bps);

    // save values to file for further processing
    auto f = File(fileName ~ "_values.csv", "w");
    f.writeln(values.map!`a.to!string`.joiner(","));
}

void test0(string folderName)
{
    auto f0 = (double x) => -x^^4 + 5 * x^^2 - 4;
    auto f1 = (double x) => 10 * x - 4 * x ^^ 3;
    auto f2 = (double x) => 10 - 12 * x ^^ 2;
    auto tf = tinflex(f0, f1, f2, 1.5, [-3.0, -1.5, 0.0, 1.5, 3]);
    tf.test(folderName.buildPath("dist0"));
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
        tinflex(c, [-3.0, -1.5, 0.0, 1.5, 3]).test(folderName.buildPath("dist1_a" ~ c.to!string));
    }

    foreach (c; [-0.9, -0.5, -0.2, 0])
    {
        tinflex(c, [-double.infinity, -2.1, -1.05, 0.1, 1.2, 2, double.infinity]).test(folderName.buildPath("dist1_b" ~ c.to!string));
        tinflex(c, [-double.infinity, -1, 0, 1, double.infinity]).test(folderName.buildPath("dist1_c" ~ c.to!string));
        tinflex(c, [-2, 0, 1.5]).test(folderName.buildPath("dist1_d" ~ c.to!string), -4, 6);
    }

    foreach (c; [-2, -1.5, -1])
    {
        tinflex(c, [-3.0, -2.1, -1.05, 0.1, 1.2, 3]).test(folderName.buildPath("dist1_e" ~ c.to!string));
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
        tinflex(c, [-3, -1, 0, 1, 3]).test(folderName.buildPath("dist2_c_" ~ c.to!string));
        tinflex(c, [-3, -1 + (cast(real) 2) ^^-52, 1e-20, 1 - (cast(real) 2)^^(-53), 3]).test(folderName.buildPath("dist2_d_" ~ c.to!string));
    }

    foreach (c; [-0.9, -0.5, -0.2, 0])
    {
        tinflex(c, [-double.infinity, -2, -1, 0, 1, 2, double.infinity]).test(folderName.buildPath("dist2_a" ~ c.to!string));
        tinflex(c, [-double.infinity, -2, -1 + (cast(real)2)^^-52, 1e-20, 1-(cast(real)2)^^(-53), 2, double.infinity]).test(folderName.buildPath("dist2_" ~ c.to!string));
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
        .test(folderName.buildPath("dist3_a_" ~ c.to!string), -1, 1);

    foreach (c; [-2, -1.5, -1, -0.9,  -0.5, -0.2, 0, 0.1, 0.5, 1])
        tinflex(c, [-1, -0.5, 0.5, 1]).test(folderName.buildPath("dist3_b_" ~ c.to!string));
}

// density with pole
void test4(string folderName)
{
    import std.math : abs, log;
    auto f0 = (real x) => - log(abs(x)) / 2;
    auto f1 = (real x) => -1 / (2 * x);
    auto f2 = (real x) => 1 / (2 * x^^2);

    tinflex(f0, f1, f2, 1.5, [-1.0, 0, 1]).test(folderName.buildPath("dist4"));
}

// different values for c
void test5(string folderName)
{
    auto f0 = (double x) => -2 * x^^4 + 4 * x^^2;
    auto f1 = (double x) => -8 * x^^3 + 8 * x;
    auto f2 = (double x) => -24 * x^^2 + 8;

    tinflex(f0, f1, f2, [-0.5, 2, -2, 0.5, -1, 0], [-double.infinity, -2, -1, 0, 1, 2, double.infinity])
    .test(folderName.buildPath("dist5_b"));

    tinflex(f0, f1, f2, [-0.5, 2, -2, 0.5, -1, 0], [-3, -2, -1, 0, 1, 2, 3])
    .test(folderName.buildPath("dist5_b"));
}

// inflection point at boundary
void test6(string folderName)
{
    auto f0 = (double x) => -x^^4 + 6 * x^^2;
    auto f1 = (double x) => 12 * x - 4 * x^^3;
    auto f2 = (double x) => 12 - 12 * x^^2;

    tinflex(f0, f1, f2, 0, [-double.infinity, -2, -1, 0, 1, 2, double.infinity])
    .test(folderName.buildPath("dist6"));
}


void test_normal(string folderName)
{
    import std.math : exp, PI, sqrt;
    alias S = real;
    //S[] points = [-S.infinity, -1.5, 0, 1.5, S.infinity];
    S[] points = [-3, -1.5, 0, 1.5, 3];
    S sqrt2PI = sqrt(2 * PI);
    auto f0 = (S x) => 1 / (exp(x * x / 2) * sqrt2PI);
    auto f1 = (S x) => -(x/(exp(x * x/2) * sqrt2PI));
    auto f2 = (S x) => (-1 + x * x) / (exp(x * x/2) * sqrt2PI);
    tinflex(f0, f1, f2, 1.5, points)
    .test(folderName.buildPath("dist_normal"));
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
