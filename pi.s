	.file "pi.tig"
	.text
	.global _Tiger_main
_Tiger_main:	/*  [] [] */
	pushq	%rbp
	movq	%rsp, %rbp
	subq	$80, %rsp
L49:
	movq	$10000, -8(%rbp)
	movq	$0, -16(%rbp)
	movq	$2800, -24(%rbp)
	movq	$0, -32(%rbp)
	movq	$0, %rax
	movq	%rax, -56(%rbp)
	movq	$-40, %rax
	addq	%rbp, %rax
	movq	%rax, -64(%rbp)
	movq	$2801, %rax
	movq	%rax, -72(%rbp)
	movq	$0, %rax
	movq	%rax, -80(%rbp)
	movq	-72(%rbp), %rax
	imul	$8, %rax
	movq	%rax, %rdi
	call	malloc
	movq	%rax, %rsi
	movq	$0, %rdx
L0:
	movq	-72(%rbp), %rax
	cmp	%rax, %rdx
	jge	L2
L1:
	movq	%rsi, %rcx
	movq	%rdx, %rax
	imul	$8, %rax
	addq	%rax, %rcx
	movq	-80(%rbp), %rax
	movq	%rax, (%rcx)
	addq	$1, %rdx
	jmp	L0
L2:
	movq	-64(%rbp), %rax
	movq	%rsi, (%rax)
	movq	$0, -48(%rbp)
L38:
	movq	$1, %rdx
	movq	-16(%rbp), %rax
	movq	%rax, %rcx
	movq	-24(%rbp), %rax
	subq	%rax, %rcx
	cmp	$0, %rcx
	jne	L40
L41:
	movq	$0, %rdx
L40:
	cmp	$0, %rdx
	je	L37
L39:
	movq	-40(%rbp), %rax
	movq	%rax, %rsi
	movq	-16(%rbp), %rax
	imul	$8, %rax
	addq	%rax, %rsi
	movq	$0, %rdx
	movq	-8(%rbp), %rax
	movq	$5, %rcx
	idiv	%rcx
	movq	%rax, (%rsi)
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
	movq	%rax, %rcx
	movq	-16(%rbp), %rax
	imul	%rax, %rcx
	movq	%rcx, -32(%rbp)
	jmp	L44
L43:
	movq	-24(%rbp), %rax
	subq	$14, %rax
	movq	%rax, -24(%rbp)
	movq	-56(%rbp), %rax
	movq	%rax, %rsi
	movq	$0, %rdx
	movq	-32(%rbp), %rax
	movq	-8(%rbp), %rcx
	idiv	%rcx
	addq	%rax, %rsi
	movq	%rbp, %rdi
	call	L6
	movq	-32(%rbp), %rax
	movq	%rax, %rsi
	movq	$0, %rdx
	movq	-32(%rbp), %rax
	movq	-8(%rbp), %rcx
	idiv	%rcx
	movq	%rax, %rcx
	movq	-8(%rbp), %rax
	imul	%rax, %rcx
	subq	%rcx, %rsi
	movq	%rsi, %rax
	movq	%rax, -56(%rbp)
	jmp	L46
L42:
	movq	$0, %rax
	jmp	L48
L48:
	addq	$80, %rsp
	leave
	ret
L6:	/* printf [m~8, t106] [] */
	pushq	%rbp
	movq	%rsp, %rbp
	subq	$16, %rsp
L51:
	movq	%rsi, %rax
	movq	%rax, -16(%rbp)
	movq	%rdi, -8(%rbp)
	movq	$1, %rcx
	movq	-16(%rbp), %rax
	cmp	$1000, %rax
	jl	L27
L28:
	movq	$0, %rcx
L27:
	cmp	$0, %rcx
	je	L26
L25:
	movq	-8(%rbp), %rcx
	movq	$0, %rax
	movq	%rcx, %rdi
	movq	%rax, %rsi
	call	L5
L26:
	movq	$1, %rcx
	movq	-16(%rbp), %rax
	cmp	$100, %rax
	jl	L31
L32:
	movq	$0, %rcx
L31:
	cmp	$0, %rcx
	je	L30
L29:
	movq	-8(%rbp), %rcx
	movq	$0, %rax
	movq	%rcx, %rdi
	movq	%rax, %rsi
	call	L5
L30:
	movq	$1, %rcx
	movq	-16(%rbp), %rax
	cmp	$10, %rax
	jl	L35
L36:
	movq	$0, %rcx
L35:
	cmp	$0, %rcx
	je	L34
L33:
	movq	-8(%rbp), %rcx
	movq	$0, %rax
	movq	%rcx, %rdi
	movq	%rax, %rsi
	call	L5
