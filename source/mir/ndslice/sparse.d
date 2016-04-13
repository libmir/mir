/++
$(H2 Sparse Tensors)

This is a submodule of $(LINK2 mir_ndslice.html, mir.ndslice).


License:   $(WEB www.boost.org/LICENSE_1_0.txt, Boost License 1.0).

Authors:   Ilya Yaroshenko

Source:    $(PHOBOSSRC std/_experimental/_ndslice/_sparse.d)

Macros:
SUBMODULE = $(LINK2 mir_ndslice_$1.html, mir.ndslice.$1)
SUBREF = $(LINK2 mir_ndslice_$1.html#.$2, $(TT $2))$(NBSP)
T2=$(TR $(TDNW $(LREF $1)) $(TD $+))
T4=$(TR $(TDNW $(LREF $1)) $(TD $2) $(TD $3) $(TD $4))

+/
module mir.ndslice.sparse;

import std.traits;
import std.meta;

import mir.ndslice.internal;

/++
Sparse tensors represented in Dictionary of Keys (DOK) format.

Params:
    N = dimension count
    lengths = list of dimension lengths
Returns:
    `N`-dimensional slice composed of indexes
See_also: $(LREF Sparse)
+/
Sparse!(Lengths.length, T) sparse(T, Lengths...)(Lengths lengths)
    if (allSatisfy!(isIndex, Lengths))
{
    return .sparse!(T, Lengths.length)([lengths]);
}

/// ditto
Sparse!(N, T) sparse(T, size_t N)(auto ref size_t[N] lengths)
{
    import mir.ndslice.slice: sliced;
    T[size_t] table;
    table[0] = 0;
    table.remove(0);
    assert(table !is null);
    with (typeof(return)) return SparseMap!T(table).sliced(lengths);
}

///
pure unittest
{
    auto slice = sparse!double(2, 3);
    slice[0][] = 1;
    slice[0, 1] = 2;
    --slice[0, 0];
    slice[1, 2] += 4;

    assert(slice == [[0, 2, 1], [0, 0, 4]]);

    import std.range.primitives: isRandomAccessRange;
    static assert(isRandomAccessRange!(Sparse!(2, double)));

	import mir.ndslice.slice: Slice, DeepElementType;
    static assert(is(Sparse!(2, double) : Slice!(2, Range), Range));
    static assert(is(DeepElementType!(Sparse!(2, double)) == double));
}

/++
Sparse Slice in Dictionary of Keys Format.
+/
template Sparse(size_t N, T)
	if(N)
{
	import mir.ndslice.slice: Slice;
	alias Sparse = Slice!(N, SparseMap!T);
}

// undocumented
struct SparseMap(T)
{
	T[size_t] table;

	auto save()
	{
		return this;
	}

	T opIndex(size_t index)
	{
		static if (isScalarType!T)
			return table.get(index, cast(T)0);
		else
			return table.get(index, null);
	}

	T opIndexAssign(T value, size_t index)
	{
		static if (isScalarType!T)
		{
			if (value != 0)
			{
				table[index] = value;
			}
		}
		else
		{
			if (value !is null)
			{
				table[index] = value;
			}
		}
		return value;
	}

	T opIndexUnary(string op)(size_t index)
		if (op == `++` || op == `--`)
	{
		mixin (`auto value = ` ~ op ~ `table[index];`);
		static if (isScalarType!T)
		{
			if (value == 0)
			{
				table.remove(index);
			}
		}
		else
		{
			if (value is null)
			{
				table.remove(index);
			}
		}
		return value;
 	}

	T opIndexOpAssign(string op)(T value, size_t index)
		if (op == `+` || op == `-`)
	{
		mixin (`value = table[index] ` ~ op ~ `= value;`); // this works
		static if (isScalarType!T)
		{
			if (value == 0)
			{
				table.remove(index);
			}
		}
		else
		{
			if (value is null)
			{
				table.remove(index);
			}
		}
		return value;
    }
}

//.dup	Create a new associative array of the same size and copy the contents of the associative array into it.
//.keys	Returns dynamic array, the elements of which are the keys in the associative array.
//.values	Returns dynamic array, the elements of which are the values in the associative array.
//.rehash	Reorganizes the associative array in place so that lookups are more efficient. rehash is effective when, for example, the program is done loading up a symbol table and now needs fast lookups in it. Returns a reference to the reorganized array.
//.clear	Removes all remaining keys and values from an associative array. The array is not rehashed after removal, to allow for the existing storage to be reused. This will affect all references to the same instance and is not equivalent to destroy(aa) which only sets the current reference to null
//.byKey()	Returns a forward range suitable for use as a ForeachAggregate to a ForeachStatement which will iterate over the keys of the associative array.
//.byValue()	Returns a forward range suitable for use as a ForeachAggregate to a ForeachStatement which will iterate over the values of the associative array.
//.byKeyValue()	Returns a forward range suitable for use as a ForeachAggregate to a ForeachStatement which will iterate over key-value pairs of the associative array. The returned pairs are represented by an opaque type with .key and .value properties for accessing the key and value of the pair, respectively.
