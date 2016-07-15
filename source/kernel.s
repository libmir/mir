	.section	__TEXT,__text,regular,pure_instructions
	.section	__TEXT,__textcoal_nt,coalesced,pure_instructions
	.globl	__D3mir4blas8internal6kernel98__T9gebp_opt1VE3mir4blas8internal12micro_kernel7MulTypei0Vmi4TG1G2NhG4dTG1G1NhG4dTG1G1NhG2dTG1G1dZ24__T9gebp_opt1TdTdTPdTPdZ9gebp_opt1FNaNbNiddPxdPdPdS3mir7ndslice5slice17__T5SliceVmi2TPdZ5SliceS3mir7ndslice5slice17__T5SliceVmi2TPdZ5SliceZv
	.weak_definition	__D3mir4blas8internal6kernel98__T9gebp_opt1VE3mir4blas8internal12micro_kernel7MulTypei0Vmi4TG1G2NhG4dTG1G1NhG4dTG1G1NhG2dTG1G1dZ24__T9gebp_opt1TdTdTPdTPdZ9gebp_opt1FNaNbNiddPxdPdPdS3mir7ndslice5slice17__T5SliceVmi2TPdZ5SliceS3mir7ndslice5slice17__T5SliceVmi2TPdZ5SliceZv
	.align	4, 0x90
__D3mir4blas8internal6kernel98__T9gebp_opt1VE3mir4blas8internal12micro_kernel7MulTypei0Vmi4TG1G2NhG4dTG1G1NhG4dTG1G1NhG2dTG1G1dZ24__T9gebp_opt1TdTdTPdTPdZ9gebp_opt1FNaNbNiddPxdPdPdS3mir7ndslice5slice17__T5SliceVmi2TPdZ5SliceS3mir7ndslice5slice17__T5SliceVmi2TPdZ5SliceZv:
	.cfi_startproc
	pushq	%rbp
Ltmp0:
	.cfi_def_cfa_offset 16
	pushq	%r15
Ltmp1:
	.cfi_def_cfa_offset 24
	pushq	%r14
Ltmp2:
	.cfi_def_cfa_offset 32
	pushq	%r13
Ltmp3:
	.cfi_def_cfa_offset 40
	pushq	%r12
Ltmp4:
	.cfi_def_cfa_offset 48
	pushq	%rbx
Ltmp5:
	.cfi_def_cfa_offset 56
	subq	$408, %rsp
Ltmp6:
	.cfi_def_cfa_offset 464
Ltmp7:
	.cfi_offset %rbx, -56
Ltmp8:
	.cfi_offset %r12, -48
Ltmp9:
	.cfi_offset %r13, -40
Ltmp10:
	.cfi_offset %r14, -32
Ltmp11:
	.cfi_offset %r15, -24
Ltmp12:
	.cfi_offset %rbp, -16
	movq	%rsi, %r12
	movq	%r12, 72(%rsp)
	movq	%rdi, 56(%rsp)
	movq	504(%rsp), %rbx
	cmpq	464(%rsp), %rbx
	jne	LBB0_72
	movq	%rdx, 64(%rsp)
	vmovsd	%xmm1, 80(%rsp)
	leaq	504(%rsp), %rcx
	cmpq	$8, %rbx
	jb	LBB0_2
	.align	4, 0x90
LBB0_8:
	cmpq	$7, %rbx
	jbe	LBB0_73
	movq	8(%rcx), %r13
	movq	%rcx, %r14
	movq	16(%r14), %rbp
	movq	24(%r14), %rax
	movq	32(%r14), %r15
	movq	%r13, 368(%rsp)
	movq	$8, 376(%rsp)
	movq	%rax, 384(%rsp)
	movq	%rbp, 392(%rsp)
	movq	%r15, 400(%rsp)
	movq	400(%rsp), %rax
	movq	%rax, 32(%rsp)
	vmovups	368(%rsp), %ymm0
	vmovups	%ymm0, (%rsp)
	movq	%r12, %rdi
	vzeroupper
	callq	__D3mir4blas8internal4copy29__T18pack_panel_genericTdTPdZ18pack_panel_genericFNaNbNiS3mir7ndslice5slice17__T5SliceVmi2TPdZ5SlicePdZv
	addq	$-8, %rbx
	movq	%rbx, (%r14)
	shlq	$6, %rbp
	addq	%r15, %rbp
	movq	%rbp, 32(%r14)
	leaq	464(%rsp), %rax
	movq	8(%rax), %rbp
	cmpq	$4, %rbp
	jb	LBB0_10
	leaq	-4(%rbp), %r15
	movq	%r15, 48(%rsp)
	shrq	$2, %r15
	leaq	(,%r15,4), %rax
	movq	%rax, 40(%rsp)
	shlq	$5, %r15
	movq	56(%rsp), %rbx
	movq	64(%rsp), %r14
	jmp	LBB0_15
	.align	4, 0x90
LBB0_16:
	addq	$256, %rbx
	leaq	504(%rsp), %rax
	movq	8(%rax), %r13
LBB0_15:
	movq	%r13, %rdi
	movq	%r14, %rsi
	movq	%r12, %rdx
	movq	%rbx, %rcx
	vmovsd	80(%rsp), %xmm0
	callq	__D3mir4blas8internal12micro_kernel87__T17gemm_micro_kernelVE3mir4blas8internal12micro_kernel7MulTypei0Vmi1Vmi2Vmi4TNhG4dTdZ17gemm_micro_kernelFNaNbNiG1dKG4G1G2NhG4dMPxG1G2NhG4dMPxG1G4dmZv
	addq	$-4, %rbp
	cmpq	$4, %rbp
	jae	LBB0_16
	movq	48(%rsp), %rcx
	subq	40(%rsp), %rcx
	movq	56(%rsp), %rax
	leaq	256(%rax,%r15,8), %r13
	movq	%rcx, %rbp
	jmp	LBB0_12
	.align	4, 0x90
LBB0_10:
	movq	56(%rsp), %r13
	movq	64(%rsp), %r14
LBB0_12:
	cmpq	$2, %rbp
	jb	LBB0_13
	leaq	-2(%rbp), %r15
	movq	%r15, %rcx
	shrq	%rcx
	leaq	(%rcx,%rcx), %rax
	subq	%rax, %r15
	shlq	$4, %rcx
	movq	%rcx, 64(%rsp)
	movq	%r13, %rbx
	movq	%r14, %r12
	leaq	504(%rsp), %r14
	.align	4, 0x90
LBB0_23:
	movq	8(%r14), %rdi
	movq	%r12, %rsi
	movq	72(%rsp), %rdx
	movq	%rbx, %rcx
	vmovsd	80(%rsp), %xmm0
	callq	__D3mir4blas8internal12micro_kernel87__T17gemm_micro_kernelVE3mir4blas8internal12micro_kernel7MulTypei0Vmi1Vmi2Vmi2TNhG4dTdZ17gemm_micro_kernelFNaNbNiG1dKG2G1G2NhG4dMPxG1G2NhG4dMPxG1G2dmZv
	subq	$-128, %rbx
	addq	$-2, %rbp
	cmpq	$1, %rbp
	ja	LBB0_23
	movq	64(%rsp), %rax
	leaq	128(%r13,%rax,8), %r13
	movq	%r12, %r14
	movq	72(%rsp), %r12
	jmp	LBB0_18
	.align	4, 0x90
LBB0_13:
	movq	%rbp, %r15
LBB0_18:
	testq	%r15, %r15
	leaq	504(%rsp), %rbx
	je	LBB0_20
	.align	4, 0x90
LBB0_19:
	movq	8(%rbx), %rdi
	movq	%r14, %rsi
	movq	%r12, %rdx
	movq	%r13, %rcx
	vmovsd	80(%rsp), %xmm0
	callq	__D3mir4blas8internal12micro_kernel87__T17gemm_micro_kernelVE3mir4blas8internal12micro_kernel7MulTypei0Vmi1Vmi2Vmi1TNhG4dTdZ17gemm_micro_kernelFNaNbNiG1dKG1G1G2NhG4dMPxG1G2NhG4dMPxG1G1dmZv
	addq	$64, %r13
	addq	$-1, %r15
	jne	LBB0_19
LBB0_20:
	movq	%r14, 64(%rsp)
	movq	%rbx, %r14
	leaq	464(%rsp), %rax
	movq	%rax, %rbp
	movq	(%rbp), %r13
	cmpq	$7, %r13
	jbe	LBB0_73
	movq	8(%rbp), %rax
	movq	16(%rbp), %rbx
	movq	24(%rbp), %rcx
	movq	32(%rbp), %r15
	movq	%rax, 328(%rsp)
	movq	$8, 336(%rsp)
	movq	%rcx, 344(%rsp)
	movq	%rbx, 352(%rsp)
	movq	%r15, 360(%rsp)
	movq	360(%rsp), %rax
	movq	%rax, 32(%rsp)
	vmovups	328(%rsp), %ymm0
	vmovups	%ymm0, (%rsp)
	movq	56(%rsp), %rdi
	vzeroupper
	callq	__D3mir4blas8internal4copy29__T18save_block_genericTdTPdZ18save_block_genericFNaNbNiPdS3mir7ndslice5slice17__T5SliceVmi2TPdZ5SliceZv
	addq	$-8, %r13
	movq	%r13, (%rbp)
	shlq	$6, %rbx
	addq	%r15, %rbx
	movq	%rbx, 32(%rbp)
	movq	%r14, %rcx
	movq	(%rcx), %rbx
	cmpq	$7, %rbx
	ja	LBB0_8
LBB0_2:
	cmpq	$4, %rbx
	jb	LBB0_3
	.align	4, 0x90
LBB0_24:
	cmpq	$3, %rbx
	jbe	LBB0_73
	movq	8(%rcx), %r13
	movq	%rcx, %r14
	movq	16(%r14), %rbp
	movq	24(%r14), %rax
	movq	32(%r14), %r15
	movq	%r13, 288(%rsp)
	movq	$4, 296(%rsp)
	movq	%rax, 304(%rsp)
	movq	%rbp, 312(%rsp)
	movq	%r15, 320(%rsp)
	movq	320(%rsp), %rax
	movq	%rax, 32(%rsp)
	vmovups	288(%rsp), %ymm0
	vmovups	%ymm0, (%rsp)
	movq	%r12, %rdi
	vzeroupper
	callq	__D3mir4blas8internal4copy29__T18pack_panel_genericTdTPdZ18pack_panel_genericFNaNbNiS3mir7ndslice5slice17__T5SliceVmi2TPdZ5SlicePdZv
	addq	$-4, %rbx
	movq	%rbx, (%r14)
	shlq	$5, %rbp
	addq	%r15, %rbp
	movq	%rbp, 32(%r14)
	leaq	464(%rsp), %rax
	movq	8(%rax), %rbp
	cmpq	$4, %rbp
	jb	LBB0_26
	leaq	-4(%rbp), %r15
	movq	%r15, 48(%rsp)
	shrq	$2, %r15
	leaq	(,%r15,4), %rax
	movq	%rax, 40(%rsp)
	shlq	$4, %r15
	movq	56(%rsp), %rbx
	movq	64(%rsp), %r14
	jmp	LBB0_31
	.align	4, 0x90
LBB0_32:
	subq	$-128, %rbx
	leaq	504(%rsp), %rax
	movq	8(%rax), %r13
LBB0_31:
	movq	%r13, %rdi
	movq	%r14, %rsi
	movq	%r12, %rdx
	movq	%rbx, %rcx
	vmovsd	80(%rsp), %xmm0
	callq	__D3mir4blas8internal12micro_kernel87__T17gemm_micro_kernelVE3mir4blas8internal12micro_kernel7MulTypei0Vmi1Vmi1Vmi4TNhG4dTdZ17gemm_micro_kernelFNaNbNiG1dKG4G1G1NhG4dMPxG1G1NhG4dMPxG1G4dmZv
	addq	$-4, %rbp
	cmpq	$4, %rbp
	jae	LBB0_32
	movq	48(%rsp), %rcx
	subq	40(%rsp), %rcx
	movq	56(%rsp), %rax
	leaq	128(%rax,%r15,8), %r13
	movq	%rcx, %rbp
	jmp	LBB0_28
	.align	4, 0x90
LBB0_26:
	movq	56(%rsp), %r13
	movq	64(%rsp), %r14
LBB0_28:
	cmpq	$2, %rbp
	jb	LBB0_29
	leaq	-2(%rbp), %r15
	movq	%r15, %rcx
	shrq	%rcx
	leaq	(%rcx,%rcx), %rax
	subq	%rax, %r15
	shlq	$3, %rcx
	movq	%rcx, 64(%rsp)
	movq	%r13, %rbx
	movq	%r14, %r12
	leaq	504(%rsp), %r14
	.align	4, 0x90
LBB0_39:
	movq	8(%r14), %rdi
	movq	%r12, %rsi
	movq	72(%rsp), %rdx
	movq	%rbx, %rcx
	vmovsd	80(%rsp), %xmm0
	callq	__D3mir4blas8internal12micro_kernel87__T17gemm_micro_kernelVE3mir4blas8internal12micro_kernel7MulTypei0Vmi1Vmi1Vmi2TNhG4dTdZ17gemm_micro_kernelFNaNbNiG1dKG2G1G1NhG4dMPxG1G1NhG4dMPxG1G2dmZv
	addq	$64, %rbx
	addq	$-2, %rbp
	cmpq	$1, %rbp
	ja	LBB0_39
	movq	64(%rsp), %rax
	leaq	64(%r13,%rax,8), %r13
	movq	%r12, %r14
	movq	72(%rsp), %r12
	jmp	LBB0_34
	.align	4, 0x90
LBB0_29:
	movq	%rbp, %r15
LBB0_34:
	testq	%r15, %r15
	leaq	504(%rsp), %rbx
	je	LBB0_36
	.align	4, 0x90
LBB0_35:
	movq	8(%rbx), %rdi
	movq	%r14, %rsi
	movq	%r12, %rdx
	movq	%r13, %rcx
	vmovsd	80(%rsp), %xmm0
	callq	__D3mir4blas8internal12micro_kernel87__T17gemm_micro_kernelVE3mir4blas8internal12micro_kernel7MulTypei0Vmi1Vmi1Vmi1TNhG4dTdZ17gemm_micro_kernelFNaNbNiG1dKG1G1G1NhG4dMPxG1G1NhG4dMPxG1G1dmZv
	addq	$32, %r13
	addq	$-1, %r15
	jne	LBB0_35
LBB0_36:
	movq	%r14, 64(%rsp)
	movq	%rbx, %r14
	leaq	464(%rsp), %rax
	movq	%rax, %rbp
	movq	(%rbp), %r13
	cmpq	$3, %r13
	jbe	LBB0_73
	movq	8(%rbp), %rax
	movq	16(%rbp), %rbx
	movq	24(%rbp), %rcx
	movq	32(%rbp), %r15
	movq	%rax, 248(%rsp)
	movq	$4, 256(%rsp)
	movq	%rcx, 264(%rsp)
	movq	%rbx, 272(%rsp)
	movq	%r15, 280(%rsp)
	movq	280(%rsp), %rax
	movq	%rax, 32(%rsp)
	vmovups	248(%rsp), %ymm0
	vmovups	%ymm0, (%rsp)
	movq	56(%rsp), %rdi
	vzeroupper
	callq	__D3mir4blas8internal4copy29__T18save_block_genericTdTPdZ18save_block_genericFNaNbNiPdS3mir7ndslice5slice17__T5SliceVmi2TPdZ5SliceZv
	addq	$-4, %r13
	movq	%r13, (%rbp)
	shlq	$5, %rbx
	addq	%r15, %rbx
	movq	%rbx, 32(%rbp)
	movq	%r14, %rcx
	movq	(%rcx), %rbx
	cmpq	$3, %rbx
	ja	LBB0_24
LBB0_3:
	cmpq	$2, %rbx
	jb	LBB0_4
	.align	4, 0x90
LBB0_40:
	cmpq	$1, %rbx
	jbe	LBB0_73
	movq	8(%rcx), %r13
	movq	%rcx, %r14
	movq	16(%r14), %rbp
	movq	24(%r14), %rax
	movq	32(%r14), %r15
	movq	%r13, 208(%rsp)
	movq	$2, 216(%rsp)
	movq	%rax, 224(%rsp)
	movq	%rbp, 232(%rsp)
	movq	%r15, 240(%rsp)
	movq	240(%rsp), %rax
	movq	%rax, 32(%rsp)
	vmovups	208(%rsp), %ymm0
	vmovups	%ymm0, (%rsp)
	movq	%r12, %rdi
	vzeroupper
	callq	__D3mir4blas8internal4copy29__T18pack_panel_genericTdTPdZ18pack_panel_genericFNaNbNiS3mir7ndslice5slice17__T5SliceVmi2TPdZ5SlicePdZv
	addq	$-2, %rbx
	movq	%rbx, (%r14)
	shlq	$4, %rbp
	addq	%r15, %rbp
	movq	%rbp, 32(%r14)
	leaq	464(%rsp), %rax
	movq	8(%rax), %rbp
	cmpq	$4, %rbp
	jb	LBB0_42
	leaq	-4(%rbp), %r15
	movq	%r15, 48(%rsp)
	shrq	$2, %r15
	leaq	(,%r15,4), %rax
	movq	%rax, 40(%rsp)
	shlq	$3, %r15
	movq	56(%rsp), %rbx
	movq	64(%rsp), %r14
	jmp	LBB0_47
	.align	4, 0x90
LBB0_48:
	addq	$64, %rbx
	leaq	504(%rsp), %rax
	movq	8(%rax), %r13
LBB0_47:
	movq	%r13, %rdi
	movq	%r14, %rsi
	movq	%r12, %rdx
	movq	%rbx, %rcx
	vmovsd	80(%rsp), %xmm0
	callq	__D3mir4blas8internal12micro_kernel87__T17gemm_micro_kernelVE3mir4blas8internal12micro_kernel7MulTypei0Vmi1Vmi1Vmi4TNhG2dTdZ17gemm_micro_kernelFNaNbNiG1dKG4G1G1NhG2dMPxG1G1NhG2dMPxG1G4dmZv
	addq	$-4, %rbp
	cmpq	$4, %rbp
	jae	LBB0_48
	movq	48(%rsp), %rcx
	subq	40(%rsp), %rcx
	movq	56(%rsp), %rax
	leaq	64(%rax,%r15,8), %r13
	movq	%rcx, %rbp
	jmp	LBB0_44
	.align	4, 0x90
LBB0_42:
	movq	56(%rsp), %r13
	movq	64(%rsp), %r14
LBB0_44:
	cmpq	$2, %rbp
	jb	LBB0_45
	leaq	-2(%rbp), %r15
	movq	%r15, %rcx
	shrq	%rcx
	leaq	(%rcx,%rcx), %rax
	subq	%rax, %r15
	shlq	$2, %rcx
	movq	%rcx, 64(%rsp)
	movq	%r13, %rbx
	movq	%r14, %r12
	leaq	504(%rsp), %r14
	.align	4, 0x90
LBB0_55:
	movq	8(%r14), %rdi
	movq	%r12, %rsi
	movq	72(%rsp), %rdx
	movq	%rbx, %rcx
	vmovsd	80(%rsp), %xmm0
	callq	__D3mir4blas8internal12micro_kernel87__T17gemm_micro_kernelVE3mir4blas8internal12micro_kernel7MulTypei0Vmi1Vmi1Vmi2TNhG2dTdZ17gemm_micro_kernelFNaNbNiG1dKG2G1G1NhG2dMPxG1G1NhG2dMPxG1G2dmZv
	addq	$32, %rbx
	addq	$-2, %rbp
	cmpq	$1, %rbp
	ja	LBB0_55
	movq	64(%rsp), %rax
	leaq	32(%r13,%rax,8), %r13
	movq	%r12, %r14
	movq	72(%rsp), %r12
	jmp	LBB0_50
	.align	4, 0x90
LBB0_45:
	movq	%rbp, %r15
LBB0_50:
	testq	%r15, %r15
	leaq	504(%rsp), %rbx
	je	LBB0_52
	.align	4, 0x90
LBB0_51:
	movq	8(%rbx), %rdi
	movq	%r14, %rsi
	movq	%r12, %rdx
	movq	%r13, %rcx
	vmovsd	80(%rsp), %xmm0
	callq	__D3mir4blas8internal12micro_kernel87__T17gemm_micro_kernelVE3mir4blas8internal12micro_kernel7MulTypei0Vmi1Vmi1Vmi1TNhG2dTdZ17gemm_micro_kernelFNaNbNiG1dKG1G1G1NhG2dMPxG1G1NhG2dMPxG1G1dmZv
	addq	$16, %r13
	addq	$-1, %r15
	jne	LBB0_51
LBB0_52:
	movq	%r14, 64(%rsp)
	movq	%rbx, %r14
	leaq	464(%rsp), %rax
	movq	%rax, %rbp
	movq	(%rbp), %r13
	cmpq	$1, %r13
	jbe	LBB0_73
	movq	8(%rbp), %rax
	movq	16(%rbp), %rbx
	movq	24(%rbp), %rcx
	movq	32(%rbp), %r15
	movq	%rax, 168(%rsp)
	movq	$2, 176(%rsp)
	movq	%rcx, 184(%rsp)
	movq	%rbx, 192(%rsp)
	movq	%r15, 200(%rsp)
	movq	200(%rsp), %rax
	movq	%rax, 32(%rsp)
	vmovups	168(%rsp), %ymm0
	vmovups	%ymm0, (%rsp)
	movq	56(%rsp), %rdi
	vzeroupper
	callq	__D3mir4blas8internal4copy29__T18save_block_genericTdTPdZ18save_block_genericFNaNbNiPdS3mir7ndslice5slice17__T5SliceVmi2TPdZ5SliceZv
	addq	$-2, %r13
	movq	%r13, (%rbp)
	shlq	$4, %rbx
	addq	%r15, %rbx
	movq	%rbx, 32(%rbp)
	movq	%r14, %rcx
	movq	(%rcx), %rbx
	cmpq	$1, %rbx
	ja	LBB0_40
LBB0_4:
	testq	%rbx, %rbx
	je	LBB0_69
	movl	$1, %ebx
	.align	4, 0x90
LBB0_6:
	movq	8(%rcx), %r13
	movq	16(%rcx), %r15
	movq	24(%rcx), %rax
	movq	%rcx, %rbp
	movq	32(%rbp), %r14
	movq	%r13, 128(%rsp)
	movq	$1, 136(%rsp)
	movq	%rax, 144(%rsp)
	movq	%r15, 152(%rsp)
	movq	%r14, 160(%rsp)
	movq	160(%rsp), %rax
	movq	%rax, 32(%rsp)
	vmovups	128(%rsp), %ymm0
	vmovups	%ymm0, (%rsp)
	movq	%r12, %rdi
	vzeroupper
	callq	__D3mir4blas8internal4copy29__T18pack_panel_genericTdTPdZ18pack_panel_genericFNaNbNiS3mir7ndslice5slice17__T5SliceVmi2TPdZ5SlicePdZv
	testq	%rbx, %rbx
	je	LBB0_7
	addq	$-1, %rbx
	movq	%rbx, (%rbp)
	leaq	(%r14,%r15,8), %rax
	movq	%rax, 32(%rbp)
	leaq	464(%rsp), %rax
	movq	8(%rax), %r15
	cmpq	$4, %r15
	vmovsd	80(%rsp), %xmm0
	movq	%rbp, %rbx
	jb	LBB0_57
	movq	%rbx, %r14
	movq	%r15, %rbp
	addq	$-4, %rbp
	movq	%rbp, %rax
	andq	$-4, %rax
	movq	%rax, 48(%rsp)
	movq	%rbp, %r15
	subq	%rax, %r15
	movq	56(%rsp), %rbx
	jmp	LBB0_62
	.align	4, 0x90
LBB0_63:
	addq	$32, %rbx
	movq	8(%r14), %r13
	addq	$-4, %rbp
	vmovsd	80(%rsp), %xmm0
LBB0_62:
	movq	%r13, %rdi
	movq	64(%rsp), %rsi
	movq	%r12, %rdx
	movq	%rbx, %rcx
	callq	__D3mir4blas8internal12micro_kernel83__T17gemm_micro_kernelVE3mir4blas8internal12micro_kernel7MulTypei0Vmi1Vmi1Vmi4TdTdZ17gemm_micro_kernelFNaNbNiG1dKG4G1G1dMPxG1G1dMPxG1G4dmZv
	cmpq	$4, %rbp
	jae	LBB0_63
	movq	56(%rsp), %rax
	movq	48(%rsp), %rcx
	leaq	32(%rax,%rcx,8), %r13
	movq	%r14, %rbx
	jmp	LBB0_59
	.align	4, 0x90
LBB0_57:
	movq	56(%rsp), %r13
LBB0_59:
	cmpq	$2, %r15
	jb	LBB0_60
	leaq	-2(%r15), %rax
	movq	%rax, 48(%rsp)
	movq	%rbx, %rbp
	andq	$-2, %rax
	movq	%rax, 40(%rsp)
	movq	%r13, %rbx
	movq	64(%rsp), %r14
	.align	4, 0x90
LBB0_71:
	movq	8(%rbp), %rdi
	movq	%r14, %rsi
	movq	%r12, %rdx
	movq	%rbx, %rcx
	vmovsd	80(%rsp), %xmm0
	callq	__D3mir4blas8internal12micro_kernel83__T17gemm_micro_kernelVE3mir4blas8internal12micro_kernel7MulTypei0Vmi1Vmi1Vmi2TdTdZ17gemm_micro_kernelFNaNbNiG1dKG2G1G1dMPxG1G1dMPxG1G2dmZv
	addq	$16, %rbx
	addq	$-2, %r15
	cmpq	$1, %r15
	ja	LBB0_71
	movq	48(%rsp), %r15
	movq	40(%rsp), %rcx
	subq	%rcx, %r15
	leaq	16(%r13,%rcx,8), %r13
	movq	%rbp, %rbx
	jmp	LBB0_65
	.align	4, 0x90
LBB0_60:
	movq	64(%rsp), %r14
LBB0_65:
	testq	%r15, %r15
	je	LBB0_67
	.align	4, 0x90
LBB0_66:
	movq	8(%rbx), %rdi
	movq	%r14, %rsi
	movq	%r12, %rdx
	movq	%r13, %rcx
	vmovsd	80(%rsp), %xmm0
	callq	__D3mir4blas8internal12micro_kernel83__T17gemm_micro_kernelVE3mir4blas8internal12micro_kernel7MulTypei0Vmi1Vmi1Vmi1TdTdZ17gemm_micro_kernelFNaNbNiG1dKG1G1G1dMPxG1G1dMPxG1G1dmZv
	addq	$8, %r13
	addq	$-1, %r15
	jne	LBB0_66
