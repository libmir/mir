/+
## Guide for Slice/Matrix/BLAS contributors

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
    significantly complex for user. `reshaped` is a good example where
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
$(TR $(TH Category) $(TH Submodule) $(TH Functions)
)
$(TR $(TDNW Slicing)
     $(TDNW $(SUBMODULE slice))
     $(TD
        $(SUBREF slice, sliced)
    )
)
$(TR $(TDNW Multidimensional operators)
     $(TDNW $(SUBMODULE operators))
     $(TD
        $(SUBREF operators, transposed)
        $(SUBREF operators, strided)
        $(SUBREF operators, reversed)
        $(SUBREF operators, packed)
        $(SUBREF operators, allReversed)
        $(SUBREF operators, everted)
        $(SUBREF operators, packEverted)
        $(SUBREF operators, swapped)
        $(SUBREF operators, unpacked)
        $(SUBREF operators, dropToNCube)
        $(SUBREF operators, dropToNCube) and other `drop*` primitives
    )
)
$(TR $(TDNW Optimized iterators)
     $(TDNW $(SUBMODULE iterators))
     $(TD
        $(SUBREF iterators, byElement)
    )
)
$(TR $(TDNW Shape and strides)
     $(TDNW $(SUBMODULE structure))
     $(TD
        $(SUBREF structure, Structure.isBlasCompatible)
        $(SUBREF structure, Structure.isContiguous)
        $(SUBREF structure, Structure.isNormal)
        $(SUBREF structure, Structure.isPure)
        $(SUBREF structure, Structure.normalized)
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

// `opIndexAssing` accepts only fully qualified index/slice. Use additional empty slice `[]`.
// tensor[0..2] *= 2; // Error: tensor.opIndex(tensor.opSlice(0u, 2u)) is not an lvalue

tensor[0..2][] *= 2;        //OK, empty slice
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

public import std.experimental.ndslice.iterators;
public import std.experimental.ndslice.operators;
public import std.experimental.ndslice.slice;
public import std.experimental.ndslice.structure;

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
