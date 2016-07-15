	.section	__TEXT,__text,regular,pure_instructions
	.section	__TEXT,__textcoal_nt,coalesced,pure_instructions
	.globl	__D3mir4blas8internal6kernel56__T9gebp_opt1Vmi1TdVE3mir4blas6common14Multiplicationi0Z9gebp_opt1FNaNbNixG1dmxmxmPxdPxdMPG1dmZv
	.weak_definition	__D3mir4blas8internal6kernel56__T9gebp_opt1Vmi1TdVE3mir4blas6common14Multiplicationi0Z9gebp_opt1FNaNbNixG1dmxmxmPxdPxdMPG1dmZv
	.align	4, 0x90
__D3mir4blas8internal6kernel56__T9gebp_opt1Vmi1TdVE3mir4blas6common14Multiplicationi0Z9gebp_opt1FNaNbNixG1dmxmxmPxdPxdMPG1dmZv:
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
	subq	$72, %rsp
Ltmp6:
	.cfi_def_cfa_offset 128
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
	vmovapd	%xmm0, %xmm15
	vmovapd	%xmm15, -32(%rsp)
	movq	%r8, -88(%rsp)
	movq	%rcx, %r10
	movq	%r10, 24(%rsp)
	movq	%rdx, %r14
	movq	%rsi, %rbx
	movq	128(%rsp), %rcx
	cmpq	$7, %rcx
	jb	LBB0_6
	vunpcklpd	%xmm15, %xmm15, %xmm0
	vmovapd	%xmm0, 48(%rsp)
	leaq	(%rdi,%rdi), %r12
	movq	%r9, 16(%rsp)
	leaq	(%rdi,%rdi,2), %r13
	leaq	(,%rdi,4), %rsi
	leaq	2(,%rdi,4), %rax
	movq	%rax, 40(%rsp)
	movq	%rdi, %r11
	movq	%r11, 64(%rsp)
	leaq	(%r11,%r11,4), %rdi
	leaq	(%r12,%r12,2), %rax
	movq	%rax, -40(%rsp)
	leaq	(%r9,%r9), %rax
	leaq	(%rax,%rax,2), %rax
	movq	%rax, -48(%rsp)
	leaq	-5(%r9), %rdx
	shrq	$2, %rdx
	leaq	(,%rdx,4), %rax
	shlq	$5, %rdx
	movq	%rbx, %rbp
	leaq	32(%rdx,%rbp), %rbx
	movq	%rbx, 8(%rsp)
	movq	%rbp, %rbx
	negq	%rax
	addq	$32, %rdx
	imulq	%r8, %rdx
	leaq	-4(%r9,%rax), %rax
	movq	%rax, -80(%rsp)
	addq	%r10, %rdx
	movq	%rdx, -72(%rsp)
	leaq	-7(%rcx), %rdx
	movabsq	$-6148914691236517205, %rax
	mulxq	%rax, %rax, %rdx
	shrq	$2, %rdx
	movq	%rdx, -104(%rsp)
	leaq	(%rdx,%rdx,2), %rax
	shlq	$4, %rax
	addq	$48, %rax
	movq	%rax, %rdx
	imulq	%r9, %rdx
	addq	%r14, %rdx
	movq	%rdx, -120(%rsp)
	imulq	%r11, %rax
	addq	%rbx, %rax
	movq	%rax, -112(%rsp)
	movq	%r9, %rax
	shlq	$4, %rax
	leaq	(%rax,%rax,2), %rax
	movq	%rax, -56(%rsp)
	movq	%r8, %rax
	andq	$-4, %rax
	movq	%rax, -96(%rsp)
	leaq	184(%r14), %rax
	movq	%rax, (%rsp)
	movq	%rcx, %rdx
	.align	4, 0x90
LBB0_2:
	movq	%rdx, -8(%rsp)
	movq	%rbx, 32(%rsp)
	movq	16(%rsp), %rax
	movq	%rax, %rbp
	movq	%r10, %r15
	movq	%rbx, %r11
	movq	%rax, %r9
	movq	%r10, %rcx
	cmpq	$5, %rax
	jb	LBB0_3
	.align	4, 0x90
LBB0_18:
	vxorpd	%xmm9, %xmm9, %xmm9
	vxorpd	%xmm10, %xmm10, %xmm10
	vxorpd	%xmm11, %xmm11, %xmm11
	vxorpd	%xmm12, %xmm12, %xmm12
	vxorpd	%xmm13, %xmm13, %xmm13
	vxorpd	%xmm14, %xmm14, %xmm14
	vxorpd	%xmm15, %xmm15, %xmm15
	vxorpd	%xmm2, %xmm2, %xmm2
	vxorpd	%xmm3, %xmm3, %xmm3
	vxorpd	%xmm4, %xmm4, %xmm4
	vxorpd	%xmm5, %xmm5, %xmm5
	vxorpd	%xmm6, %xmm6, %xmm6
	movq	%r8, %rbp
	movq	%r14, %rax
	movq	%rcx, %rdx
	.align	4, 0x90
LBB0_19:
	vmovapd	(%rdx), %xmm7
	vmovapd	16(%rdx), %xmm1
	vmovddup	(%rax), %xmm8
	vfmadd231pd	%xmm8, %xmm7, %xmm6
	vfmadd231pd	%xmm8, %xmm1, %xmm5
	vmovddup	8(%rax), %xmm0
	vfmadd231pd	%xmm0, %xmm7, %xmm4
	vfmadd231pd	%xmm0, %xmm1, %xmm3
	vmovddup	16(%rax), %xmm0
	vfmadd231pd	%xmm0, %xmm7, %xmm2
	vfmadd231pd	%xmm0, %xmm1, %xmm15
	vmovddup	24(%rax), %xmm0
	vfmadd231pd	%xmm0, %xmm7, %xmm14
	vfmadd231pd	%xmm0, %xmm1, %xmm13
	vmovddup	32(%rax), %xmm0
	vfmadd231pd	%xmm0, %xmm7, %xmm12
	vfmadd231pd	%xmm0, %xmm1, %xmm11
	vmovddup	40(%rax), %xmm0
	vfmadd231pd	%xmm0, %xmm7, %xmm10
	vfmadd231pd	%xmm0, %xmm1, %xmm9
	addq	$32, %rdx
	addq	$48, %rax
	addq	$-1, %rbp
	jne	LBB0_19
	vmovapd	48(%rsp), %xmm0
	vfmadd213pd	(%rbx), %xmm0, %xmm6
	vmovupd	%xmm6, (%rbx)
	vfmadd213pd	16(%rbx), %xmm0, %xmm5
	vmovupd	%xmm5, 16(%rbx)
	movq	64(%rsp), %rax
	vfmadd213pd	(%rbx,%rax,8), %xmm0, %xmm4
	vmovupd	%xmm4, (%rbx,%rax,8)
	vfmadd213pd	16(%rbx,%rax,8), %xmm0, %xmm3
	vmovupd	%xmm3, 16(%rbx,%rax,8)
	vfmadd213pd	(%rbx,%r12,8), %xmm0, %xmm2
	vmovupd	%xmm2, (%rbx,%r12,8)
	vfmadd213pd	16(%rbx,%r12,8), %xmm0, %xmm15
	vmovupd	%xmm15, 16(%rbx,%r12,8)
	vfmadd213pd	(%rbx,%r13,8), %xmm0, %xmm14
	vmovupd	%xmm14, (%rbx,%r13,8)
	vfmadd213pd	16(%rbx,%r13,8), %xmm0, %xmm13
	vmovupd	%xmm13, 16(%rbx,%r13,8)
	vfmadd213pd	(%rbx,%rsi,8), %xmm0, %xmm12
	movq	%r8, %rax
	vmovupd	%xmm12, (%rbx,%rsi,8)
	movq	40(%rsp), %rdx
	vfmadd213pd	(%rbx,%rdx,8), %xmm0, %xmm11
	shlq	$5, %rax
	vmovupd	%xmm11, (%rbx,%rdx,8)
	vfmadd213pd	(%rbx,%rdi,8), %xmm0, %xmm10
	addq	%rax, %rcx
	vmovupd	%xmm10, (%rbx,%rdi,8)
	vfmadd213pd	16(%rbx,%rdi,8), %xmm0, %xmm9
	vmovupd	%xmm9, 16(%rbx,%rdi,8)
	addq	$-4, %r9
	addq	$32, %rbx
	cmpq	$4, %r9
	ja	LBB0_18
	movq	-80(%rsp), %rbp
	movq	-72(%rsp), %r15
	movq	8(%rsp), %r11
LBB0_3:
	cmpq	$3, %rbp
	jb	LBB0_4
	leaq	-3(%rbp), %rdx
	shrq	%rdx
	leaq	(%rdx,%rdx), %r10
	shlq	$4, %rdx
	leaq	16(%r11,%rdx), %rax
	movq	%rax, -64(%rsp)
	leaq	-2(%rbp), %rcx
	addq	$16, %rdx
	imulq	%r8, %rdx
	addq	%r15, %rdx
	.align	4, 0x90
LBB0_35:
	vxorpd	%xmm8, %xmm8, %xmm8
	vxorpd	%xmm2, %xmm2, %xmm2
	vxorpd	%xmm3, %xmm3, %xmm3
	vxorpd	%xmm4, %xmm4, %xmm4
	vxorpd	%xmm5, %xmm5, %xmm5
	vxorpd	%xmm6, %xmm6, %xmm6
	movq	%r8, %rax
	movq	%r14, %rbx
	movq	%r15, %r9
	.align	4, 0x90
LBB0_36:
	vmovapd	(%r9), %xmm0
	vmovddup	(%rbx), %xmm7
	vmovddup	8(%rbx), %xmm1
	vmovddup	16(%rbx), %xmm9
	vmovddup	24(%rbx), %xmm10
	vmovddup	32(%rbx), %xmm11
	vmovddup	40(%rbx), %xmm12
	vfmadd231pd	%xmm7, %xmm0, %xmm6
	vfmadd231pd	%xmm1, %xmm0, %xmm5
	vfmadd231pd	%xmm9, %xmm0, %xmm4
	vfmadd231pd	%xmm10, %xmm0, %xmm3
	vfmadd231pd	%xmm11, %xmm0, %xmm2
	vfmadd231pd	%xmm12, %xmm0, %xmm8
	addq	$16, %r9
	addq	$48, %rbx
	addq	$-1, %rax
	jne	LBB0_36
	vmovapd	48(%rsp), %xmm0
	vfmadd213pd	(%r11), %xmm0, %xmm6
	vmovupd	%xmm6, (%r11)
	movq	64(%rsp), %rax
	vfmadd213pd	(%r11,%rax,8), %xmm0, %xmm5
	vmovupd	%xmm5, (%r11,%rax,8)
	vfmadd213pd	(%r11,%r12,8), %xmm0, %xmm4
	movq	%r8, %rax
	vmovupd	%xmm4, (%r11,%r12,8)
	vfmadd213pd	(%r11,%r13,8), %xmm0, %xmm3
	shlq	$4, %rax
	vmovupd	%xmm3, (%r11,%r13,8)
	vfmadd213pd	(%r11,%rsi,8), %xmm0, %xmm2
	addq	%rax, %r15
	vmovupd	%xmm2, (%r11,%rsi,8)
	vfmadd213pd	(%r11,%rdi,8), %xmm0, %xmm8
	vmovupd	%xmm8, (%r11,%rdi,8)
	addq	$-2, %rbp
	addq	$16, %r11
	cmpq	$2, %rbp
	ja	LBB0_35
	subq	%r10, %rcx
	movq	%rcx, %rbp
	movq	%rdx, %r15
	movq	-64(%rsp), %r11
	vmovapd	-32(%rsp), %xmm15
	movq	32(%rsp), %rbx
	movq	24(%rsp), %r10
	jmp	LBB0_23
	.align	4, 0x90
LBB0_4:
	vmovapd	-32(%rsp), %xmm15
	movq	32(%rsp), %rbx
LBB0_23:
	cmpq	$2, %rbp
	jb	LBB0_33
	testq	%r8, %r8
	je	LBB0_25
	movq	%r8, %rax
	andq	$-4, %rax
	movq	%r8, %rdx
	movq	%rbx, %r9
	andq	$-4, %rdx
	je	LBB0_27
	movq	%r8, %rbp
	subq	%rax, %rbp
	leaq	(%rax,%rax,2), %rcx
	shlq	$4, %rcx
	addq	%r14, %rcx
	leaq	(%r15,%rdx,8), %r10
	movq	%rdx, %rax
	addq	$24, %r15
	vxorpd	%ymm8, %ymm8, %ymm8
	movq	-96(%rsp), %rdx
	movq	(%rsp), %rbx
	vxorpd	%ymm11, %ymm11, %ymm11
	vxorpd	%ymm12, %ymm12, %ymm12
	vxorpd	%ymm5, %ymm5, %ymm5
	vxorpd	%ymm6, %ymm6, %ymm6
	vxorpd	%ymm7, %ymm7, %ymm7
	.align	4, 0x90
LBB0_29:
	vmovupd	-24(%r15), %xmm0
	vmovsd	-8(%r15), %xmm1
	vmovhpd	(%r15), %xmm1, %xmm1
	vinsertf128	$1, %xmm1, %ymm0, %ymm1
	vmovsd	-88(%rbx), %xmm0
	vmovhpd	-40(%rbx), %xmm0, %xmm0
	vmovsd	-184(%rbx), %xmm2
	vmovsd	-176(%rbx), %xmm3
	vmovhpd	-136(%rbx), %xmm2, %xmm2
	vinsertf128	$1, %xmm0, %ymm2, %ymm9
	vmovsd	-80(%rbx), %xmm0
	vmovhpd	-32(%rbx), %xmm0, %xmm0
	vmovhpd	-128(%rbx), %xmm3, %xmm2
	vinsertf128	$1, %xmm0, %ymm2, %ymm10
	vmovsd	-72(%rbx), %xmm0
	vmovhpd	-24(%rbx), %xmm0, %xmm0
	vmovsd	-168(%rbx), %xmm2
	vmovhpd	-120(%rbx), %xmm2, %xmm2
	vinsertf128	$1, %xmm0, %ymm2, %ymm13
	vmovsd	-64(%rbx), %xmm2
	vmovhpd	-16(%rbx), %xmm2, %xmm2
	vmovsd	-160(%rbx), %xmm3
	vmovhpd	-112(%rbx), %xmm3, %xmm3
	vinsertf128	$1, %xmm2, %ymm3, %ymm2
	vmovsd	-56(%rbx), %xmm3
	vmovhpd	-8(%rbx), %xmm3, %xmm3
	vmovsd	-152(%rbx), %xmm4
	vmovhpd	-104(%rbx), %xmm4, %xmm4
	vinsertf128	$1, %xmm3, %ymm4, %ymm3
	vmovsd	-48(%rbx), %xmm4
	vmovhpd	(%rbx), %xmm4, %xmm4
	vmovsd	-144(%rbx), %xmm0
	vmovhpd	-96(%rbx), %xmm0, %xmm0
	vinsertf128	$1, %xmm4, %ymm0, %ymm0
	vfmadd231pd	%ymm1, %ymm9, %ymm7
	vfmadd231pd	%ymm1, %ymm10, %ymm6
	vfmadd231pd	%ymm1, %ymm13, %ymm5
	vfmadd231pd	%ymm1, %ymm2, %ymm12
	vfmadd231pd	%ymm1, %ymm3, %ymm11
	vfmadd231pd	%ymm1, %ymm0, %ymm8
	addq	$192, %rbx
	addq	$32, %r15
	addq	$-4, %rdx
	jne	LBB0_29
	jmp	LBB0_30
LBB0_25:
	movq	%rbx, %r9
	vxorpd	%xmm2, %xmm2, %xmm2
	vxorpd	%xmm3, %xmm3, %xmm3
	vxorpd	%xmm4, %xmm4, %xmm4
	vxorpd	%xmm5, %xmm5, %xmm5
	vxorpd	%xmm6, %xmm6, %xmm6
	vxorpd	%xmm7, %xmm7, %xmm7
	movq	%r8, %rbp
	movq	%r14, %rcx
	movq	%r15, %r10
	jmp	LBB0_31
LBB0_27:
	vxorpd	%ymm8, %ymm8, %ymm8
	movq	%r8, %rbp
	movq	%r14, %rcx
	movq	%r15, %r10
	movl	$0, %eax
	vxorpd	%ymm11, %ymm11, %ymm11
	vxorpd	%ymm12, %ymm12, %ymm12
	vxorpd	%ymm5, %ymm5, %ymm5
	vxorpd	%ymm6, %ymm6, %ymm6
	vxorpd	%ymm7, %ymm7, %ymm7
LBB0_30:
	vextractf128	$1, %ymm7, %xmm0
	vaddpd	%ymm0, %ymm7, %ymm0
	vhaddpd	%ymm0, %ymm0, %ymm7
	vextractf128	$1, %ymm6, %xmm0
	vaddpd	%ymm0, %ymm6, %ymm0
	vhaddpd	%ymm0, %ymm0, %ymm6
	vextractf128	$1, %ymm5, %xmm0
	vaddpd	%ymm0, %ymm5, %ymm0
	vhaddpd	%ymm0, %ymm0, %ymm5
	vextractf128	$1, %ymm12, %xmm0
	vaddpd	%ymm0, %ymm12, %ymm0
	vhaddpd	%ymm0, %ymm0, %ymm4
	vextractf128	$1, %ymm11, %xmm0
	vaddpd	%ymm0, %ymm11, %ymm0
	vhaddpd	%ymm0, %ymm0, %ymm3
	vextractf128	$1, %ymm8, %xmm0
	vaddpd	%ymm0, %ymm8, %ymm0
	vhaddpd	%ymm0, %ymm0, %ymm2
	cmpq	%r8, %rax
	je	LBB0_32
	.align	4, 0x90
LBB0_31:
	vmovsd	(%r10), %xmm0
	vfmadd231sd	(%rcx), %xmm0, %xmm7
	vfmadd231sd	8(%rcx), %xmm0, %xmm6
	vfmadd231sd	16(%rcx), %xmm0, %xmm5
	vfmadd231sd	24(%rcx), %xmm0, %xmm4
	vfmadd231sd	32(%rcx), %xmm0, %xmm3
	vfmadd231sd	40(%rcx), %xmm0, %xmm2
	addq	$8, %r10
	addq	$48, %rcx
	addq	$-1, %rbp
	jne	LBB0_31
LBB0_32:
	vfmadd213sd	(%r11), %xmm15, %xmm7
	vmovsd	%xmm7, (%r11)
	movq	64(%rsp), %rax
	vfmadd213sd	(%r11,%rax,8), %xmm15, %xmm6
	vmovsd	%xmm6, (%r11,%rax,8)
	vfmadd213sd	(%r11,%r12,8), %xmm15, %xmm5
	vmovsd	%xmm5, (%r11,%r12,8)
	vfmadd213sd	(%r11,%r13,8), %xmm15, %xmm4
	vmovsd	%xmm4, (%r11,%r13,8)
	vfmadd213sd	(%r11,%rsi,8), %xmm15, %xmm3
	vmovsd	%xmm3, (%r11,%rsi,8)
	vfmadd213sd	(%r11,%rdi,8), %xmm15, %xmm2
	vmovsd	%xmm2, (%r11,%rdi,8)
	movq	%r9, %rbx
	movq	24(%rsp), %r10
LBB0_33:
	movq	-8(%rsp), %rdx
	addq	$-6, %rdx
	movq	-40(%rsp), %rax
	leaq	(%rbx,%rax,8), %rbx
	movq	-48(%rsp), %rcx
	leaq	(%r14,%rcx,8), %r14
	movq	8(%rsp), %rcx
	leaq	(%rcx,%rax,8), %rcx
	movq	%rcx, 8(%rsp)
	movq	(%rsp), %rax
	addq	-56(%rsp), %rax
	movq	%rax, (%rsp)
	cmpq	$6, %rdx
	ja	LBB0_2
	imulq	$-6, -104(%rsp), %rax
	movq	128(%rsp), %rcx
	leaq	-6(%rcx,%rax), %rcx
	movq	-120(%rsp), %r14
	movq	-112(%rsp), %rbx
	movq	16(%rsp), %r9
	movq	64(%rsp), %rdi
LBB0_6:
	cmpq	$5, %rcx
	jb	LBB0_39
	vunpcklpd	%xmm15, %xmm15, %xmm8
	leaq	(%rdi,%rdi), %r11
	leaq	(%rdi,%rdi,2), %r15
	leaq	(,%rdi,4), %rax
	movq	%rax, 8(%rsp)
	leaq	-5(%r9), %rdx
	shrq	$2, %rdx
	leaq	(,%rdx,4), %rax
	shlq	$5, %rdx
	leaq	32(%rdx,%rbx), %rsi
	movq	%rsi, 48(%rsp)
	negq	%rax
	leaq	-4(%r9,%rax), %rax
	movq	%rax, -48(%rsp)
	addq	$32, %rdx
	imulq	%r8, %rdx
	addq	%r10, %rdx
	movq	%rdx, -40(%rsp)
	movq	%r10, 24(%rsp)
	leaq	-5(%rcx), %rax
	shrq	$2, %rax
	movq	%rax, %rdx
	shlq	$5, %rdx
	addq	$32, %rdx
	movq	%rdx, %rsi
	imulq	%r9, %rsi
	addq	%r14, %rsi
	movq	%rsi, -96(%rsp)
	imulq	%rdi, %rdx
	addq	%rbx, %rdx
	movq	%rdx, -80(%rsp)
	shlq	$2, %rax
	movq	%rax, -72(%rsp)
	movq	%r9, %rax
	movq	%r9, 16(%rsp)
	shlq	$5, %rax
	movq	%rax, (%rsp)
	movq	%rbx, %rbp
	movq	%r8, %r10
	shlq	$5, %r10
	movq	%r8, %r12
	shlq	$4, %r12
	movq	%r8, %rax
	andq	$-4, %rax
	movq	%rax, -56(%rsp)
	movq	%rcx, %rdx
	movq	%rcx, -64(%rsp)
	.align	4, 0x90
LBB0_8:
	movq	%rdx, 40(%rsp)
	movq	%rbp, 32(%rsp)
	movq	16(%rsp), %rax
	movq	%rax, %rsi
	movq	24(%rsp), %rdx
	movq	%rdx, %rcx
	movq	%rbp, %r13
	movq	%rdx, %rbx
	movq	%rax, %rdx
	cmpq	$4, %rax
	jbe	LBB0_9
	.align	4, 0x90
LBB0_51:
	vxorpd	%xmm9, %xmm9, %xmm9
	xorl	%ecx, %ecx
	vxorpd	%xmm10, %xmm10, %xmm10
	vxorpd	%xmm11, %xmm11, %xmm11
	vxorpd	%xmm12, %xmm12, %xmm12
	vxorpd	%xmm13, %xmm13, %xmm13
	vxorpd	%xmm14, %xmm14, %xmm14
	vxorpd	%xmm1, %xmm1, %xmm1
	vxorpd	%xmm2, %xmm2, %xmm2
	movq	%r8, %rsi
	.align	4, 0x90
LBB0_52:
	vmovapd	(%rbx,%rcx), %xmm0
	vmovapd	16(%rbx,%rcx), %xmm3
	vmovddup	(%r14,%rcx), %xmm4
	vmovddup	8(%r14,%rcx), %xmm5
	vmovddup	16(%r14,%rcx), %xmm6
	vmovddup	24(%r14,%rcx), %xmm7
	vfmadd231pd	%xmm4, %xmm0, %xmm2
	vfmadd231pd	%xmm4, %xmm3, %xmm1
	vfmadd231pd	%xmm5, %xmm0, %xmm14
	vfmadd231pd	%xmm5, %xmm3, %xmm13
	vfmadd231pd	%xmm6, %xmm0, %xmm12
	vfmadd231pd	%xmm6, %xmm3, %xmm11
	vfmadd231pd	%xmm7, %xmm0, %xmm10
	vfmadd231pd	%xmm7, %xmm3, %xmm9
	addq	$32, %rcx
	addq	$-1, %rsi
	jne	LBB0_52
	vfmadd213pd	(%rbp), %xmm8, %xmm2
	vmovupd	%xmm2, (%rbp)
	vfmadd213pd	16(%rbp), %xmm8, %xmm1
	vmovupd	%xmm1, 16(%rbp)
	vfmadd213pd	(%rbp,%rdi,8), %xmm8, %xmm14
	vmovupd	%xmm14, (%rbp,%rdi,8)
	vfmadd213pd	16(%rbp,%rdi,8), %xmm8, %xmm13
	vmovupd	%xmm13, 16(%rbp,%rdi,8)
	vfmadd213pd	(%rbp,%r11,8), %xmm8, %xmm12
	vmovupd	%xmm12, (%rbp,%r11,8)
	vfmadd213pd	16(%rbp,%r11,8), %xmm8, %xmm11
	vmovupd	%xmm11, 16(%rbp,%r11,8)
	vfmadd213pd	(%rbp,%r15,8), %xmm8, %xmm10
	vmovupd	%xmm10, (%rbp,%r15,8)
	vfmadd213pd	16(%rbp,%r15,8), %xmm8, %xmm9
	vmovupd	%xmm9, 16(%rbp,%r15,8)
	addq	$-4, %rdx
	addq	$32, %rbp
	addq	%r10, %rbx
	cmpq	$4, %rdx
	ja	LBB0_51
	movq	-48(%rsp), %rsi
	movq	-40(%rsp), %rcx
	movq	48(%rsp), %r13
