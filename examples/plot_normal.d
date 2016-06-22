/**
Simple plot
*/
import mir.random.generic: tinflex, sample;
import std.stdio;
import std.algorithm : map, joiner;
import std.conv: to;
import ggplotd.ggplotd;
import ggplotd.aes;
import ggplotd.geom;

void main()
{
    import std.math : exp, PI, pow, sqrt;
    import mir.stat.distributions : normalPDF;

    alias π = PI;
    auto μ = 0; // mean
    auto σ = 1; // stddev

    auto xu2 = (real x) => pow(x - μ, 2);
    auto ss2 = 2 * pow(σ, 2);

    // PDF(NormalDistribution)
    alias f0 = mir.stat.normalPDF;

    // first derivative
    auto f1_below = sqrt(2 * π) * pow(σ, 3);
    auto f1 = (real x) => -(x - μ) * exp(-xu2(x) / ss2) / f1_below;

    // second derivative
    auto f2_above = (real x) => exp(-xu2(x) / ss2);
    auto f2_below_l = sqrt(2 * π) * ss2 * ss2 * σ;
    auto f2_below_r = sqrt(2 * π) * ss2 * σ;
    auto f2 = (real x) => (f2_above(x) * xu2(x)) / f2_below_l - (f2_above(x) / f2_below_r);

    real[] points = [-1.0, 0.0, 1.0];
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