LBB0_67:
	movq	%r14, 64(%rsp)
	movq	%rbx, %r13
	leaq	464(%rsp), %rbp
	movq	(%rbp), %rbx
	testq	%rbx, %rbx
	je	LBB0_73
	movq	8(%rbp), %rax
	movq	16(%rbp), %r15
	movq	24(%rbp), %rcx
	movq	32(%rbp), %r14
	movq	%rax, 88(%rsp)
	movq	$1, 96(%rsp)
	movq	%rcx, 104(%rsp)
	movq	%r15, 112(%rsp)
	movq	%r14, 120(%rsp)
	movq	120(%rsp), %rax
	movq	%rax, 32(%rsp)
	vmovups	88(%rsp), %ymm0
	vmovups	%ymm0, (%rsp)
	movq	56(%rsp), %rdi
	vzeroupper
	callq	__D3mir4blas8internal4copy29__T18save_block_genericTdTPdZ18save_block_genericFNaNbNiPdS3mir7ndslice5slice17__T5SliceVmi2TPdZ5SliceZv
	addq	$-1, %rbx
	movq	%rbx, (%rbp)
	leaq	(%r14,%r15,8), %rax
	movq	%rax, 32(%rbp)
	movq	%r13, %rcx
	movq	(%rcx), %rbx
	testq	%rbx, %rbx
	jne	LBB0_6
LBB0_69:
	addq	$408, %rsp
	popq	%rbx
	popq	%r12
	popq	%r13
	popq	%r14
	popq	%r15
	popq	%rbp
	retq
LBB0_73:
	leaq	L_.str30(%rip), %rsi
	leaq	L_.str6(%rip), %rcx
	movl	$132, %edi
	movl	$19, %edx
	movl	$1697, %r8d
	callq	__d_assert_msg
LBB0_7:
	leaq	L_.str35(%rip), %rsi
	leaq	L_.str6(%rip), %rcx
	movl	$124, %edi
	movl	$19, %edx
	movl	$1494, %r8d
	callq	__d_assert_msg
LBB0_72:
	leaq	L_.str(%rip), %rsi
	movl	$26, %edi
	movl	$69, %edx
	callq	__d_assert
	.cfi_endproc

	.globl	__D3mir7ndslice5slice17__T5SliceVmi2TPdZ5Slice15__T6lengthVii0Z6lengthMxFNaNbNdNiNfZm
	.weak_definition	__D3mir7ndslice5slice17__T5SliceVmi2TPdZ5Slice15__T6lengthVii0Z6lengthMxFNaNbNdNiNfZm
	.align	4, 0x90
__D3mir7ndslice5slice17__T5SliceVmi2TPdZ5Slice15__T6lengthVii0Z6lengthMxFNaNbNdNiNfZm:
	.cfi_startproc
	movq	(%rdi), %rax
	retq
	.cfi_endproc

	.globl	__D3mir4blas8internal6kernel19__T11statComplexTdZ11statComplexFNaNbNiNfdZG1d
	.weak_definition	__D3mir4blas8internal6kernel19__T11statComplexTdZ11statComplexFNaNbNiNfdZG1d
	.align	4, 0x90
__D3mir4blas8internal6kernel19__T11statComplexTdZ11statComplexFNaNbNiNfdZG1d:
	.cfi_startproc
	retq
	.cfi_endproc

	.globl	__D3mir4blas8internal4copy29__T18pack_panel_genericTdTPdZ18pack_panel_genericFNaNbNiS3mir7ndslice5slice17__T5SliceVmi2TPdZ5SlicePdZv
	.weak_definition	__D3mir4blas8internal4copy29__T18pack_panel_genericTdTPdZ18pack_panel_genericFNaNbNiS3mir7ndslice5slice17__T5SliceVmi2TPdZ5SlicePdZv
	.align	4, 0x90
__D3mir4blas8internal4copy29__T18pack_panel_genericTdTPdZ18pack_panel_genericFNaNbNiS3mir7ndslice5slice17__T5SliceVmi2TPdZ5SlicePdZv:
	.cfi_startproc
	pushq	%rax
Ltmp13:
	.cfi_def_cfa_offset 16
	movq	16(%rsp), %r10
	testq	%r10, %r10
	je	LBB3_10
	movq	24(%rsp), %rcx
	testq	%rcx, %rcx
	je	LBB3_3
	leaq	16(%rsp), %r8
	movq	32(%rsp), %r9
	movq	40(%rsp), %rdx
	movq	32(%r8), %r11
	shlq	$3, %r9
	shlq	$3, %rdx
	.align	4, 0x90
LBB3_14:
	movq	%r11, %rsi
	xorl	%eax, %eax
	.align	4, 0x90
LBB3_11:
	cmpq	%rax, %rcx
	je	LBB3_15
	vmovsd	(%rsi), %xmm0
	vmovsd	%xmm0, (%rdi,%rax,8)
	addq	$1, %rax
	addq	%rdx, %rsi
	cmpq	%rcx, %rax
	jb	LBB3_11
	movq	(%r8), %rax
	leaq	(%rdi,%rax,8), %rdi
	addq	%r9, %r11
	addq	$-1, %r10
	jne	LBB3_14
	jmp	LBB3_10
LBB3_3:
	testq	%r10, %r10
	je	LBB3_9
	movq	%r10, %rdx
	andq	$-128, %rdx
	xorl	%esi, %esi
	movq	%r10, %rax
	movq	%r10, %rcx
	andq	$-128, %rax
	je	LBB3_8
	movq	%r10, %rcx
	subq	%rdx, %rcx
	movq	%rax, %rdx
	.align	4, 0x90
LBB3_6:
	addq	$-128, %rdx
	jne	LBB3_6
	movq	%rax, %rsi
LBB3_8:
	cmpq	%rsi, %r10
	movq	%rcx, %r10
	je	LBB3_10
	.align	4, 0x90
LBB3_9:
	addq	$-1, %r10
	jne	LBB3_9
LBB3_10:
	popq	%rax
	retq
LBB3_15:
	leaq	L_.str6(%rip), %rsi
	movl	$19, %edi
	movl	$1386, %edx
	callq	__d_assert
	.cfi_endproc

	.globl	__D3mir7ndslice9iteration19__T10transposedTPdZ10transposedFNaNbNiS3mir7ndslice5slice17__T5SliceVmi2TPdZ5SliceZS3mir7ndslice5slice17__T5SliceVmi2TPdZ5Slice
	.weak_definition	__D3mir7ndslice9iteration19__T10transposedTPdZ10transposedFNaNbNiS3mir7ndslice5slice17__T5SliceVmi2TPdZ5SliceZS3mir7ndslice5slice17__T5SliceVmi2TPdZ5Slice
	.align	4, 0x90
__D3mir7ndslice9iteration19__T10transposedTPdZ10transposedFNaNbNiS3mir7ndslice5slice17__T5SliceVmi2TPdZ5SliceZS3mir7ndslice5slice17__T5SliceVmi2TPdZ5Slice:
	.cfi_startproc
	movq	8(%rsp), %r8
	movq	16(%rsp), %rcx
	movq	32(%rsp), %rdx
	movq	24(%rsp), %rsi
	movq	40(%rsp), %rax
	movq	%rcx, (%rdi)
	movq	%r8, 8(%rdi)
	movq	%rdx, 16(%rdi)
	movq	%rsi, 24(%rdi)
	movq	%rax, 32(%rdi)
	movq	%rdi, %rax
	retq
	.cfi_endproc

	.globl	__D3mir7ndslice5slice17__T5SliceVmi2TPdZ5Slice42__T7opIndexTS3mir7ndslice8internal6_SliceZ7opIndexMFNaNbNiS3mir7ndslice8internal6_SliceZS3mir7ndslice5slice17__T5SliceVmi2TPdZ5Slice
	.weak_definition	__D3mir7ndslice5slice17__T5SliceVmi2TPdZ5Slice42__T7opIndexTS3mir7ndslice8internal6_SliceZ7opIndexMFNaNbNiS3mir7ndslice8internal6_SliceZS3mir7ndslice5slice17__T5SliceVmi2TPdZ5Slice
	.align	4, 0x90
__D3mir7ndslice5slice17__T5SliceVmi2TPdZ5Slice42__T7opIndexTS3mir7ndslice8internal6_SliceZ7opIndexMFNaNbNiS3mir7ndslice8internal6_SliceZS3mir7ndslice5slice17__T5SliceVmi2TPdZ5Slice:
	.cfi_startproc
	vmovdqu	8(%rsi), %xmm0
	vpextrq	$1, %xmm0, %rax
	imulq	%rdx, %rax
	subq	%rdx, %rcx
	movq	%rcx, (%rdi)
	vmovdqu	%xmm0, 8(%rdi)
	movq	24(%rsi), %rcx
	movq	%rcx, 24(%rdi)
	shlq	$3, %rax
	addq	32(%rsi), %rax
	movq	%rax, 32(%rdi)
	movq	%rdi, %rax
	retq
	.cfi_endproc

	.globl	__D3mir7ndslice5slice17__T5SliceVmi2TPdZ5Slice16__T7opSliceVmi0Z7opSliceMFNaNbNiNfmmZS3mir7ndslice8internal6_Slice
	.weak_definition	__D3mir7ndslice5slice17__T5SliceVmi2TPdZ5Slice16__T7opSliceVmi0Z7opSliceMFNaNbNiNfmmZS3mir7ndslice8internal6_Slice
	.align	4, 0x90
__D3mir7ndslice5slice17__T5SliceVmi2TPdZ5Slice16__T7opSliceVmi0Z7opSliceMFNaNbNiNfmmZS3mir7ndslice8internal6_Slice:
	.cfi_startproc
	pushq	%rax
Ltmp14:
	.cfi_def_cfa_offset 16
	movq	%rsi, %rax
	subq	%rdx, %rax
	jb	LBB6_3
	cmpq	(%rdi), %rax
	ja	LBB6_4
	movq	%rdx, %rax
	movq	%rsi, %rdx
	popq	%rcx
	retq
LBB6_3:
	leaq	L_.str29(%rip), %rsi
	leaq	L_.str6(%rip), %rcx
	movl	$80, %edi
	movl	$19, %edx
	movl	$1693, %r8d
	callq	__d_assert_msg
LBB6_4:
	leaq	L_.str30(%rip), %rsi
	leaq	L_.str6(%rip), %rcx
	movl	$132, %edi
	movl	$19, %edx
	movl	$1697, %r8d
	callq	__d_assert_msg
	.cfi_endproc

	.globl	__D3mir7ndslice5slice17__T5SliceVmi2TPdZ5Slice25__T15popFrontExactlyVii0Z15popFrontExactlyMFNaNbNimZv
	.weak_definition	__D3mir7ndslice5slice17__T5SliceVmi2TPdZ5Slice25__T15popFrontExactlyVii0Z15popFrontExactlyMFNaNbNimZv
	.align	4, 0x90
__D3mir7ndslice5slice17__T5SliceVmi2TPdZ5Slice25__T15popFrontExactlyVii0Z15popFrontExactlyMFNaNbNimZv:
	.cfi_startproc
	pushq	%rax
Ltmp15:
	.cfi_def_cfa_offset 16
	movq	(%rdi), %rax
	subq	%rsi, %rax
	jb	LBB7_2
	movq	%rax, (%rdi)
	imulq	16(%rdi), %rsi
	shlq	$3, %rsi
	addq	%rsi, 32(%rdi)
	popq	%rax
	retq
LBB7_2:
	leaq	L_.str35(%rip), %rsi
	leaq	L_.str6(%rip), %rcx
	movl	$124, %edi
	movl	$19, %edx
	movl	$1494, %r8d
	callq	__d_assert_msg
	.cfi_endproc

	.globl	__D3mir7ndslice5slice17__T5SliceVmi2TPdZ5Slice15__T6lengthVmi1Z6lengthMxFNaNbNdNiNfZm
	.weak_definition	__D3mir7ndslice5slice17__T5SliceVmi2TPdZ5Slice15__T6lengthVmi1Z6lengthMxFNaNbNdNiNfZm
	.align	4, 0x90
__D3mir7ndslice5slice17__T5SliceVmi2TPdZ5Slice15__T6lengthVmi1Z6lengthMxFNaNbNdNiNfZm:
	.cfi_startproc
	movq	8(%rdi), %rax
	retq
	.cfi_endproc

	.globl	__D3mir4blas8internal12micro_kernel87__T17gemm_micro_kernelVE3mir4blas8internal12micro_kernel7MulTypei0Vmi1Vmi2Vmi4TNhG4dTdZ17gemm_micro_kernelFNaNbNiG1dKG4G1G2NhG4dMPxG1G2NhG4dMPxG1G4dmZv
	.weak_definition	__D3mir4blas8internal12micro_kernel87__T17gemm_micro_kernelVE3mir4blas8internal12micro_kernel7MulTypei0Vmi1Vmi2Vmi4TNhG4dTdZ17gemm_micro_kernelFNaNbNiG1dKG4G1G2NhG4dMPxG1G2NhG4dMPxG1G4dmZv
	.align	4, 0x90
__D3mir4blas8internal12micro_kernel87__T17gemm_micro_kernelVE3mir4blas8internal12micro_kernel7MulTypei0Vmi1Vmi2Vmi4TNhG4dTdZ17gemm_micro_kernelFNaNbNiG1dKG4G1G2NhG4dMPxG1G2NhG4dMPxG1G4dmZv:
	.cfi_startproc
	vxorpd	%ymm1, %ymm1, %ymm1
	vxorpd	%ymm2, %ymm2, %ymm2
	vxorpd	%ymm3, %ymm3, %ymm3
	vxorpd	%ymm4, %ymm4, %ymm4
	vxorpd	%ymm5, %ymm5, %ymm5
	vxorpd	%ymm6, %ymm6, %ymm6
	vxorpd	%ymm7, %ymm7, %ymm7
	vxorpd	%ymm8, %ymm8, %ymm8
	.align	4, 0x90
LBB9_1:
	vmovapd	(%rdx), %ymm9
	vmovapd	32(%rdx), %ymm10
	vbroadcastsd	(%rsi), %ymm11
	vbroadcastsd	8(%rsi), %ymm12
	vbroadcastsd	16(%rsi), %ymm13
	vbroadcastsd	24(%rsi), %ymm14
	vfmadd231pd	%ymm11, %ymm9, %ymm8
	vfmadd231pd	%ymm11, %ymm10, %ymm7
	vfmadd231pd	%ymm12, %ymm9, %ymm6
	vfmadd231pd	%ymm12, %ymm10, %ymm5
	vfmadd231pd	%ymm13, %ymm9, %ymm4
	vfmadd231pd	%ymm13, %ymm10, %ymm3
	vfmadd231pd	%ymm14, %ymm9, %ymm2
	vfmadd231pd	%ymm14, %ymm10, %ymm1
	addq	$64, %rdx
	addq	$32, %rsi
	addq	$-1, %rdi
	jne	LBB9_1
	vbroadcastsd	%xmm0, %ymm0
	vmulpd	%ymm8, %ymm0, %ymm8
	vmulpd	%ymm7, %ymm0, %ymm7
	vmulpd	%ymm6, %ymm0, %ymm6
	vmulpd	%ymm5, %ymm0, %ymm5
	vmulpd	%ymm4, %ymm0, %ymm4
	vmulpd	%ymm3, %ymm0, %ymm3
	vmulpd	%ymm2, %ymm0, %ymm2
	vmulpd	%ymm1, %ymm0, %ymm0
	vmovapd	%ymm8, (%rcx)
	vmovapd	%ymm7, 32(%rcx)
	vmovapd	%ymm6, 64(%rcx)
	vmovapd	%ymm5, 96(%rcx)
	vmovapd	%ymm4, 128(%rcx)
	vmovapd	%ymm3, 160(%rcx)
	vmovapd	%ymm2, 192(%rcx)
	vmovapd	%ymm0, 224(%rcx)
	vzeroupper
	retq
	.cfi_endproc

	.globl	__D3mir4blas8internal12micro_kernel87__T17gemm_micro_kernelVE3mir4blas8internal12micro_kernel7MulTypei0Vmi1Vmi2Vmi2TNhG4dTdZ17gemm_micro_kernelFNaNbNiG1dKG2G1G2NhG4dMPxG1G2NhG4dMPxG1G2dmZv
	.weak_definition	__D3mir4blas8internal12micro_kernel87__T17gemm_micro_kernelVE3mir4blas8internal12micro_kernel7MulTypei0Vmi1Vmi2Vmi2TNhG4dTdZ17gemm_micro_kernelFNaNbNiG1dKG2G1G2NhG4dMPxG1G2NhG4dMPxG1G2dmZv
	.align	4, 0x90
__D3mir4blas8internal12micro_kernel87__T17gemm_micro_kernelVE3mir4blas8internal12micro_kernel7MulTypei0Vmi1Vmi2Vmi2TNhG4dTdZ17gemm_micro_kernelFNaNbNiG1dKG2G1G2NhG4dMPxG1G2NhG4dMPxG1G2dmZv:
	.cfi_startproc
	vxorpd	%ymm1, %ymm1, %ymm1
	vxorpd	%ymm2, %ymm2, %ymm2
	vxorpd	%ymm3, %ymm3, %ymm3
	vxorpd	%ymm4, %ymm4, %ymm4
	.align	4, 0x90
LBB10_1:
	vmovapd	(%rdx), %ymm5
	vmovapd	32(%rdx), %ymm6
	vbroadcastsd	(%rsi), %ymm7
	vbroadcastsd	8(%rsi), %ymm8
	vfmadd231pd	%ymm7, %ymm5, %ymm4
	vfmadd231pd	%ymm7, %ymm6, %ymm3
	vfmadd231pd	%ymm8, %ymm5, %ymm2
	vfmadd231pd	%ymm8, %ymm6, %ymm1
	addq	$64, %rdx
	addq	$16, %rsi
	addq	$-1, %rdi
	jne	LBB10_1
	vbroadcastsd	%xmm0, %ymm0
	vmulpd	%ymm4, %ymm0, %ymm4
	vmulpd	%ymm3, %ymm0, %ymm3
	vmulpd	%ymm2, %ymm0, %ymm2
	vmulpd	%ymm1, %ymm0, %ymm0
	vmovapd	%ymm4, (%rcx)
	vmovapd	%ymm3, 32(%rcx)
	vmovapd	%ymm2, 64(%rcx)
	vmovapd	%ymm0, 96(%rcx)
	vzeroupper
	retq
	.cfi_endproc

	.globl	__D3mir4blas8internal12micro_kernel87__T17gemm_micro_kernelVE3mir4blas8internal12micro_kernel7MulTypei0Vmi1Vmi2Vmi1TNhG4dTdZ17gemm_micro_kernelFNaNbNiG1dKG1G1G2NhG4dMPxG1G2NhG4dMPxG1G1dmZv
	.weak_definition	__D3mir4blas8internal12micro_kernel87__T17gemm_micro_kernelVE3mir4blas8internal12micro_kernel7MulTypei0Vmi1Vmi2Vmi1TNhG4dTdZ17gemm_micro_kernelFNaNbNiG1dKG1G1G2NhG4dMPxG1G2NhG4dMPxG1G1dmZv
	.align	4, 0x90
__D3mir4blas8internal12micro_kernel87__T17gemm_micro_kernelVE3mir4blas8internal12micro_kernel7MulTypei0Vmi1Vmi2Vmi1TNhG4dTdZ17gemm_micro_kernelFNaNbNiG1dKG1G1G2NhG4dMPxG1G2NhG4dMPxG1G1dmZv:
	.cfi_startproc
	vxorpd	%ymm1, %ymm1, %ymm1
	vxorpd	%ymm2, %ymm2, %ymm2
	.align	4, 0x90
LBB11_1:
	vbroadcastsd	(%rsi), %ymm3
	vfmadd231pd	(%rdx), %ymm3, %ymm2
	vfmadd231pd	32(%rdx), %ymm3, %ymm1
	addq	$8, %rsi
	addq	$64, %rdx
	addq	$-1, %rdi
	jne	LBB11_1
	vbroadcastsd	%xmm0, %ymm0
	vmulpd	%ymm2, %ymm0, %ymm2
	vmulpd	%ymm1, %ymm0, %ymm0
	vmovapd	%ymm2, (%rcx)
	vmovapd	%ymm0, 32(%rcx)
	vzeroupper
	retq
	.cfi_endproc

	.globl	__D3mir4blas8internal4copy29__T18save_block_genericTdTPdZ18save_block_genericFNaNbNiPdS3mir7ndslice5slice17__T5SliceVmi2TPdZ5SliceZv
	.weak_definition	__D3mir4blas8internal4copy29__T18save_block_genericTdTPdZ18save_block_genericFNaNbNiPdS3mir7ndslice5slice17__T5SliceVmi2TPdZ5SliceZv
	.align	4, 0x90
__D3mir4blas8internal4copy29__T18save_block_genericTdTPdZ18save_block_genericFNaNbNiPdS3mir7ndslice5slice17__T5SliceVmi2TPdZ5SliceZv:
	.cfi_startproc
	pushq	%rax
Ltmp16:
	.cfi_def_cfa_offset 16
	movq	16(%rsp), %r10
	testq	%r10, %r10
	je	LBB12_10
	movq	24(%rsp), %rcx
	testq	%rcx, %rcx
	je	LBB12_3
	leaq	16(%rsp), %r8
	movq	32(%rsp), %r9
	movq	40(%rsp), %rdx
	movq	32(%r8), %r11
	shlq	$3, %r9
	shlq	$3, %rdx
	.align	4, 0x90
LBB12_14:
	movq	%r11, %rsi
	xorl	%eax, %eax
	.align	4, 0x90
LBB12_11:
	cmpq	%rax, %rcx
	je	LBB12_15
	vmovsd	(%rdi,%rax,8), %xmm0
	vmovsd	%xmm0, (%rsi)
	addq	$1, %rax
	addq	%rdx, %rsi
	cmpq	%rcx, %rax
	jb	LBB12_11
	movq	8(%r8), %rax
	leaq	(%rdi,%rax,8), %rdi
	addq	%r9, %r11
	addq	$-1, %r10
	jne	LBB12_14
	jmp	LBB12_10
LBB12_3:
	testq	%r10, %r10
	je	LBB12_9
	movq	%r10, %rdx
	andq	$-128, %rdx
	xorl	%esi, %esi
	movq	%r10, %rax
	movq	%r10, %rcx
	andq	$-128, %rax
	je	LBB12_8
	movq	%r10, %rcx
	subq	%rdx, %rcx
	movq	%rax, %rdx
	.align	4, 0x90
LBB12_6:
	addq	$-128, %rdx
	jne	LBB12_6
	movq	%rax, %rsi
LBB12_8:
	cmpq	%rsi, %r10
	movq	%rcx, %r10
	je	LBB12_10
	.align	4, 0x90
LBB12_9:
	addq	$-1, %r10
	jne	LBB12_9
LBB12_10:
	popq	%rax
	retq
LBB12_15:
	leaq	L_.str6(%rip), %rsi
	movl	$19, %edi
	movl	$1386, %edx
	callq	__d_assert
	.cfi_endproc

	.globl	__D3mir4blas8internal12micro_kernel87__T17gemm_micro_kernelVE3mir4blas8internal12micro_kernel7MulTypei0Vmi1Vmi1Vmi4TNhG4dTdZ17gemm_micro_kernelFNaNbNiG1dKG4G1G1NhG4dMPxG1G1NhG4dMPxG1G4dmZv
	.weak_definition	__D3mir4blas8internal12micro_kernel87__T17gemm_micro_kernelVE3mir4blas8internal12micro_kernel7MulTypei0Vmi1Vmi1Vmi4TNhG4dTdZ17gemm_micro_kernelFNaNbNiG1dKG4G1G1NhG4dMPxG1G1NhG4dMPxG1G4dmZv
	.align	4, 0x90
__D3mir4blas8internal12micro_kernel87__T17gemm_micro_kernelVE3mir4blas8internal12micro_kernel7MulTypei0Vmi1Vmi1Vmi4TNhG4dTdZ17gemm_micro_kernelFNaNbNiG1dKG4G1G1NhG4dMPxG1G1NhG4dMPxG1G4dmZv:
	.cfi_startproc
	vxorpd	%ymm1, %ymm1, %ymm1
	vxorpd	%ymm2, %ymm2, %ymm2
	vxorpd	%ymm3, %ymm3, %ymm3
	vxorpd	%ymm4, %ymm4, %ymm4
	.align	4, 0x90
LBB13_1:
	vmovapd	(%rdx), %ymm5
	vbroadcastsd	(%rsi), %ymm6
	vbroadcastsd	8(%rsi), %ymm7
	vbroadcastsd	16(%rsi), %ymm8
	vbroadcastsd	24(%rsi), %ymm9
	vfmadd231pd	%ymm6, %ymm5, %ymm4
	vfmadd231pd	%ymm7, %ymm5, %ymm3
	vfmadd231pd	%ymm8, %ymm5, %ymm2
	vfmadd231pd	%ymm9, %ymm5, %ymm1
	addq	$32, %rdx
	addq	$32, %rsi
	addq	$-1, %rdi
	jne	LBB13_1
	vbroadcastsd	%xmm0, %ymm0
	vmulpd	%ymm4, %ymm0, %ymm4
	vmulpd	%ymm3, %ymm0, %ymm3
	vmulpd	%ymm2, %ymm0, %ymm2
	vmulpd	%ymm1, %ymm0, %ymm0
	vmovapd	%ymm4, (%rcx)
	vmovapd	%ymm3, 32(%rcx)
	vmovapd	%ymm2, 64(%rcx)
	vmovapd	%ymm0, 96(%rcx)
	vzeroupper
	retq
	.cfi_endproc

	.globl	__D3mir4blas8internal12micro_kernel87__T17gemm_micro_kernelVE3mir4blas8internal12micro_kernel7MulTypei0Vmi1Vmi1Vmi2TNhG4dTdZ17gemm_micro_kernelFNaNbNiG1dKG2G1G1NhG4dMPxG1G1NhG4dMPxG1G2dmZv
	.weak_definition	__D3mir4blas8internal12micro_kernel87__T17gemm_micro_kernelVE3mir4blas8internal12micro_kernel7MulTypei0Vmi1Vmi1Vmi2TNhG4dTdZ17gemm_micro_kernelFNaNbNiG1dKG2G1G1NhG4dMPxG1G1NhG4dMPxG1G2dmZv
	.align	4, 0x90