LBB0_9:
	movq	%r8, %r9
	cmpq	$3, %rsi
	jb	LBB0_15
	leaq	-3(%rsi), %rbp
	shrq	%rbp
	leaq	(%rbp,%rbp), %rax
	movq	%rax, -8(%rsp)
	shlq	$4, %rbp
	leaq	16(%r13,%rbp), %rax
	leaq	-2(%rsi), %rdx
	addq	$16, %rbp
	imulq	%r9, %rbp
	addq	%rcx, %rbp
	.align	4, 0x90
LBB0_11:
	vxorpd	%xmm1, %xmm1, %xmm1
	xorl	%ebx, %ebx
	vxorpd	%xmm2, %xmm2, %xmm2
	vxorpd	%xmm3, %xmm3, %xmm3
	vxorpd	%xmm4, %xmm4, %xmm4
	movq	%r9, %r8
	.align	4, 0x90
LBB0_12:
	vmovapd	(%rcx,%rbx), %xmm0
	vmovddup	(%r14,%rbx,2), %xmm5
	vmovddup	8(%r14,%rbx,2), %xmm6
	vmovddup	16(%r14,%rbx,2), %xmm7
	vmovddup	24(%r14,%rbx,2), %xmm9
	vfmadd231pd	%xmm5, %xmm0, %xmm4
	vfmadd231pd	%xmm6, %xmm0, %xmm3
	vfmadd231pd	%xmm7, %xmm0, %xmm2
	vfmadd231pd	%xmm9, %xmm0, %xmm1
	addq	$16, %rbx
	addq	$-1, %r8
	jne	LBB0_12
	vfmadd213pd	(%r13), %xmm8, %xmm4
	vmovupd	%xmm4, (%r13)
	vfmadd213pd	(%r13,%rdi,8), %xmm8, %xmm3
	vmovupd	%xmm3, (%r13,%rdi,8)
	vfmadd213pd	(%r13,%r11,8), %xmm8, %xmm2
	vmovupd	%xmm2, (%r13,%r11,8)
	vfmadd213pd	(%r13,%r15,8), %xmm8, %xmm1
	vmovupd	%xmm1, (%r13,%r15,8)
	addq	$-2, %rsi
	addq	$16, %r13
	addq	%r12, %rcx
	cmpq	$2, %rsi
	ja	LBB0_11
	subq	-8(%rsp), %rdx
	movq	%rdx, %rsi
	movq	%rbp, %rcx
	movq	%rax, %r13
LBB0_15:
	movq	%r9, %r8
	cmpq	$2, %rsi
	jb	LBB0_63
	testq	%r8, %r8
	je	LBB0_17
	movq	%r8, %rsi
	andq	$-4, %rsi
	movq	%r8, %rdx
	vxorpd	%ymm9, %ymm9, %ymm9
	andq	$-4, %rdx
	je	LBB0_56
	movq	%r8, %r9
	subq	%rsi, %r9
	shlq	$5, %rsi
	addq	%r14, %rsi
	leaq	(%rcx,%rdx,8), %r8
	movq	-56(%rsp), %rbx
	movl	$24, %ebp
	vxorpd	%ymm3, %ymm3, %ymm3
	vxorpd	%ymm4, %ymm4, %ymm4
	vxorpd	%ymm5, %ymm5, %ymm5
	.align	4, 0x90
LBB0_58:
	vmovsd	-8(%rcx,%rbp), %xmm0
	vmovhpd	(%rcx,%rbp), %xmm0, %xmm0
	vmovupd	-24(%rcx,%rbp), %xmm1
	vinsertf128	$1, %xmm0, %ymm1, %ymm1
	vmovsd	-32(%r14,%rbp,4), %xmm0
	vmovhpd	(%r14,%rbp,4), %xmm0, %xmm0
	vmovsd	-96(%r14,%rbp,4), %xmm6
	vmovhpd	-64(%r14,%rbp,4), %xmm6, %xmm6
	vinsertf128	$1, %xmm0, %ymm6, %ymm10
	vmovsd	-24(%r14,%rbp,4), %xmm6
	vmovhpd	8(%r14,%rbp,4), %xmm6, %xmm6
	vmovsd	-88(%r14,%rbp,4), %xmm7
	vmovhpd	-56(%r14,%rbp,4), %xmm7, %xmm7
	vinsertf128	$1, %xmm6, %ymm7, %ymm6
	vmovsd	-16(%r14,%rbp,4), %xmm7
	vmovhpd	16(%r14,%rbp,4), %xmm7, %xmm7
	vmovsd	-80(%r14,%rbp,4), %xmm2
	vmovhpd	-48(%r14,%rbp,4), %xmm2, %xmm2
	vinsertf128	$1, %xmm7, %ymm2, %ymm2
	vmovsd	-8(%r14,%rbp,4), %xmm7
	vmovhpd	24(%r14,%rbp,4), %xmm7, %xmm7
	vmovsd	-72(%r14,%rbp,4), %xmm0
	vmovhpd	-40(%r14,%rbp,4), %xmm0, %xmm0
	vinsertf128	$1, %xmm7, %ymm0, %ymm0
	vfmadd231pd	%ymm1, %ymm10, %ymm5
	vfmadd231pd	%ymm1, %ymm6, %ymm4
	vfmadd231pd	%ymm1, %ymm2, %ymm3
	vfmadd231pd	%ymm1, %ymm0, %ymm9
	addq	$32, %rbp
	addq	$-4, %rbx
	jne	LBB0_58
	movq	-88(%rsp), %rbx
	jmp	LBB0_60
LBB0_17:
	vxorpd	%xmm2, %xmm2, %xmm2
	vxorpd	%xmm3, %xmm3, %xmm3
	vxorpd	%xmm4, %xmm4, %xmm4
	vxorpd	%xmm5, %xmm5, %xmm5
	movq	%r8, %r9
	movq	%r8, %rdx
	movq	%r14, %rsi
	movq	%rcx, %r8
	jmp	LBB0_61
LBB0_56:
	movq	%r8, %rbx
	movq	%rbx, %r9
	movq	%r14, %rsi
	movq	%rcx, %r8
	movl	$0, %edx
	vxorpd	%ymm3, %ymm3, %ymm3
	vxorpd	%ymm4, %ymm4, %ymm4
	vxorpd	%ymm5, %ymm5, %ymm5
LBB0_60:
	vextractf128	$1, %ymm5, %xmm0
	vaddpd	%ymm0, %ymm5, %ymm0
	vhaddpd	%ymm0, %ymm0, %ymm5
	vextractf128	$1, %ymm4, %xmm0
	vaddpd	%ymm0, %ymm4, %ymm0
	vhaddpd	%ymm0, %ymm0, %ymm4
	vextractf128	$1, %ymm3, %xmm0
	vaddpd	%ymm0, %ymm3, %ymm0
	vhaddpd	%ymm0, %ymm0, %ymm3
	vextractf128	$1, %ymm9, %xmm0
	vaddpd	%ymm0, %ymm9, %ymm0
	vhaddpd	%ymm0, %ymm0, %ymm2
	cmpq	%rbx, %rdx
	movq	%rbx, %rdx
	je	LBB0_62
	.align	4, 0x90
LBB0_61:
	vmovsd	(%r8), %xmm0
	vfmadd231sd	(%rsi), %xmm0, %xmm5
	vfmadd231sd	8(%rsi), %xmm0, %xmm4
	vfmadd231sd	16(%rsi), %xmm0, %xmm3
	vfmadd231sd	24(%rsi), %xmm0, %xmm2
	addq	$8, %r8
	addq	$32, %rsi
	addq	$-1, %r9
	jne	LBB0_61
LBB0_62:
	vfmadd213sd	(%r13), %xmm15, %xmm5
	vmovsd	%xmm5, (%r13)
	vfmadd213sd	(%r13,%rdi,8), %xmm15, %xmm4
	vmovsd	%xmm4, (%r13,%rdi,8)
	vfmadd213sd	(%r13,%r11,8), %xmm15, %xmm3
	vmovsd	%xmm3, (%r13,%r11,8)
	vfmadd213sd	(%r13,%r15,8), %xmm15, %xmm2
	vmovsd	%xmm2, (%r13,%r15,8)
	movq	%rdx, %r8
LBB0_63:
	movq	40(%rsp), %rdx
	addq	$-4, %rdx
	movq	32(%rsp), %rbp
	movq	8(%rsp), %rax
	leaq	(%rbp,%rax,8), %rbp
	addq	(%rsp), %r14
	movq	48(%rsp), %rcx
	leaq	(%rcx,%rax,8), %rcx
	movq	%rcx, 48(%rsp)
	cmpq	$4, %rdx
	ja	LBB0_8
	movq	-64(%rsp), %rcx
	addq	$-4, %rcx
	subq	-72(%rsp), %rcx
	movq	-96(%rsp), %r14
	movq	-80(%rsp), %rbx
	movq	24(%rsp), %r10
	movq	16(%rsp), %r9
LBB0_39:
	cmpq	$3, %rcx
	jb	LBB0_65
	vunpcklpd	%xmm15, %xmm15, %xmm8
	leaq	(%rdi,%rdi), %rax
	movq	%rax, 48(%rsp)
	leaq	-5(%r9), %rdx
	shrq	$2, %rdx
	leaq	(,%rdx,4), %rax
	shlq	$5, %rdx
	movq	%r9, 16(%rsp)
	leaq	32(%rdx,%rbx), %r12
	negq	%rax
	leaq	-4(%r9,%rax), %rax
	movq	%rax, -8(%rsp)
	addq	$32, %rdx
	imulq	%r8, %rdx
	addq	%r10, %rdx
	movq	%rdx, (%rsp)
	movq	%r10, 24(%rsp)
	leaq	-3(%rcx), %rax
	shrq	%rax
	movq	%rax, %rdx
	shlq	$4, %rdx
	addq	$16, %rdx
	movq	%rdx, %rsi
	imulq	%r9, %rsi
	addq	%r14, %rsi
	movq	%rsi, -72(%rsp)
	imulq	%rdi, %rdx
	addq	%rbx, %rdx
	movq	%rdx, -56(%rsp)
	addq	%rax, %rax
	movq	%rax, -48(%rsp)
	shlq	$4, %r9
	movq	%r9, 40(%rsp)
	movq	%r8, %r9
	shlq	$5, %r9
	movq	%r8, %r13
	shlq	$4, %r13
	movq	%r8, %rax
	andq	$-4, %rax
	movq	%rax, -40(%rsp)
	movq	%rbx, %rax
	movq	%rcx, %r10
	movq	%rcx, -64(%rsp)
	.align	4, 0x90
LBB0_41:
	movq	%rax, 32(%rsp)
	movq	16(%rsp), %r11
	movq	%r11, %rdx
	movq	24(%rsp), %rsi
	movq	%rsi, %rbx
	movq	%rax, %rcx
	movq	%rsi, %rbp
	movq	%r11, %rsi
	cmpq	$4, %r11
	jbe	LBB0_42
	.align	4, 0x90
LBB0_88:
	vxorpd	%xmm2, %xmm2, %xmm2
	xorl	%ecx, %ecx
	vxorpd	%xmm3, %xmm3, %xmm3
	vxorpd	%xmm4, %xmm4, %xmm4
	vxorpd	%xmm5, %xmm5, %xmm5
	movq	%r8, %rdx
	.align	4, 0x90
LBB0_89:
	vmovapd	(%rbp,%rcx,2), %xmm0
	vmovapd	16(%rbp,%rcx,2), %xmm6
	vmovddup	(%r14,%rcx), %xmm7
	vmovddup	8(%r14,%rcx), %xmm1
	vfmadd231pd	%xmm7, %xmm0, %xmm5
	vfmadd231pd	%xmm7, %xmm6, %xmm4
	vfmadd231pd	%xmm1, %xmm0, %xmm3
	vfmadd231pd	%xmm1, %xmm6, %xmm2
	addq	$16, %rcx
	addq	$-1, %rdx
	jne	LBB0_89
	vfmadd213pd	(%rax), %xmm8, %xmm5
	vmovupd	%xmm5, (%rax)
	vfmadd213pd	16(%rax), %xmm8, %xmm4
	vmovupd	%xmm4, 16(%rax)
	vfmadd213pd	(%rax,%rdi,8), %xmm8, %xmm3
	vmovupd	%xmm3, (%rax,%rdi,8)
	vfmadd213pd	16(%rax,%rdi,8), %xmm8, %xmm2
	vmovupd	%xmm2, 16(%rax,%rdi,8)
	addq	$-4, %rsi
	addq	$32, %rax
	addq	%r9, %rbp
	cmpq	$4, %rsi
	ja	LBB0_88
	movq	-8(%rsp), %rdx
	movq	(%rsp), %rbx
	movq	%r12, %rcx
LBB0_42:
	cmpq	$3, %rdx
	jb	LBB0_48
	leaq	-3(%rdx), %rax
	shrq	%rax
	leaq	(%rax,%rax), %r11
	shlq	$4, %rax
	leaq	16(%rcx,%rax), %rsi
	movq	%rsi, 8(%rsp)
	leaq	-2(%rdx), %r15
	addq	$16, %rax
	imulq	%r8, %rax
	addq	%rbx, %rax
	.align	4, 0x90
LBB0_44:
	vxorpd	%xmm2, %xmm2, %xmm2
	xorl	%ebp, %ebp
	vxorpd	%xmm3, %xmm3, %xmm3
	movq	%r8, %rsi
	.align	4, 0x90
LBB0_45:
	vmovapd	(%rbx,%rbp), %xmm0
	vmovddup	(%r14,%rbp), %xmm1
	vmovddup	8(%r14,%rbp), %xmm4
	vfmadd231pd	%xmm1, %xmm0, %xmm3
	vfmadd231pd	%xmm4, %xmm0, %xmm2
	addq	$16, %rbp
	addq	$-1, %rsi
	jne	LBB0_45
	vfmadd213pd	(%rcx), %xmm8, %xmm3
	vmovupd	%xmm3, (%rcx)
	vfmadd213pd	(%rcx,%rdi,8), %xmm8, %xmm2
	vmovupd	%xmm2, (%rcx,%rdi,8)
	addq	$-2, %rdx
	addq	$16, %rcx
	addq	%r13, %rbx
	cmpq	$2, %rdx
	ja	LBB0_44
	subq	%r11, %r15
	movq	%r15, %rdx
	movq	%rax, %rbx
	movq	8(%rsp), %rcx
LBB0_48:
	cmpq	$2, %rdx
	jb	LBB0_100
	movq	%r8, %rax
	testq	%rax, %rax
	je	LBB0_50
	movq	%rax, %rdx
	andq	$-4, %rdx
	movq	%rax, %r8
	vxorpd	%ymm2, %ymm2, %ymm2
	movq	%rax, %r15
	andq	$-4, %r8
	je	LBB0_93
	movq	%rax, %rbp
	subq	%rdx, %r15
	shlq	$4, %rdx
	addq	%r14, %rdx
	leaq	(%rbx,%r8,8), %r11
	movq	-40(%rsp), %rax
	movl	$24, %esi
	vxorpd	%ymm3, %ymm3, %ymm3
	.align	4, 0x90
LBB0_95:
	vmovsd	-8(%rbx,%rsi), %xmm0
	vmovhpd	(%rbx,%rsi), %xmm0, %xmm0
	vmovupd	-24(%rbx,%rsi), %xmm1
	vinsertf128	$1, %xmm0, %ymm1, %ymm0
	vmovsd	-16(%r14,%rsi,2), %xmm1
	vmovhpd	(%r14,%rsi,2), %xmm1, %xmm1
	vmovsd	-48(%r14,%rsi,2), %xmm4
	vmovhpd	-32(%r14,%rsi,2), %xmm4, %xmm4
	vinsertf128	$1, %xmm1, %ymm4, %ymm1
	vmovsd	-8(%r14,%rsi,2), %xmm4
	vmovhpd	8(%r14,%rsi,2), %xmm4, %xmm4
	vmovsd	-40(%r14,%rsi,2), %xmm5
	vmovhpd	-24(%r14,%rsi,2), %xmm5, %xmm5
	vinsertf128	$1, %xmm4, %ymm5, %ymm4
	vfmadd231pd	%ymm0, %ymm1, %ymm3
	vfmadd231pd	%ymm0, %ymm4, %ymm2
	addq	$32, %rsi
	addq	$-4, %rax
	jne	LBB0_95
	movq	%rbp, %rax
	jmp	LBB0_97
LBB0_50:
	vxorpd	%xmm2, %xmm2, %xmm2
	vxorpd	%xmm3, %xmm3, %xmm3
	movq	%rax, %r15
	movq	%rax, %r8
	movq	%r14, %rdx
	movq	%rbx, %r11
	jmp	LBB0_98
LBB0_93:
	movq	%r14, %rdx
	movq	%rbx, %r11
	xorl	%r8d, %r8d
	vxorpd	%ymm3, %ymm3, %ymm3
LBB0_97:
	vextractf128	$1, %ymm3, %xmm0
	vaddpd	%ymm0, %ymm3, %ymm0
	vhaddpd	%ymm0, %ymm0, %ymm3
	vextractf128	$1, %ymm2, %xmm0
	vaddpd	%ymm0, %ymm2, %ymm0
	vhaddpd	%ymm0, %ymm0, %ymm2
	cmpq	%rax, %r8
	movq	%rax, %r8
	je	LBB0_99
	.align	4, 0x90
LBB0_98:
	vmovsd	(%r11), %xmm0
	vfmadd231sd	(%rdx), %xmm0, %xmm3
	vfmadd231sd	8(%rdx), %xmm0, %xmm2
	addq	$8, %r11
	addq	$16, %rdx
	addq	$-1, %r15
	jne	LBB0_98
LBB0_99:
	vfmadd213sd	(%rcx), %xmm15, %xmm3
	vmovsd	%xmm3, (%rcx)
	vfmadd213sd	(%rcx,%rdi,8), %xmm15, %xmm2
	vmovsd	%xmm2, (%rcx,%rdi,8)
LBB0_100:
	addq	$-2, %r10
	movq	32(%rsp), %rax
	movq	48(%rsp), %rcx
	leaq	(%rax,%rcx,8), %rax
	addq	40(%rsp), %r14
	leaq	(%r12,%rcx,8), %r12
	cmpq	$2, %r10
	ja	LBB0_41
	movq	-64(%rsp), %rcx
	addq	$-2, %rcx
	subq	-48(%rsp), %rcx
	movq	-72(%rsp), %r14
	movq	-56(%rsp), %rbx
	movq	24(%rsp), %r10
	movq	16(%rsp), %r9
LBB0_65:
	cmpq	$2, %rcx
	jb	LBB0_118
	vunpcklpd	%xmm15, %xmm15, %xmm1
	cmpq	$4, %r9
	jbe	LBB0_101
	leaq	-5(%r9), %r13
	shrq	$2, %r13
	leaq	(,%r13,4), %rax
	leaq	4(,%r13,4), %r11
	leaq	32(%rbx,%rax,8), %rdx
	leaq	-4(%r9), %rcx
	subq	%rax, %rcx
	shlq	$5, %r13
	addq	$32, %r13
	imulq	%r8, %r13
	movq	%rbx, %rsi
	movq	%r10, %rbx
	leaq	(%rbx,%r13), %r10
	movq	%r9, %rax
	movq	%rbx, %rdi
	movq	%rbx, %r12
	movq	%rsi, %rbp
	movq	%rsi, %r15
	.align	4, 0x90
LBB0_68:
	vxorpd	%xmm2, %xmm2, %xmm2
	xorl	%esi, %esi
	vxorpd	%xmm3, %xmm3, %xmm3
	movq	%rdi, %rbx
	.align	4, 0x90
LBB0_69:
	vmovddup	(%r14,%rsi,8), %xmm0
	vfmadd231pd	(%rbx), %xmm0, %xmm3
	vfmadd231pd	16(%rbx), %xmm0, %xmm2
	addq	$1, %rsi
	addq	$32, %rbx
	cmpq	%rsi, %r8
	jne	LBB0_69
	movq	%r8, %rsi
	shlq	$5, %rsi
	vfmadd213pd	(%rbp), %xmm1, %xmm3
	addq	%rsi, %rdi
	vmovupd	%xmm3, (%rbp)
	vfmadd213pd	16(%rbp), %xmm1, %xmm2
	vmovupd	%xmm2, 16(%rbp)
	addq	$-4, %rax
	addq	$32, %rbp
	cmpq	$4, %rax
	ja	LBB0_68
	cmpq	$2, %rcx
	jbe	LBB0_77
	leaq	-3(%rcx), %rax
	shrq	%rax
	leaq	(%r15,%r11,8), %rsi
	movq	%rax, %rdi
	shlq	$4, %rdi
	leaq	(%rax,%rax), %r10
	leaq	16(%rdi,%rsi), %r11
	addq	$16, %rdi
	imulq	%r8, %rdi
	addq	%rdi, %r13
	leaq	-40(,%r9,8), %rdi
	andq	$-32, %rdi
	addq	$32, %rdi
	imulq	%r8, %rdi
	addq	%r12, %r13
	addq	%r12, %rdi
	movq	%r8, %rbp
	shlq	$4, %rbp
	leaq	-2(%rcx), %rbx
	.align	4, 0x90
LBB0_73:
	vxorpd	%xmm2, %xmm2, %xmm2
	xorl	%esi, %esi
	movq	%r8, %rax
	.align	4, 0x90
LBB0_74:
	vmovddup	(%r14,%rsi), %xmm0
	vfmadd231pd	(%rdi,%rsi,2), %xmm0, %xmm2
	addq	$8, %rsi
	addq	$-1, %rax
	jne	LBB0_74
	vfmadd213pd	(%rdx), %xmm1, %xmm2
	vmovupd	%xmm2, (%rdx)
	addq	$-2, %rcx
	addq	$16, %rdx
	addq	%rbp, %rdi
	cmpq	$2, %rcx
	ja	LBB0_73
	subq	%r10, %rbx
	movq	%rbx, %rcx
	movq	%r13, %r10
	movq	%r11, %rdx
LBB0_77:
	cmpq	$1, %rcx
	jbe	LBB0_118
	testq	%r8, %r8
	je	LBB0_79
	movq	%r8, %rcx
	andq	$-8, %rcx
	xorl	%eax, %eax
	movq	%r8, %rbx
	andq	$-8, %rbx
	je	LBB0_83
	movq	%r8, %rbp
	subq	%rcx, %rbp
	leaq	(%r14,%rbx,8), %rcx
	leaq	(%r10,%rbx,8), %rsi
	addq	$56, %r10
	addq	$56, %r14
	vxorpd	%ymm1, %ymm1, %ymm1
	movq	%rbx, %rax
	vxorpd	%ymm2, %ymm2, %ymm2
	.align	4, 0x90
LBB0_85:
	vmovupd	-56(%r10), %ymm0
	vmovupd	-24(%r10), %xmm3
	vmovsd	-8(%r10), %xmm4
	vmovhpd	(%r10), %xmm4, %xmm4
	vinsertf128	$1, %xmm4, %ymm3, %ymm3
	vmovupd	-24(%r14), %xmm4
	vmovsd	-8(%r14), %xmm5
	vmovhpd	(%r14), %xmm5, %xmm5
	vinsertf128	$1, %xmm5, %ymm4, %ymm4
	vfmadd231pd	-56(%r14), %ymm0, %ymm1
	vfmadd231pd	%ymm3, %ymm4, %ymm2
	addq	$64, %r10
	addq	$64, %r14
	addq	$-8, %rax
	jne	LBB0_85
	movq	%rbx, %rax
	jmp	LBB0_87
LBB0_101:
	cmpq	$3, %r9
	jb	LBB0_107
	leaq	-3(%r9), %rcx
	shrq	%rcx
	leaq	(%rcx,%rcx), %rdx
	shlq	$4, %rcx
	leaq	16(%rcx,%rbx), %r11
	movq	%rbx, %rsi
	negq	%rdx
	leaq	-2(%r9,%rdx), %rdx
	addq	$16, %rcx
	imulq	%r8, %rcx
	addq	%r10, %rcx
	movq	%r8, %rax
	shlq	$4, %rax
	.align	4, 0x90
LBB0_103:
	vxorpd	%xmm2, %xmm2, %xmm2
	xorl	%edi, %edi
	movq	%r8, %rbp
	.align	4, 0x90
