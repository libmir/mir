/**
Simple plot
*/
import mir.random.tinflex: tinflex;
import mir.random.tinflex.internal.random : sample;
import std.stdio;
import std.algorithm : map, joiner;
import std.conv: to;
import ggplotd.ggplotd;
import ggplotd.aes;
import ggplotd.geom;

void main()
{
    import std.math : exp, PI, pow, sqrt;
    import mir.random.tinflex.internal.stat.distributions : normalPDF;

    auto mean = 0; // mean
    auto stddev = 1; // stddev

    auto xu2 = (real x) => pow(x - mean, 2);
    auto ss2 = 2 * pow(stddev, 2);

    // PDF(NormalDistribution)
    auto f0 = (real x) => normalPDF(x);

    // first derivative
    auto f1_below = sqrt(2 * PI) * pow(stddev, 3);
    auto f1 = (real x) => -(x - mean) * exp(-xu2(x) / ss2) / f1_below;

    // second derivative
    auto f2_above = (real x) => exp(-xu2(x) / ss2);
    auto f2_below_l = sqrt(2 * PI) * ss2 * ss2 * stddev;
    auto f2_below_r = sqrt(2 * PI) * ss2 * stddev;
    auto f2 = (real x) => (f2_above(x) * xu2(x)) / f2_below_l - (f2_above(x) / f2_below_r);

    //real[] points = [-real.infinity, 0.0, real.infinity];
    real[] points = [-10, 0.0, 10];
    auto tf = tinflex(f0, f1, f2, 1.5, points, 1.1);
    auto values = tf.sample(1000);

    /**
    Simple plotting
    */
    auto aes = Aes!(typeof(values), "x")(values);
    auto gg = GGPlotD().put(geomHist(aes, 100));
    gg.save("hist.png");

    // save to file for further processing
    auto f = File("values.csv", "w");
    f.writeln(values.map!`a.to!string`.joiner(","));
}
