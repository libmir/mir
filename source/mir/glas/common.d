/++
$(H2 General Matrix-Vector Multiplication)

$(SCRIPT inhibitQuickIndex = 1;)

This is a submodule of $(LINK2 mir_glas.html, mir.glas).

License: $(LINK2 http://boost.org/LICENSE_1_0.txt, Boost License 1.0).

Authors: Ilya Yaroshenko
+/
module mir.glas.common;

/// Conjugation type
enum Conjugation
{
    /// Pseudo code for `gemm` is `c[i, j] += a[i, k] * b[k, j]`
    none,
    /// Pseudo code for `gemm` is `c[i, j] -= a[i, k] * b[k, j]`, for internal use only
    sub,
    /// Pseudo code for `gemm` is `c[i, j] += conj(a[i, k]) * b[k, j]`
    conjA,
    /// Pseudo code for `gemm` is `c[i, j] += a[i, k] * conj(b[k, j])`
    conjB,
    /// Pseudo code for `gemm` is `c[i, j] += conj(a[i, k] * b[k, j])`
    conjC,
}

/++
Convenient template to swap complex conjugation.
Params:
    type = type of Multiplication
    option1 = first type of conjugation, optional
    option2 = second type of conjugation, optional
+/
template swapConj(Conjugation type, Conjugation option1 = conjA, Conjugation option2 = conjB)
{
    static if (type == option1)
        alias swapConj = option2;
    else
    static if (type == option2)
        alias swapConj = option1;
    else
        alias swapConj = type;
}

///
unittest
{
    static assert(swapConj!conjN == conjN);
    static assert(swapConj!conjA == conjB);
    static assert(swapConj!conjB == conjA);

    static assert(swapConj!(conjN, conjB, conjC) == conjN);
    static assert(swapConj!(conjB, conjB, conjC) == conjC);
    static assert(swapConj!(conjC, conjB, conjC) == conjB);
}

/// Shortcuts for `$(MREF Conjugation.conjA)`
alias conjN = Conjugation.none;
/// Shortcuts for `$(MREF Conjugation.conjA)`
alias conjA = Conjugation.conjA;
/// Shortcuts for `$(MREF Conjugation.conjB)`
alias conjB = Conjugation.conjB;
/// Shortcuts for `$(MREF Conjugation.conjC)`
alias conjC = Conjugation.conjC;
