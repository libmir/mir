[![Dub package](https://img.shields.io/badge/dub-package-FF4081.svg)](http://code.dlang.org/packages/mir)
[![Build Status](https://travis-ci.org/DlangScience/mir.svg?branch=master)](https://travis-ci.org/DlangScience/mir)
[![codecov.io](https://codecov.io/github/DlangScience/mir/coverage.svg?branch=master)](https://codecov.io/github/DlangScience/mir?branch=master)
[![Join the chat at https://gitter.im/DlangScience/public](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/DlangScience/public?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

Mir
======
Numeric library and mirror for upcoming numeric packages for the Dlang standard library.

## Packages
 - `mir.ndslice` [Multidimensional Random Access Ranges and Arrays](http://dlang.org/phobos-prerelease/std_experimental_ndslice.html)
 - `mir.las.sum` Funcions and Output Ranges for Summation Algorithms. Works with user-defined types.
  - Precise algorithms: improved analog of Python's `fsum`
  - Pairwise algorithms: fast version for Input Ranges
  - Kahan, KBN, KB2 algorithms

## Notes
- `mir.ndslice` is a development version of the `std.experimental.ndslice` package.
- Mir can be used with DMD (reference D compiler) front end >= `2.068`. So ndslice can be used with LDC (LLVM D Compiler) `0.17.0`+.
- Mir is going to be a testing package for the future Dlang BLAS implementation.
