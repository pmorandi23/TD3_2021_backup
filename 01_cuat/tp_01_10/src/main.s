USE32

SECTION .kernel32

EXTERN __DATA_VMA
EXTERN limpiar_buffer
EXTERN msg_bienvenida_VGA
EXTERN __VGA_VMA
EXTERN __VGA_PHY
EXTERN limpiar_VGA
;--------------GLOBAL----------------------
GLOBAL kernel32_code_size
GLOBAL kernel32_init
GLOBAL memoria_buffer_reservada
GLOBAL contador_timer
GLOBAL resultado_promedio
GLOBAL dir_lineal_page_fault
GLOBAL error_code_PF
GLOBAL dir_phy_dinamica
GLOBAL page_fault_msg
GLOBAL page_fault_msg_2
GLOBAL page_fault_msg_3
GLOBAL page_fault_msg_4
GLOBAL page_fault_msg_5
GLOBAL page_fault_msg_6
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
    ; -> Inicializo el buffer del teclado.
    push    ebp
    mov     ebp, esp
    push dword memoria_buffer_reservada
    call limpiar_buffer                     
    leave
    ; -> Escribo la pantalla con mensaje fijo.
    push    ebp
    mov     ebp, esp
    push    __VGA_VMA
    call msg_bienvenida_VGA                     
    leave


main:
    jmp main
guard:
    hlt                                     ; Aguardo por interrupciones / excepciones
    jmp guard


kernel32_end:
    

;-------- VARIABLES DE DATOS PARA PROPOSITO GENERAL----
SECTION .data
variables_globales:
    memoria_buffer_reservada    resb 19             ; Reservo para buffer[0-16] + head[17] + tail[18] + cantidad[19] 

    contador_timer              resw 1              ; Contador del timer

    resultado_promedio          resq 1              ; Resultado del promedio cada 500ms de los dígitos en tabla.

    dir_lineal_page_fault       resd 1              ; Dir. Lineal que produjo una Page Fault Exception.

    error_code_PF               resd 1              ; Código de error del #PF

    dir_phy_dinamica            dd 0x0A000000       ; Dir. Phy. dinámica para salvar el #PF
mensajes_error:
    page_fault_msg              db "-----PAGE FAULT-----",0
    page_fault_msg_2            db "Dir. VMA = 0x",0
    page_fault_msg_3            db "Error Code: ",0
    page_fault_msg_4            db "Paginacion OFF. Se puede paginar con VMA del CR2",0
    page_fault_msg_5            db "Paginacion exitosa.",0
    page_fault_msg_6            db "PTE y PDE (Si no existia, se creo una nueva PT.) escritos exitosamente con VMA del CR2 y +4K de la dir_phy_dinamica.",0