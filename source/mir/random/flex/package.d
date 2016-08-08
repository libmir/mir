/**
Flex module.

License: $(LINK2 http://boost.org/LICENSE_1_0.txt, Boost License 1.0).

Authors: Sebastian Wilzbach, Ilya Yaroshenko

The Transformed Density Rejection with Inflection Points (Flex) algorithm
can sample from arbitrary distributions given (1) its log-density function f,
(2) its first two derivatives and (3) a partitioning into intervals
with at most one inflection point.

These can be easily found by plotting `f''`.
$(B Inflection point) can be identified by observing at which points `f''` is 0
and an inflection interval which is defined by two inflection points can either be:

$(UL
    $(LI $(F_TILDE) is entirely concave (`f''` is entirely negative))
    $(LI $(F_TILDE) is entirely convex (`f''` is entirely positive))
    $(LI $(F_TILDE) contains one inflection point (`f''` intersects the x-axis once))
)

It is not important to identity the exact inflection points, but the user input requires:

$(UL
    $(LI Continuous density function $(F_TILDE).)
    $(LI Continuous differentiability of $(F_TILDE) except in a finite number of
      points which need to have a one-sided derivative.)
    $(LI $(B Doubled) continuous differentiability of $(F_TILDE) except in a finite number of
      points which need to be inflection points.)
    $(LI At most one inflection point per interval)
)

Internally the Flex algorithm transforms the distribution with a special
transformation function and constructs for every interval a linear `hat` function
that majorizes the `pdf` and a linear `squeeze` function that is majorized by
the `pdf` from the user-defined, mutually-exclusive partitioning.

$(H3 Efficiency `rho`)

In further steps the algorithm splits those intervals until a chosen efficiency
`rho` between the ratio of the sum of all hat areas to the sum of
all squeeze areas is reached.
For example an efficiency of 1.1 means
that `10 / 110` of all drawn uniform numbers don't match the target distribution
and need be resampled.
A higher efficiency constructs more intervals, and thus requires more iterations
and a longer setup phase, but increases the speed of sampling.

$(H3 Unbounded intervals)

In each unbounded interval the transformation and thus the density must be
concave and strictly monotone.

$(H3 Transformation function (T_c)) $(A_NAME t_c_family)

The Flex algorithm uses a family of T_c transformations:

$(UL
    $(LI `T_0(x) = log(x))
    $(LI `T_c(x) = sign(c) * x^c)
)

Thus `c` has the following properties

$(UL
    $(LI Decreasing `c` may decrease the number of inflection points)
    $(LI For unbounded domains, `c > -1` is required)
    $(LI For unbounded densities, `c` must be sufficiently small, but should
         be great than -1. A common choice is `-0.5`)
    $(LI `c=0` is the pure `log` transformation and thus decreases the
         vulnerability for under- and overflows)
)

References:
    Botts, Carsten, Wolfgang Hörmann, and Josef Leydold.
    "$(LINK2 http://epub.wu-wien.ac.at/3158/1/techreport-110.pdf,
    Transformed density rejection with inflection points.)"
    Statistics and Computing 23.2 (2013): 251-260.

Macros:
    F_TILDE=$(D g(x))
    A_NAME=<a name="$1"></a>
*/
module mir.random.flex;

import mir.random.discrete : Discrete;

import std.random : isUniformRNG;
import std.traits : isCallable, isFloatingPoint, ReturnType;

version(Flex_logging)
{
    import std.experimental.logger;
}

/**
The Transformed Density Rejection with Inflection Points (Flex) algorithm
can sample from arbitrary distributions given its density function f, its
first two derivatives and a partitioning into intervals with at most one inflection
point. The partitioning needs to be mutually exclusive and sorted.

Params:
    pdf = probability density function of the distribution
    f0 = logarithmic pdf
    f1 = first derivative of logarithmic pdf
    f2 = second derivative of logarithmic pdf
    c = $(LINK2 #t_c_family, T_c family) value
    cs = $(LINK2 #t_c_family, T_c family) array
    points = non-overlapping partitioning with at most one inflection point per interval
    rho = efficiency of the Flex algorithm

Returns:
    Flex Generator.
*/
auto flex(S, F0, F1, F2)
               (in F0 f0, in F1 f1, in F2 f2,
                S c, S[] points, S rho = 1.1)
    if (isFloatingPoint!S)
{
    S[] cs = new S[points.length - 1];
    foreach (ref d; cs)
        d = c;
    return flex(f0, f1, f2, cs, points, rho);
}

/// ditto
auto flex(S, Pdf, F0, F1, F2)
               (in Pdf pdf, in F0 f0, in F1 f1, in F2 f2,
                S c, S[] points, S rho = 1.1)
    if (isFloatingPoint!S)
{
    S[] cs = new S[points.length - 1];
    foreach (ref d; cs)
        d = c;
    return flex(pdf, f0, f1, f2, cs, points, rho);
}