__D3mir4blas8internal12micro_kernel87__T17gemm_micro_kernelVE3mir4blas8internal12micro_kernel7MulTypei0Vmi1Vmi1Vmi2TNhG4dTdZ17gemm_micro_kernelFNaNbNiG1dKG2G1G1NhG4dMPxG1G1NhG4dMPxG1G2dmZv:
	.cfi_startproc
	vxorpd	%ymm1, %ymm1, %ymm1
	vxorpd	%ymm2, %ymm2, %ymm2
	.align	4, 0x90
LBB14_1:
	vmovapd	(%rdx), %ymm3
	vbroadcastsd	(%rsi), %ymm4
	vbroadcastsd	8(%rsi), %ymm5
	vfmadd231pd	%ymm4, %ymm3, %ymm2
	vfmadd231pd	%ymm5, %ymm3, %ymm1
	addq	$32, %rdx
	addq	$16, %rsi
	addq	$-1, %rdi
	jne	LBB14_1
	vbroadcastsd	%xmm0, %ymm0
	vmulpd	%ymm2, %ymm0, %ymm2
	vmulpd	%ymm1, %ymm0, %ymm0
	vmovapd	%ymm2, (%rcx)
	vmovapd	%ymm0, 32(%rcx)
	vzeroupper
	retq
	.cfi_endproc

	.globl	__D3mir4blas8internal12micro_kernel87__T17gemm_micro_kernelVE3mir4blas8internal12micro_kernel7MulTypei0Vmi1Vmi1Vmi1TNhG4dTdZ17gemm_micro_kernelFNaNbNiG1dKG1G1G1NhG4dMPxG1G1NhG4dMPxG1G1dmZv
	.weak_definition	__D3mir4blas8internal12micro_kernel87__T17gemm_micro_kernelVE3mir4blas8internal12micro_kernel7MulTypei0Vmi1Vmi1Vmi1TNhG4dTdZ17gemm_micro_kernelFNaNbNiG1dKG1G1G1NhG4dMPxG1G1NhG4dMPxG1G1dmZv
	.align	4, 0x90
__D3mir4blas8internal12micro_kernel87__T17gemm_micro_kernelVE3mir4blas8internal12micro_kernel7MulTypei0Vmi1Vmi1Vmi1TNhG4dTdZ17gemm_micro_kernelFNaNbNiG1dKG1G1G1NhG4dMPxG1G1NhG4dMPxG1G1dmZv:
	.cfi_startproc
	vxorpd	%ymm1, %ymm1, %ymm1
	.align	4, 0x90
LBB15_1:
	vbroadcastsd	(%rsi), %ymm2
	vfmadd231pd	(%rdx), %ymm2, %ymm1
	addq	$32, %rdx
	addq	$8, %rsi
	addq	$-1, %rdi
	jne	LBB15_1
	vbroadcastsd	%xmm0, %ymm0
	vmulpd	%ymm1, %ymm0, %ymm0
	vmovapd	%ymm0, (%rcx)
	vzeroupper
	retq
	.cfi_endproc

	.globl	__D3mir4blas8internal12micro_kernel87__T17gemm_micro_kernelVE3mir4blas8internal12micro_kernel7MulTypei0Vmi1Vmi1Vmi4TNhG2dTdZ17gemm_micro_kernelFNaNbNiG1dKG4G1G1NhG2dMPxG1G1NhG2dMPxG1G4dmZv
	.weak_definition	__D3mir4blas8internal12micro_kernel87__T17gemm_micro_kernelVE3mir4blas8internal12micro_kernel7MulTypei0Vmi1Vmi1Vmi4TNhG2dTdZ17gemm_micro_kernelFNaNbNiG1dKG4G1G1NhG2dMPxG1G1NhG2dMPxG1G4dmZv
	.align	4, 0x90
__D3mir4blas8internal12micro_kernel87__T17gemm_micro_kernelVE3mir4blas8internal12micro_kernel7MulTypei0Vmi1Vmi1Vmi4TNhG2dTdZ17gemm_micro_kernelFNaNbNiG1dKG4G1G1NhG2dMPxG1G1NhG2dMPxG1G4dmZv:
	.cfi_startproc
	vxorpd	%xmm1, %xmm1, %xmm1
	vxorpd	%xmm2, %xmm2, %xmm2
	vxorpd	%xmm3, %xmm3, %xmm3
	vxorpd	%xmm4, %xmm4, %xmm4
	.align	4, 0x90
LBB16_1:
	vmovapd	(%rdx), %xmm5
	vmovddup	(%rsi), %xmm6
	vmovddup	8(%rsi), %xmm7
	vmovddup	16(%rsi), %xmm8
	vmovddup	24(%rsi), %xmm9
	vfmadd231pd	%xmm6, %xmm5, %xmm4
	vfmadd231pd	%xmm7, %xmm5, %xmm3
	vfmadd231pd	%xmm8, %xmm5, %xmm2
	vfmadd231pd	%xmm9, %xmm5, %xmm1
	addq	$16, %rdx
	addq	$32, %rsi
	addq	$-1, %rdi
	jne	LBB16_1
	vunpcklpd	%xmm0, %xmm0, %xmm0
	vmulpd	%xmm4, %xmm0, %xmm4
	vmulpd	%xmm3, %xmm0, %xmm3
	vmulpd	%xmm2, %xmm0, %xmm2
	vmulpd	%xmm1, %xmm0, %xmm0
	vmovapd	%xmm4, (%rcx)
	vmovapd	%xmm3, 16(%rcx)
	vmovapd	%xmm2, 32(%rcx)
	vmovapd	%xmm0, 48(%rcx)
	retq
	.cfi_endproc

	.globl	__D3mir4blas8internal12micro_kernel87__T17gemm_micro_kernelVE3mir4blas8internal12micro_kernel7MulTypei0Vmi1Vmi1Vmi2TNhG2dTdZ17gemm_micro_kernelFNaNbNiG1dKG2G1G1NhG2dMPxG1G1NhG2dMPxG1G2dmZv
	.weak_definition	__D3mir4blas8internal12micro_kernel87__T17gemm_micro_kernelVE3mir4blas8internal12micro_kernel7MulTypei0Vmi1Vmi1Vmi2TNhG2dTdZ17gemm_micro_kernelFNaNbNiG1dKG2G1G1NhG2dMPxG1G1NhG2dMPxG1G2dmZv
	.align	4, 0x90
__D3mir4blas8internal12micro_kernel87__T17gemm_micro_kernelVE3mir4blas8internal12micro_kernel7MulTypei0Vmi1Vmi1Vmi2TNhG2dTdZ17gemm_micro_kernelFNaNbNiG1dKG2G1G1NhG2dMPxG1G1NhG2dMPxG1G2dmZv:
	.cfi_startproc
	vxorpd	%xmm1, %xmm1, %xmm1
	vxorpd	%xmm2, %xmm2, %xmm2
	.align	4, 0x90
LBB17_1:
	vmovapd	(%rdx), %xmm3
	vmovddup	(%rsi), %xmm4
	vmovddup	8(%rsi), %xmm5
	vfmadd231pd	%xmm4, %xmm3, %xmm2
	vfmadd231pd	%xmm5, %xmm3, %xmm1
	addq	$16, %rdx
	addq	$16, %rsi
	addq	$-1, %rdi
	jne	LBB17_1
	vunpcklpd	%xmm0, %xmm0, %xmm0
	vmulpd	%xmm2, %xmm0, %xmm2
	vmulpd	%xmm1, %xmm0, %xmm0
	vmovapd	%xmm2, (%rcx)
	vmovapd	%xmm0, 16(%rcx)
	retq
	.cfi_endproc

	.globl	__D3mir4blas8internal12micro_kernel87__T17gemm_micro_kernelVE3mir4blas8internal12micro_kernel7MulTypei0Vmi1Vmi1Vmi1TNhG2dTdZ17gemm_micro_kernelFNaNbNiG1dKG1G1G1NhG2dMPxG1G1NhG2dMPxG1G1dmZv
	.weak_definition	__D3mir4blas8internal12micro_kernel87__T17gemm_micro_kernelVE3mir4blas8internal12micro_kernel7MulTypei0Vmi1Vmi1Vmi1TNhG2dTdZ17gemm_micro_kernelFNaNbNiG1dKG1G1G1NhG2dMPxG1G1NhG2dMPxG1G1dmZv
	.align	4, 0x90
__D3mir4blas8internal12micro_kernel87__T17gemm_micro_kernelVE3mir4blas8internal12micro_kernel7MulTypei0Vmi1Vmi1Vmi1TNhG2dTdZ17gemm_micro_kernelFNaNbNiG1dKG1G1G1NhG2dMPxG1G1NhG2dMPxG1G1dmZv:
	.cfi_startproc
	vxorpd	%xmm1, %xmm1, %xmm1
	.align	4, 0x90
LBB18_1:
	vmovddup	(%rsi), %xmm2
	vfmadd231pd	(%rdx), %xmm2, %xmm1
	addq	$16, %rdx
	addq	$8, %rsi
	addq	$-1, %rdi
	jne	LBB18_1
	vunpcklpd	%xmm0, %xmm0, %xmm0
	vmulpd	%xmm1, %xmm0, %xmm0
	vmovapd	%xmm0, (%rcx)
	retq
	.cfi_endproc

	.globl	__D3mir4blas8internal12micro_kernel83__T17gemm_micro_kernelVE3mir4blas8internal12micro_kernel7MulTypei0Vmi1Vmi1Vmi4TdTdZ17gemm_micro_kernelFNaNbNiG1dKG4G1G1dMPxG1G1dMPxG1G4dmZv
	.weak_definition	__D3mir4blas8internal12micro_kernel83__T17gemm_micro_kernelVE3mir4blas8internal12micro_kernel7MulTypei0Vmi1Vmi1Vmi4TdTdZ17gemm_micro_kernelFNaNbNiG1dKG4G1G1dMPxG1G1dMPxG1G4dmZv
	.align	4, 0x90
__D3mir4blas8internal12micro_kernel83__T17gemm_micro_kernelVE3mir4blas8internal12micro_kernel7MulTypei0Vmi1Vmi1Vmi4TdTdZ17gemm_micro_kernelFNaNbNiG1dKG4G1G1dMPxG1G1dMPxG1G4dmZv:
	.cfi_startproc
	vxorpd	%xmm1, %xmm1, %xmm1
	testq	%rdi, %rdi
	je	LBB19_1
	movq	%rdi, %r11
	andq	$-4, %r11
	movq	%rdi, %r8
	vxorpd	%ymm8, %ymm8, %ymm8
	movq	%rdi, %r9
	andq	$-4, %r8
	je	LBB19_3
	subq	%r11, %r9
	shlq	$5, %r11
	addq	%rsi, %r11
	leaq	(%rdx,%r8,8), %r10
	addq	$120, %rsi
	addq	$24, %rdx
	vxorpd	%ymm8, %ymm8, %ymm8
	movq	%r8, %rax
	vxorpd	%ymm2, %ymm2, %ymm2
	vxorpd	%ymm3, %ymm3, %ymm3
	vxorpd	%ymm4, %ymm4, %ymm4
	.align	4, 0x90
LBB19_5:
	vmovupd	-24(%rdx), %xmm5
	vmovsd	-8(%rdx), %xmm6
	vmovhpd	(%rdx), %xmm6, %xmm6
	vinsertf128	$1, %xmm6, %ymm5, %ymm5
	vmovsd	-56(%rsi), %xmm6
	vmovhpd	-24(%rsi), %xmm6, %xmm6
	vmovsd	-120(%rsi), %xmm7
	vmovsd	-112(%rsi), %xmm1
	vmovhpd	-88(%rsi), %xmm7, %xmm7
	vinsertf128	$1, %xmm6, %ymm7, %ymm9
	vmovsd	-48(%rsi), %xmm7
	vmovhpd	-16(%rsi), %xmm7, %xmm7
	vmovhpd	-80(%rsi), %xmm1, %xmm1
	vinsertf128	$1, %xmm7, %ymm1, %ymm10
	vmovsd	-40(%rsi), %xmm7
	vmovhpd	-8(%rsi), %xmm7, %xmm7
	vmovsd	-104(%rsi), %xmm6
	vmovhpd	-72(%rsi), %xmm6, %xmm6
	vinsertf128	$1, %xmm7, %ymm6, %ymm6
	vmovsd	-32(%rsi), %xmm7
	vmovhpd	(%rsi), %xmm7, %xmm7
	vmovsd	-96(%rsi), %xmm1
	vmovhpd	-64(%rsi), %xmm1, %xmm1
	vinsertf128	$1, %xmm7, %ymm1, %ymm1
	vfmadd231pd	%ymm5, %ymm9, %ymm4
	vfmadd231pd	%ymm5, %ymm10, %ymm3
	vfmadd231pd	%ymm5, %ymm6, %ymm2
	vfmadd231pd	%ymm5, %ymm1, %ymm8
	subq	$-128, %rsi
	addq	$32, %rdx
	addq	$-4, %rax
	jne	LBB19_5
	jmp	LBB19_6
LBB19_1:
	vxorpd	%xmm2, %xmm2, %xmm2
	jmp	LBB19_7
LBB19_3:
	movq	%rsi, %r11
	movq	%rdx, %r10
	movl	$0, %r8d
	vxorpd	%ymm2, %ymm2, %ymm2
	vxorpd	%ymm3, %ymm3, %ymm3
	vxorpd	%ymm4, %ymm4, %ymm4
LBB19_6:
	vextractf128	$1, %ymm4, %xmm1
	vaddpd	%ymm1, %ymm4, %ymm1
	vhaddpd	%ymm1, %ymm1, %ymm1
	vextractf128	$1, %ymm3, %xmm4
	vaddpd	%ymm4, %ymm3, %ymm3
	vhaddpd	%ymm3, %ymm3, %ymm3
	vextractf128	$1, %ymm2, %xmm4
	vaddpd	%ymm4, %ymm2, %ymm2
	vhaddpd	%ymm2, %ymm2, %ymm2
	vextractf128	$1, %ymm8, %xmm4
	vaddpd	%ymm4, %ymm8, %ymm4
	vhaddpd	%ymm4, %ymm4, %ymm4
	vunpcklpd	%xmm3, %xmm1, %xmm1
	vunpcklpd	%xmm4, %xmm2, %xmm2
	cmpq	%rdi, %r8
	movq	%r9, %rdi
	movq	%r11, %rsi
	movq	%r10, %rdx
	je	LBB19_8
	.align	4, 0x90
LBB19_7:
	vmovddup	(%rdx), %xmm3
	vfmadd231pd	(%rsi), %xmm3, %xmm1
	vfmadd231pd	16(%rsi), %xmm3, %xmm2
	addq	$8, %rdx
	addq	$32, %rsi
	addq	$-1, %rdi
	jne	LBB19_7
LBB19_8:
	vunpcklpd	%xmm0, %xmm0, %xmm0
	vmulpd	%xmm0, %xmm1, %xmm1
	vmulpd	%xmm0, %xmm2, %xmm0
	vmovupd	%xmm1, (%rcx)
	vmovupd	%xmm0, 16(%rcx)
	vzeroupper
	retq
	.cfi_endproc

	.globl	__D3mir4blas8internal12micro_kernel83__T17gemm_micro_kernelVE3mir4blas8internal12micro_kernel7MulTypei0Vmi1Vmi1Vmi2TdTdZ17gemm_micro_kernelFNaNbNiG1dKG2G1G1dMPxG1G1dMPxG1G2dmZv
	.weak_definition	__D3mir4blas8internal12micro_kernel83__T17gemm_micro_kernelVE3mir4blas8internal12micro_kernel7MulTypei0Vmi1Vmi1Vmi2TdTdZ17gemm_micro_kernelFNaNbNiG1dKG2G1G1dMPxG1G1dMPxG1G2dmZv
	.align	4, 0x90
__D3mir4blas8internal12micro_kernel83__T17gemm_micro_kernelVE3mir4blas8internal12micro_kernel7MulTypei0Vmi1Vmi1Vmi2TdTdZ17gemm_micro_kernelFNaNbNiG1dKG2G1G1dMPxG1G1dMPxG1G2dmZv:
	.cfi_startproc
	vxorpd	%xmm1, %xmm1, %xmm1
	testq	%rdi, %rdi
	je	LBB20_6
	movq	%rdi, %r11
	andq	$-8, %r11
	movq	%rdi, %r8
	vxorpd	%ymm9, %ymm9, %ymm9
	movq	%rdi, %r9
	andq	$-8, %r8
	je	LBB20_2
	subq	%r11, %r9
	shlq	$4, %r11
	addq	%rsi, %r11
	leaq	(%rdx,%r8,8), %r10
	addq	$120, %rsi
	addq	$56, %rdx
	vxorpd	%ymm9, %ymm9, %ymm9
	movq	%r8, %rax
	vxorpd	%ymm2, %ymm2, %ymm2
	vxorpd	%ymm3, %ymm3, %ymm3
	vxorpd	%ymm4, %ymm4, %ymm4
	.align	4, 0x90
LBB20_4:
	vmovupd	-56(%rdx), %ymm8
	vmovupd	-24(%rdx), %xmm6
	vmovsd	-8(%rdx), %xmm7
	vmovhpd	(%rdx), %xmm7, %xmm7
	vinsertf128	$1, %xmm7, %ymm6, %ymm6
	vmovsd	-88(%rsi), %xmm7
	vmovhpd	-72(%rsi), %xmm7, %xmm7
	vmovsd	-120(%rsi), %xmm5
	vmovsd	-112(%rsi), %xmm1
	vmovhpd	-104(%rsi), %xmm5, %xmm5
	vinsertf128	$1, %xmm7, %ymm5, %ymm10
	vmovsd	-24(%rsi), %xmm7
	vmovhpd	-8(%rsi), %xmm7, %xmm7
	vmovsd	-56(%rsi), %xmm5
	vmovhpd	-40(%rsi), %xmm5, %xmm5
	vinsertf128	$1, %xmm7, %ymm5, %ymm11
	vmovsd	-80(%rsi), %xmm7
	vmovhpd	-64(%rsi), %xmm7, %xmm7
	vmovhpd	-96(%rsi), %xmm1, %xmm1
	vinsertf128	$1, %xmm7, %ymm1, %ymm1
	vmovsd	-16(%rsi), %xmm7
	vmovhpd	(%rsi), %xmm7, %xmm7
	vmovsd	-48(%rsi), %xmm5
	vmovhpd	-32(%rsi), %xmm5, %xmm5
	vinsertf128	$1, %xmm7, %ymm5, %ymm5
	vfmadd231pd	%ymm8, %ymm10, %ymm3
	vfmadd231pd	%ymm6, %ymm11, %ymm4
	vfmadd231pd	%ymm8, %ymm1, %ymm9
	vfmadd231pd	%ymm6, %ymm5, %ymm2
	subq	$-128, %rsi
	addq	$64, %rdx
	addq	$-8, %rax
	jne	LBB20_4
	jmp	LBB20_5
LBB20_2:
	movq	%rsi, %r11
	movq	%rdx, %r10
	movl	$0, %r8d
	vxorpd	%ymm2, %ymm2, %ymm2
	vxorpd	%ymm3, %ymm3, %ymm3
	vxorpd	%ymm4, %ymm4, %ymm4
LBB20_5:
	vaddpd	%ymm3, %ymm4, %ymm1
	vextractf128	$1, %ymm1, %xmm3
	vaddpd	%ymm3, %ymm1, %ymm1
	vhaddpd	%ymm1, %ymm1, %ymm1
	vaddpd	%ymm9, %ymm2, %ymm2
	vextractf128	$1, %ymm2, %xmm3
	vaddpd	%ymm3, %ymm2, %ymm2
	vhaddpd	%ymm2, %ymm2, %ymm2
	vunpcklpd	%xmm2, %xmm1, %xmm1
	cmpq	%rdi, %r8
	movq	%r9, %rdi
	movq	%r11, %rsi
	movq	%r10, %rdx
	je	LBB20_7
	.align	4, 0x90
LBB20_6:
	vmovddup	(%rdx), %xmm2
	vfmadd231pd	(%rsi), %xmm2, %xmm1
	addq	$8, %rdx
	addq	$16, %rsi
	addq	$-1, %rdi
	jne	LBB20_6
LBB20_7:
	vunpcklpd	%xmm0, %xmm0, %xmm0
	vmulpd	%xmm0, %xmm1, %xmm0
	vmovupd	%xmm0, (%rcx)
	vzeroupper
	retq
	.cfi_endproc

	.globl	__D3mir4blas8internal12micro_kernel83__T17gemm_micro_kernelVE3mir4blas8internal12micro_kernel7MulTypei0Vmi1Vmi1Vmi1TdTdZ17gemm_micro_kernelFNaNbNiG1dKG1G1G1dMPxG1G1dMPxG1G1dmZv
	.weak_definition	__D3mir4blas8internal12micro_kernel83__T17gemm_micro_kernelVE3mir4blas8internal12micro_kernel7MulTypei0Vmi1Vmi1Vmi1TdTdZ17gemm_micro_kernelFNaNbNiG1dKG1G1G1dMPxG1G1dMPxG1G1dmZv
	.align	4, 0x90
__D3mir4blas8internal12micro_kernel83__T17gemm_micro_kernelVE3mir4blas8internal12micro_kernel7MulTypei0Vmi1Vmi1Vmi1TdTdZ17gemm_micro_kernelFNaNbNiG1dKG1G1G1dMPxG1G1dMPxG1G1dmZv:
	.cfi_startproc
	vxorpd	%xmm1, %xmm1, %xmm1
	testq	%rdi, %rdi
	je	LBB21_6
	movq	%rdi, %rax
	andq	$-8, %rax
	movq	%rdi, %r11
	vxorpd	%ymm1, %ymm1, %ymm1
	movq	%rdi, %r8
	andq	$-8, %r11
	je	LBB21_2
	subq	%rax, %r8
	leaq	(%rsi,%r11,8), %r9
	leaq	(%rdx,%r11,8), %r10
	addq	$56, %rsi
	addq	$56, %rdx
	vxorpd	%ymm1, %ymm1, %ymm1
	movq	%r11, %rax
	vxorpd	%ymm2, %ymm2, %ymm2
	.align	4, 0x90
LBB21_4:
	vmovupd	-56(%rdx), %ymm3
	vmovupd	-24(%rdx), %xmm4
	vmovsd	-8(%rdx), %xmm5
	vmovhpd	(%rdx), %xmm5, %xmm5
	vinsertf128	$1, %xmm5, %ymm4, %ymm4
	vmovupd	-24(%rsi), %xmm5
	vmovsd	-8(%rsi), %xmm6
	vmovhpd	(%rsi), %xmm6, %xmm6
	vinsertf128	$1, %xmm6, %ymm5, %ymm5
	vfmadd231pd	-56(%rsi), %ymm3, %ymm1
	vfmadd231pd	%ymm4, %ymm5, %ymm2
	addq	$64, %rsi
	addq	$64, %rdx
	addq	$-8, %rax
	jne	LBB21_4
	jmp	LBB21_5
LBB21_2:
	movq	%rsi, %r9
	movq	%rdx, %r10
	xorl	%r11d, %r11d
	vxorpd	%ymm2, %ymm2, %ymm2
LBB21_5:
	vaddpd	%ymm1, %ymm2, %ymm1
	vextractf128	$1, %ymm1, %xmm2
	vaddpd	%ymm2, %ymm1, %ymm1
	vhaddpd	%ymm1, %ymm1, %ymm1
	cmpq	%rdi, %r11
	movq	%r8, %rdi
	movq	%r9, %rsi
	movq	%r10, %rdx
	je	LBB21_7
	.align	4, 0x90
LBB21_6:
	vmovsd	(%rdx), %xmm2
	vfmadd231sd	(%rsi), %xmm2, %xmm1
	addq	$8, %rdx
	addq	$8, %rsi
	addq	$-1, %rdi
	jne	LBB21_6
LBB21_7:
	vmulsd	%xmm0, %xmm1, %xmm0
	vmovsd	%xmm0, (%rcx)
	vzeroupper
	retq
	.cfi_endproc

	.globl	__D3mir7ndslice5slice17__T5SliceVmi2TPdZ5Slice11indexStrideMxFNaNbNiNfG2mZm
	.weak_definition	__D3mir7ndslice5slice17__T5SliceVmi2TPdZ5Slice11indexStrideMxFNaNbNiNfG2mZm
	.align	4, 0x90
__D3mir7ndslice5slice17__T5SliceVmi2TPdZ5Slice11indexStrideMxFNaNbNiNfG2mZm:
	.cfi_startproc
	pushq	%rax
Ltmp17:
	.cfi_def_cfa_offset 16
	movq	16(%rsp), %rcx
	cmpq	(%rdi), %rcx
	jae	LBB22_3
	leaq	16(%rsp), %rax
	movq	8(%rax), %rax
	cmpq	8(%rdi), %rax
	jae	LBB22_2
	imulq	16(%rdi), %rcx
	imulq	24(%rdi), %rax
	addq	%rcx, %rax
	popq	%rdx
	retq
LBB22_3:
	leaq	L_.str1(%rip), %rsi
	leaq	L_.str2(%rip), %rcx
	movl	$86, %edi
	movl	$30, %edx
	movl	$1144, %r8d
	callq	__d_assert_msg
LBB22_2:
	leaq	L_.str3(%rip), %rsi
	leaq	L_.str2(%rip), %rcx
	movl	$86, %edi
	movl	$30, %edx
	movl	$1147, %r8d
	callq	__d_assert_msg
	.cfi_endproc

	.globl	__D3mir7ndslice5slice17__T5SliceVmi2TPdZ5Slice15mathIndexStrideMxFNaNbNiNfG2mZm
	.weak_definition	__D3mir7ndslice5slice17__T5SliceVmi2TPdZ5Slice15mathIndexStrideMxFNaNbNiNfG2mZm
	.align	4, 0x90
__D3mir7ndslice5slice17__T5SliceVmi2TPdZ5Slice15mathIndexStrideMxFNaNbNiNfG2mZm:
	.cfi_startproc
	pushq	%rax
Ltmp18:
	.cfi_def_cfa_offset 16
	movq	24(%rsp), %rcx
	cmpq	(%rdi), %rcx
	jae	LBB23_3
	leaq	16(%rsp), %rax
	movq	(%rax), %rax
	cmpq	8(%rdi), %rax
	jae	LBB23_2
	imulq	16(%rdi), %rcx
	imulq	24(%rdi), %rax
	addq	%rcx, %rax
	popq	%rdx
	retq
LBB23_3:
	leaq	L_.str3(%rip), %rsi
	leaq	L_.str4(%rip), %rcx
	movl	$86, %edi
	movl	$30, %edx
	movl	$1154, %r8d
	callq	__d_assert_msg
