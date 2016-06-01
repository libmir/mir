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
    auto f0 = (double x) => -x^^4 + 5 * x^^2 - 4;
    auto f1 = (double x) => 10 * x - 4 * x ^^ 3;
    auto f2 = (double x) => 10 - 12 * x ^^ 2;
    auto tf = tinflex(f0, f1, f2, 1.5, [-3.0, -1.5, 0.0, 1.5, 3], 1.1);
    auto values = tf.sample(1000);

    /**
    Simple plotting
    */
    auto aes = Aes!(typeof(values), "x")(values);
    auto gg = GGPlotD().put(geomHist(aes));
    gg.save("hist.png");

    // save to file for further processing
    auto f = File("values.csv", "w");
    f.writeln(values.map!`a.to!string`.joiner(","));
}
