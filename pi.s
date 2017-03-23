	.file "pi.tig"
	.text
	.global _Tiger_main
_Tiger_main:	/*  [] [] */
	pushq	%rbp
	movq	%rsp, %rbp
	subq	$80, %rsp
	movq	%rbx, -56(%rbp)
L49:
	movq	$10000, -8(%rbp)
	movq	$0, -16(%rbp)
	movq	$2800, -24(%rbp)
	movq	$0, -32(%rbp)
	movq	$0, %rbx
	movq	$-40, %rax
	addq	%rbp, %rax
	movq	%rax, -64(%rbp)
	movq	$2801, %rax
	movq	%rax, -72(%rbp)
	movq	$0, %rax
	movq	%rax, -80(%rbp)
	movq	-72(%rbp), %rdi
	imul	$8, %rdi
	call	malloc
	movq	$0, %rdx
L0:
	movq	-72(%rbp), %rcx
	cmp	%rcx, %rdx
	jge	L2
L1:
	movq	%rax, %rsi
	movq	%rdx, %rcx
	imul	$8, %rcx
	addq	%rcx, %rsi
	movq	-80(%rbp), %rcx
	movq	%rcx, (%rsi)
	addq	$1, %rdx
	jmp	L0
L2:
	movq	-64(%rbp), %rcx
	movq	%rax, (%rcx)
	movq	$0, -48(%rbp)
L38:
	movq	$1, %rdx
	movq	-16(%rbp), %rax
	movq	-24(%rbp), %rcx
	subq	%rcx, %rax
	cmp	$0, %rax
	jne	L40
L41:
	movq	$0, %rdx
L40:
	cmp	$0, %rdx
	je	L37
L39:
	movq	-40(%rbp), %rcx
	movq	-16(%rbp), %rax
	imul	$8, %rax
	addq	%rax, %rcx
	xor	%rdx, %rdx
	movq	-8(%rbp), %rax
	movq	$5, %rsi
	idiv	%rsi
	movq	%rax, (%rcx)
	movq	-16(%rbp), %rax
	addq	$1, %rax
	movq	%rax, -16(%rbp)
	jmp	L38
L37:
L46:
	movq	%rbp, %rdi
	call	L3
	cmp	$0, %rax
	je	L42
L47:
	movq	-24(%rbp), %rax
	movq	%rax, -16(%rbp)
L44:
	movq	%rbp, %rdi
	call	L4
	cmp	$0, %rax
	je	L43
L45:
	movq	-32(%rbp), %rax
	movq	-16(%rbp), %rcx
	imul	%rcx, %rax
	movq	%rax, -32(%rbp)
	jmp	L44
L43:
	movq	-24(%rbp), %rax
	subq	$14, %rax
	movq	%rax, -24(%rbp)
	xor	%rdx, %rdx
	movq	-32(%rbp), %rax
	movq	-8(%rbp), %rcx
	idiv	%rcx
	addq	%rax, %rbx
	movq	%rbp, %rdi
	movq	%rbx, %rsi
	call	L6
	movq	-32(%rbp), %rbx
	xor	%rdx, %rdx
	movq	-32(%rbp), %rax
	movq	-8(%rbp), %rcx
	idiv	%rcx
	movq	-8(%rbp), %rcx
	imul	%rcx, %rax
	subq	%rax, %rbx
	jmp	L46
L42:
	movq	$0, %rax
	jmp	L48
L48:
	movq	-56(%rbp), %rbx
	addq	$80, %rsp
	leave
	ret
L6:	/* printf [m~8, t106] [] */
	pushq	%rbp
	movq	%rsp, %rbp
	subq	$16, %rsp
	movq	%rbx, -16(%rbp)
L51:
	movq	%rsi, %rbx
	movq	%rdi, -8(%rbp)
	movq	$1, %rax
	cmp	$1000, %rbx
	jl	L27
L28:
	movq	$0, %rax
L27:
	cmp	$0, %rax
	je	L26
L25:
	movq	-8(%rbp), %rdi
	movq	$0, %rsi
	call	L5
L26:
	movq	$1, %rax
	cmp	$100, %rbx
	jl	L31
L32:
	movq	$0, %rax
L31:
	cmp	$0, %rax
	je	L30
L29:
	movq	-8(%rbp), %rdi
	movq	$0, %rsi
	call	L5
L30:
	movq	$1, %rax
	cmp	$10, %rbx
	jl	L35
L36:
	movq	$0, %rax
L35:
	cmp	$0, %rax
	je	L34
L33:
	movq	-8(%rbp), %rdi
	movq	$0, %rsi
	call	L5
L34:
	movq	-8(%rbp), %rdi
	movq	%rbx, %rsi
	call	L5
	jmp	L50
L50:
	movq	-16(%rbp), %rbx
	addq	$16, %rsp
	leave
	ret
L5:	/* printi [m~8, t105] [] */
	pushq	%rbp
	movq	%rsp, %rbp
	subq	$16, %rsp
	movq	%rbx, -16(%rbp)
L53:
	movq	%rsi, %rbx
	movq	%rdi, -8(%rbp)
	movq	$1, %rax
	cmp	$0, %rbx
	jl	L23
L24:
	movq	$0, %rax
