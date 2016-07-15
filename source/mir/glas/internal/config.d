module mir.glas.internal.config;

import std.traits;
import std.meta;
import std.complex: Complex;
import mir.internal.utility;

template RegisterConfig(size_t PR, size_t PS, size_t PB, T)
	if(is(Unqual!T == T) && !isComplex!T)
{
	//static if(isFloatingPoint!T)
	//	version(X86)
	//		mixin M8;
	//	else
	//	version(X86_64)
	//		static if(is(T == real))
	//			mixin M8;
	//		else
	//		static if(is(T == float))
	//			static if(PR == 2)
	//				mixin M16_S_X86_64;
	//			else
	//				mixin M16_C_X86_64;
	//		else
	//		static if(is(T == double))
	//			static if(PR == 2)
	//				mixin M16_D_X86_64;
	//			else
	//				mixin M16_Z_X86_64;
	//		else static assert(0);
	//	else
	//		mixin M16;
	//else
	//static if(isIntegral!T)
	//	version(X86)
	//		static if(T.sizeof > size_t.sizeof)
	//			mixin M1;
	//		else
	//			mixin M4;
	//	else
	//		static if(T.sizeof > size_t.sizeof)
	//			mixin M4;
	//		else
	//			mixin M16;
	//else
		mixin M1;
	enum broadcastChain = BroadcastChain!broadcast;
}

template BroadcastChain(size_t s)
{
	import std.traits: Select;
	import core.bitop: bsr;
	static assert(s);
	static if(s == 1)
	{
		enum size_t[] BroadcastChain = [s];
	}
	else
	{
		private enum trp2 = 1 << bsr(s);
		enum size_t[] BroadcastChain = [s] ~ BroadcastChain!(Select!(trp2 == s, trp2 / 2, trp2)); 
	}
}

mixin template M16_S_X86_64()
{
	enum size_t broadcast = 6;
	alias simdChain = AliasSeq!(__vector(float[4])[2], __vector(float[4])[1], float[2], float[1]);
}

mixin template M16_D_X86_64()
{
	pragma(msg, "M16_D_X86_64");
	enum size_t broadcast = 6;
	alias simdChain = AliasSeq!(__vector(double[2])[2], __vector(double[2])[1], double[1]);
}

mixin template M16_C_X86_64()
{
	enum size_t broadcast = 2;
	alias simdChain = AliasSeq!(__vector(float[4])[2], __vector(float[4])[1], float[2], float[1]);
}

mixin template M16_Z_X86_64()
{
	enum size_t broadcast = 2;
	alias simdChain = AliasSeq!(__vector(double[2])[2], __vector(double[2])[1], double[1]);
}

mixin template M16()
{
	static if(PR == 1)
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
	static if(PR == 1)
		alias simdChain = AliasSeq!(T[2], T[1]);
	else
		alias simdChain = AliasSeq!(T[1]);
}

mixin template M4()
{
	enum size_t broadcast = 1;
	static if(PR == 1)
		alias simdChain = AliasSeq!(T[2], T[1]);
	else
		alias simdChain = AliasSeq!(T[1]);
}

mixin template M1()
{
	enum size_t broadcast = 1;
	alias simdChain = AliasSeq!(T[1]);
}