/// ditto
auto flex(S, F0, F1, F2)
               (in F0 f0, in F1 f1, in F2 f2,
                S[] cs, S[] points, S rho = 1.1)
    if (isFloatingPoint!S)
{
    import mir.internal.math: exp;
    auto pdf = (S x) => exp(f0(x));
    return flex(pdf, flexIntervals(f0, f1, f2, cs, points, rho));
}

/// ditto
auto flex(S, Pdf, F0, F1, F2)
               (in Pdf pdf, in F0 f0, in F1 f1, in F2 f2,
                S[] cs, S[] points, S rho = 1.1)
    if (isFloatingPoint!S)
{
    return flex(pdf, flexIntervals(f0, f1, f2, cs, points, rho));
}

/// ditto
auto flex(S, Pdf)(in Pdf pdf, in FlexInterval!S[] intervals)
    if (isFloatingPoint!S)
{
    return Flex!(S, typeof(pdf))(pdf, intervals);
}

/**
Data body of the Flex algorithm.
Can be used to sample from the distribution.
*/
struct Flex(S, Pdf)
    if (isFloatingPoint!S)
{
    // density function
    private const Pdf _pdf;

    // generated partition points
    private const FlexInterval!S[] _intervals;

    // discrete density sampler
    private const Discrete!S ds;

    package this(in Pdf pdf, in FlexInterval!S[] intervals)
    {
        import std.algorithm.iteration : map, sum;
        _pdf = pdf;

        _intervals = intervals;

        // pre-calculate cumulative density points
        auto cdPoints = new S[intervals.length];
        auto total = intervals.map!`a.hatArea`.sum;
        foreach (i, ref cd; cdPoints)
            cd = intervals[i].hatArea / total;

        this.ds = Discrete!S(cdPoints);
    }

    /// Generated partition points
    const(FlexInterval!S[]) intervals() @property const
    {
        return _intervals;
    }

    /**
    Sample a value from the distribution.
    Params:
        rng = random number generator to use
    Returns:
        Array of length n with the samples
    */
    S opCall() const
    {
        import std.random : rndGen;
        return flexImpl(_pdf, _intervals, ds, rndGen);
    }

    /// ditto
    S opCall(RNG)(ref RNG rng) const
        if (isUniformRNG!RNG)
    {
        return flexImpl(_pdf, _intervals, ds, rng);
    }
}

///
unittest
{
    import std.math : approxEqual;
    import std.meta : AliasSeq;
    import std.random : Mt19937;
    alias S = double;
    auto gen = Mt19937(42);
    auto f0 = (S x) => -x^^4 + 5 * x^^2 - 4;
    auto f1 = (S x) => 10 * x - 4 * x ^^ 3;
    auto f2 = (S x) => 10 - 12 * x ^^ 2;
    S[] points = [-3, -1.5, 0, 1.5, 3];

    auto tf = flex(f0, f1, f2, 1.5, points, 1.1);
    auto value = tf(gen);
}

unittest
{
    import std.meta : AliasSeq;
    import std.math : approxEqual, PI;
    import std.random : Mt19937;
    import mir.internal.math : exp, sqrt;
    import mir.utility.linearfun : LinearFun;
    foreach (S; AliasSeq!(float, double, real))
    {
        S sqrt2PI = sqrt(2 * PI);
        auto f0 = (S x) => 1 / (exp(x * x / 2) * sqrt2PI);
        auto f1 = (S x) => -(x/(exp(x * x/2) * sqrt2PI));
        auto f2 = (S x) => (-1 + x * x) / (exp(x * x/2) * sqrt2PI);
        auto pdf = (S x) => exp(f0(x));
        S[] points = [-3.0, 0, 3];
        alias TF = FlexInterval!S;
        alias LF = LinearFun!S;

        // generated from
        // auto intervals = flexIntervals(f0, f1, f2, [1.5, 1.5], points, S(1.1));

        auto intervals = [
            TF(-3, -1.36003, 1.5, LF(0.159263, -1.36003, 1.26786),
                                  LF(0.0200763, -3, 1.00667), 1.78593, 1.66515),
            TF(-1.36003, -0.720759, 1.5, LF(0.498434, -0.720759, 1.58649),
                                         LF(0.409229, -1.36003, 1.26786), 0.80997, 0.799256),
            TF(-0.720759, 0, 1.5, LF(-0, 0, 1.81923),
                                  LF(0.322909, 0, 1.81923), 1.07411, 1.02762),
            TF(0, 0.720759, 1.5, LF(-0, 0, 1.81923),
                                 LF(-0.322909, 0, 1.81923), 1.07411, 1.02762),
            TF(0.720759, 1.36003, 1.5, LF(-0.498434, 0.720759, 1.58649),
                                       LF(-0.409229, 1.36003, 1.26786), 0.80997, 0.799256),
            TF(1.36003, 3, 1.5, LF(-0.159263, 1.36003, 1.26786),
                                LF(-0.0200763, 3, 1.00667), 1.78593, 1.66515)
        ];
        auto tf = flex(pdf, intervals);
        auto gen = Mt19937(42);
        auto value = tf(gen);
        assert(value.approxEqual(S(-0.146644)));
    }
}

