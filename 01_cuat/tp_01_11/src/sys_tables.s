SECTION .sys_tables
; Direcciones LMA y VMA
EXTERN __SYS_TABLES_LMA
EXTERN __TECLADO_ISR_VMA
; Etiquetas globales
GLOBAL  DS_SEL_00
GLOBAL  CS_SEL_00
GLOBAL  DS_SEL_11
GLOBAL  CS_SEL_11
GLOBAL  TSS_SEL
GLOBAL  _gdtr_32
GLOBAL  _idtr_32
; Parte baja de direcciones de los handlers
EXTERN L_ISR00_Handler_DE
EXTERN L_ISR01_Handler_DB
EXTERN L_ISR02_Handler_NMI
EXTERN L_ISR03_Handler_BP
EXTERN L_ISR04_Handler_OF
EXTERN L_ISR05_Handler_BR
EXTERN L_ISR06_Handler_UD
EXTERN L_ISR07_Handler_NM
EXTERN L_ISR08_Handler_DF
EXTERN L_ISR10_Handler_TS
EXTERN L_ISR11_Handler_NP
EXTERN L_ISR12_Handler_SS
EXTERN L_ISR13_Handler_GP
EXTERN L_ISR14_Handler_PF
EXTERN L_ISR16_Handler_MF
EXTERN L_ISR17_Handler_AC
EXTERN L_ISR18_Handler_MC
EXTERN L_ISR19_Handler_XM
EXTERN L_IRQ00_Handler
EXTERN L_IRQ01_Handler
EXTERN L_ISR128_Handler_SC
; Parte alta de las direcciones de los Handlers
H_ISRXX_Handler     EQU 0x0010

;-------------------GDT 32 BITS ----------------
;Cada descriptor tiene 8 bytes.
GDT_32:
NULL_SEL    equ $-GDT_32       ;Indice de GDT = 0x00
    dq 0x0
CS_SEL_00   equ $-GDT_32       ;Indice de GDT = 0x10
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
DS_SEL_00      equ $-GDT_32       ;Indice de GDT = 0x20
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

CS_SEL_11      equ $-GDT_32       ;Indice de GDT = 0x30
    dw 0xFFFF       ;Limit 15-0
    dw 0x0000       ;Base 15-0
    db 0x00         ;Base 23-16
    db 11111010b    ;Atributos:
                        ;P=1 Presente en el segmento
                        ;DPL=11   nivel 3 - Usuario
                        ;S=1 Descriptor de Codigo/Datos                        
                        ;D/C=1 Segmento de Código 
                        ;ED=0 Segmento de datos comun
                        ;R=1 Legible
                        ;A=0 por defecto No Accedido
    db 11001111b    ;Limit
                    ;G
                    ;D/B
                    ;L
                    ;AVL
    db 0x00         ;Base


DS_SEL_11      equ $-GDT_32       ;Indice de GDT = 0x20
    dw 0xFFFF       ;Limit 15-0
    dw 0x0000       ;Base 15-0
    db 0x00         ;Base 23-16
    db 11110010b    ;Atributos:
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


TSS_SEL equ $-GDT_32          ;Base 0x00001000 Limite 0x00000067
    dw  0x0067                ;Limite del segmento(bits 15 -0)
    dw  0x0000                ;Base del segmento(bits 15-0)
    db  0                     ;Base del segmento(bits 23-16)
    db  10001001b             ; Atributos
                                  ; P=1 Presente en el segmento
                                  ; DPL = 00 Privilegio nivel 0 - Kernel
                                  ; S = 0 (Descriptor de TSS)
                                  ; TIPO = 1 0 B 1 siendo B = Busy y queda en 0 (Avaibable)
    db  00000000b             ; G = 0, D/B = 0, L = 0 , AVL = 0 
                              ; Límite del segmento (bits 16 - 19)
    db  0x40                  ; Base del segmento(bits 31-24)    


GDT_LENGTH EQU $-GDT_32

_gdtr_32:
    dw GDT_LENGTH-1
    ;dd 0x000FFD00 ; Base de la GDT en la section sys_tables. No van todas FFF al principio por el shadow.  
    dd GDT_32 ; Base de la GDT en la section sys_tables. Use o32 cuando la cargo en init16.  


;-------------------------IDT 32 BITS---------------------