LBB23_2:
	leaq	L_.str1(%rip), %rsi
	leaq	L_.str4(%rip), %rcx
	movl	$86, %edi
	movl	$30, %edx
	movl	$1157, %r8d
	callq	__d_assert_msg
	.cfi_endproc

	.globl	__D3mir7ndslice5slice17__T5SliceVmi2TPdZ5Slice6__ctorMFNaNbNcNiNfKxG2mKxG2lPdZS3mir7ndslice5slice17__T5SliceVmi2TPdZ5Slice
	.weak_definition	__D3mir7ndslice5slice17__T5SliceVmi2TPdZ5Slice6__ctorMFNaNbNcNiNfKxG2mKxG2lPdZS3mir7ndslice5slice17__T5SliceVmi2TPdZ5Slice
	.align	4, 0x90
__D3mir7ndslice5slice17__T5SliceVmi2TPdZ5Slice6__ctorMFNaNbNcNiNfKxG2mKxG2lPdZS3mir7ndslice5slice17__T5SliceVmi2TPdZ5Slice:
	.cfi_startproc
	movq	(%rcx), %rax
	movq	%rax, (%rdi)
	movq	8(%rcx), %rax
	movq	%rax, 8(%rdi)
	movq	(%rdx), %rax
	movq	%rax, 16(%rdi)
	movq	8(%rdx), %rax
	movq	%rax, 24(%rdi)
	movq	%rsi, 32(%rdi)
	movq	%rdi, %rax
	retq
	.cfi_endproc

	.globl	__D3mir7ndslice5slice17__T5SliceVmi2TPdZ5Slice3ptrMFNaNbNiNfZPd
	.weak_definition	__D3mir7ndslice5slice17__T5SliceVmi2TPdZ5Slice3ptrMFNaNbNiNfZPd
	.align	4, 0x90
__D3mir7ndslice5slice17__T5SliceVmi2TPdZ5Slice3ptrMFNaNbNiNfZPd:
	.cfi_startproc
	movq	32(%rdi), %rax
	retq
	.cfi_endproc

	.globl	__D3mir7ndslice5slice17__T5SliceVmi2TPdZ5Slice5shapeMxFNaNbNdNiNfZG2m
	.weak_definition	__D3mir7ndslice5slice17__T5SliceVmi2TPdZ5Slice5shapeMxFNaNbNdNiNfZG2m
	.align	4, 0x90
__D3mir7ndslice5slice17__T5SliceVmi2TPdZ5Slice5shapeMxFNaNbNdNiNfZG2m:
	.cfi_startproc
	vmovups	(%rsi), %xmm0
	vmovups	%xmm0, (%rdi)
	movq	%rdi, %rax
	retq
	.cfi_endproc

	.globl	__D3mir7ndslice5slice17__T5SliceVmi2TPdZ5Slice9structureMxFNaNbNdNiNfZS3mir7ndslice5slice18__T9StructureVmi2Z9Structure
	.weak_definition	__D3mir7ndslice5slice17__T5SliceVmi2TPdZ5Slice9structureMxFNaNbNdNiNfZS3mir7ndslice5slice18__T9StructureVmi2Z9Structure
	.align	4, 0x90
__D3mir7ndslice5slice17__T5SliceVmi2TPdZ5Slice9structureMxFNaNbNdNiNfZS3mir7ndslice5slice18__T9StructureVmi2Z9Structure:
	.cfi_startproc
	vmovups	(%rsi), %xmm0
	vmovaps	%xmm0, -40(%rsp)
	vmovups	16(%rsi), %xmm0
	vmovaps	%xmm0, -24(%rsp)
	vmovups	-40(%rsp), %ymm0
	vmovups	%ymm0, (%rdi)
	movq	%rdi, %rax
	vzeroupper
	retq
	.cfi_endproc

	.globl	__D3mir7ndslice5slice17__T5SliceVmi2TPdZ5Slice4saveMFNaNbNdNiNfZS3mir7ndslice5slice17__T5SliceVmi2TPdZ5Slice
	.weak_definition	__D3mir7ndslice5slice17__T5SliceVmi2TPdZ5Slice4saveMFNaNbNdNiNfZS3mir7ndslice5slice17__T5SliceVmi2TPdZ5Slice
	.align	4, 0x90
__D3mir7ndslice5slice17__T5SliceVmi2TPdZ5Slice4saveMFNaNbNdNiNfZS3mir7ndslice5slice17__T5SliceVmi2TPdZ5Slice:
	.cfi_startproc
	movq	32(%rsi), %rax
	vmovups	(%rsi), %xmm0
	vmovups	16(%rsi), %xmm1
	vmovups	%xmm0, (%rdi)
	vmovups	%xmm1, 16(%rdi)
	movq	%rax, 32(%rdi)
	movq	%rdi, %rax
	retq
	.cfi_endproc

	.globl	__D3mir7ndslice5slice17__T5SliceVmi2TPdZ5Slice8popFrontMFNaNbNimZv
	.weak_definition	__D3mir7ndslice5slice17__T5SliceVmi2TPdZ5Slice8popFrontMFNaNbNimZv
	.align	4, 0x90
__D3mir7ndslice5slice17__T5SliceVmi2TPdZ5Slice8popFrontMFNaNbNimZv:
	.cfi_startproc
	pushq	%rax
Ltmp19:
	.cfi_def_cfa_offset 16
	cmpq	$2, %rsi
	jae	LBB29_3
	movq	(%rdi,%rsi,8), %rax
	testq	%rax, %rax
	je	LBB29_4
	addq	$-1, %rax
	movq	%rax, (%rdi,%rsi,8)
	movq	16(%rdi,%rsi,8), %rax
	shlq	$3, %rax
	addq	%rax, 32(%rdi)
	popq	%rax
	retq
LBB29_3:
	leaq	L_.str7(%rip), %rsi
	leaq	L_.str6(%rip), %rcx
	movl	$92, %edi
	movl	$19, %edx
	movl	$1567, %r8d
	callq	__d_assert_msg
LBB29_4:
	leaq	L_.str8(%rip), %rsi
	leaq	L_.str6(%rip), %rcx
	movl	$38, %edi
	movl	$19, %edx
	movl	$1568, %r8d
	callq	__d_assert_msg
	.cfi_endproc

	.globl	__D3mir7ndslice5slice17__T5SliceVmi2TPdZ5Slice7popBackMFNaNbNiNfmZv
	.weak_definition	__D3mir7ndslice5slice17__T5SliceVmi2TPdZ5Slice7popBackMFNaNbNiNfmZv
	.align	4, 0x90
__D3mir7ndslice5slice17__T5SliceVmi2TPdZ5Slice7popBackMFNaNbNiNfmZv:
	.cfi_startproc
	pushq	%rax
Ltmp20:
	.cfi_def_cfa_offset 16
	cmpq	$2, %rsi
	jae	LBB30_3
	movq	(%rdi,%rsi,8), %rax
	testq	%rax, %rax
	je	LBB30_4
	addq	$-1, %rax
	movq	%rax, (%rdi,%rsi,8)
	popq	%rax
	retq
LBB30_3:
	leaq	L_.str9(%rip), %rsi
	leaq	L_.str6(%rip), %rcx
	movl	$91, %edi
	movl	$19, %edx
	movl	$1576, %r8d
	callq	__d_assert_msg
LBB30_4:
	leaq	L_.str8(%rip), %rsi
	leaq	L_.str6(%rip), %rcx
	movl	$38, %edi
	movl	$19, %edx
	movl	$1577, %r8d
	callq	__d_assert_msg
	.cfi_endproc

	.globl	__D3mir7ndslice5slice17__T5SliceVmi2TPdZ5Slice15popFrontExactlyMFNaNbNimmZv
	.weak_definition	__D3mir7ndslice5slice17__T5SliceVmi2TPdZ5Slice15popFrontExactlyMFNaNbNimmZv
	.align	4, 0x90
__D3mir7ndslice5slice17__T5SliceVmi2TPdZ5Slice15popFrontExactlyMFNaNbNimmZv:
	.cfi_startproc
	pushq	%rax
Ltmp21:
	.cfi_def_cfa_offset 16
	cmpq	$2, %rdx
	jae	LBB31_3
	movq	(%rdi,%rdx,8), %rax
	subq	%rsi, %rax
	jb	LBB31_4
	movq	%rax, (%rdi,%rdx,8)
	imulq	16(%rdi,%rdx,8), %rsi
	shlq	$3, %rsi
	addq	%rsi, 32(%rdi)
	popq	%rax
	retq
LBB31_3:
	leaq	L_.str10(%rip), %rsi
	leaq	L_.str6(%rip), %rcx
	movl	$99, %edi
	movl	$19, %edx
	movl	$1583, %r8d
	callq	__d_assert_msg
LBB31_4:
	leaq	L_.str11(%rip), %rsi
	leaq	L_.str6(%rip), %rcx
	movl	$106, %edi
	movl	$19, %edx
	movl	$1584, %r8d
	callq	__d_assert_msg
	.cfi_endproc

	.globl	__D3mir7ndslice5slice17__T5SliceVmi2TPdZ5Slice14popBackExactlyMFNaNbNiNfmmZv
	.weak_definition	__D3mir7ndslice5slice17__T5SliceVmi2TPdZ5Slice14popBackExactlyMFNaNbNiNfmmZv
	.align	4, 0x90
__D3mir7ndslice5slice17__T5SliceVmi2TPdZ5Slice14popBackExactlyMFNaNbNiNfmmZv:
	.cfi_startproc
	pushq	%rax
Ltmp22:
	.cfi_def_cfa_offset 16
	cmpq	$2, %rdx
	jae	LBB32_3
	movq	(%rdi,%rdx,8), %rax
	subq	%rsi, %rax
	jb	LBB32_4
	movq	%rax, (%rdi,%rdx,8)
	popq	%rax
	retq
LBB32_3:
	leaq	L_.str12(%rip), %rsi
	leaq	L_.str6(%rip), %rcx
	movl	$98, %edi
	movl	$19, %edx
	movl	$1591, %r8d
	callq	__d_assert_msg
LBB32_4:
	leaq	L_.str13(%rip), %rsi
	leaq	L_.str6(%rip), %rcx
	movl	$105, %edi
	movl	$19, %edx
	movl	$1592, %r8d
	callq	__d_assert_msg
	.cfi_endproc

	.globl	__D3mir7ndslice5slice17__T5SliceVmi2TPdZ5Slice9popFrontNMFNaNbNimmZv
	.weak_definition	__D3mir7ndslice5slice17__T5SliceVmi2TPdZ5Slice9popFrontNMFNaNbNimmZv
	.align	4, 0x90
__D3mir7ndslice5slice17__T5SliceVmi2TPdZ5Slice9popFrontNMFNaNbNimmZv:
	.cfi_startproc
	pushq	%rax
Ltmp23:
	.cfi_def_cfa_offset 16
	cmpq	$2, %rdx
	jae	LBB33_2
	movq	(%rdi,%rdx,8), %rax
	cmpq	%rsi, %rax
	cmovbeq	%rax, %rsi
	subq	%rsi, %rax
	movq	%rax, (%rdi,%rdx,8)
	imulq	16(%rdi,%rdx,8), %rsi
	shlq	$3, %rsi
	addq	%rsi, 32(%rdi)
	popq	%rax
	retq
LBB33_2:
	leaq	L_.str14(%rip), %rsi
	leaq	L_.str6(%rip), %rcx
	movl	$93, %edi
	movl	$19, %edx
	movl	$1598, %r8d
	callq	__d_assert_msg
	.cfi_endproc

	.globl	__D3std9algorithm10comparison12__T3minTmTmZ3minFNaNbNiNfmmZm
	.weak_definition	__D3std9algorithm10comparison12__T3minTmTmZ3minFNaNbNiNfmmZm
	.align	4, 0x90
__D3std9algorithm10comparison12__T3minTmTmZ3minFNaNbNiNfmmZm:
	.cfi_startproc
	cmpq	%rdi, %rsi
	cmovbq	%rsi, %rdi
	movq	%rdi, %rax
	retq
	.cfi_endproc

	.globl	__D3mir7ndslice5slice17__T5SliceVmi2TPdZ5Slice8popBackNMFNaNbNiNfmmZv
	.weak_definition	__D3mir7ndslice5slice17__T5SliceVmi2TPdZ5Slice8popBackNMFNaNbNiNfmmZv
	.align	4, 0x90
__D3mir7ndslice5slice17__T5SliceVmi2TPdZ5Slice8popBackNMFNaNbNiNfmmZv:
	.cfi_startproc
	pushq	%rax
Ltmp24:
	.cfi_def_cfa_offset 16
	cmpq	$2, %rdx
	jae	LBB35_2
	movq	(%rdi,%rdx,8), %rax
	cmpq	%rsi, %rax
	cmovbeq	%rax, %rsi
	subq	%rsi, %rax
	movq	%rax, (%rdi,%rdx,8)
	popq	%rax
	retq
LBB35_2:
	leaq	L_.str15(%rip), %rsi
	leaq	L_.str6(%rip), %rcx
	movl	$92, %edi
	movl	$19, %edx
	movl	$1605, %r8d
	callq	__d_assert_msg
	.cfi_endproc

	.globl	__D3mir7ndslice5slice17__T5SliceVmi2TPdZ5Slice13elementsCountMxFNaNbNiNfZm
	.weak_definition	__D3mir7ndslice5slice17__T5SliceVmi2TPdZ5Slice13elementsCountMxFNaNbNiNfZm
	.align	4, 0x90
__D3mir7ndslice5slice17__T5SliceVmi2TPdZ5Slice13elementsCountMxFNaNbNiNfZm:
	.cfi_startproc
	movq	8(%rdi), %rax
	imulq	(%rdi), %rax
	retq
	.cfi_endproc

	.globl	__D3mir7ndslice5slice17__T5SliceVmi2TPdZ5Slice7opIndexMFNaNbNcNimmZd
	.weak_definition	__D3mir7ndslice5slice17__T5SliceVmi2TPdZ5Slice7opIndexMFNaNbNcNimmZd
	.align	4, 0x90
__D3mir7ndslice5slice17__T5SliceVmi2TPdZ5Slice7opIndexMFNaNbNcNimmZd:
	.cfi_startproc
	pushq	%rax
Ltmp25:
	.cfi_def_cfa_offset 16
	cmpq	%rdx, (%rdi)
	jbe	LBB37_3
	cmpq	%rsi, 8(%rdi)
	jbe	LBB37_4
	imulq	16(%rdi), %rdx
	imulq	24(%rdi), %rsi
	addq	%rdx, %rsi
	shlq	$3, %rsi
	addq	32(%rdi), %rsi
	movq	%rsi, %rax
	popq	%rdx
	retq
LBB37_3:
	leaq	L_.str1(%rip), %rsi
	leaq	L_.str31(%rip), %rcx
	movl	$86, %edi
	movl	$30, %edx
	movl	$1139, %r8d
	callq	__d_assert_msg
LBB37_4:
	leaq	L_.str3(%rip), %rsi
	leaq	L_.str31(%rip), %rcx
	movl	$86, %edi
	movl	$30, %edx
	movl	$1142, %r8d
	callq	__d_assert_msg
	.cfi_endproc

	.globl	__D3mir7ndslice5slice17__T5SliceVmi2TPdZ5Slice21__T11indexStrideTmTmZ11indexStrideMxFNaNbNiNfmmZm
	.weak_definition	__D3mir7ndslice5slice17__T5SliceVmi2TPdZ5Slice21__T11indexStrideTmTmZ11indexStrideMxFNaNbNiNfmmZm
	.align	4, 0x90
__D3mir7ndslice5slice17__T5SliceVmi2TPdZ5Slice21__T11indexStrideTmTmZ11indexStrideMxFNaNbNiNfmmZm:
	.cfi_startproc
	pushq	%rax
Ltmp26:
	.cfi_def_cfa_offset 16
	cmpq	%rdx, (%rdi)
	jbe	LBB38_3
	cmpq	%rsi, 8(%rdi)
	jbe	LBB38_2
	imulq	16(%rdi), %rdx
	imulq	24(%rdi), %rsi
	addq	%rdx, %rsi
	movq	%rsi, %rax
	popq	%rdx
	retq
LBB38_3:
	leaq	L_.str1(%rip), %rsi
	leaq	L_.str31(%rip), %rcx
	movl	$86, %edi
	movl	$30, %edx
	movl	$1139, %r8d
	callq	__d_assert_msg
LBB38_2:
	leaq	L_.str3(%rip), %rsi
	leaq	L_.str31(%rip), %rcx
	movl	$86, %edi
	movl	$30, %edx
	movl	$1142, %r8d
	callq	__d_assert_msg
	.cfi_endproc

	.globl	__D3mir7ndslice5slice17__T5SliceVmi2TPdZ5Slice7opIndexMFNaNbNcNiG2mZd
	.weak_definition	__D3mir7ndslice5slice17__T5SliceVmi2TPdZ5Slice7opIndexMFNaNbNcNiG2mZd
	.align	4, 0x90
__D3mir7ndslice5slice17__T5SliceVmi2TPdZ5Slice7opIndexMFNaNbNcNiG2mZd:
	.cfi_startproc
	pushq	%rax
Ltmp27:
	.cfi_def_cfa_offset 16
	movq	16(%rsp), %rcx
	cmpq	(%rdi), %rcx
	jae	LBB39_3
	movq	24(%rsp), %rax
	cmpq	8(%rdi), %rax
	jae	LBB39_4
	imulq	16(%rdi), %rcx
	imulq	24(%rdi), %rax
	addq	%rcx, %rax
	shlq	$3, %rax
	addq	32(%rdi), %rax
	popq	%rdx
	retq
LBB39_3:
	leaq	L_.str1(%rip), %rsi
	leaq	L_.str2(%rip), %rcx
	movl	$86, %edi
	movl	$30, %edx
	movl	$1144, %r8d
	callq	__d_assert_msg
LBB39_4:
	leaq	L_.str3(%rip), %rsi
	leaq	L_.str2(%rip), %rcx
	movl	$86, %edi
	movl	$30, %edx
	movl	$1147, %r8d
	callq	__d_assert_msg
	.cfi_endproc

	.globl	__D3mir7ndslice5slice17__T5SliceVmi2TPdZ5Slice6opCallMFNaNbNcNimmZd
	.weak_definition	__D3mir7ndslice5slice17__T5SliceVmi2TPdZ5Slice6opCallMFNaNbNcNimmZd
	.align	4, 0x90
__D3mir7ndslice5slice17__T5SliceVmi2TPdZ5Slice6opCallMFNaNbNcNimmZd:
	.cfi_startproc
	pushq	%rax
Ltmp28:
	.cfi_def_cfa_offset 16
	cmpq	%rsi, (%rdi)
	jbe	LBB40_3
	cmpq	%rdx, 8(%rdi)
	jbe	LBB40_4
	imulq	16(%rdi), %rsi
	imulq	24(%rdi), %rdx
	addq	%rsi, %rdx
	shlq	$3, %rdx
	addq	32(%rdi), %rdx
	movq	%rdx, %rax
	popq	%rdx
	retq
LBB40_3:
	leaq	L_.str3(%rip), %rsi
	leaq	L_.str36(%rip), %rcx
	movl	$86, %edi
	movl	$30, %edx
	movl	$1149, %r8d
	callq	__d_assert_msg
LBB40_4:
	leaq	L_.str1(%rip), %rsi
	leaq	L_.str36(%rip), %rcx
	movl	$86, %edi
	movl	$30, %edx
	movl	$1152, %r8d
	callq	__d_assert_msg
	.cfi_endproc

	.globl	__D3mir7ndslice5slice17__T5SliceVmi2TPdZ5Slice25__T15mathIndexStrideTmTmZ15mathIndexStrideMxFNaNbNiNfmmZm
	.weak_definition	__D3mir7ndslice5slice17__T5SliceVmi2TPdZ5Slice25__T15mathIndexStrideTmTmZ15mathIndexStrideMxFNaNbNiNfmmZm
	.align	4, 0x90
__D3mir7ndslice5slice17__T5SliceVmi2TPdZ5Slice25__T15mathIndexStrideTmTmZ15mathIndexStrideMxFNaNbNiNfmmZm:
	.cfi_startproc
	pushq	%rax
Ltmp29:
	.cfi_def_cfa_offset 16
	cmpq	%rsi, (%rdi)
	jbe	LBB41_3
	cmpq	%rdx, 8(%rdi)
	jbe	LBB41_2
	imulq	16(%rdi), %rsi
	imulq	24(%rdi), %rdx
	addq	%rsi, %rdx
	movq	%rdx, %rax
	popq	%rdx
	retq
LBB41_3:
	leaq	L_.str3(%rip), %rsi
	leaq	L_.str36(%rip), %rcx
	movl	$86, %edi
	movl	$30, %edx
	movl	$1149, %r8d
	callq	__d_assert_msg
LBB41_2:
	leaq	L_.str1(%rip), %rsi
	leaq	L_.str36(%rip), %rcx
	movl	$86, %edi
	movl	$30, %edx
	movl	$1152, %r8d
	callq	__d_assert_msg
	.cfi_endproc

	.globl	__D3mir7ndslice5slice17__T5SliceVmi2TPdZ5Slice6opCallMFNaNbNcNiG2mZd
	.weak_definition	__D3mir7ndslice5slice17__T5SliceVmi2TPdZ5Slice6opCallMFNaNbNcNiG2mZd
	.align	4, 0x90
__D3mir7ndslice5slice17__T5SliceVmi2TPdZ5Slice6opCallMFNaNbNcNiG2mZd:
	.cfi_startproc
	pushq	%rax
Ltmp30:
	.cfi_def_cfa_offset 16
	movq	24(%rsp), %rcx
	cmpq	(%rdi), %rcx
	jae	LBB42_3
	movq	16(%rsp), %rax
	cmpq	8(%rdi), %rax
	jae	LBB42_4
	imulq	16(%rdi), %rcx
	imulq	24(%rdi), %rax
	addq	%rcx, %rax
	shlq	$3, %rax
	addq	32(%rdi), %rax
	popq	%rdx
	retq
LBB42_3:
	leaq	L_.str3(%rip), %rsi
	leaq	L_.str4(%rip), %rcx
	movl	$86, %edi
	movl	$30, %edx
	movl	$1154, %r8d
	callq	__d_assert_msg
LBB42_4:
	leaq	L_.str1(%rip), %rsi
	leaq	L_.str4(%rip), %rcx
	movl	$86, %edi
	movl	$30, %edx
	movl	$1157, %r8d
	callq	__d_assert_msg
	.cfi_endproc

	.globl	__D3mir7ndslice5slice17__T5SliceVmi1TPdZ5Slice11indexStrideMxFNaNbNiNfG1mZm
	.weak_definition	__D3mir7ndslice5slice17__T5SliceVmi1TPdZ5Slice11indexStrideMxFNaNbNiNfG1mZm
	.align	4, 0x90
__D3mir7ndslice5slice17__T5SliceVmi1TPdZ5Slice11indexStrideMxFNaNbNiNfG1mZm:
	.cfi_startproc
	pushq	%rax
Ltmp31:
	.cfi_def_cfa_offset 16
	cmpq	(%rdi), %rsi
	jae	LBB43_2
	imulq	8(%rdi), %rsi
	movq	%rsi, %rax
	popq	%rdx
	retq
LBB43_2:
	leaq	L_.str17(%rip), %rsi
	leaq	L_.str2(%rip), %rcx
	movl	$86, %edi
	movl	$30, %edx
	movl	$1144, %r8d
	callq	__d_assert_msg
	.cfi_endproc

	.globl	__D3mir7ndslice5slice17__T5SliceVmi1TPdZ5Slice15mathIndexStrideMxFNaNbNiNfG1mZm
	.weak_definition	__D3mir7ndslice5slice17__T5SliceVmi1TPdZ5Slice15mathIndexStrideMxFNaNbNiNfG1mZm
	.align	4, 0x90
__D3mir7ndslice5slice17__T5SliceVmi1TPdZ5Slice15mathIndexStrideMxFNaNbNiNfG1mZm:
	.cfi_startproc
	pushq	%rax
Ltmp32:
	.cfi_def_cfa_offset 16
	cmpq	(%rdi), %rsi
	jae	LBB44_2
	imulq	8(%rdi), %rsi
	movq	%rsi, %rax
	popq	%rdx
	retq
LBB44_2:
	leaq	L_.str17(%rip), %rsi
	leaq	L_.str4(%rip), %rcx
	movl	$86, %edi
	movl	$30, %edx
	movl	$1154, %r8d
	callq	__d_assert_msg
	.cfi_endproc

	.globl	__D3mir7ndslice5slice17__T5SliceVmi1TPdZ5Slice6__ctorMFNaNbNcNiNfKxG1mKxG1lPdZS3mir7ndslice5slice17__T5SliceVmi1TPdZ5Slice
	.weak_definition	__D3mir7ndslice5slice17__T5SliceVmi1TPdZ5Slice6__ctorMFNaNbNcNiNfKxG1mKxG1lPdZS3mir7ndslice5slice17__T5SliceVmi1TPdZ5Slice
	.align	4, 0x90
__D3mir7ndslice5slice17__T5SliceVmi1TPdZ5Slice6__ctorMFNaNbNcNiNfKxG1mKxG1lPdZS3mir7ndslice5slice17__T5SliceVmi1TPdZ5Slice:
	.cfi_startproc
	movq	(%rcx), %rax
	movq	%rax, (%rdi)
	movq	(%rdx), %rax
	movq	%rax, 8(%rdi)
	movq	%rsi, 16(%rdi)
	movq	%rdi, %rax
	retq
	.cfi_endproc

	.globl	__D3mir7ndslice5slice17__T5SliceVmi1TPdZ5Slice3ptrMFNaNbNiNfZPd
	.weak_definition	__D3mir7ndslice5slice17__T5SliceVmi1TPdZ5Slice3ptrMFNaNbNiNfZPd
	.align	4, 0x90
__D3mir7ndslice5slice17__T5SliceVmi1TPdZ5Slice3ptrMFNaNbNiNfZPd:
	.cfi_startproc
	movq	16(%rdi), %rax
	retq
	.cfi_endproc

	.globl	__D3mir7ndslice5slice17__T5SliceVmi1TPdZ5Slice5shapeMxFNaNbNdNiNfZG1m
	.weak_definition	__D3mir7ndslice5slice17__T5SliceVmi1TPdZ5Slice5shapeMxFNaNbNdNiNfZG1m
	.align	4, 0x90
