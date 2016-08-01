module mir.zzz_test_windows;
unittest
{
    alias S = real;
    S f = 0x1.14ada3f2c1d77p-48;
    S f2 = 0x1.14ada3f2c1d77p-48;
    import std.stdio;
    writeln("test windows");
    assert(f == f2);
    writeln("test windows II");
    import std.math;
    S f3 = 0 + f2 - 0;
    writefln("up: %a", f2.nextUp);
    writefln("down: %a", f2.nextDown);
    writefln("f2: %a", f3);
    writefln("f3: %a", f3);
    assert(f == f3);
    writeln("test windows III");
}
