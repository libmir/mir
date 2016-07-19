/**
Non-uniform distributions.

License: $(LINK2 http://boost.org/LICENSE_1_0.txt, Boost License 1.0).

Authors: Sebastian Wilzbach
*/

module mir.random.nonuniform;

import std.traits : isNumeric;
import std.stdio;

/**
Setup a _normal distribution sampler.

Params:
    T = floating-point type that should be sampled
    R = unsigned UIntType of the random generator

Returns:
    A $(LREF Ziggurat) sampler that can be called to sample from the distribution.
*/
auto normal(T, R = uint)()
{
    import mir.internal.math : exp, log, sqrt;

    auto pdf    = (T x) => cast(T) exp(T(-0.5) * x * x);
    auto invPdf = (T x) => cast(T) sqrt(T(-2) * log(x));

    // values from [Marsaglia00]
    T rightEnd = 3.442619855899;

    /// generate x for the last block (aka tail-block)
    enum fallback = q{
        T fallback(RNG)(bool isPositive, ref RNG gen) const
        {
            import std.random : uniform;
            import std.math : log;
            T x, y, u;
            do
            {
                u = uniform!("[]", T, T)(0, 1, gen);
                x = -log(u) / fs[$ - 1];
                u = uniform!("[]", T, T)(0, 1, gen);
                y = -log(u);
            }
            while(y + y < x * x);
            return isPositive ? rightEnd + x : -rightEnd - x;
        }
    };

    return Ziggurat!(T, fallback, R, true)(pdf, invPdf, 128, rightEnd, T(9.91256303526217e-3));
}

/**
Setup an _exponential distribution sampler.

Params:
    T = floating-point type that should be sampled
    R = unsigned UIntType of the random generator

Returns:
    A $(LREF Ziggurat) sampler that can be called to sample from the distribution.
*/
auto exponential(T, R = uint)()
{
    import mir.internal.math : exp, log;

    auto pdf    = (T x) => cast(T) exp(-x);
    auto invPdf = (T x) => cast(T) -log(x);

    // values from [Marsaglia00]
    enum fallback = q{
        T fallback(RNG)(ref RNG gen) const
        {
            import std.random : uniform;
            auto u = uniform!("[]", T, T)(0, 1, gen);
            return 7.69711 - u;
        }
    };

    return Ziggurat!(T, fallback, R, false)(pdf, invPdf, 256, T(7.697117470131487), T(3.949659822581572e-3));
}

/**
Ziggurat algorithm for generating a random variable from a montone, decreasing density.

Complexity: O_avg: O(1)

References:
    Marsaglia, George, and Wai Wan Tsang. "The ziggurat method for generating random variables."
    Journal of statistical software 5.8 (2000): 1-7.
*/
struct Ziggurat(T, string _fallback, R = uint, bool bothSides)
    if (isNumeric!T)
{

private:

    /// monotone decreasing probability density function
    /// constants don't matter
    T function(T x) pdf;
    T function(T x) invPdf;

    /// precalculate difference x_i / x_{i+1}
    T[] xDiv;
    /// precalculate scaling to R.max for x_i
    T[] xScaled;
    /// precalculate pdf value for x_i
    T[] fs;

    /// number of blocks
    size_t k;
    // mask to use to get the first log_2 k bits (=k - 1)
    size_t kMask;

    /// left-point of the right-most block
    T rightEnd;

    /// area of every column
    T blockArea;

public:
    this(T function(T x) pdf, T function(T x) invPdf, size_t k, T rightEnd,
         T blockArea)
    {
        this.pdf = pdf;
        this.invPdf = invPdf;
        this.k = k;
        this.rightEnd = rightEnd;
        this.blockArea = blockArea;

        // scale factor to the range of UIntType
        T maxT = bothSides ? R.max / 2 : R.max;
        kMask = k - 1;

        auto xn = rightEnd; // Next x_{i+1}
        auto xc = xn; // Current x_i
        auto fn = pdf(xn);

        // k_i = floor(2^32 (x_{i-1} / x_i))
        xDiv    = new T[k];
        xDiv[0] = (xn * fn / blockArea) * maxT;
        xDiv[1] = 0;

        // w_i = 0.5^32 * x_i
        xScaled        = new T[k];
        xScaled[0]     = (blockArea / fn) / maxT;
        xScaled[$ - 1] = xn / maxT;

        // f_i = f(x_i)
        fs        = new T[k];
        fs[0]     = T(1);
        fs[$ - 1] = fn;

        for (auto i = k - 2; i >= 1; i--)
        {
            xn = invPdf(blockArea / xn + fn);
            xDiv[i + 1] = (xn / xc) * maxT;
            fn = fs[i] = pdf(xn);
            xScaled[i] = xn / maxT;
            xc = xn;
        }
    }

    /// samples a value from the discrete distribution
    T opCall() const
    {
        import std.random : rndGen;
        return opCall(rndGen);
    }

    /// samples a value from the discrete distribution using a custom random generator
    T opCall(RNG)(ref RNG gen) const
    {
        import std.random : uniform;
        import std.traits : Signed;
        import std.range : ElementType;
        import std.mir.internal : fabs;

        // TODO: option for inlining
        for (;;)
        {
            static if (bothSides)
                Signed!(ElementType!RNG) u = gen.front;
            else
                auto u = gen.front;

            gen.popFront();

            // TODO: this is a bit biased
            size_t i = u & kMask;
            //size_t i = uniform!("[)", size_t, size_t)(0, kMask, gen);

            // U * x_i < x_{i+1}
            static if (bothSides)
            {
                if (fabs(u) < xDiv[i])
                    return u * xScaled[i];
            }
            else
            {
                if (u < xDiv[i])
                    return u * xScaled[i];
            }

            if (i == 0)
            {
                // generate x from tail block
                static if (bothSides)
                    return fallback(u > 0, gen);
                else
                    return fallback(gen);
            }
            else
            {
                auto x = u * xScaled[i];
                if (fs[i] + u * (fs[i - 1] - fs[i]) < pdf(x))
                    return x;
            }
        }
    }

private:
    mixin(_fallback);
}

unittest
{
    import std.random : Mt19937;
    auto gen = Mt19937(42);

    alias T = double;
    auto z = normal!(T, uint)();
    auto n = 10_000;
    auto obs = new T[n];
    foreach (i; 0..n)
    {
        obs[i] = z(gen);
    }

    import std.algorithm.iteration : sum;
    import std.math : approxEqual;
    assert((obs.sum / n).approxEqual(-0.02368));
}
