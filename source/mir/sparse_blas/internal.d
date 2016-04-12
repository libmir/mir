module mir.sparse_blas.internal;

import std.traits;
import mir.ndslice.slice;

package:

enum isSimpleSlice(S) = is(S : Slice!(N1, T1[]), size_t N1,T1) || is(S : Slice!(N2, T2*), size_t N2,T2);


auto toDense(R)(Slice!(1, R) x)
{
	assert(x.stride == 1);
	auto ptr = x.ptr;
	static if(isPointer!R)
	{
		return ptr[0 .. x.length];
	}
	else
	{
		return ptr.range[ptr.shift .. x.length + ptr.shift];
	}
}
