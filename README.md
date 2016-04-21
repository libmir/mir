[![codecov.io](https://codecov.io/github/libmir/mir/coverage.svg?branch=master)](https://codecov.io/github/libmir/mir?branch=master)
[![Latest version](https://img.shields.io/github/tag/libmir/mir.svg?maxAge=3600)](http://code.dlang.org/packages/mir)
[![License](https://img.shields.io/dub/l/mir.svg)](http://code.dlang.org/packages/mir)
[![Gitter](https://img.shields.io/gitter/room/libmir/public.svg)](https://gitter.im/libmir/public)
[![Circle CI](https://circleci.com/gh/libmir/mir.svg?style=svg)](https://circleci.com/gh/libmir/mir)

Mir
======
Generic Numerical Library for Science and Machine Learning.

Contents
--------

 - `mir.ndslice` [Multidimensional Random Access Ranges and Arrays](http://dlang.org/phobos-prerelease/std_experimental_ndslice.html)
 - `mir.las.sum` Functions and Output Ranges for Summation Algorithms. Works with user-defined types.
  - Precise algorithm: improved analog of Python's `fsum`
  - Pairwise algorithm: fast version for Input Ranges
  - Kahan, KBN, and KB2 algorithms
 - `mir.combinatorics` Combinations, combinations with repeats, cartesian power, permutations.

### In progress

 - `mir.sparse` Sparse Tensors (see sparse branch and `v0.15.1-beta2`+)
  -  `mir.sparse.blas` Spars BLAS

Documentation
-------------

Alpha version of API is available [here](http://docs.mir.dlang.io/latest/index.html).

Compatibility
-------------

|           | Linux | Mac OS X | Windows |
|-----------|-------|----------|---------|
| DMD 64 | [![Build Status](https://travis-ci.org/libmir/mir.svg?branch=master)](https://travis-ci.org/libmir/mir) | [![Build Status](https://travis-ci.org/libmir/mir.svg?branch=master)](https://travis-ci.org/libmir/mir) | [![Build status](https://ci.appveyor.com/api/projects/status/f2n4dih5s4c32q7u/branch/master?svg=true)](https://ci.appveyor.com/project/9il/mir/branch/master) |
| DMD 32 | [![Build Status](https://travis-ci.org/libmir/mir.svg?branch=master)](https://travis-ci.org/libmir/mir) | OS X >= 10.7 is x86-64 only | [![Build status](https://ci.appveyor.com/api/projects/status/f2n4dih5s4c32q7u/branch/master?svg=true)](https://ci.appveyor.com/project/9il/mir/branch/master) |
| LDC 64 | [![Build Status](https://travis-ci.org/libmir/mir.svg?branch=master)](https://travis-ci.org/libmir/mir) | [![Build Status](https://travis-ci.org/libmir/mir.svg?branch=master)](https://travis-ci.org/libmir/mir) | [#120](https://github.com/libmir/mir/issues/120) |
| LDC 32 | [![Build Status](https://travis-ci.org/libmir/mir.svg?branch=master)](https://travis-ci.org/libmir/mir) | OS X >= 10.7 is x86-64 only | [#120](https://github.com/libmir/mir/issues/120) |

- DMD (reference D compiler) >= `2.068`
- LDC (LLVM D Compiler) `0.17.0`+.

Installation
------------

### Rapid edit-run cycle without dub

The easiest way to execute your code is with `rdmd`.

```
rdmd -Isource examples/means_of_columns.d
```

`rdmd` is a companion to the `dmd` compiler that simplifies the typical edit-compile-link-run or edit-make-run cycle to a rapid edit-run cycle. Like make and other tools, `rdmd` uses the relative dates of the files involved to minimize the amount of work necessary. Unlike make, `rdmd` tracks dependencies and freshness without requiring additional information from the user.
You can find more information [here](https://dlang.org/rdmd.html).

### Fast setup with the package manager dub

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

### Compile with ldc

The easiest way is to specify mir's sources during compilation:

```
ldc -Isource examples/means_of_columns.d
```

If you copy `mir`'s sources to `/usr/include/dlang/ldc/mir` you don't even need the `-Isource` include.
You might want to have a look at dynamic linking with dmd below - it works with `ldc` too.

For an additional performance boost, you can pass `-release -inline` to `ldc`.

### Compile with dmd

__Warning__: Manually using `dmd` is a bit more complicated and if you are new
to DLang, we advise you to use either `rdmd`, `dub` or `ldc`.

#### Step 1: Compile your file(s)

```
dmd -c -Isource examples/means_of_columns.d
```

If you do this more often, you probably want to install a Mir package or put the mir sources to `/usr/include/dlang/dmd`.

Now you can either use static linking (will copy everything into the binary) or dynamic linking (will load binary on run) to create an executable.

#### Step 2a: Static linking

Static linking will result in copying all library routines in your binary. While this might require more disk space, it is faster and more portable.
The only downside is that it requires recompilation if `mir` is updated.

##### 2.a.1: Create static mir library

You need to create a static library of `mir` once:

```
dmd -lib -oflibmir.a $(find source -name '*.d')
```

If you have `dub` available, you can also use `dub -c static-lib`.

##### 2.a.2: Link statically

```
dmd means_of_columns.o libmir.a
```

#### Step 2b: Dynamic linking

With dynamic linking the OS will bind the binary and it's required external shared libraries at runtime.

##### 2.b.1: Create shared mir library

You need to create a shared, dynamic library of `mir` once:

```
dmd -shared -oflibmir.so -defaultlib=libphobos2.so -fPIC $(find source -name '*.d')
```

We need to specify:

- `-defaultlib=libphobos2.so` as Phobos is statically linked by default.
- `fPIC` to create Position Independent Code (it creates a global offset table)

If you have `dub` available, you can also use `dub -c dynamic-lib`.

##### 2.b.2: Link dynamically

```
dmd means_of_columns.o -Llibmir.so -L-rpath=.
```

You can inspect the dynamic linking with `ldd means_of_columns`.

### Packages

Putting `mir` in `/usr/include/dlang/dmd`, avoids the need for `-Isource`.
So you can execute your code with `rdmd <your-file.d>`

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
