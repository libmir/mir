module mir.glas.context;

import core.thread;
import cpuid.unified;
import std.range.primitives;
import std.experimental.allocator.mallocator;
import std.algorithm.comparison: min, max;

private __gshared BlasContext defaultContext;

/++
Thread pool and cache memory context.
+/
final class BlasContext
{
	enum maxThreads = 32;
	private size_t threads = 1;
	private size_t s1;
	private size_t s2;
	private void*[maxThreads] l1;
	private void* l2;
	private Cache c1;
	private Cache c2;
	private Tlb tlb;

	/++

	+/
	this(size_t threads = cpuid.unified.cores) nothrow @nogc @trusted
	in{
		assert(threads, "Threads count for BLAS context can not be null.");
		assert(threads <= cpuid.unified.cores, "Threads count for BLAS context can not be greater then amount of CPU cores despite of hyper-threading technology.");
		assert(threads <= maxThreads, "Threads count for BLAS context is limited by maxThreads.");
	}
	body
	{
		threads = 1; // for now

		this.threads = threads;


		auto dc = dCache;
		auto uc = uCache;
		
		while(!uc.empty && uc.back.size > 1 << 16) // > 64 MB is CPU memory
		{
			uc.popFront;
		}

		if(dc.length)
		{
			c1 = dc.front;
			dc.popFront;
		}
		else
		if(uc.length)
		{
			c1 = uc.front;
			uc.popFront;
		}

		if(uc.length)
		{
			c2 = uc.front;
		}
		else
		if(dc.length)
		{
			c2 = dc.front;
		}

		if(uTlb.length)
		{
			tlb = uTlb.front;
		}
		else
		if(dTlb.length)
		{
			tlb = dTlb.front;
		}

		if(c2.size == 0)
		{
			c2.size = 1024;
			c2.associative = 6;
			c2.line = 64;
		}

		if(c1.size == 0)
		{
			c1 = c2;
		}

		s1 = c1.size << 10;
		s2 = c2.size << 10;

		uint alignSize = tlb.page.max(4u).min(32u) << 10;

		l2 = AlignedMallocator.instance.alignedAllocate(s2 + s1 * threads, alignSize).ptr;
		
		foreach(ref l1e; l1[0..threads])
		{
			l1e = l2;
			l2 += s1;
		}
	}

	~this()
	{
		AlignedMallocator.instance.deallocate(l1[0][0 .. s2 + s1 * threads]);
	}

private:

	size_t[2] gemmParams(size_t[2])
	{
		size_t[2] ret = void;
		ret[0] = 256;
		ret[1] = 256;
		return ret;
	}
}

unittest
{
	auto la = new BlasContext;
}