L23:
	cmp	$0, %rax
	jne	L20
L21:
	movq	$1, %rax
	cmp	$0, %rbx
	jg	L18
L19:
	movq	$0, %rax
L18:
	cmp	$0, %rax
	jne	L15
L16:
	movq	$L14, %rdi
	call	print
L17:
L22:
	jmp	L52
L20:
	movq	$L13, %rdi
	call	print
	movq	$0, %rsi
	subq	%rbx, %rsi
	movq	%rbp, %rdi
	call	L7
	jmp	L22
L15:
	movq	%rbp, %rdi
	movq	%rbx, %rsi
	call	L7
	jmp	L17
L52:
	movq	-16(%rbp), %rbx
	addq	$16, %rsp
	leave
	ret
L14:	.long 1
	.ascii "0"
L13:	.long 1
	.ascii "-"
L7:	/* printi::f [m~8, t107] [] */
	pushq	%rbp
	movq	%rsp, %rbp
	subq	$16, %rsp
	movq	%rbx, -16(%rbp)
L55:
	movq	%rsi, %rbx
	movq	%rdi, -8(%rbp)
	movq	$1, %rax
	cmp	$0, %rbx
	jg	L11
L12:
	movq	$0, %rax
L11:
	cmp	$0, %rax
	je	L10
L9:
	movq	-8(%rbp), %rdi
	xor	%rdx, %rdx
	movq	%rbx, %rax
	movq	$10, %rcx
	idiv	%rcx
	movq	%rax, %rsi
	call	L7
	xor	%rdx, %rdx
	movq	%rbx, %rax
	movq	$10, %rcx
	idiv	%rcx
	imul	$10, %rax
	subq	%rax, %rbx
	movq	$L8, %rdi
	call	ord
	addq	%rax, %rbx
	movq	%rbx, %rdi
	call	chr
	movq	%rax, %rdi
	call	print
L10:
	movq	$0, %rax
	jmp	L54
L54:
	movq	-16(%rbp), %rbx
	addq	$16, %rsp
	leave
	ret
L8:	.long 1
	.ascii "0"
L4:	/* test2 [m~8] [] */
	pushq	%rbp
	movq	%rsp, %rbp
	subq	$8, %rsp
L57:
	movq	%rdi, -8(%rbp)
	movq	-8(%rbp), %rax
	movq	-8(%rbp), %rcx
	movq	-32(%rcx), %rsi
	movq	-8(%rbp), %rcx
	movq	-40(%rcx), %rdx
	movq	-8(%rbp), %rcx
	movq	-16(%rcx), %rcx
	imul	$8, %rcx
	addq	%rcx, %rdx
	movq	(%rdx), %rcx
	movq	-8(%rbp), %rdx
	movq	-8(%rdx), %rdx
	imul	%rdx, %rcx
	addq	%rcx, %rsi
	movq	%rsi, -32(%rax)
	movq	-8(%rbp), %rcx
	movq	-8(%rbp), %rax
	movq	-48(%rax), %rax
	subq	$1, %rax
	movq	%rax, -48(%rcx)
	movq	-8(%rbp), %rax
	movq	-40(%rax), %rsi
	movq	-8(%rbp), %rax
	movq	-16(%rax), %rax
	imul	$8, %rax
	addq	%rax, %rsi
	movq	-8(%rbp), %rax
	movq	-32(%rax), %rcx
	xor	%rdx, %rdx
	movq	-8(%rbp), %rax
	movq	-32(%rax), %rax
	movq	-8(%rbp), %rdi
	movq	-48(%rdi), %rdi
	idiv	%rdi
	movq	-8(%rbp), %rdx
	movq	-48(%rdx), %rdx
	imul	%rdx, %rax
	subq	%rax, %rcx
	movq	%rcx, (%rsi)
	movq	-8(%rbp), %rsi
	xor	%rdx, %rdx
	movq	-8(%rbp), %rax
	movq	-32(%rax), %rax
	movq	-8(%rbp), %rcx
	movq	-48(%rcx), %rcx
	idiv	%rcx
	movq	%rax, -32(%rsi)
	movq	-8(%rbp), %rcx
	movq	-8(%rbp), %rax
	movq	-48(%rax), %rax
	subq	$1, %rax
	movq	%rax, -48(%rcx)
	movq	-8(%rbp), %rcx
	movq	-8(%rbp), %rax
	movq	-16(%rax), %rax
	subq	$1, %rax
	movq	%rax, -16(%rcx)
	movq	-8(%rbp), %rax
	movq	-16(%rax), %rax
	jmp	L56
L56:
	addq	$8, %rsp
	leave
	ret
L3:	/* test [m~8] [] */
	pushq	%rbp
	movq	%rsp, %rbp
	subq	$8, %rsp
L59:
	movq	%rdi, -8(%rbp)
	movq	-8(%rbp), %rax
	movq	$0, -32(%rax)
	movq	-8(%rbp), %rcx
	movq	-8(%rbp), %rax
	movq	-24(%rax), %rax
	imul	$2, %rax
	movq	%rax, -48(%rcx)
	movq	-8(%rbp), %rax
	movq	-48(%rax), %rax
	jmp	L58
L58:
	addq	$8, %rsp
	leave
	ret
