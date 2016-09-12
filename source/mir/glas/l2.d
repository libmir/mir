/++
$(H2 Level 2)

$(SCRIPT inhibitQuickIndex = 1;)

$(RED NOT IMPLEMENTED)

This is a submodule of $(LINK2 mir_glas.html, mir.glas).

The Level 2 BLAS perform matrix-vector operations.

Note: GLAS is singe thread for now.

$(BOOKTABLE $(H2 Matrix-matrix operations),

$(TR $(TH Function Name) $(TH Description))
)

License: $(LINK2 http://boost.org/LICENSE_1_0.txt, Boost License 1.0).

Authors: Ilya Yaroshenko

Macros:
T2=$(TR $(TDNW $(LREF $1)) $(TD $+))
SUBMODULE = $(MREF_ALTTEXT $1, mir, glas, $1)
SUBREF = $(REF_ALTTEXT $(TT $2), $2, mir, glas, $1)$(NBSP)
+/
module mir.glas.l2;

import std.traits;
import std.meta;
import std.complex : Complex, conj;
import std.typecons: Flag, Yes, No;

import mir.internal.math;
import mir.internal.utility;
import mir.ndslice.internal : fastmath;
import mir.ndslice.slice;
import mir.ndslice.algorithm : ndReduce;

import mir.glas.l1;
