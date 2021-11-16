; Armamos una ROM de 4 KBytes
; El procesador arranca en FFFF0 y en modo real, con
; lo cual el mapa de memoria es de 1MB

ORG 0xFF000	; Esto es: 1MB - 4KB + 1 -> 0xFFFFF-0x1000 = 0xFEFFF. Entonces
		; el origen de nuestra ROM es: 0xFEFFF +  1 (que es la sig posición
		; de memoria): 0xFF000

USE16
code_size EQU end - init_bootstrap		

; Rellenamos la ROM con 0x90 (NOP)
times (4096-code_size) db 0x90 ; Otra opción: times 4096 resb 1

init_bootstrap:

idle:
	hlt
	jmp	idle

;/**
;* Subrutina: memcopy
;* Recibe:
;*  es:di la dirección lógica de destino (a donde quiero copiar)
;*  ds:si la dirección lógica de origen (lo que quiero copiar)
;*  cx la cantidad de bytes a copiar
;* Retorna:
;*  NULL si hubo error
;*  puntero a la dirección de inicio de la nueva copia
memcopy:
	cld
	repnz 	movsb
	ret
init:
	mov	ax,0
	mov	es,ax
	mov	di,0x7c00
	push	cs
	pop	ds
	mov	si,init_bootstrap
	mov	cx,code_size
	call	memcopy
	jmp	0x0:0x7C00
align 16
init16:				
	cli
	jmp	init
aqui:
	hlt
	jmp	aqui

align 16		
end:

