module mir.sparse.blas.axpy;

import std.traits;
import mir.ndslice.slice;
import mir.sparse.sparse;

/++
Params:
	x = sparse vector
	y = dense vector
	alpha = scalar
Returns:
	`y = alpha * x + y`
+/
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

	import mir.sparse.blas.internal;
	static if(isSimpleSlice!V2)
	{
		if(y.stride == 1)
		{
			axpy(alpha, x, y.toDense);
			return;
		}
	}

	foreach(size_t i; 0 .. x.indexes.length)
	{
		y[x.indexes[i]] += alpha * x.values[i];
	}
}

///
unittest
{
	auto x = CompressedArray!(double, uint)([1.0, 3, 4, 9, 13], [0, 3, 5, 9, 10]);
	auto y = [0.0, 1.0, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12];
	axpy(2.0, x, y);
	assert(y == [2.0, 1.0, 2, 9, 4, 13, 6, 7, 8, 27, 36, 11, 12]);
}

unittest
{
	auto x = CompressedArray!(double, uint)([1.0, 3, 4, 9, 13], [0, 3, 5, 9, 10]);
	auto y = [0.0, 1.0, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12];
	axpy(2.0, x, y.sliced);
	assert(y == [2.0, 1.0, 2, 9, 4, 13, 6, 7, 8, 27, 36, 11, 12]);
}

unittest
{
	import std.typecons: No;
	auto x = CompressedArray!(double, uint)([1.0, 3, 4, 9, 13], [0, 3, 5, 9, 10]);
	auto y = [0.0, 1.0, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12];
	axpy(2.0, x, y.sliced!(No.replaceArrayWithPointer));
	assert(y == [2.0, 1.0, 2, 9, 4, 13, 6, 7, 8, 27, 36, 11, 12]);
}
