module mir.sparse.blas.dot;

import std.traits;
import mir.ndslice.slice;
import mir.sparse;


/++
Params:
	x = sparse vector
	y = sparse vector
Returns:
	scalar `x × y`
+/
Unqual!(CommonType!(T1, T2)) dot(
	V1 : CompressedArray!(T1, I1),
	V2 : CompressedArray!(T2, I2),
	T1, T2, I1, I2)
(V1 x, V2 y)
{
	return dot!(typeof(return))(x, y);
}

/// ditto
D dot(
	D,
	V1 : CompressedArray!(T1, I1),
	V2 : CompressedArray!(T2, I2),
	T1, T2, I1, I2)
(V1 x, V2 y)
{
	pragma(inline, false);

	typeof(return) s = 0;

	uint done = 2;
	Unqual!I1 ai0 = void;
	Unqual!I2 bi0 = void;

	if(x.indexes.length && y.indexes.length) for (;;)
	{
		bi0 = y.indexes[0];
		if (x.indexes[0] < bi0)
		{
			do
			{
				x.values = x.values[1 .. $];
				x.indexes = x.indexes[1 .. $];
				if (x.indexes.length == 0)
				{
					break;
				}
			}
			while(x.indexes[0] < bi0);
			done = 2;
		}
		if (--done == 0)
		{
			goto L;
		}
		ai0 = x.indexes[0];
		if (y.indexes[0] < ai0)
		{
			do
			{
				y.values = y.values[1 .. $];
				y.indexes = y.indexes[1 .. $];
				if (y.indexes.length == 0)
				{
					break;
				}
			}
			while(y.indexes[0] < ai0);
			done = 2;
		}
		if (--done == 0)
		{
			goto L;
		}
		continue;
		L:
		s += D(x.values[0]) * D(y.values[0]);
		x.indexes = x.indexes[1 .. $];
		if(x.indexes.length == 0)
		{
			break;
		}
		y.indexes = y.indexes[1 .. $];
		if(y.indexes.length == 0)
		{
			break;
		}
		x.values = x.values[1 .. $];
		y.values = y.values[1 .. $];
	}

	return s;
}

///
unittest
{
	auto x = CompressedArray!(int, uint)([1, 3, 4, 9, 10], [0, 3, 5, 9, 100]);
	auto y = CompressedArray!(int, uint)([1, 10, 100, 1000], [1, 3, 4, 9]);
	assert(dot(x, y) == 9030);
	assert(dot!double(x, y) == 9030);
}

/++
Params:
	x = sparse vector
	y = dense vector
Returns:
	scalar `x × y`
+/
Unqual!(CommonType!(T1, ForeachType!V2)) dot(
	V1 : CompressedArray!(T1, I1),
	T1, I1, V2)
(V1 x, V2 y)
	if (isDynamicArray!V2 || is(V2 : Slice!(1, V2R), V2R))
{
	return dot!(typeof(return))(x, y);
}

///ditto
D dot(
	D,
	V1 : CompressedArray!(T1, I1),
	T1, I1, V2)
(V1 x, V2 y)
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
			return dot(x, y.toDense);
		}
	}

	alias T2 = ForeachType!V2;

	Unqual!(CommonType!(T1, T2)) s = 0;

	foreach(size_t i; 0 .. x.indexes.length)
	{
		s += y[x.indexes[i]] * x.values[i];
	}

	return s;
}

///
unittest
{
	import std.typecons: No;
	auto x = CompressedArray!(double, uint)([1.0, 3, 4, 9, 13], [0, 3, 5, 9, 10]);
	auto y = [0.0, 1.0, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12];
	auto r = 0 + 3 * 3 + 5 * 4 + 9 * 9 + 10 * 13;
	assert(dot(x, y) == r);
	assert(dot(x, y.sliced) == r);
	assert(dot(x, y.sliced!(No.replaceArrayWithPointer)) == r);
}

