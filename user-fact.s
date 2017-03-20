	.file "user-fact.tig"
	.text
	.global _Tiger_main
_Tiger_main:	/*  [] [] */
	pushq	%rbp
	movq	%rsp, %rbp
	subq	$24, %rsp
	movq	%rbx, %rax
	movq	%rax, -16(%rbp)
L57:
	movq	$L0, %rax
	movq	%rax, %rdi
	call	print
	movq	$-8, %rax
	addq	%rbp, %rax
	movq	%rax, %rbx
	call	_Tiger_getchar
	movq	%rax, (%rbx)
	movq	$0, %rax
	movq	%rax, -24(%rbp)
	movq	%rbp, %rdi
	call	L1
	movq	%rax, -24(%rbp)
	movq	%rbp, %rdi
	movq	-24(%rbp), %rax
	movq	%rax, %rsi
	call	L2
	movq	$L54, %rax
	movq	%rax, %rdi
	call	print
	movq	%rbp, %rbx
	movq	%rbp, %rdi
	movq	-24(%rbp), %rax
	movq	%rax, %rsi
	call	L3
	movq	%rbx, %rdi
	movq	%rax, %rsi
	call	L2
	movq	$L55, %rax
	movq	%rax, %rdi
	call	print
	jmp	L56
L56:
	movq	-16(%rbp), %rcx
	movq	%rcx, %rbx
	addq	$24, %rsp
	leave
	ret
L55:	.long 1
	.ascii "\n"
L54:	.long 4
	.ascii "! = "
L3:	/* fact [m~8, t103] [] */
	pushq	%rbp
	movq	%rsp, %rbp
	subq	$16, %rsp
L59:
	movq	%rsi, %rdx
	movq	%rdi, -8(%rbp)
	movq	$1, %rax
	cmp	$1, %rdx
	jle	L52
L53:
	movq	$0, %rax
L52:
	cmp	$0, %rax
	jne	L49
L50:
	movq	%rdx, %rax
	movq	%rax, -16(%rbp)
	movq	-8(%rbp), %rcx
	movq	%rdx, %rax
	subq	$1, %rax
	movq	%rcx, %rdi
	movq	%rax, %rsi
	call	L3
	movq	%rax, %rcx
	movq	-16(%rbp), %rax
	imul	%rcx, %rax
L51:
	jmp	L58
L49:
	movq	$1, %rax
	jmp	L51
L58:
	addq	$16, %rsp
	leave
	ret
L2:	/* printint [m~8, t102] [] */
	pushq	%rbp
	movq	%rsp, %rbp
	subq	$16, %rsp
	movq	%rbx, %rax
	movq	%rax, -16(%rbp)
L61:
	movq	%rsi, %rbx
	movq	%rdi, -8(%rbp)
	movq	$1, %rax
	cmp	$0, %rbx
	jl	L47
L48:
	movq	$0, %rax
L47:
	cmp	$0, %rax
	jne	L44
L45:
	movq	$1, %rax
	cmp	$0, %rbx
	jg	L42
L43:
	movq	$0, %rax
L42:
	cmp	$0, %rax
	jne	L39
L40:
	movq	$L38, %rax
	movq	%rax, %rdi
	call	print
L41:
L46:
	jmp	L60
L44:
	movq	$L37, %rax
	movq	%rax, %rdi
	call	print
	movq	$0, %rax
	subq	%rbx, %rax
	movq	%rbp, %rdi
	movq	%rax, %rsi
	call	L31
	jmp	L46
L39:
	movq	%rbp, %rdi
	movq	%rbx, %rsi
	call	L31
	jmp	L41
L60:
	movq	-16(%rbp), %rcx
	movq	%rcx, %rbx
	addq	$16, %rsp
	leave
	ret
L38:	.long 1
	.ascii "0"
L37:	.long 1
	.ascii "-"
L31:	/* printint::f [m~8, t114] [] */
	pushq	%rbp
	movq	%rsp, %rbp
	subq	$16, %rsp
	movq	%rbx, %rax
	movq	%rax, -16(%rbp)
L63:
	movq	%rsi, %rbx
	movq	%rdi, -8(%rbp)
	movq	$1, %rax
	cmp	$0, %rbx
	jg	L35
L36:
	movq	$0, %rax
L35:
	cmp	$0, %rax
	je	L34
L33:
	movq	-8(%rbp), %rsi
	xor	%rdx, %rdx
	movq	%rbx, %rax
	movq	$10, %rcx
	idiv	%rcx
	movq	%rsi, %rdi
	movq	%rax, %rsi
	call	L31
	xor	%rdx, %rdx
	movq	%rbx, %rax
	movq	$10, %rcx
	idiv	%rcx
	imul	$10, %rax
	subq	%rax, %rbx
	movq	$L32, %rax
	movq	%rax, %rdi
	call	ord
	movq	%rax, %rcx
	movq	%rbx, %rax
	addq	%rcx, %rax
	movq	%rax, %rdi
	call	chr
	movq	%rax, %rdi
	call	print
L34:
	movq	$0, %rax
	jmp	L62
L62:
	movq	-16(%rbp), %rcx
	movq	%rcx, %rbx
	addq	$16, %rsp
	leave
	ret
