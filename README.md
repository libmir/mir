[![Dub version](https://img.shields.io/dub/v/mir.svg)](http://code.dlang.org/packages/mir)
[![Build Status](https://travis-ci.org/DlangScience/mir.svg?branch=master)](https://travis-ci.org/DlangScience/mir)
[![codecov.io](https://codecov.io/github/DlangScience/mir/coverage.svg?branch=master)](https://codecov.io/github/DlangScience/mir?branch=master)
[![License](https://img.shields.io/dub/l/mir.svg)](http://code.dlang.org/packages/mir)
[![Dub downloads](https://img.shields.io/dub/dt/mir.svg)](http://code.dlang.org/packages/mir)
[![Gitter](https://img.shields.io/gitter/room/DlangScience/public.svg)](https://gitter.im/DlangScience/public)

Mir
======
Numeric library and mirror for upcoming numeric packages for the Dlang standard library.

## Packages
 - `mir.ndslice` [Multidimensional Random Access Ranges and Arrays](http://dlang.org/phobos-prerelease/std_experimental_ndslice.html)
 - `mir.las.sum` Functions and Output Ranges for Summation Algorithms. Works with user-defined types.
  - Precise algorithm: improved analog of Python's `fsum`
  - Pairwise algorithm: fast version for Input Ranges
  - Kahan, KBN, and KB2 algorithms

## TODO
 - `mir.sparse` [multidimensional sparse arrays](https://github.com/DlangScience/mir/issues/43)
 - `mir.fft` [multidimensional FFT](https://github.com/DlangScience/mir/issues/45)
 - `mir.random` [non-uniform random generators](https://github.com/DlangScience/mir/issues/46)
 - `mir.data` [sci data formats](https://github.com/DlangScience/mir/issues/47)
 - `mir.las` [linear algebra subroutines](https://github.com/DlangScience/mir/issues/48)
 - `mir.stat` [statistical functions](https://github.com/DlangScience/mir/issues/49)
  - `mir.stat.probcounting` hyperloglog algorithm implementation


## Notes
- `mir.ndslice` is a development version of the `std.experimental.ndslice` package.
- Mir can be used with DMD (reference D compiler) front end >= `2.068`. So ndslice can be used with LDC (LLVM D Compiler) `0.17.0`+.
- Mir is going to be a testing package for the future Dlang BLAS implementation.
