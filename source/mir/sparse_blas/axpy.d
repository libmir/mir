module mir.sparse_blas.axpy;

import std.traits;
import mir.ndslice.slice;
import mir.ndslice.sparse;

void axpy(
	CR,
	V1 : CompressedArray!(T1, I1),
	T1, I1, V2)
(in CR alpha, V1 x, V2 y)
	if (isDynamicArray!V2 || is(V2 : Slice!(1, V2R), V2R))
in
{
	if(x.indexes.length)
		assert(x.indexes[$-1] < y.length);
}
body
{
	pragma(inline, false);

	//alias T2 = ForeachType!V2;
	//alias T = Unqual!(CommonType!(T1, T2));

	foreach(size_t i; 0 .. x.indexes.length)
	{
		y[x.indexes[i]] += alpha * x.values[i];
	}
}

unittest
{
	auto x = CompressedArray!(double, uint)([1.0, 3, 4, 9, 13], [0, 3, 5, 9, 10]);
	auto y = [0.0, 1.0, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12];
	axpy(2.0, x, y);
	assert(y == [2.0, 1.0, 2, 9, 4, 13, 6, 7, 8, 27, 36, 11, 12]);
}
