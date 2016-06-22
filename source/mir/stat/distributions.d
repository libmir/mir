/**
Random distributions.

License: $(LINK2 http://boost.org/LICENSE_1_0.txt, Boost License 1.0).
*/

module mir.stat.distributions;

/**
Probability density function of the chi distribution with k degrees of freedom.

Params:
    x = x-position
    k = degrees of freedom

Returns: y-value of the chi density function at x

See_Also:
    $(https://en.wikipedia.org/wiki/Chi_distribution, Wikipedia)
References:
    Weisstein, Eric W. "Chi Distribution." From MathWorld--A Wolfram Web Resource.
    http://mathworld.wolfram.com/ChiDistribution.html
*/
real chiPDF(real x, size_t k)
{
    import std.exception : enforce;
    import std.mathspecial : gamma;
    import mir.internal.math : exp, pow;

    enforce(k > 0, "Degrees of freedom must be higher than 0.");
    return pow(x, (k - 1)) * exp(-x * x / 2.0) / (pow(2, (k / 2.0 - 1)) * gamma(k / 2.0));
}

unittest
{
    import std.math : approxEqual;
    assert(chiPDF(0.5, 1).approxEqual(0.704130));
    assert(chiPDF(0.5, 3).approxEqual(0.176032));
    assert(chiPDF(0.8, 1).approxEqual(0.579383));
    assert(chiPDF(0.8, 3).approxEqual(0.370805));
}

/**
Probability density function of the chi distribution with k degrees of freedom.

Params:
    x = x-position
    k = degrees of freedom

Returns: y-value of the chi density function at x

See_Also:
    $(https://en.wikipedia.org/wiki/Chi_distribution, Wikipedia)

References:
    Weisstein, Eric W. "Chi Distribution." From MathWorld--A Wolfram Web Resource.
    http://mathworld.wolfram.com/ChiDistribution.html
*/
real chiCDF(real x, size_t k)
{
    import std.exception : enforce;
    import std.mathspecial : gamma, gammaIncomplete;
    import mir.internal.math : exp;

    enforce(k > 0, "Degrees of freedom must be higher than 0.");
    return gammaIncomplete(k / 2.0, x * x / 2.0);
}

unittest
{
    import std.math : approxEqual;
    import std.mathspecial : gamma, gammaIncomplete;
    assert(chiCDF(0.5, 1).approxEqual(0.38292));
    assert(chiCDF(0.5, 3).approxEqual(0.03085));
    assert(chiCDF(0.8, 1).approxEqual(0.57628));
    assert(chiCDF(0.8, 3).approxEqual(0.11278));
}

/**
Probability density function of the chi-squared distribution with k degrees of freedom.

Params:
    x = x-position
    k = degrees of freedom

Returns: y-value of the chi-square density function at x

See_Also:
    $(LINK2 https://en.wikipedia.org/wiki/Chi-squared_distribution, Wikipedia)

References:
    Weisstein, Eric W. "Chi-Squared Distribution." From MathWorld--A Wolfram Web Resource.
    http://mathworld.wolfram.com/Chi-SquaredDistribution.html
*/
real chiSqPDF(real x, size_t k)
{
    import std.exception : enforce;
    import std.mathspecial : gamma;
    import mir.internal.math : exp, pow;

    enforce(k > 0, "Degrees of freedom must be higher than 0.");
    return pow(x, k / 2.0 - 1) *  exp(-x / 2.0) / (gamma(k / 2.0)  * pow(2, k / 2.0));
}

unittest
{
    import std.math : approxEqual;
    assert(chiSqPDF(0.5, 1).approxEqual(0.439391));
    assert(chiSqPDF(0.5, 3).approxEqual(0.219695));
    assert(chiSqPDF(0.8, 1).approxEqual(0.298983));
    assert(chiSqPDF(0.8, 3).approxEqual(0.239186));
}

/**
Cumulative distribution function of the chi-squared distribution with k degrees of freedom.

Params:
    x = x-position
    k = degrees of freedom

Returns: y-value of the chi-square density function at x

See_Also:
    $(LINK2 https://en.wikipedia.org/wiki/Chi-squared_distribution, Wikipedia)

References:
    Weisstein, Eric W. "Chi-Squared Distribution." From MathWorld--A Wolfram Web Resource.
    http://mathworld.wolfram.com/Chi-SquaredDistribution.html
*/
real chiSqCDF(real x, size_t k)
{
    import std.exception : enforce;
    import std.mathspecial : gamma, gammaIncomplete;
    import mir.internal.math : exp;

    enforce(k > 0, "Degrees of freedom must be higher than 0.");
    if (k == 2)
        return 1 - exp(-x / 2.0);
    else
        return gammaIncomplete(k / 2.0, x / 2.0);
}

unittest
{
    import std.math : approxEqual;
    import std.mathspecial : gamma, gammaIncomplete;
    assert(chiSqCDF(0.5, 1).approxEqual(0.5205));
    assert(chiSqCDF(0.5, 3).approxEqual(0.0811085));
    assert(chiSqCDF(0.8, 1).approxEqual(0.628906));
    assert(chiSqCDF(0.8, 3).approxEqual(0.150532));
    assert(chiSqCDF(6.436, 5).approxEqual(0.733926));
}

/**
Density function of the normal distribution.

Params:
    x = x-position
    mean = mean or expectation
    stddev = standard deviation
Returns: y-value of the normal distribution density function at x

See_Also:
    $(LINK2 https://en.wikipedia.org/wiki/Normal_distribution, Wikipedia)
*/
real normalPDF(real x, real mean, real stddev)
{
    import mir.internal.math : exp, pow, sqrt;
    import std.exception : enforce;
    import std.math : PI;

    enforce(stddev > 0, "Standard deviation must be greater than 0.");

    auto ss2 = 2 * stddev * stddev;
    auto below = (sqrt(2 * PI) * stddev);
    auto t = x - mean;
    return exp(-(t * t) / ss2) / below;
}

/// ditto
real normalPDF(real mean = 0, real stddev = 1)(real x)
{
    import mir.internal.math : exp, pow, sqrt;
    import std.exception : enforce;
    import std.math : PI;

    enforce(stddev > 0, "Standard deviation must be greater than 0.");

    enum ss2 = 2 * stddev * stddev;
    enum below = (sqrt(2 * PI) * stddev);

    auto t = x - mean;
    return exp(-(t * t) / ss2) / below;
}

unittest
{
    import std.math : approxEqual;
    assert(normalPDF(0.5).approxEqual(0.3520));
    assert(normalPDF(1.5).approxEqual(0.1295));
    assert(normalPDF(-2.5).approxEqual(0.0175));

    assert(normalPDF!(0.5, 1.5)(0.75).approxEqual(0.26229));
    assert(normalPDF(0.75, 0.5, 1.5).approxEqual(0.26229));
}
