#!/usr/bin/env dub
/+ dub.sdl:
name "flex_plot_all"
dependency "flex_plots" path="./flex_plot"
subConfigurations "pyd" "python35"
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
    bool plotHistogram = false;

    auto flags = getopt(
        args,
        "plotDir",  "Plot directory", &plotDir,
        "n|num_samples", "Number of samples", &n,
        "p|plot_histogram", "Plot histogram", &plotHistogram,
        "r|rho", "Efficiency rho", &rho);

    if (flags.helpWanted)
    {
        defaultGetoptPrinter("Some information about the program.", flags.options);
        import core.stdc.stdlib : exit;
        exit(0);
    }

    import std.meta : AliasSeq;
    import std.traits : fullyQualifiedName;
    import std.algorithm.searching : canFind;

    // @@@BUG 16354@@@
    // static foreach doesn't work with mixins
    import test1 : test1               = test;
    import test2 : test2               = test;
    import test3 : test3               = test;
    import test4 : test4               = test;
    import test5 : test5               = test;
    import test6 : test6               = test;
    import test_normal : test_normal   = test;
    import test_arcsine : test_arcsine = test;
    import test_gamma : test_gamma     = test;

    alias funs = AliasSeq!(test1, test2, test3, test4, test5, test6,
                          test_normal, test_arcsine, test_gamma);

    bool runAll = args.length <= 1;

    auto cf = CFlex!T(n, plotDir, rho, plotHistogram);
    foreach (i, f; funs)
    {
        bool isSelected = runAll;
        enum funName = fullyQualifiedName!(funs[i]);
        if (!runAll)
        {
            // not very elegant
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
