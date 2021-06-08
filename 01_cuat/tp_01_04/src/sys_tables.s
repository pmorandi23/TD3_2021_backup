SECTION .sys_tables_progbits


EXTERN  EXCEPTION_DUMMY
GLOBAL  CS_SEL_16
GLOBAL  CS_SEL_32
GLOBAL  DS_SEL
GLOBAL  _gdtr


%define BOOT_SEG 0xF0000
-

; Cada descriptor tiene 8 bytes.
GDT:
NULL_SEL    equ $-GDT       ;0x00
    dq 0x0
CS_SEL_16   equ $-GDT       ;0x08
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

CS_SEL_32   equ $-GDT       ;0x10
    dw 0xFFFF       ;Limit 15-0
    dw 0x0000       ;Base 15-0
    db 0x00         ;Base 23-16
    db 10011001b    ;Atributos:
                    ;P 
                    ;DPL 
                    ;S
                    ;D/C
                    ;ED/C
                    ;R/w
                    ;A
    db 11001111b    ;Limit
                    ;G
                    ;D/B
                    ;L
                    ;AVL
    db 0x00         ;Base
DS_SEL      equ $-GDT       ;0X20
    dw 0xFFFF       ;Limit 15-0
    dw 0x0000       ;Base 15-0
    db 0x00         ;Base 23-16
    db 10010010b    ;Atributos:
                    ;P
                    ;DPL
                    ;S
                    ;D/C
                    ;ED/C
                    ;R/w
                    ;A
    db 11001111b    ;Limit
                    ;G
                    ;D/B
                    ;L
                    ;AVL
    db 0x00         ;Base
GDT_LENGTH EQU $-GDT


_gdtr:
    dw GDT_LENGTH-1
    dd 0x000FFD00 ; Base de la GDT en la section sys_tables. No van todas FFF al principio por el shadow.  