L34:
	movq	-8(%rbp), %rax
	movq	%rax, %rdi
	movq	-16(%rbp), %rax
	movq	%rax, %rsi
	call	L5
	jmp	L50
L50:
	addq	$16, %rsp
	leave
	ret
L5:	/* printi [m~8, t105] [] */
	pushq	%rbp
	movq	%rsp, %rbp
	subq	$16, %rsp
L53:
	movq	%rsi, %rax
	movq	%rax, -16(%rbp)
	movq	%rdi, -8(%rbp)
	movq	$1, %rcx
	movq	-16(%rbp), %rax
	cmp	$0, %rax
	jl	L23
L24:
	movq	$0, %rcx
L23:
	cmp	$0, %rcx
	jne	L20
L21:
	movq	$1, %rcx
	movq	-16(%rbp), %rax
	cmp	$0, %rax
	jg	L18
L19:
	movq	$0, %rcx
L18:
	cmp	$0, %rcx
	jne	L15
L16:
	movq	$L14, %rax
	movq	%rax, %rdi
	call	print
L17:
L22:
	jmp	L52
L20:
	movq	$L13, %rax
	movq	%rax, %rdi
	call	print
	movq	$0, %rax
	movq	%rax, %rcx
	movq	-16(%rbp), %rax
	subq	%rax, %rcx
	movq	%rbp, %rdi
	movq	%rcx, %rsi
	call	L7
	jmp	L22
L15:
	movq	%rbp, %rdi
	movq	-16(%rbp), %rax
	movq	%rax, %rsi
	call	L7
	jmp	L17
L52:
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
	subq	$24, %rsp
L55:
	movq	%rsi, %rax
	movq	%rax, -16(%rbp)
	movq	%rdi, -8(%rbp)
	movq	$1, %rcx
	movq	-16(%rbp), %rax
	cmp	$0, %rax
	jg	L11
L12:
	movq	$0, %rcx
L11:
	cmp	$0, %rcx
	je	L10
L9:
	movq	-8(%rbp), %rsi
	movq	$0, %rdx
	movq	-16(%rbp), %rax
	movq	$10, %rcx
	idiv	%rcx
	movq	%rsi, %rdi
	movq	%rax, %rsi
	call	L7
	movq	-16(%rbp), %rax
	movq	%rax, %rsi
	movq	$0, %rdx
	movq	-16(%rbp), %rax
	movq	$10, %rcx
	idiv	%rcx
	imul	$10, %rax
	subq	%rax, %rsi
	movq	%rsi, %rax
	movq	%rax, -24(%rbp)
	movq	$L8, %rax
	movq	%rax, %rdi
	call	ord
	movq	%rax, %rcx
	movq	-24(%rbp), %rax
	addq	%rcx, %rax
	movq	%rax, %rdi
	call	chr
	movq	%rax, %rdi
	call	print
L10:
	movq	$0, %rax
	jmp	L54
L54:
	addq	$24, %rsp
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
	movq	-8(%rbp), %rcx
	movq	-8(%rbp), %rax
	movq	-32(%rax), %rax
	movq	-8(%rbp), %rdx
	movq	-40(%rdx), %rdx
	movq	%rdx, %rsi
	movq	-8(%rbp), %rdx
	movq	-16(%rdx), %rdx
	imul	$8, %rdx
	addq	%rdx, %rsi
	movq	(%rsi), %rdx
	movq	%rdx, %rsi
	movq	-8(%rbp), %rdx
	movq	-8(%rdx), %rdx
	imul	%rdx, %rsi
	addq	%rsi, %rax
	movq	%rax, -32(%rcx)
	movq	-8(%rbp), %rcx
	movq	-8(%rbp), %rax
	movq	-48(%rax), %rax
	subq	$1, %rax
	movq	%rax, -48(%rcx)
	movq	-8(%rbp), %rax
	movq	-40(%rax), %rax
	movq	%rax, %rdi
	movq	-8(%rbp), %rax
	movq	-16(%rax), %rax
	imul	$8, %rax
	addq	%rax, %rdi
	movq	-8(%rbp), %rax
	movq	-32(%rax), %rax
	movq	%rax, %rsi
	movq	$0, %rdx
	movq	-8(%rbp), %rax
	movq	-32(%rax), %rax
	movq	-8(%rbp), %rcx
	movq	-48(%rcx), %rcx
	idiv	%rcx
	movq	%rax, %rcx
	movq	-8(%rbp), %rax
	movq	-48(%rax), %rax
	imul	%rax, %rcx
	subq	%rcx, %rsi
	movq	%rsi, (%rdi)
	movq	-8(%rbp), %rsi
	movq	$0, %rdx
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
