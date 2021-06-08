USE32

SECTION .kernel32

GLOBAL kernel32_code_size
GLOBAL kernel32_init
EXTERN CS_SEL_32
EXTERN __TECLADO_ISR_VMA
EXTERN pool_teclado

kernel21_code_size EQU kernel32_end-kernel32_init

; Aquí en el kernel se puede paginar, setear Timer, manejar interrupciones.
kernel32_init:

    ;xchg    bx, bx
guard:
    hlt         ; Aguardo por interrupciones / excepciones
    jmp guard


kernel32_end:
    