module mir.random.flex.internal.area;

import mir.random.flex.internal.types : Interval;
import std.traits : ReturnType;

version(Flex_logging)
{
    import std.experimental.logger;
}

/*
FP operations depend on
 - the compiler (e.g. std.math.pow yields different results to llvm_pow)
 - the architecture (DMD x86 without optimization is unpredictable)
 - the OS (Windows has FP magic (e.g. bug 16344)

=> we use DMD64 as "true" reference and approxEqual for other compilers
*/
version(unittest)
{
    // the difference is marginal, but measurable
    version(Windows)
    {
        version = Flex_fpEqual;
    }
    else
    {
        version(DigitalMars)
        {
            version(X86_64)
            {
                alias fpEqual = (a, b) => a == b;
            }
            else
            {
                version = Flex_fpEqual;
            }
        }
        else
        {
            version = Flex_fpEqual;
        }
    }
    version(Flex_fpEqual)
    {
        import std.math : approxEqual;
        bool fpEqual(float a, float b) { return a.approxEqual(b, 1e-5, 1e-5); }
        bool fpEqual(double a, double b) { return a.approxEqual(b, 1e-14, 1e-14); }

        // probably yet another LDC Windows bug
        version(LDC)
            version(Windows)
                enum real maxError = 1e-14;
            else
                enum real maxError = 1e-18;
        else
            enum real maxError = 1e-18;

        bool fpEqual(real a, real b) { return a.approxEqual(b, 1e-18, 1e-18); }
    }
}

/**
Determines the hat and squeeze function of an interval.
Based on Theorem 1 of Botts et al. (2013).

The hat and squeeze function are set in-place in the given `Interval`.

Params:
    iv = Interval to calculate hat and squeeze for
*/
void determineSqueezeAndHat(S)(ref Interval!S iv)
{
    import mir.utility.linearfun : linearFun;
    import mir.random.flex.internal.types : determineType, FunType;

    // y (aka x0) is defined to be the maximal point of the boundary points
    enum sec = `(iv.ltx >= iv.rtx) ?
                linearFun!S((iv.rtx - iv.ltx) / (iv.rx - iv.lx), iv.lx, iv.ltx) :
                linearFun!S((iv.rtx - iv.ltx) / (iv.rx - iv.lx), iv.rx, iv.rtx)`;

    enum t_l = "linearFun!S(iv.lt1x, iv.lx, iv.ltx)";
    enum t_r = "linearFun!S(iv.rt1x, iv.rx, iv.rtx)";

    // could potentially be saved for subsequent calls
    FunType type = determineType(iv);
    with(FunType) with(iv)
    switch(type)
    {
        case T1a:
            squeeze = mixin(t_r);
            hat = mixin(t_l);
            break;
        case T1b:
            squeeze = mixin(t_l);
            hat = mixin(t_r);
            break;
        case T2a:
            squeeze = mixin(sec);
            hat = mixin(t_l);
            break;
        case T2b:
            squeeze = mixin(sec);
            hat = mixin(t_r);
            break;
        case T3a:
            squeeze = mixin(t_r);
            hat = mixin(sec);
            break;
        case T3b:
            squeeze = mixin(t_l);
            hat = mixin(sec);
            break;
        case T4a:
            // In each unbounded interval f must be concave and strictly monotone
            // Condition 4 in section 2.3 from Botts et al. (2013)
            if (iv.lx == -S.infinity)
            {
                squeeze = squeeze.init;
                hat = mixin(t_r);
                break;
            }
            if (iv.rx == +S.infinity)
            {
                squeeze = squeeze.init;
                hat = mixin(t_l);
                break;
            }
            squeeze = mixin(sec);
            hat = iv.ltx > iv.rtx ? mixin(t_l) : mixin(t_r);
            break;
        case T4b:
            // In each unbounded interval f must be concave and strictly monotone
            // Condition 4 in section 2.3 from Botts et al. (2013)
            if (iv.lx == -S.infinity)
            {
                hat = hat.init;
                squeeze = mixin(t_l);
                break;
            }
            if (iv.rx == +S.infinity)
            {
                hat = hat.init;
                squeeze = mixin(t_r);
                break;
            }
            squeeze = iv.ltx < iv.rtx ? mixin(t_l) : mixin(t_r);
            hat = mixin(sec);
            break;
        default:
            // this case shouldn't occur in production, but if we don't want to SEGFAULT or HALT
            squeeze = linearFun!S(0, 0, 0);
            hat = linearFun!S(0, 0, 0);
    }
}

unittest
{
    import std.meta : AliasSeq;
    import mir.random.flex.internal.types: determineType;
    foreach (S; AliasSeq!(float, double, real))
    {
        const f0 = (S x) => x * x;
        const f1 = (S x) => 2 * x;
        const f2 = (S x) => 2.0;
        auto c = 42; // not required for this test
        auto dhs = (S l, S r) {
            auto iv = Interval!S(l, r, c, f0(l), f1(l), f2(l),
                                          f0(r), f1(r), f2(r));
            determineSqueezeAndHat(iv);
            return iv;
        };

        // test left side
        auto hs1 = dhs(-1, 1);
        assert(hs1.hat.slope == 0);
        assert(hs1.hat.intercept == 1);
        assert(hs1.squeeze.slope == 2);
        assert(hs1.squeeze.intercept == -1);

        // test right side
        auto hs2 = dhs(1, 3);
        assert(hs2.hat.slope == 4);
        assert(hs2.hat.intercept == -3);
        assert(hs2.squeeze.slope == 2);
        assert(hs2.squeeze.intercept == -1);
    }
}

// test undefined type
unittest
{
    import mir.internal.math : fabs, log;
    import mir.random.flex.internal.transformations : transformInterval;
    import mir.random.flex.internal.types : determineType, FunType;
    import mir.utility.linearfun : linearFun;
    import std.meta : AliasSeq;
    static immutable ps = [-0.5, 0, 0.5];
    foreach (S; AliasSeq!(float, double, real))
    {
        auto f0 = (S x) => -log(fabs(x)) / 2;
        auto f1 = (S x) => -1 / (2 * x);
        auto f2 = (S x) => 1 / (2 * x * x);

        foreach (i; 0..ps.length - 1)
        {
            S l = ps[i], r = ps[i + 1];
            S c = -2;
            auto iv = Interval!S(l, r, c, f0(l), f1(l), f2(l), f0(r), f1(r), f2(r));
            transformInterval(iv);

            FunType t = determineType(iv);
            assert(t == FunType.undefined);

            determineSqueezeAndHat(iv);
            assert(iv.squeeze == linearFun!S(0, 0, 0));
            assert(iv.hat == linearFun!S(0, 0, 0));
        }
    }
}

