#!/usr/bin/env dub
/+ dub.json:
{
    "name": "flex_plot_test_normal",
    "dependencies": {"flex_plots_pack": {"path": "./flex_common"}},
    "versions": ["Flex_logging", "Flex_single"]
}
+/
/**
Gamma distribution for `a = 4` and `b = 3`.

See_Also:
    $(LINK2 https://en.wikipedia.org/wiki/Gamma_distribution, Wikipedia),
    $(LINK2 http://www.wolframalpha.com/input/?i=PDF%5BGammaDistribution%5B4,+3%5D%5D,
    Wolfram Alpha)
*/
void test(S, F)(in ref F test)
{
    import std.math : log, pow, PI, sqrt;
    enum one_div_3 = S(1) / 3;
    auto f0 = (S x) => cast(S) (-x / 3 + 3 * log(x) - log(486));
    auto f1 = (S x) => - one_div_3 + 3/x;
    auto f2 = (S x) => -3 / (x * x);
    S[] points = [0,  5, 40];
    test.plot("dist_gamma", f0, f1, f2, 1.5, points, 0, 40);
}

version(Flex_single) void main()
{
    import flex_common;
    alias T = double;
    auto cf = CFlex!T(5_000, "plots", 1.1);
    test!T(cf);
}
