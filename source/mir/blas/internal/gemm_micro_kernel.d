/++
$(General Matrix Multiplication Micro Kernel)
+/
module mir.blas.internal.gemm_micro_kernel;

import std.typecons: Flag;
import std.traits;
import mir.internal.utility;
import mir.blas.internal.utility;

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
+/
void gemm_micro_kernel (
    Conj conj,
    size_t P,
    size_t M,
    size_t N,
    V,
    F,
)
(
    ref V[N][P][M] c,
    F[P] alpha,
    scope const(V[N][P])* a,
    scope const(F[M][P])* b,
    size_t length,
)
    if (is(V == F) || is(V == __vector(F[L]), size_t L))
in
{
    assert(length);
}
body
{
    pragma(inline, true);
    enum msg = "Wrong kernel compile time arguments.";
    static assert(conj == Conj.none && P == 1 || conj != Conj.none && P == 2, msg);

    V[N][P][M] reg = void;

    foreach(size_t i; 0 .. length)
    {
        V[N][P] ai = void;
        V[M][P] bi = void;

        ai.load(a[i]);
        bi.load(b[i]);

        foreach (m; Iota!M)
        foreach (n; Iota!N)
        {
            static if (conj == Conj.none)
            {
                reg[m][0][n] += ai[0][n] * bi[0][m];
            }
            else static if (conj == Conj.complexNone)
            {
                reg[m][0][n] += ai[0][n] * bi[0][m];
                reg[m][1][n] += ai[0][n] * bi[1][m];
                reg[m][0][n] -= ai[1][n] * bi[1][m];
                reg[m][1][n] += ai[1][n] * bi[0][m];
            }
            else static if (conj == Conj.complexA)
            {
                reg[m][0][n] += ai[0][n] * bi[0][m];
                reg[m][1][n] += ai[0][n] * bi[1][m];
                reg[m][0][n] += ai[1][n] * bi[1][m];
                reg[m][1][n] -= ai[1][n] * bi[0][m];
            }
            else static if (conj == Conj.complexB)
            {
                reg[m][0][n] += ai[0][n] * bi[0][m];
                reg[m][1][n] -= ai[0][n] * bi[1][m];
                reg[m][0][n] += ai[1][n] * bi[1][m];
                reg[m][1][n] += ai[1][n] * bi[0][m];
            }
            else static if (conj == Conj.complexC)
            {
                reg[m][0][n] += ai[0][n] * bi[0][m];
                reg[m][1][n] -= ai[0][n] * bi[1][m];
                reg[m][0][n] -= ai[1][n] * bi[1][m];
                reg[m][1][n] -= ai[1][n] * bi[0][m];
            }
            else static assert(0);
        }
    }

    V[P] s = void;
    s.load(alpha);

    foreach (m; Iota!M)
    foreach (n; Iota!N)
    {
        static if (conj == Conj.none)
        {
            reg[m][0][n] *= s[0];
        }
        else
        {
            auto re = s[0] * reg[m][0][n];
            auto im = s[0] * reg[m][1][n];
            re -= s[1] * reg[m][1][n];
            im += s[1] * reg[m][0][n];
            reg[m][0][n] = re;
            reg[m][1][n] = im;
        }
    }

    c.load(reg);
}

unittest
{
    import std.meta: AliasSeq;
    with(Conj)
    foreach (conj; AliasSeq!(none, complexNone, complexA, complexB))
    {
        enum P = conj == none ? 1 : 2;
        {alias temp = gemm_micro_kernel!(conj, P, 2 / P, 4 / P, float, float);}
        {alias temp = gemm_micro_kernel!(conj, P, 2 / P, 4 / P, double, double);}
        version(X86_64)
        {
            {alias temp = gemm_micro_kernel!(conj, P, 2 / P, 4 / P, __vector(float[4]), float);}
            {alias temp = gemm_micro_kernel!(conj, P, 2 / P, 4 / P, __vector(double[2]), double);}
        }
        version(LDC)
        {
            {alias temp = gemm_micro_kernel!(conj, P, 2 / P, 4 / P, __vector(float[8]), float);}
            {alias temp = gemm_micro_kernel!(conj, P, 2 / P, 4 / P, __vector(double[4]), double);}
        }
    }
}
