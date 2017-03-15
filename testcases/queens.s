	.file "queens.tig"
	.text
	.global _Tiger_main
_Tiger_main:	/*  [] [] */
	pushq	%rbp
	movq	%rsp, %rbp
	subq	$144, %rsp
L52:
	movq	$8, -8(%rbp)
	movq	$0, -16(%rbp)
	movq	$-24, %rax
	movq	%rax, %rax
	addq	%rbp, %rax
	movq	%rax, %rax
	movq	%rax, -56(%rbp)
	movq	-8(%rbp), %rax
	movq	%rax, -64(%rbp)
	movq	$0, %rax
	movq	%rax, -72(%rbp)
	movq	-64(%rbp), %rax
	movq	%rax, %rax
	imul	$8, %rax
	movq	%rax, %rdi
	call	malloc
	movq	%rax, %rax
	movq	%rax, %rsi
	movq	$0, %rdx
L0:
	movq	-64(%rbp), %rax
	cmp	%rax, %rdx
	jge	L2
L1:
	movq	%rsi, %rcx
	movq	%rdx, %rax
	imul	$8, %rax
	addq	%rax, %rcx
	movq	-72(%rbp), %rax
	movq	%rax, (%rcx)
	movq	%rdx, %rax
	addq	$1, %rax
	movq	%rax, %rdx
	jmp	L0
L2:
	movq	-56(%rbp), %rax
	movq	%rsi, (%rax)
	movq	$-32, %rax
	movq	%rax, %rax
	addq	%rbp, %rax
	movq	%rax, %rax
	movq	%rax, -80(%rbp)
	movq	-8(%rbp), %rax
	movq	%rax, -88(%rbp)
	movq	$0, %rax
	movq	%rax, -96(%rbp)
	movq	-88(%rbp), %rax
	movq	%rax, %rax
	imul	$8, %rax
	movq	%rax, %rdi
	call	malloc
	movq	%rax, %rax
	movq	%rax, %rsi
	movq	$0, %rdx
L3:
	movq	-88(%rbp), %rax
	cmp	%rax, %rdx
	jge	L5
L4:
	movq	%rsi, %rcx
	movq	%rdx, %rax
	imul	$8, %rax
	addq	%rax, %rcx
	movq	-96(%rbp), %rax
	movq	%rax, (%rcx)
	movq	%rdx, %rax
	addq	$1, %rax
	movq	%rax, %rdx
	jmp	L3
L5:
	movq	-80(%rbp), %rax
	movq	%rsi, (%rax)
	movq	$-40, %rax
	movq	%rax, %rax
	addq	%rbp, %rax
	movq	%rax, %rax
	movq	%rax, -104(%rbp)
	movq	-8(%rbp), %rax
	movq	%rax, %rcx
	movq	-8(%rbp), %rax
	addq	%rax, %rcx
	movq	%rcx, %rax
	subq	$1, %rax
	movq	%rax, %rax
	movq	%rax, -112(%rbp)
	movq	$0, %rax
	movq	%rax, -120(%rbp)
	movq	-112(%rbp), %rax
	movq	%rax, %rax
	imul	$8, %rax
	movq	%rax, %rdi
	call	malloc
	movq	%rax, %rax
	movq	%rax, %rsi
	movq	$0, %rdx
L6:
	movq	-112(%rbp), %rax
	cmp	%rax, %rdx
	jge	L8
L7:
	movq	%rsi, %rcx
	movq	%rdx, %rax
	imul	$8, %rax
	addq	%rax, %rcx
	movq	-120(%rbp), %rax
	movq	%rax, (%rcx)
	movq	%rdx, %rax
	addq	$1, %rax
	movq	%rax, %rdx
	jmp	L6
L8:
	movq	-104(%rbp), %rax
	movq	%rsi, (%rax)
	movq	$-48, %rax
	movq	%rax, %rax
	addq	%rbp, %rax
	movq	%rax, %rax
	movq	%rax, -128(%rbp)
	movq	-8(%rbp), %rax
	movq	%rax, %rcx
	movq	-8(%rbp), %rax
	addq	%rax, %rcx
	movq	%rcx, %rax
	subq	$1, %rax
	movq	%rax, %rax
	movq	%rax, -136(%rbp)
	movq	$0, %rax
	movq	%rax, -144(%rbp)
	movq	-136(%rbp), %rax
	movq	%rax, %rax
	imul	$8, %rax
	movq	%rax, %rdi
	call	malloc
	movq	%rax, %rax
	movq	%rax, %rsi
	movq	$0, %rdx
L9:
	movq	-136(%rbp), %rax
	cmp	%rax, %rdx
	jge	L11
