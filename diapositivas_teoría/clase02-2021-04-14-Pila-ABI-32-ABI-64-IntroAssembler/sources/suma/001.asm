
global suma

section .data

section .text
suma:
	mov	rax,rdi ; op1 en rax
	add	rax,rsi ; op1 += op2
	ret
