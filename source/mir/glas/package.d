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
        $(TDNW $(LINK2 mir_glas_gemm.html, mir.glas.gemm))
        $(TD matrix-matrix multiplication)
    )
)

GLAS is generalization of $(LINK2 http://www.netlib.org/blas/, BLAS) (Basic Linear Algebra Subprograms)
Because the BLAS are efficient, portable, and widely available, they are commonly used in the development of
high quality linear algebra or related software, such as
$(LINK2 http://www.netlib.org/lapack/, LAPACK),
$(LINK2 http://www.numpy.org/,  NumPy), or $(LINK2 http://julialang.org/, The Julia language).

Efficient Level 3 BLAS implementation requires
$(LINK2 https://en.wikipedia.org/wiki/CPU_cache, cache)-friendly
and $(LINK2 https://en.wikipedia.org/wiki/Translation_lookaside_buffer, TLB)-friendly matrix blocking.
In additional, $(LINK2 https://en.wikipedia.org/wiki/SIMD, SIMD) instructions should be used for all levels on modern architectures.

$(H2 Why GLAS)

GLAS is ...
<ul>
<li>fast to execute.</li>
<li>fast to compile.</li>
<li>fast to extend using D multidimensional arrays.</li>
<li>fast to add new instruction set targets: e.g. AVX512 configuration was added in 5 minutes.</li>
</ul>

$(H2 GLAS Goals)

GLAS is aimed as be the fastest generic BLAS implementation ever. It can replace
$(LINK2 http://eigen.tuxfamily.org/, Eigen) (C++ template library for linear algebra),
$(LINK2 https://github.com/flame/blis, BLIS) (BLAS-like Library Instantiation Software Framework), and
$(LINK2 https://github.com/xianyi/OpenBLAS, OpenBlas).

Please fill $(LINK2 https://github.com/libmir/mir/issues, an issue)
if Eigen or BLIS is faster then GLAS, or if OpenBLAS is more than 12% faster then GLAS.

$(H2 Adding new target)

//If you find that GLAS is slower than $()

$(H2 GLAS-specific API changes)

$(H2 Optimization notes)

All Level 1 functions can be easily simulated with `ndslice` and Phobos.

GLAS uses `@fastmath` attribute if a compiler supports it.
`@fastmath` is available only for LDC for now and located in `ldc.attributes`.
User do not need to declare `@fastmath` attribute because GLAS functions already have it.
For other compilers functions may be slower.
In the same time Level 3 routines use generic SIMD kernels and cache/TLB optimization for all compilers.

$(H2 Implementation notes)

License: $(LINK2 http://boost.org/LICENSE_1_0.txt, Boost License 1.0).

Authors: Ilya Yaroshenko
+/
module mir.glas;

public import mir.glas.gemm;
