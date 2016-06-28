module mir.random.tinflex.internal.area;

import mir.random.tinflex.internal.types : Interval;
import std.traits : ReturnType;

/**
Determines the hat and squeeze function of an interval.
Based on Theorem 1
*/
void determineSqueezeAndHat(S)(ref Interval!S iv)
in
{
    assert(iv.lx < iv.rx, "invalid interval");
}
body
{
    import mir.random.tinflex.internal.linearfun : emptyFun, secant, tangent;
    import mir.random.tinflex.internal.types : determineType, FunType;

    enum sec = "secant(iv.lx, iv.rx, iv.ltx, iv.rtx)";
    enum t_l = "tangent(iv.lx, iv.ltx, iv.lt1x)";
    enum t_r = "tangent(iv.rx, iv.rtx, iv.rt1x)";

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
            squeeze = iv.ltx < iv.rtx ? mixin(t_l) : mixin(t_r);
            hat = mixin(sec);
            break;
        default:
            squeeze = emptyFun!S;
            hat = emptyFun!S;
    }
}

// TODO: add more tests
unittest
{
    import std.meta : AliasSeq;
    import mir.random.tinflex.internal.types: determineType;
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

alias hatArea(S) = area!(true, S);
alias squeezeArea(S) = area!(false, S);

/**
Computes the area below a function sh in-between l and r.
Based on table 1 and general equation (3) from the Tinflex paper

    (F_T(sh(r))- F_T(sh(l))) / sh.slope

Params:
    sh = linear function
    l  = start of interval
    r  = end of interval
    ly = start of interval (y-value)
    ry = end of interval (y-value)
    c  =  interval type (see paper)

Returns: Computed area below sh.
*/
void area(bool isHat, S)(ref Interval!S iv)
in
{
    assert(iv.lx < iv.rx, "invalid interval");
}
body
{
    import mir.internal.math: copysign, exp, log;
    import std.math: abs, sgn;
    import mir.random.tinflex.internal.transformations : antiderivative, inverse;

    S area = void;

    static if (isHat)
        auto sh = iv.hat;
    else
        auto sh = iv.squeeze;

    // check difference to left and right starting point
    // sigma in the paper (1: left side, -1, right side
    const byte leftOrRight = (iv.rx - sh._y) > (sh._y - iv.lx) ? 1 : -1;

    // sh.y is the boundary point where f obtains its maximum

    // specializations for T_c family (page 6)
    if (iv.c == 0)
    {
        // T_c = log(x)
        // Error in table, see equation (4)
        immutable z = leftOrRight * sh.slope * (iv.rx - iv.lx);
        // check whether approximation is possible, page 5
        if (abs(z) < S(1e-6))
        {
            area = exp(sh.a) * (iv.rx - iv.lx) * (1 + z / 2 + (z * z) / 6);
        }
        else
        {
            // F_T = e^x
            area = (exp(sh(iv.rx)) - exp(sh(iv.lx))) / sh.slope;
        }
    }
    else
    {
        // for c < 0, the tangent result must result in a valid (bounded) hat function
        if (iv.c * sh(iv.rx) < 0 || iv.c * sh(iv.lx) < 0)
        {
            // returning infinity will yield a split on this interval.
            area = S.max;
            goto L;
        }

        immutable intLength = iv.rx - iv.lx;
        immutable z = leftOrRight * sh.slope / sh.a * intLength;

        if (iv.c == 1)
        {
            // T_c^-1 = x^c
            area = S(0.5) * sh.a * intLength * (z + 2);
        }
        else if (iv.c == S(-0.5))
        {
            // T_c = -1/sqrt(x)
            if (abs(z) < S(0.5))
            {
                // T_c^-1 = 1/x^2
                area = 1 / (sh.a * sh.a) * intLength / (1 + z);
            }
            else
            {
                area = ((-1 / sh(iv.rx)) + (1 / sh(iv.lx))) / sh.slope;
            }
        }
        else if (iv.c == -1)
        {
            // T_C = -1 / x
            if (abs(z) <= S(1e-6))
            {
                // T_C^-1 = -1 / x
                area = -1 / sh.a * intLength * (1 - z / 2 + z * z / 3);
            }
            else
            {
                // F_T = -log(-x)
                area = (-log(-sh(iv.rx)) + log(-sh(iv.lx))) / sh.slope;
            }
        }
        else
        {
            // T_c = -1 / x
            //area = (r - l) * c / (c + 1) * 1 / z * ((1 + z)^^((c + 1) / c) - 1);
            if (abs(sh.slope) > S(1e-10))
            {
                alias ad = antiderivative;
                area = (ad(sh(iv.rx), iv.c) - ad(sh(iv.lx), iv.c)) / sh.slope;
            }
            else
            {
                area = inverse(sh.a, iv.c) * intLength;
            }
        }
    }

L:
    // if we receive an invalid value, we require the interval to be split
    import std.math : isFinite;
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

// example from Tinflex
unittest
{
    import mir.random.tinflex.internal.transformations : transformToInterval;
    import mir.random.tinflex.internal.types : determineType;
    import std.math: approxEqual;
    import std.meta : AliasSeq;
    import std.range: dropOne, lockstep, save;

    // inflection points: -1.7620, -1.4012, 1.4012, 1.7620
    enum points = [-3.0, -1.5, 0.0, 1.5, 3];
    enum cs = [-2, -1.5, -1, -0.9, -0.5, -0.2, 0, 0.2, 0.5, 0.9, 1, 1.5, 2];
    alias T = double;
    enum hats = [
        [T.infinity, 7.9931382154647697, 7.9931382154647697, T.infinity],
        [T.infinity, 7.5525938035874400, 7.5525938035874400, T.infinity],
        [T.infinity, 7.0034917537988290, 7.0034917537988290, T.infinity],
        [T.infinity, 6.8764592591072242, 6.8764592591072242, T.infinity],
        [T.infinity, 6.2914609279049900, 6.2914609279049900, T.infinity],
        [7.37410163492969e+01, 5.7472000242871708, 5.7472000242871708, 7.37410163492969e+01],
        [50.433577359671510, 5.3156599455901743, 5.3156599455901743, 50.433577359671510],
        [4.10692427103361e+01, 4.8145489538059349, 4.8145489538059349, 4.10692427103361e+01],
        [3.40500746703608e+01, 4.6676275718754061, 4.6676275718754061, 3.40500746703608e+01],
        [2.92349379474674e+01, 6.3570562040858194, 6.3570562040858194, 2.92349379474674e+01],
        [2.84098782525710e+01, 6.6984139650656038, 6.6984139650656038, 2.84098782525710e+01],
        [2.5438585137354e+01, 8.0223584671647483, 8.0223584671647483, 2.5438585137354e+01],
        [2.35669897095508e+01, 8.9129405418768659, 8.9129405418768659, 2.35669897095508e+01],
    ];

    enum sqs = [
        [1.27450627658748e-17, 0.0274734583331013, 0.0274734583331013, 1.27450627658748e-17],
        [1.91175941356133e-17, 0.0274734583331013, 0.0274734583331013, 1.91175941356133e-17],
        [2.68841167717671e-16, 0.0274734583331013, 0.0274734583331013, 2.68841167717671e-16],
        [3.83968250114544e-15, 0.0274734583331013, 0.0274734583331013, 3.83968250114544e-15],
        [9.23020210727521e-09, 0.0274734583331013, 0.0274734583331013, 9.23020210727521e-09],
        [7.24077129639768e-04, 0.0274734583331013, 0.0274734583331013, 7.24077129639768e-04],
        [0.316903217109288, 0.0274734583331013, 0.0274734583331013, 0.316903217109288],
        [9.57819845420090e-12, 0.0274734583331013, 0.0274734583331013, 9.57819845420090e-12],
        [7.64863079237059e-15, 0.0274734583331013, 0.0274734583331013, 7.64863079237059e-15],
        [6.37253138293737e-18, 0.0274734583331013, 0.0274734583331013, 6.37253138293737e-18],
        [3.79165617284774e-16, 0.0274734583331013, 0.0274734583331013, 3.79165617284774e-16],
        [6.3725313829374e-18, 0.0274734583331013, 0.0274734583331013, 6.3725313829374e-18],
        [6.37253138293738e-18, 0.0274734583331013, 0.0274734583331013, 6.37253138293738e-18],
    ];

    foreach (S; AliasSeq!(float, double, real))
    {
        const f0 = (S x) => -x^^4 + 5 * x^^2 - 4;
        const f1 = (S x) => 10 * x - 4 * x ^^ 3;
        const f2 = (S x) => 10 - 12 * x ^^ 2;

        auto it = (S l, S r, S c) => transformToInterval(l, r, c, f0(l), f1(l), f2(l),
                                                                  f0(r), f1(r), f2(r));

        import std.math : isInfinity;

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

// standard normal distribution
unittest
{
    import mir.random.tinflex.internal.transformations : transformToInterval;
    import mir.random.tinflex.internal.types : determineType;
    import std.math: approxEqual;
    import std.meta : AliasSeq;
    import std.range: dropOne, lockstep, save;

    enum points = [-3.0, -1.5, 0.0, 1.5, 3];
    enum cs = [50, 30, -20, -15, -10, -5, -3, -1, -0.5 -0.1, 0,
               0.1, 0.5, 1, 3, 5, 10, 15, 20, 30, 50];
    alias T = double;

    enum hats = [
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

    enum sqs = [
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

        auto it = (S l, S r, S c) => transformToInterval(l, r, c, f0(l), f1(l), f2(l),
                                                                  f0(r), f1(r), f2(r));

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
    import mir.random.tinflex.internal.transformations : transformToInterval;
    import mir.random.tinflex.internal.types : determineType;
    import std.math: approxEqual, isInfinity;
    import std.meta : AliasSeq;
    import std.range: dropOne, lockstep, save;

    enum points = [-1, -0.9, -0.5, 0.5, 0.9, 1];
    // weird numerical bug prevents us from enabling 1.5
    // test values suffer from the imprecision as well
    //enum cs = [-2, -1.5, -1, -0.9, -0.5, -0.2, 0, 0.2, 0.5, 0.9, 1, 1.5, 2];
    enum cs = [-2, -1.5, -1, -0.9, -0.5, -0.2, 0, 0.2, 0.5, 0.9, 1];
    alias T = double;

    enum hats = [
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
        //[T.infinity, 0.333398373950812, 1.1696547939447, 0.333398373950812, T.infinity],
        //[0.0229266666666667, 0.331569730344363, 1.15489483916219, 0.331569730344363, 0.0229266666666667],
    ];

    enum sqs = [
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
        //[0, 0.265692417223023, 0.9375, 0.265692417223023, 0],
        //[0, 0.274612082617970, 0.9375, 0.274612082617970, 0],
    ];

    foreach (S; AliasSeq!(float, double, real))
    {
        import std.math : log;
        auto f0 = (S x) => log(1 - x^^4);
        auto f1 = (S x) => -4 * x^^3 / (1 - x^^4);
        auto f2 = (S x) => -(4 * x^^6 + 12 * x^^2) / (x^^8 - 2 * x^^4 + 1);

        auto it = (S l, S r, S c) => transformToInterval!S(l, r, c, f0(l), f1(l), f2(l),
                                                                    f0(r), f1(r), f2(r));

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

// distribution 4
unittest
{
    import mir.random.tinflex.internal.transformations : transformToInterval;
    import mir.random.tinflex.internal.types : determineType;
    import std.math: approxEqual, isInfinity;
    import std.meta : AliasSeq;
    import std.range: dropOne, lockstep, save;

    enum points = [-1, -0.5, 0, 0.5, 1];
    // -2 yields "undefined" type
    enum cs = [-2, -1, -0.9, -0.5, 0, 0.5, 0.9, 1, 2];
    alias T = double;

    enum hats = [
        [0.585786437626905, T.infinity, T.infinity, 0.585786437626905],
        [0.591638126147109, T.infinity, T.infinity, 0.591638126147109],
        [0.592229601209145, T.infinity, T.infinity, 0.592229601209145],
        [0.594603557501361, T.infinity, T.infinity, 0.594603557501361],
        [0.597583852304615, T.infinity, T.infinity, 0.597583852304615],
        [0.600570112895970, T.infinity, T.infinity, 0.600570112895970],
        [0.602957401678320, T.infinity, T.infinity, 0.602957401678320],
        [0.603553390593274, T.infinity, T.infinity, 0.603553390593274],
        [0.609475708248730, T.infinity, T.infinity, 0.609475708248730],
    ];

    enum sqs = [
        [0.585786437626905, 0, 0, 0.585786437626905],
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
        import std.math : abs, log;
        auto f0 = (S x) => -log(abs(x))/2;
        auto f1 = (S x) => -1/(2*x);
        auto f2 = (S x) => 1/(2*x^^2);

        auto it = (S l, S r, S c) => transformToInterval!S(l, r, c, f0(l), f1(l), f2(l),
                                                                    f0(r), f1(r), f2(r));

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

// distribution 3 with other boundaries
unittest
{
    import mir.random.tinflex.internal.transformations : transformToInterval;
    import mir.random.tinflex.internal.types : determineType;
    import std.math: approxEqual, isInfinity;
    import std.meta : AliasSeq;
    import std.range: dropOne, lockstep, save;

    alias T = double;

    // the second type might induce numeric errors
    enum points = [-T.infinity, -2, -1, 0, 1, 2, T.infinity];

    // without boundaries needs to be > -1
    enum cs = [-0.9, -0.5, 0, 0.5, 0.9, 1, 2];
    // >= 0.5 yields "undefined" type

    enum hats = [
        [2.34448280665123e-08, 7.38905609893065e+00, 7.38905609893065,
         7.38905609893065, 7.38905609893065e+00, 2.34448280665123e-08],
        [4.68896561330246e-09, 7.389056098930649519, 7.38905609893065,
         7.38905609893065, 7.389056098930649519, 4.68896561330246e-09],
        [2.34448280665123e-09, 7.389056098930650, 7.38905609893065,
         7.38905609893065, 7.389056098930650, 2.34448280665123e-09],
        [T.infinity, 7.38905609893065e+00, 7.38905609893065,
         7.38905609893065, 7.38905609893065e+00, T.infinity],
        [T.infinity, 7.38905609893065e+00, 7.38905609893065,
         7.38905609893065, 7.38905609893065e+00, T.infinity],
        [T.infinity, 7.38905609893065e+00, 7.38905609893065,
         7.38905609893065, 7.38905609893065e+00, T.infinity],
        [T.infinity, 7.38905609893065e+00, 7.38905609893065,
         7.38905609893065, 7.38905609893065e+00, T.infinity],
    ];

    enum sqs = [
        [0, 5.11436710832274e-06, 1, 1, 5.11436710832274e-06, 0],
        [0, 0.000911881965554516, 1, 1, 0.000911881965554516, 0],
        [0, 0.410503110355304, 1, 1, 0.410503110355304, 0],
        [0, 2.44201329140792e-05, 1, 1, 2.44201329140792e-05, 0],
        [0, 3.67127352051629e-06, 1, 1, 3.67127352051629e-06, 0],
        [0, 2.81337936798148e-06, 1, 1, 2.81337936798148e-06, 0],
        [0, 1.12535174719259e-07, 1, 1, 1.12535174719259e-07, 0],
    ];

    foreach (S; AliasSeq!(float, double, real))
    {
        import std.math : log;
        auto f0 = (double x) => -2 *  x^^4 + 4 * x^^2;
        auto f1 = (double x) => -8 *  x^^3 + 8 * x;
        auto f2 = (double x) => -24 * x^^2 + 8;


        auto it = (S l, S r, S c) => transformToInterval!S(l, r, c, f0(l), f1(l), f2(l),
                                                                  f0(r), f1(r), f2(r));

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
