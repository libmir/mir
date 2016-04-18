module mir.sparse.blas.gemm;

import std.traits;
import mir.ndslice.slice;
import mir.sparse.sparse;

/++
Params:
	a = sparse matrix (CSR format)
	b = dense matrix
	c = dense matrix
	alpha = scalar
	beta = scalar
Returns:
	`y = alpha * a × b + beta * y` if beta does not equal null and `y = alpha * a × b` otherwise.
+/
void gemm(
	CR,
	CL,
	M1 : Slice!(1, V1),
		V1 : CompressedMap!(T1, I1, J1),
			T1, I1, J1,
	M2 : Slice!(2, V2R), V2R,
	M3 : Slice!(2, V3R), V3R)
(in CR alpha, M1 a, M2 b, in CL beta, M3 c)
in
{
	assert(a.length!0 == c.length!0);
	assert(b.length!1 == c.length!1);
}
body
{
	import mir.ndslice.iteration: transposed;
	b = b.transposed;
	c = c.transposed;
	foreach(x; b)
	{
		import mir.sparse.blas.gemv: gemv;
		gemv(alpha, a, x, beta, c.front);
		c.popFront;
	}
}

///
unittest
{
	auto sp = sparse!int(3, 5);
	sp[] =
		[[-5, 1, 7, 7, -4],
		 [-1, -5, 6, 3, -3],
		 [-5, -2, -3, 6, 0]];

	auto a = sp.compress;

	auto b = slice!double(5, 4);
	b[] =
		[[-5.0, -3, 3, 1],
		 [4.0, 3, 6, 4],
		 [-4.0, -2, -2, 2],
		 [-1.0, 9, 4, 8],
		 [9.0, 8, 3, -2]];

	auto c = slice!double(3, 4);

	gemm(1.0, a, b, 0, c);

	assert(c ==
		[[-42.0, 35, -7, 77],
		 [-69.0, -21, -42, 21],
		 [23.0, 69, 3, 29]]);
}


/++
Params:
	a = sparse matrix (CSR format)
	b = dense matrix
	c = dense matrix
	alpha = scalar
	beta = scalar
Returns:
	`y = alpha * aᵀ × b + beta * y` if beta does not equal null and `y = alpha * aᵀ × b` otherwise.
+/
void gemtm(
	CR,
	CL,
	M1 : Slice!(1, V1),
		V1 : CompressedMap!(T1, I1, J1),
			T1, I1, J1,
	M2 : Slice!(2, V2R), V2R,
	M3 : Slice!(2, V3R), V3R)
(in CR alpha, M1 a, M2 b, in CL beta, M3 c)
in
{
	assert(a.length!0 == b.length!0);
	assert(b.length!1 == c.length!1);
}
body
{
	import mir.ndslice.iteration: transposed;
	b = b.transposed;
	c = c.transposed;
	foreach(x; b)
	{
		import mir.sparse.blas.gemv: gemtv;
		gemtv(alpha, a, x, beta, c.front);
		c.popFront;
	}
}


///
unittest
{
	auto sp = sparse!int(5, 3);
	sp[] =
		[[-5, -1, -5],
		 [1, -5, -2],
		 [7, 6, -3],
		 [7, 3, 6],
		 [-4, -3, 0]];

	auto a = sp.compress;

	auto b = slice!double(5, 4);
	b[] =
		[[-5.0, -3, 3, 1],
		 [4.0, 3, 6, 4],
		 [-4.0, -2, -2, 2],
		 [-1.0, 9, 4, 8],
		 [9.0, 8, 3, -2]];

	auto c = slice!double(3, 4);

	gemtm(1.0, a, b, 0, c);

	assert(c ==
		[[-42.0, 35, -7, 77],
		 [-69.0, -21, -42, 21],
		 [23.0, 69, 3, 29]]);
}
