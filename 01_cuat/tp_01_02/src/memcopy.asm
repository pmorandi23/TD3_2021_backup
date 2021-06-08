; ROM de 64 KBytes
; El procesador arranca en FFFF0 y en modo real, con
; lo cual el mapa de memoria es de 1MB
; Ver mapa de memoria de Modo Real para ver a que direcciones se puede acceder (0xF0000 ya tiene ROM por ej)

ORG 0xF0000	; Esto es: 1MB - 64KB + 1 -> 0xFFFFF-0x1000 = 0xEFFFF. Entonces
		; el origen de nuestra ROM es: 0xEFFFF +  1 (que es la sig posición
		; de memoria): 0xF0000

USE16


ROM_SIZE EQU 0x10000; 64KB
DEST_ADDRESS EQU 0x0000; Offset de destino
code_size EQU end - init_bootstrap		

; Rellenamos la ROM con 0x90 (NOP)
times (ROM_SIZE-code_size) db 0x90 ; Otra opción: times 4096 resb 1

init_bootstrap:

idle:
    xchg bx,bx ;magic breakpoint. Se habilitan desde el bochsrc
	hlt
	jmp	idle

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
	repnz movsb
	ret
init:
	mov	ax,0x9000; Valor para el segemento de codigo destino
	mov	es,ax ; Asigno ax a es 
	mov	di,DEST_ADDRESS ;Le asigno a DI la dirección de destino para el memcopy
	mov bx,0xF000 ;Valor para del segmento de codigo origen
	mov ds,bx ; Funciona tambien con el bx
	;push    cs ;Pusheo en el SP el valor del selector de segmento CS
	;pop	ds ;Popeo el valor del SP (CS) al registro DS porque no puedo hacer mov ds,cs
	mov	si,init_bootstrap ; Le asigno a SI la dirección de inicio de mi código para el memcopy
	mov	cx,code_size ; Le asigno a CX el tamaño del código a ser copiado
	call memcopy
	jmp	0x9000:DEST_ADDRESS
align 16
init16:				
	cli
	jmp	init
aqui:
	hlt
	jmp	aqui

align 16		
end:
