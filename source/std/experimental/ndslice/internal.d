/**

License:   $(WEB www.boost.org/LICENSE_1_0.txt, Boost License 1.0).

Authors:   Ilya Yaroshenko

Source:    $(PHOBOSSRC std/_experimental/_ndslice/_internal.d)
*/
module std.experimental.ndslice.internal;

import std.traits;
import std.typecons: Tuple;
import std.meta;
import std.range.primitives;


enum string tailErrorMessage(
    string fun = __FUNCTION__,
    string pfun = __PRETTY_FUNCTION__) =
"
- - -
Emitted by function
" ~ fun ~ "
- - -
Function prototype
" ~ pfun ~ "
_____";

mixin template _DefineRet()
{
    alias Ret = typeof(return);
    static if(hasElaborateAssign!(Ret.PureRange))
        Ret ret;
    else
        Ret ret = void;
}

mixin template DimensionsCountCTError()
{
    static assert(Dimensions.length <= N,
        "Dimensions list length = " ~ Dimensions.length.stringof
        ~ " should be less or equal N = " ~ N.stringof
        ~ tailErrorMessage!());
}

enum DimensionsCountRTError = q{
    assert(dimensions.length <= N,
        "Dimensions list length should be less or equal N = " ~ N.stringof
        ~ tailErrorMessage!());
};

mixin template DimensionCTError()
{
    static assert(dimension >= 0,
        "dimension = " ~ dimension.stringof ~ " at position "
        ~ i.stringof ~ " should be greater or equal 0"
        ~ tailErrorMessage!());
    static assert(dimension < N,
        "dimension = " ~ dimension.stringof ~ " at position "
        ~ i.stringof ~ " should be less then N = " ~ N.stringof
        ~ tailErrorMessage!());
}

enum DimensionRTError = q{
    static if(isSigned!(typeof(dimension)))
    assert(dimension >= 0, "dimension should be greater or equal 0"
        ~ tailErrorMessage!());
    assert(dimension < N, "dimension should be less then N = " ~ N.stringof
        ~ tailErrorMessage!());
};

alias IncFront(Seq...) = AliasSeq!(Seq[0] + 1, Seq[1..$]);
alias DecFront(Seq...) = AliasSeq!(Seq[0] - 1, Seq[1..$]);
alias NSeqEvert(Seq...) = DecFront!(Reverse!(IncFront!Seq));
alias Parts(Seq...) = DecAll!(IncFront!Seq);
alias Snowball(Seq...) = AliasSeq!(size_t.init, SnowballImpl!(size_t.init, Seq));
template SnowballImpl(size_t val, Seq...)
{
    static if (Seq.length == 0)
        alias SnowballImpl = AliasSeq!();
    else
        alias SnowballImpl = AliasSeq!(Seq[0]+val, SnowballImpl!(Seq[0]+val, Seq[1..$]));
}
template DecAll(Seq...)
{
    static if (Seq.length == 0)
        alias DecAll = AliasSeq!();
    else
        alias DecAll = AliasSeq!(Seq[0] - 1, DecAll!(Seq[1..$]));
}
template SliceFromSeq(Range, Seq...)
{
    static if (Seq.length == 0)
        alias SliceFromSeq = Range;
    else
    {
        import std.experimental.ndslice.slice: Slice;
        alias SliceFromSeq = SliceFromSeq!(Slice!(Seq[$-1], Range), Seq[0..$-1]);
    }
}

bool isPermutation(size_t N)(auto ref in size_t[N] perm)
{
    if(perm.length == 0)
        return false;
    int[N] mask;
    foreach(j; perm)
    {
        if (j >= N)
            return false;
        if(mask[j]) //duplicate
            return false;
        mask[j] = true;
    }
    foreach(e; mask)
        if (e == false)
            return false;
    return true;
}

bool isValidPartialPermutation(size_t N)(in size_t[] perm)
{
    if(perm.length == 0)
        return false;
    int[N] mask;
    foreach(j; perm)
    {
        if (j >= N)
            return false;
        if(mask[j]) //duplicate
            return false;
        mask[j] = true;
    }
    //foreach(e; mask)
    //    if (e == false)
    //        return false;
    return true;
}

enum isIndex(I) = is(I : size_t);
enum isReference(P) =
       isPointer!P
    || isFunctionPointer!P
    || isDelegate!P
    || isDynamicArray!P
    || is(P == interface)
    || is(P == class);
enum hasReference(T) = anySatisfy!(isReference, RepresentationTypeTuple!T);
alias ImplicitlyUnqual(T) = Select!(isImplicitlyConvertible!(T, Unqual!T), Unqual!T, T);

//TODO: replace with static foreach
template Iota(size_t i, size_t j)
{
    static assert(i <= j, "Iota: i>j");
    static if (i == j)
        alias Iota = AliasSeq!();
    else
        alias Iota = AliasSeq!(i, Iota!(i+1, j));
}

template Repeat(T, size_t N)
{
    static if(N)
        alias Repeat = AliasSeq!(Repeat!(T, N-1), T);
    else
        alias Repeat = AliasSeq!();
}

size_t lengthsProduct(size_t N)(auto ref in size_t[N] lengths)
{
    size_t length = lengths[0];
    foreach(i; Iota!(1, N))
            length *= lengths[i];
    return length;
}
