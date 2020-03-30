Ddoc

$(P The following table is a quick reference guide for which mir (backports) modules to
use for a given category of functionality.)

$(BOOKTABLE ,
    $(TR
        $(TH Modules)
        $(TH Description)
    )
    $(LEADINGROW Tensors)
    $(TR
        $(TDNW $(LINK2 mir_sparse.html, mir.sparse))
        $(TD Sparse Tensors)
    )
    $(LEADINGROW Models)
    $(TR
        $(TDNW $(LINK2 mir_model_lda_hoffman.html, mir.model.lda.hoffman))
        $(TD Online variational Bayes for latent Dirichlet allocation (Online VB LDA) for sparse documents. LDA is used for topic modeling)
    )
    $(LEADINGROW Linear Algebra)
    $(TR
        $(TDNW $(LINK2 mir_glas.html, mir.glas))
        $(TD Generic Linear Algebra Subroutines (BLAS implementation))
    )
    $(TR
        $(TDNW $(LINK2 mir_sparse_blas.html, mir.sparse.blas))
        $(TD Sparse BLAS for CompressedTensor)
    )
)

Macros:
        TITLE=Mir (backports)
        WIKI=Mir (backports)
        DDOC_BLANKLINE=
        _=
