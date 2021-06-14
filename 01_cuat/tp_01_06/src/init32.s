USE32

SECTION .start32

%include "inc/processor-flags.h" 

; Selectores de segmento
EXTERN CS_SEL_32
EXTERN DS_SEL_32_prim
; Stack 32 bits
EXTERN __STACK_END_32
EXTERN __STACK_SIZE_32
; Etiquetas externas
EXTERN kernel32_init
EXTERN __fast_memcpy
EXTERN __fast_memcpy_rom
EXTERN init_pic
EXTERN _idtr_32
EXTERN _gdtr_32
EXTERN init_timer
EXTERN init_teclado
; Direcciones LMA
EXTERN __KERNEL_32_LMA
EXTERN __TECLADO_ISR_LMA
EXTERN __FUNCTIONS_LMA
EXTERN __SYS_TABLES_LMA
EXTERN __DATA_LMA
; Direcciones VMA
EXTERN __KERNEL_32_VMA
EXTERN __FUNCTIONS_VMA
EXTERN __TECLADO_ISR_VMA
EXTERN __SYS_TABLES_VMA
EXTERN __DATA_VMA
; Tamaños de códigos
EXTERN __codigo_kernel32_size
EXTERN __functions_size
EXTERN __handlers_32_size
EXTERN __sys_tables_size
EXTERN __data_size
; Etiquetas globales
GLOBAL start32_launcher

start32_launcher:
    ;xchg    bx, bx ; Breakpoint. Estoy en 32 bits
    ; -> Inicializar los selectores de datos
    mov     ax, DS_SEL_32_prim ; Selector de la GDT de datos de 32 bits FLAT. Ahora puedo acceder a todos los datos de toda la memoria.
    mov     ds, ax
    mov     es, ax
    mov     gs, ax
    mov     fs, ax
    ; -> Inicializar la pila en 32 bits
    mov     ss, ax
    mov     esp, __STACK_END_32
    xor     eax, eax
    ; -> Limpio la pila
    mov     ecx, __STACK_SIZE_32 ; Cargo el tamaño del stack en el registro counter.
.stack_init:
    push    eax ; Pusheo ceros en el stack.
    loop    .stack_init
    mov     esp, __STACK_END_32 ; Lo apunto al final
    ; -> Desempaquetamiento de la ROM (copia de las funciones a RAM)
    push    ebp
    mov     ebp, esp ; Genero el STACK FRAME
    ; -> Paso argumentos y llamo memcopy 
    push    __functions_size
    push    __FUNCTIONS_VMA
    push    __FUNCTIONS_LMA
    call    __fast_memcpy_rom
    leave
    cmp     eax, 1 ; Analizo el valor de retorno de memcopy (1 Exito , 0 Fallo)
    jne     .guard
    ; -> Desempaquetamiento de la ROM (copia del kernel a RAM)
    push    ebp
    mov     ebp, esp 
    push    __codigo_kernel32_size
    push    __KERNEL_32_VMA
    push    __KERNEL_32_LMA
    call    __fast_memcpy
    leave
    cmp     eax, 1 ; Analizo el valor de retorno de memcopy (1 Exito , 0 Fallo)
    jne     .guard
    ; -> Desempaquetamiento de la ROM (copia de los handlers Teclado + ISR a RAM)
    push    ebp
    mov     ebp, esp 
    push    __handlers_32_size
    push    __TECLADO_ISR_VMA
    push    __TECLADO_ISR_LMA
    call    __fast_memcpy
    leave
    cmp     eax, 1 ; Analizo el valor de retorno de memcopy (1 Exito , 0 Fallo)
    jne     .guard
    ; -> Desempaquetamiento de la ROM (copia de datos de ROM a RAM)
    push    ebp
    mov     ebp, esp 
    push    __data_size
    push    __DATA_VMA
    push    __DATA_LMA
    call    __fast_memcpy
    leave
    cmp     eax, 1 ; Analizo el valor de retorno de memcopy (1 Exito , 0 Fallo)
    jne     .guard
    ; -> Desempaquetamiento de la ROM (copia de las tablas de sistema (GDT e IDT) a RAM)
    push    ebp
    mov     ebp, esp 
    push    __sys_tables_size
    push    __SYS_TABLES_VMA
    push    __SYS_TABLES_LMA
    call    __fast_memcpy
    leave
    cmp     eax, 1 ; Analizo el valor de retorno de memcopy (1 Exito , 0 Fallo)
    jne     .guard
    ;-> Cargo la IDT y la GDT ya copiada en RAM
    lgdt [_gdtr_32]
    lidt [_idtr_32]  
    ; -> Init PIC , IRQ y config. Timer y teclado
    call init_teclado       ; Inicializo controlador de teclado
    call init_timer         ;Configuro Timer tick para 100ms

    call init_pic           ; Inicializo los PICs e interrupciones de Timer y Teclado

    sti                     ; Habilitación de las Interrupciones

    jmp CS_SEL_32:kernel32_init ; Salto en memoria a la sección del núcleo

.guard:
    hlt
    jmp .guard