__D3mir7ndslice5slice17__T5SliceVmi1TPdZ5Slice5shapeMxFNaNbNdNiNfZG1m:
	.cfi_startproc
	movq	(%rdi), %rax
	retq
	.cfi_endproc

	.globl	__D3mir7ndslice5slice17__T5SliceVmi1TPdZ5Slice9structureMxFNaNbNdNiNfZS3mir7ndslice5slice18__T9StructureVmi1Z9Structure
	.weak_definition	__D3mir7ndslice5slice17__T5SliceVmi1TPdZ5Slice9structureMxFNaNbNdNiNfZS3mir7ndslice5slice18__T9StructureVmi1Z9Structure
	.align	4, 0x90
__D3mir7ndslice5slice17__T5SliceVmi1TPdZ5Slice9structureMxFNaNbNdNiNfZS3mir7ndslice5slice18__T9StructureVmi1Z9Structure:
	.cfi_startproc
	movq	(%rdi), %rax
	movq	8(%rdi), %rdx
	retq
	.cfi_endproc

	.globl	__D3mir7ndslice5slice17__T5SliceVmi1TPdZ5Slice4saveMFNaNbNdNiNfZS3mir7ndslice5slice17__T5SliceVmi1TPdZ5Slice
	.weak_definition	__D3mir7ndslice5slice17__T5SliceVmi1TPdZ5Slice4saveMFNaNbNdNiNfZS3mir7ndslice5slice17__T5SliceVmi1TPdZ5Slice
	.align	4, 0x90
__D3mir7ndslice5slice17__T5SliceVmi1TPdZ5Slice4saveMFNaNbNdNiNfZS3mir7ndslice5slice17__T5SliceVmi1TPdZ5Slice:
	.cfi_startproc
	movq	16(%rsi), %rax
	vmovups	(%rsi), %xmm0
	vmovups	%xmm0, (%rdi)
	movq	%rax, 16(%rdi)
	movq	%rdi, %rax
	retq
	.cfi_endproc

	.globl	__D3mir7ndslice5slice17__T5SliceVmi1TPdZ5Slice8popFrontMFNaNbNimZv
	.weak_definition	__D3mir7ndslice5slice17__T5SliceVmi1TPdZ5Slice8popFrontMFNaNbNimZv
	.align	4, 0x90
__D3mir7ndslice5slice17__T5SliceVmi1TPdZ5Slice8popFrontMFNaNbNimZv:
	.cfi_startproc
	pushq	%rax
Ltmp33:
	.cfi_def_cfa_offset 16
	testq	%rsi, %rsi
	jne	LBB50_3
	movq	(%rdi), %rax
	testq	%rax, %rax
	je	LBB50_4
	addq	$-1, %rax
	movq	%rax, (%rdi)
	movq	8(%rdi), %rax
	shlq	$3, %rax
	addq	%rax, 16(%rdi)
	popq	%rax
	retq
LBB50_3:
	leaq	L_.str18(%rip), %rsi
	leaq	L_.str6(%rip), %rcx
	movl	$92, %edi
	movl	$19, %edx
	movl	$1567, %r8d
	callq	__d_assert_msg
LBB50_4:
	leaq	L_.str8(%rip), %rsi
	leaq	L_.str6(%rip), %rcx
	movl	$38, %edi
	movl	$19, %edx
	movl	$1568, %r8d
	callq	__d_assert_msg
	.cfi_endproc

	.globl	__D3mir7ndslice5slice17__T5SliceVmi1TPdZ5Slice7popBackMFNaNbNiNfmZv
	.weak_definition	__D3mir7ndslice5slice17__T5SliceVmi1TPdZ5Slice7popBackMFNaNbNiNfmZv
	.align	4, 0x90
__D3mir7ndslice5slice17__T5SliceVmi1TPdZ5Slice7popBackMFNaNbNiNfmZv:
	.cfi_startproc
	pushq	%rax
Ltmp34:
	.cfi_def_cfa_offset 16
	testq	%rsi, %rsi
	jne	LBB51_3
	movq	(%rdi), %rax
	testq	%rax, %rax
	je	LBB51_4
	addq	$-1, %rax
	movq	%rax, (%rdi)
	popq	%rax
	retq
LBB51_3:
	leaq	L_.str19(%rip), %rsi
	leaq	L_.str6(%rip), %rcx
	movl	$91, %edi
	movl	$19, %edx
	movl	$1576, %r8d
	callq	__d_assert_msg
LBB51_4:
	leaq	L_.str8(%rip), %rsi
	leaq	L_.str6(%rip), %rcx
	movl	$38, %edi
	movl	$19, %edx
	movl	$1577, %r8d
	callq	__d_assert_msg
	.cfi_endproc

	.globl	__D3mir7ndslice5slice17__T5SliceVmi1TPdZ5Slice15popFrontExactlyMFNaNbNimmZv
	.weak_definition	__D3mir7ndslice5slice17__T5SliceVmi1TPdZ5Slice15popFrontExactlyMFNaNbNimmZv
	.align	4, 0x90
__D3mir7ndslice5slice17__T5SliceVmi1TPdZ5Slice15popFrontExactlyMFNaNbNimmZv:
	.cfi_startproc
	pushq	%rax
Ltmp35:
	.cfi_def_cfa_offset 16
	testq	%rdx, %rdx
	jne	LBB52_3
	movq	(%rdi), %rax
	subq	%rsi, %rax
	jb	LBB52_4
	movq	%rax, (%rdi)
	imulq	8(%rdi), %rsi
	shlq	$3, %rsi
	addq	%rsi, 16(%rdi)
	popq	%rax
	retq
LBB52_3:
	leaq	L_.str20(%rip), %rsi
	leaq	L_.str6(%rip), %rcx
	movl	$99, %edi
	movl	$19, %edx
	movl	$1583, %r8d
	callq	__d_assert_msg
LBB52_4:
	leaq	L_.str21(%rip), %rsi
	leaq	L_.str6(%rip), %rcx
	movl	$106, %edi
	movl	$19, %edx
	movl	$1584, %r8d
	callq	__d_assert_msg
	.cfi_endproc

	.globl	__D3mir7ndslice5slice17__T5SliceVmi1TPdZ5Slice14popBackExactlyMFNaNbNiNfmmZv
	.weak_definition	__D3mir7ndslice5slice17__T5SliceVmi1TPdZ5Slice14popBackExactlyMFNaNbNiNfmmZv
	.align	4, 0x90
__D3mir7ndslice5slice17__T5SliceVmi1TPdZ5Slice14popBackExactlyMFNaNbNiNfmmZv:
	.cfi_startproc
	pushq	%rax
Ltmp36:
	.cfi_def_cfa_offset 16
	testq	%rdx, %rdx
	jne	LBB53_3
	movq	(%rdi), %rax
	subq	%rsi, %rax
	jb	LBB53_4
	movq	%rax, (%rdi)
	popq	%rax
	retq
LBB53_3:
	leaq	L_.str22(%rip), %rsi
	leaq	L_.str6(%rip), %rcx
	movl	$98, %edi
	movl	$19, %edx
	movl	$1591, %r8d
	callq	__d_assert_msg
LBB53_4:
	leaq	L_.str23(%rip), %rsi
	leaq	L_.str6(%rip), %rcx
	movl	$105, %edi
	movl	$19, %edx
	movl	$1592, %r8d
	callq	__d_assert_msg
	.cfi_endproc

	.globl	__D3mir7ndslice5slice17__T5SliceVmi1TPdZ5Slice9popFrontNMFNaNbNimmZv
	.weak_definition	__D3mir7ndslice5slice17__T5SliceVmi1TPdZ5Slice9popFrontNMFNaNbNimmZv
	.align	4, 0x90
__D3mir7ndslice5slice17__T5SliceVmi1TPdZ5Slice9popFrontNMFNaNbNimmZv:
	.cfi_startproc
	pushq	%rax
Ltmp37:
	.cfi_def_cfa_offset 16
	testq	%rdx, %rdx
	jne	LBB54_2
	movq	(%rdi), %rax
	cmpq	%rsi, %rax
	cmovbeq	%rax, %rsi
	subq	%rsi, %rax
	movq	%rax, (%rdi)
	imulq	8(%rdi), %rsi
	shlq	$3, %rsi
	addq	%rsi, 16(%rdi)
	popq	%rax
	retq
LBB54_2:
	leaq	L_.str24(%rip), %rsi
	leaq	L_.str6(%rip), %rcx
	movl	$93, %edi
	movl	$19, %edx
	movl	$1598, %r8d
	callq	__d_assert_msg
	.cfi_endproc

	.globl	__D3mir7ndslice5slice17__T5SliceVmi1TPdZ5Slice8popBackNMFNaNbNiNfmmZv
	.weak_definition	__D3mir7ndslice5slice17__T5SliceVmi1TPdZ5Slice8popBackNMFNaNbNiNfmmZv
	.align	4, 0x90
__D3mir7ndslice5slice17__T5SliceVmi1TPdZ5Slice8popBackNMFNaNbNiNfmmZv:
	.cfi_startproc
	pushq	%rax
Ltmp38:
	.cfi_def_cfa_offset 16
	testq	%rdx, %rdx
	jne	LBB55_2
	movq	(%rdi), %rax
	cmpq	%rsi, %rax
	cmovbeq	%rax, %rsi
	subq	%rsi, %rax
	movq	%rax, (%rdi)
	popq	%rax
	retq
LBB55_2:
	leaq	L_.str25(%rip), %rsi
	leaq	L_.str6(%rip), %rcx
	movl	$92, %edi
	movl	$19, %edx
	movl	$1605, %r8d
	callq	__d_assert_msg
	.cfi_endproc

	.globl	__D3mir7ndslice5slice17__T5SliceVmi1TPdZ5Slice13elementsCountMxFNaNbNiNfZm
	.weak_definition	__D3mir7ndslice5slice17__T5SliceVmi1TPdZ5Slice13elementsCountMxFNaNbNiNfZm
	.align	4, 0x90
__D3mir7ndslice5slice17__T5SliceVmi1TPdZ5Slice13elementsCountMxFNaNbNiNfZm:
	.cfi_startproc
	movq	(%rdi), %rax
	retq
	.cfi_endproc

	.globl	__D3mir7ndslice5slice17__T5SliceVmi1TPdZ5Slice7opIndexMFNaNbNcNimZd
	.weak_definition	__D3mir7ndslice5slice17__T5SliceVmi1TPdZ5Slice7opIndexMFNaNbNcNimZd
	.align	4, 0x90
__D3mir7ndslice5slice17__T5SliceVmi1TPdZ5Slice7opIndexMFNaNbNcNimZd:
	.cfi_startproc
	pushq	%rax
Ltmp39:
	.cfi_def_cfa_offset 16
	cmpq	%rsi, (%rdi)
	jbe	LBB57_2
	imulq	8(%rdi), %rsi
	shlq	$3, %rsi
	addq	16(%rdi), %rsi
	movq	%rsi, %rax
	popq	%rdx
	retq
LBB57_2:
	leaq	L_.str17(%rip), %rsi
	leaq	L_.str31(%rip), %rcx
	movl	$86, %edi
	movl	$30, %edx
	movl	$1139, %r8d
	callq	__d_assert_msg
	.cfi_endproc

	.globl	__D3mir7ndslice5slice17__T5SliceVmi1TPdZ5Slice19__T11indexStrideTmZ11indexStrideMxFNaNbNiNfmZm
	.weak_definition	__D3mir7ndslice5slice17__T5SliceVmi1TPdZ5Slice19__T11indexStrideTmZ11indexStrideMxFNaNbNiNfmZm
	.align	4, 0x90
__D3mir7ndslice5slice17__T5SliceVmi1TPdZ5Slice19__T11indexStrideTmZ11indexStrideMxFNaNbNiNfmZm:
	.cfi_startproc
	pushq	%rax
Ltmp40:
	.cfi_def_cfa_offset 16
	cmpq	%rsi, (%rdi)
	jbe	LBB58_2
	imulq	8(%rdi), %rsi
	movq	%rsi, %rax
	popq	%rdx
	retq
LBB58_2:
	leaq	L_.str17(%rip), %rsi
	leaq	L_.str31(%rip), %rcx
	movl	$86, %edi
	movl	$30, %edx
	movl	$1139, %r8d
	callq	__d_assert_msg
	.cfi_endproc

	.globl	__D3mir7ndslice5slice17__T5SliceVmi1TPdZ5Slice7opIndexMFNaNbNcNiG1mZd
	.weak_definition	__D3mir7ndslice5slice17__T5SliceVmi1TPdZ5Slice7opIndexMFNaNbNcNiG1mZd
	.align	4, 0x90
__D3mir7ndslice5slice17__T5SliceVmi1TPdZ5Slice7opIndexMFNaNbNcNiG1mZd:
	.cfi_startproc
	pushq	%rax
Ltmp41:
	.cfi_def_cfa_offset 16
	cmpq	(%rdi), %rsi
	jae	LBB59_2
	imulq	8(%rdi), %rsi
	shlq	$3, %rsi
	addq	16(%rdi), %rsi
	movq	%rsi, %rax
	popq	%rdx
	retq
LBB59_2:
	leaq	L_.str17(%rip), %rsi
	leaq	L_.str2(%rip), %rcx
	movl	$86, %edi
	movl	$30, %edx
	movl	$1144, %r8d
	callq	__d_assert_msg
	.cfi_endproc

	.globl	__D3mir7ndslice5slice17__T5SliceVmi1TPdZ5Slice6opCallMFNaNbNcNimZd
	.weak_definition	__D3mir7ndslice5slice17__T5SliceVmi1TPdZ5Slice6opCallMFNaNbNcNimZd
	.align	4, 0x90
__D3mir7ndslice5slice17__T5SliceVmi1TPdZ5Slice6opCallMFNaNbNcNimZd:
	.cfi_startproc
	pushq	%rax
Ltmp42:
	.cfi_def_cfa_offset 16
	cmpq	%rsi, (%rdi)
	jbe	LBB60_2
	imulq	8(%rdi), %rsi
	shlq	$3, %rsi
	addq	16(%rdi), %rsi
	movq	%rsi, %rax
	popq	%rdx
	retq
LBB60_2:
	leaq	L_.str17(%rip), %rsi
	leaq	L_.str36(%rip), %rcx
	movl	$86, %edi
	movl	$30, %edx
	movl	$1149, %r8d
	callq	__d_assert_msg
	.cfi_endproc

	.globl	__D3mir7ndslice5slice17__T5SliceVmi1TPdZ5Slice23__T15mathIndexStrideTmZ15mathIndexStrideMxFNaNbNiNfmZm
	.weak_definition	__D3mir7ndslice5slice17__T5SliceVmi1TPdZ5Slice23__T15mathIndexStrideTmZ15mathIndexStrideMxFNaNbNiNfmZm
	.align	4, 0x90
__D3mir7ndslice5slice17__T5SliceVmi1TPdZ5Slice23__T15mathIndexStrideTmZ15mathIndexStrideMxFNaNbNiNfmZm:
	.cfi_startproc
	pushq	%rax
Ltmp43:
	.cfi_def_cfa_offset 16
	cmpq	%rsi, (%rdi)
	jbe	LBB61_2
	imulq	8(%rdi), %rsi
	movq	%rsi, %rax
	popq	%rdx
	retq
LBB61_2:
	leaq	L_.str17(%rip), %rsi
	leaq	L_.str36(%rip), %rcx
	movl	$86, %edi
	movl	$30, %edx
	movl	$1149, %r8d
	callq	__d_assert_msg
	.cfi_endproc

	.globl	__D3mir7ndslice5slice17__T5SliceVmi1TPdZ5Slice6opCallMFNaNbNcNiG1mZd
	.weak_definition	__D3mir7ndslice5slice17__T5SliceVmi1TPdZ5Slice6opCallMFNaNbNcNiG1mZd
	.align	4, 0x90
__D3mir7ndslice5slice17__T5SliceVmi1TPdZ5Slice6opCallMFNaNbNcNiG1mZd:
	.cfi_startproc
	pushq	%rax
Ltmp44:
	.cfi_def_cfa_offset 16
	cmpq	(%rdi), %rsi
	jae	LBB62_2
	imulq	8(%rdi), %rsi
	shlq	$3, %rsi
	addq	16(%rdi), %rsi
	movq	%rsi, %rax
	popq	%rdx
	retq
LBB62_2:
	leaq	L_.str17(%rip), %rsi
	leaq	L_.str4(%rip), %rcx
	movl	$86, %edi
	movl	$30, %edx
	movl	$1154, %r8d
	callq	__d_assert_msg
	.cfi_endproc

	.globl	__D3mir7ndslice9iteration24__T10transposedVii1Vii0Z23__T10transposedVmi2TPdZ10transposedFNaNbNiKS3mir7ndslice5slice17__T5SliceVmi2TPdZ5SliceZS3mir7ndslice5slice17__T5SliceVmi2TPdZ5Slice
	.weak_definition	__D3mir7ndslice9iteration24__T10transposedVii1Vii0Z23__T10transposedVmi2TPdZ10transposedFNaNbNiKS3mir7ndslice5slice17__T5SliceVmi2TPdZ5SliceZS3mir7ndslice5slice17__T5SliceVmi2TPdZ5Slice
	.align	4, 0x90
__D3mir7ndslice9iteration24__T10transposedVii1Vii0Z23__T10transposedVmi2TPdZ10transposedFNaNbNiKS3mir7ndslice5slice17__T5SliceVmi2TPdZ5SliceZS3mir7ndslice5slice17__T5SliceVmi2TPdZ5Slice:
	.cfi_startproc
	movq	8(%rsi), %rax
	movq	%rax, (%rdi)
	movq	24(%rsi), %rax
	movq	%rax, 16(%rdi)
	movq	(%rsi), %rax
	movq	%rax, 8(%rdi)
	movq	16(%rsi), %rax
	movq	%rax, 24(%rdi)
	movq	32(%rsi), %rax
	movq	%rax, 32(%rdi)
	movq	%rdi, %rax
	retq
	.cfi_endproc

	.globl	__D3mir7ndslice9iteration27__T17completeTransposeVmi2Z17completeTransposeFNaNbNiNfxAmZG2m
	.weak_definition	__D3mir7ndslice9iteration27__T17completeTransposeVmi2Z17completeTransposeFNaNbNiNfxAmZG2m
	.align	4, 0x90
__D3mir7ndslice9iteration27__T17completeTransposeVmi2Z17completeTransposeFNaNbNiNfxAmZG2m:
	.cfi_startproc
	pushq	%rax
Ltmp45:
	.cfi_def_cfa_offset 16
	cmpq	$2, %rsi
	ja	LBB64_4
	vxorps	%xmm0, %xmm0, %xmm0
	vmovups	%xmm0, (%rdi)
	movq	$0, (%rsp)
	xorl	%eax, %eax
	testq	%rsi, %rsi
	je	LBB64_10
	.align	4, 0x90
LBB64_2:
	movq	(%rdx,%rax,8), %rcx
	cmpq	$2, %rcx
	jae	LBB64_3
	movl	$1, (%rsp,%rcx,4)
	cmpq	$2, %rax
	jae	LBB64_15
	movq	(%rdx,%rax,8), %rcx
	movq	%rcx, (%rdi,%rax,8)
	addq	$1, %rax
	cmpq	%rsi, %rax
	jb	LBB64_2
	cmpl	$0, (%rsp)
	jne	LBB64_11
	cmpq	$2, %rsi
	jae	LBB64_7
LBB64_10:
	movq	$0, (%rdi,%rsi,8)
	addq	$1, %rsi
LBB64_11:
	cmpl	$0, 4(%rsp)
	jne	LBB64_14
	cmpq	$1, %rsi
	ja	LBB64_7
	movq	$1, (%rdi,%rsi,8)
LBB64_14:
	movq	%rdi, %rax
	popq	%rdx
	retq
LBB64_3:
	leaq	L_.str32(%rip), %rsi
	movl	$23, %edi
	movl	$380, %edx
	callq	__d_arraybounds
LBB64_15:
	leaq	L_.str32(%rip), %rsi
	movl	$23, %edi
	movl	$381, %edx
	callq	__d_arraybounds
LBB64_4:
	leaq	L_.str32(%rip), %rsi
	movl	$23, %edi
	movl	$375, %edx
	callq	__d_assert
LBB64_7:
	leaq	L_.str32(%rip), %rsi
	movl	$23, %edi
	movl	$386, %edx
	callq	__d_arraybounds
	.cfi_endproc

	.globl	__D3mir7ndslice5slice17__T5SliceVmi2TPdZ5Slice12__T7opIndexZ7opIndexMFNaNbNiNfZS3mir7ndslice5slice17__T5SliceVmi2TPdZ5Slice
	.weak_definition	__D3mir7ndslice5slice17__T5SliceVmi2TPdZ5Slice12__T7opIndexZ7opIndexMFNaNbNiNfZS3mir7ndslice5slice17__T5SliceVmi2TPdZ5Slice
	.align	4, 0x90
__D3mir7ndslice5slice17__T5SliceVmi2TPdZ5Slice12__T7opIndexZ7opIndexMFNaNbNiNfZS3mir7ndslice5slice17__T5SliceVmi2TPdZ5Slice:
	.cfi_startproc
	movq	32(%rsi), %rax
	movq	%rax, 32(%rdi)
	vmovups	(%rsi), %ymm0
	vmovups	%ymm0, (%rdi)
	movq	%rdi, %rax
	vzeroupper
	retq
	.cfi_endproc

	.globl	__D3mir7ndslice5slice17__T5SliceVmi2TPdZ5Slice14__T5emptyVii0Z5emptyMxFNaNbNdNiNfZb
	.weak_definition	__D3mir7ndslice5slice17__T5SliceVmi2TPdZ5Slice14__T5emptyVii0Z5emptyMxFNaNbNdNiNfZb
	.align	4, 0x90
__D3mir7ndslice5slice17__T5SliceVmi2TPdZ5Slice14__T5emptyVii0Z5emptyMxFNaNbNdNiNfZb:
	.cfi_startproc
	cmpq	$0, (%rdi)
	sete	%al
	retq
	.cfi_endproc

	.globl	__D3mir7ndslice5slice17__T5SliceVmi2TPdZ5Slice14__T5frontVii0Z5frontMFNaNbNdNiZS3mir7ndslice5slice17__T5SliceVmi1TPdZ5Slice
	.weak_definition	__D3mir7ndslice5slice17__T5SliceVmi2TPdZ5Slice14__T5frontVii0Z5frontMFNaNbNdNiZS3mir7ndslice5slice17__T5SliceVmi1TPdZ5Slice
	.align	4, 0x90
__D3mir7ndslice5slice17__T5SliceVmi2TPdZ5Slice14__T5frontVii0Z5frontMFNaNbNdNiZS3mir7ndslice5slice17__T5SliceVmi1TPdZ5Slice:
	.cfi_startproc
	pushq	%rax
Ltmp46:
	.cfi_def_cfa_offset 16
	cmpq	$0, (%rsi)
	je	LBB67_2
	movq	8(%rsi), %rax
	movq	%rax, (%rdi)
	movq	24(%rsi), %rax
	movq	%rax, 8(%rdi)
	movq	32(%rsi), %rax
	movq	%rax, 16(%rdi)
	movq	%rdi, %rax
	popq	%rdx
	retq
LBB67_2:
	leaq	L_.str6(%rip), %rsi
	movl	$19, %edi
	movl	$1386, %edx
	callq	__d_assert
	.cfi_endproc

	.globl	__D3mir7ndslice5slice17__T5SliceVmi1TPdZ5Slice15__T6lengthVii0Z6lengthMxFNaNbNdNiNfZm
	.weak_definition	__D3mir7ndslice5slice17__T5SliceVmi1TPdZ5Slice15__T6lengthVii0Z6lengthMxFNaNbNdNiNfZm
	.align	4, 0x90
__D3mir7ndslice5slice17__T5SliceVmi1TPdZ5Slice15__T6lengthVii0Z6lengthMxFNaNbNdNiNfZm:
	.cfi_startproc
	movq	(%rdi), %rax
	retq
	.cfi_endproc

	.globl	__D3mir7ndslice5slice17__T5SliceVmi1TPdZ5Slice14__T5frontVii0Z5frontMFNaNbNcNdNiNfZd
	.weak_definition	__D3mir7ndslice5slice17__T5SliceVmi1TPdZ5Slice14__T5frontVii0Z5frontMFNaNbNcNdNiNfZd
	.align	4, 0x90
__D3mir7ndslice5slice17__T5SliceVmi1TPdZ5Slice14__T5frontVii0Z5frontMFNaNbNcNdNiNfZd:
	.cfi_startproc
	pushq	%rax
Ltmp47:
	.cfi_def_cfa_offset 16
	cmpq	$0, (%rdi)
	je	LBB69_2
	movq	16(%rdi), %rax
	popq	%rdx
	retq
LBB69_2:
	leaq	L_.str6(%rip), %rsi
	movl	$19, %edi
	movl	$1386, %edx
	callq	__d_assert
	.cfi_endproc

	.globl	__D3mir7ndslice5slice17__T5SliceVmi1TPdZ5Slice17__T8popFrontVii0Z8popFrontMFNaNbNiZv
	.weak_definition	__D3mir7ndslice5slice17__T5SliceVmi1TPdZ5Slice17__T8popFrontVii0Z8popFrontMFNaNbNiZv
	.align	4, 0x90
__D3mir7ndslice5slice17__T5SliceVmi1TPdZ5Slice17__T8popFrontVii0Z8popFrontMFNaNbNiZv:
	.cfi_startproc
	pushq	%rax
Ltmp48:
	.cfi_def_cfa_offset 16
	movq	(%rdi), %rax
	testq	%rax, %rax
	je	LBB70_2
	addq	$-1, %rax
	movq	%rax, (%rdi)
	movq	8(%rdi), %rax
	shlq	$3, %rax
	addq	%rax, 16(%rdi)
	popq	%rax
	retq
LBB70_2:
	leaq	L_.str34(%rip), %rsi
	leaq	L_.str6(%rip), %rcx
	movl	$102, %edi
	movl	$19, %edx
	movl	$1475, %r8d
	callq	__d_assert_msg
	.cfi_endproc

	.globl	__D3mir7ndslice5slice17__T5SliceVmi2TPdZ5Slice17__T8popFrontVii0Z8popFrontMFNaNbNiZv
	.weak_definition	__D3mir7ndslice5slice17__T5SliceVmi2TPdZ5Slice17__T8popFrontVii0Z8popFrontMFNaNbNiZv
	.align	4, 0x90
__D3mir7ndslice5slice17__T5SliceVmi2TPdZ5Slice17__T8popFrontVii0Z8popFrontMFNaNbNiZv:
	.cfi_startproc
	pushq	%rax
