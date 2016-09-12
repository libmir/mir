#!/usr/bin/env dub
/+ dub.json:
{
    "name": "flex_plot_test_beta",
    "dependencies": {"flex_common": {"path": "./flex_common"}},
    "versions": ["Flex_logging", "Flex_single"]
}
+/

/**
Beta distribution for `a=2` and `b=5`.

See_Also:
    $(LINK2 https://en.wikipedia.org/wiki/Beta_distribution, Wikipedia)
    $(LINK2 http://www.wolframalpha.com/input/?i=PDF%5BGammaDistribution%5B2,+5%5D%5D,
    Wolfram Alpha)
*/
void test(S, F)(in ref F test)
{
    import std.math : log, pow;
    auto f0 = (S x) => cast(S) log(30 * (1 - x).pow(x));
    auto f1 = (S x) => (1 - 5 * x)/(x - x * x);
    auto f2 = (S x) => (-1 + 2 * x - 5 * x * x) / (pow(-1 + x, 2) * x * x);
    S[] points = [0,  1];
    test.plot("dist_beta", f0, f1, f2, 1.5, points);
}

version(Flex_single) void main()
{
    import flex_common;
    alias T = double;
    auto cf = CFlex!T(5_000, "plots", 1.1);
    test!T(cf);
}
