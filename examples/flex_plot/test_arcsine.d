#!/usr/bin/env dub
/+ dub.json:
{
    "name": "flex_plot_test_arcsine",
    "dependencies": {"flex_plots_pack": {"path": "./flex_plots_pack"}},
    "versions": ["Flex_logging", "Flex_single"]
}
+/

/**
Arcsine distribution.

See_Also:
    $(LINK2 https://en.wikipedia.org/wiki/Arcsine_distribution, Wikipedia),
    $(LINK2 http://www.wolframalpha.com/input/?i=PDF%5BArcsineDistribution%5B0,+1%5D%5D,
    Wolfram Alpha)
*/
void test(S, F)(in ref F test)
{
    import std.math : log, pow, PI, sqrt;
    auto f0 = (S x) => cast(S) (-S(0.5) * log(-(x-1) * x) - log(PI));
    auto f1 = (S x) => (1 - 2 * x)/(2 * (-1 + x) * x);
    auto f2 = (S x) => (1 - 2 * x + 2 * x * x) / (2 * pow(1 - x, 2) * x * x);
    S[] points = [0.01, 0.99];
    test.plot("dist_arcsine", f0, f1, f2, 1.5, points);
}

version(Flex_single) void main()
{
    import flex_common;
    alias T = double;
    auto cf = CFlex!T(5_000, "plots", 1.1);
    test!T(cf);
}