/**
Flex-specific constants cutoffs for numeric errors.
*/
template constants(S)
{
    import mir.internal.math: sqrt;
    enum S smallLog = sqrt(sqrt(S.epsilon * 5));
    enum S smallExp = sqrt(sqrt(S.epsilon * 120));
}

alias hatArea(S) = area!(true, S);
alias squeezeArea(S) = area!(false, S);

/**
Computes the area below either the hat or squeeze function
in-between a interval `iv`.
Based on table 1, 2 and general equation (3) from Botts et al. (2013).

    (F_T(sh(r))- F_T(sh(l))) / sh.slope

Params:
    isHat = whether to calculate the hat or squeeze area
    iv = Interval to use

Returns: Computed area below either hat or squeeze.
*/
void area(bool isHat, S)(ref Interval!S iv)
in
{
    assert(iv.lx < iv.rx, "invalid interval");
}
body
{
    import std.math: signbit, frexp, LOG2E, isFinite;
    import mir.internal.math: copysign, exp, log2, fabs;
    import mir.random.flex.internal.transformations : antiderivative;
    import mir.random.flex : flexInverse;
    enum one_div_3 = S(1) / 3;
    enum one_div_6 = S(1) / 6;
    enum one_div_24 = S(1) / 24;

    S area = void;

    static if (isHat)
        auto sh = iv.hat;
    else
        auto sh = iv.squeeze;

    // check difference to left and right starting point
    // sigma in the paper (1: left side, -1, right side
    immutable S leftOrRight = (iv.rx - sh.y) > (sh.y - iv.lx) ? 1 : -1;
    immutable S shL = sh(iv.lx);
    immutable S shR = sh(iv.rx);
    immutable S ivLength = iv.rx - iv.lx;
    auto z = leftOrRight * sh.slope * ivLength;

    // sh.y is the boundary point where f obtains its maximum

    // specializations for T_c family (page 6, table 2 from Botts et al. (2013))
    if (iv.c == 0)
    {
        if (fabs(z) < constants!S.smallExp)
        {
            area = exp(sh.a);
            S t = (z * z * z) * one_div_24;
            t += 1 + z * S(0.5) + (z * z) * one_div_6;
            area *= t;
            area *= ivLength;
        }
        else
        {
            area = exp(shR) - exp(shL);
            area /= sh.slope;
        }
    }
    else
    {
        z /= sh.a;
        auto sgnc = copysign(S(1), iv.c);
        if (!(sgnc * shL >= 0) || !(sgnc * shR >= 0))
        {
            area = S.max;
        }
        else if (iv.c == 1)
        {
            area = S(0.5) * sh.a * ivLength;
            S t = z + 2;
            area *= t;
        }
        else if (iv.c == S(-0.5))
        {
            if (fabs(z) < S(0.5))
            {
                area = 1 / (sh.a * sh.a) * ivLength / (z + 1);
            }
            else
            {
                S _l = 1 / shL;
                S _r = 1 / shR;
                area = (_l - _r) / sh.slope;
            }
        }
        else if (iv.c == -1)
        {
            if (fabs(z) < constants!S.smallLog)
            {
                area = 1 - z * S(0.5) + z * z * one_div_3;
                area *=  -ivLength;
                area /= sh.a;
            }
            else
            {
                int lexp = void, rexp = void;
                S b = frexp(-shL, lexp);
                b /= frexp(-shR, rexp);
                immutable S rem = log2(b);
                area = lexp - rexp + rem;
                area /= sh.slope;
                area /= S(LOG2E);
            }
        }
        else
        {
            if (fabs(sh.slope) < S(1e-10))
            {
                import std.math: sgn;
                assert(sh.a * sgn(iv.c) >= 0);
                area = flexInverse!true(sh.a, iv.c);
                area *= ivLength;
            }
            else
            {
                // workaround for @@@BUG 16341 @@@
                S r = antiderivative!true(shR, iv.c);
                S l = antiderivative!true(shL, iv.c);
                area = r - l;
                area /= sh.slope;
            }
        }
    }

    // if we receive an invalid value, we require the interval to be split
    if (!isFinite(area))
        area = S.max;
    else if (area < 0)
        area = S.max;

    static if (!isHat)
    {
        // squeeze may return infinity
        if (area == S.max)
        {
            area = 0;
        }
    }

    static if (isHat)
        iv.hatArea = area;
    else
        iv.squeezeArea = area;
}

