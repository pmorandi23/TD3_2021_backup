%include "inc/processor-flags.h" 

; ----------------EXTERN------------
EXTERN ejecutar_tarea_3
;EXTERN POINTER_VMA_DIGITS_TABLE
EXTERN __DIGITS_TABLE_VMA
; ----------------GLOBAL------------
GLOBAL tarea_3_asm

CANTIDAD_DIGITOS    EQU     10      ; Cantidad de dígitos en la tabla     

; -------------RODATA--------------
SECTION .rodata_tarea3
;tarea_3_msg              db "- Tarea 3: Suma SIMD 2",0
;-------------BSS------------------
SECTION .bss_tarea3

TAREA3_DIGITS_TABLE        resq    CANTIDAD_DIGITOS     ; Tabla de dígitos de la tarea 1

; ---------------DATA-------------
SECTION .data_tarea3
suma_SIMD_words             dq    0
CANTIDAD_BYTES_TABLA        db    80

; --------------TEXT---------------
SECTION .functions_tarea_3

tarea_3_asm:
    ; La tarea tiene 10ms para correr y el tiempo de sobra espera al scheduler
    
    xor     eax, eax                        ; Inicializo eax
    xor     ebx, ebx                        ; Inicializo ebx
    pxor    mm0, mm0                        ; Inicializo registro mm0          

    ; -> Llamo a la syscall read para copiar la tabla de digitos a la tarea
    mov     edi, TAREA3_DIGITS_TABLE        ; Destino
    mov     esi, __DIGITS_TABLE_VMA         ; Fuente
    mov     byte cl, [CANTIDAD_BYTES_TABLA] ; Tamaño
    mov     eax, SYS_READ                   ; Syscall de lectura
    int 0x80

    mov     eax, TAREA3_DIGITS_TABLE    ; Principio de la tabla

loop_tabla:
    paddq   mm0, [eax]                      ; Suma en SIMD de desborde en qword
    add     eax, 8                          ; Siguiente qword
    inc     ebx                             ; Sumo al contador
    cmp     ebx, CANTIDAD_DIGITOS           ; Me quedo hasta recorrer la tabla
    jne     loop_tabla

    movq    qword [suma_SIMD_words], mm0     ;Guardo el valor de la suma saturada en words

    ; -> Muestro el resultado de la suma SIMD en pantalla
    mov     edi, suma_SIMD_words            ; Numero de 64 bits 
    mov     edx, 7                          ; Fila VGA
    mov     ecx, 79                         ; Columna VGA
    mov     eax, SYS_PRINT_VGA              ; Syscall de escritura VGA
    mov     ebx, 4                          ; 1 = byte, 2 = word, 3 = dword, 4 = qword
    int 0x80
    ; -> Pongo al CPU en halt llamando a int 0x80
    mov     eax, SYS_HALT                 
    int 0x80

    jmp tarea_3_asm