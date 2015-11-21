/++
$(BOOKTABLE $(H2 Iterators),
$(T2 byElement, `100.iota.sliced(4, 5).byElement` equals `20.iota`.)
)
+/
module std.experimental.ndslice.iterators;

import std.experimental.ndslice.slice;
import std.experimental.ndslice.internal;
import std.traits;
import std.range.primitives;

/++
Returns a random access range of all elements of a slice.
See_also: $(LREF elements)
+/
auto byElement(size_t N, Range)(auto ref Slice!(N, Range) slice)
{
    with(Slice!(N, Range))
    {
        /++
        ByElement shifts range's `_ptr` without modifying strides and lengths.
        +/
        static struct ByElement
        {

            This _slice;
            size_t _length;
            size_t[N] _indexes;

            static if (isPointer!PureRange || isForwardRange!PureRange)
            auto save() @property
            {
                return typeof(this)(_slice.save, _length, _indexes);
            }

            bool empty() const @property
            {
                return _length == 0;
            }

            size_t length() const @property
            {
                return _length;
            }

            auto ref front() @property
            {
                assert(!this.empty);
                static if (N == PureN)
                    return _slice._ptr[0];
                else with(_slice)
                {
                    alias M = DeepElemType.PureN;
                    return DeepElemType(_lengths[$-M .. $], _strides[$-M .. $], _ptr);
                }
            }

            static if (PureN == 1 && rangeHasMutableElements && !hasAccessByRef)
            auto front(DeepElemType elem) @property
            {
                assert(!this.empty);
                return _slice._ptr[0] = elem;
            }

            void popFront()
            {
                assert(!empty);
                _length--;
                popFrontImpl;
            }

            private void popFrontImpl()
            {
                foreach_reverse(i; Iota!(0, N)) with(_slice)
                {
                    _ptr += _strides[i];
                    _indexes[i]++;
                    if (_indexes[i] < _lengths[i])
                        return;
                    assert(_indexes[i] == _lengths[i]);
                    _ptr -= _lengths[i] * _strides[i];
                    _indexes[i] = 0;
                }
            }

            auto ref back() @property
            {
                assert(!this.empty);
                return opIndex(_length - 1);
            }

            static if (PureN == 1 && rangeHasMutableElements && !hasAccessByRef)
            auto back(DeepElemType elem) @property
            {
                assert(!this.empty);
                return opIndexAssign(_length - 1, elem);
            }

            void popBack()
            {
                assert(!empty);
                _length--;
            }

            void popFrontN(size_t n)
            in {
                assert(n <= _length);
            }
            body {
                _length -= n;
                //calculate shift and new indexes
                sizediff_t _shift;
                n += _indexes[N-1];
                foreach_reverse(i; Iota!(1, N)) with(_slice)
                {
                    immutable v = n / _lengths[i];
                    n %= _lengths[i];
                    _shift += (n - _indexes[i]) * _strides[i];
                    _indexes[i] = n;
                    n = _indexes[i-1] + v;
                }
                assert(n < _slice._lengths[0]);
                with(_slice)
                {
                    _shift += (n - _indexes[0]) * _strides[0];
                    _indexes[0] = n;
                }
                _slice._ptr += _shift;
            }

            void popBackN(size_t n)
            in {
                assert(n <= _length);
            }
            body {
                _length -= n;
            }

            //calculate shift for index n
            private sizediff_t getShift(size_t n)
            in {
                assert(n < _length);
            }
            body {
                sizediff_t _shift;
                n += _indexes[N-1];
                foreach_reverse(i; Iota!(1, N)) with(_slice)
                {
                    immutable v = n / _lengths[i];
                    n %= _lengths[i];
                    _shift += (n - _indexes[i]) * _strides[i];
                    n = _indexes[i-1] + v;
                }
                assert(n < _slice._lengths[0]);
                with(_slice)
                    _shift += (n - _indexes[0]) * _strides[0];
                return _shift;
            }

            auto ref opIndex(size_t index)
            {
                return _slice._ptr[getShift(index)];
            }

            static if (PureN == 1 && rangeHasMutableElements && !hasAccessByRef)
            auto opIndexAssign(DeepElemType elem, size_t index)
            {
                return _slice[getShift(index)] = elem;
            }

            auto opIndex(Tuple!(size_t, size_t) sl)
            {
                auto ret = this;
                ret.popFrontN(sl[0]);
                ret.popBackN(_length - sl[1]);
                return ret;
            }

            alias opDollar = length;

            Tuple!(size_t, size_t) opSlice(size_t pos : 0)(size_t i, size_t j)
            in   {
                assert(i <= j,
                    "ByElement.opSlice: left bound must be less then or equal right bound");
                assert(j - i <= _length,
                    "ByElement.opSlice: difference between right and left bounds must be less then or equal length");
            }
            body {
                return typeof(return)(i, j);
            }
        }
        return ByElement(slice, slice.elementsCount);
    }
}

