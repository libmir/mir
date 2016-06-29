/**
Simple plot
*/
import mir.random.tinflex: tinflex, Tinflex;
import mir.random.tinflex.internal.plot : plot;
import mir.random.tinflex.internal.random : sample;
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

    // plot PDF
    auto xs = iota!S(left, right, 0.1).array;
    auto ysfit = xs.map!((x) => exp(tf.pdf(x)) / 100).array;
    gg.put( geomLine( Aes!(typeof(xs), "x", typeof(ysfit),
        "y")( xs, ysfit ) ) );

    // plot hat, squeeze
    gg.save(fileName ~ "_hist.png");

    auto ys = tf.plot(xs);
    auto ggHS = GGPlotD().put( geomLine( Aes!(typeof(xs), "x", typeof(ys),
        "y", string[], "colour")( xs, ys, "blue".repeat.take(xs.length).array ) ) );

    ys = tf.plot(xs, false);
    ggHS.put( geomLine( Aes!(typeof(xs), "x", typeof(ys),
        "y", string[], "colour")( xs, ys, "red".repeat.take(xs.length).array ) ) );
    ggHS.save(fileName ~ "_hs.png");

    // chi-square test
    import std.range.primitives : ElementType;
    import mir.random.tinflex.internal.stat.analysis : FreqTable;
    auto ft = FreqTable!(ElementType!(typeof(values)))(100, values);
    auto bps = ft.binPoints((double x) => tf.pdf(x));
    import mir.random.tinflex.internal.stat : chisq;
    writeln(ft.bins.chisq);
    writeln(ft.bins);
    writeln(bps);

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
        tinflex(c, [-2, 0, 1.5]).test(folderName.buildPath("dist1_c" ~ c.to!string));
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
    auto tinflex = (double c,  double[] ips) => tinflex(f0, f1, f2, c, ips);

    import std.conv : to;
    foreach (c; [1.5, 2])
        tinflex(c, [-1, -0.9, -0.5, 0.5, 0.9, 1]).test(folderName.buildPath("dist3_a_" ~ c.to!string));

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

    alias funs = AliasSeq!(test0, test1, test2, test3, test5, test6, test_normal);
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