Ltmp49:
	.cfi_def_cfa_offset 16
	movq	(%rdi), %rax
	testq	%rax, %rax
	je	LBB71_2
	addq	$-1, %rax
	movq	%rax, (%rdi)
	movq	16(%rdi), %rax
	shlq	$3, %rax
	addq	%rax, 32(%rdi)
	popq	%rax
	retq
LBB71_2:
	leaq	L_.str33(%rip), %rsi
	leaq	L_.str6(%rip), %rcx
	movl	$102, %edi
	movl	$19, %edx
	movl	$1475, %r8d
	callq	__d_assert_msg
	.cfi_endproc

	.globl	__D3mir7ndslice5slice17__T5SliceVmi1TPdZ5Slice14__T5emptyVmi0Z5emptyMxFNaNbNdNiNfZb
	.weak_definition	__D3mir7ndslice5slice17__T5SliceVmi1TPdZ5Slice14__T5emptyVmi0Z5emptyMxFNaNbNdNiNfZb
	.align	4, 0x90
__D3mir7ndslice5slice17__T5SliceVmi1TPdZ5Slice14__T5emptyVmi0Z5emptyMxFNaNbNdNiNfZb:
	.cfi_startproc
	cmpq	$0, (%rdi)
	sete	%al
	retq
	.cfi_endproc

	.globl	__D3mir4blas8internal7utility31__T8set_zeroVmi4Vmi1Vmi2TNhG4dZ8set_zeroFNaNbNiNfKG4G1G2NhG4dZv
	.weak_definition	__D3mir4blas8internal7utility31__T8set_zeroVmi4Vmi1Vmi2TNhG4dZ8set_zeroFNaNbNiNfKG4G1G2NhG4dZv
	.align	4, 0x90
__D3mir4blas8internal7utility31__T8set_zeroVmi4Vmi1Vmi2TNhG4dZ8set_zeroFNaNbNiNfKG4G1G2NhG4dZv:
	.cfi_startproc
	vxorps	%ymm0, %ymm0, %ymm0
	vmovaps	%ymm0, 224(%rdi)
	vmovaps	%ymm0, 192(%rdi)
	vmovaps	%ymm0, 160(%rdi)
	vmovaps	%ymm0, 128(%rdi)
	vmovaps	%ymm0, 96(%rdi)
	vmovaps	%ymm0, 64(%rdi)
	vmovaps	%ymm0, 32(%rdi)
	vmovaps	%ymm0, (%rdi)
	vzeroupper
	retq
	.cfi_endproc

	.globl	__D3mir4blas8internal12micro_kernel86__T16gemm_nano_kernelVE3mir4blas8internal12micro_kernel7MulTypei0Vmi1Vmi2Vmi4TNhG4dTdZ16gemm_nano_kernelFNaNbNiKG4G1G2NhG4dMPxG1G2NhG4dPxG1G4dmZPxG1G4d
	.weak_definition	__D3mir4blas8internal12micro_kernel86__T16gemm_nano_kernelVE3mir4blas8internal12micro_kernel7MulTypei0Vmi1Vmi2Vmi4TNhG4dTdZ16gemm_nano_kernelFNaNbNiKG4G1G2NhG4dMPxG1G2NhG4dPxG1G4dmZPxG1G4d
	.align	4, 0x90
__D3mir4blas8internal12micro_kernel86__T16gemm_nano_kernelVE3mir4blas8internal12micro_kernel7MulTypei0Vmi1Vmi2Vmi4TNhG4dTdZ16gemm_nano_kernelFNaNbNiKG4G1G2NhG4dMPxG1G2NhG4dPxG1G4dmZPxG1G4d:
	.cfi_startproc
	vmovapd	(%rcx), %ymm7
	vmovapd	32(%rcx), %ymm6
	vmovapd	64(%rcx), %ymm5
	vmovapd	96(%rcx), %ymm4
	vmovapd	128(%rcx), %ymm3
	vmovapd	160(%rcx), %ymm2
	vmovapd	192(%rcx), %ymm1
	vmovapd	224(%rcx), %ymm0
	movq	%rdi, %rax
	shlq	$5, %rax
	addq	%rsi, %rax
	.align	4, 0x90
LBB74_1:
	vmovapd	(%rdx), %ymm8
	vmovapd	32(%rdx), %ymm9
	vbroadcastsd	(%rsi), %ymm10
	vbroadcastsd	8(%rsi), %ymm11
	vbroadcastsd	16(%rsi), %ymm12
	vbroadcastsd	24(%rsi), %ymm13
	vfmadd231pd	%ymm10, %ymm8, %ymm7
	vfmadd231pd	%ymm10, %ymm9, %ymm6
	vfmadd231pd	%ymm11, %ymm8, %ymm5
	vfmadd231pd	%ymm11, %ymm9, %ymm4
	vfmadd231pd	%ymm12, %ymm8, %ymm3
	vfmadd231pd	%ymm12, %ymm9, %ymm2
	vfmadd231pd	%ymm13, %ymm8, %ymm1
	vfmadd231pd	%ymm13, %ymm9, %ymm0
	addq	$64, %rdx
	addq	$32, %rsi
	addq	$-1, %rdi
	jne	LBB74_1
	vmovapd	%ymm7, (%rcx)
	vmovapd	%ymm6, 32(%rcx)
	vmovapd	%ymm5, 64(%rcx)
	vmovapd	%ymm4, 96(%rcx)
	vmovapd	%ymm3, 128(%rcx)
	vmovapd	%ymm2, 160(%rcx)
	vmovapd	%ymm1, 192(%rcx)
	vmovapd	%ymm0, 224(%rcx)
	vzeroupper
	retq
	.cfi_endproc

	.globl	__D3mir4blas8internal12micro_kernel43__T17scale_nano_kernelVmi1Vmi4Vmi2TNhG4dTdZ17scale_nano_kernelFNaNbNiNfKG4G1G2NhG4dG1dZv
	.weak_definition	__D3mir4blas8internal12micro_kernel43__T17scale_nano_kernelVmi1Vmi4Vmi2TNhG4dTdZ17scale_nano_kernelFNaNbNiNfKG4G1G2NhG4dG1dZv
	.align	4, 0x90
__D3mir4blas8internal12micro_kernel43__T17scale_nano_kernelVmi1Vmi4Vmi2TNhG4dTdZ17scale_nano_kernelFNaNbNiNfKG4G1G2NhG4dG1dZv:
	.cfi_startproc
	vbroadcastsd	%xmm0, %ymm0
	vmulpd	(%rdi), %ymm0, %ymm1
	vmulpd	32(%rdi), %ymm0, %ymm2
	vmulpd	64(%rdi), %ymm0, %ymm3
	vmulpd	96(%rdi), %ymm0, %ymm4
	vmulpd	128(%rdi), %ymm0, %ymm5
	vmulpd	160(%rdi), %ymm0, %ymm6
	vmulpd	192(%rdi), %ymm0, %ymm7
	vmulpd	224(%rdi), %ymm0, %ymm0
	vmovapd	%ymm1, (%rdi)
	vmovapd	%ymm2, 32(%rdi)
	vmovapd	%ymm3, 64(%rdi)
	vmovapd	%ymm4, 96(%rdi)
	vmovapd	%ymm5, 128(%rdi)
	vmovapd	%ymm6, 160(%rdi)
	vmovapd	%ymm7, 192(%rdi)
	vmovapd	%ymm0, 224(%rdi)
	vzeroupper
	retq
	.cfi_endproc

	.globl	__D3mir4blas8internal7utility27__T4loadVmi4Vmi1Vmi2TNhG4dZ4loadFNaNbNiNfKG4G1G2NhG4dKG4G1G2NhG4dZv
	.weak_definition	__D3mir4blas8internal7utility27__T4loadVmi4Vmi1Vmi2TNhG4dZ4loadFNaNbNiNfKG4G1G2NhG4dKG4G1G2NhG4dZv
	.align	4, 0x90
__D3mir4blas8internal7utility27__T4loadVmi4Vmi1Vmi2TNhG4dZ4loadFNaNbNiNfKG4G1G2NhG4dKG4G1G2NhG4dZv:
	.cfi_startproc
	vmovaps	(%rdi), %ymm0
	vmovaps	%ymm0, (%rsi)
	vmovaps	32(%rdi), %ymm0
	vmovaps	%ymm0, 32(%rsi)
	vmovaps	64(%rdi), %ymm0
	vmovaps	%ymm0, 64(%rsi)
	vmovaps	96(%rdi), %ymm0
	vmovaps	%ymm0, 96(%rsi)
	vmovaps	128(%rdi), %ymm0
	vmovaps	%ymm0, 128(%rsi)
	vmovaps	160(%rdi), %ymm0
	vmovaps	%ymm0, 160(%rsi)
	vmovaps	192(%rdi), %ymm0
	vmovaps	%ymm0, 192(%rsi)
	vmovaps	224(%rdi), %ymm0
	vmovaps	%ymm0, 224(%rsi)
	vzeroupper
	retq
	.cfi_endproc

	.globl	__D3mir4blas8internal7utility21__T4loadVmi1TNhG4dTdZ4loadFNaNbNiNfKG1NhG4dKxG1dZv
	.weak_definition	__D3mir4blas8internal7utility21__T4loadVmi1TNhG4dTdZ4loadFNaNbNiNfKG1NhG4dKxG1dZv
	.align	4, 0x90
__D3mir4blas8internal7utility21__T4loadVmi1TNhG4dTdZ4loadFNaNbNiNfKG1NhG4dKxG1dZv:
	.cfi_startproc
	vbroadcastsd	(%rdi), %ymm0
	vmovaps	%ymm0, (%rsi)
	vzeroupper
	retq
	.cfi_endproc

	.globl	__D3mir4blas8internal7utility31__T8set_zeroVmi2Vmi1Vmi2TNhG4dZ8set_zeroFNaNbNiNfKG2G1G2NhG4dZv
	.weak_definition	__D3mir4blas8internal7utility31__T8set_zeroVmi2Vmi1Vmi2TNhG4dZ8set_zeroFNaNbNiNfKG2G1G2NhG4dZv
	.align	4, 0x90
__D3mir4blas8internal7utility31__T8set_zeroVmi2Vmi1Vmi2TNhG4dZ8set_zeroFNaNbNiNfKG2G1G2NhG4dZv:
	.cfi_startproc
	vxorps	%ymm0, %ymm0, %ymm0
	vmovaps	%ymm0, 96(%rdi)
	vmovaps	%ymm0, 64(%rdi)
	vmovaps	%ymm0, 32(%rdi)
	vmovaps	%ymm0, (%rdi)
	vzeroupper
	retq
	.cfi_endproc

	.globl	__D3mir4blas8internal12micro_kernel86__T16gemm_nano_kernelVE3mir4blas8internal12micro_kernel7MulTypei0Vmi1Vmi2Vmi2TNhG4dTdZ16gemm_nano_kernelFNaNbNiKG2G1G2NhG4dMPxG1G2NhG4dPxG1G2dmZPxG1G2d
	.weak_definition	__D3mir4blas8internal12micro_kernel86__T16gemm_nano_kernelVE3mir4blas8internal12micro_kernel7MulTypei0Vmi1Vmi2Vmi2TNhG4dTdZ16gemm_nano_kernelFNaNbNiKG2G1G2NhG4dMPxG1G2NhG4dPxG1G2dmZPxG1G2d
	.align	4, 0x90
__D3mir4blas8internal12micro_kernel86__T16gemm_nano_kernelVE3mir4blas8internal12micro_kernel7MulTypei0Vmi1Vmi2Vmi2TNhG4dTdZ16gemm_nano_kernelFNaNbNiKG2G1G2NhG4dMPxG1G2NhG4dPxG1G2dmZPxG1G2d:
	.cfi_startproc
	vmovapd	(%rcx), %ymm3
	vmovapd	32(%rcx), %ymm2
	vmovapd	64(%rcx), %ymm1
	vmovapd	96(%rcx), %ymm0
	movq	%rdi, %rax
	shlq	$4, %rax
	addq	%rsi, %rax
	.align	4, 0x90
LBB79_1:
	vmovapd	(%rdx), %ymm4
	vmovapd	32(%rdx), %ymm5
	vbroadcastsd	(%rsi), %ymm6
	vbroadcastsd	8(%rsi), %ymm7
	vfmadd231pd	%ymm6, %ymm4, %ymm3
	vfmadd231pd	%ymm6, %ymm5, %ymm2
	vfmadd231pd	%ymm7, %ymm4, %ymm1
	vfmadd231pd	%ymm7, %ymm5, %ymm0
	addq	$64, %rdx
	addq	$16, %rsi
	addq	$-1, %rdi
	jne	LBB79_1
	vmovapd	%ymm3, (%rcx)
	vmovapd	%ymm2, 32(%rcx)
	vmovapd	%ymm1, 64(%rcx)
	vmovapd	%ymm0, 96(%rcx)
	vzeroupper
	retq
	.cfi_endproc

	.globl	__D3mir4blas8internal12micro_kernel43__T17scale_nano_kernelVmi1Vmi2Vmi2TNhG4dTdZ17scale_nano_kernelFNaNbNiNfKG2G1G2NhG4dG1dZv
	.weak_definition	__D3mir4blas8internal12micro_kernel43__T17scale_nano_kernelVmi1Vmi2Vmi2TNhG4dTdZ17scale_nano_kernelFNaNbNiNfKG2G1G2NhG4dG1dZv
	.align	4, 0x90
__D3mir4blas8internal12micro_kernel43__T17scale_nano_kernelVmi1Vmi2Vmi2TNhG4dTdZ17scale_nano_kernelFNaNbNiNfKG2G1G2NhG4dG1dZv:
	.cfi_startproc
	vbroadcastsd	%xmm0, %ymm0
	vmulpd	(%rdi), %ymm0, %ymm1
	vmulpd	32(%rdi), %ymm0, %ymm2
	vmulpd	64(%rdi), %ymm0, %ymm3
	vmulpd	96(%rdi), %ymm0, %ymm0
	vmovapd	%ymm1, (%rdi)
	vmovapd	%ymm2, 32(%rdi)
	vmovapd	%ymm3, 64(%rdi)
	vmovapd	%ymm0, 96(%rdi)
	vzeroupper
	retq
	.cfi_endproc

	.globl	__D3mir4blas8internal7utility27__T4loadVmi2Vmi1Vmi2TNhG4dZ4loadFNaNbNiNfKG2G1G2NhG4dKG2G1G2NhG4dZv
	.weak_definition	__D3mir4blas8internal7utility27__T4loadVmi2Vmi1Vmi2TNhG4dZ4loadFNaNbNiNfKG2G1G2NhG4dKG2G1G2NhG4dZv
	.align	4, 0x90
__D3mir4blas8internal7utility27__T4loadVmi2Vmi1Vmi2TNhG4dZ4loadFNaNbNiNfKG2G1G2NhG4dKG2G1G2NhG4dZv:
	.cfi_startproc
	vmovaps	(%rdi), %ymm0
	vmovaps	%ymm0, (%rsi)
	vmovaps	32(%rdi), %ymm0
	vmovaps	%ymm0, 32(%rsi)
	vmovaps	64(%rdi), %ymm0
	vmovaps	%ymm0, 64(%rsi)
	vmovaps	96(%rdi), %ymm0
	vmovaps	%ymm0, 96(%rsi)
	vzeroupper
	retq
	.cfi_endproc

	.globl	__D3mir4blas8internal7utility31__T8set_zeroVmi1Vmi1Vmi2TNhG4dZ8set_zeroFNaNbNiNfKG1G1G2NhG4dZv
	.weak_definition	__D3mir4blas8internal7utility31__T8set_zeroVmi1Vmi1Vmi2TNhG4dZ8set_zeroFNaNbNiNfKG1G1G2NhG4dZv
	.align	4, 0x90
__D3mir4blas8internal7utility31__T8set_zeroVmi1Vmi1Vmi2TNhG4dZ8set_zeroFNaNbNiNfKG1G1G2NhG4dZv:
	.cfi_startproc
	vxorps	%ymm0, %ymm0, %ymm0
	vmovaps	%ymm0, 32(%rdi)
	vmovaps	%ymm0, (%rdi)
	vzeroupper
	retq
	.cfi_endproc

	.globl	__D3mir4blas8internal12micro_kernel86__T16gemm_nano_kernelVE3mir4blas8internal12micro_kernel7MulTypei0Vmi1Vmi2Vmi1TNhG4dTdZ16gemm_nano_kernelFNaNbNiKG1G1G2NhG4dMPxG1G2NhG4dPxG1G1dmZPxG1G1d
	.weak_definition	__D3mir4blas8internal12micro_kernel86__T16gemm_nano_kernelVE3mir4blas8internal12micro_kernel7MulTypei0Vmi1Vmi2Vmi1TNhG4dTdZ16gemm_nano_kernelFNaNbNiKG1G1G2NhG4dMPxG1G2NhG4dPxG1G1dmZPxG1G1d
	.align	4, 0x90
__D3mir4blas8internal12micro_kernel86__T16gemm_nano_kernelVE3mir4blas8internal12micro_kernel7MulTypei0Vmi1Vmi2Vmi1TNhG4dTdZ16gemm_nano_kernelFNaNbNiKG1G1G2NhG4dMPxG1G2NhG4dPxG1G1dmZPxG1G1d:
	.cfi_startproc
	vmovapd	(%rcx), %ymm1
	vmovapd	32(%rcx), %ymm0
	leaq	(%rsi,%rdi,8), %rax
	.align	4, 0x90
LBB83_1:
	vbroadcastsd	(%rsi), %ymm2
	vfmadd231pd	(%rdx), %ymm2, %ymm1
	vfmadd231pd	32(%rdx), %ymm2, %ymm0
	addq	$8, %rsi
	addq	$64, %rdx
	addq	$-1, %rdi
	jne	LBB83_1
	vmovapd	%ymm1, (%rcx)
	vmovapd	%ymm0, 32(%rcx)
	vzeroupper
	retq
	.cfi_endproc

	.globl	__D3mir4blas8internal12micro_kernel43__T17scale_nano_kernelVmi1Vmi1Vmi2TNhG4dTdZ17scale_nano_kernelFNaNbNiNfKG1G1G2NhG4dG1dZv
	.weak_definition	__D3mir4blas8internal12micro_kernel43__T17scale_nano_kernelVmi1Vmi1Vmi2TNhG4dTdZ17scale_nano_kernelFNaNbNiNfKG1G1G2NhG4dG1dZv
	.align	4, 0x90
__D3mir4blas8internal12micro_kernel43__T17scale_nano_kernelVmi1Vmi1Vmi2TNhG4dTdZ17scale_nano_kernelFNaNbNiNfKG1G1G2NhG4dG1dZv:
	.cfi_startproc
	vbroadcastsd	%xmm0, %ymm0
	vmulpd	(%rdi), %ymm0, %ymm1
	vmulpd	32(%rdi), %ymm0, %ymm0
	vmovapd	%ymm1, (%rdi)
	vmovapd	%ymm0, 32(%rdi)
	vzeroupper
	retq
	.cfi_endproc

	.globl	__D3mir4blas8internal7utility27__T4loadVmi1Vmi1Vmi2TNhG4dZ4loadFNaNbNiNfKG1G1G2NhG4dKG1G1G2NhG4dZv
	.weak_definition	__D3mir4blas8internal7utility27__T4loadVmi1Vmi1Vmi2TNhG4dZ4loadFNaNbNiNfKG1G1G2NhG4dKG1G1G2NhG4dZv
	.align	4, 0x90
__D3mir4blas8internal7utility27__T4loadVmi1Vmi1Vmi2TNhG4dZ4loadFNaNbNiNfKG1G1G2NhG4dKG1G1G2NhG4dZv:
	.cfi_startproc
	vmovaps	(%rdi), %ymm0
	vmovaps	%ymm0, (%rsi)
	vmovaps	32(%rdi), %ymm0
	vmovaps	%ymm0, 32(%rsi)
	vzeroupper
	retq
	.cfi_endproc

	.globl	__D3mir4blas8internal7utility31__T8set_zeroVmi4Vmi1Vmi1TNhG4dZ8set_zeroFNaNbNiNfKG4G1G1NhG4dZv
	.weak_definition	__D3mir4blas8internal7utility31__T8set_zeroVmi4Vmi1Vmi1TNhG4dZ8set_zeroFNaNbNiNfKG4G1G1NhG4dZv
	.align	4, 0x90
__D3mir4blas8internal7utility31__T8set_zeroVmi4Vmi1Vmi1TNhG4dZ8set_zeroFNaNbNiNfKG4G1G1NhG4dZv:
	.cfi_startproc
	vxorps	%ymm0, %ymm0, %ymm0
	vmovaps	%ymm0, 96(%rdi)
	vmovaps	%ymm0, 64(%rdi)
	vmovaps	%ymm0, 32(%rdi)
	vmovaps	%ymm0, (%rdi)
	vzeroupper
	retq
	.cfi_endproc

	.globl	__D3mir4blas8internal12micro_kernel86__T16gemm_nano_kernelVE3mir4blas8internal12micro_kernel7MulTypei0Vmi1Vmi1Vmi4TNhG4dTdZ16gemm_nano_kernelFNaNbNiKG4G1G1NhG4dMPxG1G1NhG4dPxG1G4dmZPxG1G4d
	.weak_definition	__D3mir4blas8internal12micro_kernel86__T16gemm_nano_kernelVE3mir4blas8internal12micro_kernel7MulTypei0Vmi1Vmi1Vmi4TNhG4dTdZ16gemm_nano_kernelFNaNbNiKG4G1G1NhG4dMPxG1G1NhG4dPxG1G4dmZPxG1G4d
	.align	4, 0x90
__D3mir4blas8internal12micro_kernel86__T16gemm_nano_kernelVE3mir4blas8internal12micro_kernel7MulTypei0Vmi1Vmi1Vmi4TNhG4dTdZ16gemm_nano_kernelFNaNbNiKG4G1G1NhG4dMPxG1G1NhG4dPxG1G4dmZPxG1G4d:
	.cfi_startproc
	vmovapd	(%rcx), %ymm3
	vmovapd	32(%rcx), %ymm2
	vmovapd	64(%rcx), %ymm1
	vmovapd	96(%rcx), %ymm0
	movq	%rdi, %rax
	shlq	$5, %rax
	addq	%rsi, %rax
	.align	4, 0x90
LBB87_1:
	vmovapd	(%rdx), %ymm4
	vbroadcastsd	(%rsi), %ymm5
	vbroadcastsd	8(%rsi), %ymm6
	vbroadcastsd	16(%rsi), %ymm7
	vbroadcastsd	24(%rsi), %ymm8
	vfmadd231pd	%ymm5, %ymm4, %ymm3
	vfmadd231pd	%ymm6, %ymm4, %ymm2
	vfmadd231pd	%ymm7, %ymm4, %ymm1
	vfmadd231pd	%ymm8, %ymm4, %ymm0
	addq	$32, %rdx
	addq	$32, %rsi
	addq	$-1, %rdi
	jne	LBB87_1
	vmovapd	%ymm3, (%rcx)
	vmovapd	%ymm2, 32(%rcx)
	vmovapd	%ymm1, 64(%rcx)
	vmovapd	%ymm0, 96(%rcx)
	vzeroupper
	retq
	.cfi_endproc

	.globl	__D3mir4blas8internal12micro_kernel43__T17scale_nano_kernelVmi1Vmi4Vmi1TNhG4dTdZ17scale_nano_kernelFNaNbNiNfKG4G1G1NhG4dG1dZv
	.weak_definition	__D3mir4blas8internal12micro_kernel43__T17scale_nano_kernelVmi1Vmi4Vmi1TNhG4dTdZ17scale_nano_kernelFNaNbNiNfKG4G1G1NhG4dG1dZv
	.align	4, 0x90
__D3mir4blas8internal12micro_kernel43__T17scale_nano_kernelVmi1Vmi4Vmi1TNhG4dTdZ17scale_nano_kernelFNaNbNiNfKG4G1G1NhG4dG1dZv:
	.cfi_startproc
	vbroadcastsd	%xmm0, %ymm0
	vmulpd	(%rdi), %ymm0, %ymm1
	vmulpd	32(%rdi), %ymm0, %ymm2
	vmulpd	64(%rdi), %ymm0, %ymm3
	vmulpd	96(%rdi), %ymm0, %ymm0
	vmovapd	%ymm1, (%rdi)
	vmovapd	%ymm2, 32(%rdi)
	vmovapd	%ymm3, 64(%rdi)
	vmovapd	%ymm0, 96(%rdi)
	vzeroupper
	retq
	.cfi_endproc

	.globl	__D3mir4blas8internal7utility27__T4loadVmi4Vmi1Vmi1TNhG4dZ4loadFNaNbNiNfKG4G1G1NhG4dKG4G1G1NhG4dZv
	.weak_definition	__D3mir4blas8internal7utility27__T4loadVmi4Vmi1Vmi1TNhG4dZ4loadFNaNbNiNfKG4G1G1NhG4dKG4G1G1NhG4dZv
	.align	4, 0x90
__D3mir4blas8internal7utility27__T4loadVmi4Vmi1Vmi1TNhG4dZ4loadFNaNbNiNfKG4G1G1NhG4dKG4G1G1NhG4dZv:
	.cfi_startproc
	vmovaps	(%rdi), %ymm0
	vmovaps	%ymm0, (%rsi)
	vmovaps	32(%rdi), %ymm0
	vmovaps	%ymm0, 32(%rsi)
	vmovaps	64(%rdi), %ymm0
	vmovaps	%ymm0, 64(%rsi)
	vmovaps	96(%rdi), %ymm0
	vmovaps	%ymm0, 96(%rsi)
	vzeroupper
	retq
	.cfi_endproc

	.globl	__D3mir4blas8internal7utility31__T8set_zeroVmi2Vmi1Vmi1TNhG4dZ8set_zeroFNaNbNiNfKG2G1G1NhG4dZv
	.weak_definition	__D3mir4blas8internal7utility31__T8set_zeroVmi2Vmi1Vmi1TNhG4dZ8set_zeroFNaNbNiNfKG2G1G1NhG4dZv
	.align	4, 0x90
__D3mir4blas8internal7utility31__T8set_zeroVmi2Vmi1Vmi1TNhG4dZ8set_zeroFNaNbNiNfKG2G1G1NhG4dZv:
	.cfi_startproc
	vxorps	%ymm0, %ymm0, %ymm0
	vmovaps	%ymm0, 32(%rdi)
	vmovaps	%ymm0, (%rdi)
	vzeroupper
	retq
	.cfi_endproc

	.globl	__D3mir4blas8internal12micro_kernel86__T16gemm_nano_kernelVE3mir4blas8internal12micro_kernel7MulTypei0Vmi1Vmi1Vmi2TNhG4dTdZ16gemm_nano_kernelFNaNbNiKG2G1G1NhG4dMPxG1G1NhG4dPxG1G2dmZPxG1G2d
	.weak_definition	__D3mir4blas8internal12micro_kernel86__T16gemm_nano_kernelVE3mir4blas8internal12micro_kernel7MulTypei0Vmi1Vmi1Vmi2TNhG4dTdZ16gemm_nano_kernelFNaNbNiKG2G1G1NhG4dMPxG1G1NhG4dPxG1G2dmZPxG1G2d
	.align	4, 0x90
