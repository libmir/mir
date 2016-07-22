void main()
{
    import std.datetime: benchmark, Duration;
    import std.stdio: writefln;
    import std.conv: to;

    //auto probs = [0.3, 0.4, 0.2, 0.1];
    auto probs = [0.1, 0.05, 0.05, 0.2, 0.2, 0.2, 0.1];
    auto n = 1_00_000;

    // TODO: auto-generate
    auto f0()
    {
        import test_1;
        return m(probs, n);
    }
    auto f1()
    {
        import test_2;
        return m(probs, n);
    }
    auto f2()
    {
        import test_3;
        return m(probs, n);
    }

    auto names = ["ds", "ds.naive", "uniform"];
    auto rs = benchmark!(f0, f1, f2)(100);

    //writefln("%s", f0);
    //writefln("%s", f1);
    //writefln("%s", f2);

    foreach(j,r;rs)
        writefln("%-8s: %s", names[j], r.to!Duration);
}
