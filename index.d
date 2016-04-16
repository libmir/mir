/**
Numeric library and mirror for upcoming numeric packages for the Dlang standard library.

$(DL
	$(DT $(LINK2 http://dlang.org/phobos-prerelease/std_experimental_ndslice.html, ndslice package)
		$(DD Multidimensional Random Access Ranges and Arrays)
	)
	$(DT $(DPMODULE2 las, sum)
		$(DD Functions and Output Ranges for Summation Algorithms. Works with user-defined types.)
		$(DD Precise algorithm: improved analog of Python's `fsum`)
        $(DD Pairwise algorithm: fast version for Input Ranges)
        $(DD Kahan, KBN, and KB2 algorithms)
	)
	$(DT $(DPMODULE2 combinatorics, package)
		$(DD $(DPREF2 combinatorics, package, permutations))
		$(DD $(DPREF2 combinatorics, package, cartesianPower))
		$(DD $(DPREF2 combinatorics, package, combinations))
		$(DD $(DPREF2 combinatorics, package, combinationsRepeat))
	)
)

*/
module mir;
