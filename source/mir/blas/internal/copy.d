module blas.internal.copy;

import mir.ndslice.slice;
import mir.internal.utility;

//template gepb_opt2(size_t[])


template pack_matrix(sizes...)
{
	void pack_matrix(T, Range)(Slice!(2, Range) from, T* to)
	{
		while(from.length >= sizes[0])
		{
			to = pack_panel_generic(from[0 .. sizes[0]], to);
			from.popFrontExacly(sizes[0]);
		}
		foreach(size; sizes[1..$])
		{
			if(from.length >= size)
			{
				to = pack_panel_generic(from[0 .. size], to);
				from.popFrontExacly(size);
			}
		}
		assert(from.empty);
	}
}

T* pack_panel_generic(T, Range)(Slice!(2, Range) from, T* to)
in
{
	assert(from.length >= size);
}
body
{
	import mir.ndslice.iteration: transposed;

	static if (isComplex!(DeepElementType!(Slice!(2, Range))))
	{
		auto re = to;
		auto im = to + from.length;
		immutable shift = from.length << 1;
		foreach(col; from.transposed)
		{
			foreach(i; 0..col.length)
			{
				auto elem = col.front;
				re[i] = cast(T) elem.re;
				im[i] = cast(T) elem.im;
				col.popFront;
			}
			to += shift;
			im += shift;
		}
	}
	else
	{
		foreach(col; from.transposed)
		{
			foreach(i; 0..col.length)
			{
				to[i] = cast(T) col.front;
				col.popFront;
			}
			to += from.length;
		}
	}
}

T* save_block_generic(T, Range)(T* from, Slice!(2, Range) to)
{
	static if (isComplex!(DeepElementType!(Slice!(2, Range))))
	{
		auto re = to;
		auto im = to + from.length!1;
		immutable shift = from.length!1 << 1;
		foreach(row; from)
		{
			foreach(i; 0..row.length)
			{
				row.front = typeof(row.front)(re[i], im[i]);
				row.popFront;
			}
			to += shift;
			im += shift;
		}
	}
	else
	{
		foreach(row; from)
		{
			foreach(i; 0..row.length)
			{
				row.front = cast(typeof(row.front)) from[i];
				row.popFront;
			}
			to += from.length!1;
		}
	}
}
