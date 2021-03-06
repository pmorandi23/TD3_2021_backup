USE32

SECTION .kernel32

EXTERN __DATA_VMA
EXTERN limpiar_buffer
EXTERN msg_bienvenida_VGA
EXTERN __VGA_VMA
EXTERN __VGA_PHY
EXTERN limpiar_VGA
EXTERN escribir_mensaje_VGA
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
GLOBAL paginas_creadas
GLOBAL Stack_aux
GLOBAL TSS_aux
GLOBAL CR3_aux
GLOBAL POINTER_VMA_DIGITS_TABLE
;--------------CODE SIZE----------------
kernel21_code_size EQU kernel32_end-kernel32_init
;---------EQU-----------------------------
CANTIDAD_DATOS  EQU 10
LONG_BUFFER     EQU 16

kernel32_init:
    ;xchg bx,bx              ; Llegue al kernel
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
    
    ; -> Escribo título fijo de la tarea 1
    push    ebp
    mov     ebp, esp
    push    1       ; Es ASCII
    push    61      ; Columna VGA
    push    0       ; Fila    VGA
    push    tarea_1_msg
    call    escribir_mensaje_VGA
    leave

    ; -> Escribo título fijo de la tarea 2
    push    ebp
    mov     ebp, esp
    push    1       ; Es ASCII
    push    58      ; Columna VGA
    push    3       ; Fila    VGA
    push    tarea_2_msg
    call    escribir_mensaje_VGA
    leave

    ; -> Escribo título fijo de la tarea 3
    push    ebp
    mov     ebp, esp
    push    1       ; Es ASCII
    push    58      ; Columna VGA
    push    6       ; Fila    VGA
    push    tarea_3_msg
    call    escribir_mensaje_VGA
    leave


main:
    hlt                     ; CPU en HALT aguardando por interrupciones 
    jmp main 

guard:
    hlt                                     
    jmp guard

kernel32_end:
    

;-------- VARIABLES DE DATOS PARA PROPOSITO GENERAL--------------------------
SECTION .data_kernel
variables_globales:
    memoria_buffer_reservada    resb 19             ; Reservo para buffer[0-16] + head[17] + tail[18] + cantidad[19] 

    contador_timer              resb 1              ; Contador del timer

    ;resultado_promedio          resq 1              ; Resultado del promedio cada 500ms de los dígitos en tabla.

    dir_lineal_page_fault       resd 1              ; Dir. Lineal que produjo una Page Fault Exception.

    error_code_PF               resd 1              ; Código de error del #PF

    dir_phy_dinamica            dd 0x0A000000       ; Dir. Phy. dinámica para salvar el #PF

    paginas_creadas             resd  1              ; Cantidad de páginas creadas en el #PF .

    TSS_aux                     resd  1            ; TSS auxiliar para guardar o leer contextos en memoria

    CR3_aux                     resd  1               ; CR3 auxiliar para guardar o leer contextos de memoria

    Stack_aux                   resb 48             ; Stack para leer contexto de memoria 
mensajes_error:
    page_fault_msg              db "-----PAGE FAULT-----",0
    page_fault_msg_2            db "Dir. VMA = 0x",0
    page_fault_msg_3            db "Error Code: ",0
    page_fault_msg_4            db "Paginacion OFF. Se puede paginar con VMA del CR2",0
    page_fault_msg_5            db "Paginacion exitosa.",0
    page_fault_msg_6            db "#PF Handler - Paginas de 4K creadas: ",0
    tarea_1_msg                 db "- Tarea 1: Promedio",0
    tarea_2_msg                 db "- Tarea 2: Suma SIMD 1",0
    tarea_3_msg                 db "- Tarea 3: Suma SIMD 2",0

SECTION .table_digits_64

POINTER_VMA_DIGITS_TABLE        resb (8*10 + 1 + 8 + 8) ;Reservo memoria para 10 dígitos de 8 bytes (64b) + índice de tabla + sumatoria de dígitos + promedio
 
