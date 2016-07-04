module mir.blas.internal.micro_kernel;

import std.typecons: Flag;
import std.traits;
import mir.internal.utility;
import mir.blas.internal.utility;
import mir.blas.internal.config;

@fastmath:


/// Typeunctions type.
enum MulType
{
    /// For real numbers
    none,
    /// `c -= a b`
    sub,
    /// `c += a' b`
    conjA,
    /// `c += a b'`
    conjB,
    ///`c += (a b)'`
    conjC,
}



pragma(inline, false)
void gemm_micro_kernel (
    MulType type,
    size_t P,
    size_t N,
    size_t M,
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
    if (is(V == F) || isSIMDVector!V)
{
    V[N][P][M] reg = void;
    reg.set_zero;
    gemm_nano_kernel!type(reg, a, b, length);
    reg.scale_nano _kernel(alpha);
    c.load(reg);
}

pragma(inline, false)
void trsm_micro_kernel (
    size_t P,
    size_t N,
    size_t M,
    V,
    F,
)
(
    F[P] alpha,
    ref V[N][P][M] c,
    scope const(V[N][P])* a,
    const(F[M][P])* b,
    size_t length,
)
    if (is(V == F) || isSIMDVector!V)
{
    V[N][P][M] reg = void;
    reg.load(c);
    reg.scale_nano_kernel(alpha),
    b = gemm_nano_kernel!(MulType.sub)(reg, a, b, length);
    trsm_nano_kernel!(P, M, N, V, F)(reg, * cast(F[M][P][M]*) b);
    c.load(reg);
}

pragma(inline, true)
const(F[M][P])* gemm_nano_kernel (
    MulType type,
    bool sub = false,
    size_t P,
    size_t N,
    size_t M,
    V,
    F,
)
(
    ref V[N][P][M] c,
    scope const(V[N][P])* a,
    const(F[M][P])* b,
    size_t length,
)
    if (is(V == F) || isSIMDVector!V)
{
    pragma(inline, true);
    enum msg = "Wrong kernel compile time arguments.";
    //static assert(type == MulType.none && P == 1 || type != MulType.none && P == 2, msg);

    V[N][P][M] reg = void;
    reg.load(c);

    do
    {
        V[N][P] ai = void;
        V[M][P] bi = void;

        ai.load(*a++);
        bi.load(*b++);

        foreach (m; Iota!M)
        foreach (n; Iota!N)
        {
            static if (type == MulType.none)
            {
                static if(P == 1)
                {
                    reg[m][0][n] += ai[0][n] * bi[0][m];
                }
                else
                {
                    reg[m][0][n] += ai[0][n] * bi[0][m];
                    reg[m][1][n] += ai[0][n] * bi[1][m];
                    reg[m][0][n] -= ai[1][n] * bi[1][m];
                    reg[m][1][n] += ai[1][n] * bi[0][m];
                }
            }
            else static if (type == MulType.sub)
            {
                static if(P == 1)
                {
                    reg[m][0][n] -= ai[0][n] * bi[0][m];
                }
                else
                {
                    reg[m][0][n] -= ai[0][n] * bi[0][m];
                    reg[m][1][n] -= ai[0][n] * bi[1][m];
                    reg[m][0][n] += ai[1][n] * bi[1][m];
                    reg[m][1][n] -= ai[1][n] * bi[0][m];
                }
            }
            else static if (type == MulType.conjA)
            {
                reg[m][0][n] += ai[0][n] * bi[0][m];
                reg[m][1][n] += ai[0][n] * bi[1][m];
                reg[m][0][n] += ai[1][n] * bi[1][m];
                reg[m][1][n] -= ai[1][n] * bi[0][m];
            }
            else static if (type == MulType.conjB)
            {
                reg[m][0][n] += ai[0][n] * bi[0][m];
                reg[m][1][n] -= ai[0][n] * bi[1][m];
                reg[m][0][n] += ai[1][n] * bi[1][m];
                reg[m][1][n] += ai[1][n] * bi[0][m];
            }
            else static if (type == MulType.conjC)
            {
                reg[m][0][n] += ai[0][n] * bi[0][m];
                reg[m][1][n] -= ai[0][n] * bi[1][m];
                reg[m][0][n] -= ai[1][n] * bi[1][m];
                reg[m][1][n] -= ai[1][n] * bi[0][m];
            }
            else static assert(0);
        }
    }
    while(--length);

    c.load(reg);
    return b;
}

pragma(inline, true)
void scale_nano_kernel (
    size_t P,
    size_t M,
    size_t N,
    V,
    F,
)
(
    ref V[N][P][M] c,
    F[P] alpha,
)
{
    V[N][P][M] reg = void;
    reg.load(c);

    V[P] s = void;
    s.load(alpha);

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
void trsm_nano_kernel (
    size_t P,
    size_t M,
    size_t N,
    V,
    F,
)
(
    ref V[N][P][M] b,
    ref F[M][P][M] a,
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

alias  trsm_mecro_kernel_inst = trsm_micro_kernel!(2, 1, 2, __vector(float[2]), float);
//alias  gemm_mecro_kernel_inst = gemm_micro_kernel!(Type.none, 1, 2, 6, __vector(double[4]), double);
//alias  gemm_mecro_kernel_inst = gemm_micro_kernel!(MulType.none, 1, 2, 6, __vector(float[8]), float);

unittest
{
    import std.meta: AliasSeq;
    with(MulType)
    foreach (type; AliasSeq!(none, conjA, conjB))
    {
        enum P = type == none ? 1 : 2;
        {alias temp = gemm_micro_kernel!(type, P, 2 / P, 4 / P, float, float);}
        {alias temp = gemm_micro_kernel!(type, P, 2 / P, 4 / P, double, double);}
        version(X86_64)
        {
            {alias temp = gemm_micro_kernel!(type, P, 2 / P, 4 / P, __vector(float[4]), float);}
            {alias temp = gemm_micro_kernel!(type, P, 2 / P, 4 / P, __vector(double[2]), double);}
        }
        version(LDC)
        {
            {alias temp = gemm_micro_kernel!(type, P, 2 / P, 4 / P, __vector(float[8]), float);}
            {alias temp = gemm_micro_kernel!(type, P, 2 / P, 4 / P, __vector(double[4]), double);}
        }
    }
}
