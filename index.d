/**
Numeric library and mirror for upcoming numeric packages for the Dlang standard library.

$(DL
	$(DT $(DPMODULE ndslice)
		$(DD Multidimensional Random Access Ranges and Arrays)
	)
	$(DT $(DPMODULE2 las, sum)
		$(DD Functions and Output Ranges for Summation Algorithms. Works with user-defined types.)
		$(DD Precise algorithm: improved analog of Python's `fsum`)
        $(DD Pairwise algorithm: fast version for Input Ranges)
        $(DD Kahan, KBN, and KB2 algorithms)
	)
	$(DT $(DPMODULE combinatorics)
		$(DD $(DPMODULE2 combinatorics, permutations))
		$(DD $(DPMODULE2 combinatorics, cartesianPower))
		$(DD $(DPMODULE2 combinatorics, combinations))
		$(DD $(DPMODULE2 combinatorics, combinationsRepeat))
	)
)

*/
module mir;