unittest
{
    import std.math : approxEqual, pow;
    import std.meta : AliasSeq;
    import std.random : Mt19937;
    foreach (S; AliasSeq!(float, double, real))
    {
        auto gen = Mt19937(42);
        auto f0 = (S x) => -pow(x, 4) + 5 * x * x - 4;
        auto f1 = (S x) => 10 * x - 4 * pow(x, 3);
        auto f2 = (S x) => 10 - 12 * x * x;
        S[] points = [-3, -1.5, 0, 1.5, 3];

        auto tf = flex(f0, f1, f2, 1.5, points, 1.1);
        auto value = tf(gen);
    }
}

/**
Sample from the distribution with generated, non-overlapping hat and squeeze functions.
Uses acceptance-rejection algorithm. Based on Table 4 from Botts et al. (2013).

Params:
    pdf = probability density function of the distribution
    intervals = calculated inflection points
    ds = discrete distribution sampler for hat areas
    rng = random number generator to use
See_Also:
   $(LINK2 https://en.wikipedia.org/wiki/Rejection_sampling,
     Acceptance-rejection sampling)
*/
private S flexImpl(S, Pdf, RNG)
          (in Pdf pdf, in FlexInterval!S[] intervals,
           in Discrete!S ds, ref RNG rng)
    if (isUniformRNG!RNG)
{
    import mir.internal.math: exp, fabs, log;
    import mir.random.flex.internal.transformations : antiderivative, inverseAntiderivative;
    import std.random: dice, uniform;

    S X = void;
    enum S one_div_3 = 1 / S(3);

    // acceptance-rejection sampling
    for (;;)
    {
        // sample an interval with density proportional to their hatArea
        immutable index = ds(rng); // J in Botts et al. (2013)
        assert(index < intervals.length);
        immutable interval = intervals[index];

        S u = uniform!("[)", S, S)(0, 1, rng);

        // generate X with density proportional to the selected interval
        with(interval)
        {
            immutable hatLx = hat(lx);
            if (c == 0)
            {
                auto eXInv = exp(-hatLx);
                auto z = u * hat.slope * eXInv;
                if (fabs(z) < S(1e-6))
                {
                    X = lx + u * eXInv * (1 - z * S(0.5) + z * z * one_div_3);
                }
                else
                {
                    X = hat.inverse(log(hat.slope * u + exp(hatLx)));
                }
            }
            else
            {
                if (c == S(-0.5))
                {
                    auto eX = exp(hatLx);
                    auto z = u * hat.slope * eX;
                    if (fabs(z) < S(1e-6))
                    {
                        X = lx + u * eX * (1 - z * S(0.5) + z * z);
                        goto finish;
                    }
                }
                else if (c == 1)
                {
                    auto k = hatLx;
                    auto z = u * hat.slope / (k * k);
                    if (fabs(z) < S(1e-6))
                    {
                        X = lx + u * k * (1 - z * S(0.5) + z * z * S(0.5));
                        goto finish;
                    }
                }
                else
                {
                    if (fabs(hat.slope) < S(1e-10))
                    {
                        X = (1 - u) * lx + u * rx;
                        goto finish;
                    }
                }
                X = hat.inverse(inverseAntiderivative(u * hat.slope + antiderivative(hatLx, c), c));
            }

        finish:

            immutable hatX = hat(X);
            immutable squeezeX = squeeze(X);

            auto invHatX = flexInverse(hatX, c);
            auto invSqueezeX = squeezeArea > 0 ? flexInverse(squeezeX, c) : 0;

            immutable t = u * invHatX;

            // u * h(c) < s(X)  "squeeze evaluation"
            if (t <= invSqueezeX)
                break;

            // u * h(c) < f(X)  "density evaluation"
            if (t <= pdf(X))
                break;
        }
    }
    return X;
}

