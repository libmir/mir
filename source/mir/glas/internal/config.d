module mir.glas.internal.config;

import std.traits;
import std.meta;
import std.complex: Complex;
import mir.internal.utility;

template RegisterConfig(size_t PR, size_t PS, size_t PB, T)
    if (is(Unqual!T == T) && !isComplex!T)
{
    static if (isFloatingPoint!T)
        version(X86)
            version(LDC)
                static if (__traits(targetHasFeature, "sse2"))
                    mixin SSE2;
                else
                    mixin FPU;
            else
                mixin FPU;
        else
        version(X86_64)
            version(LDC)
                static if (__traits(targetHasFeature, "avx512f"))
                    mixin AVX512F;
                else
                static if (__traits(targetHasFeature, "avx"))
                    mixin AVX;
                else
                    mixin SSE2;
            else
                mixin SSE2;
        else
            mixin M16;
    else
    static if (isIntegral!T)
        version(X86)
            static if (T.sizeof > size_t.sizeof)
                mixin M1;
            else
                mixin M4;
        else
            static if (T.sizeof > size_t.sizeof)
                mixin M4;
            else
                mixin M16;
    else
        mixin M1;
    enum broadcastChain = BroadcastChain!broadcast;
    enum size_t nr = broadcast;
    enum size_t mr = simdChain[0].sizeof / T.sizeof;
}

template BroadcastChain(size_t s)
{
    import std.traits: Select;
    import core.bitop: bsr;
    static assert(s);
    static if (s == 1)
    {
        enum size_t[] BroadcastChain = [s];
    }
    else
    {
        private enum trp2 = 1 << bsr(s);
        enum size_t[] BroadcastChain = [s] ~ BroadcastChain!(Select!(trp2 == s, trp2 / 2, trp2));
    }
}

mixin template AVX512F()
{
    static if (is(T == real))
        mixin M8;
    else
    static if (is(T == float))
        static if (PR == 1)
            mixin AVX512_S;
        else
            mixin AVX512_C;
    else
    static if (is(T == double))
        static if (PR == 1)
            mixin AVX512_D;
        else
            mixin AVX512_Z;
    else static assert(0);
}

// AVX and AVX2
mixin template AVX()
{
    static if (is(T == real))
        mixin M8;
    else
    static if (is(T == float))
        static if (PR == 1)
            mixin AVX_S;
        else
            mixin AVX_C;
    else
    static if (is(T == double))
        static if (PR == 1)
            mixin AVX_D;
        else
            mixin AVX_Z;
    else static assert(0);
}

mixin template SSE2()
{
    static if (is(T == real))
        mixin M8;
    else
    static if (is(T == float))
        static if (PR == 1)
            mixin SSE2_S;
        else
            mixin SSE2_C;
    else
    static if (is(T == double))
        static if (PR == 1)
            mixin SSE2_D;
        else
            mixin SSE2_Z;
    else static assert(0);
}

alias FPU = M8;

template optVec(V)
{
    version(LDC)
        alias optVec = __vector(V)[1];
    else
        alias optVec = V;
}

mixin template AVX512_S()
{
    enum size_t broadcast = 6;
    alias simdChain = AliasSeq!(__vector(float[8])[4], __vector(float[16])[2], __vector(float[16])[1], __vector(float[8])[1], __vector(float[4])[1], optVec!(float[2]), float[1]);
}

mixin template AVX512_D()
{
    enum size_t broadcast = 6;
    alias simdChain = AliasSeq!(__vector(double[8])[4], __vector(double[8])[2], __vector(double[8])[1], __vector(double[4])[1], __vector(double[2])[1], double[1]);
}

mixin template AVX512_C()
{
    enum size_t broadcast = 6;
    alias simdChain = AliasSeq!(__vector(float[16])[2], __vector(float[16])[1], __vector(float[8])[1], __vector(float[4])[1], optVec!(float[2]), float[1]);
}

mixin template AVX512_Z()
{
    enum size_t broadcast = 6;
    alias simdChain = AliasSeq!(__vector(double[8])[2], __vector(double[8])[1], __vector(double[4])[1], __vector(double[2])[1], double[1]);
}

mixin template AVX_S()
{
    enum size_t broadcast = 6;
    alias simdChain = AliasSeq!(__vector(float[8])[2], __vector(float[8])[1], __vector(float[4])[1], optVec!(float[2]), float[1]);
}

mixin template AVX_D()
{
    enum size_t broadcast = 6;
    alias simdChain = AliasSeq!(__vector(double[4])[2], __vector(double[4])[1], __vector(double[2])[1], double[1]);
}

mixin template AVX_C()
{
    enum size_t broadcast = 6;
    alias simdChain = AliasSeq!(__vector(float[8])[1], __vector(float[4])[1], optVec!(float[2]), float[1]);
}

mixin template AVX_Z()
{
    enum size_t broadcast = 6;
    alias simdChain = AliasSeq!(__vector(double[4])[1], __vector(double[2])[1], double[1]);
}

mixin template SSE2_S()
{
    enum size_t broadcast = 6;
    alias simdChain = AliasSeq!(__vector(float[4])[2], __vector(float[4])[1], optVec!(float[2]), float[1]);
}

mixin template SSE2_D()
{
    enum size_t broadcast = 6;
    alias simdChain = AliasSeq!(__vector(double[2])[2], __vector(double[2])[1], double[1]);
}

mixin template SSE2_C()
{
    enum size_t broadcast = 4;
    alias simdChain = AliasSeq!(__vector(float[4])[2], __vector(float[4])[1], optVec!(float[2]), float[1]);
}

mixin template SSE2_Z()
{
    enum size_t broadcast = 4;
    alias simdChain = AliasSeq!(__vector(double[2])[2], __vector(double[2])[1], double[1]);
}

mixin template M16()
{
    static if (PR == 1)
    {
        enum size_t broadcast = 6;
        alias simdChain = AliasSeq!(T[2], T[1]);
    }
    else
    {
        enum size_t broadcast = 2;
        alias simdChain = AliasSeq!(T[2], T[1]);
    }
}

mixin template M8()
{
    enum size_t broadcast = 2;
    static if (PR == 1)
        alias simdChain = AliasSeq!(T[2], T[1]);
    else
        alias simdChain = AliasSeq!(T[1]);
}

mixin template M4()
{
    enum size_t broadcast = 1;
    static if (PR == 1)
        alias simdChain = AliasSeq!(T[2], T[1]);
    else
        alias simdChain = AliasSeq!(T[1]);
}

mixin template M1()
{
    enum size_t broadcast = 1;
    alias simdChain = AliasSeq!(T[1]);
}