LBB0_104:
	vmovddup	(%r14,%rdi), %xmm0
	vfmadd231pd	(%r10,%rdi,2), %xmm0, %xmm2
	addq	$8, %rdi
	addq	$-1, %rbp
	jne	LBB0_104
	vfmadd213pd	(%rsi), %xmm1, %xmm2
	vmovupd	%xmm2, (%rsi)
	addq	$-2, %r9
	addq	$16, %rsi
	addq	%rax, %r10
	cmpq	$2, %r9
	ja	LBB0_103
	movq	%rdx, %r9
	movq	%rcx, %r10
	movq	%r11, %rbx
LBB0_107:
	cmpq	$2, %r9
	jb	LBB0_118
	testq	%r8, %r8
	je	LBB0_109
	movq	%r8, %rcx
	andq	$-8, %rcx
	xorl	%edi, %edi
	movq	%r8, %rax
	movq	%rbx, %rsi
	andq	$-8, %rax
	je	LBB0_111
	movq	%r8, %rbx
	subq	%rcx, %rbx
	leaq	(%r14,%rax,8), %rcx
	leaq	(%r10,%rax,8), %rdx
	addq	$56, %r10
	addq	$56, %r14
	vxorpd	%ymm1, %ymm1, %ymm1
	movq	%rax, %rdi
	vxorpd	%ymm2, %ymm2, %ymm2
	.align	4, 0x90
LBB0_113:
	vmovupd	-56(%r10), %ymm0
	vmovupd	-24(%r10), %xmm3
	vmovsd	-8(%r10), %xmm4
	vmovhpd	(%r10), %xmm4, %xmm4
	vinsertf128	$1, %xmm4, %ymm3, %ymm3
	vmovupd	-24(%r14), %xmm4
	vmovsd	-8(%r14), %xmm5
	vmovhpd	(%r14), %xmm5, %xmm5
	vinsertf128	$1, %xmm5, %ymm4, %ymm4
	vfmadd231pd	-56(%r14), %ymm0, %ymm1
	vfmadd231pd	%ymm3, %ymm4, %ymm2
	addq	$64, %r10
	addq	$64, %r14
	addq	$-8, %rdi
	jne	LBB0_113
	movq	%rax, %rdi
	jmp	LBB0_115
LBB0_79:
	vxorpd	%xmm1, %xmm1, %xmm1
	movq	%r14, %rcx
	movq	%r10, %rsi
	jmp	LBB0_80
LBB0_109:
	vxorpd	%xmm1, %xmm1, %xmm1
	movq	%r14, %rcx
	movq	%r10, %rdx
	jmp	LBB0_116
LBB0_83:
	vxorpd	%ymm1, %ymm1, %ymm1
	movq	%r8, %rbp
	movq	%r14, %rcx
	movq	%r10, %rsi
	vxorpd	%ymm2, %ymm2, %ymm2
LBB0_87:
	vaddpd	%ymm1, %ymm2, %ymm0
	vextractf128	$1, %ymm0, %xmm1
	vaddpd	%ymm1, %ymm0, %ymm0
	vhaddpd	%ymm0, %ymm0, %ymm1
	cmpq	%r8, %rax
	movq	%rbp, %r8
	je	LBB0_81
	.align	4, 0x90
LBB0_80:
	vmovsd	(%rsi), %xmm0
	vfmadd231sd	(%rcx), %xmm0, %xmm1
	addq	$8, %rsi
	addq	$8, %rcx
	addq	$-1, %r8
	jne	LBB0_80
LBB0_81:
	vfmadd213sd	(%rdx), %xmm15, %xmm1
	vmovsd	%xmm1, (%rdx)
	jmp	LBB0_118
LBB0_111:
	vxorpd	%ymm1, %ymm1, %ymm1
	movq	%r8, %rbx
	movq	%r14, %rcx
	movq	%r10, %rdx
	vxorpd	%ymm2, %ymm2, %ymm2
LBB0_115:
	vaddpd	%ymm1, %ymm2, %ymm0
	vextractf128	$1, %ymm0, %xmm1
	vaddpd	%ymm1, %ymm0, %ymm0
	vhaddpd	%ymm0, %ymm0, %ymm1
	cmpq	%r8, %rdi
	movq	%rbx, %r8
	movq	%rsi, %rbx
	je	LBB0_117
	.align	4, 0x90
LBB0_116:
	vmovsd	(%rdx), %xmm0
	vfmadd231sd	(%rcx), %xmm0, %xmm1
	addq	$8, %rdx
	addq	$8, %rcx
	addq	$-1, %r8
	jne	LBB0_116
LBB0_117:
	vfmadd213sd	(%rbx), %xmm15, %xmm1
	vmovsd	%xmm1, (%rbx)
LBB0_118:
	addq	$72, %rsp
	popq	%rbx
	popq	%r12
	popq	%r13
	popq	%r14
	popq	%r15
	popq	%rbp
	vzeroupper
	retq
	.cfi_endproc

	.globl	__D3mir4blas8internal12micro_kernel79__T17gemm_micro_kernelVE3mir4blas6common14Multiplicationi0Vmi1Vmi2Vmi6TNhG2dTdZ17gemm_micro_kernelFNaNbNiG1dPxG1G2NhG2dPxG6G1dmPG1dlZPxd
	.weak_definition	__D3mir4blas8internal12micro_kernel79__T17gemm_micro_kernelVE3mir4blas6common14Multiplicationi0Vmi1Vmi2Vmi6TNhG2dTdZ17gemm_micro_kernelFNaNbNiG1dPxG1G2NhG2dPxG6G1dmPG1dlZPxd
	.align	4, 0x90
__D3mir4blas8internal12micro_kernel79__T17gemm_micro_kernelVE3mir4blas6common14Multiplicationi0Vmi1Vmi2Vmi6TNhG2dTdZ17gemm_micro_kernelFNaNbNiG1dPxG1G2NhG2dPxG6G1dmPG1dlZPxd:
	.cfi_startproc
	vxorpd	%xmm8, %xmm8, %xmm8
	vxorpd	%xmm9, %xmm9, %xmm9
	vxorpd	%xmm10, %xmm10, %xmm10
	vxorpd	%xmm11, %xmm11, %xmm11
	vxorpd	%xmm12, %xmm12, %xmm12
	vxorpd	%xmm13, %xmm13, %xmm13
	vxorpd	%xmm14, %xmm14, %xmm14
	vxorpd	%xmm15, %xmm15, %xmm15
	vxorpd	%xmm2, %xmm2, %xmm2
	vxorpd	%xmm3, %xmm3, %xmm3
	vxorpd	%xmm4, %xmm4, %xmm4
	vxorpd	%xmm5, %xmm5, %xmm5
	movq	%rdx, %r9
	movq	%r8, %rax
	.align	4, 0x90
LBB1_1:
	vmovapd	(%rax), %xmm6
	vmovapd	16(%rax), %xmm7
	vmovddup	(%rcx), %xmm1
	vfmadd231pd	%xmm1, %xmm6, %xmm5
	vfmadd231pd	%xmm1, %xmm7, %xmm4
	vmovddup	8(%rcx), %xmm1
	vfmadd231pd	%xmm1, %xmm6, %xmm3
	vfmadd231pd	%xmm1, %xmm7, %xmm2
	vmovddup	16(%rcx), %xmm1
	vfmadd231pd	%xmm1, %xmm6, %xmm15
	vfmadd231pd	%xmm1, %xmm7, %xmm14
	vmovddup	24(%rcx), %xmm1
	vfmadd231pd	%xmm1, %xmm6, %xmm13
	vfmadd231pd	%xmm1, %xmm7, %xmm12
	vmovddup	32(%rcx), %xmm1
	vfmadd231pd	%xmm1, %xmm6, %xmm11
	vfmadd231pd	%xmm1, %xmm7, %xmm10
	vmovddup	40(%rcx), %xmm1
	vfmadd231pd	%xmm1, %xmm6, %xmm9
	vfmadd231pd	%xmm1, %xmm7, %xmm8
	addq	$32, %rax
	addq	$48, %rcx
	addq	$-1, %r9
	jne	LBB1_1
	vunpcklpd	%xmm0, %xmm0, %xmm0
	vfmadd213pd	(%rsi), %xmm0, %xmm5
	vmovupd	%xmm5, (%rsi)
	vfmadd213pd	16(%rsi), %xmm0, %xmm4
	vmovupd	%xmm4, 16(%rsi)
	vfmadd213pd	(%rsi,%rdi,8), %xmm0, %xmm3
	vmovupd	%xmm3, (%rsi,%rdi,8)
	vfmadd213pd	16(%rsi,%rdi,8), %xmm0, %xmm2
	vmovupd	%xmm2, 16(%rsi,%rdi,8)
	movq	%rdi, %rax
	shlq	$4, %rax
	vfmadd213pd	(%rsi,%rax), %xmm0, %xmm15
	vmovupd	%xmm15, (%rsi,%rax)
	vfmadd213pd	16(%rsi,%rax), %xmm0, %xmm14
	vmovupd	%xmm14, 16(%rsi,%rax)
	leaq	(%rdi,%rdi,2), %rax
	vfmadd213pd	(%rsi,%rax,8), %xmm0, %xmm13
	shlq	$5, %rdx
	vmovupd	%xmm13, (%rsi,%rax,8)
	vfmadd213pd	16(%rsi,%rax,8), %xmm0, %xmm12
	vmovupd	%xmm12, 16(%rsi,%rax,8)
	movq	%rdi, %rax
	shlq	$5, %rax
	vfmadd213pd	(%rsi,%rax), %xmm0, %xmm11
	addq	%rdx, %r8
	vmovupd	%xmm11, (%rsi,%rax)
	vfmadd213pd	16(%rsi,%rax), %xmm0, %xmm10
	vmovupd	%xmm10, 16(%rsi,%rax)
	leaq	(%rdi,%rdi,4), %rax
	vfmadd213pd	(%rsi,%rax,8), %xmm0, %xmm9
	vmovupd	%xmm9, (%rsi,%rax,8)
	vfmadd213pd	16(%rsi,%rax,8), %xmm0, %xmm8
	vmovupd	%xmm8, 16(%rsi,%rax,8)
	movq	%r8, %rax
	retq
	.cfi_endproc

	.globl	__D3mir4blas8internal12micro_kernel79__T17gemm_micro_kernelVE3mir4blas6common14Multiplicationi0Vmi1Vmi1Vmi6TNhG2dTdZ17gemm_micro_kernelFNaNbNiG1dPxG1G1NhG2dPxG6G1dmPG1dlZPxd
	.weak_definition	__D3mir4blas8internal12micro_kernel79__T17gemm_micro_kernelVE3mir4blas6common14Multiplicationi0Vmi1Vmi1Vmi6TNhG2dTdZ17gemm_micro_kernelFNaNbNiG1dPxG1G1NhG2dPxG6G1dmPG1dlZPxd
	.align	4, 0x90
__D3mir4blas8internal12micro_kernel79__T17gemm_micro_kernelVE3mir4blas6common14Multiplicationi0Vmi1Vmi1Vmi6TNhG2dTdZ17gemm_micro_kernelFNaNbNiG1dPxG1G1NhG2dPxG6G1dmPG1dlZPxd:
	.cfi_startproc
	vxorpd	%xmm8, %xmm8, %xmm8
	vxorpd	%xmm9, %xmm9, %xmm9
	vxorpd	%xmm3, %xmm3, %xmm3
	vxorpd	%xmm4, %xmm4, %xmm4
	vxorpd	%xmm5, %xmm5, %xmm5
	vxorpd	%xmm6, %xmm6, %xmm6
	movq	%rdx, %r9
	movq	%r8, %rax
	.align	4, 0x90
LBB2_1:
	vmovapd	(%rax), %xmm7
	vmovddup	(%rcx), %xmm1
	vmovddup	8(%rcx), %xmm2
	vmovddup	16(%rcx), %xmm10
	vmovddup	24(%rcx), %xmm11
	vmovddup	32(%rcx), %xmm12
	vmovddup	40(%rcx), %xmm13
	vfmadd231pd	%xmm1, %xmm7, %xmm6
	vfmadd231pd	%xmm2, %xmm7, %xmm5
	vfmadd231pd	%xmm10, %xmm7, %xmm4
	vfmadd231pd	%xmm11, %xmm7, %xmm3
	vfmadd231pd	%xmm12, %xmm7, %xmm9
	vfmadd231pd	%xmm13, %xmm7, %xmm8
	addq	$16, %rax
	addq	$48, %rcx
	addq	$-1, %r9
	jne	LBB2_1
	shlq	$4, %rdx
	addq	%rdx, %r8
	vunpcklpd	%xmm0, %xmm0, %xmm0
	vfmadd213pd	(%rsi), %xmm0, %xmm6
	vmovupd	%xmm6, (%rsi)
	vfmadd213pd	(%rsi,%rdi,8), %xmm0, %xmm5
	vmovupd	%xmm5, (%rsi,%rdi,8)
	movq	%rdi, %rax
	shlq	$4, %rax
	vfmadd213pd	(%rsi,%rax), %xmm0, %xmm4
	vmovupd	%xmm4, (%rsi,%rax)
	leaq	(%rdi,%rdi,2), %rax
	vfmadd213pd	(%rsi,%rax,8), %xmm0, %xmm3
	vmovupd	%xmm3, (%rsi,%rax,8)
	movq	%rdi, %rax
	shlq	$5, %rax
	vfmadd213pd	(%rsi,%rax), %xmm0, %xmm9
	vmovupd	%xmm9, (%rsi,%rax)
	leaq	(%rdi,%rdi,4), %rax
	vfmadd213pd	(%rsi,%rax,8), %xmm0, %xmm8
	vmovupd	%xmm8, (%rsi,%rax,8)
	movq	%r8, %rax
	retq
	.cfi_endproc

	.globl	__D3mir4blas8internal12micro_kernel75__T17gemm_micro_kernelVE3mir4blas6common14Multiplicationi0Vmi1Vmi1Vmi6TdTdZ17gemm_micro_kernelFNaNbNiG1dPxG1G1dPxG6G1dmPG1dlZPxd
	.weak_definition	__D3mir4blas8internal12micro_kernel75__T17gemm_micro_kernelVE3mir4blas6common14Multiplicationi0Vmi1Vmi1Vmi6TdTdZ17gemm_micro_kernelFNaNbNiG1dPxG1G1dPxG6G1dmPG1dlZPxd
	.align	4, 0x90
__D3mir4blas8internal12micro_kernel75__T17gemm_micro_kernelVE3mir4blas6common14Multiplicationi0Vmi1Vmi1Vmi6TdTdZ17gemm_micro_kernelFNaNbNiG1dPxG1G1dPxG6G1dmPG1dlZPxd:
	.cfi_startproc
	pushq	%r14
Ltmp13:
	.cfi_def_cfa_offset 16
	pushq	%rbx
Ltmp14:
	.cfi_def_cfa_offset 24
Ltmp15:
	.cfi_offset %rbx, -24
Ltmp16:
	.cfi_offset %r14, -16
	vxorpd	%xmm1, %xmm1, %xmm1
	testq	%rdx, %rdx
	je	LBB3_1
	movq	%rdx, %rax
	andq	$-4, %rax
	movq	%rdx, %r10
	vxorpd	%ymm10, %ymm10, %ymm10
	movq	%rdx, %r9
	andq	$-4, %r10
	je	LBB3_3
	subq	%rax, %r9
	leaq	(%rax,%rax,2), %r11
	shlq	$4, %r11
	addq	%rcx, %r11
	leaq	(%r8,%r10,8), %r14
	addq	$184, %rcx
	leaq	24(%r8), %rbx
	vxorpd	%ymm10, %ymm10, %ymm10
	movq	%r10, %rax
	vxorpd	%ymm11, %ymm11, %ymm11
	vxorpd	%ymm12, %ymm12, %ymm12
	vxorpd	%ymm14, %ymm14, %ymm14
	vxorpd	%ymm5, %ymm5, %ymm5
	vxorpd	%ymm6, %ymm6, %ymm6
	.align	4, 0x90
LBB3_5:
	vmovupd	-24(%rbx), %xmm7
	vmovsd	-8(%rbx), %xmm1
	vmovhpd	(%rbx), %xmm1, %xmm1
	vinsertf128	$1, %xmm1, %ymm7, %ymm7
	vmovsd	-88(%rcx), %xmm1
	vmovhpd	-40(%rcx), %xmm1, %xmm1
	vmovsd	-184(%rcx), %xmm2
	vmovsd	-176(%rcx), %xmm3
	vmovhpd	-136(%rcx), %xmm2, %xmm2
	vinsertf128	$1, %xmm1, %ymm2, %ymm8
	vmovsd	-80(%rcx), %xmm1
	vmovhpd	-32(%rcx), %xmm1, %xmm1
	vmovhpd	-128(%rcx), %xmm3, %xmm2
	vinsertf128	$1, %xmm1, %ymm2, %ymm9
	vmovsd	-72(%rcx), %xmm1
	vmovhpd	-24(%rcx), %xmm1, %xmm1
	vmovsd	-168(%rcx), %xmm2
	vmovhpd	-120(%rcx), %xmm2, %xmm2
	vinsertf128	$1, %xmm1, %ymm2, %ymm13
	vmovsd	-64(%rcx), %xmm2
	vmovhpd	-16(%rcx), %xmm2, %xmm2
	vmovsd	-160(%rcx), %xmm3
	vmovhpd	-112(%rcx), %xmm3, %xmm3
	vinsertf128	$1, %xmm2, %ymm3, %ymm2
	vmovsd	-56(%rcx), %xmm3
	vmovhpd	-8(%rcx), %xmm3, %xmm3
	vmovsd	-152(%rcx), %xmm1
	vmovhpd	-104(%rcx), %xmm1, %xmm1
	vinsertf128	$1, %xmm3, %ymm1, %ymm1
	vmovsd	-48(%rcx), %xmm3
	vmovhpd	(%rcx), %xmm3, %xmm3
	vmovsd	-144(%rcx), %xmm4
	vmovhpd	-96(%rcx), %xmm4, %xmm4
	vinsertf128	$1, %xmm3, %ymm4, %ymm3
	vfmadd231pd	%ymm7, %ymm8, %ymm6
	vfmadd231pd	%ymm7, %ymm9, %ymm5
	vfmadd231pd	%ymm7, %ymm13, %ymm14
	vfmadd231pd	%ymm7, %ymm2, %ymm12
	vfmadd231pd	%ymm7, %ymm1, %ymm11
	vfmadd231pd	%ymm7, %ymm3, %ymm10
	addq	$192, %rcx
	addq	$32, %rbx
	addq	$-4, %rax
	jne	LBB3_5
	jmp	LBB3_6
LBB3_1:
	vxorpd	%xmm2, %xmm2, %xmm2
	vxorpd	%xmm3, %xmm3, %xmm3
	vxorpd	%xmm4, %xmm4, %xmm4
	vxorpd	%xmm5, %xmm5, %xmm5
	vxorpd	%xmm6, %xmm6, %xmm6
	movq	%rdx, %r9
	movq	%r8, %r14
	jmp	LBB3_7
LBB3_3:
	movq	%rcx, %r11
	movq	%r8, %r14
	movl	$0, %r10d
	vxorpd	%ymm11, %ymm11, %ymm11
	vxorpd	%ymm12, %ymm12, %ymm12
	vxorpd	%ymm14, %ymm14, %ymm14
	vxorpd	%ymm5, %ymm5, %ymm5
	vxorpd	%ymm6, %ymm6, %ymm6
LBB3_6:
	vextractf128	$1, %ymm6, %xmm1
	vaddpd	%ymm1, %ymm6, %ymm1
	vhaddpd	%ymm1, %ymm1, %ymm6
	vextractf128	$1, %ymm5, %xmm1
	vaddpd	%ymm1, %ymm5, %ymm1
	vhaddpd	%ymm1, %ymm1, %ymm5
	vextractf128	$1, %ymm14, %xmm1
	vaddpd	%ymm1, %ymm14, %ymm1
	vhaddpd	%ymm1, %ymm1, %ymm4
	vextractf128	$1, %ymm12, %xmm1
	vaddpd	%ymm1, %ymm12, %ymm1
	vhaddpd	%ymm1, %ymm1, %ymm3
	vextractf128	$1, %ymm11, %xmm1
	vaddpd	%ymm1, %ymm11, %ymm1
	vhaddpd	%ymm1, %ymm1, %ymm2
	vextractf128	$1, %ymm10, %xmm1
	vaddpd	%ymm1, %ymm10, %ymm1
	vhaddpd	%ymm1, %ymm1, %ymm1
	movq	%r11, %rcx
	cmpq	%rdx, %r10
	je	LBB3_8
	.align	4, 0x90
LBB3_7:
	vmovsd	(%r14), %xmm7
	vfmadd231sd	(%rcx), %xmm7, %xmm6
	vfmadd231sd	8(%rcx), %xmm7, %xmm5
	vfmadd231sd	16(%rcx), %xmm7, %xmm4
	vfmadd231sd	24(%rcx), %xmm7, %xmm3
	vfmadd231sd	32(%rcx), %xmm7, %xmm2
	vfmadd231sd	40(%rcx), %xmm7, %xmm1
	addq	$8, %r14
	addq	$48, %rcx
	addq	$-1, %r9
	jne	LBB3_7
LBB3_8:
	leaq	(%r8,%rdx,8), %rax
	vfmadd213sd	(%rsi), %xmm0, %xmm6
	vmovsd	%xmm6, (%rsi)
	vfmadd213sd	(%rsi,%rdi,8), %xmm0, %xmm5
	vmovsd	%xmm5, (%rsi,%rdi,8)
	movq	%rdi, %rcx
	shlq	$4, %rcx
	vfmadd213sd	(%rsi,%rcx), %xmm0, %xmm4
	vmovsd	%xmm4, (%rsi,%rcx)
	leaq	(%rdi,%rdi,2), %rcx
	vfmadd213sd	(%rsi,%rcx,8), %xmm0, %xmm3
	vmovsd	%xmm3, (%rsi,%rcx,8)
	movq	%rdi, %rcx
	shlq	$5, %rcx
	vfmadd213sd	(%rsi,%rcx), %xmm0, %xmm2
	vmovsd	%xmm2, (%rsi,%rcx)
	leaq	(%rdi,%rdi,4), %rcx
	vfmadd213sd	(%rsi,%rcx,8), %xmm0, %xmm1
	vmovsd	%xmm1, (%rsi,%rcx,8)
	popq	%rbx
	popq	%r14
	vzeroupper
	retq
	.cfi_endproc

	.globl	__D3mir4blas8internal12micro_kernel79__T17gemm_micro_kernelVE3mir4blas6common14Multiplicationi0Vmi1Vmi2Vmi4TNhG2dTdZ17gemm_micro_kernelFNaNbNiG1dPxG1G2NhG2dPxG4G1dmPG1dlZPxd
	.weak_definition	__D3mir4blas8internal12micro_kernel79__T17gemm_micro_kernelVE3mir4blas6common14Multiplicationi0Vmi1Vmi2Vmi4TNhG2dTdZ17gemm_micro_kernelFNaNbNiG1dPxG1G2NhG2dPxG4G1dmPG1dlZPxd
	.align	4, 0x90
__D3mir4blas8internal12micro_kernel79__T17gemm_micro_kernelVE3mir4blas6common14Multiplicationi0Vmi1Vmi2Vmi4TNhG2dTdZ17gemm_micro_kernelFNaNbNiG1dPxG1G2NhG2dPxG4G1dmPG1dlZPxd:
	.cfi_startproc
	vxorpd	%xmm8, %xmm8, %xmm8
	vxorpd	%xmm9, %xmm9, %xmm9
	vxorpd	%xmm10, %xmm10, %xmm10
	vxorpd	%xmm11, %xmm11, %xmm11
	vxorpd	%xmm12, %xmm12, %xmm12
	vxorpd	%xmm13, %xmm13, %xmm13
	vxorpd	%xmm14, %xmm14, %xmm14
	vxorpd	%xmm1, %xmm1, %xmm1
	movq	%rdx, %r9
	movq	%r8, %rax
	.align	4, 0x90