L10:
	movq	%rsi, %rcx
	movq	%rdx, %rax
	imul	$8, %rax
	addq	%rax, %rcx
	movq	-144(%rbp), %rax
	movq	%rax, (%rcx)
	movq	%rdx, %rax
	addq	$1, %rax
	movq	%rax, %rdx
	jmp	L9
L11:
	movq	-128(%rbp), %rax
	movq	%rsi, (%rax)
	movq	$0, %rax
	movq	%rbp, %rdi
	movq	%rax, %rsi
	call	L13
	movq	%rax, %rax
	movq	-16(%rbp), %rax
	jmp	L51
L51:
	addq	$144, %rsp
	leave
	ret
L13:	/* try [m~8, t116] [] */
	pushq	%rbp
	movq	%rsp, %rbp
	subq	$24, %rsp
L54:
	movq	%rsi, %rax
	movq	%rax, -16(%rbp)
	movq	%rdi, -8(%rbp)
	movq	$1, %rdx
	movq	-8(%rbp), %rax
	movq	-8(%rax), %rcx
	movq	-16(%rbp), %rax
	cmp	%rcx, %rax
	je	L49
L50:
	movq	$0, %rdx
L49:
	cmp	$0, %rdx
	jne	L46
L47:
	movq	$0, %rax
	movq	%rax, -24(%rbp)
L44:
	movq	-8(%rbp), %rax
	movq	-8(%rax), %rax
	movq	%rax, %rcx
	subq	$1, %rcx
	movq	-24(%rbp), %rax
	cmp	%rcx, %rax
	jg	L29
L45:
	movq	$1, %rdx
	movq	-8(%rbp), %rax
	movq	-24(%rax), %rax
	movq	%rax, %rcx
	movq	-24(%rbp), %rax
	movq	%rax, %rax
	imul	$8, %rax
	addq	%rax, %rcx
	movq	(%rcx), %rax
	cmp	$0, %rax
	je	L33
L34:
	movq	$0, %rdx
L33:
	cmp	$0, %rdx
	jne	L30
L31:
	movq	$0, %rax
L32:
	cmp	$0, %rax
	jne	L37
L38:
	movq	$0, %rax
L39:
	cmp	$0, %rax
	je	L43
L42:
	movq	-8(%rbp), %rax
	movq	-24(%rax), %rax
	movq	%rax, %rcx
	movq	-24(%rbp), %rax
	movq	%rax, %rax
	imul	$8, %rax
	addq	%rax, %rcx
	movq	$1, %rax
	movq	%rax, (%rcx)
	movq	-8(%rbp), %rax
	movq	-40(%rax), %rax
	movq	%rax, %rdx
	movq	-24(%rbp), %rax
	movq	%rax, %rcx
	movq	-16(%rbp), %rax
	addq	%rax, %rcx
	movq	%rcx, %rax
	imul	$8, %rax
	addq	%rax, %rdx
	movq	$1, %rax
	movq	%rax, (%rdx)
	movq	-8(%rbp), %rax
	movq	-48(%rax), %rax
	movq	%rax, %rdx
	movq	-24(%rbp), %rax
	movq	%rax, %rax
	addq	$7, %rax
	movq	%rax, %rcx
	movq	-16(%rbp), %rax
	subq	%rax, %rcx
	movq	%rcx, %rax
	imul	$8, %rax
	addq	%rax, %rdx
	movq	$1, %rax
	movq	%rax, (%rdx)
	movq	-8(%rbp), %rax
	movq	-32(%rax), %rax
	movq	%rax, %rcx
	movq	-16(%rbp), %rax
	movq	%rax, %rax
	imul	$8, %rax
	addq	%rax, %rcx
	movq	-24(%rbp), %rax
	movq	%rax, (%rcx)
	movq	-8(%rbp), %rcx
	movq	-16(%rbp), %rax
	movq	%rax, %rax
	addq	$1, %rax
	movq	%rcx, %rdi
	movq	%rax, %rsi
	call	L13
	movq	%rax, %rax
	movq	-8(%rbp), %rax
	movq	-24(%rax), %rax
	movq	%rax, %rcx
	movq	-24(%rbp), %rax
	movq	%rax, %rax
	imul	$8, %rax
	addq	%rax, %rcx
	movq	$0, %rax
	movq	%rax, (%rcx)
	movq	-8(%rbp), %rax
	movq	-40(%rax), %rax
	movq	%rax, %rdx
	movq	-24(%rbp), %rax
	movq	%rax, %rcx
	movq	-16(%rbp), %rax
	addq	%rax, %rcx
	movq	%rcx, %rax
	imul	$8, %rax
	addq	%rax, %rdx
	movq	$0, %rax
	movq	%rax, (%rdx)
	movq	-8(%rbp), %rax
	movq	-48(%rax), %rax
	movq	%rax, %rdx
	movq	-24(%rbp), %rax
	movq	%rax, %rax
	addq	$7, %rax
	movq	%rax, %rcx
	movq	-16(%rbp), %rax
	subq	%rax, %rcx
	movq	%rcx, %rax
	imul	$8, %rax
	addq	%rax, %rdx
	movq	$0, %rax
	movq	%rax, (%rdx)
