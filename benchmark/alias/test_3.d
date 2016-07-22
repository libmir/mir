extern(D) auto m(T)(T[] ps, size_t n)
{
    import std.random : Mt19937, uniform;
    auto gen = Mt19937(42);

    size_t[] arr = new size_t[ps.length];
    foreach (i; 0..n)
        arr[uniform!("[)", size_t, size_t)(0, ps.length, gen)]++;
    return arr;
}