; Cada descriptor tiene 8 bytes.
IDT:
; Divide Error
ISR00_IDT   EQU $-IDT   
    dw L_ISR00_Handler_DE                       ; 2 bytes - Offset 15-0 - Segmento de referencia al código de la EXCEPTION 

    dw CS_SEL_00                                ; 2 bytes - Selector de segmento de código

    db 00000000b                                ; 1 byte - 000 e indefinido
    db 10001111b                                ; 1 byte - Atributos
                                                    ; P = 1 (Presente en el segmento)
                                                    ; DPL = 00 (Nivel de privilegio priotidad Kernel)
                                                    ; S = 0 (Descriptor de sistema)
                                                    ; TIPO = 1111 (Puerta de Excepcion de 32 bits 80386 - Trap Gate)
    dw H_ISRXX_Handler       ; 2 bytes - Offset 31-16 - Segmento de referencia al código de la EXCEPTION 
; Debug Exceptions - Reservada 
ISR01_IDT   EQU $-IDT   
    dq 0x0
; NMI
ISR02_IDT   EQU $-IDT   

    dw L_ISR02_Handler_NMI                      ; 2 bytes - Offset 15-0 - Segmento de referencia al código de la EXCEPTION 
    dw CS_SEL_00                                ; 2 bytes - Selector de segmento de código

    db 00000000b                                ; 1 byte - 000 e indefinido
    db 10001111b                                ; 1 byte - Atributos
                                                    ; P = 1 (Presente en el segmento)
                                                    ; DPL = 00 (Nivel de privilegio priotidad Kernel)
                                                    ; S = 0 (Descriptor de sistema)
                                                    ; TIPO = 1111 (Puerta de Excepcion de 32 bits 80386 - Trap Gate)
    dw H_ISRXX_Handler                          ; 2 bytes - Offset 31-16 - Segmento de referencia al código de la EXCEPTION 
; Breakpoint
ISR03_IDT   EQU $-IDT   
    dw L_ISR03_Handler_BP                       ; 2 bytes - Offset 15-0 - Segmento de referencia al código de la EXCEPTION 
    dw CS_SEL_00                                ; 2 bytes - Selector de segmento de código

    db 00000000b                                ; 1 byte - 000 e indefinido
    db 10001111b                                ; 1 byte - Atributos
                                                    ; P = 1 (Presente en el segmento)
                                                    ; DPL = 00 (Nivel de privilegio priotidad Kernel)
                                                    ; S = 0 (Descriptor de sistema)
                                                    ; TIPO = 1111 (Puerta de Excepcion de 32 bits 80386 - Trap Gate)
    dw H_ISRXX_Handler                           ; 2 bytes - Offset 31-16 - Segmento de referencia al código de la EXCEPTION 
; Overflow
ISR04_IDT   EQU $-IDT   
    dw L_ISR04_Handler_OF                       ; 2 bytes - Offset 15-0 - Segmento de referencia al código de la EXCEPTION 
    dw CS_SEL_00                                ; 2 bytes - Selector de segmento de código

    db 00000000b                                ; 1 byte - 000 e indefinido
    db 10001111b                                ; 1 byte - Atributos
                                                    ; P = 1 (Presente en el segmento)
                                                    ; DPL = 00 (Nivel de privilegio priotidad Kernel)
                                                    ; S = 0 (Descriptor de sistema)
                                                    ; TIPO = 1111 (Puerta de Excepcion de 32 bits 80386 - Trap Gate)
    dw H_ISRXX_Handler                          ; 2 bytes - Offset 31-16 - Segmento de referencia al código de la EXCEPTION 
; BOUND Range Exceeded
ISR05_IDT   EQU $-IDT   
    dw L_ISR05_Handler_BR                       ; 2 bytes - Offset 15-0 - Segmento de referencia al código de la EXCEPTION 
    dw CS_SEL_00                                ; 2 bytes - Selector de segmento de código

    db 00000000b                                ; 1 byte - 000 e indefinido
    db 10001111b                                ; 1 byte - Atributos
                                                    ; P = 1 (Presente en el segmento)
                                                    ; DPL = 00 (Nivel de privilegio priotidad Kernel)
                                                    ; S = 0 (Descriptor de sistema)
                                                    ; TIPO = 1111 (Puerta de Excepcion de 32 bits 80386 - Trap Gate)
    dw H_ISRXX_Handler                          ; 2 bytes - Offset 31-16 - Segmento de referencia al código de la EXCEPTION 
