	.file "merge.tig"
	.text
	.global _Tiger_main
_Tiger_main:	/*  [] [] */
	pushq	%rbp
	movq	%rsp, %rbp
	subq	$48, %rsp
L78:
	movq	$-8, %rax
	movq	%rax, -16(%rbp)
	movq	-16(%rbp), %rax
	addq	%rbp, %rax
	movq	%rax, -24(%rbp)
	call	_Tiger_getchar
	movq	-24(%rbp), %rcx
	movq	%rax, (%rcx)
	movq	%rbp, %rdi
	call	L28
	movq	%rax, -32(%rbp)
	movq	$-8, %rax
	movq	%rax, -40(%rbp)
	movq	-40(%rbp), %rax
	addq	%rbp, %rax
	movq	%rax, -48(%rbp)
	call	_Tiger_getchar
	movq	-48(%rbp), %rcx
	movq	%rax, (%rcx)
	movq	%rbp, %rdi
	call	L28
	movq	%rbp, %rdi
	movq	-32(%rbp), %rsi
	movq	%rax, %rdx
	call	L29
	movq	%rbp, %rdi
	movq	%rax, %rsi
	call	L31
	jmp	L77
L77:
	addq	$48, %rsp
	leave
	ret
L31:	/* printlist [m~8, t112] [] */
	pushq	%rbp
	movq	%rsp, %rbp
	subq	$16, %rsp
	movq	%rbx, -16(%rbp)
L80:
	movq	%rsi, %rbx
	movq	%rdi, -8(%rbp)
	movq	$1, %rax
	cmp	$0, %rbx
	je	L75
L76:
	movq	$0, %rax
L75:
	cmp	$0, %rax
	jne	L72
L73:
	movq	-8(%rbp), %rdi
	movq	0(%rbx), %rsi
	call	L30
	movq	$L71, %rdi
	call	print
	movq	-8(%rbp), %rdi
	movq	8(%rbx), %rsi
	call	L31
L74:
	jmp	L79
L72:
	movq	$L70, %rdi
	call	print
	jmp	L74
L79:
	movq	-16(%rbp), %rbx
	addq	$16, %rsp
	leave
	ret
L71:	.long 1
	.ascii " "
L70:	.long 1
	.ascii "\n"
L30:	/* printint [m~8, t111] [] */
	pushq	%rbp
	movq	%rsp, %rbp
	subq	$16, %rsp
	movq	%rbx, -16(%rbp)
L82:
	movq	%rsi, %rbx
	movq	%rdi, -8(%rbp)
	movq	$1, %rax
	cmp	$0, %rbx
	jl	L68
L69:
	movq	$0, %rax
L68:
	cmp	$0, %rax
	jne	L65
L66:
	movq	$1, %rax
	cmp	$0, %rbx
	jg	L63
L64:
	movq	$0, %rax
L63:
	cmp	$0, %rax
	jne	L60
L61:
	movq	$L59, %rdi
	call	print
L62:
L67:
	jmp	L81
L65:
	movq	$L58, %rdi
	call	print
	movq	$0, %rsi
	subq	%rbx, %rsi
	movq	%rbp, %rdi
	call	L52
	jmp	L67
L60:
	movq	%rbp, %rdi
	movq	%rbx, %rsi
	call	L52
	jmp	L62
L81:
	movq	-16(%rbp), %rbx
	addq	$16, %rsp
	leave
	ret
L59:	.long 1
	.ascii "0"
L58:	.long 1
	.ascii "-"
L52:	/* printint::f [m~8, t126] [] */
	pushq	%rbp
	movq	%rsp, %rbp
	subq	$16, %rsp
	movq	%rbx, -16(%rbp)
L84:
	movq	%rsi, %rbx
	movq	%rdi, -8(%rbp)
	movq	$1, %rax
	cmp	$0, %rbx
	jg	L56
L57:
	movq	$0, %rax
L56:
	cmp	$0, %rax
	je	L55
L54:
	movq	-8(%rbp), %rdi
	xor	%rdx, %rdx
	movq	%rbx, %rax
	movq	$10, %rcx
	idiv	%rcx
	movq	%rax, %rsi
	call	L52
	xor	%rdx, %rdx
	movq	%rbx, %rax
	movq	$10, %rcx
	idiv	%rcx
	imul	$10, %rax
	subq	%rax, %rbx
	movq	$L53, %rdi
	call	ord
	addq	%rax, %rbx
	movq	%rbx, %rdi
	call	chr
	movq	%rax, %rdi
	call	print
