/++

$(H1 GLAS (Generic Linear Algebra Subprograms))

The GLAS are generic routines that provide standard building blocks for performing vector and matrix operations.
The Level 1 GLAS perform scalar, vector and vector-vector operations,
the Level 2 GLAS perform matrix-vector operations, and the Level 3 GLAS perform matrix-matrix operations.

$(H2 Implemented Routines)

The list of already implemented features.

$(BOOKTABLE ,
    $(TR
        $(TH Modules)
        $(TH Description)
    )
    $(TR
        $(TDNW $(SUBMODULE l1))
        $(TD scalar and vector operations $(RED %90 done))
    )
    $(TR
        $(TDNW $(SUBMODULE l2))
        $(TD matrix-vector operations $(RED %3 done))
    )
    $(TR
        $(TDNW $(SUBMODULE l3))
        $(TD matrix-matrix operations $(RED 40% done))
    )
)

GLAS is generalization of $(LINK2 http://www.netlib.org/blas/, BLAS) (Basic Linear Algebra Subprograms)
Because the BLAS are efficient, portable, and widely available, they are commonly used in the development of
high quality linear algebra or related software, such as
$(LINK2 http://www.netlib.org/lapack/, LAPACK),
$(LINK2 http://www.numpy.org/,  NumPy), or $(LINK2 http://julialang.org/, The Julia language).

Efficient Level 3 BLAS implementation requires
$(LINK2 https://en.wikipedia.org/wiki/CPU_cache, cache)-friendly matrix blocking.
In additional, $(LINK2 https://en.wikipedia.org/wiki/SIMD, SIMD) instructions should be used for all levels on modern architectures.

$(H2 Why GLAS)

GLAS is ...
<ul>
<li>fast to execute.</li>
<li>fast to compile.</li>
<li>fast to extend using $(MREF_ALTTEXT ndslices, mir, ndslice).</li>
<li>fast to add new instruction set targets.</li>
</ul>

$(H2 Optimization notes)

GLAS requires recent $(LINK2 https://github.com/ldc-developers/ldc, LDC) >= 1.1.0-beta2.

License: $(LINK2 http://boost.org/LICENSE_1_0.txt, Boost License 1.0).

Authors: Ilya Yaroshenko

Macros:
SUBMODULE = $(MREF_ALTTEXT $1, mir, glas, $1)
SUBREF = $(REF_ALTTEXT $(TT $2), $2, mir, glas, $1)$(NBSP)
+/
module mir.glas;

public import mir.glas.l1;
public import mir.glas.l2;
public import mir.glas.l3;
