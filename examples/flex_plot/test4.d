#!/usr/bin/env dub
/+ dub.sdl:
name "flex_plot4"
dependency "flex_common" path="./common"
versions "Flex_logging" "Flex_single"
+/

// density with pole
void test(S, F)(in ref F test)
{
    import std.math : abs, log;
    auto f0 = (S x) => - cast(S) log(abs(x)) * S(0.5);
    auto f1 = (S x) => -1 / (2 * x);
    auto f2 = (S x) => S(0.5) / (x * x);

    test.plot("dist4", f0, f1, f2, -1.5, [-1.0, 0, 1]);
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