L32:	.long 1
	.ascii "0"
L1:	/* readint [m~8] [] */
	pushq	%rbp
	movq	%rsp, %rbp
	subq	$40, %rsp
	movq	%rbx, %rax
	movq	%rax, -16(%rbp)
L65:
	movq	%rdi, -8(%rbp)
	movq	$8, %rax
	movq	%rax, %rdi
	call	malloc
	movq	$0, 0(%rax)
	movq	%rax, -24(%rbp)
	movq	$0, %rbx
	movq	%rbp, %rdi
	call	L5
	movq	-24(%rbp), %rax
	movq	%rax, -32(%rbp)
	movq	-32(%rbp), %rax
	addq	$0, %rax
	movq	%rax, -32(%rbp)
	movq	-8(%rbp), %rax
	movq	-8(%rax), %rax
	movq	%rbp, %rdi
	movq	%rax, %rsi
	call	L4
	movq	%rax, %rcx
	movq	-32(%rbp), %rax
	movq	%rcx, (%rax)
L29:
	movq	-8(%rbp), %rax
	movq	-8(%rax), %rax
	movq	%rbp, %rdi
	movq	%rax, %rsi
	call	L4
	cmp	$0, %rax
	je	L27
L30:
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
	movq	$L28, %rax
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
	jmp	L29
L27:
	movq	%rbx, %rax
	jmp	L64
L64:
	movq	-16(%rbp), %rcx
	movq	%rcx, %rbx
	addq	$40, %rsp
	leave
	ret
L28:	.long 1
	.ascii "0"
L5:	/* readint::skipto [m~8] [] */
	pushq	%rbp
	movq	%rsp, %rbp
	subq	$16, %rsp
	movq	%rbx, %rax
	movq	%rax, -16(%rbp)
L67:
	movq	%rdi, -8(%rbp)
L25:
	movq	$1, %rbx
	movq	-8(%rbp), %rax
	movq	-8(%rax), %rax
	movq	-8(%rax), %rcx
	movq	$L15, %rax
	movq	%rcx, %rdi
	movq	%rax, %rsi
	call	_Tiger_strcmp
	cmp	$0, %rax
	je	L20
L21:
	movq	$0, %rbx
L20:
	cmp	$0, %rbx
	jne	L17
L18:
	movq	$1, %rbx
	movq	-8(%rbp), %rax
	movq	-8(%rax), %rax
	movq	-8(%rax), %rcx
	movq	$L16, %rax
	movq	%rcx, %rdi
	movq	%rax, %rsi
	call	_Tiger_strcmp
	cmp	$0, %rax
	je	L22
L23:
	movq	$0, %rbx
L22:
	movq	%rbx, %rax
L19:
	cmp	$0, %rax
	je	L24
L26:
	movq	$-8, %rax
	movq	%rax, %rcx
	movq	-8(%rbp), %rax
	movq	-8(%rax), %rax
	addq	%rax, %rcx
	movq	%rcx, %rbx
	call	_Tiger_getchar
	movq	%rax, (%rbx)
	jmp	L25
L17:
	movq	$1, %rax
	jmp	L19
L24:
	movq	$0, %rax
	jmp	L66
L66:
	movq	-16(%rbp), %rcx
	movq	%rcx, %rbx
	addq	$16, %rsp
	leave
	ret
L16:	.long 1
	.ascii "\n"
L15:	.long 1
	.ascii " "
L4:	/* readint::isdigit [m~8, t107] [] */
	pushq	%rbp
	movq	%rsp, %rbp
	subq	$32, %rsp
	movq	%rbx, %rax
	movq	%rax, -16(%rbp)
L69:
	movq	%rsi, %rax
	movq	%rdi, -8(%rbp)
	movq	$1, %rbx
	movq	-8(%rbp), %rax
	movq	-8(%rax), %rax
	movq	-8(%rax), %rax
	movq	%rax, %rdi
	call	ord
	movq	%rax, -24(%rbp)
	movq	$L6, %rax
	movq	%rax, %rdi
	call	ord
	movq	%rax, %rcx
	movq	-24(%rbp), %rax
	cmp	%rcx, %rax
	jge	L11
L12:
	movq	$0, %rbx
L11:
	cmp	$0, %rbx
	jne	L8
L9:
	movq	$0, %rax
L10:
	jmp	L68
L8:
	movq	$1, %rbx
	movq	-8(%rbp), %rax
	movq	-8(%rax), %rax
	movq	-8(%rax), %rax
	movq	%rax, %rdi
	call	ord
	movq	%rax, -32(%rbp)
	movq	$L7, %rax
	movq	%rax, %rdi
	call	ord
	movq	%rax, %rcx
	movq	-32(%rbp), %rax
	cmp	%rcx, %rax
	jle	L13
L14:
	movq	$0, %rbx
L13:
	movq	%rbx, %rax
	jmp	L10
L68:
	movq	-16(%rbp), %rcx
	movq	%rcx, %rbx
	addq	$32, %rsp
	leave
	ret
L7:	.long 1
	.ascii "9"
L6:	.long 1
	.ascii "0"
L0:	.long 16
	.ascii "Enter a number: "
