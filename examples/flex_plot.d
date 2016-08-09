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
    bool saveCSV;

    auto flags = getopt(
        args,
        "plotDir",  "Plot directory", &plotDir,
        "n|num_samples", "Number of samples", &n,
        "p|plot_histogram", "Plot histogram", &plotHistogram,
        "r|rho", "Efficiency rho", &rho,
        "c|csv", "Save csv", &saveCSV);

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
    import test_double_dist                  : double_dist                  = test;
    import test_near_extrema                 : near_extrema                 = test;
    import test_density_at_boundaries        : density_at_boundaries        = test;
    import test_density_with_poles           : density_with_poles           = test;
    import test_different_c_values           : different_c_values           = test;
    import test_inflection_point_at_boundary : inflection_point_at_boundary = test;
    import test_normal                       : normal                       = test;
    import test_arcsine                      : arcsine                      = test;
    import test_beta                         : beta                         = test;
    import test_gamma                        : gamma                        = test;

    alias funs = AliasSeq!(double_dist, near_extrema, density_at_boundaries,
                           density_with_poles, different_c_values, inflection_point_at_boundary,
                           normal, arcsine, gamma);

    bool runAll = args.length <= 1;

    auto cf = CFlex!T(n, plotDir, rho, plotHistogram);
    cf.saveCSV = saveCSV;
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
            f!T(cf);
        }
    }
}
