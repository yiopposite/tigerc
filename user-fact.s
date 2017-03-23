	.file "user-fact.tig"
	.text
	.global _Tiger_main
_Tiger_main:	/*  [] [] */
	pushq	%rbp
	movq	%rsp, %rbp
	subq	$32, %rsp
L57:
	movq	$L0, %rdi
	call	print
	movq	$-8, %rax
	movq	%rax, -16(%rbp)
	movq	-16(%rbp), %rax
	addq	%rbp, %rax
	movq	%rax, -24(%rbp)
	call	_Tiger_getchar
	movq	-24(%rbp), %rcx
	movq	%rax, (%rcx)
	movq	$0, %rax
	movq	%rax, -32(%rbp)
	movq	%rbp, %rdi
	call	L1
	movq	%rax, -32(%rbp)
	movq	%rbp, %rdi
	movq	-32(%rbp), %rsi
	call	L2
	movq	$L54, %rdi
	call	print
	movq	%rbp, %rdi
	movq	-32(%rbp), %rsi
	call	L3
	movq	%rbp, %rdi
	movq	%rax, %rsi
	call	L2
	movq	$L55, %rdi
	call	print
	jmp	L56
L56:
	addq	$32, %rsp
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
	movq	%rdi, -8(%rbp)
	movq	$1, %rax
	cmp	$1, %rsi
	jle	L52
L53:
	movq	$0, %rax
L52:
	cmp	$0, %rax
	jne	L49
L50:
	movq	%rsi, -16(%rbp)
	movq	-8(%rbp), %rdi
	subq	$1, %rsi
	call	L3
	movq	-16(%rbp), %rcx
	imul	%rax, %rcx
L51:
	movq	%rcx, %rax
	jmp	L58
L49:
	movq	$1, %rcx
	jmp	L51
L58:
	addq	$16, %rsp
	leave
	ret
L2:	/* printint [m~8, t102] [] */
	pushq	%rbp
	movq	%rsp, %rbp
	subq	$16, %rsp
	movq	%rbx, -16(%rbp)
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
	movq	$L38, %rdi
	call	print
L41:
L46:
	jmp	L60
L44:
	movq	$L37, %rdi
	call	print
	movq	$0, %rsi
	subq	%rbx, %rsi
	movq	%rbp, %rdi
	call	L31
	jmp	L46
L39:
	movq	%rbp, %rdi
	movq	%rbx, %rsi
	call	L31
	jmp	L41
L60:
	movq	-16(%rbp), %rbx
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
	movq	%rbx, -16(%rbp)
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
	movq	-8(%rbp), %rdi
	xor	%rdx, %rdx
	movq	%rbx, %rax
	movq	$10, %rcx
	idiv	%rcx
	movq	%rax, %rsi
	call	L31
	xor	%rdx, %rdx
	movq	%rbx, %rax
	movq	$10, %rcx
	idiv	%rcx
	imul	$10, %rax
	subq	%rax, %rbx
	movq	$L32, %rdi
	call	ord
	addq	%rax, %rbx
	movq	%rbx, %rdi
	call	chr
	movq	%rax, %rdi
	call	print
L34:
	movq	$0, %rax
	jmp	L62
L62:
	movq	-16(%rbp), %rbx
	addq	$16, %rsp
	leave
	ret
L32:	.long 1
	.ascii "0"
L1:	/* readint [m~8] [] */
	pushq	%rbp
	movq	%rsp, %rbp
	subq	$40, %rsp
	movq	%rbx, -16(%rbp)
L65:
	movq	%rdi, -8(%rbp)
	movq	$8, %rdi
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
	movq	-8(%rax), %rsi
	movq	%rbp, %rdi
	call	L4
	movq	-32(%rbp), %rcx
	movq	%rax, (%rcx)
L29:
	movq	-8(%rbp), %rax
	movq	-8(%rax), %rsi
	movq	%rbp, %rdi
	call	L4
	cmp	$0, %rax
	je	L27
L30:
	imul	$10, %rbx
	movq	-8(%rbp), %rax
	movq	-8(%rax), %rdi
	call	ord
	addq	%rax, %rbx
	movq	$L28, %rdi
	call	ord
	subq	%rax, %rbx
	movq	$-8, %rax
	movq	-8(%rbp), %rcx
	addq	%rcx, %rax
	movq	%rax, -40(%rbp)
	call	_Tiger_getchar
	movq	-40(%rbp), %rcx
	movq	%rax, (%rcx)
	jmp	L29
L27:
	movq	%rbx, %rax
	jmp	L64
L64:
	movq	-16(%rbp), %rbx
	addq	$40, %rsp
	leave
	ret
L28:	.long 1
	.ascii "0"
L5:	/* readint::skipto [m~8] [] */
	pushq	%rbp
	movq	%rsp, %rbp
	subq	$16, %rsp
	movq	%rbx, -16(%rbp)
L67:
	movq	%rdi, -8(%rbp)
L25:
	movq	$1, %rbx
	movq	-8(%rbp), %rax
	movq	-8(%rax), %rax
	movq	-8(%rax), %rdi
	movq	$L15, %rsi
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
	movq	-8(%rax), %rdi
	movq	$L16, %rsi
	call	_Tiger_strcmp
	cmp	$0, %rax
	je	L22
L23:
	movq	$0, %rbx
L22:
L19:
	cmp	$0, %rbx
	je	L24
L26:
	movq	$-8, %rbx
	movq	-8(%rbp), %rax
	movq	-8(%rax), %rax
	addq	%rax, %rbx
	call	_Tiger_getchar
	movq	%rax, (%rbx)
	jmp	L25
L17:
	movq	$1, %rbx
	jmp	L19
L24:
	movq	$0, %rax
	jmp	L66
L66:
	movq	-16(%rbp), %rbx
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
	movq	%rbx, -16(%rbp)
L69:
	movq	%rdi, -8(%rbp)
	movq	$1, %rbx
	movq	-8(%rbp), %rax
	movq	-8(%rax), %rax
	movq	-8(%rax), %rdi
	call	ord
	movq	%rax, -24(%rbp)
	movq	$L6, %rdi
	call	ord
	movq	-24(%rbp), %rcx
	cmp	%rax, %rcx
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
	movq	-8(%rax), %rdi
	call	ord
	movq	%rax, -32(%rbp)
	movq	$L7, %rdi
	call	ord
	movq	-32(%rbp), %rcx
	cmp	%rax, %rcx
	jle	L13
L14:
	movq	$0, %rbx
L13:
	movq	%rbx, %rax
	jmp	L10
L68:
	movq	-16(%rbp), %rbx
	addq	$32, %rsp
	leave
	ret
L7:	.long 1
	.ascii "9"
L6:	.long 1
	.ascii "0"
L0:	.long 16
	.ascii "Enter a number: "
