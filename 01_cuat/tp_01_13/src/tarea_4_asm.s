; ----------------EXTERN------------
EXTERN ejecutar_tarea_4


; ----------------GLOBAL------------
GLOBAL tarea_4_asm


; -------------RODATA--------------
SECTION .rodata_tarea4
dummy_t4    db  1
;-------------BSS------------------
SECTION .bss_tarea4

; ---------------DATA-------------
SECTION .data_tarea4

; --------------TEXT---------------
SECTION .functions_tarea_4

tarea_4_asm:

    ; La tarea tiene 10ms para correr y el tiempo de sobra espera al scheduler
    ;call ejecutar_tarea_4
    ;xchg bx, bx

loop_tarea_4_asm:

    hlt

    jmp loop_tarea_4_asm