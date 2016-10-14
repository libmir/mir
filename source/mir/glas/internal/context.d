module mir.glas.internal.context;

import std.range.primitives;
import cpuid.unified;

__gshared immutable Cache c1;
__gshared immutable Cache c2;
__gshared immutable Tlb tlb;

nothrow @nogc
shared static this()
{
    cpuid_init();

    auto dc = dCache;
    auto uc = uCache;

    import std.stdio;

    enum msg =  "MIR: failed to get CPUID information";

    while (!uc.empty && uc.back.size > (1024 * 32)) // > 32 MB is CPU memory
    {
        uc.popBack;
    }

    if (dc.length)
    {
        c1 = dc.front;
        dc.popFront;
    }
    else
    if (uc.length)
    {
        c1 = uc.front;
        uc.popFront;
    }
    else assert(0, msg);

    if (uc.length)
    {
        c2 = uc.back;
    }
    else
    if (dc.length)
    {
        c2 = dc.back;
    }
    else assert(0, msg);

    if (uTlb.length)
    {
        tlb = uTlb.back;
    }
    else
    if (dTlb.length)
    {
        tlb = dTlb.back;
    }
    else assert(0, msg);
}
