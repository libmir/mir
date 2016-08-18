/++
$(H2 General Matrix-Vector Multiplication)

$(SCRIPT inhibitQuickIndex = 1;)

This is a submodule of $(LINK2 mir_glas.html, mir.glas).

License: $(LINK2 http://boost.org/LICENSE_1_0.txt, Boost License 1.0).

Authors: Ilya Yaroshenko
+/
module mir.glas.common;

/++
Returns a lazily initialized global instantiation of $(LREF GlasContext).
This function can safely be called concurrently from multiple non-worker
threads.
+/
@property GlasContext glas() @trusted
{
    __gshared GlasContext ctx;
    import std.concurrency : initOnce;
    return initOnce!ctx(new GlasContext);
}

/++
GLAS Context

Note: `GlasContext` is single thread for now.
+/
final class GlasContext
{
    import std.experimental.allocator.mallocator;
    import mir.glas.internal.context;
    static import cpuid.unified;
    import core.sync.mutex;

    private
    {
        Mutex _mutex;
        void[] _memory;
        uint _threads;
        uint _cache1Size;
        uint _cache2Size;
        uint _cacheLine;
    }

    nothrow @nogc
    this(
        Mutex mutex = new Mutex,
        uint threads = 1, //cpuid.unified.threads,
        uint cache1Size = defaultCache1Size(),
        uint cache2Size = defaultCache2Size(),
        uint cacheLine = defaultCacheLine(),
        )
    {
        assert(threads, "Threads count must not be null.");
        _threads = threads;
        _cache1Size = cache1Size << 10;
        _cache2Size = cache2Size << 10;
        _cacheLine = cacheLine;
        _memory = AlignedMallocator.instance.alignedAllocate(_cache2Size << 1, 4096);
    }

    nothrow @nogc
    ~this()
    {
        AlignedMallocator.instance.deallocate(_memory);
    }


    /// Returns: reused unaligned memory chunk
    nothrow @nogc
    void[] memory(size_t size)
    {
        if (_memory.length < size)
        {
            auto f = _memory.length << 1;
            if (f > size)
                size = f;
            AlignedMallocator.instance.deallocate(_memory);
            _memory = AlignedMallocator.instance.alignedAllocate(size, 4096);
        }
        return _memory[0 .. size];
    }

@safe pure nothrow @nogc:

    /// Returns the mutex for this context.
    Mutex mutex() { return _mutex; }
    ///  Thread count
    uint threads() { return _threads; }
    /// Context's level 1 cache size in KB
    uint cache1Size() { return _cache1Size; }
    /// Context's level 2 or Level 3 cache size in KB
    uint cache2Size() { return _cache2Size; }
    /// Context's cache line size
    uint cacheLine() { return _cacheLine; }

    static:

    /// Default level 1 cache size in KB
    uint defaultCache1Size() { return c1.size; }
    /// Default level 2 or Level 3 cache size in KB
    uint defaultCache2Size() { return c2.size; }
    /// Default cache line size
    uint defaultCacheLine() { return c1.line; }
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
    For internal use only.

    Pseudo code for `gemm` is `c[i, j] -= a[i, k] * b[k, j]`, for internal use only.
    +/
    sub,
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
