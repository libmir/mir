module mir.blas.generic.gemm;

import mir.internal.utility;

import std.typecons: Flag;

enum Conj
{
	none,
	complexNone,
	complexA,
	complexB,
}

void gemmMicroKernel(
	Conj conj,
	Flag!"add" add,
	size_t P,
	size_t N,
	size_t M,
	V,
	F
)(
	in size_t kc,
	size_t blocks,
	scope const(V[P][N])* a,
	scope const(F[P][M])* b,
	scope V[P][N][M]* c,
	)
{
	pragma(inline, false);
	enum msg = "Wrong kernel compile time arguments.";
	static assert(conj == Conj.none && P == 1 || conj != Conj.none && P == 2, msg);
	do
	{
		V[P][N][M] reg = void;
		foreach(m; Iota!(0, M))
		foreach(n; Iota!(0, N))
		foreach(p; Iota!(0, P))
			static if(add)
				reg[m][n][p] = c[0][m][n][p];
			else
				reg[m][n][p] = 0;
		size_t i = kc;
		do
		{
			V[P][N] ai = void;
			V[P][M] bi = void;
			foreach(n; Iota!(0, N))
			foreach(p; Iota!(0, P))
				ai[n][p] = a[0][n][p];
			foreach(m; Iota!(0, M))
			foreach(p; Iota!(0, P))
				bi[m][p] = b[0][m][p];
			a++;
			b++;
			foreach(m; Iota!(0, M))
			foreach(n; Iota!(0, N))
			{
				reg[m][n][0] += ai[n][0] * bi[m][0];
				static if(conj == Conj.complexNone)
				{
					reg[m][n][1] += ai[n][0] * bi[m][1];
					reg[m][n][0] -= ai[n][1] * bi[m][1];
					reg[m][n][1] += ai[n][1] * bi[m][0];
				}
				else static if(conj == Conj.complexA)
				{
					reg[m][n][1] += ai[n][0] * bi[m][1];
					reg[m][n][0] += ai[n][1] * bi[m][1];
					reg[m][n][1] -= ai[n][1] * bi[m][0];
				}
				else static if(conj == Conj.complexB)
				{
					reg[m][n][1] -= ai[n][0] * bi[m][1];
					reg[m][n][0] += ai[n][1] * bi[m][1];
					reg[m][n][1] += ai[n][1] * bi[m][0];
				}
				else static assert(conj == Conj.none, msg);
			}
		}
		while(--i);
		b -= kc;
		foreach(m; Iota!(0, M))
		foreach(n; Iota!(0, N))
		foreach(p; Iota!(0, P))
			c[0][m][n][p] = reg[m][n][p];
		c++;
	}
	while(--blocks);
}
