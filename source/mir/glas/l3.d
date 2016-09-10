/++
$(H2 Level 3)

$(SCRIPT inhibitQuickIndex = 1;)

This is a submodule of $(LINK2 mir_glas.html, mir.glas).

Level 3 GLAS perform matrix-matrix operations.

$(BOOKTABLE $(H2 Matrix-matrix operations),

$(TR $(TH Function Name) $(TH Description))
$(T2 gemm, general matrix-matrix multiplication)
$(T2 symm, symmetric or hermitian matrix-matrix multiplication)

)

License: $(LINK2 http://boost.org/LICENSE_1_0.txt, Boost License 1.0).

Authors: Ilya Yaroshenko

Macros:
T2=$(TR $(TDNW $(LREF $1)) $(TD $+))
SUBMODULE = $(LINK2 mir_glas_$1.html, mir.glas.$1)
SUBREF = $(LINK2 mir_glas_$1.html#.$2, $(TT $2))$(NBSP)
+/
module mir.glas.l3;
public import mir.glas.common;

import std.traits;
import std.meta;
import std.complex: Complex;
import mir.ndslice.slice;
import mir.internal.utility;

/++
Performs general matrix-matrix multiplication.

Pseudo_code: `C := alpha A × B + beta C`.

Params:
    ctx = GLAS context. Should not be accessed by other threads.
    alpha = scalar
    asl = `m x k` matrix
    bsl = `k x n` matrix
    beta = scalar. When  `beta`  is supplied as zero then the matrix `csl` need not be set on input.
    csl = `m x n` matrix with one stride equal to `±1`.
    conja = specifies if the matrix `asl` stores conjugated elements.
    conjb = specifies if the matrix `bsl` stores conjugated elements.

Note:
    GLAS does not require transposition parameters.
    Use $(LINK2 mir_ndslice_iteration.html#transposed, mir.ndslice.iteration.transposed)
    to perform zero cost `Slice` transposition.

BLAS: SGEMM, DGEMM, CGEMM, ZGEMM

See_also: $(SUBREF common, Conjugated).
+/
pragma(inline, true)
nothrow @nogc
void gemm(A, B, C)
(
    GlasContext* ctx,
    C alpha,
        Slice!(2, A*) asl,
        Slice!(2, B*) bsl,
    C beta,
        Slice!(2, C*) csl,
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
    mixin prefix3;
    import mir.glas.internal.gemm: gemm_impl;
    gemm_impl(
        ctx,
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

    auto c = slice!double([3, 4], 0);

    auto glas = new GlasContext;
    glas.gemm(1.0, a, b, 1.0, c);

    assert(c ==
        [[-42.0,  35,  -7, 77],
         [-69.0, -21, -42, 21],
         [ 23.0,  69,   3, 29]]);
}

/++
Performs symmetric or hermitian matrix-matrix multiplication.

Pseudo_code: `C := alpha A × B + beta C` or `C := alpha B × A + beta C`,
    where  `alpha` and `beta` are scalars, `A` is a symmetric or hermitian matrix and `B` and
    `C` are `m × n` matrices.

Params:
    ctx = GLAS context. Should not be accessed by other threads.
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
    asl = `k x k` matrix, where `k` is `m`  when  `side` equals to 'Side.left'
           and is `n` otherwise.
    bsl = `m x n` matrix
    beta = scalar. When  `beta`  is supplied as zero then the matrix `csl` need not be set on input.
    csl = `m x n` matrix with one stride equals to `±1`.
    conja = specifies whether the matrix A is symmetric (`Conjugated.no`) or hermitian (`Conjugated.yes`).
    conjb = specifies if the matrix `bsl` stores conjugated elements.

Note:
    GLAS does not require transposition parameters.
    Use $(LINK2 mir_ndslice_iteration.html#transposed, mir.ndslice.iteration.transposed)
    to perform zero cost `Slice` transposition.

BLAS: SSYMM, DSYMM, CSYMM, ZSYMM, SHEMM, DHEMM, CHEMM, ZHEMM

See_also: $(SUBREF common, Conjugated), $(SUBREF common, Side), $(SUBREF common, Uplo).
+/
pragma(inline, true)
nothrow @nogc
void symm(A, B, C)
(
    GlasContext* ctx,
    Side side,
    Uplo uplo,
    C alpha,
        Slice!(2, A*) asl,
        Slice!(2, B*) bsl,
    C beta,
        Slice!(2, C*) csl,
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
    mixin prefix3;

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
        ctx,
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

    auto glas = new GlasContext;
    glas.symm(Side.left, Uplo.lower, 1.0, a, b, 0.0, c);

    assert(c ==
        [[ 38,  23,  20,   2],
         [-27, -20, -17, -21],
         [ 24,  12, -18, -18]]);
}

/// Hermitian matrix
unittest
{
    import mir.ndslice;
    import std.complex;
    alias cd = Complex!double;

    auto a = slice!cd(3, 3);
    a[] =
        [[cd(-2, 0),   cd.init,   cd.init],
         [cd(+3, 2), cd(-5, 0),   cd.init],
         [cd(-4, 7), cd(-2, 3), cd(-3, 0)]];

    auto b = slice!cd(3, 4);
    b[] =
        [[cd(-5, 3), cd(-3, 9), cd( 3, 2), cd(1, 2)],
         [cd( 4, 5), cd( 3, 4), cd( 6, 5), cd(4, 9)],
         [cd(-4, 2), cd(-2, 2), cd(-2, 7), cd(2, 6)]];

    auto c = slice!cd(3, 4);
    auto d = slice!cd(3, 4);

    auto glas = new GlasContext;

    glas.symm(Side.left, Uplo.lower, cd(1.0), a, b, cd(0.0), c, Conjugated.yes);

    ndEach!((ref a, ref b){a = conj(b);}, Select.triangular)(a, a.transposed);
    glas.gemm(cd(1.0), a, b, cd(0.0), d);

    assert(c == d);
}