L55:
	movq	$0, %rax
	jmp	L83
L83:
	movq	-16(%rbp), %rbx
	addq	$16, %rsp
	leave
	ret
L53:	.long 1
	.ascii "0"
L29:	/* merge [m~8, t109, t110] [] */
	pushq	%rbp
	movq	%rsp, %rbp
	subq	$56, %rsp
	movq	%rbx, -16(%rbp)
	movq	%r12, -24(%rbp)
L86:
	movq	%rdx, %r12
	movq	%rsi, %rbx
	movq	%rdi, -8(%rbp)
	movq	$1, %rax
	cmp	$0, %rbx
	je	L50
L51:
	movq	$0, %rax
L50:
	cmp	$0, %rax
	jne	L47
L48:
	movq	$1, %rax
	cmp	$0, %r12
	je	L45
L46:
	movq	$0, %rax
L45:
	cmp	$0, %rax
	jne	L42
L43:
	movq	$1, %rdx
	movq	0(%r12), %rcx
	movq	0(%rbx), %rax
	cmp	%rcx, %rax
	jl	L40
L41:
	movq	$0, %rdx
L40:
	cmp	$0, %rdx
	jne	L37
L38:
	movq	$16, %rdi
	call	malloc
	movq	%rax, -32(%rbp)
	movq	0(%r12), %rcx
	movq	-32(%rbp), %rax
	movq	%rcx, 0(%rax)
	movq	-32(%rbp), %rax
	movq	%rax, -40(%rbp)
	movq	-40(%rbp), %rax
	addq	$8, %rax
	movq	%rax, -40(%rbp)
	movq	-8(%rbp), %rdi
	movq	8(%r12), %rdx
	movq	%rbx, %rsi
	call	L29
	movq	-40(%rbp), %rcx
	movq	%rax, (%rcx)
	movq	-32(%rbp), %rax
L39:
L44:
L49:
	jmp	L85
L47:
	movq	%r12, %rax
	jmp	L49
L42:
	movq	%rbx, %rax
	jmp	L44
L37:
	movq	$16, %rdi
	call	malloc
	movq	%rax, -48(%rbp)
	movq	0(%rbx), %rcx
	movq	-48(%rbp), %rax
	movq	%rcx, 0(%rax)
	movq	-48(%rbp), %rax
	movq	%rax, -56(%rbp)
	movq	-56(%rbp), %rax
	addq	$8, %rax
	movq	%rax, -56(%rbp)
	movq	-8(%rbp), %rdi
	movq	8(%rbx), %rsi
	movq	%r12, %rdx
	call	L29
	movq	-56(%rbp), %rcx
	movq	%rax, (%rcx)
	movq	-48(%rbp), %rax
	jmp	L39
L85:
	movq	-24(%rbp), %r12
	movq	-16(%rbp), %rbx
	addq	$56, %rsp
	leave
	ret
L28:	/* readlist [m~8] [] */
	pushq	%rbp
	movq	%rsp, %rbp
	subq	$24, %rsp
	movq	%rbx, -16(%rbp)
	movq	%r12, -24(%rbp)
L88:
	movq	%rdi, -8(%rbp)
	movq	$8, %rdi
	call	malloc
	movq	$0, 0(%rax)
	movq	%rax, %rbx
	movq	-8(%rbp), %rdi
	movq	%rbx, %rsi
	call	L0
	movq	%rax, %r12
	movq	0(%rbx), %rax
	cmp	$0, %rax
	jne	L34
L35:
	movq	$0, %rax
L36:
	jmp	L87
L34:
	movq	$16, %rdi
	call	malloc
	movq	%rax, %rbx
	movq	%r12, 0(%rbx)
	movq	%rbx, %r12
	addq	$8, %r12
	movq	-8(%rbp), %rdi
	call	L28
	movq	%rax, (%r12)
	movq	%rbx, %rax
	jmp	L36
L87:
	movq	-24(%rbp), %r12
	movq	-16(%rbp), %rbx
	addq	$24, %rsp
	leave
	ret