// example from Botts et al. (2013) (distribution 1)
// split up into all three floating-point types
unittest
{
    import mir.random.flex.internal.transformations : transformInterval;
    import mir.random.flex.internal.types : determineType;
    import std.math: approxEqual;
    import std.meta : AliasSeq;
    import std.range: dropOne, lockstep, save;

    alias S = float;

    // inflection points: -1.7620, -1.4012, 1.4012, 1.7620
    static immutable S[] points = [-3.0, -1.5, 0.0, 1.5, 3];
    static immutable S[] cs = [-2, -1.5, -1, -0.9, -0.5, -0.2, 0, 0.2, 0.5, 0.9, 1, 1.5, 2];
    static immutable S[][] hats = [
        [0x1.fffffep+127, 0x1.ff8f94p+2, 0x1.ff8f94p+2, 0x1.fffffep+127],
        [0x1.fffffep+127, 0x1.e35dbap+2, 0x1.e35dbap+2, 0x1.fffffep+127],
        [0x1.fffffep+127, 0x1.c03936p+2, 0x1.c03936p+2, 0x1.fffffep+127],
        [0x1.fffffep+127, 0x1.b817f4p+2, 0x1.b817f4p+2, 0x1.fffffep+127],
        [0x1.fffffep+127, 0x1.92a74cp+2, 0x1.92a74cp+2, 0x1.fffffep+127],
        [0x1.26f6cep+6, 0x1.6fd21ep+2, 0x1.6fd21ep+2, 0x1.26f6cep+6], /* - 0.2 */
        [0x1.9377f8p+5, 0x1.5433c6p+2, 0x1.5433c6p+2, 0x1.9377f8p+5],
        [0x1.488dc6p+5, 0x1.34218cp+2, 0x1.34218cp+2, 0x1.488dc6p+5],
        [0x1.10668ep+5, 0x1.2aba6ap+2, 0x1.2aba6ap+2, 0x1.10668ep+5],
        [0x1.d3c25p+4, 0x1.96da06p+2, 0x1.96da06p+2, 0x1.d3c25p+4],
        [0x1.c68edcp+4, 0x1.acb2dp+2, 0x1.acb2dp+2, 0x1.c68edcp+4],
        [0x1.97046ep+4, 0x1.00b728p+3, 0x1.00b728p+3, 0x1.97046ep+4],
        [0x1.791264p+4, 0x1.1d36dp+3, 0x1.1d36dp+3, 0x1.791264p+4]
    ];

    static immutable S[][] sqs = [
        [0x1.d635b6p-57, 0x1.c2200ap-6, 0x1.c2200ap-6, 0x1.d635b6p-57],
        [0x1.60a856p-56, 0x1.c22004p-6, 0x1.c22004p-6, 0x1.60a856p-56],
        [0x1.35f3e8p-52, 0x1.c2200ap-6, 0x1.c2200ap-6, 0x1.35f3e8p-52],
        [0x1.14ada2p-48, 0x1.c22008p-6, 0x1.c22008p-6, 0x1.14ada2p-48],
        [0x1.3d25b8p-27, 0x1.c22008p-6, 0x1.c22008p-6, 0x1.3d25b8p-27],
        [0x1.7b9ffcp-11, 0x1.c2200cp-6, 0x1.c2200cp-6, 0x1.7b9ffcp-11],
        [0x1.448246p-2, 0x1.c2200ap-6, 0x1.c2200ap-6, 0x1.448246p-2],
        [0x1.5100bap-37, 0x1.c22008p-6, 0x1.c22008p-6, 0x1.5100bap-37],
        [0x1.13922ap-47, 0x1.c2200ap-6, 0x1.c2200ap-6, 0x1.13922ap-47],
        [0x1.d6357ap-58, 0x1.c22008p-6, 0x1.c22008p-6, 0x1.d6357ap-58],
        [0x1.b525f2p-52, 0x1.c2200ap-6, 0x1.c2200ap-6, 0x1.b525f2p-52],
        [0x1.d63592p-58, 0x1.c22008p-6, 0x1.c22008p-6, 0x1.d63592p-58],
        [0x1.d635b6p-58, 0x1.c2200ap-6, 0x1.c2200ap-6, 0x1.d635b6p-58]
    ];

    const f0 = (S x) => -x^^4 + 5 * x^^2 - 4;
    const f1 = (S x) => 10 * x - 4 * x ^^ 3;
    const f2 = (S x) => 10 - 12 * x ^^ 2;

    auto it = (S l, S r, S c)
    {
        auto iv = Interval!S(l, r, c, f0(l), f1(l), f2(l), f0(r), f1(r), f2(r));
        transformInterval(iv);
        return iv;
    };

    import std.math : isInfinity;
    import std.conv;

    // calculate the area of all intervals
    foreach (i, c; cs)
    {
        foreach (j, p1, p2; points.lockstep(points.save.dropOne))
        {
            auto iv = it(p1, p2, c);
            version(Flex_logging)
            {
                scope(failure)
                {
                    logf("c=%g, p1=%g,p2=%g, hat=%g, squeeze=%f",
                                     c, p1, p2, iv.hatArea, iv.squeezeArea);
                    version(Flex_logging_hex) logf("hat: %a, squeeze: %a", iv.hatArea, iv.squeezeArea);
                    version(Flex_logging_hex) logf("exp. hat: %a, squeeze: %a", hats[i][j], sqs[i][j]);
                    version(Flex_logging_hex) logf("iv: %s", iv.logHex);
                }
            }

            determineSqueezeAndHat(iv);

            hatArea!S(iv);
            assert(iv.hatArea.fpEqual(hats[i][j]));

            squeezeArea!S(iv);
            assert(iv.squeezeArea.fpEqual(sqs[i][j]));
        }
    }
}

