
USE16
GLOBAL _gdt
GLOBAL KDS_4Gbyte
GLOBAL _4G_Data_sel
GLOBAL KCS_4Gbyte
GLOBAL _4G_Code_sel
GLOBAL UDS_4Gbyte
GLOBAL _4G_UData_sel
GLOBAL UCS_4Gbyte
GLOBAL _4G_UCode_sel
GLOBA gdt_size

section .sys_tables

ALIGN 8
gdt:
            resb	8	;NULL Descriptor. Dejamos 8 bytes sin usar.

;Selector 1: Segmento de datos de 4 Gbyte DPL=00. Este segmento se mapeará sobre el
;espacio de memoria, abarcando todo el rango de direccionamiento físico de M.P.
_4G_Data_sel	equ	$-gdt	;Calcula dinámicamente el selector del Segmento 
				;de datos de 4 Gbyte.
KDS_4Gbyte:
	dw 0xffff       ;limite 15-0
	dw 0x0000       ;base 15-0
	db 0x00			;base 23.16
	db 10010010b    ;Presente, Segmento Datos Read Write
	db 0xCF			;G = 1, D/B = 1, y limite 0Fh
	db 0x00         ;base 31.24

;Selector 2: Segmento de código de 4 Gbyte DPL=00. Este segmento se mapeará sobre el
;espacio de memoria, abarcando todo el rango de direccionamiento físico de M.P.
_4G_Code_sel	equ	$-gdt	;Calcula dinámicamente el slector del Segmento 
				;de código de 4 Gbyte.
KCS_4Gbyte:
	dw 0xffff	;limite 15.00
	dw 0x0000	;base 15.00
	db 0x00		;base 23.16
	db 10011010b    ;Presente Segmento código no conforming Readable
	db 0xCF		;G = 1, D/B = 1, y limite 0Fh
	db 0x00		;base 31.24

;Selector 3: Segmento de datos de 4 Gbyte DPL=11. Este segmento se mapeará sobre el
;espacio de memoria, abarcando todo el rango de direccionamiento físico de M.P.
_4G_UData_sel	equ	($-gdt)|3	;Calcula dinámicamente el selector del
					;Segmento de datos de 4 Gbyte.
UDS_4Gbyte:
	dw 0xffff       ;limite 15-0
	dw 0x0000       ;base 15-0
	db 0x00		;base 23.16
	db 11110010b    ;Presente, Segmento Datos Read Write
	db 0xCF		;G = 1, D/B = 1, y limite 0Fh
	db 0x00          ;base 31.24

;Selector 4: Segmento de código de 4 Gbyte DPL=11. Este segmento se mapeará sobre el
;espacio de memoria, abarcando todo el rango de direccionamiento físico de M.P.
_4G_UCode_sel	equ	($-gdt)|3	;Calcula dinámicamente el selector del 
					;Segmento de código de 4 Gbyte.
UCS_4Gbyte:
	dw 0xffff	;limite 15.00
    dw 0x0000	;base 15.00
    db 0x00		;base 23.16
    db 11111010b    ;Presente Segmento código no conforming Readable
    db 0xCF		;G = 1, D/B = 1, y limite 0Fh
    db 0x00		;base 31.24
gdt_size	equ	$-gdt	;calcula dinámicamente el tamaño de la gdt