/**
Reduced version of $(LREF Interval). Contains only the necessary information
needed in the generation phase.
*/
struct FlexInterval(S)
    if (isFloatingPoint!S)
{
    import mir.utility.linearfun : LinearFun;

    /// left position of the interval
    S lx;

    /// right position of the interval
    S rx;

    /// T_c family of the interval
    S c;

    ///
    LinearFun!S hat;

    ///
    LinearFun!S squeeze;

    ///
    S hatArea;

    ///
    S squeezeArea;

    // disallow NaN points
    invariant {
        import std.math : isNaN;
        import std.meta : AliasSeq;
        alias seq =  AliasSeq!(lx, rx, c, hatArea, squeezeArea);
        foreach (i, v; seq)
            assert(!v.isNaN, "variable " ~ seq[i].stringof ~ " isn't allowed to be NaN");

        assert(lx < rx, "invalid interval - right side must be larger than the left side");
    }
}

/**
Calculate the intervals for the Flex algorithm for a T_c family given its
density function, the first two derivatives and a valid start partitioning.
The Flex algorithm will try to split the intervals until a chosen efficiency
rho is reached.

Params:
    f0 = probability density function of the distribution
    f1 = first derivative of f0
    f1 = second derivative of f0
    cs = T_c family (single value or array)
    points = non-overlapping partitioning with at most one inflection point per interval
    rho = efficiency of the Flex algorithm
    apprMaxPoints = maximal number of splitting points before Flex is aborted

Returns: Array of IntervalPoints
*/
FlexInterval!S[] flexIntervals(S, F0, F1, F2)
                            (in F0 f0, in F1 f1, in F2 f2,
                             in S[] cs, in S[] points, in S rho = 1.1,
                             in int apprMaxPoints = 1_000, in int maxIterations = 1_000)