LBB4_1:
	vmovapd	(%rax), %xmm2
	vmovapd	16(%rax), %xmm3
	vmovddup	(%rcx), %xmm4
	vmovddup	8(%rcx), %xmm5
	vmovddup	16(%rcx), %xmm6
	vmovddup	24(%rcx), %xmm7
	vfmadd231pd	%xmm4, %xmm2, %xmm1
	vfmadd231pd	%xmm4, %xmm3, %xmm14
	vfmadd231pd	%xmm5, %xmm2, %xmm13
	vfmadd231pd	%xmm5, %xmm3, %xmm12
	vfmadd231pd	%xmm6, %xmm2, %xmm11
	vfmadd231pd	%xmm6, %xmm3, %xmm10
	vfmadd231pd	%xmm7, %xmm2, %xmm9
	vfmadd231pd	%xmm7, %xmm3, %xmm8
	addq	$32, %rax
	addq	$32, %rcx
	addq	$-1, %r9
	jne	LBB4_1
	vunpcklpd	%xmm0, %xmm0, %xmm0
	vfmadd213pd	(%rsi), %xmm0, %xmm1
	vmovupd	%xmm1, (%rsi)
	vfmadd213pd	16(%rsi), %xmm0, %xmm14
	vmovupd	%xmm14, 16(%rsi)
	vfmadd213pd	(%rsi,%rdi,8), %xmm0, %xmm13
	shlq	$5, %rdx
	vmovupd	%xmm13, (%rsi,%rdi,8)
	vfmadd213pd	16(%rsi,%rdi,8), %xmm0, %xmm12
	vmovupd	%xmm12, 16(%rsi,%rdi,8)
	movq	%rdi, %rax
	shlq	$4, %rax
	vfmadd213pd	(%rsi,%rax), %xmm0, %xmm11
	addq	%rdx, %r8
	vmovupd	%xmm11, (%rsi,%rax)
	vfmadd213pd	16(%rsi,%rax), %xmm0, %xmm10
	vmovupd	%xmm10, 16(%rsi,%rax)
	leaq	(%rdi,%rdi,2), %rax
	vfmadd213pd	(%rsi,%rax,8), %xmm0, %xmm9
	vmovupd	%xmm9, (%rsi,%rax,8)
	vfmadd213pd	16(%rsi,%rax,8), %xmm0, %xmm8
	vmovupd	%xmm8, 16(%rsi,%rax,8)
	movq	%r8, %rax
	retq
	.cfi_endproc

	.globl	__D3mir4blas8internal12micro_kernel79__T17gemm_micro_kernelVE3mir4blas6common14Multiplicationi0Vmi1Vmi1Vmi4TNhG2dTdZ17gemm_micro_kernelFNaNbNiG1dPxG1G1NhG2dPxG4G1dmPG1dlZPxd
	.weak_definition	__D3mir4blas8internal12micro_kernel79__T17gemm_micro_kernelVE3mir4blas6common14Multiplicationi0Vmi1Vmi1Vmi4TNhG2dTdZ17gemm_micro_kernelFNaNbNiG1dPxG1G1NhG2dPxG4G1dmPG1dlZPxd
	.align	4, 0x90
__D3mir4blas8internal12micro_kernel79__T17gemm_micro_kernelVE3mir4blas6common14Multiplicationi0Vmi1Vmi1Vmi4TNhG2dTdZ17gemm_micro_kernelFNaNbNiG1dPxG1G1NhG2dPxG4G1dmPG1dlZPxd:
	.cfi_startproc
	vxorpd	%xmm1, %xmm1, %xmm1
	vxorpd	%xmm2, %xmm2, %xmm2
	vxorpd	%xmm3, %xmm3, %xmm3
	vxorpd	%xmm4, %xmm4, %xmm4
	movq	%rdx, %r9
	movq	%r8, %rax
	.align	4, 0x90
LBB5_1:
	vmovapd	(%rax), %xmm5
	vmovddup	(%rcx), %xmm6
	vmovddup	8(%rcx), %xmm7
	vmovddup	16(%rcx), %xmm8
	vmovddup	24(%rcx), %xmm9
	vfmadd231pd	%xmm6, %xmm5, %xmm4
	vfmadd231pd	%xmm7, %xmm5, %xmm3
	vfmadd231pd	%xmm8, %xmm5, %xmm2
	vfmadd231pd	%xmm9, %xmm5, %xmm1
	addq	$16, %rax
	addq	$32, %rcx
	addq	$-1, %r9
	jne	LBB5_1
	shlq	$4, %rdx
	addq	%rdx, %r8
	vunpcklpd	%xmm0, %xmm0, %xmm0
	vfmadd213pd	(%rsi), %xmm0, %xmm4
	vmovupd	%xmm4, (%rsi)
	vfmadd213pd	(%rsi,%rdi,8), %xmm0, %xmm3
	vmovupd	%xmm3, (%rsi,%rdi,8)
	movq	%rdi, %rax
	shlq	$4, %rax
	vfmadd213pd	(%rsi,%rax), %xmm0, %xmm2
	vmovupd	%xmm2, (%rsi,%rax)
	leaq	(%rdi,%rdi,2), %rax
	vfmadd213pd	(%rsi,%rax,8), %xmm0, %xmm1
	vmovupd	%xmm1, (%rsi,%rax,8)
	movq	%r8, %rax
	retq
	.cfi_endproc

	.globl	__D3mir4blas8internal12micro_kernel75__T17gemm_micro_kernelVE3mir4blas6common14Multiplicationi0Vmi1Vmi1Vmi4TdTdZ17gemm_micro_kernelFNaNbNiG1dPxG1G1dPxG4G1dmPG1dlZPxd
	.weak_definition	__D3mir4blas8internal12micro_kernel75__T17gemm_micro_kernelVE3mir4blas6common14Multiplicationi0Vmi1Vmi1Vmi4TdTdZ17gemm_micro_kernelFNaNbNiG1dPxG1G1dPxG4G1dmPG1dlZPxd
	.align	4, 0x90
__D3mir4blas8internal12micro_kernel75__T17gemm_micro_kernelVE3mir4blas6common14Multiplicationi0Vmi1Vmi1Vmi4TdTdZ17gemm_micro_kernelFNaNbNiG1dPxG1G1dPxG4G1dmPG1dlZPxd:
	.cfi_startproc
	pushq	%r14
Ltmp17:
	.cfi_def_cfa_offset 16
	pushq	%rbx
Ltmp18:
	.cfi_def_cfa_offset 24
Ltmp19:
	.cfi_offset %rbx, -24
Ltmp20:
	.cfi_offset %r14, -16
	vxorpd	%xmm1, %xmm1, %xmm1
	testq	%rdx, %rdx
	je	LBB6_1
	movq	%rdx, %r10
	andq	$-4, %r10
	movq	%rdx, %r11
	vxorpd	%ymm8, %ymm8, %ymm8
	movq	%rdx, %r9
	andq	$-4, %r11
	je	LBB6_3
	subq	%r10, %r9
	shlq	$5, %r10
	addq	%rcx, %r10
	leaq	(%r8,%r11,8), %r14
	addq	$120, %rcx
	leaq	24(%r8), %rbx
	vxorpd	%ymm8, %ymm8, %ymm8
	movq	%r11, %rax
	vxorpd	%ymm2, %ymm2, %ymm2
	vxorpd	%ymm3, %ymm3, %ymm3
	vxorpd	%ymm4, %ymm4, %ymm4
	.align	4, 0x90
LBB6_5:
	vmovupd	-24(%rbx), %xmm5
	vmovsd	-8(%rbx), %xmm6
	vmovhpd	(%rbx), %xmm6, %xmm6
	vinsertf128	$1, %xmm6, %ymm5, %ymm5
	vmovsd	-56(%rcx), %xmm6
	vmovhpd	-24(%rcx), %xmm6, %xmm6
	vmovsd	-120(%rcx), %xmm7
	vmovsd	-112(%rcx), %xmm1
	vmovhpd	-88(%rcx), %xmm7, %xmm7
	vinsertf128	$1, %xmm6, %ymm7, %ymm9
	vmovsd	-48(%rcx), %xmm7
	vmovhpd	-16(%rcx), %xmm7, %xmm7
	vmovhpd	-80(%rcx), %xmm1, %xmm1
	vinsertf128	$1, %xmm7, %ymm1, %ymm10
	vmovsd	-40(%rcx), %xmm7
	vmovhpd	-8(%rcx), %xmm7, %xmm7
	vmovsd	-104(%rcx), %xmm6
	vmovhpd	-72(%rcx), %xmm6, %xmm6
	vinsertf128	$1, %xmm7, %ymm6, %ymm6
	vmovsd	-32(%rcx), %xmm7
	vmovhpd	(%rcx), %xmm7, %xmm7
	vmovsd	-96(%rcx), %xmm1
	vmovhpd	-64(%rcx), %xmm1, %xmm1
	vinsertf128	$1, %xmm7, %ymm1, %ymm1
	vfmadd231pd	%ymm5, %ymm9, %ymm4
	vfmadd231pd	%ymm5, %ymm10, %ymm3
	vfmadd231pd	%ymm5, %ymm6, %ymm2
	vfmadd231pd	%ymm5, %ymm1, %ymm8
	subq	$-128, %rcx
	addq	$32, %rbx
	addq	$-4, %rax
	jne	LBB6_5
	jmp	LBB6_6
LBB6_1:
	vxorpd	%xmm2, %xmm2, %xmm2
	vxorpd	%xmm3, %xmm3, %xmm3
	vxorpd	%xmm4, %xmm4, %xmm4
	movq	%rdx, %r9
	movq	%r8, %r14
	jmp	LBB6_7
LBB6_3:
	movq	%rcx, %r10
	movq	%r8, %r14
	movl	$0, %r11d
	vxorpd	%ymm2, %ymm2, %ymm2
	vxorpd	%ymm3, %ymm3, %ymm3
	vxorpd	%ymm4, %ymm4, %ymm4
LBB6_6:
	vextractf128	$1, %ymm4, %xmm1
	vaddpd	%ymm1, %ymm4, %ymm1
	vhaddpd	%ymm1, %ymm1, %ymm4
	vextractf128	$1, %ymm3, %xmm1
	vaddpd	%ymm1, %ymm3, %ymm1
	vhaddpd	%ymm1, %ymm1, %ymm3
	vextractf128	$1, %ymm2, %xmm1
	vaddpd	%ymm1, %ymm2, %ymm1
	vhaddpd	%ymm1, %ymm1, %ymm2
	vextractf128	$1, %ymm8, %xmm1
	vaddpd	%ymm1, %ymm8, %ymm1
	vhaddpd	%ymm1, %ymm1, %ymm1
	movq	%r10, %rcx
	cmpq	%rdx, %r11
	je	LBB6_8
	.align	4, 0x90
LBB6_7:
	vmovsd	(%r14), %xmm5
	vfmadd231sd	(%rcx), %xmm5, %xmm4
	vfmadd231sd	8(%rcx), %xmm5, %xmm3
	vfmadd231sd	16(%rcx), %xmm5, %xmm2
	vfmadd231sd	24(%rcx), %xmm5, %xmm1
	addq	$8, %r14
	addq	$32, %rcx
	addq	$-1, %r9
	jne	LBB6_7
LBB6_8:
	leaq	(%r8,%rdx,8), %rax
	vfmadd213sd	(%rsi), %xmm0, %xmm4
	vmovsd	%xmm4, (%rsi)
	vfmadd213sd	(%rsi,%rdi,8), %xmm0, %xmm3
	vmovsd	%xmm3, (%rsi,%rdi,8)
	movq	%rdi, %rcx
	shlq	$4, %rcx
	vfmadd213sd	(%rsi,%rcx), %xmm0, %xmm2
	vmovsd	%xmm2, (%rsi,%rcx)
	leaq	(%rdi,%rdi,2), %rcx
	vfmadd213sd	(%rsi,%rcx,8), %xmm0, %xmm1
	vmovsd	%xmm1, (%rsi,%rcx,8)
	popq	%rbx
	popq	%r14
	vzeroupper
	retq
	.cfi_endproc

	.globl	__D3mir4blas8internal12micro_kernel79__T17gemm_micro_kernelVE3mir4blas6common14Multiplicationi0Vmi1Vmi2Vmi2TNhG2dTdZ17gemm_micro_kernelFNaNbNiG1dPxG1G2NhG2dPxG2G1dmPG1dlZPxd
	.weak_definition	__D3mir4blas8internal12micro_kernel79__T17gemm_micro_kernelVE3mir4blas6common14Multiplicationi0Vmi1Vmi2Vmi2TNhG2dTdZ17gemm_micro_kernelFNaNbNiG1dPxG1G2NhG2dPxG2G1dmPG1dlZPxd
	.align	4, 0x90
__D3mir4blas8internal12micro_kernel79__T17gemm_micro_kernelVE3mir4blas6common14Multiplicationi0Vmi1Vmi2Vmi2TNhG2dTdZ17gemm_micro_kernelFNaNbNiG1dPxG1G2NhG2dPxG2G1dmPG1dlZPxd:
	.cfi_startproc
	vxorpd	%xmm8, %xmm8, %xmm8
	vxorpd	%xmm2, %xmm2, %xmm2
	vxorpd	%xmm3, %xmm3, %xmm3
	vxorpd	%xmm4, %xmm4, %xmm4
	movq	%rdx, %r9
	movq	%r8, %rax
	.align	4, 0x90
LBB7_1:
	vmovapd	(%rax), %xmm5
	vmovapd	16(%rax), %xmm6
	vmovddup	(%rcx), %xmm7
	vmovddup	8(%rcx), %xmm1
	vfmadd231pd	%xmm7, %xmm5, %xmm4
	vfmadd231pd	%xmm7, %xmm6, %xmm3
	vfmadd231pd	%xmm1, %xmm5, %xmm2
	vfmadd231pd	%xmm1, %xmm6, %xmm8
	addq	$32, %rax
	addq	$16, %rcx
	addq	$-1, %r9
	jne	LBB7_1
	vunpcklpd	%xmm0, %xmm0, %xmm0
	vfmadd213pd	(%rsi), %xmm0, %xmm4
	shlq	$5, %rdx
	vmovupd	%xmm4, (%rsi)
	vfmadd213pd	16(%rsi), %xmm0, %xmm3
	addq	%rdx, %r8
	vmovupd	%xmm3, 16(%rsi)
	vfmadd213pd	(%rsi,%rdi,8), %xmm0, %xmm2
	vmovupd	%xmm2, (%rsi,%rdi,8)
	vfmadd213pd	16(%rsi,%rdi,8), %xmm0, %xmm8
	vmovupd	%xmm8, 16(%rsi,%rdi,8)
	movq	%r8, %rax
	retq
	.cfi_endproc

	.globl	__D3mir4blas8internal12micro_kernel79__T17gemm_micro_kernelVE3mir4blas6common14Multiplicationi0Vmi1Vmi1Vmi2TNhG2dTdZ17gemm_micro_kernelFNaNbNiG1dPxG1G1NhG2dPxG2G1dmPG1dlZPxd
	.weak_definition	__D3mir4blas8internal12micro_kernel79__T17gemm_micro_kernelVE3mir4blas6common14Multiplicationi0Vmi1Vmi1Vmi2TNhG2dTdZ17gemm_micro_kernelFNaNbNiG1dPxG1G1NhG2dPxG2G1dmPG1dlZPxd
	.align	4, 0x90
__D3mir4blas8internal12micro_kernel79__T17gemm_micro_kernelVE3mir4blas6common14Multiplicationi0Vmi1Vmi1Vmi2TNhG2dTdZ17gemm_micro_kernelFNaNbNiG1dPxG1G1NhG2dPxG2G1dmPG1dlZPxd:
	.cfi_startproc
	vxorpd	%xmm1, %xmm1, %xmm1
	vxorpd	%xmm2, %xmm2, %xmm2
	movq	%rdx, %r9
	movq	%r8, %rax
	.align	4, 0x90
LBB8_1:
	vmovapd	(%rax), %xmm3
	vmovddup	(%rcx), %xmm4
	vmovddup	8(%rcx), %xmm5
	vfmadd231pd	%xmm4, %xmm3, %xmm2
	vfmadd231pd	%xmm5, %xmm3, %xmm1
	addq	$16, %rax
	addq	$16, %rcx
	addq	$-1, %r9
	jne	LBB8_1
	shlq	$4, %rdx
	addq	%rdx, %r8
	vunpcklpd	%xmm0, %xmm0, %xmm0
	vfmadd213pd	(%rsi), %xmm0, %xmm2
	vmovupd	%xmm2, (%rsi)
	vfmadd213pd	(%rsi,%rdi,8), %xmm0, %xmm1
	vmovupd	%xmm1, (%rsi,%rdi,8)
	movq	%r8, %rax
	retq
	.cfi_endproc

	.globl	__D3mir4blas8internal12micro_kernel75__T17gemm_micro_kernelVE3mir4blas6common14Multiplicationi0Vmi1Vmi1Vmi2TdTdZ17gemm_micro_kernelFNaNbNiG1dPxG1G1dPxG2G1dmPG1dlZPxd
	.weak_definition	__D3mir4blas8internal12micro_kernel75__T17gemm_micro_kernelVE3mir4blas6common14Multiplicationi0Vmi1Vmi1Vmi2TdTdZ17gemm_micro_kernelFNaNbNiG1dPxG1G1dPxG2G1dmPG1dlZPxd
	.align	4, 0x90
__D3mir4blas8internal12micro_kernel75__T17gemm_micro_kernelVE3mir4blas6common14Multiplicationi0Vmi1Vmi1Vmi2TdTdZ17gemm_micro_kernelFNaNbNiG1dPxG1G1dPxG2G1dmPG1dlZPxd:
	.cfi_startproc
	pushq	%r14
Ltmp21:
	.cfi_def_cfa_offset 16
	pushq	%rbx
Ltmp22:
	.cfi_def_cfa_offset 24
Ltmp23:
	.cfi_offset %rbx, -24
Ltmp24:
	.cfi_offset %r14, -16
	vxorpd	%xmm1, %xmm1, %xmm1
	testq	%rdx, %rdx
	je	LBB9_1
	movq	%rdx, %r10
	andq	$-8, %r10
	movq	%rdx, %r11
	vxorpd	%ymm9, %ymm9, %ymm9
	movq	%rdx, %r9
	andq	$-8, %r11
	je	LBB9_3
	subq	%r10, %r9
	shlq	$4, %r10
	addq	%rcx, %r10
	leaq	(%r8,%r11,8), %rax
	addq	$120, %rcx
	leaq	56(%r8), %rbx
	vxorpd	%ymm9, %ymm9, %ymm9
	movq	%r11, %r14
	vxorpd	%ymm2, %ymm2, %ymm2
	vxorpd	%ymm3, %ymm3, %ymm3
	vxorpd	%ymm4, %ymm4, %ymm4
	.align	4, 0x90
LBB9_5:
	vmovupd	-56(%rbx), %ymm8
	vmovupd	-24(%rbx), %xmm6
	vmovsd	-8(%rbx), %xmm7
	vmovhpd	(%rbx), %xmm7, %xmm7
	vinsertf128	$1, %xmm7, %ymm6, %ymm6
	vmovsd	-88(%rcx), %xmm7
	vmovhpd	-72(%rcx), %xmm7, %xmm7
	vmovsd	-120(%rcx), %xmm5
	vmovsd	-112(%rcx), %xmm1
	vmovhpd	-104(%rcx), %xmm5, %xmm5
	vinsertf128	$1, %xmm7, %ymm5, %ymm10
	vmovsd	-24(%rcx), %xmm7
	vmovhpd	-8(%rcx), %xmm7, %xmm7
	vmovsd	-56(%rcx), %xmm5
	vmovhpd	-40(%rcx), %xmm5, %xmm5
	vinsertf128	$1, %xmm7, %ymm5, %ymm11
	vmovsd	-80(%rcx), %xmm7
	vmovhpd	-64(%rcx), %xmm7, %xmm7
	vmovhpd	-96(%rcx), %xmm1, %xmm1
	vinsertf128	$1, %xmm7, %ymm1, %ymm1
	vmovsd	-16(%rcx), %xmm7
	vmovhpd	(%rcx), %xmm7, %xmm7
	vmovsd	-48(%rcx), %xmm5
	vmovhpd	-32(%rcx), %xmm5, %xmm5
	vinsertf128	$1, %xmm7, %ymm5, %ymm5
	vfmadd231pd	%ymm8, %ymm10, %ymm3
	vfmadd231pd	%ymm6, %ymm11, %ymm4
	vfmadd231pd	%ymm8, %ymm1, %ymm9
	vfmadd231pd	%ymm6, %ymm5, %ymm2
	subq	$-128, %rcx
	addq	$64, %rbx
	addq	$-8, %r14
	jne	LBB9_5
	jmp	LBB9_6
LBB9_1:
	vxorpd	%xmm3, %xmm3, %xmm3
	movq	%rdx, %r9
	movq	%r8, %rax
	jmp	LBB9_7
LBB9_3:
	movq	%rcx, %r10
	movq	%r8, %rax
	movl	$0, %r11d
	vxorpd	%ymm2, %ymm2, %ymm2
	vxorpd	%ymm3, %ymm3, %ymm3
	vxorpd	%ymm4, %ymm4, %ymm4
LBB9_6:
	vaddpd	%ymm3, %ymm4, %ymm1
	vextractf128	$1, %ymm1, %xmm3
	vaddpd	%ymm3, %ymm1, %ymm1
	vhaddpd	%ymm1, %ymm1, %ymm3
	vaddpd	%ymm9, %ymm2, %ymm1
	vextractf128	$1, %ymm1, %xmm2
	vaddpd	%ymm2, %ymm1, %ymm1
	vhaddpd	%ymm1, %ymm1, %ymm1
	movq	%r10, %rcx
	cmpq	%rdx, %r11
	je	LBB9_8
	.align	4, 0x90
LBB9_7:
	vmovsd	(%rax), %xmm2
	vfmadd231sd	(%rcx), %xmm2, %xmm3
	vfmadd231sd	8(%rcx), %xmm2, %xmm1
	addq	$8, %rax
	addq	$16, %rcx
	addq	$-1, %r9
	jne	LBB9_7
LBB9_8:
	leaq	(%r8,%rdx,8), %rax
	vfmadd213sd	(%rsi), %xmm0, %xmm3
	vmovsd	%xmm3, (%rsi)
	vfmadd213sd	(%rsi,%rdi,8), %xmm0, %xmm1
	vmovsd	%xmm1, (%rsi,%rdi,8)
	popq	%rbx
	popq	%r14
	vzeroupper
	retq
	.cfi_endproc

	.globl	__D3mir4blas8internal12micro_kernel79__T17gemm_micro_kernelVE3mir4blas6common14Multiplicationi0Vmi1Vmi2Vmi1TNhG2dTdZ17gemm_micro_kernelFNaNbNiG1dPxG1G2NhG2dPxG1G1dmPG1dlZPxd
	.weak_definition	__D3mir4blas8internal12micro_kernel79__T17gemm_micro_kernelVE3mir4blas6common14Multiplicationi0Vmi1Vmi2Vmi1TNhG2dTdZ17gemm_micro_kernelFNaNbNiG1dPxG1G2NhG2dPxG1G1dmPG1dlZPxd
	.align	4, 0x90
__D3mir4blas8internal12micro_kernel79__T17gemm_micro_kernelVE3mir4blas6common14Multiplicationi0Vmi1Vmi2Vmi1TNhG2dTdZ17gemm_micro_kernelFNaNbNiG1dPxG1G2NhG2dPxG1G1dmPG1dlZPxd:
	.cfi_startproc
	vxorpd	%xmm1, %xmm1, %xmm1
	vxorpd	%xmm2, %xmm2, %xmm2
	movq	%rdx, %rax
	movq	%r8, %rdi
	.align	4, 0x90
LBB10_1:
	vmovddup	(%rcx), %xmm3
	vfmadd231pd	(%rdi), %xmm3, %xmm2
	vfmadd231pd	16(%rdi), %xmm3, %xmm1
	addq	$8, %rcx
	addq	$32, %rdi
	addq	$-1, %rax
	jne	LBB10_1
	shlq	$5, %rdx
	addq	%rdx, %r8
	vunpcklpd	%xmm0, %xmm0, %xmm0
	vfmadd213pd	(%rsi), %xmm0, %xmm2
	vmovupd	%xmm2, (%rsi)
	vfmadd213pd	16(%rsi), %xmm0, %xmm1
	vmovupd	%xmm1, 16(%rsi)
	movq	%r8, %rax
	retq
	.cfi_endproc

	.globl	__D3mir4blas8internal12micro_kernel79__T17gemm_micro_kernelVE3mir4blas6common14Multiplicationi0Vmi1Vmi1Vmi1TNhG2dTdZ17gemm_micro_kernelFNaNbNiG1dPxG1G1NhG2dPxG1G1dmPG1dlZPxd
	.weak_definition	__D3mir4blas8internal12micro_kernel79__T17gemm_micro_kernelVE3mir4blas6common14Multiplicationi0Vmi1Vmi1Vmi1TNhG2dTdZ17gemm_micro_kernelFNaNbNiG1dPxG1G1NhG2dPxG1G1dmPG1dlZPxd
	.align	4, 0x90
__D3mir4blas8internal12micro_kernel79__T17gemm_micro_kernelVE3mir4blas6common14Multiplicationi0Vmi1Vmi1Vmi1TNhG2dTdZ17gemm_micro_kernelFNaNbNiG1dPxG1G1NhG2dPxG1G1dmPG1dlZPxd:
	.cfi_startproc
	vxorpd	%xmm1, %xmm1, %xmm1
	movq	%rdx, %rax
	movq	%r8, %rdi
	.align	4, 0x90
