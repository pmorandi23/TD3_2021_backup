global strncpy_asm64

section .text
strncpy_asm64:
	push 	rcx
	cld
	mov 	rcx, rdx
 	REPE  	movsb
	pop		rcx
	mov 	rax, rdi
	ret