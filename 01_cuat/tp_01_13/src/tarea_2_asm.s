%include "inc/processor-flags.h" 

; -----------EXTERN FUNCIONES------------
EXTERN ejecutar_tarea_2
; -----------EXTERN VARIABLES------------
;EXTERN POINTER_VMA_DIGITS_TABLE
EXTERN __DIGITS_TABLE_VMA
; ----------------GLOBAL------------
GLOBAL tarea_2_asm
GLOBAL tarea_2_AC_generate

; ---------------EQU-----------------
CANTIDAD_DIGITOS    EQU     10      ; Cantidad de dígitos en la tabla     

; -------------RODATA--------------
SECTION .rodata_tarea2
;tarea_2_msg              db "- Tarea 2: Suma SIMD 1",0

;-------------BSS------------------
SECTION .bss_tarea2

TAREA2_DIGITS_TABLE        resq    CANTIDAD_DIGITOS     ; Tabla de dígitos de la tarea 1

; ---------------DATA-------------
SECTION .data_tarea2

suma_SIMD_words             dq    0
CANTIDAD_BYTES_TABLA        db    80

; --------------TEXT---------------
SECTION .functions_tarea_2

tarea_2_asm:
    ; La tarea tiene 10ms para correr y el tiempo de sobra espera al scheduler

    xor     eax, eax                        ; Inicializo eax
    xor     ebx, ebx                        ; Inicializo ebx
    xor     ecx, ecx
    pxor    mm0, mm0                        ; Inicializo registro mm0          
    ;mov     eax, POINTER_VMA_DIGITS_TABLE   ; Principio de la tabla

    ; -> Llamo a la syscall read para copiar la tabla de digitos a la tarea
    mov     edi, TAREA2_DIGITS_TABLE
    mov     esi, __DIGITS_TABLE_VMA
    mov     byte cl, [CANTIDAD_BYTES_TABLA]
    mov     eax, SYS_READ
    int 0x80

    mov     eax, TAREA2_DIGITS_TABLE    ; Principio de la tabla

loop_tabla:
    paddusw mm0, [eax]                  ; Suma en SIMD
    add eax, 8                          ; Siguiente qword
    inc ebx                             ; Sumo al contador
    cmp ebx, CANTIDAD_DIGITOS           ; Me quedo hasta recorrer la tabla
    jne loop_tabla

    movq qword [suma_SIMD_words], mm0     ;Guardo el valor de la suma saturada en words

    ; -> Muestro el resultado de la suma SIMD en pantalla
    mov edi, suma_SIMD_words             ; Numero de 64 bits 
    mov edx, 4                          ; Fila VGA
    mov ecx, 79                         ; Columna VGA
    mov eax, SYS_PRINT_VGA                  ; Syscall de escritura VGA
    mov ebx, 4                          ; tamaño del dato    1 = byte, 2 = word, 3 = dword, 4 = qword
    int 0x80
    ; -> Pongo al CPU en halt llamando a int 0x80
    mov eax, SYS_HALT                 
    int 0x80
    jmp tarea_2_asm

tarea_2_AC_generate:
    mov dword[0x01430001],0x6 