LBB11_1:
	vmovddup	(%rcx), %xmm2
	vfmadd231pd	(%rdi), %xmm2, %xmm1
	addq	$16, %rdi
	addq	$8, %rcx
	addq	$-1, %rax
	jne	LBB11_1
	shlq	$4, %rdx
	addq	%rdx, %r8
	vunpcklpd	%xmm0, %xmm0, %xmm0
	vfmadd213pd	(%rsi), %xmm0, %xmm1
	vmovupd	%xmm1, (%rsi)
	movq	%r8, %rax
	retq
	.cfi_endproc

	.globl	__D3mir4blas8internal12micro_kernel75__T17gemm_micro_kernelVE3mir4blas6common14Multiplicationi0Vmi1Vmi1Vmi1TdTdZ17gemm_micro_kernelFNaNbNiG1dPxG1G1dPxG1G1dmPG1dlZPxd
	.weak_definition	__D3mir4blas8internal12micro_kernel75__T17gemm_micro_kernelVE3mir4blas6common14Multiplicationi0Vmi1Vmi1Vmi1TdTdZ17gemm_micro_kernelFNaNbNiG1dPxG1G1dPxG1G1dmPG1dlZPxd
	.align	4, 0x90
__D3mir4blas8internal12micro_kernel75__T17gemm_micro_kernelVE3mir4blas6common14Multiplicationi0Vmi1Vmi1Vmi1TdTdZ17gemm_micro_kernelFNaNbNiG1dPxG1G1dPxG1G1dmPG1dlZPxd:
	.cfi_startproc
	pushq	%rbx
Ltmp25:
	.cfi_def_cfa_offset 16
Ltmp26:
	.cfi_offset %rbx, -16
	vxorpd	%xmm1, %xmm1, %xmm1
	testq	%rdx, %rdx
	je	LBB12_1
	movq	%rdx, %rax
	andq	$-8, %rax
	movq	%rdx, %r9
	vxorpd	%ymm1, %ymm1, %ymm1
	movq	%rdx, %r11
	andq	$-8, %r9
	je	LBB12_3
	subq	%rax, %r11
	leaq	(%rcx,%r9,8), %r10
	leaq	(%r8,%r9,8), %rdi
	addq	$56, %rcx
	leaq	56(%r8), %rax
	vxorpd	%ymm1, %ymm1, %ymm1
	movq	%r9, %rbx
	vxorpd	%ymm2, %ymm2, %ymm2
	.align	4, 0x90
LBB12_5:
	vmovupd	-56(%rax), %ymm3
	vmovupd	-24(%rax), %xmm4
	vmovsd	-8(%rax), %xmm5
	vmovhpd	(%rax), %xmm5, %xmm5
	vinsertf128	$1, %xmm5, %ymm4, %ymm4
	vmovupd	-24(%rcx), %xmm5
	vmovsd	-8(%rcx), %xmm6
	vmovhpd	(%rcx), %xmm6, %xmm6
	vinsertf128	$1, %xmm6, %ymm5, %ymm5
	vfmadd231pd	-56(%rcx), %ymm3, %ymm1
	vfmadd231pd	%ymm4, %ymm5, %ymm2
	addq	$64, %rcx
	addq	$64, %rax
	addq	$-8, %rbx
	jne	LBB12_5
	jmp	LBB12_6
LBB12_1:
	movq	%rdx, %r11
	movq	%r8, %rdi
	jmp	LBB12_7
LBB12_3:
	movq	%rcx, %r10
	movq	%r8, %rdi
	xorl	%r9d, %r9d
	vxorpd	%ymm2, %ymm2, %ymm2
LBB12_6:
	vaddpd	%ymm1, %ymm2, %ymm1
	vextractf128	$1, %ymm1, %xmm2
	vaddpd	%ymm2, %ymm1, %ymm1
	vhaddpd	%ymm1, %ymm1, %ymm1
	movq	%r10, %rcx
	cmpq	%rdx, %r9
	je	LBB12_8
	.align	4, 0x90
LBB12_7:
	vmovsd	(%rdi), %xmm2
	vfmadd231sd	(%rcx), %xmm2, %xmm1
	addq	$8, %rdi
	addq	$8, %rcx
	addq	$-1, %r11
	jne	LBB12_7
LBB12_8:
	leaq	(%r8,%rdx,8), %rax
	vfmadd213sd	(%rsi), %xmm1, %xmm0
	vmovsd	%xmm0, (%rsi)
	popq	%rbx
	vzeroupper
	retq
	.cfi_endproc

	.globl	__D3mir4blas8internal7utility31__T8set_zeroVmi6Vmi1Vmi2TNhG2dZ8set_zeroFNaNbNiNfKG6G1G2NhG2dZv
	.weak_definition	__D3mir4blas8internal7utility31__T8set_zeroVmi6Vmi1Vmi2TNhG2dZ8set_zeroFNaNbNiNfKG6G1G2NhG2dZv
	.align	4, 0x90
__D3mir4blas8internal7utility31__T8set_zeroVmi6Vmi1Vmi2TNhG2dZ8set_zeroFNaNbNiNfKG6G1G2NhG2dZv:
	.cfi_startproc
	vxorps	%ymm0, %ymm0, %ymm0
	vmovups	%ymm0, 160(%rdi)
	vmovups	%ymm0, 128(%rdi)
	vmovups	%ymm0, 96(%rdi)
	vmovups	%ymm0, 64(%rdi)
	vmovups	%ymm0, 32(%rdi)
	vmovups	%ymm0, (%rdi)
	vzeroupper
	retq
	.cfi_endproc

	.globl	__D3mir4blas8internal12micro_kernel78__T16gemm_nano_kernelVE3mir4blas6common14Multiplicationi0Vmi1Vmi2Vmi6TNhG2dTdZ16gemm_nano_kernelFNaNbNiKG6G1G2NhG2dPxG1G2NhG2dPxG6G1dmZG2Pxd
	.weak_definition	__D3mir4blas8internal12micro_kernel78__T16gemm_nano_kernelVE3mir4blas6common14Multiplicationi0Vmi1Vmi2Vmi6TNhG2dTdZ16gemm_nano_kernelFNaNbNiKG6G1G2NhG2dPxG1G2NhG2dPxG6G1dmZG2Pxd
	.align	4, 0x90
__D3mir4blas8internal12micro_kernel78__T16gemm_nano_kernelVE3mir4blas6common14Multiplicationi0Vmi1Vmi2Vmi6TNhG2dTdZ16gemm_nano_kernelFNaNbNiKG6G1G2NhG2dPxG1G2NhG2dPxG6G1dmZG2Pxd:
	.cfi_startproc
	vmovapd	(%r8), %xmm11
	vmovapd	16(%r8), %xmm10
	vmovapd	32(%r8), %xmm9
	vmovapd	48(%r8), %xmm8
	vmovapd	64(%r8), %xmm7
	vmovapd	80(%r8), %xmm6
	vmovapd	96(%r8), %xmm5
	vmovapd	112(%r8), %xmm4
	vmovapd	128(%r8), %xmm3
	vmovapd	144(%r8), %xmm14
	vmovapd	160(%r8), %xmm13
	vmovapd	176(%r8), %xmm12
	leaq	(%rsi,%rsi,2), %r9
	shlq	$4, %r9
	addq	%rdx, %r9
	movq	%rsi, %r10
	movq	%rcx, %rax
	.align	4, 0x90
LBB14_1:
	vmovapd	(%rax), %xmm0
	vmovapd	16(%rax), %xmm1
	vmovddup	(%rdx), %xmm2
	vfmadd231pd	%xmm2, %xmm0, %xmm11
	vfmadd231pd	%xmm2, %xmm1, %xmm10
	vmovddup	8(%rdx), %xmm2
	vfmadd231pd	%xmm2, %xmm0, %xmm9
	vfmadd231pd	%xmm2, %xmm1, %xmm8
	vmovddup	16(%rdx), %xmm2
	vfmadd231pd	%xmm2, %xmm0, %xmm7
	vfmadd231pd	%xmm2, %xmm1, %xmm6
	vmovddup	24(%rdx), %xmm2
	vfmadd231pd	%xmm2, %xmm0, %xmm5
	vfmadd231pd	%xmm2, %xmm1, %xmm4
	vmovddup	32(%rdx), %xmm2
	vfmadd231pd	%xmm2, %xmm0, %xmm3
	vfmadd231pd	%xmm2, %xmm1, %xmm14
	vmovddup	40(%rdx), %xmm2
	vfmadd231pd	%xmm2, %xmm0, %xmm13
	vfmadd231pd	%xmm2, %xmm1, %xmm12
	addq	$32, %rax
	addq	$48, %rdx
	addq	$-1, %r10
	jne	LBB14_1
	vmovapd	%xmm11, (%r8)
	vmovapd	%xmm10, 16(%r8)
	vmovapd	%xmm9, 32(%r8)
	vmovapd	%xmm8, 48(%r8)
	vmovapd	%xmm7, 64(%r8)
	vmovapd	%xmm6, 80(%r8)
	vmovapd	%xmm5, 96(%r8)
	vmovapd	%xmm4, 112(%r8)
	vmovapd	%xmm3, 128(%r8)
	vmovapd	%xmm14, 144(%r8)
	vmovapd	%xmm13, 160(%r8)
	vmovapd	%xmm12, 176(%r8)
	shlq	$5, %rsi
	addq	%rsi, %rcx
	movq	%rcx, (%rdi)
	movq	%r9, 8(%rdi)
	movq	%rdi, %rax
	retq
	.cfi_endproc

	.globl	__D3mir4blas8internal12micro_kernel43__T17scale_nano_kernelVmi1Vmi6Vmi2TNhG2dTdZ17scale_nano_kernelFNaNbNiNfKG6G1G2NhG2dG1dZv
	.weak_definition	__D3mir4blas8internal12micro_kernel43__T17scale_nano_kernelVmi1Vmi6Vmi2TNhG2dTdZ17scale_nano_kernelFNaNbNiNfKG6G1G2NhG2dG1dZv
	.align	4, 0x90
__D3mir4blas8internal12micro_kernel43__T17scale_nano_kernelVmi1Vmi6Vmi2TNhG2dTdZ17scale_nano_kernelFNaNbNiNfKG6G1G2NhG2dG1dZv:
	.cfi_startproc
	vunpcklpd	%xmm0, %xmm0, %xmm0
	vmulpd	(%rdi), %xmm0, %xmm1
	vmulpd	16(%rdi), %xmm0, %xmm2
	vmulpd	32(%rdi), %xmm0, %xmm3
	vmulpd	48(%rdi), %xmm0, %xmm4
	vmulpd	64(%rdi), %xmm0, %xmm5
	vmulpd	80(%rdi), %xmm0, %xmm6
	vmulpd	96(%rdi), %xmm0, %xmm7
	vmulpd	112(%rdi), %xmm0, %xmm8
	vmulpd	128(%rdi), %xmm0, %xmm9
	vmulpd	144(%rdi), %xmm0, %xmm10
	vmulpd	160(%rdi), %xmm0, %xmm11
	vmulpd	176(%rdi), %xmm0, %xmm0
	vmovapd	%xmm1, (%rdi)
	vmovapd	%xmm2, 16(%rdi)
	vmovapd	%xmm3, 32(%rdi)
	vmovapd	%xmm4, 48(%rdi)
	vmovapd	%xmm5, 64(%rdi)
	vmovapd	%xmm6, 80(%rdi)
	vmovapd	%xmm7, 96(%rdi)
	vmovapd	%xmm8, 112(%rdi)
	vmovapd	%xmm9, 128(%rdi)
	vmovapd	%xmm10, 144(%rdi)
	vmovapd	%xmm11, 160(%rdi)
	vmovapd	%xmm0, 176(%rdi)
	retq
	.cfi_endproc

	.globl	__D3mir4blas8internal12micro_kernel42__T16save_nano_kernelVmi1Vmi2Vmi6TNhG2dTdZ16save_nano_kernelFNaNbNiKG6G1G2NhG2dPG1dlZv
	.weak_definition	__D3mir4blas8internal12micro_kernel42__T16save_nano_kernelVmi1Vmi2Vmi6TNhG2dTdZ16save_nano_kernelFNaNbNiKG6G1G2NhG2dPG1dlZv
	.align	4, 0x90
__D3mir4blas8internal12micro_kernel42__T16save_nano_kernelVmi1Vmi2Vmi6TNhG2dTdZ16save_nano_kernelFNaNbNiKG6G1G2NhG2dPG1dlZv:
	.cfi_startproc
	vmovsd	(%rdx), %xmm0
	vaddsd	(%rsi), %xmm0, %xmm0
	vmovsd	%xmm0, (%rsi)
	vmovsd	8(%rdx), %xmm0
	vaddsd	8(%rsi), %xmm0, %xmm0
	vmovsd	%xmm0, 8(%rsi)
	vmovsd	16(%rdx), %xmm0
	vaddsd	16(%rsi), %xmm0, %xmm0
	vmovsd	%xmm0, 16(%rsi)
	vmovsd	24(%rdx), %xmm0
	vaddsd	24(%rsi), %xmm0, %xmm0
	vmovsd	%xmm0, 24(%rsi)
	vmovsd	32(%rdx), %xmm0
	vaddsd	(%rsi,%rdi,8), %xmm0, %xmm0
	vmovsd	%xmm0, (%rsi,%rdi,8)
	vmovsd	40(%rdx), %xmm0
	vaddsd	8(%rsi,%rdi,8), %xmm0, %xmm0
	vmovsd	%xmm0, 8(%rsi,%rdi,8)
	vmovsd	48(%rdx), %xmm0
	vaddsd	16(%rsi,%rdi,8), %xmm0, %xmm0
	vmovsd	%xmm0, 16(%rsi,%rdi,8)
	vmovsd	56(%rdx), %xmm0
	vaddsd	24(%rsi,%rdi,8), %xmm0, %xmm0
	vmovsd	%xmm0, 24(%rsi,%rdi,8)
	movq	%rdi, %rax
	shlq	$4, %rax
	vmovsd	64(%rdx), %xmm0
	vaddsd	(%rsi,%rax), %xmm0, %xmm0
	vmovsd	%xmm0, (%rsi,%rax)
	vmovsd	72(%rdx), %xmm0
	vaddsd	8(%rsi,%rax), %xmm0, %xmm0
	vmovsd	%xmm0, 8(%rsi,%rax)
	vmovsd	80(%rdx), %xmm0
	vaddsd	16(%rsi,%rax), %xmm0, %xmm0
	vmovsd	%xmm0, 16(%rsi,%rax)
	vmovsd	88(%rdx), %xmm0
	vaddsd	24(%rsi,%rax), %xmm0, %xmm0
	vmovsd	%xmm0, 24(%rsi,%rax)
	leaq	(%rdi,%rdi,2), %rax
	vmovsd	96(%rdx), %xmm0
	vaddsd	(%rsi,%rax,8), %xmm0, %xmm0
	vmovsd	%xmm0, (%rsi,%rax,8)
	vmovsd	104(%rdx), %xmm0
	vaddsd	8(%rsi,%rax,8), %xmm0, %xmm0
	vmovsd	%xmm0, 8(%rsi,%rax,8)
	vmovsd	112(%rdx), %xmm0
	vaddsd	16(%rsi,%rax,8), %xmm0, %xmm0
	vmovsd	%xmm0, 16(%rsi,%rax,8)
	vmovsd	120(%rdx), %xmm0
	vaddsd	24(%rsi,%rax,8), %xmm0, %xmm0
	vmovsd	%xmm0, 24(%rsi,%rax,8)
	movq	%rdi, %rax
	shlq	$5, %rax
	vmovsd	128(%rdx), %xmm0
	vaddsd	(%rsi,%rax), %xmm0, %xmm0
	vmovsd	%xmm0, (%rsi,%rax)
	vmovsd	136(%rdx), %xmm0
	vaddsd	8(%rsi,%rax), %xmm0, %xmm0
	vmovsd	%xmm0, 8(%rsi,%rax)
	vmovsd	144(%rdx), %xmm0
	vaddsd	16(%rsi,%rax), %xmm0, %xmm0
	vmovsd	%xmm0, 16(%rsi,%rax)
	vmovsd	152(%rdx), %xmm0
	vaddsd	24(%rsi,%rax), %xmm0, %xmm0
	vmovsd	%xmm0, 24(%rsi,%rax)
	leaq	(%rdi,%rdi,4), %rax
	vmovsd	160(%rdx), %xmm0
	vaddsd	(%rsi,%rax,8), %xmm0, %xmm0
	vmovsd	%xmm0, (%rsi,%rax,8)
	vmovsd	168(%rdx), %xmm0
	vaddsd	8(%rsi,%rax,8), %xmm0, %xmm0
	vmovsd	%xmm0, 8(%rsi,%rax,8)
	vmovsd	176(%rdx), %xmm0
	vaddsd	16(%rsi,%rax,8), %xmm0, %xmm0
	vmovsd	%xmm0, 16(%rsi,%rax,8)
	vmovsd	184(%rdx), %xmm0
	vaddsd	24(%rsi,%rax,8), %xmm0, %xmm0
	vmovsd	%xmm0, 24(%rsi,%rax,8)
	retq
	.cfi_endproc

	.globl	__D3mir4blas8internal7utility27__T4loadVmi6Vmi1Vmi2TNhG2dZ4loadFNaNbNiNfKG6G1G2NhG2dKG6G1G2NhG2dZv
	.weak_definition	__D3mir4blas8internal7utility27__T4loadVmi6Vmi1Vmi2TNhG2dZ4loadFNaNbNiNfKG6G1G2NhG2dKG6G1G2NhG2dZv
	.align	4, 0x90
__D3mir4blas8internal7utility27__T4loadVmi6Vmi1Vmi2TNhG2dZ4loadFNaNbNiNfKG6G1G2NhG2dKG6G1G2NhG2dZv:
	.cfi_startproc
	vmovaps	(%rdi), %xmm0
	vmovaps	%xmm0, (%rsi)
	vmovaps	16(%rdi), %xmm0
	vmovaps	%xmm0, 16(%rsi)
	vmovaps	32(%rdi), %xmm0
	vmovaps	%xmm0, 32(%rsi)
	vmovaps	48(%rdi), %xmm0
	vmovaps	%xmm0, 48(%rsi)
	vmovaps	64(%rdi), %xmm0
	vmovaps	%xmm0, 64(%rsi)
	vmovaps	80(%rdi), %xmm0
	vmovaps	%xmm0, 80(%rsi)
	vmovaps	96(%rdi), %xmm0
	vmovaps	%xmm0, 96(%rsi)
	vmovaps	112(%rdi), %xmm0
	vmovaps	%xmm0, 112(%rsi)
	vmovaps	128(%rdi), %xmm0
	vmovaps	%xmm0, 128(%rsi)
	vmovaps	144(%rdi), %xmm0
	vmovaps	%xmm0, 144(%rsi)
	vmovaps	160(%rdi), %xmm0
	vmovaps	%xmm0, 160(%rsi)
	vmovaps	176(%rdi), %xmm0
	vmovaps	%xmm0, 176(%rsi)
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

	.globl	__D3mir4blas8internal12micro_kernel38__T16save_nano_kernelVmi1Vmi2TNhG2dTdZ16save_nano_kernelFNaNbNiKG1G2NhG2dPG1dZv
	.weak_definition	__D3mir4blas8internal12micro_kernel38__T16save_nano_kernelVmi1Vmi2TNhG2dTdZ16save_nano_kernelFNaNbNiKG1G2NhG2dPG1dZv
	.align	4, 0x90
__D3mir4blas8internal12micro_kernel38__T16save_nano_kernelVmi1Vmi2TNhG2dTdZ16save_nano_kernelFNaNbNiKG1G2NhG2dPG1dZv:
	.cfi_startproc
	vmovsd	(%rsi), %xmm0
	vaddsd	(%rdi), %xmm0, %xmm0
	vmovsd	%xmm0, (%rdi)
	vmovsd	8(%rsi), %xmm0
	vaddsd	8(%rdi), %xmm0, %xmm0
	vmovsd	%xmm0, 8(%rdi)
	vmovsd	16(%rsi), %xmm0
	vaddsd	16(%rdi), %xmm0, %xmm0
	vmovsd	%xmm0, 16(%rdi)
	vmovsd	24(%rsi), %xmm0
	vaddsd	24(%rdi), %xmm0, %xmm0
	vmovsd	%xmm0, 24(%rdi)
	retq
	.cfi_endproc

	.globl	__D3mir4blas8internal7utility31__T8set_zeroVmi6Vmi1Vmi1TNhG2dZ8set_zeroFNaNbNiNfKG6G1G1NhG2dZv
	.weak_definition	__D3mir4blas8internal7utility31__T8set_zeroVmi6Vmi1Vmi1TNhG2dZ8set_zeroFNaNbNiNfKG6G1G1NhG2dZv
	.align	4, 0x90
__D3mir4blas8internal7utility31__T8set_zeroVmi6Vmi1Vmi1TNhG2dZ8set_zeroFNaNbNiNfKG6G1G1NhG2dZv:
	.cfi_startproc
	vxorps	%ymm0, %ymm0, %ymm0
	vmovups	%ymm0, 64(%rdi)
	vmovups	%ymm0, 32(%rdi)
	vmovups	%ymm0, (%rdi)
	vzeroupper
	retq
	.cfi_endproc

	.globl	__D3mir4blas8internal12micro_kernel78__T16gemm_nano_kernelVE3mir4blas6common14Multiplicationi0Vmi1Vmi1Vmi6TNhG2dTdZ16gemm_nano_kernelFNaNbNiKG6G1G1NhG2dPxG1G1NhG2dPxG6G1dmZG2Pxd
	.weak_definition	__D3mir4blas8internal12micro_kernel78__T16gemm_nano_kernelVE3mir4blas6common14Multiplicationi0Vmi1Vmi1Vmi6TNhG2dTdZ16gemm_nano_kernelFNaNbNiKG6G1G1NhG2dPxG1G1NhG2dPxG6G1dmZG2Pxd
	.align	4, 0x90
__D3mir4blas8internal12micro_kernel78__T16gemm_nano_kernelVE3mir4blas6common14Multiplicationi0Vmi1Vmi1Vmi6TNhG2dTdZ16gemm_nano_kernelFNaNbNiKG6G1G1NhG2dPxG1G1NhG2dPxG6G1dmZG2Pxd:
	.cfi_startproc
	vmovapd	(%r8), %xmm5
	vmovapd	16(%r8), %xmm4
	vmovapd	32(%r8), %xmm3
	vmovapd	48(%r8), %xmm2
	vmovapd	64(%r8), %xmm1
	vmovapd	80(%r8), %xmm0
	leaq	(%rsi,%rsi,2), %r9
	shlq	$4, %r9
	addq	%rdx, %r9
	movq	%rsi, %r10
	movq	%rcx, %rax
	.align	4, 0x90
LBB21_1:
	vmovapd	(%rax), %xmm6
	vmovddup	(%rdx), %xmm7
	vmovddup	8(%rdx), %xmm8
	vmovddup	16(%rdx), %xmm9
	vmovddup	24(%rdx), %xmm10
	vmovddup	32(%rdx), %xmm11
	vmovddup	40(%rdx), %xmm12
	vfmadd231pd	%xmm7, %xmm6, %xmm5
	vfmadd231pd	%xmm8, %xmm6, %xmm4
	vfmadd231pd	%xmm9, %xmm6, %xmm3
	vfmadd231pd	%xmm10, %xmm6, %xmm2
	vfmadd231pd	%xmm11, %xmm6, %xmm1
	vfmadd231pd	%xmm12, %xmm6, %xmm0
	addq	$16, %rax
	addq	$48, %rdx
	addq	$-1, %r10
	jne	LBB21_1
	vmovapd	%xmm5, (%r8)
	vmovapd	%xmm4, 16(%r8)
	vmovapd	%xmm3, 32(%r8)
	vmovapd	%xmm2, 48(%r8)
	vmovapd	%xmm1, 64(%r8)
	vmovapd	%xmm0, 80(%r8)
	shlq	$4, %rsi
	addq	%rsi, %rcx
	movq	%rcx, (%rdi)
	movq	%r9, 8(%rdi)
	movq	%rdi, %rax
	retq
	.cfi_endproc

	.globl	__D3mir4blas8internal12micro_kernel43__T17scale_nano_kernelVmi1Vmi6Vmi1TNhG2dTdZ17scale_nano_kernelFNaNbNiNfKG6G1G1NhG2dG1dZv
	.weak_definition	__D3mir4blas8internal12micro_kernel43__T17scale_nano_kernelVmi1Vmi6Vmi1TNhG2dTdZ17scale_nano_kernelFNaNbNiNfKG6G1G1NhG2dG1dZv
	.align	4, 0x90
