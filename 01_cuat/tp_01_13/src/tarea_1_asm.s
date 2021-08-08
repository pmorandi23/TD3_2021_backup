%include "inc/processor-flags.h" 

; ----------------EXTERN------------
EXTERN ejecutar_tarea_1
EXTERN __DIGITS_TABLE_VMA

; -----------EXTERN VARIABLES-------

;-----------------EXTERN EQU--------
;EXTERN SYS_P_VGA
; ----------------GLOBAL------------
GLOBAL tarea_1_asm
GLOBAL resultado_promedio
GLOBAL TAREA1_DIGITS_TABLE
;---------------EQU----------------
CANTIDAD_DIGITOS    EQU     10      ; Cantidad de dígitos en la tabla     

; -------------RODATA--------------
SECTION .rodata_tarea1
;tarea_1_msg              db "- Tarea 1: Promedio",0

;---------------BSS----------------
SECTION .bss_tarea1

resultado_promedio         resq    1                    ; Resultado del promedio de dig. de 64 bits
TAREA1_DIGITS_TABLE        resq    CANTIDAD_DIGITOS     ; Tabla de dígitos de la tarea 1

; ---------------DATA--------------
SECTION .data_tarea1

CANTIDAD_BYTES_TABLA        db    80


; --------------TEXT---------------
SECTION .functions_tarea_1

tarea_1_asm:
    ; La tarea tiene 10ms para correr y el tiempo de sobra espera al scheduler
    ; -> Sumatoria de dígitos de 64b y cálculo del promedio 
    
    ; -> Llamo a la syscall read para copiar la tabla de digitos a la tarea
    mov     edi, TAREA1_DIGITS_TABLE
    mov     esi, __DIGITS_TABLE_VMA
    mov     byte cl, [CANTIDAD_BYTES_TABLA]
    mov     eax, SYS_READ
    int 0x80

    mov     eax, TAREA1_DIGITS_TABLE    ; Principio de la tabla


    call ejecutar_tarea_1

    ; -> Muestro el resultado del promedio en pantalla
    mov edi, resultado_promedio         ; Numero de 64 bits 
    mov edx, 1                          ; Fila VGA
    mov ecx, 79                         ; Columna VGA
    mov eax, SYS_PRINT_VGA                  ; Syscall de escritura VGA
    mov ebx, 4                          ; tamaño del dato    1 = byte, 2 = word, 3 = dword, 4 = qword
    int 0x80

    ; -> Pongo al CPU en halt llamando a int 0x80
    mov eax, SYS_HALT                 
    int 0x80 

    jmp tarea_1_asm

 