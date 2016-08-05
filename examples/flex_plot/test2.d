#!/usr/bin/env dub
/+ dub.sdl:
name "flex_plot2"
dependency "flex_common" path="./common"
versions "Flex_logging" "Flex_single"
+/

// test at and near extrema
void test(S, F)(in ref F test)
{
    import std.math : pow;
    import std.conv : to;
    auto f0 = (S x) => -2 * pow(x, 4) + 4 * x * x;
    auto f1 = (S x) => -8 * pow(x, 3) + 8 * x;
    auto f2 = (S x) => -24 * x * x + 8;

    foreach (c; [-2, -1.1, -1, 0.5, 1, 1.5, 2])
    {
        test.plot("dist2_c_" ~ c.to!string, f0, f1, f2, c, [-3, -1, 0, 1, 3]);
        test.plot("dist2_d_" ~ c.to!string, f0, f1, f2, c,
            [-3, -1 + (cast(S) 2) ^^-52, 1e-20, 1 - (cast(S) 2)^^(-53), 3]);
    }

    foreach (c; [-0.9, -0.5, -0.2, 0])
    {
        test.plot("dist2_a" ~ c.to!string, f0, f1, f2, c,
            [-S.infinity, -2, -1, 0, 1, 2, S.infinity]);
        test.plot("dist2_" ~ c.to!string, f0, f1, f2, c,
            [-S.infinity, -2, -1 + (cast(S)2)^^-52, 1e-20, 1-(cast(S)2)^^(-53), 2, S.infinity]);
    }
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