__D3mir4blas8internal12micro_kernel43__T17scale_nano_kernelVmi1Vmi6Vmi1TNhG2dTdZ17scale_nano_kernelFNaNbNiNfKG6G1G1NhG2dG1dZv:
	.cfi_startproc
	vunpcklpd	%xmm0, %xmm0, %xmm0
	vmulpd	(%rdi), %xmm0, %xmm1
	vmulpd	16(%rdi), %xmm0, %xmm2
	vmulpd	32(%rdi), %xmm0, %xmm3
	vmulpd	48(%rdi), %xmm0, %xmm4
	vmulpd	64(%rdi), %xmm0, %xmm5
	vmulpd	80(%rdi), %xmm0, %xmm0
	vmovapd	%xmm1, (%rdi)
	vmovapd	%xmm2, 16(%rdi)
	vmovapd	%xmm3, 32(%rdi)
	vmovapd	%xmm4, 48(%rdi)
	vmovapd	%xmm5, 64(%rdi)
	vmovapd	%xmm0, 80(%rdi)
	retq
	.cfi_endproc

	.globl	__D3mir4blas8internal12micro_kernel42__T16save_nano_kernelVmi1Vmi1Vmi6TNhG2dTdZ16save_nano_kernelFNaNbNiKG6G1G1NhG2dPG1dlZv
	.weak_definition	__D3mir4blas8internal12micro_kernel42__T16save_nano_kernelVmi1Vmi1Vmi6TNhG2dTdZ16save_nano_kernelFNaNbNiKG6G1G1NhG2dPG1dlZv
	.align	4, 0x90
__D3mir4blas8internal12micro_kernel42__T16save_nano_kernelVmi1Vmi1Vmi6TNhG2dTdZ16save_nano_kernelFNaNbNiKG6G1G1NhG2dPG1dlZv:
	.cfi_startproc
	vmovsd	(%rdx), %xmm0
	vaddsd	(%rsi), %xmm0, %xmm0
	vmovsd	%xmm0, (%rsi)
	vmovsd	8(%rdx), %xmm0
	vaddsd	8(%rsi), %xmm0, %xmm0
	vmovsd	%xmm0, 8(%rsi)
	vmovsd	16(%rdx), %xmm0
	vaddsd	(%rsi,%rdi,8), %xmm0, %xmm0
	vmovsd	%xmm0, (%rsi,%rdi,8)
	vmovsd	24(%rdx), %xmm0
	vaddsd	8(%rsi,%rdi,8), %xmm0, %xmm0
	vmovsd	%xmm0, 8(%rsi,%rdi,8)
	movq	%rdi, %rax
	shlq	$4, %rax
	vmovsd	32(%rdx), %xmm0
	vaddsd	(%rsi,%rax), %xmm0, %xmm0
	vmovsd	%xmm0, (%rsi,%rax)
	vmovsd	40(%rdx), %xmm0
	vaddsd	8(%rsi,%rax), %xmm0, %xmm0
	vmovsd	%xmm0, 8(%rsi,%rax)
	leaq	(%rdi,%rdi,2), %rax
	vmovsd	48(%rdx), %xmm0
	vaddsd	(%rsi,%rax,8), %xmm0, %xmm0
	vmovsd	%xmm0, (%rsi,%rax,8)
	vmovsd	56(%rdx), %xmm0
	vaddsd	8(%rsi,%rax,8), %xmm0, %xmm0
	vmovsd	%xmm0, 8(%rsi,%rax,8)
	movq	%rdi, %rax
	shlq	$5, %rax
	vmovsd	64(%rdx), %xmm0
	vaddsd	(%rsi,%rax), %xmm0, %xmm0
	vmovsd	%xmm0, (%rsi,%rax)
	vmovsd	72(%rdx), %xmm0
	vaddsd	8(%rsi,%rax), %xmm0, %xmm0
	vmovsd	%xmm0, 8(%rsi,%rax)
	leaq	(%rdi,%rdi,4), %rax
	vmovsd	80(%rdx), %xmm0
	vaddsd	(%rsi,%rax,8), %xmm0, %xmm0
	vmovsd	%xmm0, (%rsi,%rax,8)
	vmovsd	88(%rdx), %xmm0
	vaddsd	8(%rsi,%rax,8), %xmm0, %xmm0
	vmovsd	%xmm0, 8(%rsi,%rax,8)
	retq
	.cfi_endproc

	.globl	__D3mir4blas8internal7utility27__T4loadVmi6Vmi1Vmi1TNhG2dZ4loadFNaNbNiNfKG6G1G1NhG2dKG6G1G1NhG2dZv
	.weak_definition	__D3mir4blas8internal7utility27__T4loadVmi6Vmi1Vmi1TNhG2dZ4loadFNaNbNiNfKG6G1G1NhG2dKG6G1G1NhG2dZv
	.align	4, 0x90
__D3mir4blas8internal7utility27__T4loadVmi6Vmi1Vmi1TNhG2dZ4loadFNaNbNiNfKG6G1G1NhG2dKG6G1G1NhG2dZv:
	.cfi_startproc
	vmovaps	(%rdi), %xmm0
	vmovaps	%xmm0, (%rsi)
	vmovaps	16(%rdi), %xmm0
	vmovaps	%xmm0, 16(%rsi)
	vmovaps	32(%rdi), %xmm0
	vmovaps	%xmm0, 32(%rsi)
	vmovaps	48(%rdi), %xmm0
	vmovaps	%xmm0, 48(%rsi)
	vmovaps	64(%rdi), %xmm0
	vmovaps	%xmm0, 64(%rsi)
	vmovaps	80(%rdi), %xmm0
	vmovaps	%xmm0, 80(%rsi)
	retq
	.cfi_endproc

	.globl	__D3mir4blas8internal12micro_kernel38__T16save_nano_kernelVmi1Vmi1TNhG2dTdZ16save_nano_kernelFNaNbNiKG1G1NhG2dPG1dZv
	.weak_definition	__D3mir4blas8internal12micro_kernel38__T16save_nano_kernelVmi1Vmi1TNhG2dTdZ16save_nano_kernelFNaNbNiKG1G1NhG2dPG1dZv
	.align	4, 0x90
__D3mir4blas8internal12micro_kernel38__T16save_nano_kernelVmi1Vmi1TNhG2dTdZ16save_nano_kernelFNaNbNiKG1G1NhG2dPG1dZv:
	.cfi_startproc
	vmovsd	(%rsi), %xmm0
	vaddsd	(%rdi), %xmm0, %xmm0
	vmovsd	%xmm0, (%rdi)
	vmovsd	8(%rsi), %xmm0
	vaddsd	8(%rdi), %xmm0, %xmm0
	vmovsd	%xmm0, 8(%rdi)
	retq
	.cfi_endproc

	.globl	__D3mir4blas8internal7utility27__T8set_zeroVmi6Vmi1Vmi1TdZ8set_zeroFNaNbNiNfKG6G1G1dZv
	.weak_definition	__D3mir4blas8internal7utility27__T8set_zeroVmi6Vmi1Vmi1TdZ8set_zeroFNaNbNiNfKG6G1G1dZv
	.align	4, 0x90
__D3mir4blas8internal7utility27__T8set_zeroVmi6Vmi1Vmi1TdZ8set_zeroFNaNbNiNfKG6G1G1dZv:
	.cfi_startproc
	vxorps	%ymm0, %ymm0, %ymm0
	vmovups	%ymm0, 16(%rdi)
	vmovups	%ymm0, (%rdi)
	vzeroupper
	retq
	.cfi_endproc

	.globl	__D3mir4blas8internal12micro_kernel74__T16gemm_nano_kernelVE3mir4blas6common14Multiplicationi0Vmi1Vmi1Vmi6TdTdZ16gemm_nano_kernelFNaNbNiKG6G1G1dPxG1G1dPxG6G1dmZG2Pxd
	.weak_definition	__D3mir4blas8internal12micro_kernel74__T16gemm_nano_kernelVE3mir4blas6common14Multiplicationi0Vmi1Vmi1Vmi6TdTdZ16gemm_nano_kernelFNaNbNiKG6G1G1dPxG1G1dPxG6G1dmZG2Pxd
	.align	4, 0x90
__D3mir4blas8internal12micro_kernel74__T16gemm_nano_kernelVE3mir4blas6common14Multiplicationi0Vmi1Vmi1Vmi6TdTdZ16gemm_nano_kernelFNaNbNiKG6G1G1dPxG1G1dPxG6G1dmZG2Pxd:
	.cfi_startproc
	pushq	%r15
Ltmp27:
	.cfi_def_cfa_offset 16
	pushq	%r14
Ltmp28:
	.cfi_def_cfa_offset 24
	pushq	%rbx
Ltmp29:
	.cfi_def_cfa_offset 32
Ltmp30:
	.cfi_offset %rbx, -32
Ltmp31:
	.cfi_offset %r14, -24
Ltmp32:
	.cfi_offset %r15, -16
	vmovupd	(%r8), %xmm5
	vmovupd	16(%r8), %xmm3
	vmovupd	32(%r8), %xmm1
	leaq	(%rsi,%rsi,2), %rax
	shlq	$4, %rax
	addq	%rdx, %rax
	leaq	(%rcx,%rsi,8), %r9
	testq	%rsi, %rsi
	je	LBB27_6
	movq	%rsi, %rbx
	andq	$-4, %rbx
	movq	%rsi, %r10
	vpermilpd	$1, %xmm1, %xmm0
	vmovq	%xmm0, %xmm0
	vxorpd	%ymm6, %ymm6, %ymm6
	vinsertf128	$0, %xmm0, %ymm6, %ymm9
	vmovq	%xmm1, %xmm1
	vinsertf128	$0, %xmm1, %ymm6, %ymm10
	vpermilpd	$1, %xmm3, %xmm2
	vmovq	%xmm2, %xmm2
	vinsertf128	$0, %xmm2, %ymm6, %ymm12
	vmovq	%xmm3, %xmm3
	vinsertf128	$0, %xmm3, %ymm6, %ymm13
	vpermilpd	$1, %xmm5, %xmm4
	vmovq	%xmm4, %xmm4
	vinsertf128	$0, %xmm4, %ymm6, %ymm4
	vmovq	%xmm5, %xmm5
	vinsertf128	$0, %xmm5, %ymm6, %ymm5
	movq	%rsi, %r11
	andq	$-4, %r10
	je	LBB27_2
	subq	%rbx, %r11
	leaq	(%rbx,%rbx,2), %r15
	shlq	$4, %r15
	addq	%rdx, %r15
	leaq	(%rcx,%r10,8), %r14
	addq	$184, %rdx
	addq	$24, %rcx
	movq	%r10, %rbx
	.align	4, 0x90
LBB27_4:
	vmovupd	-24(%rcx), %xmm6
	vmovsd	-8(%rcx), %xmm7
	vmovhpd	(%rcx), %xmm7, %xmm7
	vinsertf128	$1, %xmm7, %ymm6, %ymm6
	vmovsd	-88(%rdx), %xmm7
	vmovhpd	-40(%rdx), %xmm7, %xmm7
	vmovsd	-184(%rdx), %xmm0
	vmovsd	-176(%rdx), %xmm1
	vmovhpd	-136(%rdx), %xmm0, %xmm0
	vinsertf128	$1, %xmm7, %ymm0, %ymm11
	vmovsd	-80(%rdx), %xmm0
	vmovhpd	-32(%rdx), %xmm0, %xmm0
	vmovhpd	-128(%rdx), %xmm1, %xmm1
	vinsertf128	$1, %xmm0, %ymm1, %ymm8
	vmovsd	-72(%rdx), %xmm0
	vmovhpd	-24(%rdx), %xmm0, %xmm0
	vmovsd	-168(%rdx), %xmm1
	vmovhpd	-120(%rdx), %xmm1, %xmm1
	vinsertf128	$1, %xmm0, %ymm1, %ymm0
	vmovsd	-64(%rdx), %xmm1
	vmovhpd	-16(%rdx), %xmm1, %xmm1
	vmovsd	-160(%rdx), %xmm7
	vmovhpd	-112(%rdx), %xmm7, %xmm7
	vinsertf128	$1, %xmm1, %ymm7, %ymm1
	vmovsd	-56(%rdx), %xmm7
	vmovhpd	-8(%rdx), %xmm7, %xmm7
	vmovsd	-152(%rdx), %xmm2
	vmovhpd	-104(%rdx), %xmm2, %xmm2
	vinsertf128	$1, %xmm7, %ymm2, %ymm2
	vmovsd	-48(%rdx), %xmm7
	vmovhpd	(%rdx), %xmm7, %xmm7
	vmovsd	-144(%rdx), %xmm3
	vmovhpd	-96(%rdx), %xmm3, %xmm3
	vinsertf128	$1, %xmm7, %ymm3, %ymm3
	vfmadd231pd	%ymm6, %ymm11, %ymm5
	vfmadd231pd	%ymm6, %ymm8, %ymm4
	vfmadd231pd	%ymm6, %ymm0, %ymm13
	vfmadd231pd	%ymm6, %ymm1, %ymm12
	vfmadd231pd	%ymm6, %ymm2, %ymm10
	vfmadd231pd	%ymm6, %ymm3, %ymm9
	addq	$192, %rdx
	addq	$32, %rcx
	addq	$-4, %rbx
	jne	LBB27_4
	jmp	LBB27_5
LBB27_2:
	movq	%rdx, %r15
	movq	%rcx, %r14
	xorl	%r10d, %r10d
LBB27_5:
	vextractf128	$1, %ymm5, %xmm0
	vaddpd	%ymm0, %ymm5, %ymm0
	vhaddpd	%ymm0, %ymm0, %ymm0
	vextractf128	$1, %ymm4, %xmm1
	vaddpd	%ymm1, %ymm4, %ymm1
	vhaddpd	%ymm1, %ymm1, %ymm1
	vextractf128	$1, %ymm13, %xmm2
	vaddpd	%ymm2, %ymm13, %ymm2
	vhaddpd	%ymm2, %ymm2, %ymm2
	vextractf128	$1, %ymm12, %xmm3
	vaddpd	%ymm3, %ymm12, %ymm3
	vhaddpd	%ymm3, %ymm3, %ymm3
	vextractf128	$1, %ymm10, %xmm4
	vaddpd	%ymm4, %ymm10, %ymm4
	vhaddpd	%ymm4, %ymm4, %ymm4
	vextractf128	$1, %ymm9, %xmm5
	vaddpd	%ymm5, %ymm9, %ymm5
	vhaddpd	%ymm5, %ymm5, %ymm6
	vunpcklpd	%xmm1, %xmm0, %xmm5
	vunpcklpd	%xmm3, %xmm2, %xmm3
	vunpcklpd	%xmm6, %xmm4, %xmm1
	cmpq	%rsi, %r10
	movq	%r11, %rsi
	movq	%r15, %rdx
	movq	%r14, %rcx
	je	LBB27_7
	.align	4, 0x90
LBB27_6:
	vmovddup	(%rcx), %xmm0
	vfmadd231pd	(%rdx), %xmm0, %xmm5
	vfmadd231pd	16(%rdx), %xmm0, %xmm3
	vfmadd231pd	32(%rdx), %xmm0, %xmm1
	addq	$8, %rcx
	addq	$48, %rdx
	addq	$-1, %rsi
	jne	LBB27_6
LBB27_7:
	vmovupd	%xmm5, (%r8)
	vmovupd	%xmm3, 16(%r8)
	vmovupd	%xmm1, 32(%r8)
	movq	%r9, (%rdi)
	movq	%rax, 8(%rdi)
	movq	%rdi, %rax
	popq	%rbx
	popq	%r14
	popq	%r15
	vzeroupper
	retq
	.cfi_endproc

	.globl	__D3mir4blas8internal12micro_kernel39__T17scale_nano_kernelVmi1Vmi6Vmi1TdTdZ17scale_nano_kernelFNaNbNiNfKG6G1G1dG1dZv
	.weak_definition	__D3mir4blas8internal12micro_kernel39__T17scale_nano_kernelVmi1Vmi6Vmi1TdTdZ17scale_nano_kernelFNaNbNiNfKG6G1G1dG1dZv
	.align	4, 0x90
__D3mir4blas8internal12micro_kernel39__T17scale_nano_kernelVmi1Vmi6Vmi1TdTdZ17scale_nano_kernelFNaNbNiNfKG6G1G1dG1dZv:
	.cfi_startproc
	vunpcklpd	%xmm0, %xmm0, %xmm0
	vmulpd	(%rdi), %xmm0, %xmm1
	vmulpd	16(%rdi), %xmm0, %xmm2
	vmulpd	32(%rdi), %xmm0, %xmm0
	vmovupd	%xmm1, (%rdi)
	vmovupd	%xmm2, 16(%rdi)
	vmovupd	%xmm0, 32(%rdi)
	retq
	.cfi_endproc

	.globl	__D3mir4blas8internal12micro_kernel38__T16save_nano_kernelVmi1Vmi1Vmi6TdTdZ16save_nano_kernelFNaNbNiKG6G1G1dPG1dlZv
	.weak_definition	__D3mir4blas8internal12micro_kernel38__T16save_nano_kernelVmi1Vmi1Vmi6TdTdZ16save_nano_kernelFNaNbNiKG6G1G1dPG1dlZv
	.align	4, 0x90
__D3mir4blas8internal12micro_kernel38__T16save_nano_kernelVmi1Vmi1Vmi6TdTdZ16save_nano_kernelFNaNbNiKG6G1G1dPG1dlZv:
	.cfi_startproc
	vmovsd	(%rdx), %xmm0
	vaddsd	(%rsi), %xmm0, %xmm0
	vmovsd	%xmm0, (%rsi)
	vmovsd	8(%rdx), %xmm0
	vaddsd	(%rsi,%rdi,8), %xmm0, %xmm0
	vmovsd	%xmm0, (%rsi,%rdi,8)
	movq	%rdi, %rax
	shlq	$4, %rax
	vmovsd	16(%rdx), %xmm0
	vaddsd	(%rsi,%rax), %xmm0, %xmm0
	vmovsd	%xmm0, (%rsi,%rax)
	leaq	(%rdi,%rdi,2), %rax
	vmovsd	24(%rdx), %xmm0
	vaddsd	(%rsi,%rax,8), %xmm0, %xmm0
	vmovsd	%xmm0, (%rsi,%rax,8)
	movq	%rdi, %rax
	shlq	$5, %rax
	vmovsd	32(%rdx), %xmm0
	vaddsd	(%rsi,%rax), %xmm0, %xmm0
	vmovsd	%xmm0, (%rsi,%rax)
	leaq	(%rdi,%rdi,4), %rax
	vmovsd	40(%rdx), %xmm0
	vaddsd	(%rsi,%rax,8), %xmm0, %xmm0
	vmovsd	%xmm0, (%rsi,%rax,8)
	retq
	.cfi_endproc

	.globl	__D3mir4blas8internal7utility23__T4loadVmi6Vmi1Vmi1TdZ4loadFNaNbNiNfKG6G1G1dKG6G1G1dZv
	.weak_definition	__D3mir4blas8internal7utility23__T4loadVmi6Vmi1Vmi1TdZ4loadFNaNbNiNfKG6G1G1dKG6G1G1dZv
	.align	4, 0x90
__D3mir4blas8internal7utility23__T4loadVmi6Vmi1Vmi1TdZ4loadFNaNbNiNfKG6G1G1dKG6G1G1dZv:
	.cfi_startproc
	vmovsd	(%rdi), %xmm0
	vmovsd	%xmm0, (%rsi)
	vmovsd	8(%rdi), %xmm0
	vmovsd	%xmm0, 8(%rsi)
	vmovsd	16(%rdi), %xmm0
	vmovsd	%xmm0, 16(%rsi)
	vmovsd	24(%rdi), %xmm0
	vmovsd	%xmm0, 24(%rsi)
	vmovsd	32(%rdi), %xmm0
	vmovsd	%xmm0, 32(%rsi)
	vmovsd	40(%rdi), %xmm0
	vmovsd	%xmm0, 40(%rsi)
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

	.globl	__D3mir4blas8internal12micro_kernel34__T16save_nano_kernelVmi1Vmi1TdTdZ16save_nano_kernelFNaNbNiNfKG1G1dPG1dZv
	.weak_definition	__D3mir4blas8internal12micro_kernel34__T16save_nano_kernelVmi1Vmi1TdTdZ16save_nano_kernelFNaNbNiNfKG1G1dPG1dZv
	.align	4, 0x90
__D3mir4blas8internal12micro_kernel34__T16save_nano_kernelVmi1Vmi1TdTdZ16save_nano_kernelFNaNbNiNfKG1G1dPG1dZv:
	.cfi_startproc
	vmovsd	(%rsi), %xmm0
	vaddsd	(%rdi), %xmm0, %xmm0
	vmovsd	%xmm0, (%rdi)
	retq
	.cfi_endproc

	.globl	__D3mir4blas8internal7utility31__T8set_zeroVmi4Vmi1Vmi2TNhG2dZ8set_zeroFNaNbNiNfKG4G1G2NhG2dZv
	.weak_definition	__D3mir4blas8internal7utility31__T8set_zeroVmi4Vmi1Vmi2TNhG2dZ8set_zeroFNaNbNiNfKG4G1G2NhG2dZv
	.align	4, 0x90
__D3mir4blas8internal7utility31__T8set_zeroVmi4Vmi1Vmi2TNhG2dZ8set_zeroFNaNbNiNfKG4G1G2NhG2dZv:
	.cfi_startproc
	vxorps	%ymm0, %ymm0, %ymm0
	vmovups	%ymm0, 96(%rdi)
	vmovups	%ymm0, 64(%rdi)
	vmovups	%ymm0, 32(%rdi)
	vmovups	%ymm0, (%rdi)
	vzeroupper
	retq
	.cfi_endproc

	.globl	__D3mir4blas8internal12micro_kernel78__T16gemm_nano_kernelVE3mir4blas6common14Multiplicationi0Vmi1Vmi2Vmi4TNhG2dTdZ16gemm_nano_kernelFNaNbNiKG4G1G2NhG2dPxG1G2NhG2dPxG4G1dmZG2Pxd
	.weak_definition	__D3mir4blas8internal12micro_kernel78__T16gemm_nano_kernelVE3mir4blas6common14Multiplicationi0Vmi1Vmi2Vmi4TNhG2dTdZ16gemm_nano_kernelFNaNbNiKG4G1G2NhG2dPxG1G2NhG2dPxG4G1dmZG2Pxd
	.align	4, 0x90
__D3mir4blas8internal12micro_kernel78__T16gemm_nano_kernelVE3mir4blas6common14Multiplicationi0Vmi1Vmi2Vmi4TNhG2dTdZ16gemm_nano_kernelFNaNbNiKG4G1G2NhG2dPxG1G2NhG2dPxG4G1dmZG2Pxd:
	.cfi_startproc
	vmovapd	(%r8), %xmm7
	vmovapd	16(%r8), %xmm6
	vmovapd	32(%r8), %xmm13
	vmovapd	48(%r8), %xmm12
	vmovapd	64(%r8), %xmm11
	vmovapd	80(%r8), %xmm10
	vmovapd	96(%r8), %xmm9
	vmovapd	112(%r8), %xmm8
	movq	%rsi, %r10
	shlq	$5, %r10
	leaq	(%rdx,%r10), %r9
	movq	%rcx, %rax
	.align	4, 0x90
LBB34_1:
	vmovapd	(%rax), %xmm0
	vmovapd	16(%rax), %xmm1
	vmovddup	(%rdx), %xmm2
	vmovddup	8(%rdx), %xmm3
	vmovddup	16(%rdx), %xmm4
	vmovddup	24(%rdx), %xmm5
	vfmadd231pd	%xmm2, %xmm0, %xmm7
	vfmadd231pd	%xmm2, %xmm1, %xmm6
	vfmadd231pd	%xmm3, %xmm0, %xmm13
	vfmadd231pd	%xmm3, %xmm1, %xmm12
	vfmadd231pd	%xmm4, %xmm0, %xmm11
	vfmadd231pd	%xmm4, %xmm1, %xmm10
	vfmadd231pd	%xmm5, %xmm0, %xmm9
	vfmadd231pd	%xmm5, %xmm1, %xmm8
	addq	$32, %rax
	addq	$32, %rdx
	addq	$-1, %rsi
	jne	LBB34_1
	vmovapd	%xmm7, (%r8)
	vmovapd	%xmm6, 16(%r8)
	vmovapd	%xmm13, 32(%r8)
	vmovapd	%xmm12, 48(%r8)
	vmovapd	%xmm11, 64(%r8)
	vmovapd	%xmm10, 80(%r8)
	vmovapd	%xmm9, 96(%r8)
	vmovapd	%xmm8, 112(%r8)
	addq	%r10, %rcx
	movq	%rcx, (%rdi)
	movq	%r9, 8(%rdi)
	movq	%rdi, %rax
	retq
	.cfi_endproc

	.globl	__D3mir4blas8internal12micro_kernel43__T17scale_nano_kernelVmi1Vmi4Vmi2TNhG2dTdZ17scale_nano_kernelFNaNbNiNfKG4G1G2NhG2dG1dZv
	.weak_definition	__D3mir4blas8internal12micro_kernel43__T17scale_nano_kernelVmi1Vmi4Vmi2TNhG2dTdZ17scale_nano_kernelFNaNbNiNfKG4G1G2NhG2dG1dZv
	.align	4, 0x90