; Invalid Opcode (Undefined Opcode)
ISR06_IDT   EQU $-IDT   
    dw L_ISR06_Handler_UD                       ; 2 bytes - Offset 15-0 - Segmento de referencia al código de la EXCEPTION 
    dw CS_SEL_00                                ; 2 bytes - Selector de segmento de código

    db 00000000b                                ; 1 byte - 000 e indefinido
    db 10001111b                                ; 1 byte - Atributos
                                                    ; P = 1 (Presente en el segmento)
                                                    ; DPL = 00 (Nivel de privilegio priotidad Kernel)
                                                    ; S = 0 (Descriptor de sistema)
                                                    ; TIPO = 1111 (Puerta de Excepcion de 32 bits 80386 - Trap Gate)
    dw H_ISRXX_Handler                          ; 2 bytes - Offset 31-16 - Segmento de referencia al código de la EXCEPTION 
; Device Not Available (No Math Coprocessor)
ISR07_IDT   EQU $-IDT   
    dw L_ISR07_Handler_NM                       ; 2 bytes - Offset 15-0 - Segmento de referencia al código de la EXCEPTION 
    dw CS_SEL_00                                ; 2 bytes - Selector de segmento de código

    db 00000000b                                ; 1 byte - 000 e indefinido
    db 10001111b                                ; 1 byte - Atributos
                                                    ; P = 1 (Presente en el segmento)
                                                    ; DPL = 00 (Nivel de privilegio priotidad Kernel)
                                                    ; S = 0 (Descriptor de sistema)
                                                    ; TIPO = 1111 (Puerta de Excepcion de 32 bits 80386 - Trap Gate)
    dw H_ISRXX_Handler                          ; 2 bytes - Offset 31-16 - Segmento de referencia al código de la EXCEPTION
; Double Fault
ISR08_IDT   EQU $-IDT   
    dw L_ISR08_Handler_DF                       ; 2 bytes - Offset 15-0 - Segmento de referencia al código de la EXCEPTION 
    dw CS_SEL_00                                ; 2 bytes - Selector de segmento de código

    db 00000000b                                ; 1 byte - 000 e indefinido
    db 10001111b                                ; 1 byte - Atributos
                                                    ; P = 1 (Presente en el segmento)
                                                    ; DPL = 00 (Nivel de privilegio priotidad Kernel)
                                                    ; S = 0 (Descriptor de sistema)
                                                    ; TIPO = 1111 (Puerta de Excepcion de 32 bits 80386 - Trap Gate)
    dw H_ISRXX_Handler                          ; 2 bytes - Offset 31-16 - Segmento de referencia al código de la EXCEPTION
; Coprocessor Segment Overrun (reserved)
ISR09_IDT   EQU $-IDT   
    dq 0x0
; Invalid TSS
ISR10_IDT   EQU $-IDT   
    dw L_ISR10_Handler_TS                       ; 2 bytes - Offset 15-0 - Segmento de referencia al código de la EXCEPTION 
    dw CS_SEL_00                                ; 2 bytes - Selector de segmento de código

    db 00000000b                                ; 1 byte - 000 e indefinido
    db 10001111b                                ; 1 byte - Atributos
                                                    ; P = 1 (Presente en el segmento)
                                                    ; DPL = 00 (Nivel de privilegio priotidad Kernel)
                                                    ; S = 0 (Descriptor de sistema)
                                                    ; TIPO = 1111 (Puerta de Excepcion de 32 bits 80386 - Trap Gate)
    dw H_ISRXX_Handler                          ; 2 bytes - Offset 31-16 - Segmento de referencia al código de la EXCEPTION
; Segment Not Present
ISR11_IDT   EQU $-IDT   
    dw L_ISR11_Handler_NP                       ; 2 bytes - Offset 15-0 - Segmento de referencia al código de la EXCEPTION 
    dw CS_SEL_00                                ; 2 bytes - Selector de segmento de código

    db 00000000b                                ; 1 byte - 000 e indefinido
    db 10001111b                                ; 1 byte - Atributos
                                                    ; P = 1 (Presente en el segmento)
                                                    ; DPL = 00 (Nivel de privilegio priotidad Kernel)
                                                    ; S = 0 (Descriptor de sistema)
                                                    ; TIPO = 1111 (Puerta de Excepcion de 32 bits 80386 - Trap Gate)
    dw H_ISRXX_Handler                          ; 2 bytes - Offset 31-16 - Segmento de referencia al código de la EXCEPTION
