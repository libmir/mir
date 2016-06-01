#!/usr/bin/env dub
/+ dub.sdl:
name "flex_plot6"
dependency "flex_common" path="./common"
versions "Flex_logging" "Flex_single"
+/

/// Test inflection point at boundary
void test(S, F)(in ref F test)
{
    import std.math : pow;
    auto f0 = (S x) => -pow(x, 4) + 6 * x * x;
    auto f1 = (S x) => 12 * x - 4 * pow(x, 3);
    auto f2 = (S x) => 12 - 12 * x * x;

    test.plot("dist6", f0, f1, f2, 0, [-S.infinity, -2, -1, 0, 1, 2, S.infinity], -5, 5);
}

version(Flex_single) void main()
{
    import flex_common;
    alias T = double;
    int n = 5_000;
    string plotDir = "plots";
    T rho = 1.1;
    auto cf = CFlex!T(5_000, plotDir, rho);
    test!(T, typeof(cf))(cf);
}