in
{
    import std.algorithm.searching : all;
    import std.math : isFinite, isInfinity;
    import std.range: drop, empty, front, save;

    // check efficiency rho
    assert(rho.isFinite, "rho must be a valid value");
    assert(rho > 1, "rho must be > 1");

    // check points
    assert(points.length >= 2, "two or more splitting points are required");
    assert(points[1..$-1].all!isFinite, "intermediate interval can't be indefinite");

    // check cs
    assert(cs.length == points.length - 1, "cs must have length equal to |points| - 1");

    // check first c
    if (points[0].isInfinity)
        assert(cs.front > - 1,"c must be > -1 for unbounded domains");

    // check last c
    if (points[$ - 1].isInfinity)
        assert(cs[$ - 1] > - 1,"cs must be > -1 for unbounded domains");
}
body
{
    import mir.random.flex.internal.calc: arcmean, calcInterval;
    import mir.random.flex.internal.transformations : transform, transformInterval;
    import mir.random.flex.internal.types: Interval;
    import mir.internal.math: copysign, exp, pow;
    import mir.sum: Summator, Summation;
    import std.algorithm.sorting : sort;
    import std.container.array: Array;
    import std.container.binaryheap: BinaryHeap;
    import std.math: nextDown;
    import std.range.primitives : front, empty, popFront;

    alias Sum = Summator!(S, Summation.precise);

    Sum totalHatAreaSummator = 0;
    Sum totalSqueezeAreaSummator = 0;

    auto nrIntervals = cs.length;

    // binary heap can't be extended with normal arrays, see
    // https://github.com/dlang/phobos/pull/4359
    auto arr = Array!(Interval!S)();
    auto ips = BinaryHeap!(typeof(arr), (Interval!S a, Interval!S b){
        S aVal = a.hatArea - a.squeezeArea;
        S bVal = b.hatArea - b.squeezeArea;
        // Explicit order is needed for LDC (undefined otherwise)
        if (!(aVal == bVal))
            return aVal < bVal;
        else
            return a.lx < b.lx;
    })(arr);

    S l = points[0];
    S l0 = f0(points[0]);
    S l1 = f1(points[0]);
    S l2 = f2(points[0]);

    version(Flex_logging)
    {
        log("starting flex with p=", points, ", cs=", cs);
        version(Flex_logging_hex)
        {
            logf("points= %(%a, %)", points);
            logf("cs= %(%a, %)", points);
        }
    }

    // initialize with user given splitting points
    foreach (i, r; points[1..$])
    {
        auto iv = Interval!S(l, r, cs[i], l0, l1, l2, f0(r), f1(r), f2(r));
        l = r;
        l0 = iv.rtx;
        l1 = iv.rt1x;
        l2 = iv.rt2x;
        transformInterval(iv);

        calcInterval(iv);
        totalHatAreaSummator += iv.hatArea;
        totalSqueezeAreaSummator += iv.squeezeArea;

        ips.insert(iv);
    }

    version(Windows) {} else
    version(Flex_logging)
    {
        import std.algorithm.iteration : map;
        import std.array : array;
        auto ipsD = ips.dup.array;
        log("----");

        logf("Interval: %(%f, %)", ipsD.map!`a.lx`);
        version(Flex_logging_hex)
            logf("Interval: %(%a, %)", ipsD.map!`a.lx`);

        logf("hatArea: %(%f, %)", ipsD.map!`a.hatArea`);
        version(Flex_logging_hex)
            logf("hatArea: %(%a, %)", ipsD.map!`a.hatArea`);

        logf("squeezeArea %(%f, %)", ipsD.map!`a.squeezeArea`);
        version(Flex_logging_hex)
            logf("squeezeArea %(%a, %)", ipsD.map!`a.squeezeArea`);

        log("----");
    }

    // Flex is not guaranteed to converge
    for (auto i = 0; i < maxIterations && nrIntervals < apprMaxPoints; i++)
    {
        immutable totalHatArea = totalHatAreaSummator.sum;
        immutable totalSqueezeArea = totalSqueezeAreaSummator.sum;

        // Flex aims for a user defined efficiency
        if (totalHatArea / totalSqueezeArea <= rho)
            break;

        version(Windows) {} else
        version(Flex_logging)
        {
            tracef("iteration %d: totalHat: %.3f, totalSqueeze: %.3f, rho: %.3f",
                    i, totalHatArea, totalSqueezeArea, totalHatArea / totalSqueezeArea);
            version(Flex_logging_hex)
                tracef("iteration %d: totalHat: %a, totalSqueeze: %a, rho: %a",
                        i, totalHatArea, totalSqueezeArea, totalHatArea / totalSqueezeArea);
            version(Flex_logging_hex)
                logf("to be split: %s", ips.front.logHex);
        }

        immutable avgArea = nextDown(totalHatArea - totalSqueezeArea) / nrIntervals;

        // remove the first element and split it
        auto curEl = ips.front;
        ips.removeFront;

        // prepare total areas for update
        totalHatAreaSummator -= curEl.hatArea;
        totalSqueezeAreaSummator -= curEl.squeezeArea;

        // split the interval at the arcmean into two parts
        auto mid = arcmean!S(curEl);

        // cache
        immutable c = curEl.c;

        // calculate new values
        S mx0 = f0(mid);
        S mx1 = f1(mid);
        S mx2 = f2(mid);

        Interval!S midIP = Interval!S(mid, curEl.rx, c,
                                      mx0, mx1, mx2,
                                      curEl.rtx, curEl.rt1x, curEl.rt2x);

        // apply transformation to right side (for c=0 no transformations are applied)
        if (c)
            mixin(transform!("midIP.ltx", "midIP.lt1x", "midIP.lt2x", "c"));

        // left interval: update right values
        curEl.rx = mid;
        curEl.rtx = midIP.ltx;
        curEl.rt1x = midIP.lt1x;
        curEl.rt2x = midIP.lt2x;

        // recalculate intervals
        calcInterval(curEl);
        calcInterval(midIP);

        version(Flex_logging)
        {
            log("--split ", nrIntervals, " between ", curEl.lx, " - ", curEl.rx);
            log("interval to be split: ", curEl);
            log("new middle interval created: ", midIP);
            version(Flex_logging_hex)
            {
                logf("left: %s", curEl.logHex);
                logf("right: %s", midIP.logHex);
            }

            log("update left: ", curEl);
            log("update mid: ", midIP);
        }

        // update total areas
        totalHatAreaSummator += curEl.hatArea;
        totalHatAreaSummator += midIP.hatArea;
        totalSqueezeAreaSummator += curEl.squeezeArea;
        totalSqueezeAreaSummator += midIP.squeezeArea;

        // insert new middle part into linked list
        ips.insert(curEl);
        ips.insert(midIP);

        nrIntervals++;
    }

    // for sampling only a subset of the attributes is needed
    auto intervals = new FlexInterval!S[nrIntervals];
    size_t i = 0;
    foreach (ref ip; ips)
        intervals[i++] = FlexInterval!S(ip.lx, ip.rx, ip.c, ip.hat,
                                     ip.squeeze, ip.hatArea, ip.squeezeArea);

    // intervals have been sorted after hatArea
    intervals.sort!`a.lx < b.lx`();
    version(Flex_logging)
    {
        import std.algorithm;
        import std.array;
        log("----");
        log("Intervals generated: ", intervals.length);
        log("Interval: ", intervals.map!`a.lx`);
        log("hatArea", intervals.map!`a.hatArea`);
        log("squeezeArea", intervals.map!`a.squeezeArea`);
        log("----");
    }

    return intervals;
}