unittest
{
    import mir.random.flex.internal.transformations : transformInterval;
    import mir.random.flex.internal.types : determineType;
    import std.math: approxEqual;
    import std.meta : AliasSeq;
    import std.range: dropOne, lockstep, save;

    alias S = double;

    // inflection points: -1.7620, -1.4012, 1.4012, 1.7620
    static immutable S[] points = [-3.0, -1.5, 0.0, 1.5, 3];
    static immutable S[] cs = [-2, -1.5, -1, -0.9, -0.5, -0.2, 0, 0.2, 0.5, 0.9, 1, 1.5, 2];
    static immutable S[][] hats = [
        [0x1.fffffffffffffp+1023, 0x1.ff8f9396f50e2p+2, 0x1.ff8f9396f50e2p+2, 0x1.fffffffffffffp+1023],
        [0x1.fffffffffffffp+1023, 0x1.e35db2669856ep+2, 0x1.e35db2669856ep+2, 0x1.fffffffffffffp+1023],
        [0x1.fffffffffffffp+1023, 0x1.c039357a17c94p+2, 0x1.c039357a17c93p+2, 0x1.fffffffffffffp+1023],
        [0x1.fffffffffffffp+1023, 0x1.b817e89389152p+2, 0x1.b817e89389152p+2, 0x1.fffffffffffffp+1023],
        [0x1.fffffffffffffp+1023, 0x1.92a74bbc5a7adp+2, 0x1.92a74bbc5a7adp+2, 0x1.fffffffffffffp+1023],
        [0x1.26f6ccfd68206p+6, 0x1.6fd2200cf8904p+2, 0x1.6fd2200cf8904p+2, 0x1.26f6ccfd68206p+6],
        [0x1.9377f7682099fp+5, 0x1.5433c5c5bde25p+2, 0x1.5433c5c5bde25p+2, 0x1.9377f7682099fp+5],
        [0x1.488dcf1f4309dp+5, 0x1.342191ef6599bp+2, 0x1.342191ef6599bp+2, 0x1.488dcf1f4309dp+5],
        [0x1.10668d8c7c75fp+5, 0x1.2aba68fec7377p+2, 0x1.2aba68fec7377p+2, 0x1.10668d8c7c75fp+5],
        [0x1.d3c24e4b0f649p+4, 0x1.96da0243d87adp+2, 0x1.96da0243d87adp+2, 0x1.d3c24e4b0f649p+4],
        [0x1.c68edc7fa224cp+4, 0x1.acb2d07cc1b15p+2, 0x1.acb2d07cc1b15p+2, 0x1.c68edc7fa224cp+4],
        [0x1.970471d957273p+4, 0x1.00b7291aa85c7p+3, 0x1.00b7291aa85c7p+3, 0x1.970471d957273p+4],
        [0x1.791263cd3b075p+4, 0x1.1d36cf1551b79p+3, 0x1.1d36cf1551b79p+3, 0x1.791263cd3b075p+4]
    ];

    static immutable S[][] sqs = [
        [0x1.d635b6e68a736p-57, 0x1.c22009431db6ep-6, 0x1.c22009431db6ep-6, 0x1.d635b6e68a736p-57],
        [0x1.60a84928d21eep-56, 0x1.c22009431db71p-6, 0x1.c22009431db71p-6, 0x1.60a84928d21eep-56],
        [0x1.35f3e85077c39p-52, 0x1.c22009431db6fp-6, 0x1.c22009431db6fp-6, 0x1.35f3e85077c39p-52],
        [0x1.14ada3f2c1d78p-48, 0x1.c22009431db6cp-6, 0x1.c22009431db6cp-6, 0x1.14ada3f2c1d78p-48],
        [0x1.3d25b762ac29ap-27, 0x1.c22009431db6ep-6, 0x1.c22009431db6ep-6, 0x1.3d25b762ac29ap-27],
        [0x1.7b9ffcbb90945p-11, 0x1.c22009431db6ap-6, 0x1.c22009431db6ap-6, 0x1.7b9ffcbb90945p-11],
        [0x1.448246e5ed23bp-2, 0x1.c22009431db6ep-6, 0x1.c22009431db6ep-6, 0x1.448246e5ed23bp-2],
        [0x1.5100bdf24c8cap-37, 0x1.c22009431db6cp-6, 0x1.c22009431db6cp-6, 0x1.5100bdf24c8cap-37],
        [0x1.13922ad8cc53fp-47, 0x1.c22009431db7p-6, 0x1.c22009431db7p-6, 0x1.13922ad8cc53fp-47],
        [0x1.d635b6e68a727p-58, 0x1.c22009431db6cp-6, 0x1.c22009431db6cp-6, 0x1.d635b6e68a727p-58],
        [0x1.b525f00a54b74p-52, 0x1.c22009431db6ep-6, 0x1.c22009431db6ep-6, 0x1.b525f00a54b74p-52],
        [0x1.d635b6e68a748p-58, 0x1.c22009431db71p-6, 0x1.c22009431db71p-6, 0x1.d635b6e68a748p-58],
        [0x1.d635b6e68a736p-58, 0x1.c22009431db7p-6, 0x1.c22009431db7p-6, 0x1.d635b6e68a736p-58]
    ];

    const f0 = (S x) => -x^^4 + 5 * x^^2 - 4;
    const f1 = (S x) => 10 * x - 4 * x ^^ 3;
    const f2 = (S x) => 10 - 12 * x ^^ 2;

    auto it = (S l, S r, S c)
    {
        auto iv = Interval!S(l, r, c, f0(l), f1(l), f2(l), f0(r), f1(r), f2(r));
        transformInterval(iv);
        return iv;
    };

    import std.math : isInfinity;
    import std.conv;

    // calculate the area of all intervals
    foreach (i, c; cs)
    {
        foreach (j, p1, p2; points.lockstep(points.save.dropOne))
        {
            auto iv = it(p1, p2, c);
            version(Flex_logging)
            {
                scope(failure)
                {
                    logf("c=%g, p1=%g,p2=%g, hat=%g, squeeze=%f",
                                     c, p1, p2, iv.hatArea, iv.squeezeArea);
                    version(Flex_logging_hex) logf("hat: %a, squeeze: %a", iv.hatArea, iv.squeezeArea);
                    version(Flex_logging_hex) logf("exp. hat: %a, squeeze: %a", hats[i][j], sqs[i][j]);
                    version(Flex_logging_hex) logf("iv: %s", iv.logHex);
                }
            }

            determineSqueezeAndHat(iv);

            hatArea!S(iv);
            assert(iv.hatArea.fpEqual(hats[i][j]));

            squeezeArea!S(iv);
            assert(iv.squeezeArea.fpEqual(sqs[i][j]));
        }
    }
}

