	.section	__TEXT,__text,regular,pure_instructions
	.align	4, 0x90
__D3mir4blas4gemm16__moduleinfoCtorZ:
	movq	__Dmodule_ref@GOTPCREL(%rip), %rax
	movq	(%rax), %rcx
	movq	%rcx, __D3mir4blas4gemm11__moduleRefZ(%rip)
	leaq	__D3mir4blas4gemm11__moduleRefZ(%rip), %rcx
	movq	%rcx, (%rax)
	retq

	.section	__DATA,__data
	.globl	__D3mir4blas4gemm12__ModuleInfoZ
	.align	4
__D3mir4blas4gemm12__ModuleInfoZ:
	.long	2147484672
	.long	0
	.quad	1
	.quad	__D3mir4blas7context12__ModuleInfoZ
	.asciz	"mir.glas.gemm"
	.space	2

	.align	3
__D3mir4blas4gemm11__moduleRefZ:
	.quad	0
	.quad	__D3mir4blas4gemm12__ModuleInfoZ

	.section	__DATA,__mod_init_func,mod_init_funcs
	.align	3
	.quad	__D3mir4blas4gemm16__moduleinfoCtorZ

.subsections_via_symbols
