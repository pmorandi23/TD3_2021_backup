; ----------------EXTERN------------
EXTERN ejecutar_tarea_2


; ----------------GLOBAL------------
GLOBAL tarea_2_asm


; -------------RODATA--------------
SECTION .rodata_tarea2

;-------------BSS------------------
SECTION .bss_tarea2

; ---------------DATA-------------
SECTION .data_tarea2

; --------------TEXT---------------
SECTION .functions_tarea_2

tarea_2_asm:
    ; La tarea tiene 10ms para correr y el tiempo de sobra espera al scheduler
    call ejecutar_tarea_2

    ;xchg bx, bx

loop_tarea_2_asm:


    jmp loop_tarea_2_asm