unittest
{
    import mir.random.flex.internal.transformations : transformInterval;
    import mir.random.flex.internal.types : determineType;
    import std.math: approxEqual;
    import std.meta : AliasSeq;
    import std.range: dropOne, lockstep, save;

    alias S = real;

    // inflection points: -1.7620, -1.4012, 1.4012, 1.7620
    static immutable S[] points = [-3.0, -1.5, 0.0, 1.5, 3];
    static immutable S[] cs = [-2, -1.5, -1, -0.9, -0.5, -0.2, 0, 0.2, 0.5, 0.9, 1, 1.5, 2];
    static immutable S[][] hats = [
        [S.max, 0xf.fc7c9cb7a87140cp-1, 0xf.fc7c9cb7a87140cp-1, S.max],
        [S.max, 0xf.1aed9334c2b6f0fp-1, 0xf.1aed9334c2b6f0fp-1, S.max],
        [S.max, 0xe.01c9abd0be49affp-1, 0xe.01c9abd0be49affp-1, S.max],
        [S.max, 0xd.c0bf449c48aa21bp-1, 0xd.c0bf449c48aa21bp-1, S.max],
        [S.max, 0xc.953a5de2d3d6f01p-1, 0xc.953a5de2d3d6f01p-1, S.max],
        [0x9.37b667eb41023fcp+3, 0xb.7e910067c482675p-1, 0xb.7e910067c482675p-1, 0x9.37b667eb41023fcp+3],
        [0xc.9bbfbb4104cf353p+2, 0xa.a19e2e2def1264cp-1, 0xa.a19e2e2def1264cp-1, 0xc.9bbfbb4104cf353p+2],
        [0xa.446e78fa184e4b1p+2, 0x9.a10c8f7b2ccdb53p-1, 0x9.a10c8f7b2ccdb53p-1, 0xa.446e78fa184e4b1p+2],
        [0x8.83346c63e3aff87p+2, 0x9.55d347f639bbc7fp-1, 0x9.55d347f639bbc7fp-1, 0x8.83346c63e3aff87p+2],
        [0xe.9e1272587b22107p+1, 0xc.b6d0121ec3d5d6ep-1, 0xc.b6d0121ec3d5d6ep-1, 0xe.9e1272587b22107p+1],
        [0xe.3476e3fd1125a4fp+1, 0xd.659683e60d8b3acp-1, 0xd.659683e60d8b3acp-1, 0xe.3476e3fd1125a4fp+1],
        [0xc.b8238ecab9389e8p+1, 0x8.05b948d542e2c47p+0, 0x8.05b948d542e2c47p+0, 0xc.b8238ecab9389e8p+1],
        [0xb.c8931e69d83ab2dp+1, 0x8.e9b678aa8dbcf0ep+0, 0x8.e9b678aa8dbcf0ep+0, 0xb.c8931e69d83ab2dp+1]
    ];

    static immutable S[][] sqs = [
        [0xe.b1adb734539b1dcp-60, 0xe.11004a18edb759dp-9, 0xe.11004a18edb759dp-9, 0xe.b1adb734539b1dcp-60],
        [0xb.0542494690fac27p-59, 0xe.11004a18edb759dp-9, 0xe.11004a18edb759dp-9, 0xb.0542494690fac27p-59],
        [0x9.af9f4283be1c807p-55, 0xe.11004a18edb759dp-9, 0xe.11004a18edb759dp-9, 0x9.af9f4283be1c807p-55],
        [0x8.a56d1f960ebb8aep-51, 0xe.11004a18edb759dp-9, 0xe.11004a18edb759dp-9, 0x8.a56d1f960ebb8aep-51],
        [0x9.e92dbb15614d431p-30, 0xe.11004a18edb759ep-9, 0xe.11004a18edb759ep-9, 0x9.e92dbb15614d431p-30],
        [0xb.dcffe5dc84a2a02p-14, 0xe.11004a18edb7598p-9, 0xe.11004a18edb7598p-9, 0xb.dcffe5dc84a2a02p-14],
        [0xa.2412372f691d7bbp-5, 0xe.11004a18edb759dp-9, 0xe.11004a18edb759dp-9, 0xa.2412372f691d7bbp-5],
        [0xa.8805ef926456f8dp-40, 0xe.11004a18edb7598p-9, 0xe.11004a18edb7598p-9, 0xa.8805ef926456f8dp-40],
        [0x8.9c9156c6629f808p-50, 0xe.11004a18edb759cp-9, 0xe.11004a18edb759cp-9, 0x8.9c9156c6629f808p-50],
        [0xe.b1adb734539b1bap-61, 0xe.11004a18edb759dp-9, 0xe.11004a18edb759dp-9, 0xe.b1adb734539b1bap-61],
        [0xd.a92f8052a5ba36p-55, 0xe.11004a18edb759dp-9, 0xe.11004a18edb759dp-9, 0xd.a92f8052a5ba36p-55],
        [0xe.b1adb734539b1e3p-61, 0xe.11004a18edb759dp-9, 0xe.11004a18edb759dp-9, 0xe.b1adb734539b1e3p-61],
        [0xe.b1adb734539b1e3p-61, 0xe.11004a18edb759dp-9, 0xe.11004a18edb759dp-9, 0xe.b1adb734539b1e3p-61]
    ];

    const f0 = (S x) => -x^^4 + 5 * x^^2 - 4;
    const f1 = (S x) => 10 * x - 4 * x ^^ 3;
    const f2 = (S x) => 10 - 12 * x ^^ 2;

    auto it = (S l, S r, S c)
    {
        auto iv = Interval!S(l, r, c, f0(l), f1(l), f2(l), f0(r), f1(r), f2(r));
        transformInterval(iv);
        return iv;
    };

    import std.math : isInfinity;
    import std.conv;

    // calculate the area of all intervals
    foreach (i, c; cs)
    {
        foreach (j, p1, p2; points.lockstep(points.save.dropOne))
        {
            auto iv = it(p1, p2, c);
            version(Flex_logging)
            {
                scope(failure)
                {
                    version(Windows)
                    {
                        import std.math : nextDown, nextUp;
                        logf("got: %a", iv.squeezeArea);
                        logf("-- up: %a, down: %a", iv.squeezeArea.nextUp, iv.squeezeArea.nextDown);
                        logf("exp: %a", sqs[i][j]);
                        logf("-- up: %a, down: %a", sqs[i][j].nextUp, sqs[i][j].nextDown);
                        logf("%s", iv.squeezeArea == sqs[i][j]);
                        import std.math : approxEqual;
                        logf("%s", iv.squeezeArea.approxEqual(sqs[i][j]));
                        logf("pos: %d,%d", i, j);
                    }
                    logf("c=%g, p1=%g,p2=%g, hat=%g, squeeze=%f",
                                     c, p1, p2, iv.hatArea, iv.squeezeArea);
                    version(Flex_logging_hex) logf("hat: %a, squeeze: %a", iv.hatArea, iv.squeezeArea);
                    version(Flex_logging_hex) logf("exp. hat: %a, squeeze: %a", hats[i][j], sqs[i][j]);
                    version(Flex_logging_hex) logf("iv: %s", iv.logHex);
                }
            }

            import mir.random.flex.internal.transformations : antiderivative;

            determineSqueezeAndHat(iv);
            hatArea!S(iv);
            squeezeArea!S(iv);

            assert(iv.hatArea.fpEqual(hats[i][j]));
            assert(iv.squeezeArea.fpEqual(sqs[i][j]));
        }
    }
}

