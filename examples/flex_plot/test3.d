#!/usr/bin/env dub
/+ dub.sdl:
name "flex_plot3"
dependency "flex_common" path="./common"
versions "Flex_logging" "Flex_single"
+/


// density vanishes at boundaries
void test(S, F)(in ref F test)
{
    import std.math : log, pow;
    auto f0 = (S x) => cast(S) log(1 - pow(x, 4));
    auto f1 = (S x) => -4 * pow(x, 3) / (1 - pow(x, 4));
    auto f2 = (S x) => -(4 * pow(x, 6) + 12 * x * x) / (pow(x, 8) - 2 * pow(x, 4) + 1);

    foreach (c; [1.5, 2])
        test.plot("dist3_a_" ~ c.to!string, f0, f1, f2, c, [-1, -0.9, -0.5, 0.5, 0.9, 1], -1, 1);

    foreach (c; [-2, -1.5, -1, -0.9,  -0.5, -0.2, 0, 0.1, 0.5, 1])
        test.plot("dist3_b_" ~ c.to!string, f0, f1, f2, c, [-1, -0.5, 0.5, 1]);
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
