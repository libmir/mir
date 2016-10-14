#!/usr/bin/env dub
/+ dub.json:
{
    "name": "flex_plot_test_normal",
    "dependencies": {"flex_plots_pack": {"path": "./flex_common"}},
    "versions": ["Flex_logging", "Flex_single"]
}
+/
/**
Normal distribution.

See_Also:
    $(LINK2 https://en.wikipedia.org/wiki/Normal_distribution, Wikipedia)
*/
void test(S, F)(in ref F test)
{
    import std.math : exp, log, PI, sqrt;
    S[] points = [-S.infinity, -1.5, 0, 1.5, S.infinity];
    enum S halfLog2PI = S(0.5) * log(2 * PI);
    auto f0 = (S x) => -(x * x) * S(0.5) - halfLog2PI;
    auto f1 = (S x) => -x;
    auto f2 = (S x) => S(-1);
    test.plot("dist_normal", f0, f1, f2, -0.5, points, -4, 4);
}

version(Flex_single) void main()
{
    import flex_common;
    alias T = double;
    auto cf = CFlex!T(5_000, "plots", 1.1);
    test!T(cf);
}