// standard normal distribution
unittest
{
    import mir.random.flex.internal.transformations : transformInterval;
    import mir.random.flex.internal.types : determineType;
    import std.math: approxEqual;
    import std.meta : AliasSeq;
    import std.range: dropOne, lockstep, save;

    static immutable points = [-3.0, -1.5, 0.0, 1.5, 3];
    static immutable cs = [50, 30, -20, -15, -10, -5, -3, -1, -0.5 -0.1, 0,
               0.1, 0.5, 1, 3, 5, 10, 15, 20, 30, 50];
    alias T = double;

    static immutable hats = [
            [1.67431896655145, 2.23537139944758, 2.23537139944758, 1.67431896655145],
            [1.65700745049712, 2.23537139944758, 2.23537139944758, 1.65700745049712],
            [1.60443687828298, 2.23537139944758, 2.23537139944758, 1.60443687828298],
            [1.59105983181206, 2.23537139944758, 2.23537139944758, 1.59105983181206],
            [1.58460606785453, 2.23537139944758, 2.23537139944758, 1.58460606785453],
            [1.59456909302941, 2.23537139944758, 2.23537139944758, 1.59456909302941],
            [1.59869179316417, 2.23537139944758, 2.23537139944758, 1.59869179316417],
            [1.60285750977850, 2.23537139944758, 2.23537139944758, 1.60285750977850],
            [1.60369357305562, 2.23537139944758, 2.23537139944758, 1.60369357305562],
            [1.60494851845389, 2.23537139944758, 2.23537139944758, 1.60494851845389],
            [1.60515773329117, 2.23537139944758, 2.23537139944758, 1.60515773329117],
            [1.60599463627441, 2.23537139944758, 2.23537139944758, 1.60599463627441],
            [1.60704061773156, 2.23537139944758, 2.23537139944758, 1.60704061773156],
            [1.61121503001525, 2.23537139944758, 2.23537139944758, 1.61121503001525],
            [1.61535496753299, 2.23537139944758, 2.23537139944758, 1.61535496753299],
            [1.62539615854004, 2.23537139944758, 2.23537139944758, 1.62539615854004],
            [1.63474405659451, 2.23537139944758, 2.23537139944758, 1.63474405659451],
            [1.64317897426652, 2.23537139944758, 2.23537139944758, 1.64317897426652],
            [1.65700745049712, 2.23537139944758, 2.23537139944758, 1.65700745049712],
            [1.67431896655145, 2.23537139944758, 2.23537139944758, 1.67431896655145],
    ];

    static immutable sqs = [
            [1.51833330996727, 1.77490696128331, 1.77490696128331, 1.51833330996727],
            [1.51942399916562, 1.79750552337956, 1.79750552337956, 1.51942399916562],
            [1.52435663489656, 1.79473210742505, 1.79473210742505, 1.52435663489656],
            [1.52358853655010, 1.81925875550887, 1.81925875550887, 1.52358853655010],
            [1.52291660567805, 1.85460628941149, 1.85460628941149, 1.52291660567805],
            [1.52232082514591, 1.90241787008622, 1.90241787008622, 1.52232082514591],
            [1.52210047700875, 1.92454531600287, 1.92454531600287, 1.52210047700875],
            [1.52188923770928, 1.94774502197384, 1.94774502197384, 1.52188923770928],
            [1.52184802383180, 1.95246040323233, 1.95246040323233, 1.52184802383180],
            [1.52178682577666, 1.95955574696794, 1.95955574696794, 1.52178682577666],
            [1.52177669779364, 1.96073980659116, 1.96073980659116, 1.52177669779364],
            [1.52173638800292, 1.96547718961052, 1.96547718961052, 1.52173638800292],
            [1.52168645018491, 1.95620207199188, 1.95620207199188, 1.52168645018491],
            [1.52149152523258, 1.92006225070127, 1.92006225070127, 1.52149152523258],
            [1.52130393244461, 1.89545328457997, 1.89545328457997, 1.52130393244461],
            [1.52086399284014, 1.85702081381895, 1.85702081381895, 1.52086399284014],
            [1.52046063869111, 1.83396234438399, 1.83396234438399, 1.52046063869111],
            [1.52008880012048, 1.81818347787266, 1.81818347787266, 1.52008880012048],
            [1.51942399916562, 1.79750552337956, 1.79750552337956, 1.51942399916562],
            [1.51833330996727, 1.77490696128331, 1.77490696128331, 1.51833330996727],
    ];

    foreach (S; AliasSeq!(float, double, real))
    {
        import mir.internal.math : exp, sqrt;
        import std.math : PI;

        S sqrt2PI = sqrt(2 * PI);
        auto f0 = (S x) => 1 / (exp(x * x / 2) * sqrt2PI);
        auto f1 = (S x) => -(x/(exp(x * x/2) * sqrt2PI));
        auto f2 = (S x) => (-1 + x * x) / (exp(x * x/2) * sqrt2PI);

        auto it = (S l, S r, S c)
        {
            auto iv = Interval!S(l, r, c, f0(l), f1(l), f2(l), f0(r), f1(r), f2(r));
            transformInterval(iv);
            return iv;
        };

        // calculate the area of all intervals
        foreach (i, c; cs)
        {
            foreach (j, p1, p2; points.lockstep(points.save.dropOne))
            {
                auto iv = it(p1, p2, c);
                determineSqueezeAndHat(iv);

                hatArea!S(iv);
                assert(iv.hatArea.approxEqual(hats[i][j]));

                squeezeArea!S(iv);
                assert(iv.squeezeArea.approxEqual(sqs[i][j]));
            }
        }
    }
}

