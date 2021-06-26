USE32

%include "inc/functions_asm.h"
%include "inc/processor-flags.h" 

;----------------EXTERN--------------------
EXTERN DS_SEL_32
EXTERN CS_SEL_32
EXTERN __TECLADO_ISR_VMA
EXTERN __VGA_VMA
EXTERN __DIGITS_TABLE_INIT
EXTERN __PAG_DINAMICA_INIT_PHY
EXTERN determinar_tecla_presionada
EXTERN memoria_buffer_reservada
EXTERN contador_handler
EXTERN contador_timer
EXTERN dir_lineal_page_fault
EXTERN dir_phy_dinamica
EXTERN resultado_promedio
EXTERN __DIGITS_TABLE_VMA
EXTERN __PAG_DINAMICA_INIT_VMA
EXTERN __PAGE_TABLES_PHY
EXTERN error_code_PF
EXTERN page_fault_msg
EXTERN page_fault_msg_2
EXTERN page_fault_msg_3
EXTERN page_fault_msg_4
EXTERN page_fault_msg_5
EXTERN page_fault_msg_6
EXTERN escribir_mensaje_VGA
EXTERN limpiar_VGA
EXTERN mostrar_numero32_VGA
EXTERN set_page_table_entry
EXTERN set_dir_page_table_entry
;----------------GLOBAL--------------------
GLOBAL L_ISR00_Handler_DE
GLOBAL L_ISR02_Handler_NMI
GLOBAL L_ISR03_Handler_BP
GLOBAL L_ISR04_Handler_OF
GLOBAL L_ISR05_Handler_BR
GLOBAL L_ISR06_Handler_UD
GLOBAL L_ISR07_Handler_NM
GLOBAL L_ISR08_Handler_DF
GLOBAL L_ISR10_Handler_TS
GLOBAL L_ISR11_Handler_NP
GLOBAL L_ISR12_Handler_SS
GLOBAL L_ISR13_Handler_GP
GLOBAL L_ISR14_Handler_PF
GLOBAL L_ISR16_Handler_MF
GLOBAL L_ISR17_Handler_AC
GLOBAL L_ISR18_Handler_MC
GLOBAL L_ISR19_Handler_XM
GLOBAL L_IRQ00_Handler
GLOBAL L_IRQ01_Handler
;----------------EQU--------------------
VMA_ISR_TECLADO     EQU 0x00100000
; Parte baja de las direcciones de los Handlers 
L_ISR00_Handler_DE  EQU ISR00_Handler_DE    - VMA_ISR_TECLADO 
L_ISR01_Handler_DB  EQU ISR01_Handler_DB    - VMA_ISR_TECLADO 
L_ISR02_Handler_NMI EQU ISR02_Handler_NMI   - VMA_ISR_TECLADO 
L_ISR03_Handler_BP  EQU ISR03_Handler_BP    - VMA_ISR_TECLADO 
L_ISR04_Handler_OF  EQU ISR04_Handler_OF    - VMA_ISR_TECLADO 
L_ISR05_Handler_BR  EQU ISR05_Handler_BR    - VMA_ISR_TECLADO 
L_ISR06_Handler_UD  EQU ISR06_Handler_UD    - VMA_ISR_TECLADO 
L_ISR07_Handler_NM  EQU ISR07_Handler_NM    - VMA_ISR_TECLADO 
L_ISR08_Handler_DF  EQU ISR08_Handler_DF    - VMA_ISR_TECLADO   
L_ISR10_Handler_TS  EQU ISR10_Handler_TS    - VMA_ISR_TECLADO 
L_ISR11_Handler_NP  EQU ISR11_Handler_NP    - VMA_ISR_TECLADO 
L_ISR12_Handler_SS  EQU ISR12_Handler_SS    - VMA_ISR_TECLADO 
L_ISR13_Handler_GP  EQU ISR13_Handler_GP    - VMA_ISR_TECLADO 
L_ISR14_Handler_PF  EQU ISR14_Handler_PF    - VMA_ISR_TECLADO 
L_ISR16_Handler_MF  EQU ISR16_Handler_MF    - VMA_ISR_TECLADO 
L_ISR17_Handler_AC  EQU ISR17_Handler_AC    - VMA_ISR_TECLADO 
L_ISR18_Handler_MC  EQU ISR18_Handler_MC    - VMA_ISR_TECLADO 
L_ISR19_Handler_XM  EQU ISR19_Handler_XM    - VMA_ISR_TECLADO 
L_IRQ00_Handler     EQU IRQ00_Handler       - VMA_ISR_TECLADO
L_IRQ01_Handler     EQU IRQ01_Handler       - VMA_ISR_TECLADO


