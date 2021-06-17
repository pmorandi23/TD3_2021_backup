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
EXTERN set_cr3
EXTERN set_dir_page_table_entry
EXTERN set_page_table_entry
; Direcciones LMA
EXTERN __KERNEL_32_LMA
EXTERN __TECLADO_ISR_LMA
EXTERN __FUNCTIONS_LMA
EXTERN __SYS_TABLES_LMA
EXTERN __DATA_LMA
EXTERN __TAREA_1_LMA
; Direcciones VMA
EXTERN __KERNEL_32_VMA
EXTERN __FUNCTIONS_VMA
EXTERN __TECLADO_ISR_VMA
EXTERN __SYS_TABLES_VMA
EXTERN __DATA_VMA
EXTERN __TAREA_1_VMA
EXTERN __PAGE_TABLES_VMA
; Tamaños de códigos
EXTERN __codigo_kernel32_size
EXTERN __functions_size
EXTERN __handlers_32_size
EXTERN __sys_tables_size
EXTERN __data_size
EXTERN __codigo_tarea_01_size
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
    push    __TAREA_1_VMA
    push    __TAREA_1_LMA
    call    __fast_memcpy
    leave
    cmp     eax, 1 ; Analizo el valor de retorno de memcopy (1 Exito , 0 Fallo)
    jne     .guard

  ; -> Desempaquetamiento de la ROM (copia del código de la tarea 1 a RAM)
    push    ebp
    mov     ebp, esp 
    push    __codigo_tarea_01_size
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

    ;;;;;;;;;;;;; PAGINACIÓN;;;;;;;;;;;;;;;;;;;;;;;;;;

    ; -> Inicializo CR3 con la dirección base de la DPT (Directorio de Tablas de Página).
    push    ebp
    mov     ebp, esp
    push    PAG_PWT_YES
    push    PAG_PCD_YES
    push    (dword)__PAGE_TABLES_VMA
    call    set_cr3
    mov     cr3, eax
    leave

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;;;;;;;;;;;;;;;; MAPEO DE LAS ENTRIES DEL DIRECTORIO DE TABLAS DE PAGINAS (DTP);;;;;;;;;;;;;;;;;;;;;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ;

    ;-> Inicializo entrada 0 de la DPT (para ISR,SYSTABLES)
    ; Las direcciones VMA (Dir. Lineales) que tendra esta entrada de DPT :  __SYS_TABLES_VMA        = 0x00000000;
    ;                                                                       __PAGE_TABLES_VMA       = 0x00010000;
    ;                                                                       __FUNCTIONS_VMA         = 0x00050000;
    ;                                                                       __VGA_VMA               = 0x000B8000;
    ;                                                                       __TECLADO_ISR_VMA       = 0x00100000;
    ;                                                                       __DATA_VMA              = 0x00200000;
    ;                                                                       __DIGITS_TABLE          = 0x00210000;
    ;                                                                       __KERNEL_32_VMA         = 0x00220000;
    ;                                                                       __TAREA_1_VMA           = 0x00310000;
    ;                                                                       __TAREA1_TEXT_VMA       = 0x00310000;
    ;                                                                       __TAREA1_BSS_VMA        = 0x00320000;
    ;                                                                       __TAREA1_DATA_VMA       = 0x00330000;
    ;                                                                       __TAREA1_RODATA_VMA     = 0x00340000;                                                                                                                                                                                                                  
    ; Todas tienen como 10 bits más significativos(31-22) 0x00 y corresponden al índice en el DTP.
    push    ebp
    mov     ebp, esp
    push    PAG_P_YES                           ; Presente: Indica si la página está en la memoria (P=1), generando una excepción #PF cuando se intenta acceder a una dirección de memoria que tiene al menos un descriptor con P=0 a lo largo de la estructura de tablas.
    push    PAG_RW_W                            ; Readable / Writable: Establece si la página es Read Only (0) o si puede ser escrita (1).
    push    PAG_US_SUP                          ; User / Supervisor: Privilegio de la P´agina: ’0’ Supervisor (Kernel), y ’1’ Usuario.
    push    PAG_PWT_NO                          ; Page-Level Write Through. Establece el modo de escritura que tendrá la página en el Cache.
    push    PAG_PCD_NO                          ; Page-Level Cache Disable. Establece que una página integre el tipo de memoria no cacheable.
    push    PAG_A                               ; Accedido. Se setea cada vez que la página es accedida.
    push    PAG_PS_4K                           ; Page Size: Existe solo en el DPT. Si es ’0’ la PDE corresponde a una PT de 4 Kbytes. Si es ’1’ a una página de 4Mbytes.
    push    dword((__PAGE_TABLES_VMA+0x1000))   ; Coloco la Page Table (PT) abajo de los primeros 4K de la DPT.
    push    0x00                                ; Indice del DTP .
    push    dword(__PAGE_TABLES_VMA)
    call    set_dir_page_table_entry
    leave

    ; -> Inicializo entrada 0x7F de la DPT (paga Kernel, Tabla de digitos, Datos)
      ; Las direcciones VMA (Dir. Lineales) que tendra esta entrada de DPT :   __STACK_START_32        = 0x1FFF8000;
    ;                                                                          __STACK_END_32          = 0x1FFF8FFF;
    ;                                                                          __TAREA1_STACK_START    = 0x1FFFF000;
    ;                                                                          __TAREA1_STACK_END      = 0x1FFFFFFF;                                                                                                                                                                                                                             
    ; Todas tienen como 10 bits más significativos(31-22) 0x7F y corresponden al índice en el DTP.
    push    ebp
    mov     ebp, esp
    push    PAG_P_YES                           ; Presente: Indica si la página está en la memoria (P=1), generando una excepción #PF cuando se intenta acceder a una dirección de memoria que tiene al menos un descriptor con P=0 a lo largo de la estructura de tablas.
    push    PAG_RW_W                            ; Readable / Writable: Establece si la página es Read Only (0) o si puede ser escrita (1).
    push    PAG_US_SUP                          ; User / Supervisor: Privilegio de la P´agina: ’0’ Supervisor (Kernel), y ’1’ Usuario.
    push    PAG_PWT_NO                          ; Page-Level Write Through. Establece el modo de escritura que tendrá la página en el Cache.
    push    PAG_PCD_NO                          ; Page-Level Cache Disable. Establece que una página integre el tipo de memoria no cacheable.
    push    PAG_A                               ; Accedido. Se setea cada vez que la página es accedida.
    push    PAG_PS_4K                           ; Page Size: Existe solo en el DPT. Si es ’0’ la PDE corresponde a una PT de 4 Kbytes. Si es ’1’ a una página de 4Mbytes.
    push    dword((__PAGE_TABLES_VMA+0x1000+0x1000*0x7F)) ; Coloco la Page Table (PT) abajo de la primera entrada de PT(0x00) de 4K.
    push    0x7F                                ; Indice del DTP .
    push    dword(__PAGE_TABLES_VMA)
    call    set_dir_page_table_entry
    leave

    ; -> Inicializo entrada 0x3FF de la DPT (para start32_launcher, para éste código.)
    ; Aca estoy paginando para ROM.  Dir. Lineal (VMA = LMA)
    ; La dirección VMA (Dir. Lineal) que tendrá esta entrada de DPT :    __INIT_16_VMA           = 0xFFFF0000;
    ;                                                                    __VGA_INIT_VMA          = 0xFFFF5000;
    ;                                                                    __INIT_32_VMA           = 0xFFFFB000;
    ;                                                                    __FUNCTIONS_ROM_VMA     = 0xFFFFFC00;
    ;                                                                    __RESET_VMA             = 0xFFFFFFF0;
    ;                                                                    
    ; Tiene como 10 bits más significativos(31-22) 0x3FF y corresponde al índice en el DTP.

    push    ebp
    mov     ebp, esp
    push    PAG_P_YES                           ; Presente: Indica si la página está en la memoria (P=1), generando una excepción #PF cuando se intenta acceder a una dirección de memoria que tiene al menos un descriptor con P=0 a lo largo de la estructura de tablas.
    push    PAG_RW_W                            ; Readable / Writable: Establece si la página es Read Only (0) o si puede ser escrita (1).
    push    PAG_US_SUP                          ; User / Supervisor: Privilegio de la P´agina: ’0’ Supervisor (Kernel), y ’1’ Usuario.
    push    PAG_PWT_NO                          ; Page-Level Write Through. Establece el modo de escritura que tendrá la página en el Cache.
    push    PAG_PCD_NO                          ; Page-Level Cache Disable. Establece que una página integre el tipo de memoria no cacheable.
    push    PAG_A                               ; Accedido. Se setea cada vez que la página es accedida.
    push    PAG_PS_4K                           ; Page Size: Existe solo en el DPT. Si es ’0’ la PDE corresponde a una PT de 4 Kbytes. Si es ’1’ a una página de 4Mbytes.
    push    dword((__PAGE_TABLES_VMA+0x1000+0x1000*0x3FF))  ; Coloco la Page Table (PT) (0x3FF * 0xFFF) desde el fin de la DPT
    push    0x3FF                               ; Indice del DTP.
    push    dword(__PAGE_TABLES_VMA)            ; Base del DTP.
    call    set_dir_page_table_entry
    leave

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;;;;;;;;;;;;;;;; MAPEO DE LAS ENTRIES DE LAS TABLAS DE PAGINAS (PT o TP);;;;;;;;;;;;;;;;;;;;;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

                        ;---------------------------
  ;----------------------TABLA DE PAGINAS 0x00 (TP 0x00)----------------
                        ;----------------------------
  ;-----------------------------------------------------------------
    ;1° Pagina de 4K - Sys Tables  0x0000-0000 a 0x0000-0FFF
    ; Indice en la TP = 0x00 (bits 21-12 de __SYS_TABLES_VMA = 0x00000000)
    ;-----------------------------------------------------------------
    push    ebp
    mov     ebp, esp
    push PAG_P_YES
    push PAG_RW_R
    push PAG_US_SUP
    push PAG_PWT_NO
    push PAG_PCD_NO
    push PAG_A
    push PAG_D
    push PAG_PAT
    push PAG_G_YES
    push dword(__SYS_TABLES_VMA)
    push 0x00
    push dword(__PAGE_TABLES_VMA+0x1000)
    call set_page_table_entry 
    leave
    ;-----------------------------------------------------------------
    ;2° Pagina de 4K - Tablas de Paginacion  0x0001-0000 a 0x0001-0FFF
    ; Indice en la TP = 0x10 (bits 21-12 de __PAGE_TABLES_VMA = 0x00010000)
    ;-----------------------------------------------------------------
    push    ebp
    mov     ebp, esp
    push PAG_P_YES
    push PAG_RW_R
    push PAG_US_SUP
    push PAG_PWT_NO
    push PAG_PCD_NO
    push PAG_A
    push PAG_D
    push PAG_PAT
    push PAG_G_YES
    push dword(__PAGE_TABLES_VMA)
    push 0x10
    push dword(__PAGE_TABLES_VMA+0x1000)
    call set_page_table_entry 
    leave
    ;-----------------------------------------------------------------
    ;3° Pagina de 4K - Funciones de RAM  0x0005-0000 a 0x0005-0FFF
    ; Indice en la TP = 0x50 (bits 21-12 de __FUNCTIONS_VMA = 0x00050000)
    ;-----------------------------------------------------------------
    push    ebp
    mov     ebp, esp
    push PAG_P_YES
    push PAG_RW_R
    push PAG_US_SUP
    push PAG_PWT_NO
    push PAG_PCD_NO
    push PAG_A
    push PAG_D
    push PAG_PAT
    push PAG_G_YES
    push dword(__FUNCTIONS_VMA)
    push 0x50
    push dword(__PAGE_TABLES_VMA+0x1000)
    call set_page_table_entry 
    leave

    ;-----------------------------------------------------------------
    ;4° Pagina de 4K - RAM de Video  0x000B-8000 a 0x000B-8FFF
    ; Indice en la TP = 0xB8 (bits 21-12 de __VGA_VMA = 0x000B8000)
    ;-----------------------------------------------------------------
    push    ebp
    mov     ebp, esp
    push PAG_P_YES
    push PAG_RW_W
    push PAG_US_SUP
    push PAG_PWT_NO
    push PAG_PCD_NO
    push PAG_A
    push PAG_D
    push PAG_PAT
    push PAG_G_YES
    push dword(__VGA_VMA)
    push 0xB8
    push dword(__PAGE_TABLES_VMA+0x1000)
    call set_page_table_entry 
    leave

    ;-----------------------------------------------------------------
    ;5° Pagina de 4K - Teclado + ISR  0x0010-0000 a 0x0010-0FFF
    ; Indice en la TP = 0x100 (bits 21-12 de __TECLADO_ISR_VMA = 0x00100000)
    ;-----------------------------------------------------------------
    push    ebp
    mov     ebp, esp
    push PAG_P_YES
    push PAG_RW_R
    push PAG_US_SUP
    push PAG_PWT_NO
    push PAG_PCD_NO
    push PAG_A
    push PAG_D
    push PAG_PAT
    push PAG_G_YES
    push dword(__PT_TECLADO_ISR)
    push 0x100
    push dword(__PAGE_TABLES_VMA+0x1000)
    call set_page_table_entry 
    leave

    ;-----------------------------------------------------------------
    ;6° Pagina de 4K - Datos 0x0020-0000 a 0x0020-0FFF
    ; Indice en la TP = 0x200 (bits 21-12 de __DATA_VMA = 0x00200000)
    ;-----------------------------------------------------------------
    push    ebp
    mov     ebp, esp
    push PAG_P_YES
    push PAG_RW_W
    push PAG_US_SUP
    push PAG_PWT_NO
    push PAG_PCD_NO
    push PAG_A
    push PAG_D
    push PAG_PAT
    push PAG_G_YES
    push dword(__DATA_VMA)
    push 0x200
    push dword(__PAGE_TABLES_VMA+0x1000)
    call set_page_table_entry 
    leave

    ;-----------------------------------------------------------------
    ;7° Pagina de 4K - Digitos 0x0021-0000 a 0x0021-0FFF
    ; Indice en la TP = 0x210 (bits 21-12 de __DIGITS_TABLE = 0x00210000)
    ;-----------------------------------------------------------------
    push    ebp
    mov     ebp, esp
    push PAG_P_YES
    push PAG_RW_W
    push PAG_US_SUP
    push PAG_PWT_NO
    push PAG_PCD_NO
    push PAG_A
    push PAG_D
    push PAG_PAT
    push PAG_G_YES
    push dword(__DIGITS_TABLE)
    push 0x210
    push dword(__PAGE_TABLES_VMA+0x1000)
    call set_page_table_entry 
    leave

    ;-----------------------------------------------------------------
    ;8° Pagina de 4K - Kernel 0x0022-0000 a 0x0022-0FFF
    ; Indice en la TP = 0x220 (bits 21-12 de __KERNEL_32_VMA = 0x00220000;)
    ;-----------------------------------------------------------------
    push    ebp
    mov     ebp, esp
    push PAG_P_YES
    push PAG_RW_R
    push PAG_US_SUP
    push PAG_PWT_NO
    push PAG_PCD_NO
    push PAG_A
    push PAG_D
    push PAG_PAT
    push PAG_G_YES
    push dword(__KERNEL_32_VMA)
    push 0x220
    push dword(__PAGE_TABLES_VMA+0x1000)
    call set_page_table_entry 
    leave

    ;-----------------------------------------------------------------
    ;9° Pagina de 4K - TEXT Tarea 1 0x0031-0000 a 0x0031-0FFF
    ; Indice en la TP = 0x310 (bits 21-12 de __TAREA1_TEXT_VMA = 0x00310000;)
    ;-----------------------------------------------------------------
    push    ebp
    mov     ebp, esp
    push PAG_P_YES
    push PAG_RW_R
    push PAG_US_SUP
    push PAG_PWT_NO
    push PAG_PCD_NO
    push PAG_A
    push PAG_D
    push PAG_PAT
    push PAG_G_YES
    push dword(__TAREA1_TEXT_VMA)
    push 0x310
    push dword(__PAGE_TABLES_VMA+0x1000)
    call set_page_table_entry 
    leave

    ;-----------------------------------------------------------------
    ;10° Pagina de 4K - BSS Tarea 1 0x0032-0000 a 0x0032-0FFF
    ; Indice en la TP = 0x320 (bits 21-12 de __TAREA1_BSS_VMA = 0x00320000)
    ;-----------------------------------------------------------------
    push    ebp
    mov     ebp, esp
    push PAG_P_YES
    push PAG_RW_W
    push PAG_US_SUP
    push PAG_PWT_NO
    push PAG_PCD_NO
    push PAG_A
    push PAG_D
    push PAG_PAT
    push PAG_G_YES
    push dword(__TAREA1_BSS_VMA)
    push 0x320
    push dword(__PAGE_TABLES_VMA+0x1000)
    call set_page_table_entry 
    leave

    ;-----------------------------------------------------------------
    ;11° Pagina de 4K - DATA Tarea 1 0x0033-0000 a 0x0033-0FFF
    ; Indice en la TP = 0x330 (bits 21-12 de __TAREA1_DATA_VMA = 0x00330000)
    ;-----------------------------------------------------------------
    push    ebp
    mov     ebp, esp
    push PAG_P_YES
    push PAG_RW_W
    push PAG_US_SUP
    push PAG_PWT_NO
    push PAG_PCD_NO
    push PAG_A
    push PAG_D
    push PAG_PAT
    push PAG_G_YES
    push dword(__TAREA1_DATA_VMA)
    push 0x330
    push dword(__PAGE_TABLES_VMA+0x1000)
    call set_page_table_entry 
    leave

    ;-----------------------------------------------------------------
    ;12° Pagina de 4K - RODATA Tarea 1 0x0034-0000 a 0x0034-0FFF
    ; Indice en la TP = 0x340 (bits 21-12 de __TAREA1_RODATA_VMA = 0x00340000)
    ;-----------------------------------------------------------------
    push    ebp
    mov     ebp, esp
    push PAG_P_YES
    push PAG_RW_R
    push PAG_US_SUP
    push PAG_PWT_NO
    push PAG_PCD_NO
    push PAG_A
    push PAG_D
    push PAG_PAT
    push PAG_G_YES
    push dword(__TAREA1_RODATA_VMA)
    push 0x340
    push dword(__PAGE_TABLES_VMA+0x1000)
    call set_page_table_entry 
    leave

    ;-----------------------------------------------------------------
    ;Paginados los 1ros 4MB
    ;-----------------------------------------------------------------
                       ;---------------------------
  ;----------------------TABLA DE PAGINAS 0x7F (TP 0x7F)----------------
                        ;----------------------------
    ;-----------------------------------------------------------------
    ;13° Pagina de 4K - Stack de Sistema 0x1FFF-8000 a 0x1FFF-8FFF
    ; Indice en la TP = 0x3F8 (bits 21-12 de __STACK_START_32 = 0x1FFF8000)
    ;-----------------------------------------------------------------
    push    ebp
    mov     ebp, esp
    push PAG_P_YES
    push PAG_RW_W
    push PAG_US_SUP
    push PAG_PWT_NO
    push PAG_PCD_NO
    push PAG_A
    push PAG_D
    push PAG_PAT
    push PAG_G_YES
    push dword(__STACK_START_32)
    push 0x3F8
    push dword(__PAGE_TABLES_VMA+0x1000+(0x1000*0x7F))
    call set_page_table_entry 
    leave

    ;-----------------------------------------------------------------
    ;14° Pagina de 4K - Stack de TAREA 01 0x1FFF-F000 a 0x1FFF-FFFF
    ; Indice en la TP = 0x3FF (bits 21-12 de __TAREA1_STACK_START = 0x1FFFF000)
    ;-----------------------------------------------------------------
    push    ebp
    mov     ebp, esp
    push PAG_P_YES
    push PAG_RW_W
    push PAG_US_SUP
    push PAG_PWT_NO
    push PAG_PCD_NO
    push PAG_A
    push PAG_D
    push PAG_PAT
    push PAG_G_YES
    push dword(__TAREA1_STACK_START)
    push 0x3FF
    push dword(__PAGE_TABLES_VMA+0x1000+(0x1000*0x7F))
    call set_page_table_entry 
    leave

                          ;---------------------------
    ;----------------------TABLA DE PAGINAS 0x3FF (TP 0x3FF)----------------
                          ;----------------------------
                          ;PAGINACION DE LA ROM DE 64 KB;
    ;-----------------------------------------------------------------
    ;15° Pagina de 4K - Stack de TAREA 01 0x1FFF-F000 a 0x1FFF-FFFF
    ; Indice en la TP = 0x3FB (bits 21-12 de __INIT_32_VMA = 0xFFFFB000)
    ;-----------------------------------------------------------------
    push    ebp
    mov     ebp, esp
    push PAG_P_YES
    push PAG_RW_W
    push PAG_US_SUP
    push PAG_PWT_NO
    push PAG_PCD_NO
    push PAG_A
    push PAG_D
    push PAG_PAT
    push PAG_G_YES
    push dword(__INIT_32_VMA)
    push 0x3FB
    push dword(__PAGE_TABLES_VMA+0x1000+(0x1000*0x3FF))
    call set_page_table_entry 
    leave

    ; -> Habilito la paginación
    mov   eax, cr0 
    or    eax, X86_CR0_PG
    mov   cr0, eax


    jmp CS_SEL_32:kernel32_init ; Salto en memoria a la sección del núcleo

.guard:
    hlt
    jmp .guard




