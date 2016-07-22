extern(C) auto m(T)(T[] ps, size_t n)
{
    import mir.random.discrete : naiveDiscrete;
    import std.random : Mt19937;
    auto gen = Mt19937(42);

    auto psArr = ps.dup;

    foreach (i, ref p; psArr[1..$])
        p += psArr[i];

    auto ds = naiveDiscrete(psArr);
    size_t[] arr = new size_t[ps.length];
    foreach (i; 0..n)
        arr[ds(gen)]++;
    return arr;
}
