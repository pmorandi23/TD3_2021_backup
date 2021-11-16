; Armamos una ROM de 4 KBytes
; El procesador arranca en FFFF0 y en modo real, con
; lo cual el mapa de memoria es de 1MB

ORG 0xFF000	; Esto es: 1MB - 4KB + 1 -> 0xFFFFF-0x1000 = 0xFEFFF. Entonces
		; el origen de nuestra ROM es: 0xFEFFF +  1 (que es la sig posición
		; de memoria): 0xFF000

USE16
code_size EQU end - init16

; Rellenamos la ROM con 0x90 (NOP)
times (4096-code_size) db 0x90 ; Otra opción: times 4096 resb 1

init16:				
	cli
	jmp init16
aqui:
	hlt
	jmp aqui

align 16		
end:
		
