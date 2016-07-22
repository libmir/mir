extern(C) auto m(T)(T[] ps, size_t n)
{
    import mir.random.discrete : discrete;
    import std.random : Mt19937;
    auto gen = Mt19937(42);

    auto ds = discrete(ps);
    size_t[] arr = new size_t[ps.length];
    foreach (i; 0..n)
        arr[ds(gen)]++;
    return arr;
}
