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
Пакет `ndslice` предоставляет компактный и гибкий API 
для работы с многомерными массивами и итераторами.
Пакет предназначен для создания алгоритмов машинного обучения и обработки изображений, 
расчетов в физики, статистике и линейной алгебре.

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


$(H2 Example: image proccessing)

Note: Пример доступен на $(LINK2 GitHub, https://github.com/DlangScience/examples/tree/master/image_processing/median-filter).

В качестве примера реализован $(LINK2 https://en.wikipedia.org/wiki/Median_filter, медианный filter).
Функция `movingWindowByChannel` может быть также использована и с другми фильтрами,
аргументом которых является скользящее окно,
в частности матрицами свертки, такими как $(LINK2 https://en.wikipedia.org/wiki/Sobel_operator, Sobel operator).

`movingWindowByChannel` итерируется по изображению в режиме скользящего окна.
Каждое окно передается в `filter`, который вычичляет значение пикселя
соответсвующее данному окну.

Данная функция не вычилсляет краевые случаи, когда окно перекрывается с 
изображением частично. Однако она вполне может использоваться для такого расчета.
Для этого, к примеру, достаточно создать расширенное изображение,
с краями отраженными от настоящего изображения, и уже у нему пременить данную функцию.

---
/++
Params:
    filter = унарная функция. В качестве аргумента выступает окно размерности 2D.
    image = изображение размерности `(h, w, c)`,
        где с - количество каналов в изображении
    nr = количество строк в окне
    nс = количество колонок в окне

Returns:
    изображение размерности `(h - nr + 1, w - nc + 1, c)`,
        где с - количество каналов в изображении.
        Гарантировано плотнаое размещение данных в памяти.
+/
Slice!(3, C*) movingWindowByChannel(alias filter, C)
(Slice!(3, C*) image, size_t nr, size_t nc)
{
    import std.algorithm.iteration: map;
    import std.array: array;
    auto wnds = image        // 1. 3D : the last dimension is color channel 
        .pack!1              // 2. 2D of 1D : packs the last dimension
        .windows(nr, nc)     // 3. 2D of 2D of 1D : splits image to overlapping windows
        .unpack              // 4. 5D : unpacks windows
        .transposed!(0, 1, 4)// 5. 5D : brings color channel dimension to third position
        .pack!2;             // 6. 3D of 2D : packs the last two dimensions
    return wnds
        .byElement           // 7. Range of 2D : gets the range of all elements in `wnds`
        .map!filter          // 8. Range of C : 2D to C lazy conversion
        .array               // 9. C[] : sole memory allocation in this function
        .sliced(wnds.shape); //10. 3D : returns slice with corresponding shape
}
---

Также потребуется функция вычисляющее значение медианы итератора.

---
/++
Params:
    r = input range
    buf = буффер с длинной не менее количества элементов в `r`
Returns:
    медианное значение в рэндже `r`
+/
T median(Range, T)(Range r, T[] buf)
{
    import std.algorithm.sorting: sort;
    size_t n;
    foreach(e; r)
        buf[n++] = e;
    buf[0..n].sort();
    immutable m = n >> 1;
    return n & 1 ? buf[m] : cast(T)((buf[m-1] + buf[m])/2);
}
---

Функция `main`:
---
void main(string[] args)
{
    import std.conv: to;
    import std.getopt: getopt, defaultGetoptPrinter;
    import std.path: stripExtension;

    uint nr, nc, def = 3;
    auto helpInformation = args.getopt(
        "nr", "number of rows in window, default value is " ~ def.to!string, &nr, 
        "nc", "number of columns in window default value equals to nr", &nc);
    if(helpInformation.helpWanted)
    {
        defaultGetoptPrinter(
            "Usage: median-filter [<options...>] [<file_names...>]\noptions:", 
            helpInformation.options);
        return;
    }
    if(!nr) nr = def;
    if(!nc) nc = nr;

    auto buf = new ubyte[nr * nc];

    foreach(name; args[1..$])
    {
        import imageformats; // can be found at code.dlang.org
    
        IFImage image = read_image(name);

        auto ret = image.pixels
            .sliced(image.h, image.w, image.c)
            .movingWindowByChannel
                !(window => median(window.byElement, buf))
                 (nr, nc);

        write_image(
            name.stripExtension ~ "_filtered.png",
            ret.length!1,
            ret.length!0,
            (&ret[0, 0, 0])[0..ret.elementsCount]);
    }
}
---

Полученаая программа работает как с цветными так и с чернобелыми изображениями.

---
$ median-filter --help
Usage: median-filter [<options...>] [<file_names...>]
options:
     --nr number of rows in window, default value is 3
     --nc number of columns in window default value equals to nr
-h --help This help information.
---

$(H2 Сравнение с `numpy.ndarray`)
`numpy` - безусловно один из самых успешных математических пакетов,
упростивший жизнь многим инженерам и ученым.
Однако, в виду особенностей реализации языка Python,
при желании программитса использовать функциональность,
которая не представлена в `numpy`,
он может обнаружить, что встроеных функций реализованных
специально для `numpy` ему не хватает, а их реализация на
Python работает очень медленно.
Решением проблемы может быть расширение самого `numpy`,
однако это представляется малообоснованным поскольку каждая,
даже самая простая функция функция `numpy`,
которая обращается непосредстванно к данным `ndarray`,
для должной производительности должна быть реализована на C.

В тоже время при работе с `ndslice` инженеру доступна вся
номенклатура стандартной библиотеки D, и функции,
которые он напишет сам, будут работать так же эффективно,
как если бы они были написаны на С.

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

// relaxed
unittest {

    import std.experimental.ndslice;

    static Slice!(3, ubyte*) movingWindowByChannel
    (Slice!(3, ubyte*) image, size_t nr, size_t nc, ubyte delegate(Slice!(2, ubyte*)) filter)
    {
        import std.algorithm.iteration: map;
        import std.array: array;
        auto wnds = image
            .pack!1
            .windows(nr, nc)
            .unpack
            .transposed!(0, 1, 4)
            .pack!2;
        return wnds
            .byElement
            .map!filter
            .array
            .sliced(wnds.shape);
    }

    /++
    Params:
        r = input range
        buf = буффер с длинной не менее количества элементов в `r`
    Returns:
        медианное значение в рэндже `r`
    +/
    static T median(Range, T)(Range r, T[] buf)
    {
        import std.algorithm.sorting: sort;
        size_t n;
        foreach(e; r)
            buf[n++] = e;
        buf[0..n].sort();
        immutable m = n >> 1;
        return n & 1 ? buf[m] : cast(T)((buf[m-1] + buf[m])/2);
    }

    /++
    Работает как с цветными так и с чернобелыми изображениями.
    +/
    import std.conv: to;
    import std.getopt: getopt, defaultGetoptPrinter;
    import std.path: stripExtension;

    auto args = ["std"];
    uint nr, nc, def = 3;
    auto helpInformation = args.getopt(
        "nr", "number of rows in window, default value is " ~ def.to!string, &nr,
        "nc", "number of columns in window default value equals to nr", &nc);
    if(helpInformation.helpWanted)
    {
        defaultGetoptPrinter(
            "Usage: median-filter [<options...>] [<file_names...>]\noptions:",
            helpInformation.options);
        return;
    }
    if(!nr) nr = def;
    if(!nc) nc = nr;

    auto buf = new ubyte[nr * nc];

    foreach(name; args[1..$])
    {
        //import imageformats;

        //IFImage image = read_image(name);

        //auto ret = image.pixels
        //    .sliced(image.h, image.w, image.c)
        auto ret =
            movingWindowByChannel
                 (new ubyte[300].sliced(10, 10, 3), nr, nc, window => median(window.byElement, buf));

        //write_image(
        //    name.stripExtension ~ "_filtered.png",
        //    ret.length!1,
        //    ret.length!0,
        //    (&ret[0, 0, 0])[0..ret.elementsCount]);
    }
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
