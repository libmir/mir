/+
## Guide for Slice/BLAS contributors

1. Pay _unprecedented_ attention to functions to be
       a. inlined(!),
       b. `@nogc`,
       c. `nothrow`,
       d. `pure`.
    95% of functions will be marked with `pragma(inline, true)`. So, use
    _simple_ `assert`s with messages that can be computed at compile time.
    The goals are:
        1. to reduce executable size for _any_ compilation mode
        2. to reduce template bloat in object files
        3. to reduce compilation time
        4. to allow a user to write an extern C bindings for code based on `Slice`.

2. Do not import `std.format`, `std.string` and `std.conv` to format error
    messages.`"Use" ~ Concatenation.stringof`.

3. Try to use already defined `mixin template`s for pretty error messaging.

4. Do not use `Exception`s/`enforce`s to check indexes and length. Exceptions are
    allowed only for algorithms where validation of an input data is
    significantly complex for user. `reshape` is a good example where
    Exceptions are required. Put an example of Exception handing and workaround
    for a function that can throw.

5. Do not use compile time flags for simple checks like transposition
    of a matrix. It is much better to have runtime matrix transposition.
    Furthermore, Slice provide runtime matrix transposition out of the box.

6. Do not use _Fortran_VS_C_ flags. They are about notation,
    but not about algorithm itself. To care about math world users add
    appropriate code example in the documentation. `transposed` / `everted`
    can be used for cash friendly code.

7. Do not use D compile time power to produce dummy entities like
    `IdentityMatrix`.

8. Try to separate allocation and algorithm logic whenever possible.

9. Add CTFE unittests to new functions.
+/

/**
This package implements generic algorithms for creating and manipulating of n-dimensional random access ranges and arrays,
which are represented with the $(SUBREF slice, Slice).

$(SCRIPT inhibitQuickIndex = 1;)

$(DIVC quickindex,
$(BOOKTABLE ,
$(TR $(TH Category) $(TH Submodule) $(TH Declarations)
)
$(TR $(TDNW Slicing)
     $(TDNW $(SUBMODULE slice))
     $(TD
        $(SUBREF slice, sliced)
        $(SUBREF slice, Slice)
        $(SUBREF slice, assumeSameStructure)
        $(SUBREF slice, ReplaceArrayWithPointer)
        $(SUBREF slice, DeepElementType)
    )
)
$(TR $(TDNW Iteration)
     $(TDNW $(SUBMODULE iteration))
     $(TD
        $(SUBREF iteration, transposed)
        $(SUBREF iteration, strided)
        $(SUBREF iteration, reversed)
        $(SUBREF iteration, rotated)
        $(SUBREF iteration, everted)
        $(SUBREF iteration, swapped)
        $(SUBREF iteration, allReversed)
        $(SUBREF iteration, dropToHypercube) and other `drop` primitives
    )
)
$(TR $(TDNW Optimized Selection)
     $(TDNW $(SUBMODULE selection))
     $(TD
        $(SUBREF selection, blocks)
        $(SUBREF selection, windows)
        $(SUBREF selection, diagonal)
        $(SUBREF selection, reshape)
        $(SUBREF selection, byElement)
        $(SUBREF selection, byElementInStandardSimplex)
        $(SUBREF selection, indexSlice)
        $(SUBREF selection, pack)
        $(SUBREF selection, evertPack)
        $(SUBREF selection, unpack)
    )
)
))

Example: slicing, indexing and operations
----
import std.array: array;
import std.range: iota;

auto tensor = 60.iota.array.sliced(3, 4, 5);

assert(tensor[1, 2] == tensor[1][2]);
assert(tensor[1, 2, 3] == tensor[1][2][3]);

assert( tensor[0..$, 0..$, 4] == tensor.transposed!2[4]);
assert(&tensor[0..$, 0..$, 4][1, 2] is &tensor[1, 2, 4]);

tensor[1, 2, 3]++; //`opIndex` returns reference
--tensor[1, 2, 3]; //`opUnary`

++tensor[];
tensor[] -= 1;

// `opIndexAssing` accepts only fully qualified index/slice. Use additional empty slice `[]` operator.
// tensor[0..2] *= 2; // Error: tensor.opIndex(tensor.opSlice(0u, 2u)) is not an lvalue

tensor[0..2][] *= 2;        //OK, empty slice `[]` operator
tensor[0..2, 3, 0..$] /= 2; //OK, 3 index/slice positions are defined.

//fully qualified index defined by static array
size_t[3] index = [1, 2, 3];
assert(tensor[index] == tensor[1, 2, 3]);
----

Example: operations with rvalue slices
----
auto tensor = new int[60].sliced(3, 4, 5);
auto matrix = new int[12].sliced(3, 4);
auto vector = new int[ 3].sliced(3);

foreach(i; 0..3)
    vector[i] = i;

// fill matrix columns
// transposed matrix shape is (4, 3)
//            vector shape is (   3)
matrix.transposed[] = vector;

// fill tensor with vector
// transposed tensor shape is (4, 5, 3)
//            vector shape is (      3)
tensor.transposed!(1, 2)[] = vector;


// transposed tensor shape is (5, 3, 4)
//            matrix shape is (   3, 4)
tensor.transposed!2[] += matrix;

// transposed tensor shape is (5, 4, 3)
// transposed matrix shape is (   4, 3)
tensor.everted[] ^= matrix.transposed; // XOR
----

Example: formatting, see also $(LINK2 std_format.html, std.format).
----
import std.algorithm, std.exception, std.format,
    std.functional, std.conv, std.string, std.range;

Slice!(2, int*) toMatrix(string str)
{
    string[][] data = str.lineSplitter.filter!(not!empty).map!split.array;
    size_t rows = data.length.enforce("empty input");
    size_t columns = data[0].length.enforce("empty first row");
    data.each!(a => enforce(a.length == columns, "rows have different lengths"));

    auto slice = new int[rows * columns].sliced(rows, columns);
    foreach(i, line; data)
        foreach(j, num; line)
            slice[i, j] = num.to!int;
    return slice;
}

auto input = "\r1 2  3\r\n 4 5 6\n";
auto ouptut = "1 2 3\n4 5 6\n";
auto fmt = "%(%(%s %)\n%)\n";
assert(format(fmt, toMatrix(input)) == ouptut);
----

License:   $(WEB www.boost.org/LICENSE_1_0.txt, Boost License 1.0).

Authors:   Ilya Yaroshenko

Source:    $(PHOBOSSRC std/_experimental/_ndslice/_package.d)

Macros:
SUBMODULE = $(LINK2 std_experimental_ndslice_$1.html, std.experimental.ndslice.$1)
SUBREF = $(LINK2 std_experimental_ndslice_$1.html#.$2, $(TT $2))$(NBSP)
T2=$(TR $(TDNW $(LREF $1)) $(TD $+))
T4=$(TR $(TDNW $(LREF $1)) $(TD $2) $(TD $3) $(TD $4))
*/
module std.experimental.ndslice;