__D3mir4blas8internal12micro_kernel43__T17scale_nano_kernelVmi1Vmi4Vmi2TNhG2dTdZ17scale_nano_kernelFNaNbNiNfKG4G1G2NhG2dG1dZv:
	.cfi_startproc
	vunpcklpd	%xmm0, %xmm0, %xmm0
	vmulpd	(%rdi), %xmm0, %xmm1
	vmulpd	16(%rdi), %xmm0, %xmm2
	vmulpd	32(%rdi), %xmm0, %xmm3
	vmulpd	48(%rdi), %xmm0, %xmm4
	vmulpd	64(%rdi), %xmm0, %xmm5
	vmulpd	80(%rdi), %xmm0, %xmm6
	vmulpd	96(%rdi), %xmm0, %xmm7
	vmulpd	112(%rdi), %xmm0, %xmm0
	vmovapd	%xmm1, (%rdi)
	vmovapd	%xmm2, 16(%rdi)
	vmovapd	%xmm3, 32(%rdi)
	vmovapd	%xmm4, 48(%rdi)
	vmovapd	%xmm5, 64(%rdi)
	vmovapd	%xmm6, 80(%rdi)
	vmovapd	%xmm7, 96(%rdi)
	vmovapd	%xmm0, 112(%rdi)
	retq
	.cfi_endproc

	.globl	__D3mir4blas8internal12micro_kernel42__T16save_nano_kernelVmi1Vmi2Vmi4TNhG2dTdZ16save_nano_kernelFNaNbNiKG4G1G2NhG2dPG1dlZv
	.weak_definition	__D3mir4blas8internal12micro_kernel42__T16save_nano_kernelVmi1Vmi2Vmi4TNhG2dTdZ16save_nano_kernelFNaNbNiKG4G1G2NhG2dPG1dlZv
	.align	4, 0x90
__D3mir4blas8internal12micro_kernel42__T16save_nano_kernelVmi1Vmi2Vmi4TNhG2dTdZ16save_nano_kernelFNaNbNiKG4G1G2NhG2dPG1dlZv:
	.cfi_startproc
	vmovsd	(%rdx), %xmm0
	vaddsd	(%rsi), %xmm0, %xmm0
	vmovsd	%xmm0, (%rsi)
	vmovsd	8(%rdx), %xmm0
	vaddsd	8(%rsi), %xmm0, %xmm0
	vmovsd	%xmm0, 8(%rsi)
	vmovsd	16(%rdx), %xmm0
	vaddsd	16(%rsi), %xmm0, %xmm0
	vmovsd	%xmm0, 16(%rsi)
	vmovsd	24(%rdx), %xmm0
	vaddsd	24(%rsi), %xmm0, %xmm0
	vmovsd	%xmm0, 24(%rsi)
	vmovsd	32(%rdx), %xmm0
	vaddsd	(%rsi,%rdi,8), %xmm0, %xmm0
	vmovsd	%xmm0, (%rsi,%rdi,8)
	vmovsd	40(%rdx), %xmm0
	vaddsd	8(%rsi,%rdi,8), %xmm0, %xmm0
	vmovsd	%xmm0, 8(%rsi,%rdi,8)
	vmovsd	48(%rdx), %xmm0
	vaddsd	16(%rsi,%rdi,8), %xmm0, %xmm0
	vmovsd	%xmm0, 16(%rsi,%rdi,8)
	vmovsd	56(%rdx), %xmm0
	vaddsd	24(%rsi,%rdi,8), %xmm0, %xmm0
	vmovsd	%xmm0, 24(%rsi,%rdi,8)
	movq	%rdi, %rax
	shlq	$4, %rax
	vmovsd	64(%rdx), %xmm0
	vaddsd	(%rsi,%rax), %xmm0, %xmm0
	vmovsd	%xmm0, (%rsi,%rax)
	vmovsd	72(%rdx), %xmm0
	vaddsd	8(%rsi,%rax), %xmm0, %xmm0
	vmovsd	%xmm0, 8(%rsi,%rax)
	vmovsd	80(%rdx), %xmm0
	vaddsd	16(%rsi,%rax), %xmm0, %xmm0
	vmovsd	%xmm0, 16(%rsi,%rax)
	vmovsd	88(%rdx), %xmm0
	vaddsd	24(%rsi,%rax), %xmm0, %xmm0
	vmovsd	%xmm0, 24(%rsi,%rax)
	leaq	(%rdi,%rdi,2), %rax
	vmovsd	96(%rdx), %xmm0
	vaddsd	(%rsi,%rax,8), %xmm0, %xmm0
	vmovsd	%xmm0, (%rsi,%rax,8)
	vmovsd	104(%rdx), %xmm0
	vaddsd	8(%rsi,%rax,8), %xmm0, %xmm0
	vmovsd	%xmm0, 8(%rsi,%rax,8)
	vmovsd	112(%rdx), %xmm0
	vaddsd	16(%rsi,%rax,8), %xmm0, %xmm0
	vmovsd	%xmm0, 16(%rsi,%rax,8)
	vmovsd	120(%rdx), %xmm0
	vaddsd	24(%rsi,%rax,8), %xmm0, %xmm0
	vmovsd	%xmm0, 24(%rsi,%rax,8)
	retq
	.cfi_endproc

	.globl	__D3mir4blas8internal7utility27__T4loadVmi4Vmi1Vmi2TNhG2dZ4loadFNaNbNiNfKG4G1G2NhG2dKG4G1G2NhG2dZv
	.weak_definition	__D3mir4blas8internal7utility27__T4loadVmi4Vmi1Vmi2TNhG2dZ4loadFNaNbNiNfKG4G1G2NhG2dKG4G1G2NhG2dZv
	.align	4, 0x90
__D3mir4blas8internal7utility27__T4loadVmi4Vmi1Vmi2TNhG2dZ4loadFNaNbNiNfKG4G1G2NhG2dKG4G1G2NhG2dZv:
	.cfi_startproc
	vmovaps	(%rdi), %xmm0
	vmovaps	%xmm0, (%rsi)
	vmovaps	16(%rdi), %xmm0
	vmovaps	%xmm0, 16(%rsi)
	vmovaps	32(%rdi), %xmm0
	vmovaps	%xmm0, 32(%rsi)
	vmovaps	48(%rdi), %xmm0
	vmovaps	%xmm0, 48(%rsi)
	vmovaps	64(%rdi), %xmm0
	vmovaps	%xmm0, 64(%rsi)
	vmovaps	80(%rdi), %xmm0
	vmovaps	%xmm0, 80(%rsi)
	vmovaps	96(%rdi), %xmm0
	vmovaps	%xmm0, 96(%rsi)
	vmovaps	112(%rdi), %xmm0
	vmovaps	%xmm0, 112(%rsi)
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

	.globl	__D3mir4blas8internal12micro_kernel78__T16gemm_nano_kernelVE3mir4blas6common14Multiplicationi0Vmi1Vmi1Vmi4TNhG2dTdZ16gemm_nano_kernelFNaNbNiKG4G1G1NhG2dPxG1G1NhG2dPxG4G1dmZG2Pxd
	.weak_definition	__D3mir4blas8internal12micro_kernel78__T16gemm_nano_kernelVE3mir4blas6common14Multiplicationi0Vmi1Vmi1Vmi4TNhG2dTdZ16gemm_nano_kernelFNaNbNiKG4G1G1NhG2dPxG1G1NhG2dPxG4G1dmZG2Pxd
	.align	4, 0x90
__D3mir4blas8internal12micro_kernel78__T16gemm_nano_kernelVE3mir4blas6common14Multiplicationi0Vmi1Vmi1Vmi4TNhG2dTdZ16gemm_nano_kernelFNaNbNiKG4G1G1NhG2dPxG1G1NhG2dPxG4G1dmZG2Pxd:
	.cfi_startproc
	vmovapd	(%r8), %xmm3
	vmovapd	16(%r8), %xmm2
	vmovapd	32(%r8), %xmm1
	vmovapd	48(%r8), %xmm0
	movq	%rsi, %r9
	shlq	$5, %r9
	addq	%rdx, %r9
	movq	%rsi, %r10
	movq	%rcx, %rax
	.align	4, 0x90
LBB39_1:
	vmovapd	(%rax), %xmm4
	vmovddup	(%rdx), %xmm5
	vmovddup	8(%rdx), %xmm6
	vmovddup	16(%rdx), %xmm7
	vmovddup	24(%rdx), %xmm8
	vfmadd231pd	%xmm5, %xmm4, %xmm3
	vfmadd231pd	%xmm6, %xmm4, %xmm2
	vfmadd231pd	%xmm7, %xmm4, %xmm1
	vfmadd231pd	%xmm8, %xmm4, %xmm0
	addq	$16, %rax
	addq	$32, %rdx
	addq	$-1, %r10
	jne	LBB39_1
	vmovapd	%xmm3, (%r8)
	vmovapd	%xmm2, 16(%r8)
	vmovapd	%xmm1, 32(%r8)
	vmovapd	%xmm0, 48(%r8)
	shlq	$4, %rsi
	addq	%rsi, %rcx
	movq	%rcx, (%rdi)
	movq	%r9, 8(%rdi)
	movq	%rdi, %rax
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

	.globl	__D3mir4blas8internal12micro_kernel42__T16save_nano_kernelVmi1Vmi1Vmi4TNhG2dTdZ16save_nano_kernelFNaNbNiKG4G1G1NhG2dPG1dlZv
	.weak_definition	__D3mir4blas8internal12micro_kernel42__T16save_nano_kernelVmi1Vmi1Vmi4TNhG2dTdZ16save_nano_kernelFNaNbNiKG4G1G1NhG2dPG1dlZv
	.align	4, 0x90
__D3mir4blas8internal12micro_kernel42__T16save_nano_kernelVmi1Vmi1Vmi4TNhG2dTdZ16save_nano_kernelFNaNbNiKG4G1G1NhG2dPG1dlZv:
	.cfi_startproc
	vmovsd	(%rdx), %xmm0
	vaddsd	(%rsi), %xmm0, %xmm0
	vmovsd	%xmm0, (%rsi)
	vmovsd	8(%rdx), %xmm0
	vaddsd	8(%rsi), %xmm0, %xmm0
	vmovsd	%xmm0, 8(%rsi)
	vmovsd	16(%rdx), %xmm0
	vaddsd	(%rsi,%rdi,8), %xmm0, %xmm0
	vmovsd	%xmm0, (%rsi,%rdi,8)
	vmovsd	24(%rdx), %xmm0
	vaddsd	8(%rsi,%rdi,8), %xmm0, %xmm0
	vmovsd	%xmm0, 8(%rsi,%rdi,8)
	movq	%rdi, %rax
	shlq	$4, %rax
	vmovsd	32(%rdx), %xmm0
	vaddsd	(%rsi,%rax), %xmm0, %xmm0
	vmovsd	%xmm0, (%rsi,%rax)
	vmovsd	40(%rdx), %xmm0
	vaddsd	8(%rsi,%rax), %xmm0, %xmm0
	vmovsd	%xmm0, 8(%rsi,%rax)
	leaq	(%rdi,%rdi,2), %rax
	vmovsd	48(%rdx), %xmm0
	vaddsd	(%rsi,%rax,8), %xmm0, %xmm0
	vmovsd	%xmm0, (%rsi,%rax,8)
	vmovsd	56(%rdx), %xmm0
	vaddsd	8(%rsi,%rax,8), %xmm0, %xmm0
	vmovsd	%xmm0, 8(%rsi,%rax,8)
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

	.globl	__D3mir4blas8internal12micro_kernel74__T16gemm_nano_kernelVE3mir4blas6common14Multiplicationi0Vmi1Vmi1Vmi4TdTdZ16gemm_nano_kernelFNaNbNiKG4G1G1dPxG1G1dPxG4G1dmZG2Pxd
	.weak_definition	__D3mir4blas8internal12micro_kernel74__T16gemm_nano_kernelVE3mir4blas6common14Multiplicationi0Vmi1Vmi1Vmi4TdTdZ16gemm_nano_kernelFNaNbNiKG4G1G1dPxG1G1dPxG4G1dmZG2Pxd
	.align	4, 0x90
__D3mir4blas8internal12micro_kernel74__T16gemm_nano_kernelVE3mir4blas6common14Multiplicationi0Vmi1Vmi1Vmi4TdTdZ16gemm_nano_kernelFNaNbNiKG4G1G1dPxG1G1dPxG4G1dmZG2Pxd:
	.cfi_startproc
	pushq	%r15
Ltmp33:
	.cfi_def_cfa_offset 16
	pushq	%r14
Ltmp34:
	.cfi_def_cfa_offset 24
	pushq	%rbx
Ltmp35:
	.cfi_def_cfa_offset 32
Ltmp36:
	.cfi_offset %rbx, -32
Ltmp37:
	.cfi_offset %r14, -24
Ltmp38:
	.cfi_offset %r15, -16
	vmovupd	(%r8), %xmm3
	vmovupd	16(%r8), %xmm1
	movq	%rsi, %r10
	shlq	$5, %r10
	addq	%rdx, %r10
	leaq	(%rcx,%rsi,8), %r9
	testq	%rsi, %rsi
	je	LBB44_6
	movq	%rsi, %rax
	andq	$-4, %rax
	movq	%rsi, %r11
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
	movq	%rsi, %r15
	andq	$-4, %r11
	je	LBB44_2
	subq	%rax, %r15
	shlq	$5, %rax
	addq	%rdx, %rax
	leaq	(%rcx,%r11,8), %r14
	addq	$120, %rdx
	addq	$24, %rcx
	movq	%r11, %rbx
	.align	4, 0x90
LBB44_4:
	vmovupd	-24(%rcx), %xmm4
	vmovsd	-8(%rcx), %xmm5
	vmovhpd	(%rcx), %xmm5, %xmm5
	vinsertf128	$1, %xmm5, %ymm4, %ymm4
	vmovsd	-56(%rdx), %xmm5
	vmovhpd	-24(%rdx), %xmm5, %xmm5
	vmovsd	-120(%rdx), %xmm6
	vmovsd	-112(%rdx), %xmm7
	vmovhpd	-88(%rdx), %xmm6, %xmm6
	vinsertf128	$1, %xmm5, %ymm6, %ymm5
	vmovsd	-48(%rdx), %xmm6
	vmovhpd	-16(%rdx), %xmm6, %xmm6
	vmovhpd	-80(%rdx), %xmm7, %xmm7
	vinsertf128	$1, %xmm6, %ymm7, %ymm6
	vmovsd	-40(%rdx), %xmm7
	vmovhpd	-8(%rdx), %xmm7, %xmm7
	vmovsd	-104(%rdx), %xmm0
	vmovhpd	-72(%rdx), %xmm0, %xmm0
	vinsertf128	$1, %xmm7, %ymm0, %ymm0
	vmovsd	-32(%rdx), %xmm7
	vmovhpd	(%rdx), %xmm7, %xmm7
	vmovsd	-96(%rdx), %xmm1
	vmovhpd	-64(%rdx), %xmm1, %xmm1
	vinsertf128	$1, %xmm7, %ymm1, %ymm1
	vfmadd231pd	%ymm4, %ymm5, %ymm3
	vfmadd231pd	%ymm4, %ymm6, %ymm2
	vfmadd231pd	%ymm4, %ymm0, %ymm9
	vfmadd231pd	%ymm4, %ymm1, %ymm8
	subq	$-128, %rdx
	addq	$32, %rcx
	addq	$-4, %rbx
	jne	LBB44_4
	jmp	LBB44_5
LBB44_2:
	movq	%rdx, %rax
	movq	%rcx, %r14
	xorl	%r11d, %r11d
LBB44_5:
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
	cmpq	%rsi, %r11
	movq	%r15, %rsi
	movq	%rax, %rdx
	movq	%r14, %rcx
	je	LBB44_7
	.align	4, 0x90
LBB44_6:
	vmovddup	(%rcx), %xmm0
	vfmadd231pd	(%rdx), %xmm0, %xmm3
	vfmadd231pd	16(%rdx), %xmm0, %xmm1
	addq	$8, %rcx
	addq	$32, %rdx
	addq	$-1, %rsi
	jne	LBB44_6
LBB44_7:
	vmovupd	%xmm3, (%r8)
	vmovupd	%xmm1, 16(%r8)
	movq	%r9, (%rdi)
	movq	%r10, 8(%rdi)
	movq	%rdi, %rax
	popq	%rbx
	popq	%r14
	popq	%r15
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

	.globl	__D3mir4blas8internal12micro_kernel38__T16save_nano_kernelVmi1Vmi1Vmi4TdTdZ16save_nano_kernelFNaNbNiKG4G1G1dPG1dlZv
	.weak_definition	__D3mir4blas8internal12micro_kernel38__T16save_nano_kernelVmi1Vmi1Vmi4TdTdZ16save_nano_kernelFNaNbNiKG4G1G1dPG1dlZv
	.align	4, 0x90
__D3mir4blas8internal12micro_kernel38__T16save_nano_kernelVmi1Vmi1Vmi4TdTdZ16save_nano_kernelFNaNbNiKG4G1G1dPG1dlZv:
	.cfi_startproc
	vmovsd	(%rdx), %xmm0
	vaddsd	(%rsi), %xmm0, %xmm0
	vmovsd	%xmm0, (%rsi)
	vmovsd	8(%rdx), %xmm0
	vaddsd	(%rsi,%rdi,8), %xmm0, %xmm0
	vmovsd	%xmm0, (%rsi,%rdi,8)
	movq	%rdi, %rax
	shlq	$4, %rax
	vmovsd	16(%rdx), %xmm0
	vaddsd	(%rsi,%rax), %xmm0, %xmm0
	vmovsd	%xmm0, (%rsi,%rax)
	leaq	(%rdi,%rdi,2), %rax
	vmovsd	24(%rdx), %xmm0
	vaddsd	(%rsi,%rax,8), %xmm0, %xmm0
	vmovsd	%xmm0, (%rsi,%rax,8)
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

	.globl	__D3mir4blas8internal7utility31__T8set_zeroVmi2Vmi1Vmi2TNhG2dZ8set_zeroFNaNbNiNfKG2G1G2NhG2dZv
	.weak_definition	__D3mir4blas8internal7utility31__T8set_zeroVmi2Vmi1Vmi2TNhG2dZ8set_zeroFNaNbNiNfKG2G1G2NhG2dZv
	.align	4, 0x90
__D3mir4blas8internal7utility31__T8set_zeroVmi2Vmi1Vmi2TNhG2dZ8set_zeroFNaNbNiNfKG2G1G2NhG2dZv:
	.cfi_startproc
	vxorps	%ymm0, %ymm0, %ymm0
	vmovups	%ymm0, 32(%rdi)
	vmovups	%ymm0, (%rdi)
	vzeroupper
	retq
	.cfi_endproc

	.globl	__D3mir4blas8internal12micro_kernel78__T16gemm_nano_kernelVE3mir4blas6common14Multiplicationi0Vmi1Vmi2Vmi2TNhG2dTdZ16gemm_nano_kernelFNaNbNiKG2G1G2NhG2dPxG1G2NhG2dPxG2G1dmZG2Pxd
	.weak_definition	__D3mir4blas8internal12micro_kernel78__T16gemm_nano_kernelVE3mir4blas6common14Multiplicationi0Vmi1Vmi2Vmi2TNhG2dTdZ16gemm_nano_kernelFNaNbNiKG2G1G2NhG2dPxG1G2NhG2dPxG2G1dmZG2Pxd
	.align	4, 0x90
__D3mir4blas8internal12micro_kernel78__T16gemm_nano_kernelVE3mir4blas6common14Multiplicationi0Vmi1Vmi2Vmi2TNhG2dTdZ16gemm_nano_kernelFNaNbNiKG2G1G2NhG2dPxG1G2NhG2dPxG2G1dmZG2Pxd:
	.cfi_startproc
	vmovapd	(%r8), %xmm3
	vmovapd	16(%r8), %xmm2
	vmovapd	32(%r8), %xmm1
	vmovapd	48(%r8), %xmm0
	movq	%rsi, %r9
	shlq	$4, %r9
	addq	%rdx, %r9
	movq	%rsi, %r10
	movq	%rcx, %rax
	.align	4, 0x90
LBB49_1:
	vmovapd	(%rax), %xmm4
	vmovapd	16(%rax), %xmm5
	vmovddup	(%rdx), %xmm6
	vmovddup	8(%rdx), %xmm7
	vfmadd231pd	%xmm6, %xmm4, %xmm3
	vfmadd231pd	%xmm6, %xmm5, %xmm2
	vfmadd231pd	%xmm7, %xmm4, %xmm1
	vfmadd231pd	%xmm7, %xmm5, %xmm0
	addq	$32, %rax
	addq	$16, %rdx
	addq	$-1, %r10
	jne	LBB49_1
	vmovapd	%xmm3, (%r8)
	vmovapd	%xmm2, 16(%r8)
	vmovapd	%xmm1, 32(%r8)
	vmovapd	%xmm0, 48(%r8)
	shlq	$5, %rsi
	addq	%rsi, %rcx
	movq	%rcx, (%rdi)
	movq	%r9, 8(%rdi)
	movq	%rdi, %rax
	retq
	.cfi_endproc

	.globl	__D3mir4blas8internal12micro_kernel43__T17scale_nano_kernelVmi1Vmi2Vmi2TNhG2dTdZ17scale_nano_kernelFNaNbNiNfKG2G1G2NhG2dG1dZv
	.weak_definition	__D3mir4blas8internal12micro_kernel43__T17scale_nano_kernelVmi1Vmi2Vmi2TNhG2dTdZ17scale_nano_kernelFNaNbNiNfKG2G1G2NhG2dG1dZv
	.align	4, 0x90
__D3mir4blas8internal12micro_kernel43__T17scale_nano_kernelVmi1Vmi2Vmi2TNhG2dTdZ17scale_nano_kernelFNaNbNiNfKG2G1G2NhG2dG1dZv:
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

	.globl	__D3mir4blas8internal12micro_kernel42__T16save_nano_kernelVmi1Vmi2Vmi2TNhG2dTdZ16save_nano_kernelFNaNbNiKG2G1G2NhG2dPG1dlZv
	.weak_definition	__D3mir4blas8internal12micro_kernel42__T16save_nano_kernelVmi1Vmi2Vmi2TNhG2dTdZ16save_nano_kernelFNaNbNiKG2G1G2NhG2dPG1dlZv
	.align	4, 0x90
__D3mir4blas8internal12micro_kernel42__T16save_nano_kernelVmi1Vmi2Vmi2TNhG2dTdZ16save_nano_kernelFNaNbNiKG2G1G2NhG2dPG1dlZv:
	.cfi_startproc
	vmovsd	(%rdx), %xmm0
	vaddsd	(%rsi), %xmm0, %xmm0
	vmovsd	%xmm0, (%rsi)
	vmovsd	8(%rdx), %xmm0
	vaddsd	8(%rsi), %xmm0, %xmm0
	vmovsd	%xmm0, 8(%rsi)
	vmovsd	16(%rdx), %xmm0
	vaddsd	16(%rsi), %xmm0, %xmm0
	vmovsd	%xmm0, 16(%rsi)
	vmovsd	24(%rdx), %xmm0
	vaddsd	24(%rsi), %xmm0, %xmm0
	vmovsd	%xmm0, 24(%rsi)
	vmovsd	32(%rdx), %xmm0
	vaddsd	(%rsi,%rdi,8), %xmm0, %xmm0
	vmovsd	%xmm0, (%rsi,%rdi,8)
	vmovsd	40(%rdx), %xmm0
	vaddsd	8(%rsi,%rdi,8), %xmm0, %xmm0
	vmovsd	%xmm0, 8(%rsi,%rdi,8)
	vmovsd	48(%rdx), %xmm0
	vaddsd	16(%rsi,%rdi,8), %xmm0, %xmm0
	vmovsd	%xmm0, 16(%rsi,%rdi,8)
	vmovsd	56(%rdx), %xmm0
	vaddsd	24(%rsi,%rdi,8), %xmm0, %xmm0
	vmovsd	%xmm0, 24(%rsi,%rdi,8)
	retq
	.cfi_endproc

	.globl	__D3mir4blas8internal7utility27__T4loadVmi2Vmi1Vmi2TNhG2dZ4loadFNaNbNiNfKG2G1G2NhG2dKG2G1G2NhG2dZv
	.weak_definition	__D3mir4blas8internal7utility27__T4loadVmi2Vmi1Vmi2TNhG2dZ4loadFNaNbNiNfKG2G1G2NhG2dKG2G1G2NhG2dZv
	.align	4, 0x90