__D3mir4blas8internal12micro_kernel86__T16gemm_nano_kernelVE3mir4blas8internal12micro_kernel7MulTypei0Vmi1Vmi1Vmi2TNhG4dTdZ16gemm_nano_kernelFNaNbNiKG2G1G1NhG4dMPxG1G1NhG4dPxG1G2dmZPxG1G2d:
	.cfi_startproc
	vmovapd	(%rcx), %ymm1
	vmovapd	32(%rcx), %ymm0
	movq	%rdi, %rax
	shlq	$4, %rax
	addq	%rsi, %rax
	.align	4, 0x90
LBB91_1:
	vmovapd	(%rdx), %ymm2
	vbroadcastsd	(%rsi), %ymm3
	vbroadcastsd	8(%rsi), %ymm4
	vfmadd231pd	%ymm3, %ymm2, %ymm1
	vfmadd231pd	%ymm4, %ymm2, %ymm0
	addq	$32, %rdx
	addq	$16, %rsi
	addq	$-1, %rdi
	jne	LBB91_1
	vmovapd	%ymm1, (%rcx)
	vmovapd	%ymm0, 32(%rcx)
	vzeroupper
	retq
	.cfi_endproc

	.globl	__D3mir4blas8internal12micro_kernel43__T17scale_nano_kernelVmi1Vmi2Vmi1TNhG4dTdZ17scale_nano_kernelFNaNbNiNfKG2G1G1NhG4dG1dZv
	.weak_definition	__D3mir4blas8internal12micro_kernel43__T17scale_nano_kernelVmi1Vmi2Vmi1TNhG4dTdZ17scale_nano_kernelFNaNbNiNfKG2G1G1NhG4dG1dZv
	.align	4, 0x90
__D3mir4blas8internal12micro_kernel43__T17scale_nano_kernelVmi1Vmi2Vmi1TNhG4dTdZ17scale_nano_kernelFNaNbNiNfKG2G1G1NhG4dG1dZv:
	.cfi_startproc
	vbroadcastsd	%xmm0, %ymm0
	vmulpd	(%rdi), %ymm0, %ymm1
	vmulpd	32(%rdi), %ymm0, %ymm0
	vmovapd	%ymm1, (%rdi)
	vmovapd	%ymm0, 32(%rdi)
	vzeroupper
	retq
	.cfi_endproc

	.globl	__D3mir4blas8internal7utility27__T4loadVmi2Vmi1Vmi1TNhG4dZ4loadFNaNbNiNfKG2G1G1NhG4dKG2G1G1NhG4dZv
	.weak_definition	__D3mir4blas8internal7utility27__T4loadVmi2Vmi1Vmi1TNhG4dZ4loadFNaNbNiNfKG2G1G1NhG4dKG2G1G1NhG4dZv
	.align	4, 0x90
__D3mir4blas8internal7utility27__T4loadVmi2Vmi1Vmi1TNhG4dZ4loadFNaNbNiNfKG2G1G1NhG4dKG2G1G1NhG4dZv:
	.cfi_startproc
	vmovaps	(%rdi), %ymm0
	vmovaps	%ymm0, (%rsi)
	vmovaps	32(%rdi), %ymm0
	vmovaps	%ymm0, 32(%rsi)
	vzeroupper
	retq
	.cfi_endproc

	.globl	__D3mir4blas8internal7utility31__T8set_zeroVmi1Vmi1Vmi1TNhG4dZ8set_zeroFNaNbNiNfKG1G1G1NhG4dZv
	.weak_definition	__D3mir4blas8internal7utility31__T8set_zeroVmi1Vmi1Vmi1TNhG4dZ8set_zeroFNaNbNiNfKG1G1G1NhG4dZv
	.align	4, 0x90
__D3mir4blas8internal7utility31__T8set_zeroVmi1Vmi1Vmi1TNhG4dZ8set_zeroFNaNbNiNfKG1G1G1NhG4dZv:
	.cfi_startproc
	vxorps	%ymm0, %ymm0, %ymm0
	vmovaps	%ymm0, (%rdi)
	vzeroupper
	retq
	.cfi_endproc

	.globl	__D3mir4blas8internal12micro_kernel86__T16gemm_nano_kernelVE3mir4blas8internal12micro_kernel7MulTypei0Vmi1Vmi1Vmi1TNhG4dTdZ16gemm_nano_kernelFNaNbNiKG1G1G1NhG4dMPxG1G1NhG4dPxG1G1dmZPxG1G1d
	.weak_definition	__D3mir4blas8internal12micro_kernel86__T16gemm_nano_kernelVE3mir4blas8internal12micro_kernel7MulTypei0Vmi1Vmi1Vmi1TNhG4dTdZ16gemm_nano_kernelFNaNbNiKG1G1G1NhG4dMPxG1G1NhG4dPxG1G1dmZPxG1G1d
	.align	4, 0x90
__D3mir4blas8internal12micro_kernel86__T16gemm_nano_kernelVE3mir4blas8internal12micro_kernel7MulTypei0Vmi1Vmi1Vmi1TNhG4dTdZ16gemm_nano_kernelFNaNbNiKG1G1G1NhG4dMPxG1G1NhG4dPxG1G1dmZPxG1G1d:
	.cfi_startproc
	vmovapd	(%rcx), %ymm0
	leaq	(%rsi,%rdi,8), %rax
	.align	4, 0x90
LBB95_1:
	vbroadcastsd	(%rsi), %ymm1
	vfmadd231pd	(%rdx), %ymm1, %ymm0
	addq	$32, %rdx
	addq	$8, %rsi
	addq	$-1, %rdi
	jne	LBB95_1
	vmovapd	%ymm0, (%rcx)
	vzeroupper
	retq
	.cfi_endproc

	.globl	__D3mir4blas8internal12micro_kernel43__T17scale_nano_kernelVmi1Vmi1Vmi1TNhG4dTdZ17scale_nano_kernelFNaNbNiNfKG1G1G1NhG4dG1dZv
	.weak_definition	__D3mir4blas8internal12micro_kernel43__T17scale_nano_kernelVmi1Vmi1Vmi1TNhG4dTdZ17scale_nano_kernelFNaNbNiNfKG1G1G1NhG4dG1dZv
	.align	4, 0x90
__D3mir4blas8internal12micro_kernel43__T17scale_nano_kernelVmi1Vmi1Vmi1TNhG4dTdZ17scale_nano_kernelFNaNbNiNfKG1G1G1NhG4dG1dZv:
	.cfi_startproc
	vbroadcastsd	%xmm0, %ymm0
	vmulpd	(%rdi), %ymm0, %ymm0
	vmovapd	%ymm0, (%rdi)
	vzeroupper
	retq
	.cfi_endproc

	.globl	__D3mir4blas8internal7utility27__T4loadVmi1Vmi1Vmi1TNhG4dZ4loadFNaNbNiNfKG1G1G1NhG4dKG1G1G1NhG4dZv
	.weak_definition	__D3mir4blas8internal7utility27__T4loadVmi1Vmi1Vmi1TNhG4dZ4loadFNaNbNiNfKG1G1G1NhG4dKG1G1G1NhG4dZv
	.align	4, 0x90
__D3mir4blas8internal7utility27__T4loadVmi1Vmi1Vmi1TNhG4dZ4loadFNaNbNiNfKG1G1G1NhG4dKG1G1G1NhG4dZv:
	.cfi_startproc
	vmovaps	(%rdi), %ymm0
	vmovaps	%ymm0, (%rsi)
	vzeroupper
	retq
	.cfi_endproc

	.globl	__D3mir4blas8internal7utility31__T8set_zeroVmi4Vmi1Vmi1TNhG2dZ8set_zeroFNaNbNiNfKG4G1G1NhG2dZv
	.weak_definition	__D3mir4blas8internal7utility31__T8set_zeroVmi4Vmi1Vmi1TNhG2dZ8set_zeroFNaNbNiNfKG4G1G1NhG2dZv
	.align	4, 0x90
__D3mir4blas8internal7utility31__T8set_zeroVmi4Vmi1Vmi1TNhG2dZ8set_zeroFNaNbNiNfKG4G1G1NhG2dZv:
	.cfi_startproc
	vxorps	%ymm0, %ymm0, %ymm0
	vmovups	%ymm0, 32(%rdi)
	vmovups	%ymm0, (%rdi)
	vzeroupper
	retq
	.cfi_endproc

	.globl	__D3mir4blas8internal12micro_kernel86__T16gemm_nano_kernelVE3mir4blas8internal12micro_kernel7MulTypei0Vmi1Vmi1Vmi4TNhG2dTdZ16gemm_nano_kernelFNaNbNiKG4G1G1NhG2dMPxG1G1NhG2dPxG1G4dmZPxG1G4d
	.weak_definition	__D3mir4blas8internal12micro_kernel86__T16gemm_nano_kernelVE3mir4blas8internal12micro_kernel7MulTypei0Vmi1Vmi1Vmi4TNhG2dTdZ16gemm_nano_kernelFNaNbNiKG4G1G1NhG2dMPxG1G1NhG2dPxG1G4dmZPxG1G4d
	.align	4, 0x90
__D3mir4blas8internal12micro_kernel86__T16gemm_nano_kernelVE3mir4blas8internal12micro_kernel7MulTypei0Vmi1Vmi1Vmi4TNhG2dTdZ16gemm_nano_kernelFNaNbNiKG4G1G1NhG2dMPxG1G1NhG2dPxG1G4dmZPxG1G4d:
	.cfi_startproc
	vmovapd	(%rcx), %xmm3
	vmovapd	16(%rcx), %xmm2
	vmovapd	32(%rcx), %xmm1
	vmovapd	48(%rcx), %xmm0
	movq	%rdi, %rax
	shlq	$5, %rax
	addq	%rsi, %rax
	.align	4, 0x90
LBB99_1:
	vmovapd	(%rdx), %xmm4
	vmovddup	(%rsi), %xmm5
	vmovddup	8(%rsi), %xmm6
	vmovddup	16(%rsi), %xmm7
	vmovddup	24(%rsi), %xmm8
	vfmadd231pd	%xmm5, %xmm4, %xmm3
	vfmadd231pd	%xmm6, %xmm4, %xmm2
	vfmadd231pd	%xmm7, %xmm4, %xmm1
	vfmadd231pd	%xmm8, %xmm4, %xmm0
	addq	$16, %rdx
	addq	$32, %rsi
	addq	$-1, %rdi
	jne	LBB99_1
	vmovapd	%xmm3, (%rcx)
	vmovapd	%xmm2, 16(%rcx)
	vmovapd	%xmm1, 32(%rcx)
	vmovapd	%xmm0, 48(%rcx)
	retq
	.cfi_endproc

	.globl	__D3mir4blas8internal12micro_kernel43__T17scale_nano_kernelVmi1Vmi4Vmi1TNhG2dTdZ17scale_nano_kernelFNaNbNiNfKG4G1G1NhG2dG1dZv
	.weak_definition	__D3mir4blas8internal12micro_kernel43__T17scale_nano_kernelVmi1Vmi4Vmi1TNhG2dTdZ17scale_nano_kernelFNaNbNiNfKG4G1G1NhG2dG1dZv
	.align	4, 0x90
__D3mir4blas8internal12micro_kernel43__T17scale_nano_kernelVmi1Vmi4Vmi1TNhG2dTdZ17scale_nano_kernelFNaNbNiNfKG4G1G1NhG2dG1dZv:
	.cfi_startproc
	vunpcklpd	%xmm0, %xmm0, %xmm0
	vmulpd	(%rdi), %xmm0, %xmm1
	vmulpd	16(%rdi), %xmm0, %xmm2
	vmulpd	32(%rdi), %xmm0, %xmm3
	vmulpd	48(%rdi), %xmm0, %xmm0
	vmovapd	%xmm1, (%rdi)
	vmovapd	%xmm2, 16(%rdi)
	vmovapd	%xmm3, 32(%rdi)
	vmovapd	%xmm0, 48(%rdi)
	retq
	.cfi_endproc

	.globl	__D3mir4blas8internal7utility27__T4loadVmi4Vmi1Vmi1TNhG2dZ4loadFNaNbNiNfKG4G1G1NhG2dKG4G1G1NhG2dZv
	.weak_definition	__D3mir4blas8internal7utility27__T4loadVmi4Vmi1Vmi1TNhG2dZ4loadFNaNbNiNfKG4G1G1NhG2dKG4G1G1NhG2dZv
	.align	4, 0x90
__D3mir4blas8internal7utility27__T4loadVmi4Vmi1Vmi1TNhG2dZ4loadFNaNbNiNfKG4G1G1NhG2dKG4G1G1NhG2dZv:
	.cfi_startproc
	vmovaps	(%rdi), %xmm0
	vmovaps	%xmm0, (%rsi)
	vmovaps	16(%rdi), %xmm0
	vmovaps	%xmm0, 16(%rsi)
	vmovaps	32(%rdi), %xmm0
	vmovaps	%xmm0, 32(%rsi)
	vmovaps	48(%rdi), %xmm0
	vmovaps	%xmm0, 48(%rsi)
	retq
	.cfi_endproc

	.globl	__D3mir4blas8internal7utility21__T4loadVmi1TNhG2dTdZ4loadFNaNbNiNfKG1NhG2dKxG1dZv
	.weak_definition	__D3mir4blas8internal7utility21__T4loadVmi1TNhG2dTdZ4loadFNaNbNiNfKG1NhG2dKxG1dZv
	.align	4, 0x90
__D3mir4blas8internal7utility21__T4loadVmi1TNhG2dTdZ4loadFNaNbNiNfKG1NhG2dKxG1dZv:
	.cfi_startproc
	vmovddup	(%rdi), %xmm0
	vmovapd	%xmm0, (%rsi)
	retq
	.cfi_endproc

	.globl	__D3mir4blas8internal7utility31__T8set_zeroVmi2Vmi1Vmi1TNhG2dZ8set_zeroFNaNbNiNfKG2G1G1NhG2dZv
	.weak_definition	__D3mir4blas8internal7utility31__T8set_zeroVmi2Vmi1Vmi1TNhG2dZ8set_zeroFNaNbNiNfKG2G1G1NhG2dZv
	.align	4, 0x90
__D3mir4blas8internal7utility31__T8set_zeroVmi2Vmi1Vmi1TNhG2dZ8set_zeroFNaNbNiNfKG2G1G1NhG2dZv:
	.cfi_startproc
	vxorps	%ymm0, %ymm0, %ymm0
	vmovups	%ymm0, (%rdi)
	vzeroupper
	retq
	.cfi_endproc

	.globl	__D3mir4blas8internal12micro_kernel86__T16gemm_nano_kernelVE3mir4blas8internal12micro_kernel7MulTypei0Vmi1Vmi1Vmi2TNhG2dTdZ16gemm_nano_kernelFNaNbNiKG2G1G1NhG2dMPxG1G1NhG2dPxG1G2dmZPxG1G2d
	.weak_definition	__D3mir4blas8internal12micro_kernel86__T16gemm_nano_kernelVE3mir4blas8internal12micro_kernel7MulTypei0Vmi1Vmi1Vmi2TNhG2dTdZ16gemm_nano_kernelFNaNbNiKG2G1G1NhG2dMPxG1G1NhG2dPxG1G2dmZPxG1G2d
	.align	4, 0x90
__D3mir4blas8internal12micro_kernel86__T16gemm_nano_kernelVE3mir4blas8internal12micro_kernel7MulTypei0Vmi1Vmi1Vmi2TNhG2dTdZ16gemm_nano_kernelFNaNbNiKG2G1G1NhG2dMPxG1G1NhG2dPxG1G2dmZPxG1G2d:
	.cfi_startproc
	vmovapd	(%rcx), %xmm1
	vmovapd	16(%rcx), %xmm0
	movq	%rdi, %rax
	shlq	$4, %rax
	addq	%rsi, %rax
	.align	4, 0x90
LBB104_1:
	vmovapd	(%rdx), %xmm2
	vmovddup	(%rsi), %xmm3
	vmovddup	8(%rsi), %xmm4
	vfmadd231pd	%xmm3, %xmm2, %xmm1
	vfmadd231pd	%xmm4, %xmm2, %xmm0
	addq	$16, %rdx
	addq	$16, %rsi
	addq	$-1, %rdi
	jne	LBB104_1
	vmovapd	%xmm1, (%rcx)
	vmovapd	%xmm0, 16(%rcx)
	retq
	.cfi_endproc

	.globl	__D3mir4blas8internal12micro_kernel43__T17scale_nano_kernelVmi1Vmi2Vmi1TNhG2dTdZ17scale_nano_kernelFNaNbNiNfKG2G1G1NhG2dG1dZv
	.weak_definition	__D3mir4blas8internal12micro_kernel43__T17scale_nano_kernelVmi1Vmi2Vmi1TNhG2dTdZ17scale_nano_kernelFNaNbNiNfKG2G1G1NhG2dG1dZv
	.align	4, 0x90
__D3mir4blas8internal12micro_kernel43__T17scale_nano_kernelVmi1Vmi2Vmi1TNhG2dTdZ17scale_nano_kernelFNaNbNiNfKG2G1G1NhG2dG1dZv:
	.cfi_startproc
	vunpcklpd	%xmm0, %xmm0, %xmm0
	vmulpd	(%rdi), %xmm0, %xmm1
	vmulpd	16(%rdi), %xmm0, %xmm0
	vmovapd	%xmm1, (%rdi)
	vmovapd	%xmm0, 16(%rdi)
	retq
	.cfi_endproc

	.globl	__D3mir4blas8internal7utility27__T4loadVmi2Vmi1Vmi1TNhG2dZ4loadFNaNbNiNfKG2G1G1NhG2dKG2G1G1NhG2dZv
	.weak_definition	__D3mir4blas8internal7utility27__T4loadVmi2Vmi1Vmi1TNhG2dZ4loadFNaNbNiNfKG2G1G1NhG2dKG2G1G1NhG2dZv
	.align	4, 0x90
__D3mir4blas8internal7utility27__T4loadVmi2Vmi1Vmi1TNhG2dZ4loadFNaNbNiNfKG2G1G1NhG2dKG2G1G1NhG2dZv:
	.cfi_startproc
	vmovaps	(%rdi), %xmm0
	vmovaps	%xmm0, (%rsi)
	vmovaps	16(%rdi), %xmm0
	vmovaps	%xmm0, 16(%rsi)
	retq
	.cfi_endproc

	.globl	__D3mir4blas8internal7utility31__T8set_zeroVmi1Vmi1Vmi1TNhG2dZ8set_zeroFNaNbNiNfKG1G1G1NhG2dZv
	.weak_definition	__D3mir4blas8internal7utility31__T8set_zeroVmi1Vmi1Vmi1TNhG2dZ8set_zeroFNaNbNiNfKG1G1G1NhG2dZv
	.align	4, 0x90
__D3mir4blas8internal7utility31__T8set_zeroVmi1Vmi1Vmi1TNhG2dZ8set_zeroFNaNbNiNfKG1G1G1NhG2dZv:
	.cfi_startproc
	vxorps	%xmm0, %xmm0, %xmm0
	vmovaps	%xmm0, (%rdi)
	retq
	.cfi_endproc

	.globl	__D3mir4blas8internal12micro_kernel86__T16gemm_nano_kernelVE3mir4blas8internal12micro_kernel7MulTypei0Vmi1Vmi1Vmi1TNhG2dTdZ16gemm_nano_kernelFNaNbNiKG1G1G1NhG2dMPxG1G1NhG2dPxG1G1dmZPxG1G1d
	.weak_definition	__D3mir4blas8internal12micro_kernel86__T16gemm_nano_kernelVE3mir4blas8internal12micro_kernel7MulTypei0Vmi1Vmi1Vmi1TNhG2dTdZ16gemm_nano_kernelFNaNbNiKG1G1G1NhG2dMPxG1G1NhG2dPxG1G1dmZPxG1G1d
	.align	4, 0x90
__D3mir4blas8internal12micro_kernel86__T16gemm_nano_kernelVE3mir4blas8internal12micro_kernel7MulTypei0Vmi1Vmi1Vmi1TNhG2dTdZ16gemm_nano_kernelFNaNbNiKG1G1G1NhG2dMPxG1G1NhG2dPxG1G1dmZPxG1G1d:
	.cfi_startproc
	vmovapd	(%rcx), %xmm0
	leaq	(%rsi,%rdi,8), %rax
	.align	4, 0x90
LBB108_1:
	vmovddup	(%rsi), %xmm1
	vfmadd231pd	(%rdx), %xmm1, %xmm0
	addq	$16, %rdx
	addq	$8, %rsi
	addq	$-1, %rdi
	jne	LBB108_1
	vmovapd	%xmm0, (%rcx)
	retq
	.cfi_endproc

	.globl	__D3mir4blas8internal12micro_kernel43__T17scale_nano_kernelVmi1Vmi1Vmi1TNhG2dTdZ17scale_nano_kernelFNaNbNiNfKG1G1G1NhG2dG1dZv
	.weak_definition	__D3mir4blas8internal12micro_kernel43__T17scale_nano_kernelVmi1Vmi1Vmi1TNhG2dTdZ17scale_nano_kernelFNaNbNiNfKG1G1G1NhG2dG1dZv
	.align	4, 0x90
__D3mir4blas8internal12micro_kernel43__T17scale_nano_kernelVmi1Vmi1Vmi1TNhG2dTdZ17scale_nano_kernelFNaNbNiNfKG1G1G1NhG2dG1dZv:
	.cfi_startproc
	vunpcklpd	%xmm0, %xmm0, %xmm0
	vmulpd	(%rdi), %xmm0, %xmm0
	vmovapd	%xmm0, (%rdi)
	retq
	.cfi_endproc

	.globl	__D3mir4blas8internal7utility27__T4loadVmi1Vmi1Vmi1TNhG2dZ4loadFNaNbNiNfKG1G1G1NhG2dKG1G1G1NhG2dZv
	.weak_definition	__D3mir4blas8internal7utility27__T4loadVmi1Vmi1Vmi1TNhG2dZ4loadFNaNbNiNfKG1G1G1NhG2dKG1G1G1NhG2dZv
	.align	4, 0x90
__D3mir4blas8internal7utility27__T4loadVmi1Vmi1Vmi1TNhG2dZ4loadFNaNbNiNfKG1G1G1NhG2dKG1G1G1NhG2dZv:
	.cfi_startproc
	vmovaps	(%rdi), %xmm0
	vmovaps	%xmm0, (%rsi)
	retq
	.cfi_endproc

	.globl	__D3mir4blas8internal7utility27__T8set_zeroVmi4Vmi1Vmi1TdZ8set_zeroFNaNbNiNfKG4G1G1dZv
	.weak_definition	__D3mir4blas8internal7utility27__T8set_zeroVmi4Vmi1Vmi1TdZ8set_zeroFNaNbNiNfKG4G1G1dZv
	.align	4, 0x90
__D3mir4blas8internal7utility27__T8set_zeroVmi4Vmi1Vmi1TdZ8set_zeroFNaNbNiNfKG4G1G1dZv:
	.cfi_startproc
	vxorps	%ymm0, %ymm0, %ymm0
	vmovups	%ymm0, (%rdi)
	vzeroupper
	retq
	.cfi_endproc

	.globl	__D3mir4blas8internal12micro_kernel82__T16gemm_nano_kernelVE3mir4blas8internal12micro_kernel7MulTypei0Vmi1Vmi1Vmi4TdTdZ16gemm_nano_kernelFNaNbNiKG4G1G1dMPxG1G1dPxG1G4dmZPxG1G4d
	.weak_definition	__D3mir4blas8internal12micro_kernel82__T16gemm_nano_kernelVE3mir4blas8internal12micro_kernel7MulTypei0Vmi1Vmi1Vmi4TdTdZ16gemm_nano_kernelFNaNbNiKG4G1G1dMPxG1G1dPxG1G4dmZPxG1G4d
	.align	4, 0x90
__D3mir4blas8internal12micro_kernel82__T16gemm_nano_kernelVE3mir4blas8internal12micro_kernel7MulTypei0Vmi1Vmi1Vmi4TdTdZ16gemm_nano_kernelFNaNbNiKG4G1G1dMPxG1G1dPxG1G4dmZPxG1G4d:
	.cfi_startproc
	pushq	%rbx
Ltmp50:
	.cfi_def_cfa_offset 16
Ltmp51:
	.cfi_offset %rbx, -16
	vmovupd	(%rcx), %xmm3
	vmovupd	16(%rcx), %xmm1
	movq	%rdi, %rax
	shlq	$5, %rax
	addq	%rsi, %rax
	testq	%rdi, %rdi
	je	LBB112_6
	movq	%rdi, %r8
	andq	$-4, %r8
	movq	%rdi, %r9
	vpermilpd	$1, %xmm1, %xmm0
	vmovq	%xmm0, %xmm0
	vxorpd	%ymm4, %ymm4, %ymm4
	vinsertf128	$0, %xmm0, %ymm4, %ymm8
	vmovq	%xmm1, %xmm1
	vinsertf128	$0, %xmm1, %ymm4, %ymm9
	vpermilpd	$1, %xmm3, %xmm2
	vmovq	%xmm2, %xmm2
	vinsertf128	$0, %xmm2, %ymm4, %ymm2
	vmovq	%xmm3, %xmm3
	vinsertf128	$0, %xmm3, %ymm4, %ymm3
	movq	%rdi, %r10
	andq	$-4, %r9
	je	LBB112_2
	subq	%r8, %r10
	shlq	$5, %r8
	addq	%rsi, %r8
	leaq	(%rdx,%r9,8), %r11
	addq	$120, %rsi
	addq	$24, %rdx
	movq	%r9, %rbx
	.align	4, 0x90