;----------------SECTION-----------------------
SECTION .teclado_and_ISR
;------------ HANDLER IRQ TIMER---------------------
IRQ00_Handler:
    pushad                                      ;Salvo los registros de uso general.

    ;xchg    bx, bx                              ; Breakpoint
    ;mov eax , [contador_timer]                  ; Si lo quiero hacer en asm... pero sin resetear variable. 
    ;inc eax
    ;mov [contador_timer], eax

    push    ebp
    mov     ebp, esp 
    push contador_timer                         ; Contador del Timer actual              
    push __DIGITS_TABLE_VMA                     ; Dir. de tabla de dígitos
    push resultado_promedio                     ; Resultado del prom. cada 500ms
    call contador_handler                       ; Cada 50 ticks (500ms) ejecuto la tarea 1.
    leave
end_handler_timer:
    mov al, 0x20                                ; ACK de la IRQ para el PIC 
    out 0x20, al
    popad                                       ;Recupero registros
    iret                                        ;Retorno de la IRQ

;----------HANDLER IRQ TECLADO-----------------
IRQ01_Handler:
    pushad                                      ; Guardo todos los registros  para asegurarme que no se rompa el estado actual.
    mov     dl,0x21                             ; Guardo la interrupcion en el registro DX
    xor     eax, eax
    ; ->Leo el puerto
    in      al, PORT_A_8042                     ; Leo el puerto 0x60 (Keyboard Output Buffer Register)
    mov     bl, al                              ; Copio lo leído en otro registro
    and     bl, 0x80                            ; Hago un AND para obtener el bit 7 (BRK)
    cmp     bl, 0x80                            ; Si el bit vale 0 la tecla fue presionada (Make), si es 1 se dejó de presionar (Break)
    jz      end_handler_teclado                 ; Si se dejo de presionar, no la leo. Solo leo cuando se presionada (Make)
    push    dword memoria_buffer_reservada      ; Buffer en VMA
    push    eax                                 ; Tecla presionada.
    call determinar_tecla_presionada
    add     esp, 8

end_handler_teclado:
    ;xchg    bx, bx                              ; Breakpoint
    mov     al, 0x20                             ; ACK de la IRQ para el PIC 
    out     0x20, al
    popad                                        ; Recupero registros
    iret                                         ; Retorno de la IRQ

;-----------HANDLERs DE EXCEPTIONS-------------
;#DE (Divide Error)
ISR00_Handler_DE:
    xchg    bx,bx
    mov     dl,0x00
    hlt

ISR01_Handler_DB:
    xchg    bx,bx
    mov dl,0x01
    hlt

ISR02_Handler_NMI:
    xchg    bx,bx
    mov dl,0x02
    hlt

ISR03_Handler_BP:
    xchg    bx,bx
    mov dl,0x03
    hlt

ISR04_Handler_OF:
    xchg    bx,bx
    mov dl,0x04
    hlt

ISR05_Handler_BR:
    xchg    bx,bx
    mov dl,0x05
    hlt
;#UD (Invalid Opcode Fetch) 
ISR06_Handler_UD:
    xchg    bx,bx
    mov     dl,0x06
    hlt

ISR07_Handler_NM:
    xchg    bx,bx
    mov dl,0x07
    hlt

ISR08_Handler_DF:
    xchg    bx,bx
    mov dl,0x08
    hlt

ISR10_Handler_TS:
    xchg    bx,bx
    mov dl,0x0A
    hlt

ISR11_Handler_NP:
    xchg    bx,bx
    mov dl,0x0B
    hlt

ISR12_Handler_SS:
    xchg    bx,bx
    mov dl,0x0C
    hlt
; Funciono al no tener el CS al retornar de un call
ISR13_Handler_GP:
    xchg    bx,bx
    mov dl,0x0D
    hlt