// default flex with c=1.5
unittest
{
    import std.algorithm : equal, map;
    import std.math : approxEqual;
    import std.meta : AliasSeq;

    static immutable hats = [1.79547e-05, 0.00271776, 0.0629733, 0.0912821,
                             0.18815, 0.754863, 1.13845, 1.10943, 0.788248,
                             0.547819, 0.619752, 0.254661, 0.105682, 0.0790885,
                             0.0212445, 0.0252439, 0.0252439, 0.0212445,
                             0.0790885, 0.105682, 0.254661, 0.619752, 0.547819,
                             0.788248, 1.10943, 0.566373, 0.523965, 0.754863,
                             0.18815, 0.0912821, 0.0629733, 0.00271776, 1.79547e-05];

    static immutable sqs = [2.36004e-18, 3.89553e-05, 0.00970061, 0.0704188,
                            0.165753, 0.674084, 1.05251, 1.04208, 0.769742,
                            0.539798, 0.53902, 0.215078, 0.090285, 0.0522061,
                            0.0163806, 0.00980223, 0.00980223, 0.0163806,
                            0.0522061, 0.090285, 0.215078, 0.53902, 0.539798,
                            0.769742, 1.04208, 0.555479, 0.515533, 0.674084,
                            0.165753, 0.0704188, 0.00970061, 3.89553e-05, 2.36004e-18];

    foreach (S; AliasSeq!(float, double, real))
    {
        auto f0 = (S x) => -x^^4 + 5 * x^^2 - 4;
        auto f1 = (S x) => 10 * x - 4 * x ^^ 3;
        auto f2 = (S x) => 10 - 12 * x ^^ 2;
        S[] cs = [1.5, 1.5, 1.5, 1.5];
        S[] points = [-3, -1.5, 0, 1.5, 3];
        auto ips = flexIntervals(f0, f1, f2, cs, points, S(1.1));

        foreach (i, el; ips)
        {
            version(Flex_logging) scope(failure)
            {
                logf("at %d got %a, expected %a (%2$f)", i, el.hatArea, hats[i]);
                logf("at %d got %a, expected %a (%2$f)", i, el.squeezeArea, sqs[i]);
                logf("iv %s", el);
            }
            assert(el.hatArea.approxEqual(hats[i]));
            assert(el.squeezeArea.approxEqual(sqs[i]));
        }
    }
}

// default flex with c=1
unittest
{
    import std.algorithm : equal, map;
    import std.math : approxEqual;
    import std.meta : AliasSeq;
    static immutable hats = [1.49622e-05, 0.00227029, 0.0540631, 0.0880036,
                             0.184448, 0.752102, 1.13921, 1.10993, 1.40719,
                             0.606916, 0.249029, 0.103608, 0.119708, 0.0238081,
                             0.0238081, 0.119708, 0.103608, 0.249029, 0.606916,
                             0.547504, 0.789818, 1.10993, 1.13921, 0.752102,
                             0.184448, 0.0880036, 0.0540631, 0.00227029, 1.49622e-05];

    static immutable sqs = [5.34911e-17, 5.37841e-05, 0.0118652, 0.0738576,
                            0.17077, 0.706057, 1.04936, 1.04196, 1.29868,
                            0.55554, 0.2213, 0.0925191, 0.0495667, 0.00980223,
                            0.00980223, 0.0495667, 0.0925191, 0.2213, 0.55554,
                            0.543916, 0.768265, 1.04196, 1.04936, 0.706057,
                            0.17077, 0.0738576, 0.0118652, 5.37841e-05,
                            5.34911e-17];

    foreach (S; AliasSeq!(float, double, real))
    {
        auto f0 = (S x) => -x^^4 + 5 * x^^2 - 4;
        auto f1 = (S x) => 10 * x - 4 * x ^^ 3;
        auto f2 = (S x) => 10 - 12 * x ^^ 2;
        S[] points = [-3, -1.5, 0, 1.5, 3];
        S[] cs = [1.0, 1.0, 1.0, 1.0];
        auto ips = flexIntervals(f0, f1, f2, cs, points, S(1.1));

        foreach (i, el; ips)
        {
            version(Flex_logging) scope(failure)
            {
                logf("got %a, expected %a", el.hatArea, hats[i]);
                logf("got %a, expected %a", el.squeezeArea, sqs[i]);
                logf("iv %s", el);
            }
            assert(el.hatArea.approxEqual(hats[i]));
            assert(el.squeezeArea.approxEqual(sqs[i]));
        }
    }
}