public import std.experimental.ndslice.slice;
public import std.experimental.ndslice.iteration;
public import std.experimental.ndslice.selection;

//example test
unittest {
    import std.array: array;
    import std.range: iota;

    auto tensor = 60.iota.array.sliced(3, 4, 5);

    assert(tensor[1, 2] == tensor[1][2]);
    assert(tensor[1, 2, 3] == tensor[1][2][3]);

    assert( tensor[0..$, 0..$, 4] == tensor.transposed!2[4]);
    assert(&tensor[0..$, 0..$, 4][1, 2] is &tensor[1, 2, 4]);

    tensor[1, 2, 3]++; //`opIndex` returns reference
    --tensor[1, 2, 3]; //`opUnary`

    ++tensor[];
    tensor[] -= 1;

    // `opIndexAssing` accepts only fully qualified index/slice. Use additional empty slice `[]`.
    static assert(!__traits(compiles), tensor[0..2] *= 2);

    tensor[0..2][] *= 2;        //OK, empty slice
    tensor[0..2, 3, 0..$] /= 2; //OK, 3 index/slice positions are defined.

    //fully qualified index defined by static array
    size_t[3] index = [1, 2, 3];
    assert(tensor[index] == tensor[1, 2, 3]);
}

//example test
unittest {
    auto tensor = new int[60].sliced(3, 4, 5);
    auto matrix = new int[12].sliced(3, 4);
    auto vector = new int[ 3].sliced(3);

    foreach(i; 0..3)
        vector[i] = i;

    // fill matrix columns
    matrix.transposed[] = vector;

    // fill tensor with vector
    // transposed tensor shape is (4, 5, 3)
    //            vector shape is (      3)
    tensor.transposed!(1, 2)[] = vector;


    // transposed tensor shape is (5, 3, 4)
    //            matrix shape is (   3, 4)
    tensor.transposed!2[] += matrix;

    // transposed tensor shape is (5, 4, 3)
    // transposed matrix shape is (   4, 3)
    tensor.everted[] ^= matrix.transposed; // XOR
}

//example test
unittest {
    import std.algorithm, std.exception, std.format,
        std.functional, std.conv, std.string, std.range;

    Slice!(2, int*) toMatrix(string str)
    {
        string[][] data = str.lineSplitter.filter!(not!empty).map!split.array;
        size_t rows = data.length.enforce("empty input");
        size_t columns = data[0].length.enforce("empty first row");
        data.each!(a => enforce(a.length == columns, "rows have different lengths"));

        auto slice = new int[rows * columns].sliced(rows, columns);
        foreach(i, line; data)
            foreach(j, num; line)
                slice[i, j] = num.to!int;
        return slice;
    }

    auto input = "\r1 2  3\r\n 4 5 6\n";
    auto ouptut = "1 2 3\n4 5 6\n";
    auto fmt = "%(%(%s %)\n%)\n";
    assert(format(fmt, toMatrix(input)) == ouptut);
}