; Stack-Segment Fault
ISR12_IDT   EQU $-IDT   
    dw L_ISR12_Handler_SS                       ; 2 bytes - Offset 15-0 - Segmento de referencia al código de la EXCEPTION 
    dw CS_SEL_00                                ; 2 bytes - Selector de segmento de código

    db 00000000b                                ; 1 byte - 000 e indefinido
    db 10001111b                                ; 1 byte - Atributos
                                                    ; P = 1 (Presente en el segmento)
                                                    ; DPL = 00 (Nivel de privilegio priotidad Kernel)
                                                    ; S = 0 (Descriptor de sistema)
                                                    ; TIPO = 1111 (Puerta de Excepcion de 32 bits 80386 - Trap Gate)
    dw H_ISRXX_Handler                          ; 2 bytes - Offset 31-16 - Segmento de referencia al código de la EXCEPTION
; General Protection
ISR13_IDT   EQU $-IDT   
    dw L_ISR13_Handler_GP                       ; 2 bytes - Offset 15-0 - Segmento de referencia al código de la EXCEPTION 
    dw CS_SEL_00                                ; 2 bytes - Selector de segmento de código

    db 00000000b                                ; 1 byte - 000 e indefinido
    db 10001111b                                ; 1 byte - Atributos
                                                    ; P = 1 (Presente en el segmento)
                                                    ; DPL = 00 (Nivel de privilegio priotidad Kernel)
                                                    ; S = 0 (Descriptor de sistema)
                                                    ; TIPO = 1111 (Puerta de Excepcion de 32 bits 80386 - Trap Gate)
    dw H_ISRXX_Handler                          ; 2 bytes - Offset 31-16 - Segmento de referencia al código de la EXCEPTION
; Page Fault
ISR14_IDT   EQU $-IDT   
    dw L_ISR14_Handler_PF                       ; 2 bytes - Offset 15-0 - Segmento de referencia al código de la EXCEPTION 
    dw CS_SEL_00                                ; 2 bytes - Selector de segmento de código

    db 00000000b                                ; 1 byte - 000 e indefinido
    db 10001111b                                ; 1 byte - Atributos
                                                    ; P = 1 (Presente en el segmento)
                                                    ; DPL = 00 (Nivel de privilegio priotidad Kernel)
                                                    ; S = 0 (Descriptor de sistema)
                                                    ; TIPO = 1111 (Puerta de Excepcion de 32 bits 80386 - Trap Gate)
    dw H_ISRXX_Handler                          ; 2 bytes - Offset 31-16 - Segmento de referencia al código de la EXCEPTION
; (Intel reserved. Do not use.)
ISR15_IDT   EQU $-IDT   
    dq 0x0
; x87 FPU Floating-Point Error (Math Fault)
ISR16_IDT   EQU $-IDT   
    dw L_ISR16_Handler_MF                       ; 2 bytes - Offset 15-0 - Segmento de referencia al código de la EXCEPTION 
    dw CS_SEL_00                                ; 2 bytes - Selector de segmento de código

    db 00000000b                                ; 1 byte - 000 e indefinido
    db 10001111b                                ; 1 byte - Atributos
                                                    ; P = 1 (Presente en el segmento)
                                                    ; DPL = 00 (Nivel de privilegio priotidad Kernel)
                                                    ; S = 0 (Descriptor de sistema)
                                                    ; TIPO = 1111 (Puerta de Excepcion de 32 bits 80386 - Trap Gate)
    dw H_ISRXX_Handler                          ; 2 bytes - Offset 31-16 - Segmento de referencia al código de la EXCEPTION
; Alignment Check
ISR17_IDT   EQU $-IDT   
    dw L_ISR17_Handler_AC                       ; 2 bytes - Offset 15-0 - Segmento de referencia al código de la EXCEPTION 
    dw CS_SEL_00                                ; 2 bytes - Selector de segmento de código

    db 00000000b                                ; 1 byte - 000 e indefinido
    db 10001111b                                ; 1 byte - Atributos
                                                    ; P = 1 (Presente en el segmento)
                                                    ; DPL = 00 (Nivel de privilegio priotidad Kernel)
                                                    ; S = 0 (Descriptor de sistema)
                                                    ; TIPO = 1111 (Puerta de Excepcion de 32 bits 80386 - Trap Gate)
    dw H_ISRXX_Handler                          ; 2 bytes - Offset 31-16 - Segmento de referencia al código de la EXCEPTION
