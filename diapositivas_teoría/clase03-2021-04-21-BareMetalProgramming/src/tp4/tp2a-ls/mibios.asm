; Armamos una ROM de 4 KBytes
; El procesador arranca en FFFF0 y en modo real, con
; lo cual el mapa de memoria es de 1MB

code_size EQU end - reset 
GLOBAL	reset
USE16
section .data
times (4096-code_size) db 0x90 ; Otra opción: times 4096 resb 1

section .resetVector

reset:				
	cli
	jmp reset 
aqui:
	hlt
	jmp aqui

align 16		
end:
