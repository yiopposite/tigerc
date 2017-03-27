	.file "queens.tig"
	.text
	.global _Tiger_main
_Tiger_main:	/*  [] [] */
	pushq	%rbp
	movq	%rsp, %rbp
	subq	$128, %rsp
	movq	%rbx, -56(%rbp)
	movq	%r12, -64(%rbp)
L52:
	movq	$8, -8(%rbp)
	movq	$0, -16(%rbp)
	movq	$-24, %r12
	addq	%rbp, %r12
	movq	-8(%rbp), %rbx
	movq	$0, %rax
	movq	%rax, -72(%rbp)
	movq	%rbx, %rdi
	imul	$8, %rdi
	call	malloc
	movq	$0, %rdx
L0:
	cmp	%rbx, %rdx
	jge	L2
L1:
	movq	%rax, %rsi
	movq	%rdx, %rcx
	imul	$8, %rcx
	addq	%rcx, %rsi
	movq	-72(%rbp), %rcx
	movq	%rcx, (%rsi)
	addq	$1, %rdx
	jmp	L0
L2:
	movq	%rax, (%r12)
	movq	$-32, %rbx
	addq	%rbp, %rbx
	movq	-8(%rbp), %r12
	movq	$0, %rax
	movq	%rax, -80(%rbp)
	movq	%r12, %rdi
	imul	$8, %rdi
	call	malloc
	movq	$0, %rdx
L3:
	cmp	%r12, %rdx
	jge	L5
L4:
	movq	%rax, %rsi
	movq	%rdx, %rcx
	imul	$8, %rcx
	addq	%rcx, %rsi
	movq	-80(%rbp), %rcx
	movq	%rcx, (%rsi)
	addq	$1, %rdx
	jmp	L3
L5:
	movq	%rax, (%rbx)
	movq	$-40, %rax
	movq	%rax, -104(%rbp)
	movq	-104(%rbp), %rax
	addq	%rbp, %rax
	movq	%rax, -112(%rbp)
	movq	-8(%rbp), %r12
	movq	-8(%rbp), %rax
	addq	%rax, %r12
	subq	$1, %r12
	movq	$0, %rax
	movq	%rax, -88(%rbp)
	movq	%r12, %rdi
	imul	$8, %rdi
	call	malloc
	movq	$0, %rdx
L6:
	cmp	%r12, %rdx
	jge	L8
L7:
	movq	%rax, %rbx
	movq	%rdx, %rcx
	imul	$8, %rcx
	addq	%rcx, %rbx
	movq	-88(%rbp), %rcx
	movq	%rcx, (%rbx)
	addq	$1, %rdx
	jmp	L6
L8:
	movq	-112(%rbp), %rcx
	movq	%rax, (%rcx)
	movq	$-48, %rax
	movq	%rax, -120(%rbp)
	movq	-120(%rbp), %rax
	addq	%rbp, %rax
	movq	%rax, -128(%rbp)
	movq	-8(%rbp), %r12
	movq	-8(%rbp), %rax
	addq	%rax, %r12
	subq	$1, %r12
	movq	$0, %rax
	movq	%rax, -96(%rbp)
	movq	%r12, %rdi
	imul	$8, %rdi
	call	malloc
	movq	$0, %rdx
L9:
	cmp	%r12, %rdx
	jge	L11
L10:
	movq	%rax, %rbx
	movq	%rdx, %rcx
	imul	$8, %rcx
	addq	%rcx, %rbx
	movq	-96(%rbp), %rcx
	movq	%rcx, (%rbx)
	addq	$1, %rdx
	jmp	L9
L11:
	movq	-128(%rbp), %rcx
	movq	%rax, (%rcx)
	movq	$0, %rsi
	movq	%rbp, %rdi
	call	L13
	movq	-16(%rbp), %rax
	jmp	L51
L51:
	movq	-64(%rbp), %r12
	movq	-56(%rbp), %rbx
	addq	$128, %rsp
	leave
	ret
L13:	/* try [m~8, t116] [] */
	pushq	%rbp
	movq	%rsp, %rbp
	subq	$24, %rsp
	movq	%rbx, -16(%rbp)
L54:
	movq	%rsi, -24(%rbp)
	movq	%rdi, -8(%rbp)
	movq	$1, %rdx
	movq	-8(%rbp), %rax
	movq	-8(%rax), %rcx
	movq	-24(%rbp), %rax
	cmp	%rcx, %rax
	je	L49
L50:
	movq	$0, %rdx
L49:
	cmp	$0, %rdx
	jne	L46
L47:
	movq	$0, %rbx
L44:
	movq	-8(%rbp), %rax
	movq	-8(%rax), %rax
	subq	$1, %rax
	cmp	%rax, %rbx
	jg	L29
