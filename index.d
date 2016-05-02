Ddoc

$(P Numerical library and mirror for upcoming numeric packages for the Dlang
standard library.)

$(P The following table is a quick reference guide for which mir modules to
use for a given category of functionality.)

$(BOOKTABLE ,
    $(TR
        $(TH Modules)
        $(TH Description)
    )
    $(LEADINGROW Models)
    $(TR
        $(TDNW $(LINK2 mir_blas.html, mir.model.lda.hoffman))
        $(TD Online variational Bayes for latent Dirichlet allocation (Online VB LDA) for sparse documents. LDA is used for topic modeling)
    )
    $(LEADINGROW Sparse)
    $(TR
        $(TDNW $(LINK2 mir_sparse.html, mir.sparse))
        $(TD Sparse Tensors)
    )
    $(TR
        $(TDNW $(LINK2 mir_sparse_blas.html, mir.sparse.blas))
        $(TD Sparse BLAS for CompressedTensor)
    )
    $(LEADINGROW Other)
    $(TR
        $(TDNW $(LINK2 mir_combinatorics.html, mir.combinatorics))
        $(TD Combinations, combinations with repeats, cartesian power, permutations)
    )
    $(TR
        $(TDNW $(LINK2 mir_sum.html, mir.sum))
        $(TD Functions and Output Ranges for Summation Algorithms)
    )
)

Macros:
        TITLE=Mir
        WIKI=Mir
        DDOC_BLANKLINE=
        _=
