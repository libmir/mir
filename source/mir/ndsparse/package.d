/++
$(H1 Sparse Tensors)

The package provides a compressed multidimensional sparse array implementation.
In addition, it includes various functions for iteration, accessing, and converting.
$(LINK2 mir_ndslice_sparse.html, mir.ndslice.sparse) is publicly imported and can be
used to construct multidimensional tensor.

$(SCRIPT inhibitQuickIndex = 1;)

$(DIVC quickindex,
$(BOOKTABLE ,
$(TR $(TH Category) $(TH Submodule) $(TH Declarations)
)
$(TR $(TDNW Dlang Compressed Sparse Tensors $(BR)
     $(SMALL Generalization of Compressed Sparse Row (CSR) matrix format))
     $(TDNW $(SUBMODULE sparse))
     $(TD
        $(SUBREF sparse, sparse)
    )
)
))

License:   $(WEB www.boost.org/LICENSE_1_0.txt, Boost License 1.0).

Authors:   Ilya Yaroshenko

Macros:
SUBMODULE = $(LINK2 mir_ndsparse_$1.html, mir.ndsparse.$1)
SUBREF = $(LINK2 mir_ndsparse_$1.html#.$2, $(TT $2))$(NBSP)
T2=$(TR $(TDNW $(LREF $1)) $(TD $+))
T4=$(TR $(TDNW $(LREF $1)) $(TD $2) $(TD $3) $(TD $4))
+/
module mir.ndsparse;