// default flex with custom c's
unittest
{
    import std.algorithm : equal, map;
    import std.math : approxEqual;
    import std.meta : AliasSeq;

    static immutable hats = [1.69137e-05, 0.00256095, 0.0597127, 0.0899876,
                             0.186679, 0.747491, 0.524337, 0.566407, 1.10963,
                             0.788573, 0.547394, 0.617211, 0.253546, 0.105271,
                             0.130463, 0.0249657, 0.0252439, 0.13294, 0.105682,
                             0.25466, 0.619752, 0.547819, 0.788249, 1.10933,
                             1.13829, 0.429167, 0.310853, 0.188879, 0.0919179,
                             0.0644612, 0.00278727, 1.84149e-05];

    static immutable sqs = [2.36004e-18, 4.3382e-05, 0.0103914, 0.0716524,
                            0.167594, 0.685574, 0.515237, 0.555414, 1.04203,
                            0.769447, 0.540575, 0.541969, 0.216192, 0.0906883,
                            0.0462627, 0.00980223, 0.00980223, 0.045605,
                            0.0902851, 0.215078, 0.53902, 0.539798, 0.769742,
                            1.0421, 1.05314, 0.42437, 0.294228, 0.164901,
                            0.0698581, 0.00941278, 3.71912e-05, 2.36004e-18];

    foreach (S; AliasSeq!(float, double, real))
    {
        auto f0 = (S x) => -x^^4 + 5 * x^^2 - 4;
        auto f1 = (S x) => 10 * x - 4 * x ^^ 3;
        auto f2 = (S x) => 10 - 12 * x ^^ 2;
        S[] cs = [1.3, 1.4, 1.5, 1.6];
        S[] points = [-3, -1.5, 0, 1.5, 3];
        auto ips = flexIntervals(f0, f1, f2, cs, points, S(1.1));

        assert(ips.map!`a.hatArea`.equal!approxEqual(hats));
        assert(ips.map!`a.squeezeArea`.equal!approxEqual(sqs));
    }
}

// test standard normal distribution
unittest
{
    import mir.internal.math : exp, sqrt;
    import std.algorithm : equal, map;
    import std.meta : AliasSeq;
    import std.math : approxEqual, PI;
    static immutable hats = [1.60809, 2.23537, 0.797556, 1.23761, 1.60809];
    static immutable sqs = [1.52164, 1.94559, 0.776976, 1.19821, 1.52164];

    foreach (S; AliasSeq!(float, double, real))
    {
        S sqrt2PI = sqrt(2 * PI);
        auto f0 = (S x) => 1 / (exp(x * x / 2) * sqrt2PI);
        auto f1 = (S x) => -(x/(exp(x * x/2) * sqrt2PI));
        auto f2 = (S x) => (-1 + x * x) / (exp(x * x/2) * sqrt2PI);
        S[] cs = [1.5, 1.5, 1.5, 1.5];
        S[] points = [-3, -1.5, 0, 1.5, 3];
        auto ips = flexIntervals(f0, f1, f2, cs, points, S(1.1));

        assert(ips.map!`a.hatArea`.equal!approxEqual(hats));
        assert(ips.map!`a.squeezeArea`.equal!approxEqual(sqs));
    }
}

unittest
{
    import std.algorithm : equal, map;
    import std.array : array;
    import std.math : approxEqual;
    import std.meta : AliasSeq;
    import std.range : repeat;
    import mir.internal.math : log;

    static immutable hats = [0.00648327, 0.0133705, 0.33157, 0.5, 0.5, 0.16167,
                             0.136019, 0.0133705, 0.00648327];

    static immutable sqs = [0, 0.0125563, 0.274612, 0.484543, 0.484543,
                            0.156698, 0.12444, 0.0125563, 0];

    foreach (S; AliasSeq!(float, real))
    {
        auto f0 = (S x) => cast(S) log(1 - x^^4);
        auto f1 = (S x) => S(-4) * x^^3 / (1 - x^^4);
        auto f2 = (S x) => -(S(4) * x^^6 + 12 * x^^2) / (x^^8 - 2 * x^^4 + 1);
        S[] points = [S(-1), -0.9, -0.5, 0.5, 0.9, 1];
        S[] cs = S(2).repeat(points.length - 1).array;

        auto ips = flexIntervals(f0, f1, f2, cs, points, S(1.1));
        assert(ips.map!`a.hatArea`.equal!approxEqual(hats));
        assert(ips.map!`a.squeezeArea`.equal!approxEqual(sqs));
    }

    // double behavior is different
    {
        alias S = double;

        S[] hatsD = [0.0229267, 0.33157, 0.5, 0.5, 0.16167, 0.136019, 0.0229267];
        S[] sqsD =  [0, 0.274612, 0.484543, 0.484543, 0.156698, 0.12444, 0];

        auto f0 = (S x) => cast(S) log(1 - x^^4);
        auto f1 = (S x) => -S(4) * x^^3 / (1 - x^^4);
        auto f2 = (S x) => -(S(4) * x^^6 + 12 * x^^2) / (x^^8 - 2 * x^^4 + 1);
        S[] points = [S(-1), -0.9, -0.5, 0.5, 0.9, 1];
        S[] cs = S(2).repeat(points.length - 1).array;

        auto ips = flexIntervals(f0, f1, f2, cs, points, S(1.1));

        assert(ips.map!`a.hatArea`.equal!approxEqual(hatsD));
        assert(ips.map!`a.squeezeArea`.equal!approxEqual(sqsD));
    }
}

