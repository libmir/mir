/++
$(SCRIPT inhibitQuickIndex = 1;)

This is a submodule of $(LINK2 mir_ndslice.html, mir.ndslice).

License: $(LINK2 http://boost.org/LICENSE_1_0.txt, Boost License 1.0).

Authors: Ilya Yaroshenko
+/
module mir.glas.trsm;

import std.typecons: Flag;
import std.traits;
import mir.internal.utility;
import mir.glas.common;

@fastmath:

package:

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
    const(F[P][M])* b,
    size_t length,
)
    if (is(V == F) || isSIMDVector!V)
{
    V[N][P][M] reg = void;
    reg.load(c);
    reg.scale_nano_kernel(alpha),
    ab = gemm_nano_kernel!(Multiplication.sub)(reg, a, b, length);
    trsm_nano_kernel!(P, M, N, V, F)(reg, * cast(F[P][M][M]*) ab[1]);
    c.load(reg);
}

//llvmAttr("unsafe-fp-math", "true")
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
    ref F[P][M][M] a,
)
    if (is(V == F) || isSIMDVector!V)
{
    V[N][P][M] reg = void;
    reg.load(b);
    foreach (m; Iota!M)
    {
        foreach (i; Iota!m)
        {
            V[P] s = void;

            foreach (p; Iota!P)
                s[p].load(a[i][m][p]);

            foreach (n; Iota!N)
            {
                static if (P == 1)
                {
                    reg[m][0][n] -= s[0] * reg[i][0][n];
                }
                else
                {
                    reg[m][0][n] -= s[0] * reg[i][0][n];
                    reg[m][0][n] -= s[1] * reg[i][1][n];
                    reg[m][1][n] += s[0] * reg[i][1][n];
                    reg[m][1][n] -= s[1] * reg[i][0][n];
                }
            }
        }

        V[P] s = void;
        foreach (p; Iota!P)
            s[p].load(a[m][m][p]);

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
    }
    b.load(reg);
}