unittest
{
    import std.algorithm.comparison: equal;
    import std.range: iota;
    immutable r = 1_000_000.iota;

    auto t0 = r.sliced(1000);
    assert(t0.front == 0);
    assert(t0.back == 999);
    assert(t0[9] == 9);

    auto t1 = t0[10..20];
    assert(t1.front == 10);
    assert(t1.back == 19);
    assert(t1[9] == 19);

    t1.popFront();
    assert(t1.front == 11);
    t1.popFront();
    assert(t1.front == 12);

    t1.popBack();
    assert(t1.back == 18);
    t1.popBack();
    assert(t1.back == 17);

    assert(t1.equal(iota(12, 18)));
}

unittest
{
    import std.algorithm.comparison: equal;
    import std.array: array;
    import std.range: iota;
    auto r = 1_000.iota.array;

    auto t0 = r.sliced(1000);
    assert(t0.length == 1000);
    assert(t0.front == 0);
    assert(t0.back == 999);
    assert(t0[9] == 9);

    auto t1 = t0[10..20];
    assert(t1.front == 10);
    assert(t1.back == 19);
    assert(t1[9] == 19);

    t1.popFront();
    assert(t1.front == 11);
    t1.popFront();
    assert(t1.front == 12);

    t1.popBack();
    assert(t1.back == 18);
    t1.popBack();
    assert(t1.back == 17);

    assert(t1.equal(iota(12, 18)));

    t1.front = 13;
    assert(t1.front == 13);
    t1.front++;
    assert(t1.front == 14);
    t1.front += 2;
    assert(t1.front == 16);
    t1.front = 12;
    assert((t1.front = 12) == 12);

    t1.back = 13;
    assert(t1.back == 13);
    t1.back++;
    assert(t1.back == 14);
    t1.back += 2;
    assert(t1.back == 16);
    t1.back = 12;
    assert((t1.back = 12) == 12);

    t1[3] = 13;
    assert(t1[3] == 13);
    t1[3]++;
    assert(t1[3] == 14);
    t1[3] += 2;
    assert(t1[3] == 16);
    t1[3] = 12;
    assert((t1[3] = 12) == 12);

    t1[3..5] = 100;
    assert(t1[2] != 100);
    assert(t1[3] == 100);
    assert(t1[4] == 100);
    assert(t1[5] != 100);

    t1[3..5] += 100;
    assert(t1[2] <  100);
    assert(t1[3] == 200);
    assert(t1[4] == 200);
    assert(t1[5] <  100);

    --t1[3..5];

    assert(t1[2] <  100);
    assert(t1[3] == 199);
    assert(t1[4] == 199);
    assert(t1[5] <  100);

    --t1[];
    assert(t1[3] == 198);
    assert(t1[4] == 198);

    t1[] += 2;
    assert(t1[3] == 200);
    assert(t1[4] == 200);

    t1[] *= t1[];
    assert(t1[3] == 40000);
    assert(t1[4] == 40000);


    assert(&t1[$-1] is &(t1.back()));
}

unittest
{
    import std.range: iota;
    auto r = (10_000L * 2 * 3 * 4).iota;

    auto t0 = r.sliced(10, 20, 30, 40);
    assert(t0.length == 10);
    assert(t0.length!0 == 10);
    assert(t0.length!1 == 20);
    assert(t0.length!2 == 30);
    assert(t0.length!3 == 40);
}

unittest {
    import std.experimental.ndslice.internal: Iota;
    import std.meta: AliasSeq;
    import std.range;
    foreach(R; AliasSeq!(
        int*, int[], typeof(1.iota),
        const(int)*, const(int)[],
        immutable(int)*, immutable(int)[],
        double*, double[], typeof(10.0.iota),
        Tuple!(double, int[string])*, Tuple!(double, int[string])[]))
    foreach(n; Iota!(1, 4))
    {
        alias S = Slice!(n, R);
        static assert(isRandomAccessRange!S);
        static assert(hasSlicing!S);
        static assert(hasLength!S);
    }

    immutable int[] im = [1,2,3,4,5,6];
    auto slice = im.sliced(2, 3);
}

unittest {
    auto tensor = new int[100].sliced(3, 4, 8);
    assert(&(tensor.back.back.back()) is &tensor[2, 3, 7]);
    assert(&(tensor.front.front.front()) is &tensor[0, 0, 0]);
}

unittest {
    import std.experimental.ndslice.selection: pack;
    auto slice = new int[24].sliced(2, 3, 4);
    auto r0 = slice.pack!1[1, 2];
    slice.pack!1[1, 2] = 4;
    auto r1 = slice[1, 2];
    assert(slice[1, 2, 3] == 4);
}

unittest {
    auto ar = new int[3 * 8 * 9];

    auto tensor = ar.sliced(3, 8, 9);
    tensor[0, 1, 2] = 4;
    tensor[0, 1, 2]++;
    assert(tensor[0, 1, 2] == 5);
    tensor[0, 1, 2]--;
    assert(tensor[0, 1, 2] == 4);
    tensor[0, 1, 2] += 2;
    assert(tensor[0, 1, 2] == 6);

    auto matrix = tensor[0..$, 1, 0..$];
    matrix[] = 10;
    assert(tensor[0, 1, 2] == 10);
    assert(matrix[0, 2] == tensor[0, 1, 2]);
    assert(&matrix[0, 2] is &tensor[0, 1, 2]);
}
