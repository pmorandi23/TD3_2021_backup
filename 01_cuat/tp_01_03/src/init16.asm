BITS 16
GLOBAL init16_entry

SECTION .init16

init16_size EQU end - init_bootstrap		

init_bootstrap:
    xchg bx,bx ;magic breakpoint. Se habilitan desde el bochsrc. Si se copio OK deberia saltar acá
	hlt
memcopy:
	cld
	repnz movsb
	ret
init16_entry:
;* Seteamos un stack en 0x00068000(par ss:sp deberia ser ss=0x6000 y sp=0x8000)
    mov ax,0x6000
    mov ss,ax
	mov sp,0x8000
; Seteo pares de destino (es:di) y fuente (ds:si)
    mov ax,0x0
    mov es,ax
    mov di,0x7C00
    mov bx,0xF000 ;Valor para del segmento de codigo origen
	mov ds,bx ; Funciona tambien con el bx
    mov si,init_bootstrap
; Seteo cantidad de bytes a copiar calculada al principio
    mov cx,init16_size
    call memcopy
    jmp 0x0:0x7C00
    align 16
end:

