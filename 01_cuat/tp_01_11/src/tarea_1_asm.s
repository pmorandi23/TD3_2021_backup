; ----------------EXTERN------------
EXTERN ejecutar_tarea_1
EXTERN __DIGITS_TABLE_VMA
; -----------EXTERN VARIABLES-------

;-----------------EXTERN EQU--------
EXTERN SYS_P_VGA
; ----------------GLOBAL------------
GLOBAL tarea_1_asm
GLOBAL resultado_promedio

; -------------RODATA--------------
SECTION .rodata_tarea1

;---------------BSS----------------
SECTION .bss_tarea1

; ---------------DATA--------------
SECTION .data_tarea1

resultado_promedio resq 1   ; Resultado del promedio de dig. de 64 bits


; --------------TEXT---------------
SECTION .functions_tarea_1

tarea_1_asm:
    ; La tarea tiene 10ms para correr y el tiempo de sobra espera al scheduler
    ;xchg bx, bx

    call ejecutar_tarea_1

    ;xchg bx, bx

    mov edi, resultado_promedio         ; Numero de 64 bits 
    mov edx, 1                          ; Fila VGA
    mov ecx, 79                         ; Columna VGA
    mov eax, SYS_P_VGA                  ; Syscall de escritura VGA
    mov ebx, 4                          ; tamaño del dato    1 = byte, 2 = word, 3 = dword, 4 = qword
    int 0x80

loop_tarea_1_asm:

    jmp loop_tarea_1_asm