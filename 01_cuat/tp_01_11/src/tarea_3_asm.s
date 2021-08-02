; ----------------EXTERN------------
EXTERN ejecutar_tarea_3


; ----------------GLOBAL------------
GLOBAL tarea_3_asm


; -------------RODATA--------------
SECTION .rodata_tarea3

;-------------BSS------------------
SECTION .bss_tarea3

; ---------------DATA-------------
SECTION .data_tarea3

; --------------TEXT---------------
SECTION .functions_tarea_3

tarea_3_asm:
    ; La tarea tiene 10ms para correr y el tiempo de sobra espera al scheduler
    call ejecutar_tarea_3

    ;xchg bx, bx

loop_tarea_3_asm:


    jmp loop_tarea_3_asm