module blas.internal.copy;

import mir.ndslice.slice;
import mir.internal.utility;

template pack_matrix(size_t[] sizes)
{
	void pack_matrix(T, Range)(Slice!(2, Range) from, T* to)
	{
		while(from.length >= sizes[0])
		{
			to = pack_panel_generic(from[0 .. sizes[0]], to);
			from.popFrontExacly(sizes[0]);
		}
		foreach(i; Iota(1, sizes.length))
		{
			if(from.length >= size)
			{
				to = pack_panel_generic(from[0 .. sizes[i]], to);
				from.popFrontExacly(sizes[i]);
			}
		}
		assert(from.empty);
	}
}

T* pack_panel_generic(T, Range)(Slice!(2, Range) from, T* to)
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

/++
T* unpack_panel_generic(T, Range)(T* from, Slice!(2, Range) to)
{
	static if (isComplex!(DeepElementType!(Slice!(2, Range))))
	{
		auto re = from;
		auto im = from + from.length!1;
		immutable shift = from.length!1 << 1;
		foreach(row; tp)
		{
			foreach(i; 0..row.length)
			{
				row.front = typeof(row.front)(re[i], im[i]);
				row.popFront;
			}
			re += shift;
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
			from += from.length!1;
		}
	}
}

T* unpack_panel_generic(T, Range)(const(T)* from, Slice!(2, Range) to, Complex!T beta)
{
	auto from_re = from;
	auto from_im = from + from.length!1;
	immutable shift = from.length!1 << 1;
	foreach(row; tp)
	{
		foreach(i; 0..row.length)
		{
			row.front = typeof(row.front)(Complex!T(from_re[i], from_im[i]) + beta * cast(Complex!T) row.front);
			row.popFront;
		}
		from_re += shift;
		from_im += shift;
	}
}

T* unpack_panel_generic(T, Range)(T* from, Slice!(2, Range) to, T beta)
{
	foreach(row; from)
	{
		foreach(i; 0..row.length)
		{
			row.front = cast(typeof(row.front)) (from[i] + beta * cast(T) row.front);
			row.popFront;
		}
		from += from.length!1;
	}
}
+/