__D3mir4blas8internal7utility27__T4loadVmi2Vmi1Vmi2TNhG2dZ4loadFNaNbNiNfKG2G1G2NhG2dKG2G1G2NhG2dZv:
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

	.globl	__D3mir4blas8internal12micro_kernel78__T16gemm_nano_kernelVE3mir4blas6common14Multiplicationi0Vmi1Vmi1Vmi2TNhG2dTdZ16gemm_nano_kernelFNaNbNiKG2G1G1NhG2dPxG1G1NhG2dPxG2G1dmZG2Pxd
	.weak_definition	__D3mir4blas8internal12micro_kernel78__T16gemm_nano_kernelVE3mir4blas6common14Multiplicationi0Vmi1Vmi1Vmi2TNhG2dTdZ16gemm_nano_kernelFNaNbNiKG2G1G1NhG2dPxG1G1NhG2dPxG2G1dmZG2Pxd
	.align	4, 0x90
__D3mir4blas8internal12micro_kernel78__T16gemm_nano_kernelVE3mir4blas6common14Multiplicationi0Vmi1Vmi1Vmi2TNhG2dTdZ16gemm_nano_kernelFNaNbNiKG2G1G1NhG2dPxG1G1NhG2dPxG2G1dmZG2Pxd:
	.cfi_startproc
	vmovapd	(%r8), %xmm1
	vmovapd	16(%r8), %xmm0
	movq	%rsi, %r10
	shlq	$4, %r10
	leaq	(%rdx,%r10), %r9
	movq	%rcx, %rax
	.align	4, 0x90
LBB54_1:
	vmovapd	(%rax), %xmm2
	vmovddup	(%rdx), %xmm3
	vmovddup	8(%rdx), %xmm4
	vfmadd231pd	%xmm3, %xmm2, %xmm1
	vfmadd231pd	%xmm4, %xmm2, %xmm0
	addq	$16, %rax
	addq	$16, %rdx
	addq	$-1, %rsi
	jne	LBB54_1
	vmovapd	%xmm1, (%r8)
	vmovapd	%xmm0, 16(%r8)
	addq	%r10, %rcx
	movq	%rcx, (%rdi)
	movq	%r9, 8(%rdi)
	movq	%rdi, %rax
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

	.globl	__D3mir4blas8internal12micro_kernel42__T16save_nano_kernelVmi1Vmi1Vmi2TNhG2dTdZ16save_nano_kernelFNaNbNiKG2G1G1NhG2dPG1dlZv
	.weak_definition	__D3mir4blas8internal12micro_kernel42__T16save_nano_kernelVmi1Vmi1Vmi2TNhG2dTdZ16save_nano_kernelFNaNbNiKG2G1G1NhG2dPG1dlZv
	.align	4, 0x90
__D3mir4blas8internal12micro_kernel42__T16save_nano_kernelVmi1Vmi1Vmi2TNhG2dTdZ16save_nano_kernelFNaNbNiKG2G1G1NhG2dPG1dlZv:
	.cfi_startproc
	vmovsd	(%rdx), %xmm0
	vaddsd	(%rsi), %xmm0, %xmm0
	vmovsd	%xmm0, (%rsi)
	vmovsd	8(%rdx), %xmm0
	vaddsd	8(%rsi), %xmm0, %xmm0
	vmovsd	%xmm0, 8(%rsi)
	vmovsd	16(%rdx), %xmm0
	vaddsd	(%rsi,%rdi,8), %xmm0, %xmm0
	vmovsd	%xmm0, (%rsi,%rdi,8)
	vmovsd	24(%rdx), %xmm0
	vaddsd	8(%rsi,%rdi,8), %xmm0, %xmm0
	vmovsd	%xmm0, 8(%rsi,%rdi,8)
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

	.globl	__D3mir4blas8internal7utility27__T8set_zeroVmi2Vmi1Vmi1TdZ8set_zeroFNaNbNiNfKG2G1G1dZv
	.weak_definition	__D3mir4blas8internal7utility27__T8set_zeroVmi2Vmi1Vmi1TdZ8set_zeroFNaNbNiNfKG2G1G1dZv
	.align	4, 0x90
__D3mir4blas8internal7utility27__T8set_zeroVmi2Vmi1Vmi1TdZ8set_zeroFNaNbNiNfKG2G1G1dZv:
	.cfi_startproc
	vxorps	%xmm0, %xmm0, %xmm0
	vmovups	%xmm0, (%rdi)
	retq
	.cfi_endproc

	.globl	__D3mir4blas8internal12micro_kernel74__T16gemm_nano_kernelVE3mir4blas6common14Multiplicationi0Vmi1Vmi1Vmi2TdTdZ16gemm_nano_kernelFNaNbNiKG2G1G1dPxG1G1dPxG2G1dmZG2Pxd
	.weak_definition	__D3mir4blas8internal12micro_kernel74__T16gemm_nano_kernelVE3mir4blas6common14Multiplicationi0Vmi1Vmi1Vmi2TdTdZ16gemm_nano_kernelFNaNbNiKG2G1G1dPxG1G1dPxG2G1dmZG2Pxd
	.align	4, 0x90
__D3mir4blas8internal12micro_kernel74__T16gemm_nano_kernelVE3mir4blas6common14Multiplicationi0Vmi1Vmi1Vmi2TdTdZ16gemm_nano_kernelFNaNbNiKG2G1G1dPxG1G1dPxG2G1dmZG2Pxd:
	.cfi_startproc
	pushq	%r15
Ltmp39:
	.cfi_def_cfa_offset 16
	pushq	%r14
Ltmp40:
	.cfi_def_cfa_offset 24
	pushq	%rbx
Ltmp41:
	.cfi_def_cfa_offset 32
Ltmp42:
	.cfi_offset %rbx, -32
Ltmp43:
	.cfi_offset %r14, -24
Ltmp44:
	.cfi_offset %r15, -16
	vmovupd	(%r8), %xmm1
	movq	%rsi, %r10
	shlq	$4, %r10
	addq	%rdx, %r10
	leaq	(%rcx,%rsi,8), %r9
	testq	%rsi, %rsi
	je	LBB59_6
	movq	%rsi, %rax
	andq	$-4, %rax
	movq	%rsi, %r11
	vpermilpd	$1, %xmm1, %xmm0
	vmovq	%xmm0, %xmm0
	vxorpd	%ymm2, %ymm2, %ymm2
	vinsertf128	$0, %xmm0, %ymm2, %ymm0
	vmovq	%xmm1, %xmm1
	vinsertf128	$0, %xmm1, %ymm2, %ymm1
	movq	%rsi, %r15
	andq	$-4, %r11
	je	LBB59_2
	subq	%rax, %r15
	shlq	$4, %rax
	addq	%rdx, %rax
	leaq	(%rcx,%r11,8), %r14
	addq	$56, %rdx
	addq	$24, %rcx
	movq	%r11, %rbx
	.align	4, 0x90
LBB59_4:
	vmovupd	-24(%rcx), %xmm2
	vmovsd	-8(%rcx), %xmm3
	vmovhpd	(%rcx), %xmm3, %xmm3
	vinsertf128	$1, %xmm3, %ymm2, %ymm2
	vmovsd	-24(%rdx), %xmm3
	vmovhpd	-8(%rdx), %xmm3, %xmm3
	vmovsd	-56(%rdx), %xmm4
	vmovsd	-48(%rdx), %xmm5
	vmovhpd	-40(%rdx), %xmm4, %xmm4
	vinsertf128	$1, %xmm3, %ymm4, %ymm3
	vmovsd	-16(%rdx), %xmm4
	vmovhpd	(%rdx), %xmm4, %xmm4
	vmovhpd	-32(%rdx), %xmm5, %xmm5
	vinsertf128	$1, %xmm4, %ymm5, %ymm4
	vfmadd231pd	%ymm2, %ymm3, %ymm1
	vfmadd231pd	%ymm2, %ymm4, %ymm0
	addq	$64, %rdx
	addq	$32, %rcx
	addq	$-4, %rbx
	jne	LBB59_4
	jmp	LBB59_5
LBB59_2:
	movq	%rdx, %rax
	movq	%rcx, %r14
	xorl	%r11d, %r11d
LBB59_5:
	vextractf128	$1, %ymm1, %xmm2
	vaddpd	%ymm2, %ymm1, %ymm1
	vhaddpd	%ymm1, %ymm1, %ymm1
	vextractf128	$1, %ymm0, %xmm2
	vaddpd	%ymm2, %ymm0, %ymm0
	vhaddpd	%ymm0, %ymm0, %ymm0
	vunpcklpd	%xmm0, %xmm1, %xmm1
	cmpq	%rsi, %r11
	movq	%r15, %rsi
	movq	%rax, %rdx
	movq	%r14, %rcx
	je	LBB59_7
	.align	4, 0x90
LBB59_6:
	vmovddup	(%rcx), %xmm0
	vfmadd231pd	(%rdx), %xmm0, %xmm1
	addq	$8, %rcx
	addq	$16, %rdx
	addq	$-1, %rsi
	jne	LBB59_6
LBB59_7:
	vmovupd	%xmm1, (%r8)
	movq	%r9, (%rdi)
	movq	%r10, 8(%rdi)
	movq	%rdi, %rax
	popq	%rbx
	popq	%r14
	popq	%r15
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

	.globl	__D3mir4blas8internal12micro_kernel38__T16save_nano_kernelVmi1Vmi1Vmi2TdTdZ16save_nano_kernelFNaNbNiKG2G1G1dPG1dlZv
	.weak_definition	__D3mir4blas8internal12micro_kernel38__T16save_nano_kernelVmi1Vmi1Vmi2TdTdZ16save_nano_kernelFNaNbNiKG2G1G1dPG1dlZv
	.align	4, 0x90
__D3mir4blas8internal12micro_kernel38__T16save_nano_kernelVmi1Vmi1Vmi2TdTdZ16save_nano_kernelFNaNbNiKG2G1G1dPG1dlZv:
	.cfi_startproc
	vmovsd	(%rdx), %xmm0
	vaddsd	(%rsi), %xmm0, %xmm0
	vmovsd	%xmm0, (%rsi)
	vmovsd	8(%rdx), %xmm0
	vaddsd	(%rsi,%rdi,8), %xmm0, %xmm0
	vmovsd	%xmm0, (%rsi,%rdi,8)
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

	.globl	__D3mir4blas8internal7utility31__T8set_zeroVmi1Vmi1Vmi2TNhG2dZ8set_zeroFNaNbNiNfKG1G1G2NhG2dZv
	.weak_definition	__D3mir4blas8internal7utility31__T8set_zeroVmi1Vmi1Vmi2TNhG2dZ8set_zeroFNaNbNiNfKG1G1G2NhG2dZv
	.align	4, 0x90
__D3mir4blas8internal7utility31__T8set_zeroVmi1Vmi1Vmi2TNhG2dZ8set_zeroFNaNbNiNfKG1G1G2NhG2dZv:
	.cfi_startproc
	vxorps	%ymm0, %ymm0, %ymm0
	vmovups	%ymm0, (%rdi)
	vzeroupper
	retq
	.cfi_endproc

	.globl	__D3mir4blas8internal12micro_kernel78__T16gemm_nano_kernelVE3mir4blas6common14Multiplicationi0Vmi1Vmi2Vmi1TNhG2dTdZ16gemm_nano_kernelFNaNbNiKG1G1G2NhG2dPxG1G2NhG2dPxG1G1dmZG2Pxd
	.weak_definition	__D3mir4blas8internal12micro_kernel78__T16gemm_nano_kernelVE3mir4blas6common14Multiplicationi0Vmi1Vmi2Vmi1TNhG2dTdZ16gemm_nano_kernelFNaNbNiKG1G1G2NhG2dPxG1G2NhG2dPxG1G1dmZG2Pxd
	.align	4, 0x90
__D3mir4blas8internal12micro_kernel78__T16gemm_nano_kernelVE3mir4blas6common14Multiplicationi0Vmi1Vmi2Vmi1TNhG2dTdZ16gemm_nano_kernelFNaNbNiKG1G1G2NhG2dPxG1G2NhG2dPxG1G1dmZG2Pxd:
	.cfi_startproc
	vmovapd	(%r8), %xmm1
	vmovapd	16(%r8), %xmm0
	leaq	(%rdx,%rsi,8), %r9
	movq	%rsi, %r10
	movq	%rcx, %rax
	.align	4, 0x90
LBB64_1:
	vmovddup	(%rdx), %xmm2
	vfmadd231pd	(%rax), %xmm2, %xmm1
	vfmadd231pd	16(%rax), %xmm2, %xmm0
	addq	$8, %rdx
	addq	$32, %rax
	addq	$-1, %r10
	jne	LBB64_1
	vmovapd	%xmm1, (%r8)
	vmovapd	%xmm0, 16(%r8)
	shlq	$5, %rsi
	addq	%rsi, %rcx
	movq	%rcx, (%rdi)
	movq	%r9, 8(%rdi)
	movq	%rdi, %rax
	retq
	.cfi_endproc

	.globl	__D3mir4blas8internal12micro_kernel43__T17scale_nano_kernelVmi1Vmi1Vmi2TNhG2dTdZ17scale_nano_kernelFNaNbNiNfKG1G1G2NhG2dG1dZv
	.weak_definition	__D3mir4blas8internal12micro_kernel43__T17scale_nano_kernelVmi1Vmi1Vmi2TNhG2dTdZ17scale_nano_kernelFNaNbNiNfKG1G1G2NhG2dG1dZv
	.align	4, 0x90
__D3mir4blas8internal12micro_kernel43__T17scale_nano_kernelVmi1Vmi1Vmi2TNhG2dTdZ17scale_nano_kernelFNaNbNiNfKG1G1G2NhG2dG1dZv:
	.cfi_startproc
	vunpcklpd	%xmm0, %xmm0, %xmm0
	vmulpd	(%rdi), %xmm0, %xmm1
	vmulpd	16(%rdi), %xmm0, %xmm0
	vmovapd	%xmm1, (%rdi)
	vmovapd	%xmm0, 16(%rdi)
	retq
	.cfi_endproc

	.globl	__D3mir4blas8internal12micro_kernel42__T16save_nano_kernelVmi1Vmi2Vmi1TNhG2dTdZ16save_nano_kernelFNaNbNiKG1G1G2NhG2dPG1dlZv
	.weak_definition	__D3mir4blas8internal12micro_kernel42__T16save_nano_kernelVmi1Vmi2Vmi1TNhG2dTdZ16save_nano_kernelFNaNbNiKG1G1G2NhG2dPG1dlZv
	.align	4, 0x90
__D3mir4blas8internal12micro_kernel42__T16save_nano_kernelVmi1Vmi2Vmi1TNhG2dTdZ16save_nano_kernelFNaNbNiKG1G1G2NhG2dPG1dlZv:
	.cfi_startproc
	vmovsd	(%rdx), %xmm0
	vaddsd	(%rsi), %xmm0, %xmm0
	vmovsd	%xmm0, (%rsi)
	vmovsd	8(%rdx), %xmm0
	vaddsd	8(%rsi), %xmm0, %xmm0
	vmovsd	%xmm0, 8(%rsi)
	vmovsd	16(%rdx), %xmm0
	vaddsd	16(%rsi), %xmm0, %xmm0
	vmovsd	%xmm0, 16(%rsi)
	vmovsd	24(%rdx), %xmm0
	vaddsd	24(%rsi), %xmm0, %xmm0
	vmovsd	%xmm0, 24(%rsi)
	retq
	.cfi_endproc

	.globl	__D3mir4blas8internal7utility27__T4loadVmi1Vmi1Vmi2TNhG2dZ4loadFNaNbNiNfKG1G1G2NhG2dKG1G1G2NhG2dZv
	.weak_definition	__D3mir4blas8internal7utility27__T4loadVmi1Vmi1Vmi2TNhG2dZ4loadFNaNbNiNfKG1G1G2NhG2dKG1G1G2NhG2dZv
	.align	4, 0x90
__D3mir4blas8internal7utility27__T4loadVmi1Vmi1Vmi2TNhG2dZ4loadFNaNbNiNfKG1G1G2NhG2dKG1G1G2NhG2dZv:
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

	.globl	__D3mir4blas8internal12micro_kernel78__T16gemm_nano_kernelVE3mir4blas6common14Multiplicationi0Vmi1Vmi1Vmi1TNhG2dTdZ16gemm_nano_kernelFNaNbNiKG1G1G1NhG2dPxG1G1NhG2dPxG1G1dmZG2Pxd
	.weak_definition	__D3mir4blas8internal12micro_kernel78__T16gemm_nano_kernelVE3mir4blas6common14Multiplicationi0Vmi1Vmi1Vmi1TNhG2dTdZ16gemm_nano_kernelFNaNbNiKG1G1G1NhG2dPxG1G1NhG2dPxG1G1dmZG2Pxd
	.align	4, 0x90
__D3mir4blas8internal12micro_kernel78__T16gemm_nano_kernelVE3mir4blas6common14Multiplicationi0Vmi1Vmi1Vmi1TNhG2dTdZ16gemm_nano_kernelFNaNbNiKG1G1G1NhG2dPxG1G1NhG2dPxG1G1dmZG2Pxd:
	.cfi_startproc
	vmovapd	(%r8), %xmm0
	leaq	(%rdx,%rsi,8), %r9
	movq	%rsi, %r10
	movq	%rcx, %rax
	.align	4, 0x90
LBB69_1:
	vmovddup	(%rdx), %xmm1
	vfmadd231pd	(%rax), %xmm1, %xmm0
	addq	$16, %rax
	addq	$8, %rdx
	addq	$-1, %r10
	jne	LBB69_1
	vmovapd	%xmm0, (%r8)
	shlq	$4, %rsi
	addq	%rsi, %rcx
	movq	%rcx, (%rdi)
	movq	%r9, 8(%rdi)
	movq	%rdi, %rax
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

	.globl	__D3mir4blas8internal12micro_kernel42__T16save_nano_kernelVmi1Vmi1Vmi1TNhG2dTdZ16save_nano_kernelFNaNbNiKG1G1G1NhG2dPG1dlZv
	.weak_definition	__D3mir4blas8internal12micro_kernel42__T16save_nano_kernelVmi1Vmi1Vmi1TNhG2dTdZ16save_nano_kernelFNaNbNiKG1G1G1NhG2dPG1dlZv
	.align	4, 0x90
__D3mir4blas8internal12micro_kernel42__T16save_nano_kernelVmi1Vmi1Vmi1TNhG2dTdZ16save_nano_kernelFNaNbNiKG1G1G1NhG2dPG1dlZv:
	.cfi_startproc
	vmovsd	(%rdx), %xmm0
	vaddsd	(%rsi), %xmm0, %xmm0
	vmovsd	%xmm0, (%rsi)
	vmovsd	8(%rdx), %xmm0
	vaddsd	8(%rsi), %xmm0, %xmm0
	vmovsd	%xmm0, 8(%rsi)
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

	.globl	__D3mir4blas8internal7utility27__T8set_zeroVmi1Vmi1Vmi1TdZ8set_zeroFNaNbNiNfKG1G1G1dZv
	.weak_definition	__D3mir4blas8internal7utility27__T8set_zeroVmi1Vmi1Vmi1TdZ8set_zeroFNaNbNiNfKG1G1G1dZv
	.align	4, 0x90
__D3mir4blas8internal7utility27__T8set_zeroVmi1Vmi1Vmi1TdZ8set_zeroFNaNbNiNfKG1G1G1dZv:
	.cfi_startproc
	movq	$0, (%rdi)
	retq
	.cfi_endproc

	.globl	__D3mir4blas8internal12micro_kernel74__T16gemm_nano_kernelVE3mir4blas6common14Multiplicationi0Vmi1Vmi1Vmi1TdTdZ16gemm_nano_kernelFNaNbNiKG1G1G1dPxG1G1dPxG1G1dmZG2Pxd
	.weak_definition	__D3mir4blas8internal12micro_kernel74__T16gemm_nano_kernelVE3mir4blas6common14Multiplicationi0Vmi1Vmi1Vmi1TdTdZ16gemm_nano_kernelFNaNbNiKG1G1G1dPxG1G1dPxG1G1dmZG2Pxd
	.align	4, 0x90
__D3mir4blas8internal12micro_kernel74__T16gemm_nano_kernelVE3mir4blas6common14Multiplicationi0Vmi1Vmi1Vmi1TdTdZ16gemm_nano_kernelFNaNbNiKG1G1G1dPxG1G1dPxG1G1dmZG2Pxd:
	.cfi_startproc
	pushq	%r15
Ltmp45:
	.cfi_def_cfa_offset 16
	pushq	%r14
Ltmp46:
	.cfi_def_cfa_offset 24
	pushq	%rbx
Ltmp47:
	.cfi_def_cfa_offset 32
Ltmp48:
	.cfi_offset %rbx, -32
Ltmp49:
	.cfi_offset %r14, -24
Ltmp50:
	.cfi_offset %r15, -16
	vmovsd	(%r8), %xmm0
	leaq	(%rdx,%rsi,8), %r9
	leaq	(%rcx,%rsi,8), %r10
	testq	%rsi, %rsi
	je	LBB74_6
	movq	%rsi, %rax
	andq	$-8, %rax
	movq	%rsi, %rbx
	vxorpd	%ymm1, %ymm1, %ymm1
	vmovsd	%xmm0, %xmm1, %xmm0
	vinsertf128	$0, %xmm0, %ymm1, %ymm0
	movq	%rsi, %r11
	andq	$-8, %rbx
	je	LBB74_2
	subq	%rax, %r11
	leaq	(%rdx,%rbx,8), %r14
	leaq	(%rcx,%rbx,8), %r15
	addq	$56, %rdx
	addq	$56, %rcx
	vxorpd	%ymm1, %ymm1, %ymm1
	movq	%rbx, %rax
	.align	4, 0x90
LBB74_4:
	vmovupd	-56(%rcx), %ymm2
	vmovupd	-24(%rcx), %xmm3
	vmovsd	-8(%rcx), %xmm4
	vmovhpd	(%rcx), %xmm4, %xmm4
	vinsertf128	$1, %xmm4, %ymm3, %ymm3
	vmovupd	-24(%rdx), %xmm4
	vmovsd	-8(%rdx), %xmm5
	vmovhpd	(%rdx), %xmm5, %xmm5
	vinsertf128	$1, %xmm5, %ymm4, %ymm4
	vfmadd231pd	-56(%rdx), %ymm2, %ymm0
	vfmadd231pd	%ymm3, %ymm4, %ymm1
	addq	$64, %rdx
	addq	$64, %rcx
	addq	$-8, %rax
	jne	LBB74_4
	jmp	LBB74_5
LBB74_2:
	movq	%rdx, %r14
	movq	%rcx, %r15
	xorl	%ebx, %ebx
LBB74_5:
	vaddpd	%ymm0, %ymm1, %ymm0
	vextractf128	$1, %ymm0, %xmm1
	vaddpd	%ymm1, %ymm0, %ymm0
	vhaddpd	%ymm0, %ymm0, %ymm0
	cmpq	%rsi, %rbx
	movq	%r11, %rsi
	movq	%r14, %rdx
	movq	%r15, %rcx
	je	LBB74_7
	.align	4, 0x90
LBB74_6:
	vmovsd	(%rcx), %xmm1
	vfmadd231sd	(%rdx), %xmm1, %xmm0
	addq	$8, %rcx
	addq	$8, %rdx
	addq	$-1, %rsi
	jne	LBB74_6
LBB74_7:
	vmovsd	%xmm0, (%r8)
	movq	%r10, (%rdi)
	movq	%r9, 8(%rdi)
	movq	%rdi, %rax
	popq	%rbx
	popq	%r14
	popq	%r15
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

	.globl	__D3mir4blas8internal12micro_kernel38__T16save_nano_kernelVmi1Vmi1Vmi1TdTdZ16save_nano_kernelFNaNbNiKG1G1G1dPG1dlZv
	.weak_definition	__D3mir4blas8internal12micro_kernel38__T16save_nano_kernelVmi1Vmi1Vmi1TdTdZ16save_nano_kernelFNaNbNiKG1G1G1dPG1dlZv
	.align	4, 0x90
__D3mir4blas8internal12micro_kernel38__T16save_nano_kernelVmi1Vmi1Vmi1TdTdZ16save_nano_kernelFNaNbNiKG1G1G1dPG1dlZv:
	.cfi_startproc
	vmovsd	(%rdx), %xmm0
	vaddsd	(%rsi), %xmm0, %xmm0
	vmovsd	%xmm0, (%rsi)
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

	.section	__TEXT,__text,regular,pure_instructions
	.align	4, 0x90
__D3mir4blas8internal6kernel16__moduleinfoCtorZ:
	movq	__Dmodule_ref@GOTPCREL(%rip), %rax
	movq	(%rax), %rcx
	movq	%rcx, __D3mir4blas8internal6kernel11__moduleRefZ(%rip)
	leaq	__D3mir4blas8internal6kernel11__moduleRefZ(%rip), %rcx
	movq	%rcx, (%rax)
	retq

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
