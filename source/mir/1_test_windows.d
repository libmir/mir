unittest
{
    S f = 0x1.14ada3f2c1d77p-48;
    S f2 = 0x1.14ada3f2c1d77p-48;
    import std.stdio;
    writeln("test windows");
    assert(f == f2);
}
