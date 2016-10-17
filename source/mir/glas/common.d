/++
$(SCRIPT inhibitQuickIndex = 1;)

This is a submodule of $(MREF mir,glas).

License: $(LINK2 http://boost.org/LICENSE_1_0.txt, Boost License 1.0).

Authors: Ilya Yaroshenko
+/
module mir.glas.common;

/++
Uplo specifies whether a matrix is an upper or lower triangular matrix.
+/
enum Uplo
{
    /// upper triangular matrix.
    lower,
    /// lower triangular matrix
    upper,
}

/++
Convenient template to invert $(LREF Uplo) flag.
Params:
    type = type of matrix (upper or lower)
    option1 = first type of conjugation, optional
    option2 = second type of conjugation, optional
+/
template swapUplo(Uplo type)
{
    static if (type == Uplo.lower)
        alias swapUplo = Uplo.upper;
    else
        alias swapUplo = Uplo.lower;
}

///
unittest
{
    static assert(swapUplo!(Uplo.upper) == Uplo.lower);
    static assert(swapUplo!(Uplo.lower) == Uplo.upper);
}

/++
Convenient function to invert $(LREF Uplo) flag.
Params:
    type = type of matrix (upper or lower)
    option1 = first type of conjugation, optional
    option2 = second type of conjugation, optional
+/
Uplo swapUplo(Uplo type)
{
    if (type == Uplo.lower)
        return Uplo.upper;
    else
        return Uplo.lower;
}

///
unittest
{
    assert(swapUplo(Uplo.upper) == Uplo.lower);
    assert(swapUplo(Uplo.lower) == Uplo.upper);
}

/++
Diag specifies whether or not a matrix is unitriangular.
+/
enum Diag
{
    /// a matrix assumed to be unit triangular
    unit,
    /// a matrix not assumed to be unit triangular
    nounit,
}

/++
On entry, `Side`  specifies whether  the  symmetric matrix  A
appears on the  left or right.
+/
enum Side
{
    ///
    left,
    ///
    right,
}

///
enum Conjugated
{
    ///
    no,
    ///
    yes,
}

package mixin template prefix3()
{
    enum CA = isComplex!A && (isComplex!C || isComplex!B);
    enum CB = isComplex!B && (isComplex!C || isComplex!A);
    enum CC = isComplex!C;

    enum PA = CA ? 2 : 1;
    enum PB = CB ? 2 : 1;
    enum PC = CC ? 2 : 1;

    alias T = realType!C;
    static assert(!isComplex!T);
}

package enum msgWrongType = "result slice must be not qualified (const/immutable/shared)";
