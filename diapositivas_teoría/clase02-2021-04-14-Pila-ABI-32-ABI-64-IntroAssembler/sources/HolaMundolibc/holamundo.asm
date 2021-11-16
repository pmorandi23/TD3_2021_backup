section .data
   msg:  DB 'Hola Mundo', 10
   largo EQU $ - msg
global main

extern printf

section .text
main:
	push rbp
	mov rbp,rsp
	mov rdi,msg
	mov eax,1 
	call printf 
	mov eax,0
	pop rbp
	ret