// distribution 3
unittest
{
    import mir.random.flex.internal.transformations : transformInterval;
    import mir.random.flex.internal.types : determineType;
    import std.math: approxEqual, isInfinity;
    import std.meta : AliasSeq;
    import std.range: dropOne, lockstep, save;

    alias T = double;

    static immutable hats = [
        [0.0260342748818352, 0.341774164121358, T.infinity, 0.341774164121358, 0.0260342748818352],
        [0.0255195012598719, 0.340879607179185, 1.45967502781908, 0.340879607179185, 0.0255195012598719],
        [0.0249051103301305, 0.339910651723605, 1.33969931023869, 0.339910651723605, 0.0249051103301305],
        [0.0247671298819936, 0.339706935431057, 1.32474434347014, 0.339706935431057, 0.0247671298819936],
        [0.0241509516030223, 0.338855421686747, 1.27840909090909, 0.338855421686747, 0.0241509516030223],
        [0.0236042978029155, 0.338174820299361, 1.25280832701565, 0.338174820299361, 0.0236042978029155],
        [0.0231868425038531, 0.337698990123062, 1.23856323982515, 0.337698990123062, 0.0231868425038531],
        [0.02271505222945705, 0.337203971697137, 1.22602352052675, 0.337203971697137, 0.02271505222945705],
        [0.0218704478045944, 0.336422222222222, 1.20972222222222, 0.336422222222222, 0.0218704478045944],
        [0.020325745898257, 0.33529755225067, 1.19154057993372, 0.33529755225067, 0.020325745898257],
        [0.019810, 0.33500, 1.1875, 0.33500, 0.019810],
    ];

    static immutable sqs = [
        [0, 0.201283752146090, 0.9375, 0.201283752146090, 0],
        [0, 0.209217913884886, 0.9375, 0.209217913884886, 0],
        [0, 0.217877503273927, 0.9375, 0.217877503273927, 0],
        [0, 0.219685264865866, 0.9375, 0.219685264865866, 0],
        [0, 0.227123314523190, 0.9375, 0.227123314523190, 0],
        [0, 0.232873353231109, 0.9375, 0.232873353231109, 0],
        [0, 0.236761479385710, 0.9375, 0.236761479385710, 0],
        [0.00573166666666667, 0.240675568820739, 0.9375, 0.240675568820739, 0.00573166666666667],
        [0.0114633333333333, 0.246561104841063, 0.9375, 0.246561104841063, 0.0114633333333333],
        [0.01629, 0.25435396130873, 0.9375, 0.25435396130873, 0.01629],
        [0.017195, 0.25628, 0.9375, 0.25628, 0.017195],
    ];

    foreach (S; AliasSeq!(float, double, real))
    {

        import mir.internal.math : log;
        auto f0 = (S x) => log(1 - x^^4);
        auto f1 = (S x) => -4 * x^^3 / (1 - x^^4);
        auto f2 = (S x) => -(4 * x^^6 + 12 * x^^2) / (x^^8 - 2 * x^^4 + 1);

        auto it = (S l, S r, S c)
        {
            auto iv = Interval!S(l, r, c, f0(l), f1(l), f2(l), f0(r), f1(r), f2(r));
            transformInterval(iv);
            return iv;
        };

        S[] points = [-1, -0.9, -0.5, 0.5, 0.9, 1];
        // weird numerical bug prevents us from enabling 1.5
        // test values suffer from the imprecision as well
        S[] cs = [-2, -1.5, -1, -0.9, -0.5, -0.2, 0, 0.2, 0.5, 0.9, 1];

        // calculate the area of all intervals
        foreach (i, c; cs)
        {
            foreach (j, p1, p2; points.lockstep(points.save.dropOne))
            {
                auto iv = it(p1, p2, c);

                determineSqueezeAndHat!S(iv);

                hatArea!S(iv);
                if (iv.hatArea == S.max)
                    assert(hats[i][j].isInfinity);
                else
                    assert(iv.hatArea.approxEqual(hats[i][j]));

                squeezeArea!S(iv);
                assert(iv.squeezeArea.approxEqual(sqs[i][j]));
            }
        }
    }
}

// distribution 4
unittest
{
    import mir.internal.math : log;
    import mir.random.flex.internal.transformations : transformInterval;
    import mir.random.flex.internal.types : determineType;
    import std.math: abs, approxEqual, isInfinity;
    import std.meta : AliasSeq;
    import std.range: dropOne, lockstep, save;

    static immutable points = [-1, -0.5, 0, 0.5, 1];
    // -2 yields "undefined" type
    static immutable cs = [-1, -0.9, -0.5, 0, 0.5, 0.9, 1, 2];
    alias T = double;

    static immutable hats = [
        [0.591638126147109, T.infinity, T.infinity, 0.591638126147109],
        [0.592229601209145, T.infinity, T.infinity, 0.592229601209145],
        [0.594603557501361, T.infinity, T.infinity, 0.594603557501361],
        [0.597583852304615, T.infinity, T.infinity, 0.597583852304615],
        [0.600570112895970, T.infinity, T.infinity, 0.600570112895970],
        [0.602957401678320, T.infinity, T.infinity, 0.602957401678320],
        [0.603553390593274, T.infinity, T.infinity, 0.603553390593274],
        [0.609475708248730, T.infinity, T.infinity, 0.609475708248730],
    ];

    static immutable sqs = [
        [0.575364144903562, 0.980258143468547, 0.980258143468547, 0.575364144903562],
        [0.574524477344522, 0.971313482411421, 0.971313482411421, 0.574524477344522],
        [0.571428571428571, 0.942809041582063, 0.942809041582063, 0.571428571428571],
        [0.568050833375483, 0.917430419224029, 0.917430419224029, 0.568050833375483],
        [0.565104166666667, 0.898614867757904, 0.898614867757904, 0.565104166666667],
        [0.562996791787212, 0.886576496557052, 0.886576496557052, 0.562996791787212],
        [0.562500000000000, 0.883883476483184, 0.883883476483184, 0.562500000000000],
        [0.558078204724922, 0.861928812542302, 0.861928812542302, 0.558078204724922],
    ];

    foreach (S; AliasSeq!(float, double, real))
    {

        auto f0 = (S x) => -log(abs(x)) / 2;
        auto f1 = (S x) => -1 / (2 * x);
        auto f2 = (S x) => 1 / (2 * x * x);

        auto it = (S l, S r, S c)
        {
            auto iv = Interval!S(l, r, c, f0(l), f1(l), f2(l), f0(r), f1(r), f2(r));
            transformInterval(iv);
            return iv;
        };

        // calculate the area of all intervals
        foreach (i, c; cs)
        {
            foreach (j, p1, p2; points.lockstep(points.save.dropOne))
            {
                auto iv = it(p1, p2, c);
                determineSqueezeAndHat(iv);

                hatArea!S(iv);
                if (iv.hatArea == S.max)
                    assert(hats[i][j].isInfinity);
                else
                    assert(iv.hatArea.approxEqual(hats[i][j]));

                squeezeArea!S(iv);
                assert(iv.squeezeArea.approxEqual(sqs[i][j]));
            }
        }
    }
}

