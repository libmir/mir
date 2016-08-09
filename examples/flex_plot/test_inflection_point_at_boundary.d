#!/usr/bin/env dub
/+ dub.sdl:
name "flex_plot_test_inflection_point_at_boundary"
dependency "flex_common" path="./flex_common"
versions "Flex_logging" "Flex_single"
+/

/**
Test with inflection point at boundary.
*/
void test(S, F)(in ref F test)
{
    import std.math : pow;
    auto f0 = (S x) => -pow(x, 4) + 6 * x * x;
    auto f1 = (S x) => 12 * x - 4 * pow(x, 3);
    auto f2 = (S x) => 12 - 12 * x * x;

    test.plot("dist_if_at_boundary", f0, f1, f2, 0, [-S.infinity, -2, -1, 0, 1, 2, S.infinity], -5, 5);
}

version(Flex_single) void main()
{
    import flex_common;
    alias T = double;
    auto cf = CFlex!T(5_000, "plots", 1.1);
    test!T(cf);
}
