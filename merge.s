	.file "merge.tig"
	.text
	.global _Tiger_main
_Tiger_main:	/*  [] [] */
	pushq	%rbp
	movq	%rsp, %rbp
	subq	$24, %rsp
	movq	%rbx, %rax
	movq	%rax, -16(%rbp)
L76:
	movq	$-8, %rax
	addq	%rbp, %rax
	movq	%rax, %rbx
	call	_Tiger_getchar
	movq	%rax, (%rbx)
	movq	%rbp, %rdi
	call	L28
	movq	%rax, -24(%rbp)
	movq	$-8, %rax
	addq	%rbp, %rax
	movq	%rax, %rbx
	call	_Tiger_getchar
	movq	%rax, (%rbx)
	movq	%rbp, %rdi
	call	L28
	movq	%rax, %rcx
	movq	%rbp, %rbx
	movq	%rbp, %rdi
	movq	-24(%rbp), %rax
	movq	%rax, %rsi
	movq	%rcx, %rdx
	call	L29
	movq	%rbx, %rdi
	movq	%rax, %rsi
	call	L31
	jmp	L75
L75:
	movq	-16(%rbp), %rcx
	movq	%rcx, %rbx
	addq	$24, %rsp
	leave
	ret
L31:	/* printlist [m~8, t112] [] */
	pushq	%rbp
	movq	%rsp, %rbp
	subq	$16, %rsp
	movq	%rbx, %rax
	movq	%rax, -16(%rbp)
L78:
	movq	%rsi, %rbx
	movq	%rdi, -8(%rbp)
	movq	$1, %rax
	cmp	$0, %rbx
	je	L73
L74:
	movq	$0, %rax
L73:
	cmp	$0, %rax
	jne	L70
L71:
	movq	-8(%rbp), %rcx
	movq	0(%rbx), %rax
	movq	%rcx, %rdi
	movq	%rax, %rsi
	call	L30
	movq	$L69, %rax
	movq	%rax, %rdi
	call	print
	movq	-8(%rbp), %rcx
	movq	8(%rbx), %rax
	movq	%rcx, %rdi
	movq	%rax, %rsi
	call	L31
L72:
	jmp	L77
L70:
	movq	$L68, %rax
	movq	%rax, %rdi
	call	print
	jmp	L72
L77:
	movq	-16(%rbp), %rcx
	movq	%rcx, %rbx
	addq	$16, %rsp
	leave
	ret
L69:	.long 1
	.ascii " "
L68:	.long 1
	.ascii "\n"
L30:	/* printint [m~8, t111] [] */
	pushq	%rbp
	movq	%rsp, %rbp
	subq	$16, %rsp
	movq	%rbx, %rax
	movq	%rax, -16(%rbp)
L80:
	movq	%rsi, %rbx
	movq	%rdi, -8(%rbp)
	movq	$1, %rax
	cmp	$0, %rbx
	jl	L66
L67:
	movq	$0, %rax
L66:
	cmp	$0, %rax
	jne	L63
L64:
	movq	$1, %rax
	cmp	$0, %rbx
	jg	L61
L62:
	movq	$0, %rax
L61:
	cmp	$0, %rax
	jne	L58
L59:
	movq	$L57, %rax
	movq	%rax, %rdi
	call	print
L60:
L65:
	jmp	L79
L63:
	movq	$L56, %rax
	movq	%rax, %rdi
	call	print
	movq	$0, %rax
	subq	%rbx, %rax
	movq	%rbp, %rdi
	movq	%rax, %rsi
	call	L50
	jmp	L65
L58:
	movq	%rbp, %rdi
	movq	%rbx, %rsi
	call	L50
	jmp	L60
L79:
	movq	-16(%rbp), %rcx
	movq	%rcx, %rbx
	addq	$16, %rsp
	leave
	ret
L57:	.long 1
	.ascii "0"
L56:	.long 1
	.ascii "-"
L50:	/* printint::f [m~8, t126] [] */
	pushq	%rbp
	movq	%rsp, %rbp
	subq	$16, %rsp
	movq	%rbx, %rax
	movq	%rax, -16(%rbp)
L82:
	movq	%rsi, %rbx
	movq	%rdi, -8(%rbp)
	movq	$1, %rax
	cmp	$0, %rbx
	jg	L54
L55:
	movq	$0, %rax
L54:
	cmp	$0, %rax
	je	L53
L52:
	movq	-8(%rbp), %rsi
	xor	%rdx, %rdx
	movq	%rbx, %rax
	movq	$10, %rcx
	idiv	%rcx
	movq	%rsi, %rdi
	movq	%rax, %rsi
	call	L50
	xor	%rdx, %rdx
	movq	%rbx, %rax
	movq	$10, %rcx
	idiv	%rcx
	imul	$10, %rax
	subq	%rax, %rbx
	movq	$L51, %rax
	movq	%rax, %rdi
	call	ord
	movq	%rax, %rcx
	movq	%rbx, %rax
	addq	%rcx, %rax
	movq	%rax, %rdi
	call	chr
	movq	%rax, %rdi
	call	print
