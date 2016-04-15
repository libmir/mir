module mir.las.sparse;

import std.traits;
import mir.ndslice.slice;
import mir.ndslice.sparse;

Unqual!(CommonType!(T1, T2)) dot(V1 : CompressedArray!(T1, I1), V2 : CompressedArray!(T2, I2), T1, T2, I1, I2)(V1 a, V2 b)
{
	typeof(return) s = 0;

	uint done = 2;
	Unqual!I1 ai0 = void;
	Unqual!I2 bi0 = void;
	if(a.indexes.length && b.indexes.length) for (;;)
	{
		bi0 = b.indexes[0];
		if (a.indexes[0] < bi0)
		{
		    do {
		        a.values = a.values[1 .. $];
		        a.indexes = a.indexes[1 .. $];
		        if (a.indexes.length == 0)
		        	break;
		    }
		    while(a.indexes[0] < bi0);
		    done = 2;
		}
		if (--done == 0) goto L;
		ai0 = a.indexes[0];
		if (b.indexes[0] < ai0)
		{
		    do {
		        b.values = b.values[1 .. $];
		        b.indexes = b.indexes[1 .. $];
		        if (b.indexes.length == 0)
		        	break;
		    }
		    while(b.indexes[0] < ai0);
		    done = 2;
		}
		if (--done == 0) goto L;
		continue;
		L:
		s += a.values[0] * b.values[0];
		a.indexes = a.indexes[1 .. $];
		if(a.indexes.length == 0)
			break;
        b.indexes = b.indexes[1 .. $];
		if(b.indexes.length == 0)
			break;
        a.values = a.values[1 .. $];
        b.values = b.values[1 .. $];
	}
	return s;
}

unittest
{
	auto a = CompressedArray!(int, uint)([1, 3, 4, 9, 10],       [0, 3, 5, 9, 100]);
	auto b = CompressedArray!(int, uint)([1, 10, 100, 1000], [1, 3, 4, 9]);
	assert(dot(a, b) == 9030);
}

Unqual!(CommonType!(T1, T2)) dot(S1 : CompressedArray!(T1, I1), S2 : T2[], T1, T2, I1)(S1 a, S2 b)
{
	typeof(return) s0 = 0;
	typeof(return) s1 = 0;
	typeof(return) s2 = 0;
	typeof(return) s3 = 0;

	size_t p = b.indexes.length & ~size_t(0xF);
	for(size_t i = 0; i < p; p += 0x10)
	{
		auto j0 = b.indexes[i + 0x0];
		auto j1 = b.indexes[i + 0x1];
		auto j2 = b.indexes[i + 0x2];
		auto j3 = b.indexes[i + 0x3];
		s0 += a[j0] * b.values[i + 0x0];
		s1 += a[j1] * b.values[i + 0x1];
		s2 += a[j2] * b.values[i + 0x2];
		s3 += a[j3] * b.values[i + 0x3];

		auto j4 = b.indexes[i + 0x4];
		auto j5 = b.indexes[i + 0x5];
		auto j6 = b.indexes[i + 0x6];
		auto j7 = b.indexes[i + 0x7];
		s0 += a[j4] * b.values[i + 0x4];
		s1 += a[j5] * b.values[i + 0x5];
		s2 += a[j6] * b.values[i + 0x6];
		s3 += a[j7] * b.values[i + 0x7];

		auto j8 = b.indexes[i + 0x8];
		auto j9 = b.indexes[i + 0x9];
		auto jA = b.indexes[i + 0xA];
		auto jB = b.indexes[i + 0xB];
		s0 += a[j8] * b.values[i + 0x8];
		s1 += a[j9] * b.values[i + 0x9];
		s2 += a[jA] * b.values[i + 0xA];
		s3 += a[jB] * b.values[i + 0xB];

		auto jC = b.indexes[i + 0xC];
		auto jD = b.indexes[i + 0xD];
		auto jE = b.indexes[i + 0xE];
		auto jF = b.indexes[i + 0xF];
		s0 += a[jC] * b.values[i + 0xC];
		s1 += a[jD] * b.values[i + 0xD];
		s2 += a[jE] * b.values[i + 0xE];
		s3 += a[jF] * b.values[i + 0xF];
	}

	p = b.indexes.length & ~size_t(0x3);
	for(size_t i = 0; i < p; p += 0x4)
	{
		auto j0 = b.indexes[i + 0x0];
		auto j1 = b.indexes[i + 0x1];
		auto j2 = b.indexes[i + 0x2];
		auto j3 = b.indexes[i + 0x3];
		s0 += a[j0] * b.values[i + 0x0];
		s1 += a[j1] * b.values[i + 0x1];
		s2 += a[j2] * b.values[i + 0x2];
		s3 += a[j3] * b.values[i + 0x3];
	}

	p = b.indexes.length;
	for(size_t i = 0; i < p; p += 0x1)
	{
		auto j0 = b.indexes[i + 0x0];
		auto j1 = b.indexes[i + 0x1];
		auto j2 = b.indexes[i + 0x2];
		auto j3 = b.indexes[i + 0x3];
		s0 += a[j0] * b.values[i + 0x0];
		s1 += a[j1] * b.values[i + 0x1];
		s2 += a[j2] * b.values[i + 0x2];
		s3 += a[j3] * b.values[i + 0x3];
	}

	s0 += s2;
	s1 += s3;
	s0 += s1;

	return s0;
}

unittest
{
}


Unqual!(CommonType!(T1, T2)) dot(S1 : CompressedArray!(T1, I1), S2 : T2[], T1, T2, I1)(S2 a, S1 b)
{
	return .dot(b, a);
}

unittest
{
}