L43:
	movq	-24(%rbp), %rax
	movq	%rax, %rax
	addq	$1, %rax
	movq	%rax, %rax
	movq	%rax, -24(%rbp)
	jmp	L44
L46:
	movq	-8(%rbp), %rax
	movq	%rax, %rdi
	call	L12
	movq	%rax, %rax
	movq	-8(%rbp), %rcx
	movq	-8(%rbp), %rax
	movq	-16(%rax), %rax
	movq	%rax, %rax
	addq	$1, %rax
	movq	%rax, -16(%rcx)
	movq	$0, %rax
L48:
	movq	%rax, %rax
	jmp	L53
L30:
	movq	$1, %rsi
	movq	-8(%rbp), %rax
	movq	-40(%rax), %rax
	movq	%rax, %rdx
	movq	-24(%rbp), %rax
	movq	%rax, %rcx
	movq	-16(%rbp), %rax
	addq	%rax, %rcx
	movq	%rcx, %rax
	imul	$8, %rax
	addq	%rax, %rdx
	movq	(%rdx), %rax
	cmp	$0, %rax
	je	L35
L36:
	movq	$0, %rsi
L35:
	movq	%rsi, %rax
	jmp	L32
L37:
	movq	$1, %rax
	movq	-8(%rbp), %rcx
	movq	-48(%rcx), %rcx
	movq	%rcx, %rsi
	movq	-24(%rbp), %rcx
	movq	%rcx, %rcx
	addq	$7, %rcx
	movq	%rcx, %rdx
	movq	-16(%rbp), %rcx
	subq	%rcx, %rdx
	movq	%rdx, %rcx
	imul	$8, %rcx
	addq	%rcx, %rsi
	movq	(%rsi), %rcx
	cmp	$0, %rcx
	je	L40
L41:
	movq	$0, %rax
L40:
	movq	%rax, %rax
	jmp	L39
L29:
	movq	$0, %rax
	jmp	L48
L53:
	addq	$24, %rsp
	leave
	ret
L12:	/* printboard [m~8] [] */
	pushq	%rbp
	movq	%rsp, %rbp
	subq	$24, %rsp
L56:
	movq	%rdi, -8(%rbp)
	movq	$0, %rax
	movq	%rax, -16(%rbp)
L26:
	movq	-8(%rbp), %rax
	movq	-8(%rax), %rax
	movq	%rax, %rcx
	subq	$1, %rcx
	movq	-16(%rbp), %rax
	cmp	%rcx, %rax
	jg	L14
L27:
	movq	$0, %rax
	movq	%rax, -24(%rbp)
L23:
	movq	-8(%rbp), %rax
	movq	-8(%rax), %rax
	movq	%rax, %rcx
	subq	$1, %rcx
	movq	-24(%rbp), %rax
	cmp	%rcx, %rax
	jg	L15
L24:
	movq	$1, %rdx
	movq	-8(%rbp), %rax
	movq	-32(%rax), %rax
	movq	%rax, %rcx
	movq	-16(%rbp), %rax
	movq	%rax, %rax
	imul	$8, %rax
	addq	%rax, %rcx
	movq	(%rcx), %rcx
	movq	-24(%rbp), %rax
	cmp	%rax, %rcx
	je	L21
L22:
	movq	$0, %rdx
L21:
	cmp	$0, %rdx
	jne	L18
L19:
	movq	$L17, %rax
	movq	%rax, %rax
L20:
	movq	%rax, %rdi
	call	print
	movq	%rax, %rax
	movq	-24(%rbp), %rax
	movq	%rax, %rax
	addq	$1, %rax
	movq	%rax, %rax
	movq	%rax, -24(%rbp)
	jmp	L23
L18:
	movq	$L16, %rax
	movq	%rax, %rax
	jmp	L20
L15:
	movq	$L25, %rax
	movq	%rax, %rdi
	call	print
	movq	%rax, %rax
	movq	-16(%rbp), %rax
	movq	%rax, %rax
	addq	$1, %rax
	movq	%rax, %rax
	movq	%rax, -16(%rbp)
	jmp	L26
L14:
	movq	$L28, %rax
	movq	%rax, %rdi
	call	print
	movq	%rax, %rax
	movq	%rax, %rax
	jmp	L55
L55:
	addq	$24, %rsp
	leave
	ret
L28:	.long 1
	.ascii "\n"
L25:	.long 1
	.ascii "\n"
L17:	.long 2
	.ascii " ."
L16:	.long 2
	.ascii " O"