L53:
	movq	$0, %rax
	jmp	L81
L81:
	movq	-16(%rbp), %rcx
	movq	%rcx, %rbx
	addq	$16, %rsp
	leave
	ret
L51:	.long 1
	.ascii "0"
L29:	/* merge [m~8, t109, t110] [] */
	pushq	%rbp
	movq	%rsp, %rbp
	subq	$56, %rsp
	movq	%rbx, %rax
	movq	%rax, -16(%rbp)
L84:
	movq	%rdx, %rbx
	movq	%rsi, %rax
	movq	%rax, -24(%rbp)
	movq	%rdi, -8(%rbp)
	movq	$1, %rcx
	movq	-24(%rbp), %rax
	cmp	$0, %rax
	je	L48
L49:
	movq	$0, %rcx
L48:
	cmp	$0, %rcx
	jne	L45
L46:
	movq	$1, %rax
	cmp	$0, %rbx
	je	L43
L44:
	movq	$0, %rax
L43:
	cmp	$0, %rax
	jne	L40
L41:
	movq	$1, %rdx
	movq	0(%rbx), %rcx
	movq	-24(%rbp), %rax
	movq	0(%rax), %rax
	cmp	%rcx, %rax
	jl	L38
L39:
	movq	$0, %rdx
L38:
	cmp	$0, %rdx
	jne	L35
L36:
	movq	$16, %rax
	movq	%rax, %rdi
	call	malloc
	movq	%rax, -32(%rbp)
	movq	0(%rbx), %rcx
	movq	-32(%rbp), %rax
	movq	%rcx, 0(%rax)
	movq	-32(%rbp), %rax
	movq	%rax, -40(%rbp)
	movq	-40(%rbp), %rax
	addq	$8, %rax
	movq	%rax, -40(%rbp)
	movq	-8(%rbp), %rax
	movq	8(%rbx), %rcx
	movq	%rax, %rdi
	movq	-24(%rbp), %rax
	movq	%rax, %rsi
	movq	%rcx, %rdx
	call	L29
	movq	%rax, %rcx
	movq	-40(%rbp), %rax
	movq	%rcx, (%rax)
	movq	-32(%rbp), %rax
L37:
L42:
L47:
	jmp	L83
L45:
	movq	%rbx, %rax
	jmp	L47
L40:
	movq	-24(%rbp), %rax
	jmp	L42
L35:
	movq	$16, %rax
	movq	%rax, %rdi
	call	malloc
	movq	%rax, -48(%rbp)
	movq	-24(%rbp), %rax
	movq	0(%rax), %rcx
	movq	-48(%rbp), %rax
	movq	%rcx, 0(%rax)
	movq	-48(%rbp), %rax
	movq	%rax, -56(%rbp)
	movq	-56(%rbp), %rax
	addq	$8, %rax
	movq	%rax, -56(%rbp)
	movq	-8(%rbp), %rcx
	movq	-24(%rbp), %rax
	movq	8(%rax), %rax
	movq	%rcx, %rdi
	movq	%rax, %rsi
	movq	%rbx, %rdx
	call	L29
	movq	%rax, %rcx
	movq	-56(%rbp), %rax
	movq	%rcx, (%rax)
	movq	-48(%rbp), %rax
	jmp	L37
L83:
	movq	-16(%rbp), %rcx
	movq	%rcx, %rbx
	addq	$56, %rsp
	leave
	ret
L28:	/* readlist [m~8] [] */
	pushq	%rbp
	movq	%rsp, %rbp
	subq	$32, %rsp
	movq	%rbx, %rax
	movq	%rax, -16(%rbp)
L86:
	movq	%rdi, -8(%rbp)
	movq	$8, %rax
	movq	%rax, %rdi
	call	malloc
	movq	$0, 0(%rax)
	movq	%rax, %rbx
	movq	-8(%rbp), %rax
	movq	%rax, %rdi
	movq	%rbx, %rsi
	call	L0
	movq	%rax, -24(%rbp)
	movq	0(%rbx), %rax
	cmp	$0, %rax
	jne	L32
L33:
	movq	$0, %rax
L34:
	jmp	L85
L32:
	movq	$16, %rax
	movq	%rax, %rdi
	call	malloc
	movq	%rax, %rbx
	movq	-24(%rbp), %rax
	movq	%rax, 0(%rbx)
	movq	%rbx, %rax
	movq	%rax, -32(%rbp)
	movq	-32(%rbp), %rax
	addq	$8, %rax
	movq	%rax, -32(%rbp)
	movq	-8(%rbp), %rax
	movq	%rax, %rdi
	call	L28
	movq	%rax, %rcx
	movq	-32(%rbp), %rax
	movq	%rcx, (%rax)
	movq	%rbx, %rax
	jmp	L34
L85:
	movq	-16(%rbp), %rcx
	movq	%rcx, %rbx
	addq	$32, %rsp
	leave
	ret
L0:	/* readint [m~8, t100] [] */
	pushq	%rbp
	movq	%rsp, %rbp
	subq	$40, %rsp
	movq	%rbx, %rax
	movq	%rax, -16(%rbp)