;-----------------------------------
;----------Page Fault (#PF)---------
;-----------------------------------

;Error code
;The Page Fault sets an error code:
;
; 31              4               0
;+---+--  --+---+---+---+---+---+---+
;|   Reserved   | I | R | U | W | P |
;+---+--  --+---+---+---+---+---+---+
;Length	Name	Description
;P	1 bit	Present	When set, the page fault was caused by a page-protection violation. When not set, it was caused by a non-present page.
;W	1 bit	Write	When set, the page fault was caused by a write access. When not set, it was caused by a read access.
;U	1 bit	User	When set, the page fault was caused while CPL = 3. This does not necessarily mean that the page fault was a privilege violation.
;R	1 bit	Reserved write	When set, one or more page directory entries contain reserved bits which are set to 1. This only applies when the PSE or PAE flags in CR4 are set to 1.
;I	1 bit	Instruction Fetch	When set, the page fault was caused by an instruction fetch. This only applies when the No-Execute bit is supported and enabled.
ISR14_Handler_PF:
    cli                                     ; Deshabilito interrupciones.
    pushad                                  ; Guardo registros.
    mov     ebx, [esp + 32]                 ; Guardo el Error Code. 
    mov     [error_code_PF], ebx
    mov     eax, cr2
    mov     [dir_lineal_page_fault], eax    ; Guardo dir. lineal VMA que falló
    ; -> Limpio pantalla.
    push    ebp
    mov     ebp, esp
    push    __VGA_VMA
    call    limpiar_VGA                     
    leave
    ; -> Escribo mensaje de Page Fault.
    push    ebp
    mov     ebp, esp
    push    1       ; Es ASCII
    push    10      ; Columna VGA
    push    0       ; Fila    VGA
    push    page_fault_msg
    call    escribir_mensaje_VGA
    leave
     ; -> Escribo mensaje "La dir VMA es"
    push    ebp
    mov     ebp, esp
    push    1       ; Es ASCII
    push    10      ; Columna VGA
    push    1       ; Fila    VGA
    push    page_fault_msg_2
    call    escribir_mensaje_VGA
    leave
    ; -> Muestro la dir VMA no mapeada en PHY
    push    ebp
    mov     ebp, esp
    push    30      ; Columna VGA
    push    1       ; Fila VGA
    push    dword[dir_lineal_page_fault]
    call    mostrar_numero32_VGA
    leave
    ; -> Muestro el mensaje "Error Code:"
    push    ebp
    mov     ebp, esp
    push    10      ; Columna VGA
    push    2       ; Fila VGA
    push    page_fault_msg_3
    call    escribir_mensaje_VGA
    leave
    ; -> Muestro el valor del Error Code
    push    ebp
    mov     ebp, esp
    push    30      ; Columna VGA
    push    2       ; Fila VGA
    push    dword[error_code_PF]
    call    mostrar_numero32_VGA
    leave

    ;xchg    bx, bx 
    ; -> Analizo el Error Code
    ; Si es una Pagina no presente (Bit 0 = 0) debe repaginar.
    and ebx, 0x1F   ; Bits 0 - 5 donde tengo los flags.
    cmp ebx, 0x00
    je pag_no_presente
    cmp ebx, 0x02
    je write_access
    jmp end_handler_PF
pag_no_presente:
write_access:
    xchg  bx, bx
    
    ; -> Limpio pantalla.
    push    ebp
    mov     ebp, esp
    push    __VGA_VMA
    call    limpiar_VGA                     
    leave
    ; -> Escribo mensaje "Apago paginacion (bit 8 CR0)"
    push    ebp
    mov     ebp, esp
    push    1       ; Es ASCII
    push    10      ; Columna VGA
    push    1       ; Fila    VGA
    push    page_fault_msg_4
    call    escribir_mensaje_VGA
    leave

    xchg  bx, bx

    ;---------------------------------------------------
    ; -> -----------Apago la paginación-----------------
    ;---------------------------------------------------
    xor   eax, eax
    mov   eax, cr0 
    and   eax, 0x7FFFFFFF
    mov   cr0, eax
    ; -> Debo realizar la paginación para la VMA que falló y 
    ; para la PHY 0x0A000000
    ; -> Cargo el PDE (Page Directory Entry)
    push    ebp
    mov     ebp, esp
    push    PAG_P_YES                           ; Presente: Indica si la página está en la memoria (P=1), generando una excepción #PF cuando se intenta acceder a una dirección de memoria que tiene al menos un descriptor con P=0 a lo largo de la estructura de tablas.
    push    PAG_RW_W                            ; Readable / Writable: Establece si la página es Read Only (0) o si puede ser escrita (1).
    push    PAG_US_SUP                          ; User / Supervisor: Privilegio de la P´agina: ’0’ Supervisor (Kernel), y ’1’ Usuario.
    push    PAG_PWT_NO                          ; Page-Level Write Through. Establece el modo de escritura que tendrá la página en el Cache.
    push    PAG_PCD_NO                          ; Page-Level Cache Disable. Establece que una página integre el tipo de memoria no cacheable.
    push    PAG_A                               ; Accedido. Se setea cada vez que la página es accedida.
    push    PAG_PS_4K                           ; Page Size: Existe solo en el DPT. Si es ’0’ la PDE corresponde a una PT de 4 Kbytes. Si es ’1’ a una página de 4Mbytes.
    push    dword[dir_lineal_page_fault]        ; Dir. Lineal(VMA) - Me va a dar la ubicación del PDE. 
    push    dword __PAGE_TABLES_PHY             ; Dir. Fisica(PHY) - Base de la DPT.
    call    set_dir_page_table_entry
    leave

    ;xchg    bx, bx                               ; BREAK ANTES DE ARRANCAR A PAGINAR DINAMICAMENTE

    ; -> Cargo la PTE (Page Table Entry)
    ; Ya tengo cargada la PT antes de arrancar la paginación en init32
    push    ebp
    mov     ebp, esp
    push    PAG_P_YES
    push    PAG_RW_W
    push    PAG_US_SUP
    push    PAG_PWT_NO
    push    PAG_PCD_NO
    push    PAG_A
    push    PAG_D
    push    PAG_PAT
    push    PAG_G_YES
    push    dword __PAG_DINAMICA_INIT_PHY
    ;push    dword [dir_phy_dinamica]        ; Esta debe variar +4KB a medida que se van creando paginas.
    push    dword [dir_lineal_page_fault]   ; Dir. Lineal VMA que trajo el CR2.
    push    dword __PAGE_TABLES_PHY         ; PT inicializada antes de activar paginación.
    call    set_page_table_entry 
    leave

    ;---------------------------------------------------
    ; -> -----------Prendo la paginación-----------------
    ;---------------------------------------------------
    xor   eax, eax
    mov   eax, cr0 
    or    eax, X86_CR0_PG
    mov   cr0, eax

    ;xchg    bx, bx 

    ; -> Limpio pantalla.
    push    ebp
    mov     ebp, esp
    push    __VGA_VMA
    call    limpiar_VGA                     
    leave
    ; -> Escribo mensaje "PTE y PDE paginado OK."
    push    ebp
    mov     ebp, esp
    push    1       ; Es ASCII
    push    0      ; Columna VGA
    push    1       ; Fila    VGA
    push    page_fault_msg_6
    call    escribir_mensaje_VGA
    leave

    xchg    bx, bx  ; BREAK LUEGO DE PAGINAR EL DPT

    
; -> Analizo valor de la Dir. Fisica.
    ;xor     eax, eax
    ;mov     eax,[dir_phy_dinamica]
    ;and     eax, 0xFFFFF000                 ; 20 bits mas sig. poseen DIR_BASE_PAGE.
    ; -> Puedo paginar desde 0x1FFF8 a 0xA000 = 0x15FF8 -> 90.104 páginas de 4K.
    ; Lo limito en 90K páginas y luego las sobreescribo para no romper la memoria.
    ;cmp     eax, 0x15F90
    ;jle     resetear_dir_phy_dinamica    ;  0x01200025   dir_phy_dinamica


    ; -> Sumo 4K para mapear la próx. dir física.
    mov     ebx, 0x1000
    ;shl     ebx, 12
    add     eax, ebx              ; Sumo 4K
    mov     [dir_phy_dinamica], eax
    ;xchg    bx, bx                          ; BREAK LUEGO DE PAGINAR.

    jmp     end_handler_PF                  ; Finalizo el handler #PF


resetear_dir_phy_dinamica:
    mov     dword[dir_phy_dinamica], 0x0A000000
end_handler_PF:
   
    ; -> Limpio pantalla.
    push    ebp
    mov     ebp, esp
    push    __VGA_VMA
    call    limpiar_VGA                     
    leave
    ; -> Muestro el mensaje "Paginación exitosa."
    push    ebp
    mov     ebp, esp
    push    10      ; Columna VGA
    push    2       ; Fila VGA
    push    page_fault_msg_3
    call    escribir_mensaje_VGA
    leave
    ; -> Finalizo la rutina del #PF
    mov al, 0x20                
    out 0x20, al                ; ACK al PIC
    mov edx,0x0E                ; Guardo en edx el valor de la excep. #PF
    popad                       ; Tomo valores de registros guardados.
    sti                         ; Habilito interrupciones.
    iretd

ISR15_Handler_RES:
    xchg    bx,bx
    mov dl,0x0F
    hlt

ISR16_Handler_MF:
    xchg    bx,bx
    mov dl,0x10
    hlt

ISR17_Handler_AC:
    xchg    bx,bx
    mov dl,0x11
    hlt

ISR18_Handler_MC:
    xchg    bx,bx
    mov dl,0x12
    hlt

ISR19_Handler_XM:
    xchg    bx,bx
    mov dl,0x13
    hlt
