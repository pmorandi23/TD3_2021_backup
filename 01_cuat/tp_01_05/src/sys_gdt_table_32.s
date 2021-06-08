SECTION .sys_tables_progbits


EXTERN  EXCEPTION_DUMMY
EXTERN __SYS_TABLES_LMA
GLOBAL  CS_SEL_16
GLOBAL  CS_SEL_32
GLOBAL  DS_SEL_32
GLOBAL  _gdtr



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
DS_SEL_32      equ $-GDT       ;0X20
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


_gdtr:
    dw GDT_LENGTH-1
    ;dd 0x000FFD00 ; Base de la GDT en la section sys_tables. No van todas FFF al principio por el shadow.  
    dd __SYS_TABLES_LMA ; Base de la GDT en la section sys_tables. Use o32 cuando la cargo en init16.  