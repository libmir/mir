#!/usr/bin/env dub
/+ dub.sdl:
name "flex_plot_all"
dependency "flex_plots" path="./flex_plot"
subConfigurations "pyd" "python34"
versions "Flex_logging"
+/

/**
Provides a convenient interface to access all plots
*/
void main(string[] args)
{
    import std.getopt: getopt, defaultGetoptPrinter;
    import std.stdio : writefln;
    import flex_common : CFlex;

    alias T = double;
    string plotDir = "plots";
    int n = 5_000;
    T rho = 1.1;
    bool plotHistogram = true;

    auto flags = getopt(
        args,
        "plotDir",  "Plot directory", &plotDir,
        "n|num_samples", "Number of samples", &n,
        "p|plot_histogram", "Plot histogram", &plotHistogram,
        "r|rho", "Efficiency rho", &rho);

    if (flags.helpWanted)
        defaultGetoptPrinter("Some information about the program.", flags.options);

    import std.meta : AliasSeq;
    import std.traits : fullyQualifiedName;
    import std.algorithm.searching : canFind;

    // TODO: proper introspection
    alias mods = AliasSeq!("test1", "test2", "test3", "test4", "test5", "test6",
                          "test_normal", "test_arcsine", "test_gamma");
    foreach (mod; mods)
        mixin("import " ~ mod ~ " : " ~ mod ~ " = test;");

    import test_normal : test_normal = test;
    //alias funs = AliasSeq!(test1, test2, test3, test4, test5, test6,
                          //test_normal, test_arcsine, test_gamma);
    alias funs = AliasSeq!(test_normal);

    bool runAll = args.length <= 1;

    auto cf = CFlex!T(n, plotDir, rho, plotHistogram);
    foreach (i, f; funs)
    {
        bool isSelected = runAll;
        enum funName = fullyQualifiedName!(funs[i]);
        if (!runAll)
        {
            // not very elegant, will be rewritten soon
            foreach (arg; args[1..$])
            {
                if (funName.canFind(arg))
                {
                    isSelected = true;
                    break;
                }
            }
        }
        if (isSelected)
        {
            writefln("=== Running: %s", funName);
            f!(T, typeof(cf))(cf);
        }
    }
}
