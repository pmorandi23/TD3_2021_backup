SECTION .sys_idt_table_32

GLOBAL _idtr

EXTERN __TECLADO_ISR_VMA
EXTERN CS_SEL_32

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
EXTERN L_IRQ01_Handler
; Parte alta de las direcciones de los Handlers
H_ISRXX_Handler     EQU 0x0010

; Cada descriptor tiene 8 bytes.
IDT:
; Divide Error
ISR00_IDT   EQU $-IDT   
    dw L_ISR00_Handler_DE                       ; 2 bytes - Offset 15-0 - Segmento de referencia al código de la EXCEPTION 

    dw CS_SEL_32                                ; 2 bytes - Selector de segmento de código

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
    dw CS_SEL_32                                ; 2 bytes - Selector de segmento de código

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
    dw CS_SEL_32                                ; 2 bytes - Selector de segmento de código

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
    dw CS_SEL_32                                ; 2 bytes - Selector de segmento de código

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
    dw CS_SEL_32                                ; 2 bytes - Selector de segmento de código

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
    dw CS_SEL_32                                ; 2 bytes - Selector de segmento de código

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
    dw CS_SEL_32                                ; 2 bytes - Selector de segmento de código

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
    dw CS_SEL_32                                ; 2 bytes - Selector de segmento de código

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
    dw CS_SEL_32                                ; 2 bytes - Selector de segmento de código

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
    dw CS_SEL_32                                ; 2 bytes - Selector de segmento de código

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
    dw CS_SEL_32                                ; 2 bytes - Selector de segmento de código

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
    dw CS_SEL_32                                ; 2 bytes - Selector de segmento de código

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
    dw CS_SEL_32                                ; 2 bytes - Selector de segmento de código

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
    dw CS_SEL_32                                ; 2 bytes - Selector de segmento de código

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
    dw CS_SEL_32                                ; 2 bytes - Selector de segmento de código

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
    dw CS_SEL_32                                ; 2 bytes - Selector de segmento de código

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
    dw CS_SEL_32                                ; 2 bytes - Selector de segmento de código

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
    dq 0x0
; IRQ1 - KBI (Keyboard Interrupt)
ISR32_IRQ_1 EQU $-IDT
    dw L_IRQ01_Handler                          ; 2 bytes - Offset 15-0 - Segmento de referencia al código de la EXCEPTION 
    dw CS_SEL_32                                ; 2 bytes - Selector de segmento de código

    db 00000000b                                ; 1 byte - 000 e indefinido
    db 10001110b                                ; 1 byte - Atributos
                                                    ; P = 1 (Presente en el segmento)
                                                    ; DPL = 00 (Nivel de privilegio priotidad Kernel)
                                                    ; S = 0 (Descriptor de sistema)
                                                    ; TIPO = 1110 (Puerta de Interrupción de 32 bits 80386 - Int. Gate)
    dw H_ISRXX_Handler                          ; 2 bytes - Offset 31-16 - Segmento de referencia al código de la EXCEPTION

ISR32_IRQ_2_15 EQU $-IDT   
    times 13 dq 0x0000  ;Usuario


IDT_LENGTH EQU $-IDT
_idtr:
    dw IDT_LENGTH-1
    dd IDT       ; Base de la IDT donde termina la GDT para que esten una arriba de la otra en ROM


