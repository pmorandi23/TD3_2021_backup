USE16

SECTION .ROM_init

%include "inc/processor-flags.h" 

GLOBAL return_init_screen
GLOBAL start16
GLOBAL DS_SEL_32_prim

EXTERN __INIT_16_LMA
EXTERN start32_launcher
EXTERN __STACK_START_16
EXTERN __STACK_END_16
EXTERN init_screen


start16:
    test    eax, 0x0 ; Verifico que el uP no este en fallo
    jne     fault_end 
    xor     eax, eax ; Pongo en 0 al acumulador
    mov     cr3, eax ; Invalidar TLB (se va a utilizar mas en paginación y cache})

    ; ->Seteo 16 bits stack (SI NO ESTABA, NO SE CARGA LA GDT. HAY QUE INICIALIZAR UN STACK EN 16 BITS AUNQUE NO SE USE!)
    mov ax,cs
    mov ds,ax
    mov ax,__STACK_START_16
    mov ss,ax
    mov sp,__STACK_END_16

    ;-> Deshabilitar cache <-
    mov     eax, cr0
    or      eax, (X86_CR0_NW | X86_CR0_CD)
    mov     cr0, eax
    wbinvd    ; Write back and invalidates cache

    o32 lgdt [gdtr_16] ; Carga de la GDT pero sin entrar en MP . [ds:_gtdr] está implícito usando []

    ;-> Inicializo la pantalla
    jmp init_screen
return_init_screen:


    ; -> Establecer el uP en MP (Modo Protegido) <-
    smsw    ax ; Stores the machine status word (bits 0 through 15 of control register CR0) into the destination operand. The destination operand can be a general-purpose register or a memory location.
    or      ax, X86_CR0_PE
    lmsw    ax ; Loads the source operand into the machine status word, bits 0 through 15 of register CR0. The source operand can be a 16-bit general-purpose register or a memory location
    ;xchg    bx, bx ; Breakpoint. En este punto el uP entró en MP
    jmp     dword CS_SEL_32_prim:start32_launcher ; Salto en memoria a la seccion de codigo de 32 bits.

fault_end:
    hlt

;------------------------------------GDT 16 BITS------------------------------------------------
GDT:
NULL_SEL_16     equ $-GDT       ;0x00
    dq 0x0
CS_SEL_16       equ $-GDT       ;0x08
    dw 0xFFFF       ;Limit 15-0
    dw 0x0000       ;Base 15-0
    db 0xFF         ;Base 23-16
    db 10011001b    ;Atributos:
                    ;P
                    ;DPL
                    ;S
                    ;D/C
                    ;ED/C
                    ;R/w
                    ;A
    db 01000000b    ;Limit
                    ;G
                    ;D/B
                    ;L
                    ;AVL
    db 0xFF         ;Base 31-24

CS_SEL_32_prim  equ $-GDT       ;0x10
    dw 0xFFFF       ;Limit 15-0
    dw 0x0000       ;Base 15-0
    db 0x00         ;Base 23-16
    db 10011001b    ;Atributos:                   
                        ;P=1 Presente en el segmento
                        ;DPL=00 Privilegio nivel 0 - Kernel
                        ;S=1 Descriptor de Codigo/Datos        
                        ;D/C=1 Segmento de Codigo 
                        ;C=0 No puede ser invocado
                        ;R=0 No legible
                        ;A=1 por defecto Accedido
    db 11001111b    ;Limit 19-16 (Parte baja)
                    ;Parte alta:
                        ;G=1 Maximo offset = Limite*0x1000+0xFFF
                        ;D/B=1 Big, Segmento de 32
                        ;L=0 No 64 bits nativo
                        ;AVL=0 No utilizado
    db 0x00         ;Base
DS_SEL_32_prim  equ $-GDT       ;0x18
    dw 0xFFFF       ;Limit 15-0
    dw 0x0000       ;Base 15-0
    db 0x00         ;Base 23-16
    db 10010010b    ;Atributos:
                        ;P=1 Presente en el segmento
                        ;DPL=00 Privilegio nivel 0 - Kernel
                        ;S=1 Descriptor de Codigo/Datos                        
                        ;D/C=0 Segmento de Datos 
                        ;ED=0 Segmento de datos comun
                        ;W=1 Escribible
                        ;A=0 por defecto No Accedido
    db 11001111b    ;Limit
                    ;G
                    ;D/B
                    ;L
                    ;AVL
    db 0x00         ;Base
GDT_LENGTH EQU $-GDT

gdtr_16:                                
    dw  GDT_LENGTH - 1                 ;Li­mite GDT (16 bits).
    dd  GDT                            ;Base GDT (32 bits). __SYS_TABLES_LMA
