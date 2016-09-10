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
    $(LEADINGROW Level 3)
    $(TR
        $(TDNW $(LINK2 mir_glas_l3.html, mir.glas.gemm))
        $(TD matrix-matrix operations)
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
<li>fast to extend using D multidimensional arrays.</li>
<li>fast to add new instruction set targets.</li>
</ul>

$(H2 Optimization notes)

GLAS requires recent $(LINK2 https://github.com/ldc-developers/ldc, LDC) >= 1.1.0-beta2.

License: $(LINK2 http://boost.org/LICENSE_1_0.txt, Boost License 1.0).

Authors: Ilya Yaroshenko
+/
module mir.glas;

public import mir.glas.l3;
