/**

License:   $(WEB www.boost.org/LICENSE_1_0.txt, Boost License 1.0).

Authors:   Ilya Yaroshenko

Source:    $(PHOBOSSRC std/_experimental/_ndslice/_structure.d)

Macros:
T2=$(TR $(TDNW $(LREF $1)) $(TD $+))
T4=$(TR $(TDNW $(LREF $1)) $(TD $2) $(TD $3) $(TD $4))
*/
module std.experimental.ndslice.structure;


///
struct Structure(size_t N)
    if(N && N < 256)
{
    ///
    size_t    [N] lengths;

    ///
    sizediff_t[N] strides;

    ///
    static if(N == 2)
    bool isBlasCompatible() @property
    {
        return strides[0] == 1 && strides[1] > 0 || strides[1] == 1 && strides[0] > 0;
    }
    else enum bool isBlasCompatible = N == 1; //BLAS level-1 allows negative strides.

    ///
    static if(N > 1)
    bool isContiguous() @property
    {
        size_t length = strides[N-1];
        foreach_reverse(i; Iota!(0, N-1))
        {
            length *= lengths[i+1];
            if(length != strides[i])
                return false;
        }
        return true;
    }
    else
    enum bool isContiguous = true;

    ///
    bool isNormal() @property
    {
        foreach(i; Iota!(0, N-1))
        {
            if(strides[i] <= strides[i+1])
                return false;
        }
        return strides[N-1] > 0;
    }

    ///
    bool isPure() @property
    {
        size_t length = 1;
        foreach_reverse(i; Iota!(0, N))
        {
            if(length != strides[i])
                return false;
            length *= lengths[i];
        }
        return true;
    }

    ///
    Structure normalized() @property
    {
        Structure ret = this;
        with(ret)
        {
            foreach(i; Iota!(0, N))
            {
                if(strides[i] < 0)
                    strides[i] = -strides[i];
            }
            //TODO: optimize sort
            //import std.algorithm.mutation: swap;
            import std.algorithm.sorting: sort;
            import std.range: zip;
            zip(lengths[], strides[]).sort!((a, b) => a[1] > b[1]);
        }
        return ret;
    }
}
