/++
$(SCRIPT inhibitQuickIndex = 1;)

This is a submodule of $(LINK2 mir_glas.html, mir.glas).

License: $(LINK2 http://boost.org/LICENSE_1_0.txt, Boost License 1.0).

Authors: Ilya Yaroshenko
+/
module mir.glas.common;

/++
GLAS Context

Note: `GlasContext` is single thread for now.
+/
struct GlasContext
{
    import mir.internal.memory;
    import mir.glas.internal.context;
    static import cpuid.unified;
    import core.sync.mutex;

    private
    {
        void[] _memory;
    }

nothrow @nogc:

    ~this()
    {
        release;
    }

    /// Returns: reused unaligned memory chunk
    nothrow @nogc void[] memory(size_t size)
    {
        if (_memory.length < size)
        {
            auto f = _memory.length << 1;
            if (f > size)
                size = f;
            if(_memory !is null)
                deallocate(_memory);
            _memory = alignedAllocate(size, 4096);
        }
        return _memory[0 .. size];
    }

    /// Releases memory.
    void release()
    {
        if(_memory !is null)
            deallocate(_memory);
    }
}

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
Diag specifies whether or not a matrix is unitriangular.
+/
enum Diag
{
    /// a matrix assumed to be unit triangular
    unit,
    /// a matrix not assumed to be unit triangular
    nounit,
}

/// Default conjugation type
enum Conjugation
{
    /++
    No conjugation.

    Pseudo code for `gemm` is `c[i, j] += a[i, k] * b[k, j]`.
    +/
    none,
    /++
    A is conjugated.

    Pseudo code for `gemm` is `c[i, j] += conj(a[i, k]) * b[k, j]`.
    +/
    conjA,
    /++
    B is conjugated.

    Pseudo code for `gemm` is `c[i, j] += a[i, k] * conj(b[k, j])`.
    +/
    conjB,
    /++
    Product is conjugated.

    Pseudo code for `gemm` is `c[i, j] += conj(a[i, k] * b[k, j])`.
    +/
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