L45:
	movq	$1, %rdx
	movq	-8(%rbp), %rax
	movq	-24(%rax), %rcx
	movq	%rbx, %rax
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
	movq	-24(%rax), %rcx
	movq	%rbx, %rax
	imul	$8, %rax
	addq	%rax, %rcx
	movq	$1, %rax
	movq	%rax, (%rcx)
	movq	-8(%rbp), %rax
	movq	-40(%rax), %rcx
	movq	%rbx, %rax
	movq	-24(%rbp), %rdx
	addq	%rdx, %rax
	imul	$8, %rax
	addq	%rax, %rcx
	movq	$1, %rax
	movq	%rax, (%rcx)
	movq	-8(%rbp), %rax
	movq	-48(%rax), %rcx
	movq	%rbx, %rax
	addq	$7, %rax
	movq	-24(%rbp), %rdx
	subq	%rdx, %rax
	imul	$8, %rax
	addq	%rax, %rcx
	movq	$1, %rax
	movq	%rax, (%rcx)
	movq	-8(%rbp), %rax
	movq	-32(%rax), %rcx
	movq	-24(%rbp), %rax
	imul	$8, %rax
	addq	%rax, %rcx
	movq	%rbx, (%rcx)
	movq	-8(%rbp), %rdi
	movq	-24(%rbp), %rsi
	addq	$1, %rsi
	call	L13
	movq	-8(%rbp), %rax
	movq	-24(%rax), %rcx
	movq	%rbx, %rax
	imul	$8, %rax
	addq	%rax, %rcx
	movq	$0, %rax
	movq	%rax, (%rcx)
	movq	-8(%rbp), %rax
	movq	-40(%rax), %rcx
	movq	%rbx, %rax
	movq	-24(%rbp), %rdx
	addq	%rdx, %rax
	imul	$8, %rax
	addq	%rax, %rcx
	movq	$0, %rax
	movq	%rax, (%rcx)
	movq	-8(%rbp), %rax
	movq	-48(%rax), %rcx
	movq	%rbx, %rax
	addq	$7, %rax
	movq	-24(%rbp), %rdx
	subq	%rdx, %rax
	imul	$8, %rax
	addq	%rax, %rcx
	movq	$0, %rax
	movq	%rax, (%rcx)
L43:
	addq	$1, %rbx
	jmp	L44
L46:
	movq	-8(%rbp), %rcx
	movq	-8(%rbp), %rax
	movq	-16(%rax), %rax
	addq	$1, %rax
	movq	%rax, -16(%rcx)
	movq	$0, %rax
L48:
	jmp	L53
L30:
	movq	$1, %rax
	movq	-8(%rbp), %rcx
	movq	-40(%rcx), %rdx
	movq	%rbx, %rcx
	movq	-24(%rbp), %rsi
	addq	%rsi, %rcx
	imul	$8, %rcx
	addq	%rcx, %rdx
	movq	(%rdx), %rcx
	cmp	$0, %rcx
	je	L35
L36:
	movq	$0, %rax
L35:
	jmp	L32
L37:
	movq	$1, %rax
	movq	-8(%rbp), %rcx
	movq	-48(%rcx), %rdx
	movq	%rbx, %rcx
	addq	$7, %rcx
	movq	-24(%rbp), %rsi
	subq	%rsi, %rcx
	imul	$8, %rcx
	addq	%rcx, %rdx
	movq	(%rdx), %rcx
	cmp	$0, %rcx
	je	L40
L41:
	movq	$0, %rax
L40:
	jmp	L39
L29:
	movq	$0, %rax
	jmp	L48
L53:
	movq	-16(%rbp), %rbx
	addq	$24, %rsp
	leave
	ret
L12:	/* printboard [m~8] [] */
	pushq	%rbp
	movq	%rsp, %rbp
	subq	$24, %rsp
	movq	%rbx, -16(%rbp)
	movq	%r12, -24(%rbp)
L56:
	movq	%rdi, -8(%rbp)
	movq	$0, %rbx
L26:
	movq	-8(%rbp), %rax
	movq	-8(%rax), %rax
	subq	$1, %rax
	cmp	%rax, %rbx
	jg	L14
L27:
	movq	$0, %r12
L23:
	movq	-8(%rbp), %rax
	movq	-8(%rax), %rax
	subq	$1, %rax
	cmp	%rax, %r12
	jg	L15
L24:
	movq	$1, %rdx
	movq	-8(%rbp), %rax
	movq	-32(%rax), %rcx
	movq	%rbx, %rax
	imul	$8, %rax
	addq	%rax, %rcx
	movq	(%rcx), %rax
	cmp	%r12, %rax
	je	L21
L22:
	movq	$0, %rdx
L21:
	cmp	$0, %rdx
	jne	L18
L19:
	movq	$L17, %rdi
L20:
	call	print
	addq	$1, %r12
	jmp	L23
L18:
	movq	$L16, %rdi
	jmp	L20
L15:
	movq	$L25, %rdi
	call	print
	addq	$1, %rbx
	jmp	L26
L14:
	movq	$L28, %rdi
	call	print
	jmp	L55
L55:
	movq	-24(%rbp), %r12
	movq	-16(%rbp), %rbx
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
