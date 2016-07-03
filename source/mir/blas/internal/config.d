module mir.blas.internal.config;

version(LDC)
{
	static if (__VERSION__ >= 2071)
	{
		static import ldc.attributes;
		alias fastmath = ldc.attributes.fastmath;
	}
	else
	{
		struct FastMath{}
		FastMath fastmath() { return FastMath.init; };
	}
}
else
{
	struct FastMath{}
	FastMath fastmath() { return FastMath.init; };
}

