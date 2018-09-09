/++
$(H2 Level 2)

$(SCRIPT inhibitQuickIndex = 1;)

This is a submodule of $(MREF mir,glas).

The Level 2 BLAS perform matrix-vector operations.

Note: GLAS is singe thread for now.

$(BOOKTABLE $(H2 Matrix-vector operations),

$(TR $(TH Function Name) $(TH Description))
$(T2 gemv, general matrix-vector multiplication, $(RED partially optimized))
)

License:   $(HTTP boost.org/LICENSE_1_0.txt, Boost License 1.0).
Copyright: Copyright © 2016-, Ilya Yaroshenko
Authors:   Ilya Yaroshenko

Macros:
T2=$(TR $(TDNW $(LREF $1)) $(TD $+))
SUBMODULE = $(MREF_ALTTEXT $1, mir, glas, $1)
SUBREF = $(REF_ALTTEXT $(TT $2), $2, mir, glas, $1)$(NBSP)
NDSLICEREF = $(REF_ALTTEXT $(TT $2), $2, mir, ndslice, $1)$(NBSP)
+/
module mir.glas.l2;

import std.traits;
import std.meta;

import mir.math.common;
import mir.internal.utility;
import mir.ndslice.slice;

import mir.glas.l1;

import mir.math.common: fastmath;

@fastmath:

/++
$(RED DRAFT)
Performs general matrix-vector multiplication.

Pseudo_code: `y := alpha A × x + beta y`.

Params:
    alpha = scalar
    asl = `m ⨉ n` matrix
    xsl = `n ⨉ 1` vector
    beta = scalar. When  `beta`  is supplied as zero then the vector `ysl` need not be set on input.
    ysl = `m ⨉ 1` vector
    conja = specifies if the matrix `asl` stores conjugated elements.

Note:
    GLAS does not require transposition parameters.
    Use $(NDSLICEREF iteration, transposed)
    to perform zero cost `Slice` transposition.

BLAS: SGEMV, DGEMV, (CGEMV, ZGEMV are not implemented for now)
+/
nothrow @nogc @system
void gemv(A, B, C,
    SliceKind kindA,
    SliceKind kindB,
    SliceKind kindC,
    )
(
    C alpha,
        Slice!(const(A)*,  2, kindA) asl,
        Slice!(const(B)*,  1, kindB) xsl,
    C beta,
        Slice!(C*,  1, kindC) ysl,
)
    if (allSatisfy!(isNumeric, A, B, C))
in
{
    assert(asl.length!0 == ysl.length, "constraint: asl.length!0 == ysl.length");
    assert(asl.length!1 == xsl.length, "constraint: asl.length!1 == xsl.length");
}
body
{
    import mir.ndslice.dynamic: reversed;
    static assert(is(Unqual!C == C), msgWrongType);
    if (ysl.empty)
        return;
    if (beta == 0)
    {
        ysl[] = 0;
    }
    else
    if (beta == 1)
    {
        ysl[] *= beta;
    }
    if (xsl.empty)
        return;
    do
    {
        ysl.front += alpha * dot(asl.front, xsl);
        asl.popFront;
        ysl.popFront;
    }
    while (ysl.length);
}

///
unittest
{
    import mir.ndslice;

    auto a = slice!double(3, 5);
    a[] =
        [[-5,  1,  7, 7, -4],
         [-1, -5,  6, 3, -3],
         [-5, -2, -3, 6,  0]];

    auto b = slice!double(5);
    b[] =
        [-5.0,
          4.0,
         -4.0,
         -1.0,
          9.0];

    auto c = slice!double(3);

    gemv!(double, double, double)(1.0, a, b, 0.0, c);

    assert(c ==
        [-42.0,
         -69.0,
          23.0]);
}
