[![codecov.io](https://codecov.io/github/libmir/mir/coverage.svg?branch=master)](https://codecov.io/github/libmir/mir?branch=master)
[![Latest version](https://img.shields.io/github/tag/libmir/mir.svg?maxAge=3600)](http://code.dlang.org/packages/mir)
[![License](https://img.shields.io/dub/l/mir.svg)](http://code.dlang.org/packages/mir)
[![Gitter](https://img.shields.io/gitter/room/libmir/public.svg)](https://gitter.im/libmir/public)
[![Circle CI](https://circleci.com/gh/libmir/mir.svg?style=svg)](https://circleci.com/gh/libmir/mir)

Mir
======
Generic Numerical Library for Science and Machine Learning.

##### Projects based on Mir
- [Computer Vision Library for D Programming Language](https://github.com/ljubobratovicrelja/dcv)

Documentation
-------------

API can be found [here](http://docs.mir.dlang.io/latest/index.html).
Read also the [Mir blog](http://blog.mir.dlang.io/).

Contents
--------

- `mir.ndslice` [Multidimensional Random Access Ranges and Arrays](http://docs.mir.dlang.io/latest/mir_ndslice.html)
- `mir.sparse` Sparse Tensors
 - `Sparse` - DOK format
 - Different ranges for COO format
 - `CompressedTensor` - CSR/CSC formats
- `mir.sparse.blas` - Sparse BLAS for `CompressedTensor`
- `mir.model.lda.hoffman` - Online variational Bayes for latent Dirichlet allocation (Online VB LDA) for sparse documents. LDA is used for topic modeling.
- `mir.combinatorics` Combinations, combinations with repeats, cartesian power, permutations.
- `mir.las.sum` Functions and Output Ranges for Summation Algorithms. Works with user-defined types.
 - Precise algorithm: improved analog of Python's `fsum`
 - Pairwise algorithm: fast version for Input Ranges
 - Kahan, KBN, and KB2 algorithms

### In progress

 - `mir.random` - non-uniform RNGs.
 - `mir.glas` - Generic Linear Algebra Subroutines.

Compatibility
-------------

- LDC (LLVM D Compiler) >= `1.1.0-beta2` (recommended compiler).
- DMD (reference D compiler) >= `2.072.1`.

|           | Linux | Mac OS X | Windows |
|-----------|-------|----------|---------|
| LDC 64 | [![Build Status](https://travis-ci.org/libmir/mir.svg?branch=master)](https://travis-ci.org/libmir/mir) | [![Build Status](https://travis-ci.org/libmir/mir.svg?branch=master)](https://travis-ci.org/libmir/mir) | [![Build status](https://ci.appveyor.com/api/projects/status/f2n4dih5s4c32q7u/branch/master?svg=true)](https://ci.appveyor.com/project/9il/mir/branch/master) by ignoring issue [#120](https://github.com/libmir/mir/issues/120) |
| LDC 32 | [![Build Status](https://travis-ci.org/libmir/mir.svg?branch=master)](https://travis-ci.org/libmir/mir) | OS X >= 10.7 is x86-64 only | [![Build status](https://ci.appveyor.com/api/projects/status/f2n4dih5s4c32q7u/branch/master?svg=true)](https://ci.appveyor.com/project/9il/mir/branch/master) by ignoring issue [#120](https://github.com/libmir/mir/issues/120) |
| DMD 64 | [![Build Status](https://travis-ci.org/libmir/mir.svg?branch=master)](https://travis-ci.org/libmir/mir) | [![Build Status](https://travis-ci.org/libmir/mir.svg?branch=master)](https://travis-ci.org/libmir/mir) | [![Build status](https://ci.appveyor.com/api/projects/status/f2n4dih5s4c32q7u/branch/master?svg=true)](https://ci.appveyor.com/project/9il/mir/branch/master) |
| DMD 32 | [![Build Status](https://travis-ci.org/libmir/mir.svg?branch=master)](https://travis-ci.org/libmir/mir) | OS X >= 10.7 is x86-64 only | [![Build status](https://ci.appveyor.com/api/projects/status/f2n4dih5s4c32q7u/branch/master?svg=true)](https://ci.appveyor.com/project/9il/mir/branch/master) |

Installation
------------

### Fast setup with the dub package manager

[![Dub version](https://img.shields.io/dub/v/mir.svg)](http://code.dlang.org/packages/mir)
[![Dub downloads](https://img.shields.io/dub/dt/mir.svg)](http://code.dlang.org/packages/mir)

[Dub](https://code.dlang.org/getting_started) is the D's package manager.
You can create a new project with:

```
dub init --format=json <project-name>
```

Now you need to edit the `dub.json` add `mir` as dependency and set its targetType to `executable`.

```json
{
	...
	"dependencies": {
		"mir": "~><current-version>"
	},
	"targetType": "executable"
}
```

Now you can create a main file in the `source` and run your code with:

```
dub
```

You can use a different compile with `dub --compiler ldc`.
For a performance boost, add `-b release` to let the compiler perform additional
optimizations, inlining, removal of bound checking and `assert` statements.

#### Arch Linux

| Type   | Name         | Version  |
|--------|--------------|----------|
| Stable | `libmir`     | [![libmir](https://img.shields.io/aur/version/libmir.svg)](https://aur.archlinux.org/packages/libmir/) [![libmir](https://img.shields.io/aur/votes/libmir.svg)](https://aur.archlinux.org/packages/libmir/) |
| Latest | `libmir-git` | [![libmir-git](https://img.shields.io/aur/version/libmir-git.svg)](https://aur.archlinux.org/packages/libmir-git/) |

Contributing
------------

See our [TODO List](https://github.com/libmir/mir/issues?q=is%3Aissue+is%3Aopen+label%3A%22New+Package%22).
Mir is very young and we are open for contributing to source code, documentation, examples and benchmarks.

Notes
-----

- `mir.ndslice` is a development version of the [`std.experimental.ndslice`](http://dlang.org/phobos/std_experimental_ndslice.html) package.
