/++
$(SCRIPT inhibitQuickIndex = 1;)

This is a submodule of $(LINK2 mir_ndslice.html, mir.ndslice).

License: $(LINK2 http://boost.org/LICENSE_1_0.txt, Boost License 1.0).

Authors: Ilya Yaroshenko
+/
module mir.glas.trsm;

import std.traits;
import std.meta;

import mir.internal.utility;
import mir.glas.common;
import mir.glas.gemm;

@fastmath:

package:

pragma(inline, false)
void trsm_micro_kernel (
    size_t PA,
    size_t PB,
    size_t N,
    size_t M,
    V,
    F,
)
(
    F[P] alpha,
    ref V[N][PA][M] c,
    scope const(V[N][PA])* a,
    const(F[PB][M])* b,
    size_t length,
)
    if (is(V == F) || isSIMDVector!V)
{
    version(LDC) pragma(inline, true);
    V[N][PA][M] reg = void;
    foreach (m; Iota!M)
    foreach (p; Iota!PB)
    foreach (n; Iota!N)
        reg[m][p][n] = c[m][p][n];
    reg.scale_nano_kernel(alpha);
    auto ab = gemm_nano_kernel!(Multiplication.sub)(reg, a, b, length);
    trsm_nano_kernel!(PA, PB, M, N, V, F)(reg, *cast(F[P][M][M]*) ab[1]);
    foreach (m; Iota!M)
    foreach (p; Iota!PB)
    foreach (n; Iota!N)
        c[m][p][n] = reg[m][p][n];
}

//alias rrr= trsm_nano_kernel!(1, 1, 3, 4, double, double);
//llvmAttr("unsafe-fp-math", "true")
pragma(inline, true)
void trsm_nano_kernel (
    Conjugation type,
    Uplo uplo,
    bool unit,
    size_t PA,
    size_t PB,
    size_t M,
    size_t N,
    F,
)
(
    ref F[N][PA][N] a,
    ref F[PB][M][N] b,
)
     if (type == conjN || type == conjA)
{
    enum AA = PA == 2;
    enum AB = PA == 2 && AA;
    F[N][PB][M] reg = void;
    foreach (n; Iota!N)
    foreach (m; Iota!M)
    foreach (p; Iota!PB)
        reg[n][m][p] = b[n][m][p];
    foreach (n; Select!(uplo == Uplo.lower, Iota!N, Reverse!(Iota!N)))
    {
        foreach (i; Select!(uplo == Uplo.lower, Iota!n, Iota!(n + 1, N)))
        {
            F[PA] s = void;
            foreach (p; Iota!PB)
                s[p] = a[n][p][i];
            foreach (m; Iota!M)
            {
                    reg[n][m][0]  -= s[0] * reg[i][m][0];
     static if (AB) reg[n][m][1]  -= s[0] * reg[i][m][1];
                static if (type == conjN)
                {
     static if (AA) reg[n][m][0]  += s[1] * reg[i][m][1];
     static if (AB) reg[n][m][1]  -= s[1] * reg[i][m][0];
                }
                else
                {
     static if (AA) reg[n][m][0]  -= s[1] * reg[i][m][1];
     static if (AB) reg[n][m][1]  += s[1] * reg[i][m][0];
                }
            }
        }
        static if (!unit)
        {
            F[PA] s = void;
            foreach (p; Iota!PB)
                s[p] = a[n][p][n];
            foreach (n; Iota!N)
            {
                auto re  = s[0] * reg[n][m][0];
 static if (AA) auto im  = s[0] * reg[n][m][1];
                static if (type == conjN)
                {
 static if (AB)      re -= s[1] * reg[n][m][1];
 static if (AB)      im += s[1] * reg[n][m][0];
                }
                else
                {
 static if (AB)      re += s[1] * reg[n][m][1];
 static if (AB)      im -= s[1] * reg[n][m][0];
                }
                reg[n][m][0] = re;
 static if (AA) reg[n][m][1] = im;
            }
        }
    }
    foreach (n; Iota!N)
    foreach (m; Iota!M)
    foreach (p; Iota!PB)
        b[n][m][p] = reg[n][m][p];
}
