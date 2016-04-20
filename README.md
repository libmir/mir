[![codecov.io](https://codecov.io/github/DlangScience/mir/coverage.svg?branch=master)](https://codecov.io/github/DlangScience/mir?branch=master)
[![Latest version](https://img.shields.io/github/tag/DlangScience/mir.svg?maxAge=3600)](http://code.dlang.org/packages/mir)
[![License](https://img.shields.io/dub/l/mir.svg)](http://code.dlang.org/packages/mir)
[![Gitter](https://img.shields.io/gitter/room/DlangScience/public.svg)](https://gitter.im/DlangScience/public)
[![Circle CI](https://circleci.com/gh/DlangScience/mir.svg?style=svg)](https://circleci.com/gh/DlangScience/mir)

Mir
======
Generic Numeric Library for Science and Machine Learning.

## Contents

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

### In progress

 - `mir.sparse` Sparse Tensors (see sparse branch and `v0.15.1-beta2`+)
  -  `mir.sparse.blas` Spars BLAS

## Documentation

Alpha version of API is available [here](http://docs.mir.dlang.io/latest/index.html).

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
[![Dub downloads](https://img.shields.io/dub/dt/mir.svg)](http://code.dlang.org/packages/mir)

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
| Stable | `libmir`     | [![libmir](https://img.shields.io/aur/version/libmir.svg)](https://aur.archlinux.org/packages/libmir/) [![libmir](https://img.shields.io/aur/votes/libmir.svg)](https://aur.archlinux.org/packages/libmir/) |
| Latest | `libmir-git` | [![libmir-git](https://img.shields.io/aur/version/libmir-git.svg)](https://aur.archlinux.org/packages/libmir-git/) |

### On any platform with import paths

Mir is a pure source code library, that means it can be easily distributed to
any system. So you can just copy Mir's source to your system's dlang import path.
For example on  Linux this is `/usr/include/dlang/dmd/mir`
(or `/usr/include/dlang/dmd/mir` for ldc).

Alternatively you can pass mir's directory directly to dmd and ldc using `-I <path-to-mir>`.

## Contributing

See our [TODO List](https://github.com/DlangScience/mir/issues?q=is%3Aissue+is%3Aopen+label%3A%22New+Package%22).
Mir is very young and we are open for contributing to source code, documentation, examples and benchmarks.

## Notes

- `mir.ndslice` is a development version of the [`std.experimental.ndslice`](http://dlang.org/phobos/std_experimental_ndslice.html) package.
