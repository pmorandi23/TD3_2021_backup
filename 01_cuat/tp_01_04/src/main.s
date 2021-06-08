USE32

SECTION .kernel32

GLOBAL kernel32_code_size
GLOBAL kernel32_init

kernel21_code_size EQU kernel32_end-kernel32_init

; Aquí en el kernel se puede paginar, setear Timer, manejar interrupciones.
kernel32_init:

.guard:
    hlt
    jmp .guard

kernel32_end:
    