// distribution 4 with less points
unittest
{
    import mir.internal.math : log;
    import mir.random.flex.internal.transformations : transformInterval;
    import mir.random.flex.internal.types : determineType;
    import std.math: abs, approxEqual, isInfinity;
    import std.meta : AliasSeq;
    import std.range: dropOne, lockstep, save;

    static immutable points = [-1, 0, 1];
    // -2 yields "undefined" type
    static immutable cs = [-1.5, -1, -0.9, -0.5, 0, 0.5, 0.9, 1, 1.5, 2];
    alias T = double;

    static immutable hats = [
        [T(3)],
        [T.infinity],
        [T.infinity],
        [T.infinity],
        [T.infinity],
        [T.infinity],
        [T.infinity],
        [T.infinity],
        [T.infinity],
        [T.infinity],
        [T.infinity],
    ];

    static immutable sqs = [
        [1.48016],
        [1.38629436111989],
        [1.37364470014208],
        [1.33333333333333],
        [1.29744254140026],
        [1.27083333333333],
        [1.25380850551221],
        [1.25],
        [1.2330750067473],
        [1.21895141649746],
    ];

    foreach (S; AliasSeq!(float, double, real))
    {
        auto f0 = (S x) => -log(abs(x)) / 2;
        auto f1 = (S x) => -1 / (2 * x);
        auto f2 = (S x) => 1 / (2 * x * x);

        auto it = (S l, S r, S c)
        {
            auto iv = Interval!S(l, r, c, f0(l), f1(l), f2(l), f0(r), f1(r), f2(r));
            transformInterval(iv);
            return iv;
        };

        // calculate the area of all intervals
        foreach (i, c; cs)
        {
            foreach (j, p1, p2; points.lockstep(points.save.dropOne))
            {
                auto iv = it(p1, p2, c);
                determineSqueezeAndHat(iv);

                hatArea!S(iv);

                if (iv.hatArea == S.max)
                    assert(hats[i][0].isInfinity);
                else
                    assert(iv.hatArea.approxEqual(hats[i][0]));

                squeezeArea!S(iv);
                assert(iv.squeezeArea.approxEqual(sqs[i][0]));
            }
        }
    }
}

// distribution 3 with other boundaries
unittest
{
    import mir.internal.math : log;
    import mir.random.flex.internal.transformations : transformInterval;
    import mir.random.flex.internal.types : determineType;
    import std.math: approxEqual, isInfinity;
    import std.meta : AliasSeq;
    import std.range: dropOne, lockstep, save;

    alias T = double;

    // the second type might induce numeric errors
    static immutable points = [-T.infinity, -2, -1, 0, 1, 2, T.infinity];

    // without boundaries needs to be > -1
    static immutable cs = [-0.9, -0.5, 0];
    // >= 0.5 yields "undefined" type

    static immutable hats = [
        [2.34448280665123e-08, 7.38905609893065e+00, 7.38905609893065,
         7.38905609893065, 7.38905609893065e+00, 2.34448280665123e-08],
        [4.68896561330246e-09, 7.389056098930649519, 7.38905609893065,
         7.38905609893065, 7.389056098930649519, 4.68896561330246e-09],
        [2.34448280665123e-09, 7.389056098930650, 7.38905609893065,
         7.38905609893065, 7.389056098930650, 2.34448280665123e-09],
    ];

    static immutable sqs = [
        [0, 5.11436710832274e-06, 1, 1, 5.11436710832274e-06, 0],
        [0, 0.000911881965554516, 1, 1, 0.000911881965554516, 0],
        [0, 0.410503110355304, 1, 1, 0.410503110355304, 0],
    ];

    foreach (S; AliasSeq!(float, double, real))
    {
        auto f0 = (double x) => -2 *  x^^4 + 4 * x^^2;
        auto f1 = (double x) => -8 *  x^^3 + 8 * x;
        auto f2 = (double x) => -24 * x^^2 + 8;

        auto it = (S l, S r, S c)
        {
            auto iv = Interval!S(l, r, c, f0(l), f1(l), f2(l), f0(r), f1(r), f2(r));
            transformInterval(iv);
            return iv;
        };

        // calculate the area of all intervals
        foreach (i, c; cs)
        {
            foreach (j, p1, p2; points.lockstep(points.save.dropOne))
            {
                auto iv = it(p1, p2, c);
                determineSqueezeAndHat(iv);

                hatArea!S(iv);
                if (iv.hatArea == S.max)
                    assert(hats[i][j].isInfinity);
                else
                    assert(iv.hatArea.approxEqual(hats[i][j]));

                squeezeArea!S(iv);
                assert(iv.squeezeArea.approxEqual(sqs[i][j]));
            }
        }
    }
}

/**
Calculate the parameters for an interval.
Given an interval, determine its type (e.g. purely concave, or purely convex)
and its hat and squeeze function.
Given these functions, compute the area and overwrite the references data type.

Params:
    iv = Interval which should be calculated
*/
void calcInterval(S)(ref Interval!S iv)
in
{
    assert(iv.lx < iv.rx, "invalid interval");
}
body
{
    import mir.random.flex.internal.types : determineType;
    import std.math: isFinite;

    // calculate hat and squeeze functions
    determineSqueezeAndHat(iv);

    // update area
    hatArea!S(iv);
    squeezeArea!S(iv);

    assert(iv.hatArea.isFinite, "hat area should be lower than infinity");
    assert(iv.squeezeArea.isFinite, "squeezeArea area should be lower than infinity");
}