L0:	/* readint [m~8, t100] [] */
	pushq	%rbp
	movq	%rsp, %rbp
	subq	$24, %rsp
	movq	%rbx, -16(%rbp)
	movq	%r12, -24(%rbp)
L90:
	movq	%rsi, %r12
	movq	%rdi, -8(%rbp)
	movq	$0, %rbx
	movq	%rbp, %rdi
	call	L2
	addq	$0, %r12
	movq	-8(%rbp), %rax
	movq	-8(%rax), %rsi
	movq	%rbp, %rdi
	call	L1
	movq	%rax, (%r12)
L26:
	movq	-8(%rbp), %rax
	movq	-8(%rax), %rsi
	movq	%rbp, %rdi
	call	L1
	cmp	$0, %rax
	je	L24
L27:
	imul	$10, %rbx
	movq	-8(%rbp), %rax
	movq	-8(%rax), %rdi
	call	ord
	addq	%rax, %rbx
	movq	$L25, %rdi
	call	ord
	subq	%rax, %rbx
	movq	$-8, %r12
	movq	-8(%rbp), %rax
	addq	%rax, %r12
	call	_Tiger_getchar
	movq	%rax, (%r12)
	jmp	L26
L24:
	movq	%rbx, %rax
	jmp	L89
L89:
	movq	-24(%rbp), %r12
	movq	-16(%rbp), %rbx
	addq	$24, %rsp
	leave
	ret
L25:	.long 1
	.ascii "0"
L2:	/* readint::skipto [m~8] [] */
	pushq	%rbp
	movq	%rsp, %rbp
	subq	$16, %rsp
	movq	%rbx, -16(%rbp)
L92:
	movq	%rdi, -8(%rbp)
L22:
	movq	$1, %rbx
	movq	-8(%rbp), %rax
	movq	-8(%rax), %rax
	movq	-8(%rax), %rdi
	movq	$L12, %rsi
	call	_Tiger_strcmp
	cmp	$0, %rax
	je	L17
L18:
	movq	$0, %rbx
L17:
	cmp	$0, %rbx
	jne	L14
L15:
	movq	$1, %rbx
	movq	-8(%rbp), %rax
	movq	-8(%rax), %rax
	movq	-8(%rax), %rdi
	movq	$L13, %rsi
	call	_Tiger_strcmp
	cmp	$0, %rax
	je	L19
L20:
	movq	$0, %rbx
L19:
L16:
	cmp	$0, %rbx
	je	L21
L23:
	movq	$-8, %rbx
	movq	-8(%rbp), %rax
	movq	-8(%rax), %rax
	addq	%rax, %rbx
	call	_Tiger_getchar
	movq	%rax, (%rbx)
	jmp	L22
L14:
	movq	$1, %rbx
	jmp	L16
L21:
	movq	$0, %rax
	jmp	L91
L91:
	movq	-16(%rbp), %rbx
	addq	$16, %rsp
	leave
	ret
L13:	.long 1
	.ascii "\n"
L12:	.long 1
	.ascii " "
L1:	/* readint::isdigit [m~8, t102] [] */
	pushq	%rbp
	movq	%rsp, %rbp
	subq	$24, %rsp
	movq	%rbx, -16(%rbp)
	movq	%r12, -24(%rbp)
L94:
	movq	%rdi, -8(%rbp)
	movq	$1, %rbx
	movq	-8(%rbp), %rax
	movq	-8(%rax), %rax
	movq	-8(%rax), %rdi
	call	ord
	movq	%rax, %r12
	movq	$L3, %rdi
	call	ord
	cmp	%rax, %r12
	jge	L8
L9:
	movq	$0, %rbx
L8:
	cmp	$0, %rbx
	jne	L5
L6:
	movq	$0, %rax
L7:
	jmp	L93
L5:
	movq	$1, %rbx
	movq	-8(%rbp), %rax
	movq	-8(%rax), %rax
	movq	-8(%rax), %rdi
	call	ord
	movq	%rax, %r12
	movq	$L4, %rdi
	call	ord
	cmp	%rax, %r12
	jle	L10
L11:
	movq	$0, %rbx
L10:
	movq	%rbx, %rax
	jmp	L7
L93:
	movq	-24(%rbp), %r12
	movq	-16(%rbp), %rbx
	addq	$24, %rsp
	leave
	ret
L4:	.long 1
	.ascii "9"
L3:	.long 1
	.ascii "0"
