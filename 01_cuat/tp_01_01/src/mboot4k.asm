; Armamos una ROM de 4 KBytes
; El procesador arranca en FFFF0 y en modo real, con
; lo cual el mapa de memoria es de 1MB

ORG 0xFF000	; Esto es: 1MB - 4KB + 1 -> 0xFFFFF-0x1000 = 0xFEFFF. Entonces
			; el origen de nuestra ROM es: 0xFEFFF +  1 (que es la sig posición
			; de memoria): 0xFF000

USE16
code_size EQU (end - init16)	;Tamaño del código desde el final de la memoria 0xFFFFF (end) hasta la etiqueta el comienzo del código(init16)		

; Rellenamos la ROM con 0x90 (NOP) desde 0xFF000 hasta init16
times (4096-code_size) db 0x90 ; Otra opción: times 4096 resb 1

init16:				
	cli
	jmp	init16
aqui:
	hlt		; Si por algún motivo sale del loop: HALT
	jmp	aqui    ; Solo sale por reset o por interrupción
align 16		; Completa hasta la siguiente dirección múltiplo
			; de 16 (verificar con que completa con NOP ’s).

end:


