USE32

SECTION .kernel32

EXTERN __DATA_VMA
EXTERN limpiar_buffer
;--------------GLOBAL----------------------
GLOBAL kernel32_code_size
GLOBAL kernel32_init
GLOBAL memoria_buffer_reservada
GLOBAL contador_timer
GLOBAL resultado_promedio

kernel21_code_size EQU kernel32_end-kernel32_init
;---------EQU-----------------------------
CANTIDAD_DATOS  EQU 10
LONG_BUFFER     EQU 16

kernel32_init:
    ;xchg bx,bx
    xor eax,eax
    xor ebx,ebx
    xor ecx,ecx
    xor edx,edx
    push dword memoria_buffer_reservada
    call limpiar_buffer                     ; Limpio el buffer de teclado para inicializarlo. 
    add esp,4


main:
    jmp main
guard:
    hlt                                     ; Aguardo por interrupciones / excepciones
    jmp guard


kernel32_end:
    

;-------- VARIABLES DE DATOS PARA PROPOSITO GENERAL----
SECTION .data

memoria_buffer_reservada    resb 19             ;Reservo para buffer[0-16] + head[17] + tail[18] + cantidad[19] 

contador_timer              resw 1              ; Contador del timer

resultado_promedio          resq 1              ; Resultado del promedio cada 500ms de los dígitos en tabla.