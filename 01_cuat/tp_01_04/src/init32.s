USE32

SECTION .start32

%include "inc/processor-flags.h" 


EXTERN DS_SEL
EXTERN __STACK_END_32
EXTERN __STACK_SIZE_32
EXTERN CS_SEL_32
EXTERN kernel32_init
EXTERN __KERNEL_32_LMA
EXTERN __codigo_kernel32_size
EXTERN __fast_memcpy
EXTERN __fast_memcpy_rom
EXTERN kernel32_code_size
EXTERN __functions_size
EXTERN __FUNCTIONS_LMA
EXTERN __KERNEL_32_VMA
EXTERN __FUNCTIONS_VMA

GLOBAL start32_launcher

start32_launcher:
    xchg    bx, bx ; Breakpoint. Estoy en 32 bits
    ; -> Inicializar los selectores de datos
    mov     ax, DS_SEL ; Selector de la GDT de datos de 32 bits FLAT. Ahora puedo acceder a todos los datos de toda la memoria.
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
    xchg    bx, bx ; Breakpoint
    ; -> Desempaquetamiento de la ROM (copia de las funciones a RAM)
    push    ebp
    mov     ebp, esp ; Genero el STACK FRAME
    ; -> Paso argumentos y llamo memcopy 
    push    __functions_size
    push    __FUNCTIONS_VMA
    push    __FUNCTIONS_LMA
    call    __fast_memcpy_rom
    xchg    bx, bx ; Breakpoint
    leave
    cmp     eax, 1 ; Analizo el valor de retorno de memcopy (1 Exito , 0 Fallo)
    jne     .guard
    xchg    bx, bx ; Breakpoint
    ; -> Desempaquetamiento de la ROM (copia del kernel a RAM)
    push    ebp
    mov     ebp, esp 
    push    __codigo_kernel32_size
    push    __KERNEL_32_VMA
    push    __KERNEL_32_LMA
    call    __fast_memcpy_rom
    xchg    bx, bx ; Breakpoint
    leave
    cmp     eax, 1 ; Analizo el valor de retorno de memcopy (1 Exito , 0 Fallo)
    jne     .guard
    xchg    bx, bx ; Breakpoint
    jmp CS_SEL_32:kernel32_init ; Salto en memoria a la sección del núcleo

.guard:
    hlt




