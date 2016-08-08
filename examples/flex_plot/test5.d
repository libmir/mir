#!/usr/bin/env dub
/+ dub.sdl:
name "flex_plot5"
dependency "flex_common" path="./common"
versions "Flex_logging" "Flex_single"
+/

/// Test different values for c
void test(S, F)(in ref F test)
{
    import std.math : pow;
    auto f0 = (S x) => -2 * pow(x, 4)  + 4 * x * x;
    auto f1 = (S x) => -8 * pow(x, 3) + 8 * x;
    auto f2 = (S x) => -24 * x * x + 8;

    test.plot("dist5_a", f0, f1, f2, [-0.5, 2, -2, 0.5, -1, 0],
        [-S.infinity, -2, -1, 0, 1, 2, S.infinity]);

    test.plot("dist5_b", f0, f1, f2, [-0.5, 2, -2, 0.5, -1, 0], [-3, -2, -1, 0, 1, 2, 3]);
}

version(Flex_single) void main()
{
    import flex_common;
    alias T = double;
    auto cf = CFlex!T(5_000, "plots", 1.1);
    test!T(cf);
}
