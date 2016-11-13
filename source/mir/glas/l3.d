/++
$(H2 Level 3)

$(SCRIPT inhibitQuickIndex = 1;)

This is a submodule of $(MREF mir,glas).

The Level 3 GLAS perform matrix-matrix operations.

Note: GLAS is singe thread for now.

$(BOOKTABLE $(H2 Matrix-matrix operations),

$(TR $(TH Function Name) $(TH Description))
$(T2 gemm, general matrix-matrix multiplication)
$(T2 symm, symmetric or hermitian matrix-matrix multiplication)

)

License: $(LINK2 http://boost.org/LICENSE_1_0.txt, Boost License 1.0).

Authors: Ilya Yaroshenko

Macros:
T2=$(TR $(TDNW $(LREF $1)) $(TD $+))
SUBMODULE = $(MREF_ALTTEXT $1, mir, glas, $1)
SUBREF = $(REF_ALTTEXT $(TT $2), $2, mir, glas, $1)$(NBSP)
NDSLICEREF = $(REF_ALTTEXT $(TT $2), $2, mir, ndslice, $1)$(NBSP)
+/
module mir.glas.l3;
public import mir.glas.common;

import std.traits;
import std.meta;
import mir.ndslice.slice;
import mir.internal.utility;

import ldc.attributes : fastmath;
@fastmath:

/++
Performs general matrix-matrix multiplication.

Pseudo_code: `C := alpha A × B + beta C`.

Params:
    alpha = scalar
    asl = `m ⨉ k` matrix
    bsl = `k ⨉ n` matrix
    beta = scalar. When  `beta`  is supplied as zero then the matrix `csl` need not be set on input.
    csl = `m ⨉ n` matrix with one stride equal to `±1`.
    conja = specifies if the matrix `asl` stores conjugated elements.
    conjb = specifies if the matrix `bsl` stores conjugated elements.

Note:
    GLAS does not require transposition parameters.
    Use $(NDSLICEREF iteration, transposed)
    to perform zero cost `Slice` transposition.

BLAS: SGEMM, DGEMM, CGEMM, ZGEMM

See_also: $(SUBREF common, Conjugated).
+/
deprecated("use mir-glas package instead")
pragma(inline, true)
nothrow @nogc
void gemm(A, B, C)
(
    C alpha,
        Slice!(2, const(A)*) asl,
        Slice!(2, const(B)*) bsl,
    C beta,
        Slice!(2, C*)        csl,
    Conjugated conja = Conjugated.no,
    Conjugated conjb = Conjugated.no,
)
in
{
    assert(asl.length!1 == bsl.length!0, "constraint: asl.length!1 == bsl.length!0");
    assert(csl.length!0 == asl.length!0, "constraint: csl.length!0 == asl.length!0");
    assert(csl.length!1 == bsl.length!1, "constraint: csl.length!1 == bsl.length!1");
    assert(csl.stride!0 == +1
        || csl.stride!0 == -1
        || csl.stride!1 == +1
        || csl.stride!1 == -1, "constraint: csl.stride!0 or csl.stride!1 must be equal to +/-1");
}
body
{
    static assert(is(Unqual!C == C), msgWrongType);
    import mir.glas.internal.gemm: gemm_impl;
    gemm_impl(
        alpha,
            cast(Slice!(2, Unqual!A*)) asl,
            cast(Slice!(2, Unqual!B*)) bsl,
        beta,
                                       csl,
        conja,
        conjb,
        );
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

    auto b = slice!double(5, 4);
    b[] =
        [[-5.0, -3,  3,  1],
         [ 4.0,  3,  6,  4],
         [-4.0, -2, -2,  2],
         [-1.0,  9,  4,  8],
         [  9.0, 8,  3, -2]];

    auto c = slice!double(3, 4);

    gemm(1.0, a, b, 0.0, c);

    assert(c ==
        [[-42.0,  35,  -7, 77],
         [-69.0, -21, -42, 21],
         [ 23.0,  69,   3, 29]]);
}

unittest
{
    auto a = slice!double(3, 0);
    auto b = slice!double(0, 4);
    auto c = slice!double(3, 4);

    gemm(1.0, a, b, 0.0, c);

    assert(c ==
        [[0.0, 0, 0, 0],
         [0.0, 0, 0, 0],
         [0.0, 0, 0, 0]]);

    c[] = 2;
    gemm(1.0, a, b, 2, c);

    assert(c ==
        [[4.0, 4, 4, 4],
         [4.0, 4, 4, 4],
         [4.0, 4, 4, 4]]);
}

/++
Performs symmetric or hermitian matrix-matrix multiplication.

Pseudo_code: `C := alpha A × B + beta C` or `C := alpha B × A + beta C`,
    where  `alpha` and `beta` are scalars, `A` is a symmetric or hermitian matrix and `B` and
    `C` are `m × n` matrices.

Params:
    side = specifies whether the symmetric matrix A
           appears on the  left or right  in the  operation.
    uplo = specifies  whether  the  upper  or  lower triangular
           part of the symmetric matrix A is to be referenced.
           When `uplo` equals to `Uplo.upper`, the upper triangular
           part of the matrix `asl`  must contain the upper triangular part
           of the symmetric / hermitian matrix A and the strictly lower triangular
           part of `asl` is not referenced, and when `uplo` equals to `Uplo.lower`,
           the lower triangular part of the matrix `asl`
           must contain the lower triangular part of the symmetric / hermitian
           matrix A and the strictly upper triangular part of `asl` is not
           referenced.
    alpha = scalar
    asl = `k ⨉ k` matrix, where `k` is `m`  when  `side` equals to 'Side.left'
           and is `n` otherwise.
    bsl = `m ⨉ n` matrix
    beta = scalar. When  `beta`  is supplied as zero then the matrix `csl` need not be set on input.
    csl = `m ⨉ n` matrix with one stride equals to `±1`.
    conja = specifies whether the matrix A is symmetric (`Conjugated.no`) or hermitian (`Conjugated.yes`).
    conjb = specifies if the matrix `bsl` stores conjugated elements.

Note:
    GLAS does not require transposition parameters.
    Use $(NDSLICEREF iteration, transposed)
    to perform zero cost `Slice` transposition.

BLAS: SSYMM, DSYMM, CSYMM, ZSYMM, SHEMM, DHEMM, CHEMM, ZHEMM

See_also: $(SUBREF common, Conjugated), $(SUBREF common, Side), $(SUBREF common, Uplo).
+/
deprecated("use mir-glas package instead")
pragma(inline, true)
nothrow @nogc
void symm(A, B, C)
(
    Side side,
    Uplo uplo,
    C alpha,
        Slice!(2, const(A)*) asl,
        Slice!(2, const(B)*) bsl,
    C beta,
        Slice!(2, C*)        csl,
    Conjugated conja = Conjugated.no,
    Conjugated conjb = Conjugated.no,
)
in
{
    assert(asl.length!0 == asl.length!1, "constraint: asl.length!0 == asl.length!1");
    assert(asl.length!1 == bsl.length!0, "constraint: asl.length!1 == bsl.length!0");
    assert(csl.length!0 == asl.length!0, "constraint: csl.length!0 == asl.length!0");
    assert(csl.length!1 == bsl.length!1, "constraint: csl.length!1 == bsl.length!1");
    assert(csl.stride!0 == +1
        || csl.stride!0 == -1
        || csl.stride!1 == +1
        || csl.stride!1 == -1, "constraint: csl.stride!0 or csl.stride!1 must be equal to +/-1");
}
body
{
    static assert(is(Unqual!C == C), msgWrongType);

    import mir.ndslice.iteration : transposed;
    if (side == Side.right)
    {
        asl = asl.transposed;
        bsl = bsl.transposed;
        csl = csl.transposed;
    }
    if (uplo == Uplo.upper)
    {
        asl = asl.transposed;
    }

    import mir.glas.internal.symm: symm_impl;
    symm_impl(
        alpha,
            cast(Slice!(2, Unqual!A*)) asl,
            cast(Slice!(2, Unqual!B*)) bsl,
        beta,
                                       csl,
        conja,
        conjb,
        );
}

/// Symmetric matrix
unittest
{
    import mir.ndslice;

    auto a = slice!double(3, 3);
    a[] =
        [[-2.0, double.init, double.init],
         [+3.0,         -5, double.init],
         [-4.0,         -2,         -3]];

    auto b = slice!double(3, 4);
    b[] =
        [[-5, -3,  3, 1],
         [ 4,  3,  6, 4],
         [-4, -2, -2, 2]];

    auto c = slice!double(3, 4);

    symm(Side.left, Uplo.lower, 1.0, a, b, 0.0, c);

    assert(c ==
        [[ 38,  23,  20,   2],
         [-27, -20, -17, -21],
         [ 24,  12, -18, -18]]);
}

/// Hermitian matrix
unittest
{
    import mir.ndslice;

    auto a = slice!cdouble(3, 3);
    a[] =
        [[-2 + 0i, cdouble.init, cdouble.init],
         [+3 + 2i, -5 + 0i, cdouble.init],
         [-4 + 7i, -2 + 3i, -3 + 0i]];

    auto b = slice!cdouble(3, 4);
    b[] =
        [[-5 + 3i, -3 + 9i,  3 + 2i, 1 + 2i],
         [ 4 + 5i,  3 + 4i,  6 + 5i, 4 + 9i],
         [-4 + 2i, -2 + 2i, -2 + 7i, 2 + 6i]];

    auto c = slice!cdouble(3, 4);
    auto d = slice!cdouble(3, 4);

    symm(Side.left, Uplo.lower, 1 + 0i, a, b, 0 + 0i, c, Conjugated.yes);

    ndEach!((ref a, ref b){a = (b.re - b.im * 1fi);}, Select.triangular)(a, a.transposed);
    gemm(1 + 0i, a, b, 0 + 0i, d);

    assert(c == d);
}

unittest
{
    auto a = slice!double(3, 3);
    auto b = slice!double(3, 4);
    auto c = slice!double(3, 4);

    symm(Side.left, Uplo.lower, 0.0, a, b, 0.0, c);

    assert(c ==
        [[0.0, 0, 0, 0],
         [0.0, 0, 0, 0],
         [0.0, 0, 0, 0]]);

    c[] = 2;
    symm(Side.left, Uplo.upper, 0.0, a, b, 2, c);

    assert(c ==
        [[4.0, 4, 4, 4],
         [4.0, 4, 4, 4],
         [4.0, 4, 4, 4]]);
}
