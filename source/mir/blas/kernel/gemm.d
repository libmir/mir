/++
$(General Matrix Multiplication Micro Kernel)
+/
module mir.blas.generic.gemm;

import std.typecons: Flag;
import mir.internal.utility;

/// Conjunctions type.
enum Conj
{
    /// For real numbers
    none,
    /// `c = a b`
    complexNone,
    /// `c = a' b`
    complexA,
    /// `c = a b'`
    complexB,
    ///`c = (a b)'`
    complexC,
}

/++
General matrix multiplication micro kernel.

Params:
    conj = indicates type of multiplication for complex numbers
    add = indicates type of assignment for `c`:
        `c += Ab` if flag is set and `c = Ab` otherwise.
    P = number of components in type: 1 for reals and 2 for complex
    N = number of registers for each row in a register matrix
    M = number of rows in a register matrix
    V = numeric or vector type
    F = numeric type
    columns = number of columns
    rows = number of rows
    a = kernel matrix composed of register vectors
    b = input vector composed of register vectors
    c = output vector composed of register matrices
+/
void gemmMicroKernel(
    Conj conj,
    Flag!"add" add,
    size_t P,
    size_t N,
    size_t M,
    V,
    F
)(
    in size_t columns,
    size_t rows,
    scope const(V[P][N])* a,
    scope const(F[P][M])* b,
    scope V[P][N][M]* c,
    )
in
{
    assert(columns);
    assert(rows);
}
body
{
    pragma(inline, false);
    enum msg = "Wrong kernel compile time arguments.";
    static assert(conj == Conj.none && P == 1 || conj != Conj.none && P == 2, msg);
    do
    {
        V[P][N][M] reg = void;
        foreach (m; Iota!(0, M))
        foreach (n; Iota!(0, N))
        foreach (p; Iota!(0, P))
            static if (add)
                reg[m][n][p] = c[0][m][n][p];
            else
                reg[m][n][p] = 0;
        size_t i = columns;
        do
        {
            V[P][N] ai = void;
            V[P][M] bi = void;
            foreach (n; Iota!(0, N))
            foreach (p; Iota!(0, P))
                ai[n][p] = a[0][n][p];
            foreach (m; Iota!(0, M))
            foreach (p; Iota!(0, P))
                bi[m][p] = b[0][m][p];
            a++;
            b++;
            foreach (m; Iota!(0, M))
            foreach (n; Iota!(0, N))
            {
                reg[m][n][0] += ai[n][0] * bi[m][0];
                static if (conj == Conj.complexNone)
                {
                    reg[m][n][1] += ai[n][0] * bi[m][1];
                    reg[m][n][0] -= ai[n][1] * bi[m][1];
                    reg[m][n][1] += ai[n][1] * bi[m][0];
                }
                else static if (conj == Conj.complexA)
                {
                    reg[m][n][1] += ai[n][0] * bi[m][1];
                    reg[m][n][0] += ai[n][1] * bi[m][1];
                    reg[m][n][1] -= ai[n][1] * bi[m][0];
                }
                else static if (conj == Conj.complexB)
                {
                    reg[m][n][1] -= ai[n][0] * bi[m][1];
                    reg[m][n][0] += ai[n][1] * bi[m][1];
                    reg[m][n][1] += ai[n][1] * bi[m][0];
                }
                else static if (conj == Conj.complexC)
                {
                    reg[m][n][1] -= ai[n][0] * bi[m][1];
                    reg[m][n][0] -= ai[n][1] * bi[m][1];
                    reg[m][n][1] -= ai[n][1] * bi[m][0];
                }
                else static assert(conj == Conj.none, msg);
            }
        }
        while (--i);
        b -= columns;
        foreach (m; Iota!(0, M))
        foreach (n; Iota!(0, N))
        foreach (p; Iota!(0, P))
            c[0][m][n][p] = reg[m][n][p];
        c++;
    }
    while (--rows);
}

unittest
{
    import std.meta: AliasSeq;
    import std.typecons: Yes, No;
    with(Conj)
    foreach(conj; AliasSeq!(none, complexNone, complexA, complexB))
    foreach(add; AliasSeq!(No.add, Yes.add))
    {
        enum P = conj == none ? 1 : 2;
        {alias temp = gemmMicroKernel!(conj, add, P, 2 / P, 4 / P, float, float);}
        {alias temp = gemmMicroKernel!(conj, add, P, 2 / P, 4 / P, double, double);}
        version(LDC)
        {
            {alias temp = gemmMicroKernel!(conj, add, P, 2 / P, 4 / P, __vector(float[8]), float);}
            {alias temp = gemmMicroKernel!(conj, add, P, 2 / P, 4 / P, __vector(double[4]), double);}
        }
    }
}
