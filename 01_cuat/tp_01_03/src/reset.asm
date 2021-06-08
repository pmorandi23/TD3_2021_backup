; INICIALIZACIÓN BÁSICA UTILIZANDO EL LINKER
; El mapa de memoria propuesto
 
; Binario copiado                 0x00007C00
; Pila                            0x00068000
; Secuencia inicialización ROM    0xFFFF0000
; Vector de reset                 0xFFFFFFF0

BITS 16
GLOBAL reset_entry
EXTERN init16_entry

SECTION .reset
reset_entry: ;0xFFFFFFF0
    cli; 0xFFFFFFF1 (1 byte de tamaño de instrucción)
    jmp init16_entry; 0xFFFFFFF3 (2 bytes de tamaño de instrucción)
    ALIGN 16; Directiva de pre procesador que rellena con operaciones "nop (0x90)" hasta la próxima dirección multiplo de 16bytes 


