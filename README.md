[![codecov.io](https://codecov.io/github/DlangScience/mir/coverage.svg?branch=master)](https://codecov.io/github/DlangScience/mir?branch=master)
[![Build Status](https://travis-ci.org/DlangScience/mir.svg?branch=master)](https://travis-ci.org/DlangScience/mir)
[![Build status](https://ci.appveyor.com/api/projects/status/ir2k3o3j0isqp7pw/branch/master?svg=true)](https://ci.appveyor.com/project/9il/mir/branch/master)
[![Circle CI](https://circleci.com/gh/DlangScience/mir.svg?style=svg)](https://circleci.com/gh/DlangScience/mir)

[![Dub version](https://img.shields.io/dub/v/mir.svg)](http://code.dlang.org/packages/mir)
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
 - `mir.combinatorics`
  - `combinations`
  - `permutations`
  - `cartesianPower`
  - `combinationsRepeat`

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
- Mir is going to be a testing package for the future Dlang BLAS implementation.

## Compatibility

|           | Linux | Mac OS X | Windows |
|-----------|-------|----------|---------|
| DMD 64 | [![Build Status](https://travis-ci.org/DlangScience/mir.svg?branch=master)](https://travis-ci.org/DlangScience/mir) | [![Build Status](https://travis-ci.org/DlangScience/mir.svg?branch=master)](https://travis-ci.org/DlangScience/mir) | [![Build status](https://ci.appveyor.com/api/projects/status/ir2k3o3j0isqp7pw/branch/master?svg=true)](https://ci.appveyor.com/project/9il/mir/branch/master) |
| DMD 32 | [![Build Status](https://travis-ci.org/DlangScience/mir.svg?branch=master)](https://travis-ci.org/DlangScience/mir) | OS X >= 10.7 is x86-64 only | [![Build status](https://ci.appveyor.com/api/projects/status/ir2k3o3j0isqp7pw/branch/master?svg=true)](https://ci.appveyor.com/project/9il/mir/branch/master) |
| LDC 64 | [![Build Status](https://travis-ci.org/DlangScience/mir.svg?branch=master)](https://travis-ci.org/DlangScience/mir) | [![Build Status](https://travis-ci.org/DlangScience/mir.svg?branch=master)](https://travis-ci.org/DlangScience/mir) | [#120](https://github.com/DlangScience/mir/issues/120) |
| LDC 32 | [![Build Status](https://travis-ci.org/DlangScience/mir.svg?branch=master)](https://travis-ci.org/DlangScience/mir) | OS X >= 10.7 is x86-64 only | [#120](https://github.com/DlangScience/mir/issues/120) |

- DMD (reference D compiler) >= `2.068`
- LDC (LLVM D Compiler) `0.17.0`+.

## Packages

### On any platform with dub

[![Dub version](https://img.shields.io/dub/v/mir.svg)](http://code.dlang.org/packages/mir)

[Dub](https://code.dlang.org/getting_started) is the D's package manager.
You can create a new project with:

```
dub init --format=json <project-name>
```

Now you need to edit the `dub.json` add `mir` as dependency:

```
{
	...
	"dependencies": {
		"mir": "~><current-version>"
	}
}
```

Now you can create a main file in the `source` and run your code with:

```
dub
```

### Arch Linux

| Type   | Name         | Version  |
|--------|--------------|----------|
| Stable | `libmir`     | [![libmir](https://img.shields.io/aur/version/libmir.svg)](https://aur.archlinux.org/packages/libmir/) |
| Latest | `libmir-git` | [![libmir-git](https://img.shields.io/aur/version/libmir-git.svg)](https://aur.archlinux.org/packages/libmir-git/) |

### On any platform with import paths

Mir is a pure source code library, that means it can be easily distributed to
any system. So you can just copy Mir's source to your system's dlang import path.
For example on  Linux this is `/usr/include/dlang/dmd/mir`
(or `/usr/include/dlang/dmd/mir` for ldc).

Alternatively you can pass mir's directory directly to dmd and ldc using `-I <path-to-mir>`.
