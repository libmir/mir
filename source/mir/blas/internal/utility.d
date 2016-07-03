module mir.blas.internal.utility;

import std.traits;
import mir.internal.utility;

void set_zero(size_t A, size_t B, size_t C, V)(ref V[C][B][A] to)
{
    foreach (p; Iota!A)
    foreach (m; Iota!B)
    foreach (n; Iota!C)
        to[p][m][n] = 0;
}

void load(size_t A, size_t B, size_t C, V)(ref V[C][B][A] to, ref V[C][B][A] from)
{
    foreach (p; Iota!A)
    foreach (m; Iota!B)
    foreach (n; Iota!C)
        to[p][m][n] = from[p][m][n];
}

void load(size_t A, size_t C, V, F)
(ref V[C][A] to, ref const F[C][A] from)
    if(isFloatingPoint!F || isSIMDVector!F)
{
    static if (isSIMDVector!V && !isSIMDVector!F)
        version(LDC)
        foreach (n; Iota!C)
        foreach (p; Iota!A)
                to[p][n] = from[p][n];
        else
        foreach (n; Iota!C)
        foreach (p; Iota!A)
        {
            auto e = from[p][n];
            foreach(s; Iota!(to[p][n].array.length))
                to[p][n].array[s] = e;
        }
    else
    foreach (n; Iota!C)
    foreach (p; Iota!A)
        to[p][n] = from[p][n];
}

void load(size_t A, V, F)
(ref V[A] to, ref const F[A] from)
    if(isFloatingPoint!F || isSIMDVector!F)
{
    static if (isSIMDVector!V && !isSIMDVector!F)
        version(LDC)
        foreach (p; Iota!A)
                to[p] = from[p];
        else
        foreach (p; Iota!A)
        {
            auto e = from[p];
            foreach(s; Iota!(to[p].array.length))
                to[p].array[s] = e;
        }
    else
    foreach (p; Iota!A)
        to[p] = from[p];
}