; Machine Check
ISR18_IDT   EQU $-IDT   
    dw L_ISR18_Handler_MC                       ; 2 bytes - Offset 15-0 - Segmento de referencia al código de la EXCEPTION 
    dw CS_SEL_00                                ; 2 bytes - Selector de segmento de código

    db 00000000b                                ; 1 byte - 000 e indefinido
    db 10001111b                                ; 1 byte - Atributos
                                                    ; P = 1 (Presente en el segmento)
                                                    ; DPL = 00 (Nivel de privilegio priotidad Kernel)
                                                    ; S = 0 (Descriptor de sistema)
                                                    ; TIPO = 1111 (Puerta de Excepcion de 32 bits 80386 - Trap Gate)
    dw H_ISRXX_Handler                          ; 2 bytes - Offset 31-16 - Segmento de referencia al código de la EXCEPTION
; SIMD Floating-Point Exception
ISR19_IDT   EQU $-IDT   
    dw L_ISR19_Handler_XM                       ; 2 bytes - Offset 15-0 - Segmento de referencia al código de la EXCEPTION 
    dw CS_SEL_00                                ; 2 bytes - Selector de segmento de código

    db 00000000b                                ; 1 byte - 000 e indefinido
    db 10001111b                                ; 1 byte - Atributos
                                                    ; P = 1 (Presente en el segmento)
                                                    ; DPL = 00 (Nivel de privilegio priotidad Kernel)
                                                    ; S = 0 (Descriptor de sistema)
                                                    ; TIPO = 1111 (Puerta de Excepcion de 32 bits 80386 - Trap Gate)
    dw H_ISRXX_Handler                          ; 2 bytes - Offset 31-16 - Segmento de referencia al código de la EXCEPTION
; Virtualization Exception (20) hasta Intel reserver. Do not use (31) todo reservado.
ISR20to31_idt EQU $-IDT
    times 12 dq 0x0  
; IRQ0 - Timer tick
ISR32_IRQ_0 EQU $-IDT
    dw L_IRQ00_Handler                          ; 2 bytes - Offset 15-0 - Segmento de referencia al código de la EXCEPTION 
    dw CS_SEL_00                                ; 2 bytes - Selector de segmento de código

    db 00000000b                                ; 1 byte - 000 e indefinido
    db 10001110b                                ; 1 byte - Atributos
                                                    ; P = 1 (Presente en el segmento)
                                                    ; DPL = 00 (Nivel de privilegio priotidad Kernel)
                                                    ; S = 0 (Descriptor de sistema)
                                                    ; TIPO = 1110 (Puerta de Interrupción de 32 bits 80386 - Int. Gate)
    dw H_ISRXX_Handler                          ; 2 bytes - Offset 31-16 - Segmento de referencia al código de la EXCEPTION
; IRQ1 - KBI (Keyboard Interrupt)
ISR33_IRQ_1 EQU $-IDT
    dw L_IRQ01_Handler                          ; 2 bytes - Offset 15-0 - Segmento de referencia al código de la EXCEPTION 
    dw CS_SEL_00                                ; 2 bytes - Selector de segmento de código

    db 00000000b                                ; 1 byte - 000 e indefinido
    db 10001110b                                ; 1 byte - Atributos
                                                    ; P = 1 (Presente en el segmento)
                                                    ; DPL = 00 (Nivel de privilegio priotidad Kernel)
                                                    ; S = 0 (Descriptor de sistema)
                                                    ; TIPO = 1110 (Puerta de Interrupción de 32 bits 80386 - Int. Gate)
    dw H_ISRXX_Handler                          ; 2 bytes - Offset 31-16 - Segmento de referencia al código de la EXCEPTION

ISR34to46_idt EQU $-IDT   
    times 13 dq 0x0000  ;Usuario
       
ISER47to127_idt EQU $ - IDT
    times 81 dq 0x0000

; Compuerta de interrupción de system call.
ISER128_idt EQU $ - IDT
    dw L_ISR128_Handler_SC              ;Offset 15-0
    dw CS_SEL_00                       ;Selector.
    db 0x00                             ;No usado.
    db 0xEE                             ;Compuerta de interrupción. DPL = 11
    dw H_ISRXX_Handler                  ;Offset 31-16


IDT_LENGTH EQU $-IDT
_idtr_32:
    dw IDT_LENGTH-1
    dd IDT       ; Base de la IDT donde termina la GDT para que esten una arriba de la otra en ROM