LBB112_4:
	vmovupd	-24(%rdx), %xmm4
	vmovsd	-8(%rdx), %xmm5
	vmovhpd	(%rdx), %xmm5, %xmm5
	vinsertf128	$1, %xmm5, %ymm4, %ymm4
	vmovsd	-56(%rsi), %xmm5
	vmovhpd	-24(%rsi), %xmm5, %xmm5
	vmovsd	-120(%rsi), %xmm6
	vmovsd	-112(%rsi), %xmm7
	vmovhpd	-88(%rsi), %xmm6, %xmm6
	vinsertf128	$1, %xmm5, %ymm6, %ymm5
	vmovsd	-48(%rsi), %xmm6
	vmovhpd	-16(%rsi), %xmm6, %xmm6
	vmovhpd	-80(%rsi), %xmm7, %xmm7
	vinsertf128	$1, %xmm6, %ymm7, %ymm6
	vmovsd	-40(%rsi), %xmm7
	vmovhpd	-8(%rsi), %xmm7, %xmm7
	vmovsd	-104(%rsi), %xmm0
	vmovhpd	-72(%rsi), %xmm0, %xmm0
	vinsertf128	$1, %xmm7, %ymm0, %ymm0
	vmovsd	-32(%rsi), %xmm7
	vmovhpd	(%rsi), %xmm7, %xmm7
	vmovsd	-96(%rsi), %xmm1
	vmovhpd	-64(%rsi), %xmm1, %xmm1
	vinsertf128	$1, %xmm7, %ymm1, %ymm1
	vfmadd231pd	%ymm4, %ymm5, %ymm3
	vfmadd231pd	%ymm4, %ymm6, %ymm2
	vfmadd231pd	%ymm4, %ymm0, %ymm9
	vfmadd231pd	%ymm4, %ymm1, %ymm8
	subq	$-128, %rsi
	addq	$32, %rdx
	addq	$-4, %rbx
	jne	LBB112_4
	jmp	LBB112_5
LBB112_2:
	movq	%rsi, %r8
	movq	%rdx, %r11
	xorl	%r9d, %r9d
LBB112_5:
	vextractf128	$1, %ymm3, %xmm0
	vaddpd	%ymm0, %ymm3, %ymm0
	vhaddpd	%ymm0, %ymm0, %ymm0
	vextractf128	$1, %ymm2, %xmm1
	vaddpd	%ymm1, %ymm2, %ymm1
	vhaddpd	%ymm1, %ymm1, %ymm1
	vextractf128	$1, %ymm9, %xmm2
	vaddpd	%ymm2, %ymm9, %ymm2
	vhaddpd	%ymm2, %ymm2, %ymm2
	vextractf128	$1, %ymm8, %xmm3
	vaddpd	%ymm3, %ymm8, %ymm3
	vhaddpd	%ymm3, %ymm3, %ymm4
	vunpcklpd	%xmm1, %xmm0, %xmm3
	vunpcklpd	%xmm4, %xmm2, %xmm1
	cmpq	%rdi, %r9
	movq	%r10, %rdi
	movq	%r8, %rsi
	movq	%r11, %rdx
	je	LBB112_7
	.align	4, 0x90
LBB112_6:
	vmovddup	(%rdx), %xmm0
	vfmadd231pd	(%rsi), %xmm0, %xmm3
	vfmadd231pd	16(%rsi), %xmm0, %xmm1
	addq	$8, %rdx
	addq	$32, %rsi
	addq	$-1, %rdi
	jne	LBB112_6
LBB112_7:
	vmovupd	%xmm3, (%rcx)
	vmovupd	%xmm1, 16(%rcx)
	popq	%rbx
	vzeroupper
	retq
	.cfi_endproc

	.globl	__D3mir4blas8internal12micro_kernel39__T17scale_nano_kernelVmi1Vmi4Vmi1TdTdZ17scale_nano_kernelFNaNbNiNfKG4G1G1dG1dZv
	.weak_definition	__D3mir4blas8internal12micro_kernel39__T17scale_nano_kernelVmi1Vmi4Vmi1TdTdZ17scale_nano_kernelFNaNbNiNfKG4G1G1dG1dZv
	.align	4, 0x90
__D3mir4blas8internal12micro_kernel39__T17scale_nano_kernelVmi1Vmi4Vmi1TdTdZ17scale_nano_kernelFNaNbNiNfKG4G1G1dG1dZv:
	.cfi_startproc
	vunpcklpd	%xmm0, %xmm0, %xmm0
	vmulpd	(%rdi), %xmm0, %xmm1
	vmulpd	16(%rdi), %xmm0, %xmm0
	vmovupd	%xmm1, (%rdi)
	vmovupd	%xmm0, 16(%rdi)
	retq
	.cfi_endproc

	.globl	__D3mir4blas8internal7utility23__T4loadVmi4Vmi1Vmi1TdZ4loadFNaNbNiNfKG4G1G1dKG4G1G1dZv
	.weak_definition	__D3mir4blas8internal7utility23__T4loadVmi4Vmi1Vmi1TdZ4loadFNaNbNiNfKG4G1G1dKG4G1G1dZv
	.align	4, 0x90
__D3mir4blas8internal7utility23__T4loadVmi4Vmi1Vmi1TdZ4loadFNaNbNiNfKG4G1G1dKG4G1G1dZv:
	.cfi_startproc
	vmovsd	(%rdi), %xmm0
	vmovsd	%xmm0, (%rsi)
	vmovsd	8(%rdi), %xmm0
	vmovsd	%xmm0, 8(%rsi)
	vmovsd	16(%rdi), %xmm0
	vmovsd	%xmm0, 16(%rsi)
	vmovsd	24(%rdi), %xmm0
	vmovsd	%xmm0, 24(%rsi)
	retq
	.cfi_endproc

	.globl	__D3mir4blas8internal7utility17__T4loadVmi1TdTdZ4loadFNaNbNiNfKG1dKxG1dZv
	.weak_definition	__D3mir4blas8internal7utility17__T4loadVmi1TdTdZ4loadFNaNbNiNfKG1dKxG1dZv
	.align	4, 0x90
__D3mir4blas8internal7utility17__T4loadVmi1TdTdZ4loadFNaNbNiNfKG1dKxG1dZv:
	.cfi_startproc
	vmovsd	(%rdi), %xmm0
	vmovsd	%xmm0, (%rsi)
	retq
	.cfi_endproc

	.globl	__D3mir4blas8internal7utility27__T8set_zeroVmi2Vmi1Vmi1TdZ8set_zeroFNaNbNiNfKG2G1G1dZv
	.weak_definition	__D3mir4blas8internal7utility27__T8set_zeroVmi2Vmi1Vmi1TdZ8set_zeroFNaNbNiNfKG2G1G1dZv
	.align	4, 0x90
__D3mir4blas8internal7utility27__T8set_zeroVmi2Vmi1Vmi1TdZ8set_zeroFNaNbNiNfKG2G1G1dZv:
	.cfi_startproc
	vxorps	%xmm0, %xmm0, %xmm0
	vmovups	%xmm0, (%rdi)
	retq
	.cfi_endproc

	.globl	__D3mir4blas8internal12micro_kernel82__T16gemm_nano_kernelVE3mir4blas8internal12micro_kernel7MulTypei0Vmi1Vmi1Vmi2TdTdZ16gemm_nano_kernelFNaNbNiKG2G1G1dMPxG1G1dPxG1G2dmZPxG1G2d
	.weak_definition	__D3mir4blas8internal12micro_kernel82__T16gemm_nano_kernelVE3mir4blas8internal12micro_kernel7MulTypei0Vmi1Vmi1Vmi2TdTdZ16gemm_nano_kernelFNaNbNiKG2G1G1dMPxG1G1dPxG1G2dmZPxG1G2d
	.align	4, 0x90
__D3mir4blas8internal12micro_kernel82__T16gemm_nano_kernelVE3mir4blas8internal12micro_kernel7MulTypei0Vmi1Vmi1Vmi2TdTdZ16gemm_nano_kernelFNaNbNiKG2G1G1dMPxG1G1dPxG1G2dmZPxG1G2d:
	.cfi_startproc
	pushq	%rbx
Ltmp52:
	.cfi_def_cfa_offset 16
Ltmp53:
	.cfi_offset %rbx, -16
	vmovupd	(%rcx), %xmm1
	movq	%rdi, %rax
	shlq	$4, %rax
	addq	%rsi, %rax
	testq	%rdi, %rdi
	je	LBB117_6
	movq	%rdi, %r8
	andq	$-4, %r8
	movq	%rdi, %r9
	vpermilpd	$1, %xmm1, %xmm0
	vmovq	%xmm0, %xmm0
	vxorpd	%ymm2, %ymm2, %ymm2
	vinsertf128	$0, %xmm0, %ymm2, %ymm0
	vmovq	%xmm1, %xmm1
	vinsertf128	$0, %xmm1, %ymm2, %ymm1
	movq	%rdi, %r10
	andq	$-4, %r9
	je	LBB117_2
	subq	%r8, %r10
	shlq	$4, %r8
	addq	%rsi, %r8
	leaq	(%rdx,%r9,8), %r11
	addq	$56, %rsi
	addq	$24, %rdx
	movq	%r9, %rbx
	.align	4, 0x90
LBB117_4:
	vmovupd	-24(%rdx), %xmm2
	vmovsd	-8(%rdx), %xmm3
	vmovhpd	(%rdx), %xmm3, %xmm3
	vinsertf128	$1, %xmm3, %ymm2, %ymm2
	vmovsd	-24(%rsi), %xmm3
	vmovhpd	-8(%rsi), %xmm3, %xmm3
	vmovsd	-56(%rsi), %xmm4
	vmovsd	-48(%rsi), %xmm5
	vmovhpd	-40(%rsi), %xmm4, %xmm4
	vinsertf128	$1, %xmm3, %ymm4, %ymm3
	vmovsd	-16(%rsi), %xmm4
	vmovhpd	(%rsi), %xmm4, %xmm4
	vmovhpd	-32(%rsi), %xmm5, %xmm5
	vinsertf128	$1, %xmm4, %ymm5, %ymm4
	vfmadd231pd	%ymm2, %ymm3, %ymm1
	vfmadd231pd	%ymm2, %ymm4, %ymm0
	addq	$64, %rsi
	addq	$32, %rdx
	addq	$-4, %rbx
	jne	LBB117_4
	jmp	LBB117_5
LBB117_2:
	movq	%rsi, %r8
	movq	%rdx, %r11
	xorl	%r9d, %r9d
LBB117_5:
	vextractf128	$1, %ymm1, %xmm2
	vaddpd	%ymm2, %ymm1, %ymm1
	vhaddpd	%ymm1, %ymm1, %ymm1
	vextractf128	$1, %ymm0, %xmm2
	vaddpd	%ymm2, %ymm0, %ymm0
	vhaddpd	%ymm0, %ymm0, %ymm0
	vunpcklpd	%xmm0, %xmm1, %xmm1
	cmpq	%rdi, %r9
	movq	%r10, %rdi
	movq	%r8, %rsi
	movq	%r11, %rdx
	je	LBB117_7
	.align	4, 0x90
LBB117_6:
	vmovddup	(%rdx), %xmm0
	vfmadd231pd	(%rsi), %xmm0, %xmm1
	addq	$8, %rdx
	addq	$16, %rsi
	addq	$-1, %rdi
	jne	LBB117_6
LBB117_7:
	vmovupd	%xmm1, (%rcx)
	popq	%rbx
	vzeroupper
	retq
	.cfi_endproc

	.globl	__D3mir4blas8internal12micro_kernel39__T17scale_nano_kernelVmi1Vmi2Vmi1TdTdZ17scale_nano_kernelFNaNbNiNfKG2G1G1dG1dZv
	.weak_definition	__D3mir4blas8internal12micro_kernel39__T17scale_nano_kernelVmi1Vmi2Vmi1TdTdZ17scale_nano_kernelFNaNbNiNfKG2G1G1dG1dZv
	.align	4, 0x90
__D3mir4blas8internal12micro_kernel39__T17scale_nano_kernelVmi1Vmi2Vmi1TdTdZ17scale_nano_kernelFNaNbNiNfKG2G1G1dG1dZv:
	.cfi_startproc
	vunpcklpd	%xmm0, %xmm0, %xmm0
	vmulpd	(%rdi), %xmm0, %xmm0
	vmovupd	%xmm0, (%rdi)
	retq
	.cfi_endproc

	.globl	__D3mir4blas8internal7utility23__T4loadVmi2Vmi1Vmi1TdZ4loadFNaNbNiNfKG2G1G1dKG2G1G1dZv
	.weak_definition	__D3mir4blas8internal7utility23__T4loadVmi2Vmi1Vmi1TdZ4loadFNaNbNiNfKG2G1G1dKG2G1G1dZv
	.align	4, 0x90
__D3mir4blas8internal7utility23__T4loadVmi2Vmi1Vmi1TdZ4loadFNaNbNiNfKG2G1G1dKG2G1G1dZv:
	.cfi_startproc
	vmovsd	(%rdi), %xmm0
	vmovsd	%xmm0, (%rsi)
	vmovsd	8(%rdi), %xmm0
	vmovsd	%xmm0, 8(%rsi)
	retq
	.cfi_endproc

	.globl	__D3mir4blas8internal7utility27__T8set_zeroVmi1Vmi1Vmi1TdZ8set_zeroFNaNbNiNfKG1G1G1dZv
	.weak_definition	__D3mir4blas8internal7utility27__T8set_zeroVmi1Vmi1Vmi1TdZ8set_zeroFNaNbNiNfKG1G1G1dZv
	.align	4, 0x90
__D3mir4blas8internal7utility27__T8set_zeroVmi1Vmi1Vmi1TdZ8set_zeroFNaNbNiNfKG1G1G1dZv:
	.cfi_startproc
	movq	$0, (%rdi)
	retq
	.cfi_endproc

	.globl	__D3mir4blas8internal12micro_kernel82__T16gemm_nano_kernelVE3mir4blas8internal12micro_kernel7MulTypei0Vmi1Vmi1Vmi1TdTdZ16gemm_nano_kernelFNaNbNiKG1G1G1dMPxG1G1dPxG1G1dmZPxG1G1d
	.weak_definition	__D3mir4blas8internal12micro_kernel82__T16gemm_nano_kernelVE3mir4blas8internal12micro_kernel7MulTypei0Vmi1Vmi1Vmi1TdTdZ16gemm_nano_kernelFNaNbNiKG1G1G1dMPxG1G1dPxG1G1dmZPxG1G1d
	.align	4, 0x90
__D3mir4blas8internal12micro_kernel82__T16gemm_nano_kernelVE3mir4blas8internal12micro_kernel7MulTypei0Vmi1Vmi1Vmi1TdTdZ16gemm_nano_kernelFNaNbNiKG1G1G1dMPxG1G1dPxG1G1dmZPxG1G1d:
	.cfi_startproc
	pushq	%rbx
Ltmp54:
	.cfi_def_cfa_offset 16
Ltmp55:
	.cfi_offset %rbx, -16
	vmovsd	(%rcx), %xmm0
	leaq	(%rsi,%rdi,8), %rax
	testq	%rdi, %rdi
	je	LBB121_6
	movq	%rdi, %rbx
	andq	$-8, %rbx
	movq	%rdi, %r8
	vxorpd	%ymm1, %ymm1, %ymm1
	vmovsd	%xmm0, %xmm1, %xmm0
	vinsertf128	$0, %xmm0, %ymm1, %ymm0
	movq	%rdi, %r9
	andq	$-8, %r8
	je	LBB121_2
	subq	%rbx, %r9
	leaq	(%rsi,%r8,8), %r10
	leaq	(%rdx,%r8,8), %r11
	addq	$56, %rsi
	addq	$56, %rdx
	vxorpd	%ymm1, %ymm1, %ymm1
	movq	%r8, %rbx
	.align	4, 0x90
LBB121_4:
	vmovupd	-56(%rdx), %ymm2
	vmovupd	-24(%rdx), %xmm3
	vmovsd	-8(%rdx), %xmm4
	vmovhpd	(%rdx), %xmm4, %xmm4
	vinsertf128	$1, %xmm4, %ymm3, %ymm3
	vmovupd	-24(%rsi), %xmm4
	vmovsd	-8(%rsi), %xmm5
	vmovhpd	(%rsi), %xmm5, %xmm5
	vinsertf128	$1, %xmm5, %ymm4, %ymm4
	vfmadd231pd	-56(%rsi), %ymm2, %ymm0
	vfmadd231pd	%ymm3, %ymm4, %ymm1
	addq	$64, %rsi
	addq	$64, %rdx
	addq	$-8, %rbx
	jne	LBB121_4
	jmp	LBB121_5
LBB121_2:
	movq	%rsi, %r10
	movq	%rdx, %r11
	xorl	%r8d, %r8d
LBB121_5:
	vaddpd	%ymm0, %ymm1, %ymm0
	vextractf128	$1, %ymm0, %xmm1
	vaddpd	%ymm1, %ymm0, %ymm0
	vhaddpd	%ymm0, %ymm0, %ymm0
	cmpq	%rdi, %r8
	movq	%r9, %rdi
	movq	%r10, %rsi
	movq	%r11, %rdx
	je	LBB121_7
	.align	4, 0x90
LBB121_6:
	vmovsd	(%rdx), %xmm1
	vfmadd231sd	(%rsi), %xmm1, %xmm0
	addq	$8, %rdx
	addq	$8, %rsi
	addq	$-1, %rdi
	jne	LBB121_6
LBB121_7:
	vmovsd	%xmm0, (%rcx)
	popq	%rbx
	vzeroupper
	retq
	.cfi_endproc

	.globl	__D3mir4blas8internal12micro_kernel39__T17scale_nano_kernelVmi1Vmi1Vmi1TdTdZ17scale_nano_kernelFNaNbNiNfKG1G1G1dG1dZv
	.weak_definition	__D3mir4blas8internal12micro_kernel39__T17scale_nano_kernelVmi1Vmi1Vmi1TdTdZ17scale_nano_kernelFNaNbNiNfKG1G1G1dG1dZv
	.align	4, 0x90
__D3mir4blas8internal12micro_kernel39__T17scale_nano_kernelVmi1Vmi1Vmi1TdTdZ17scale_nano_kernelFNaNbNiNfKG1G1G1dG1dZv:
	.cfi_startproc
	vmulsd	(%rdi), %xmm0, %xmm0
	vmovsd	%xmm0, (%rdi)
	retq
	.cfi_endproc

	.globl	__D3mir4blas8internal7utility23__T4loadVmi1Vmi1Vmi1TdZ4loadFNaNbNiNfKG1G1G1dKG1G1G1dZv
	.weak_definition	__D3mir4blas8internal7utility23__T4loadVmi1Vmi1Vmi1TdZ4loadFNaNbNiNfKG1G1G1dKG1G1G1dZv
	.align	4, 0x90
__D3mir4blas8internal7utility23__T4loadVmi1Vmi1Vmi1TdZ4loadFNaNbNiNfKG1G1G1dKG1G1G1dZv:
	.cfi_startproc
	vmovsd	(%rdi), %xmm0
	vmovsd	%xmm0, (%rsi)
	retq
	.cfi_endproc

	.globl	__D3std10functional20__T6safeOpVAyaa1_3cZ15__T6safeOpTmTmZ6safeOpFNaNbNiNfKmKmZb
	.weak_definition	__D3std10functional20__T6safeOpVAyaa1_3cZ15__T6safeOpTmTmZ6safeOpFNaNbNiNfKmKmZb
	.align	4, 0x90
__D3std10functional20__T6safeOpVAyaa1_3cZ15__T6safeOpTmTmZ6safeOpFNaNbNiNfKmKmZb:
	.cfi_startproc
	movq	(%rsi), %rax
	cmpq	(%rdi), %rax
	setb	%al
	retq
	.cfi_endproc

	.section	__TEXT,__text,regular,pure_instructions
	.align	4, 0x90
__D3mir4blas8internal6kernel16__moduleinfoCtorZ:
	movq	__Dmodule_ref@GOTPCREL(%rip), %rax
	movq	(%rax), %rcx
	movq	%rcx, __D3mir4blas8internal6kernel11__moduleRefZ(%rip)
	leaq	__D3mir4blas8internal6kernel11__moduleRefZ(%rip), %rcx
	movq	%rcx, (%rax)
	retq

	.section	__TEXT,__cstring,cstring_literals
	.align	4
L_.str:
	.asciz	"mir/blas/internal/kernel.d"

	.align	4
L_.str1:
	.asciz	"index at position 0LU from the range [0 ..2LU) must be less than corresponding length."

	.align	4
L_.str2:
	.asciz	"mir/ndslice/slice.d-mixin-1140"

	.align	4
L_.str3:
	.asciz	"index at position 1LU from the range [0 ..2LU) must be less than corresponding length."

	.align	4
L_.str4:
	.asciz	"mir/ndslice/slice.d-mixin-1150"

	.align	4
L_.str6:
	.asciz	"mir/ndslice/slice.d"

	.align	4
L_.str7:
	.asciz	"mir.ndslice.slice.Slice!(2LU, double*).Slice.popFront: dimension should be less than N = 2LU"

	.align	4
L_.str8:
	.asciz	": length!dim should be greater than 0."

	.align	4
L_.str9:
	.asciz	"mir.ndslice.slice.Slice!(2LU, double*).Slice.popBack: dimension should be less than N = 2LU"

	.align	4
L_.str10:
	.asciz	"mir.ndslice.slice.Slice!(2LU, double*).Slice.popFrontExactly: dimension should be less than N = 2LU"

	.align	4
L_.str11:
	.asciz	"mir.ndslice.slice.Slice!(2LU, double*).Slice.popFrontExactly: n should be less than or equal to length!dim"

	.align	4
L_.str12:
	.asciz	"mir.ndslice.slice.Slice!(2LU, double*).Slice.popBackExactly: dimension should be less than N = 2LU"

	.align	4
L_.str13:
	.asciz	"mir.ndslice.slice.Slice!(2LU, double*).Slice.popBackExactly: n should be less than or equal to length!dim"

	.align	4
L_.str14:
	.asciz	"mir.ndslice.slice.Slice!(2LU, double*).Slice.popFrontN: dimension should be less than N = 2LU"

	.align	4
L_.str15:
	.asciz	"mir.ndslice.slice.Slice!(2LU, double*).Slice.popBackN: dimension should be less than N = 2LU"

	.section	__TEXT,__const_coal,coalesced
	.globl	__D3mir7ndslice5slice17__T5SliceVmi2TPdZ5Slice6__initZ
	.weak_definition	__D3mir7ndslice5slice17__T5SliceVmi2TPdZ5Slice6__initZ
	.align	3
__D3mir7ndslice5slice17__T5SliceVmi2TPdZ5Slice6__initZ:
	.space	40

	.section	__TEXT,__cstring,cstring_literals
	.align	4
L_.str17:
	.asciz	"index at position 0LU from the range [0 ..1LU) must be less than corresponding length."

	.align	4
L_.str18:
	.asciz	"mir.ndslice.slice.Slice!(1LU, double*).Slice.popFront: dimension should be less than N = 1LU"

	.align	4
L_.str19:
	.asciz	"mir.ndslice.slice.Slice!(1LU, double*).Slice.popBack: dimension should be less than N = 1LU"

	.align	4
L_.str20:
	.asciz	"mir.ndslice.slice.Slice!(1LU, double*).Slice.popFrontExactly: dimension should be less than N = 1LU"

	.align	4
L_.str21:
	.asciz	"mir.ndslice.slice.Slice!(1LU, double*).Slice.popFrontExactly: n should be less than or equal to length!dim"

	.align	4
L_.str22:
	.asciz	"mir.ndslice.slice.Slice!(1LU, double*).Slice.popBackExactly: dimension should be less than N = 1LU"

	.align	4
L_.str23:
	.asciz	"mir.ndslice.slice.Slice!(1LU, double*).Slice.popBackExactly: n should be less than or equal to length!dim"

	.align	4
L_.str24:
	.asciz	"mir.ndslice.slice.Slice!(1LU, double*).Slice.popFrontN: dimension should be less than N = 1LU"

	.align	4
L_.str25:
	.asciz	"mir.ndslice.slice.Slice!(1LU, double*).Slice.popBackN: dimension should be less than N = 1LU"

	.section	__TEXT,__const_coal,coalesced
	.globl	__D3mir7ndslice5slice17__T5SliceVmi1TPdZ5Slice6__initZ
	.weak_definition	__D3mir7ndslice5slice17__T5SliceVmi1TPdZ5Slice6__initZ
	.align	3
__D3mir7ndslice5slice17__T5SliceVmi1TPdZ5Slice6__initZ:
	.space	24

	.globl	__D3mir7ndslice5slice18__T9StructureVmi1Z9Structure6__initZ
	.weak_definition	__D3mir7ndslice5slice18__T9StructureVmi1Z9Structure6__initZ
	.align	3
__D3mir7ndslice5slice18__T9StructureVmi1Z9Structure6__initZ:
	.space	16

	.globl	__D3mir7ndslice5slice18__T9StructureVmi2Z9Structure6__initZ
	.weak_definition	__D3mir7ndslice5slice18__T9StructureVmi2Z9Structure6__initZ
	.align	3
__D3mir7ndslice5slice18__T9StructureVmi2Z9Structure6__initZ:
	.space	32

	.section	__TEXT,__cstring,cstring_literals
	.align	4
L_.str29:
	.asciz	"Slice.opSlice!0LU: the left bound must be less than or equal to the right bound."

	.align	4
L_.str30:
	.asciz	"Slice.opSlice!0LU: difference between the right and the left bounds must be less than or equal to the length of the given dimension."

	.align	4
L_.str31:
	.asciz	"mir/ndslice/slice.d-mixin-1135"

	.align	4
L_.str32:
	.asciz	"mir/ndslice/iteration.d"

	.align	4
L_.str33:
	.asciz	"mir.ndslice.slice.Slice!(2LU, double*).Slice.popFront!0.popFront: length!0LU should be greater than 0."

	.align	4
L_.str34:
	.asciz	"mir.ndslice.slice.Slice!(1LU, double*).Slice.popFront!0.popFront: length!0LU should be greater than 0."

	.align	4
L_.str35:
	.asciz	"mir.ndslice.slice.Slice!(2LU, double*).Slice.popFrontExactly!0.popFrontExactly: n should be less than or equal to length!0LU"

	.align	4
L_.str36:
	.asciz	"mir/ndslice/slice.d-mixin-1145"

	.section	__DATA,__data
	.globl	__D3mir4blas8internal6kernel12__ModuleInfoZ
	.align	4
__D3mir4blas8internal6kernel12__ModuleInfoZ:
	.long	2147483652
	.long	0
	.asciz	"mir.glas.internal.kernel"
	.space	3

	.align	3
__D3mir4blas8internal6kernel11__moduleRefZ:
	.quad	0
	.quad	__D3mir4blas8internal6kernel12__ModuleInfoZ

	.section	__DATA,__mod_init_func,mod_init_funcs
	.align	3
	.quad	__D3mir4blas8internal6kernel16__moduleinfoCtorZ

.subsections_via_symbols
