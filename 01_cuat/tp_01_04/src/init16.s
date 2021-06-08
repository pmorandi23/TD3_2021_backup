USE16

SECTION .ROM_init

%include "inc/processor-flags.h" 

EXTERN CS_SEL_32
EXTERN _gdtr
EXTERN start32_launcher
EXTERN __STACK_START_16
EXTERN __STACK_END_16

GLOBAL start16

start16:
    test    eax, 0x0 ; Verifico que el uP no este en fallo
    jne     fault_end 
    xor     eax, eax ; Pongo en 0 al acumulador
    mov     cr3, eax ; Invalidar TLB (se va a utilizar mas en paginación y cache})

    ; ->Seteo 16 bits stack (SI NO ESTABA, NO SE CARGA LA GDT. HAY QUE INICIALIZAR UN STACK EN 16 BITS AUNQUE NO SE USE!)
    mov ax,cs
    mov ds,ax
    mov ax,__STACK_START_16
    mov ss,ax
    mov sp,__STACK_END_16

    ;-> Deshabilitar cache <-
    mov     eax, cr0
    or      eax, (X86_CR0_NW | X86_CR0_CD)
    mov     cr0, eax
    wbinvd    ; Write back and invalidates cache

    xchg    bx, bx ; Breakpoint
    lgdt [_gdtr] ; Carga de la GDT pero sin entrar en MP . [ds:_gtdr] está implícito usando []

    ; -> Establecer el uP en MP (Modo Protegido) <-
    smsw    ax ; Stores the machine status word (bits 0 through 15 of control register CR0) into the destination operand. The destination operand can be a general-purpose register or a memory location.
    or      ax, X86_CR0_PE
    lmsw    ax ; Loads the source operand into the machine status word, bits 0 through 15 of register CR0. The source operand can be a 16-bit general-purpose register or a memory location
    xchg    bx, bx ; Breakpoint. En este punto el uP entró en MP
    jmp     dword CS_SEL_32:start32_launcher ; Salto en memoria a la seccion de codigo de 32 bits.

fault_end:
    hlt
