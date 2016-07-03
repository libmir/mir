module mir.blas.internal.micro_kernel;

import std.typecons: Flag;
import std.traits;
import mir.internal.utility;
import mir.blas.internal.utility;
import mir.blas.internal.config;

@fastmath:


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



pragma(inline, false)
void gemm_micro_kernel (
    Conj conj,
    size_t P,
    size_t N,
    size_t M,
    V,
    F,
)
(
    ref V[N][P][M] c,
    scope const(V[N][P])* a,
    scope const(F[M][P])* b,
    size_t length,
)
    if (is(V == F) || isSIMDVector!V)
{
    V[N][P][M] reg = void;
    reg.set_zero;
    gemm_micro_kernel_impl!conj(reg, a, b, length);
    c.load(reg);
}

pragma(inline, true)
void gemm_micro_kernel_impl (
    Conj conj,
    size_t P,
    size_t N,
    size_t M,
    V,
    F,
)
(
    ref V[N][P][M] c,
    scope const(V[N][P])* a,
    scope const(F[M][P])* b,
    size_t length,
)
    if (is(V == F) || isSIMDVector!V)
{
    pragma(inline, true);
    enum msg = "Wrong kernel compile time arguments.";
    static assert(conj == Conj.none && P == 1 || conj != Conj.none && P == 2, msg);

    V[N][P][M] reg = void;
    reg.load(c);

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

    c.load(reg);
}

pragma(inline, true)
void gemm_micro_kernel_scale (
    size_t P,
    size_t M,
    size_t N,
    V,
    F,
)
(
    F[P] alpha,
    ref V[N][P][M] c,
    scope const(V[N][P])* a,
    scope const(F[M][P])* b,
    size_t length,
)
{
    V[N][P][M] reg = void;
    reg.load(c);

    V[P] s = void;
    s.load(a);

    foreach (m; Iota!M)
    foreach (n; Iota!N)
    {
        static if (P == 1)
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


pragma(inline, true)
void trsm_micro_kernel_impl (
    size_t P,
    size_t M,
    size_t N,
    V,
    F,
)
(
    ref F[M][P][M] a,
    ref V[N][P][M] b,
    size_t length,
)
    if (is(V == F) || isSIMDVector!V)
{
    V[N][P][M] reg = void;
    reg.load(b);
    foreach(m; Iota!M)
    {
        foreach(i; Iota!m)
        {
            V[P] s = void;

            foreach(p; Iota!P)
                s[p].load(a[i][p][m]);

            foreach(n; Iota!N)
            {
                static if (P == 1)
                {
                    reg[m][0][n] -= s[0] * reg[i][0][n];
                }
                else
                {
                    reg[m][0][n] -= s[0] * reg[i][0][n];
                    reg[m][1][n] += s[0] * reg[i][1][n];
                    reg[m][0][n] -= s[1] * reg[i][1][n];
                    reg[m][1][n] -= s[1] * reg[i][0][n];
                }
            }
        }

        V[P] s = void;
        foreach(p; Iota!P)
            s[p].load(a[m][p][m]);

        foreach(n; Iota!N)
        {
            static if(P == 1)
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
    }
    b.load(reg);
}

alias  trsm_mecro_kernel_inst = trsm_micro_kernel_impl!(1, 4, 4, __vector(double[4]), double);
alias  gemm_mecro_kernel_inst = gemm_micro_kernel_impl!(Conj.none, 1, 2, 4, __vector(double[4]), double);

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
