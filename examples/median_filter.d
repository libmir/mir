#!/usr/bin/env dub
/+ dub.json:
{
    "name": "median_filter",
    "dependencies": {"mir": {"path": ".."}, "imageformats": "==6.1.0"},
}
+/

import mir.ndslice;

/++
A median filter is implemented as an example. The function
`movingWindowByChannel` can also be used with other filters that use a sliding
window as the argument, in particular with convolution matrices such as the
$(LINK2 https://en.wikipedia.org/wiki/Sobel_operator, Sobel operator).

`movingWindowByChannel` iterates over an image in sliding window mode.
Each window is transferred to a `filter`, which calculates the value of the
pixel that corresponds to the given window.

This function does not calculate border cases in which a window overlaps
the image partially. However, the function can still be used to carry out such
calculations. That can be done by creating an amplified image, with the edges
reflected from the original image, and then applying the given function to the
new file.

Note: You can find the example at
$(LINK2 https://github.com/DlangScience/examples/tree/master/image_processing/median-filter, GitHub).

Params:
    filter = unary function. Dimension window 2D is the argument.
    image = image dimensions `(h, w, c)`,
        where с is the number of channels in the image
    nr = number of rows in the window
    nс = number of columns in the window

Returns:
    image dimensions `(h - nr + 1, w - nc + 1, c)`,
        where с is the number of channels in the image.
        Dense data layout is guaranteed.
+/

Slice!(Contiguous, [3], C*) movingWindowByChannel(alias filter, C)
(Slice!(Universal, [3], C*) image, size_t nr, size_t nc)
{
        // 0. 3D
        // The last dimension represents the color channel.
    return image
        // 1. 2D composed of 1D
        // Packs the last dimension.
        .pack!1
        // 2. 2D composed of 2D composed of 1D
        // Splits image into overlapping windows.
        .windows(nr, nc)
        // 3. 5D
        // Unpacks the windows.
        .unpack
        // 4. 5D
        // Brings the color channel dimension to the third position.
        .transposed!(0, 1, 4)
        // 5. 3D Composed of 2D
        // Packs the last two dimensions.
        .pack!2
        // 2D to pixel lazy conversion.
        .map!filter
        // Creates the new image. The only memory allocation in this function.
        .slice;
}

/++
Params:
    r = input range
    buf = buffer with length no less than the number of elements in `r`
Returns:
    median value over the range `r`
+/
T median(SliceKind kind, Iterator, T)(Slice!(kind, [2], Iterator) sl, T[] buf)
{
    import std.algorithm.sorting : topN;
    // copy sl to the buffer
    auto retPtr = reduce!(
        (ptr, elem) {
            *ptr = elem;
            return ptr + 1;
        } )(buf.ptr, sl);
    auto n = retPtr - buf.ptr;
    buf[0 .. n].topN(n / 2);
    return buf[n / 2];
}

/++
This program works both with color and grayscale images.
+/
void main(string[] args)
{
    import std.conv: to;
    import std.getopt: getopt, defaultGetoptPrinter;
    import std.path: stripExtension;

    uint nr, nc, def = 3;
    auto helpInformation = args.getopt(
        "nr", "number of rows in window, default value is " ~ def.to!string, &nr,
        "nc", "number of columns in window, default value is equal to nr", &nc);
    if (helpInformation.helpWanted)
    {
        defaultGetoptPrinter(
            "Usage: median-filter [<options...>] [<file_names...>]\noptions:",
            helpInformation.options);
        return;
    }
    if (!nr) nr = def;
    if (!nc) nc = nr;

    auto buf = new ubyte[nr * nc];

    if (args.length == 1)
    {
        import std.stdio: writeln;
        writeln("No input file given");
    }

    foreach (name; args[1 .. $])
    {
        import imageformats; // can be found at code.dlang.org

        IFImage image = read_image(name);

        auto ret = image.pixels
            .sliced(cast(size_t)image.h, cast(size_t)image.w, cast(size_t)image.c)
            .universal
            .movingWindowByChannel
                !(window => median(window, buf))
                 (nr, nc);

        write_image(
            name.stripExtension ~ "_filtered.png",
            ret.length!1,
            ret.length!0,
            (&ret[0, 0, 0])[0 .. ret.elementsCount]);
    }
}
