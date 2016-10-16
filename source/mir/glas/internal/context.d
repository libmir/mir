module mir.glas.internal.context;

import std.range.primitives;
import cpuid.unified;
import mir.internal.memory;

__gshared uint c1;
__gshared uint c2;
__gshared uint line;
__gshared void[] _memory;


import ldc.attributes : fastmath;
@fastmath:

/// Returns: reused unaligned memory chunk
nothrow @nogc void[] memory(size_t size)
{
    if (_memory.length < size)
    {
        auto f = _memory.length << 1;
        if (f > size)
            size = f;
        if (_memory !is null)
            deallocate(_memory);
        _memory = alignedAllocate(size, 4096);
    }
    return _memory[0 .. size];
}

/// Releases memory.
nothrow @nogc void release()
{
    if (_memory !is null)
        deallocate(_memory);
}

nothrow @nogc
shared static this()
{
    cpuid_init();

    auto dc = dCache;
    auto uc = uCache;

    import std.stdio;

    enum msg =  "MIR: failed to get CPUID information";

    while (!uc.empty && uc.back.size > (1024 * 64)) // > 64 MB is CPU memory
    {
        uc.popBack;
    }

    if (dc.length)
    {
        c1 = dc.front.size;
        line = dc.front.line;
        dc.popFront;
    }
    else
    if (uc.length)
    {
        c1 = uc.front.size;
        line = uc.front.line;
        uc.popFront;
    }
    else
    {
        c1 = 16;
    }

    if (uc.length)
    {
        c2 = uc.back.size;
    }
    else
    if (dc.length)
    {
        c2 = dc.back.size;
    }
    else
    {
        c1 = 256;
    }

    c1 <<= 10;
    c2 <<= 10;
    if(line == 0)
        line = 64;
}