///Common slice
unittest {
    import std.algorithm.comparison: equal;
    import std.range: iota;
    assert(100.iota
        .sliced(4, 5)
        .byElement
        .equal(20.iota));
}

///Packed slice
unittest {
    import std.experimental.ndslice.operators;
    import std.range: iota, drop;
    import std.algorithm.comparison: equal;
    assert(100000.iota
        .sliced(3, 4, 5, 6, 7)
        .packed!2
        .byElement()
        .drop(1)
        .front
        .byElement
        .equal(iota(6 * 7, 6 * 7 * 2)));
}

/++
Random access and slicing.
Random access is more expensive comparing with iteration with input range primitives.
+/
unittest {
    import std.range: iota;
    auto elems = 100.iota.sliced(4, 5).byElement;

    elems = elems[11 .. $-2];

    assert(elems.length == 7);
    assert(elems.front == 11);
    assert(elems.back == 17);

    foreach(i; 0..7)
        assert(elems[i] == i+11);
}

unittest {
    import std.range: iota;
    auto elems = 100.iota.sliced(4, 5).byElement;
    static assert(isRandomAccessRange!(typeof(elems)));
    static assert(hasSlicing!(typeof(elems)));
}

// Check strides
unittest {
    import std.experimental.ndslice.operators;
    import std.range: iota;
    auto elems = 100.iota.sliced(4, 5).everted.byElement;
    static assert(isRandomAccessRange!(typeof(elems)));

    elems = elems[11 .. $-2];
    auto elems2 = elems;
    foreach(i; 0..7)
    {
        assert(elems[i] == elems2.front);
        elems2.popFront;
    }
}

unittest {
    import std.experimental.ndslice.operators;
    import std.range: iota;
    import std.algorithm.comparison: equal;

    auto range = 100000.iota;
    auto slice0 = range.sliced(3, 4, 5, 6, 7);
    auto slice1 = slice0.transposed!(2, 1).packed!2;
    auto elems0 = slice0.byElement;
    auto elems1 = slice1.byElement;

    import std.meta;
    foreach(S; AliasSeq!(typeof(elems0), typeof(elems1)))
    {
        static assert(isForwardRange!S);
        static assert(hasLength!S);
    }

    assert(elems0.length == slice0.elementsCount);
    assert(elems1.length == 5 * 4 * 3);

    auto elems2 = elems1;
    foreach(q; slice1)
        foreach(w; q)
            foreach(e; w)
            {
                assert(!elems2.empty);
                assert(e == elems2.front);
                elems2.popFront;
            }
    assert(elems2.empty);

    elems0.popFront();
    elems0.popFrontN(slice0.elementsCount - 14);
    assert(elems0.length == 13);
    assert(elems0.equal(range[slice0.elementsCount-13 .. slice0.elementsCount]));

    foreach(elem; elems0) {}
}