L88:
	movq	%rsi, %rax
	movq	%rax, -24(%rbp)
	movq	%rdi, -8(%rbp)
	movq	$0, %rbx
	movq	%rbp, %rdi
	call	L2
	movq	-24(%rbp), %rax
	movq	%rax, -32(%rbp)
	movq	-32(%rbp), %rax
	addq	$0, %rax
	movq	%rax, -32(%rbp)
	movq	-8(%rbp), %rax
	movq	-8(%rax), %rax
	movq	%rbp, %rdi
	movq	%rax, %rsi
	call	L1
	movq	%rax, %rcx
	movq	-32(%rbp), %rax
	movq	%rcx, (%rax)
L26:
	movq	-8(%rbp), %rax
	movq	-8(%rax), %rax
	movq	%rbp, %rdi
	movq	%rax, %rsi
	call	L1
	cmp	$0, %rax
	je	L24
L27:
	movq	%rbx, %rax
	imul	$10, %rax
	movq	%rax, %rbx
	movq	-8(%rbp), %rax
	movq	-8(%rax), %rax
	movq	%rax, %rdi
	call	ord
	movq	%rax, %rcx
	movq	%rbx, %rax
	addq	%rcx, %rax
	movq	%rax, %rbx
	movq	$L25, %rax
	movq	%rax, %rdi
	call	ord
	movq	%rax, %rcx
	movq	%rbx, %rax
	subq	%rcx, %rax
	movq	%rax, %rbx
	movq	$-8, %rax
	movq	%rax, %rcx
	movq	-8(%rbp), %rax
	addq	%rax, %rcx
	movq	%rcx, %rax
	movq	%rax, -40(%rbp)
	call	_Tiger_getchar
	movq	%rax, %rcx
	movq	-40(%rbp), %rax
	movq	%rcx, (%rax)
	jmp	L26
L24:
	movq	%rbx, %rax
	jmp	L87
L87:
	movq	-16(%rbp), %rcx
	movq	%rcx, %rbx
	addq	$40, %rsp
	leave
	ret
L25:	.long 1
	.ascii "0"
L2:	/* readint::skipto [m~8] [] */
	pushq	%rbp
	movq	%rsp, %rbp
	subq	$16, %rsp
	movq	%rbx, %rax
	movq	%rax, -16(%rbp)
L90:
	movq	%rdi, -8(%rbp)
L22:
	movq	$1, %rbx
	movq	-8(%rbp), %rax
	movq	-8(%rax), %rax
	movq	-8(%rax), %rcx
	movq	$L12, %rax
	movq	%rcx, %rdi
	movq	%rax, %rsi
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
	movq	-8(%rax), %rcx
	movq	$L13, %rax
	movq	%rcx, %rdi
	movq	%rax, %rsi
	call	_Tiger_strcmp
	cmp	$0, %rax
	je	L19
L20:
	movq	$0, %rbx
L19:
	movq	%rbx, %rax
L16:
	cmp	$0, %rax
	je	L21
L23:
	movq	$-8, %rax
	movq	%rax, %rcx
	movq	-8(%rbp), %rax
	movq	-8(%rax), %rax
	addq	%rax, %rcx
	movq	%rcx, %rbx
	call	_Tiger_getchar
	movq	%rax, (%rbx)
	jmp	L22
L14:
	movq	$1, %rax
	jmp	L16
L21:
	movq	$0, %rax
	jmp	L89
L89:
	movq	-16(%rbp), %rcx
	movq	%rcx, %rbx
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
	subq	$32, %rsp
	movq	%rbx, %rax
	movq	%rax, -16(%rbp)
L92:
	movq	%rsi, %rax
	movq	%rdi, -8(%rbp)
	movq	$1, %rbx
	movq	-8(%rbp), %rax
	movq	-8(%rax), %rax
	movq	-8(%rax), %rax
	movq	%rax, %rdi
	call	ord
	movq	%rax, -24(%rbp)
	movq	$L3, %rax
	movq	%rax, %rdi
	call	ord
	movq	%rax, %rcx
	movq	-24(%rbp), %rax
	cmp	%rcx, %rax
	jge	L8
L9:
	movq	$0, %rbx
L8:
	cmp	$0, %rbx
	jne	L5
L6:
	movq	$0, %rax
L7:
	jmp	L91
L5:
	movq	$1, %rbx
	movq	-8(%rbp), %rax
	movq	-8(%rax), %rax
	movq	-8(%rax), %rax
	movq	%rax, %rdi
	call	ord
	movq	%rax, -32(%rbp)
	movq	$L4, %rax
	movq	%rax, %rdi
	call	ord
	movq	%rax, %rcx
	movq	-32(%rbp), %rax
	cmp	%rcx, %rax
	jle	L10
L11:
	movq	$0, %rbx
L10:
	movq	%rbx, %rax
	jmp	L7
L91:
	movq	-16(%rbp), %rcx
	movq	%rcx, %rbx
	addq	$32, %rsp
	leave
	ret
L4:	.long 1
	.ascii "9"
L3:	.long 1
	.ascii "0"