/**
Compute inverse transformation of a T_c family given point x.
Based on Table 1, column 3 of Botts et al. (2013).

Params:
    common = can c be 0, -0.5, -1 or 1
    x = value to transform
    c = T_c family to use for the transformation

Returns: flex-inversed value of x
*/
S flexInverse(bool common = false, S)(in S x, in S c)
{
    import mir.internal.math : pow, fabs, exp, copysign;
    import std.math: sgn;
    assert(sgn(c) * x >= 0);
    static if (!common)
    {
        if (c == 0)
            return exp(x);
        if (c == S(-0.5))
            return 1 / (x * x);
        if (c == -1)
            return -1 / x;
        if (c == 1)
            return x;
    }
    // LDC intrinsics compiles to the assembler powf which yields different results
    return pow(fabs(x), 1 / c);
}

unittest
{
    import std.math: E, approxEqual;
    import std.meta : AliasSeq;
    foreach (S; AliasSeq!(float, double, real))
    {
        assert(flexInverse!(false, S)(1, 0).approxEqual(E));

        assert(flexInverse!(false, S)(2, 1) == 2);
        assert(flexInverse!(false, S)(8, 1) == 8);

        assert(flexInverse!(false, S)(1, 1.5) == 1);
        assert(flexInverse!(false, S)(2, 1.5).approxEqual(1.58740));
    }
}

unittest
{
    import std.math;
    import std.meta : AliasSeq;
    foreach (S; AliasSeq!(float, double, real))
    {
        S[][] results = [
            [S.nan, S.nan, S.nan, S.nan, S.nan, S.nan, S(0),
             0.707106781186548, 1, 1.224744871391589,
             1.414213562373095, 1.581138830084190, 1.73205080756887],
            [S.nan, S.nan, S.nan, S.nan, S.nan, S.nan, S(0),
             0.629960524947437, 1, 1.310370697104448,
             1.587401051968199, 1.842015749320193, 2.080083823051904],
            [-3, -2.5, -2, -1.5, -1, -0.5, S(0), 0.5, 1, 1.5, 2, 2.5, 3],
            [S.nan, S.nan, S.nan, S.nan, S.nan, S.nan, S(0),
             0.462937356143645, 1, 1.569122877964822,
             2.160119477784612, 2.767932947224778, 3.389492891729259],
            [9, 6.25, 4, 2.25, 1, 0.25, S(0),
             0.25, 1, 2.25, 4, 6.25, 9],
            [0.0497870683678639, 0.0820849986238988, 0.1353352832366127,
             0.2231301601484298, 0.3678794411714423, 0.6065306597126334,
             S(1), 1.6487212707001282, 2.7182818284590451, 4.4816890703380645,
             7.3890560989306504, 12.1824939607034732, 20.0855369231876679],
            [S(1)/S(9), 0.16, 0.25, S(4)/S(9), 1, 4, S.infinity, 4,
             1, S(4)/S(9), 0.25, 0.16, S(1)/S(9)],
            [0.295029384023820, 0.361280428054673, 0.462937356143645,
             0.637298718948650, 1, 2.160119477784612, S.infinity,
             S.nan, S.nan, S.nan, S.nan, S.nan, S.nan],
            [S(1)/S(3), 0.4, 0.5, S(2)/S(3), 1, 2, S.infinity, -2,
             -1, -S(2)/S(3), -0.5, -0.4, -S(1)/S(3)],
            [0.480749856769136, 0.542883523318981, 0.629960524947437,
             0.763142828368888, 1, 1.587401051968199, S.infinity,
             S.nan, S.nan, S.nan, S.nan, S.nan, S.nan],
            [0.577350269189626, 0.632455532033676, 0.707106781186548,
             0.816496580927726, 1, 1.414213562373095, S.infinity,
             S.nan, S.nan, S.nan, S.nan, S.nan, S.nan],
        ];
        S[] xs = [-3, -2.5, -2, -1.5, -1, -0.5, 0, 0.5, 1, 1.5, 2, 2.5, 3.0];
        S[] cs = [2, 1.5, 1, 0.9, 0.5, 0, -0.5, -0.9, -1, -1.5, -2];

        foreach (i, c; cs)
        {
            foreach (j, x; xs)
            {
                if (sgn(c) * x >= 0)
                {
                    S r = results[i][j];
                        S v = flexInverse!(false, S)(x, c);
                    if (r.isInfinity)
                        assert(v.isInfinity);
                    else
                        assert(v.approxEqual(r));
                }
            }
        }
    }
}