USE32

SECTION .start32

%include "inc/processor-flags.h" 

; Selectores de segmento
EXTERN CS_SEL_32
EXTERN DS_SEL_32_prim
; Stack 32 bits
EXTERN __STACK_END_32_VMA
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
EXTERN carga_tp_dinamica_1024_pte
; Direcciones LMA
EXTERN __KERNEL_32_LMA
EXTERN __TECLADO_ISR_LMA
EXTERN __FUNCTIONS_LMA
EXTERN __SYS_TABLES_LMA
EXTERN __DATOS_SYS32_LMA
EXTERN __TAREA1_BSS_LMA
EXTERN __TAREA1_DATA_LMA
EXTERN __TAREA1_TEXT_LMA
EXTERN __TAREA1_RODATA_LMA
; Direcciones VMA
EXTERN __DIGITS_TABLE_VMA
EXTERN __TAREA1_BSS_VMA
EXTERN __TAREA1_DATA_VMA
EXTERN __TAREA1_TEXT_VMA
EXTERN __TAREA1_RODATA_VMA
EXTERN __STACK_START_32_VMA
EXTERN __TAREA1_STACK_START
EXTERN __INIT_32_VMA
EXTERN __KERNEL_32_VMA
EXTERN __FUNCTIONS_VMA
EXTERN __TECLADO_ISR_VMA
EXTERN __SYS_TABLES_VMA
EXTERN __DATOS_SYS32_VMA
EXTERN __TAREA_1_VMA
EXTERN __PAGE_TABLES_VMA
EXTERN __VGA_VMA
EXTERN __TAREA1_STACK_START_VMA
EXTERN __INIT_16_VMA
EXTERN __PAG_DINAMICA_INIT_VMA
; Direcciones físicas
EXTERN __SYS_TABLES_PHY        
EXTERN __PAGE_TABLES_PHY       
EXTERN __FUNCTIONS_PHY         
EXTERN __VGA_PHY               
EXTERN __TECLADO_ISR_PHY       
EXTERN __DATOS_SYS32_PHY       
EXTERN __DIGITS_TABLE_PHY      
EXTERN __KERNEL_32_PHY         
EXTERN __TAREA1_TEXT_PHY       
EXTERN __TAREA1_BSS_PHY        
EXTERN __TAREA1_DATA_PHY       
EXTERN __TAREA1_RODATA_PHY     
EXTERN __STACK_START_32_PHY    
EXTERN __TAREA1_STACK_START_PHY
EXTERN __INIT_ROM_PHY          
EXTERN __RESET_PHY             
EXTERN __STACK_END_32_PHY
EXTERN __PAG_DINAMICA_INIT_PHY
; Tamaños de códigos
EXTERN __codigo_kernel32_size
EXTERN __functions_size
EXTERN __handlers_32_size
EXTERN __sys_tables_size
EXTERN __data_size
EXTERN __tarea_01_size
EXTERN __tarea_1_bss_size
EXTERN __tarea_1_data_size
EXTERN __tarea_1_rodata_size
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
    mov     esp, __STACK_END_32_PHY
    xor     eax, eax
    ; -> Limpio la pila
    mov     ecx, __STACK_SIZE_32 ; Cargo el tamaño del stack en el registro counter.
.stack_init:
    push    eax ; Pusheo ceros en el stack.
    loop    .stack_init
    mov     esp, __STACK_END_32_PHY ; Lo apunto al final
    ; -> Desempaquetamiento de la ROM (copia de las funciones a RAM)
    push    ebp
    mov     ebp, esp ; Genero el STACK FRAME
    ; -> Paso argumentos y llamo memcopy 
    push    __functions_size
    push    __FUNCTIONS_PHY
    push    __FUNCTIONS_LMA
    call    __fast_memcpy_rom
    leave
    cmp     eax, 1 ; Analizo el valor de retorno de memcopy (1 Exito , 0 Fallo)
    jne     .guard
    ; -> Desempaquetamiento de la ROM (copia del kernel a RAM)
    push    ebp
    mov     ebp, esp 
    push    __codigo_kernel32_size
    push    __KERNEL_32_PHY
    push    __KERNEL_32_LMA
    call    __fast_memcpy
    leave
    cmp     eax, 1 ; Analizo el valor de retorno de memcopy (1 Exito , 0 Fallo)
    jne     .guard
    ; -> Desempaquetamiento de la ROM (copia de los handlers Teclado + ISR a RAM)
    push    ebp
    mov     ebp, esp 
    push    __handlers_32_size
    push    __TECLADO_ISR_PHY
    push    __TECLADO_ISR_LMA
    call    __fast_memcpy
    leave
    cmp     eax, 1 ; Analizo el valor de retorno de memcopy (1 Exito , 0 Fallo)
    jne     .guard
    ; -> Desempaquetamiento de la ROM (copia de datos de ROM a RAM)
    push    ebp
    mov     ebp, esp 
    push    __data_size
    push    __DATOS_SYS32_PHY
    push    __DATOS_SYS32_LMA
    call    __fast_memcpy
    leave
    cmp     eax, 1 ; Analizo el valor de retorno de memcopy (1 Exito , 0 Fallo)
    jne     .guard
    ; -> Desempaquetamiento de la ROM (copia de las tablas de sistema (GDT e IDT) a RAM)
    push    ebp
    mov     ebp, esp 
    push    __sys_tables_size
    push    __SYS_TABLES_PHY
    push    __SYS_TABLES_LMA
    call    __fast_memcpy
    leave
    cmp     eax, 1 ; Analizo el valor de retorno de memcopy (1 Exito , 0 Fallo)
    jne     .guard
  ; -> Desempaquetamiento de la ROM (copia del .text de la TAREA_1 a RAM)
    push    ebp
    mov     ebp, esp 
    push    __tarea_01_size
    push    __TAREA1_TEXT_PHY
    push    __TAREA1_TEXT_LMA
    call    __fast_memcpy
    leave
    cmp     eax, 1 ; Analizo el valor de retorno de memcopy (1 Exito , 0 Fallo)
    jne     .guard
 ; -> Desempaquetamiento de la ROM (copia del .bss de la TAREA _1 a RAM)
    push    ebp
    mov     ebp, esp 
    push    __tarea_1_bss_size
    push    __TAREA1_BSS_PHY
    push    __TAREA1_BSS_LMA
    call    __fast_memcpy
    leave
    cmp     eax, 1 ; Analizo el valor de retorno de memcopy (1 Exito , 0 Fallo)
    jne     .guard
   ; -> Desempaquetamiento de la ROM (copia del .data de la TAREA _1 a RAM)
    push    ebp
    mov     ebp, esp 
    push    __tarea_1_data_size
    push    __TAREA1_DATA_PHY
    push    __TAREA1_DATA_LMA
    call    __fast_memcpy
    leave
    cmp     eax, 1 ; Analizo el valor de retorno de memcopy (1 Exito , 0 Fallo)
    jne     .guard
    ; -> Desempaquetamiento de la ROM (copia del .rodata de la TAREA _1 a RAM)
    push    ebp
    mov     ebp, esp 
    push    __tarea_1_rodata_size
    push    __TAREA1_RODATA_PHY
    push    __TAREA1_RODATA_LMA
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

    ;;;;;;;;;;;;; PAGINACIÓN;;;;;;;;;;;;;;;;;;;;;;;;;;


    ; -> Inicializo CR3 con la dirección base de la DPT (Directorio de Tablas de Página).
    push    ebp
    mov     ebp, esp
    push    PAG_PWT_YES
    push    PAG_PCD_YES
    push    dword __PAGE_TABLES_PHY
    call    set_cr3
    mov     cr3, eax
    leave

    ;xchg    bx, bx

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;;;;;;;;;;;;;;;; MAPEO DE LAS ENTRIES DEL DIRECTORIO DE TABLAS DE PAGINAS (DTP);;;;;;;;;;;;;;;;;;;;;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;;;;;;;;;;;;;;;;; SE VAN A PISAR LAS PDE A MEDIDA;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;;;;;;;;;;;;;;;;;QUE SE VAYAN INSERTANDO VMA CON IGUAL DIR. OFFSET;;;;;;;;;;;;;;;
    ;

    ;-> Inicializo entrada 0 de la DPT 
    push    ebp
    mov     ebp, esp
    push    PAG_P_YES                           ; Presente: Indica si la página está en la memoria (P=1), generando una excepción #PF cuando se intenta acceder a una dirección de memoria que tiene al menos un descriptor con P=0 a lo largo de la estructura de tablas.
    push    PAG_RW_W                            ; Readable / Writable: Establece si la página es Read Only (0) o si puede ser escrita (1).
    push    PAG_US_SUP                          ; User / Supervisor: Privilegio de la P´agina: ’0’ Supervisor (Kernel), y ’1’ Usuario.
    push    PAG_PWT_NO                          ; Page-Level Write Through. Establece el modo de escritura que tendrá la página en el Cache.
    push    PAG_PCD_NO                          ; Page-Level Cache Disable. Establece que una página integre el tipo de memoria no cacheable.
    push    PAG_A                               ; Accedido. Se setea cada vez que la página es accedida.
    push    PAG_PS_4K                           ; Page Size: Existe solo en el DPT. Si es ’0’ la PDE corresponde a una PT de 4 Kbytes. Si es ’1’ a una página de 4Mbytes.
    push    dword __SYS_TABLES_VMA                 ; Dir. Lineal(VMA) - Me va a dar la ubicación del PDE. 
    push    dword __PAGE_TABLES_PHY             ; Dir. Fisica(PHY) - Base de la DPT.
    call    set_dir_page_table_entry
    leave

   ; -> Inicializo entrada de la DPT 
    push    ebp
    mov     ebp, esp
    push    PAG_P_YES                           ; Presente: Indica si la página está en la memoria (P=1), generando una excepción #PF cuando se intenta acceder a una dirección de memoria que tiene al menos un descriptor con P=0 a lo largo de la estructura de tablas.
    push    PAG_RW_W                            ; Readable / Writable: Establece si la página es Read Only (0) o si puede ser escrita (1).
    push    PAG_US_SUP                          ; User / Supervisor: Privilegio de la P´agina: ’0’ Supervisor (Kernel), y ’1’ Usuario.
    push    PAG_PWT_NO                          ; Page-Level Write Through. Establece el modo de escritura que tendrá la página en el Cache.
    push    PAG_PCD_NO                          ; Page-Level Cache Disable. Establece que una página integre el tipo de memoria no cacheable.
    push    PAG_A                               ; Accedido. Se setea cada vez que la página es accedida.
    push    PAG_PS_4K                           ; Page Size: Existe solo en el DPT. Si es ’0’ la PDE corresponde a una PT de 4 Kbytes. Si es ’1’ a una página de 4Mbytes.
    push    dword __PAGE_TABLES_VMA          ; Dir. Lineal(VMA) - Me va a dar la ubicación del PDE.
    push    dword __PAGE_TABLES_PHY             ; Dir. Fisica(PHY) - Base de la DPT.
    call    set_dir_page_table_entry
    leave

    ; -> Inicializo entrada de la DPT

    push    ebp
    mov     ebp, esp
    push    PAG_P_YES                           ; Presente: Indica si la página está en la memoria (P=1), generando una excepción #PF cuando se intenta acceder a una dirección de memoria que tiene al menos un descriptor con P=0 a lo largo de la estructura de tablas.
    push    PAG_RW_W                            ; Readable / Writable: Establece si la página es Read Only (0) o si puede ser escrita (1).
    push    PAG_US_SUP                          ; User / Supervisor: Privilegio de la P´agina: ’0’ Supervisor (Kernel), y ’1’ Usuario.
    push    PAG_PWT_NO                          ; Page-Level Write Through. Establece el modo de escritura que tendrá la página en el Cache.
    push    PAG_PCD_NO                          ; Page-Level Cache Disable. Establece que una página integre el tipo de memoria no cacheable.
    push    PAG_A                               ; Accedido. Se setea cada vez que la página es accedida.
    push    PAG_PS_4K                           ; Page Size: Existe solo en el DPT. Si es ’0’ la PDE corresponde a una PT de 4 Kbytes. Si es ’1’ a una página de 4Mbytes.
    push    dword __FUNCTIONS_VMA                 ; Dir. Lineal(VMA) - Me va a dar la ubicación del PDE.  
    push    dword __PAGE_TABLES_PHY             ; Dir. Fisica(PHY) - Base de la DPT.
    call    set_dir_page_table_entry      
    leave

    ; -> Inicializo entrada de la DPT 

    push    ebp
    mov     ebp, esp
    push    PAG_P_YES                           ; Presente: Indica si la página está en la memoria (P=1), generando una excepción #PF cuando se intenta acceder a una dirección de memoria que tiene al menos un descriptor con P=0 a lo largo de la estructura de tablas.
    push    PAG_RW_W                            ; Readable / Writable: Establece si la página es Read Only (0) o si puede ser escrita (1).
    push    PAG_US_SUP                          ; User / Supervisor: Privilegio de la P´agina: ’0’ Supervisor (Kernel), y ’1’ Usuario.
    push    PAG_PWT_NO                          ; Page-Level Write Through. Establece el modo de escritura que tendrá la página en el Cache.
    push    PAG_PCD_NO                          ; Page-Level Cache Disable. Establece que una página integre el tipo de memoria no cacheable.
    push    PAG_A                               ; Accedido. Se setea cada vez que la página es accedida.
    push    PAG_PS_4K                           ; Page Size: Existe solo en el DPT. Si es ’0’ la PDE corresponde a una PT de 4 Kbytes. Si es ’1’ a una página de 4Mbytes.
    push    dword __VGA_VMA                     ; Dir. Lineal(VMA) - Me va a dar la ubicación del PDE.  
    push    dword __PAGE_TABLES_PHY             ; Dir. Fisica(PHY) - Base de la DPT.
    call    set_dir_page_table_entry      
    leave

    ; -> Inicializo entrada de la DPT 

    push    ebp
    mov     ebp, esp
    push    PAG_P_YES                           ; Presente: Indica si la página está en la memoria (P=1), generando una excepción #PF cuando se intenta acceder a una dirección de memoria que tiene al menos un descriptor con P=0 a lo largo de la estructura de tablas.
    push    PAG_RW_W                            ; Readable / Writable: Establece si la página es Read Only (0) o si puede ser escrita (1).
    push    PAG_US_SUP                          ; User / Supervisor: Privilegio de la P´agina: ’0’ Supervisor (Kernel), y ’1’ Usuario.
    push    PAG_PWT_NO                          ; Page-Level Write Through. Establece el modo de escritura que tendrá la página en el Cache.
    push    PAG_PCD_NO                          ; Page-Level Cache Disable. Establece que una página integre el tipo de memoria no cacheable.
    push    PAG_A                               ; Accedido. Se setea cada vez que la página es accedida.
    push    PAG_PS_4K                           ; Page Size: Existe solo en el DPT. Si es ’0’ la PDE corresponde a una PT de 4 Kbytes. Si es ’1’ a una página de 4Mbytes.
    push    dword __TECLADO_ISR_VMA             ; Dir. Lineal(VMA) - Me va a dar la ubicación del PDE.  
    push    dword __PAGE_TABLES_PHY             ; Dir. Fisica(PHY) - Base de la DPT.
    call    set_dir_page_table_entry      
    leave

    ; -> Inicializo entrada de la DPT 

    push    ebp
    mov     ebp, esp
    push    PAG_P_YES                           ; Presente: Indica si la página está en la memoria (P=1), generando una excepción #PF cuando se intenta acceder a una dirección de memoria que tiene al menos un descriptor con P=0 a lo largo de la estructura de tablas.
    push    PAG_RW_W                            ; Readable / Writable: Establece si la página es Read Only (0) o si puede ser escrita (1).
    push    PAG_US_SUP                          ; User / Supervisor: Privilegio de la P´agina: ’0’ Supervisor (Kernel), y ’1’ Usuario.
    push    PAG_PWT_NO                          ; Page-Level Write Through. Establece el modo de escritura que tendrá la página en el Cache.
    push    PAG_PCD_NO                          ; Page-Level Cache Disable. Establece que una página integre el tipo de memoria no cacheable.
    push    PAG_A                               ; Accedido. Se setea cada vez que la página es accedida.
    push    PAG_PS_4K                           ; Page Size: Existe solo en el DPT. Si es ’0’ la PDE corresponde a una PT de 4 Kbytes. Si es ’1’ a una página de 4Mbytes.
    push    dword __DATOS_SYS32_VMA             ; Dir. Lineal(VMA) - Me va a dar la ubicación del PDE.  
    push    dword __PAGE_TABLES_PHY             ; Dir. Fisica(PHY) - Base de la DPT.
    call    set_dir_page_table_entry      
    leave

    ; -> Inicializo entrada de la DPT 

    push    ebp
    mov     ebp, esp
    push    PAG_P_YES                           ; Presente: Indica si la página está en la memoria (P=1), generando una excepción #PF cuando se intenta acceder a una dirección de memoria que tiene al menos un descriptor con P=0 a lo largo de la estructura de tablas.
    push    PAG_RW_W                            ; Readable / Writable: Establece si la página es Read Only (0) o si puede ser escrita (1).
    push    PAG_US_SUP                          ; User / Supervisor: Privilegio de la P´agina: ’0’ Supervisor (Kernel), y ’1’ Usuario.
    push    PAG_PWT_NO                          ; Page-Level Write Through. Establece el modo de escritura que tendrá la página en el Cache.
    push    PAG_PCD_NO                          ; Page-Level Cache Disable. Establece que una página integre el tipo de memoria no cacheable.
    push    PAG_A                               ; Accedido. Se setea cada vez que la página es accedida.
    push    PAG_PS_4K                           ; Page Size: Existe solo en el DPT. Si es ’0’ la PDE corresponde a una PT de 4 Kbytes. Si es ’1’ a una página de 4Mbytes.
    push    dword __DIGITS_TABLE_VMA            ; Dir. Lineal(VMA) - Me va a dar la ubicación del PDE.  
    push    dword __PAGE_TABLES_PHY             ; Dir. Fisica(PHY) - Base de la DPT.
    call    set_dir_page_table_entry      
    leave

    ; -> Inicializo entrada de la DPT

    push    ebp
    mov     ebp, esp
    push    PAG_P_YES                           ; Presente: Indica si la página está en la memoria (P=1), generando una excepción #PF cuando se intenta acceder a una dirección de memoria que tiene al menos un descriptor con P=0 a lo largo de la estructura de tablas.
    push    PAG_RW_W                            ; Readable / Writable: Establece si la página es Read Only (0) o si puede ser escrita (1).
    push    PAG_US_SUP                          ; User / Supervisor: Privilegio de la P´agina: ’0’ Supervisor (Kernel), y ’1’ Usuario.
    push    PAG_PWT_NO                          ; Page-Level Write Through. Establece el modo de escritura que tendrá la página en el Cache.
    push    PAG_PCD_NO                          ; Page-Level Cache Disable. Establece que una página integre el tipo de memoria no cacheable.
    push    PAG_A                               ; Accedido. Se setea cada vez que la página es accedida.
    push    PAG_PS_4K                           ; Page Size: Existe solo en el DPT. Si es ’0’ la PDE corresponde a una PT de 4 Kbytes. Si es ’1’ a una página de 4Mbytes.
    push    dword __KERNEL_32_VMA               ; Dir. Lineal(VMA) - Me va a dar la ubicación del PDE.  
    push    dword __PAGE_TABLES_PHY             ; Dir. Fisica(PHY) - Base de la DPT.
    call    set_dir_page_table_entry      
    leave

    ; -> Inicializo entrada de la DPT

    push    ebp
    mov     ebp, esp
    push    PAG_P_YES                           ; Presente: Indica si la página está en la memoria (P=1), generando una excepción #PF cuando se intenta acceder a una dirección de memoria que tiene al menos un descriptor con P=0 a lo largo de la estructura de tablas.
    push    PAG_RW_W                            ; Readable / Writable: Establece si la página es Read Only (0) o si puede ser escrita (1).
    push    PAG_US_SUP                          ; User / Supervisor: Privilegio de la P´agina: ’0’ Supervisor (Kernel), y ’1’ Usuario.
    push    PAG_PWT_NO                          ; Page-Level Write Through. Establece el modo de escritura que tendrá la página en el Cache.
    push    PAG_PCD_NO                          ; Page-Level Cache Disable. Establece que una página integre el tipo de memoria no cacheable.
    push    PAG_A                               ; Accedido. Se setea cada vez que la página es accedida.
    push    PAG_PS_4K                           ; Page Size: Existe solo en el DPT. Si es ’0’ la PDE corresponde a una PT de 4 Kbytes. Si es ’1’ a una página de 4Mbytes.
    push    dword __TAREA1_TEXT_VMA             ; Dir. Lineal(VMA) - Me va a dar la ubicación del PDE.  
    push    dword __PAGE_TABLES_PHY             ; Dir. Fisica(PHY) - Base de la DPT.
    call    set_dir_page_table_entry      
    leave

    ; -> Inicializo entrada de la DPT 

    push    ebp
    mov     ebp, esp
    push    PAG_P_YES                           ; Presente: Indica si la página está en la memoria (P=1), generando una excepción #PF cuando se intenta acceder a una dirección de memoria que tiene al menos un descriptor con P=0 a lo largo de la estructura de tablas.
    push    PAG_RW_W                            ; Readable / Writable: Establece si la página es Read Only (0) o si puede ser escrita (1).
    push    PAG_US_SUP                          ; User / Supervisor: Privilegio de la P´agina: ’0’ Supervisor (Kernel), y ’1’ Usuario.
    push    PAG_PWT_NO                          ; Page-Level Write Through. Establece el modo de escritura que tendrá la página en el Cache.
    push    PAG_PCD_NO                          ; Page-Level Cache Disable. Establece que una página integre el tipo de memoria no cacheable.
    push    PAG_A                               ; Accedido. Se setea cada vez que la página es accedida.
    push    PAG_PS_4K                           ; Page Size: Existe solo en el DPT. Si es ’0’ la PDE corresponde a una PT de 4 Kbytes. Si es ’1’ a una página de 4Mbytes.
    push    dword __TAREA1_BSS_VMA             ; Dir. Lineal(VMA) - Me va a dar la ubicación del PDE.  
    push    dword __PAGE_TABLES_PHY             ; Dir. Fisica(PHY) - Base de la DPT.
    call    set_dir_page_table_entry      
    leave

    ; -> Inicializo entrada de la DPT 

    push    ebp
    mov     ebp, esp
    push    PAG_P_YES                           ; Presente: Indica si la página está en la memoria (P=1), generando una excepción #PF cuando se intenta acceder a una dirección de memoria que tiene al menos un descriptor con P=0 a lo largo de la estructura de tablas.
    push    PAG_RW_W                            ; Readable / Writable: Establece si la página es Read Only (0) o si puede ser escrita (1).
    push    PAG_US_SUP                          ; User / Supervisor: Privilegio de la P´agina: ’0’ Supervisor (Kernel), y ’1’ Usuario.
    push    PAG_PWT_NO                          ; Page-Level Write Through. Establece el modo de escritura que tendrá la página en el Cache.
    push    PAG_PCD_NO                          ; Page-Level Cache Disable. Establece que una página integre el tipo de memoria no cacheable.
    push    PAG_A                               ; Accedido. Se setea cada vez que la página es accedida.
    push    PAG_PS_4K                           ; Page Size: Existe solo en el DPT. Si es ’0’ la PDE corresponde a una PT de 4 Kbytes. Si es ’1’ a una página de 4Mbytes.
    push    dword __TAREA1_DATA_VMA             ; Dir. Lineal(VMA) - Me va a dar la ubicación del PDE.  
    push    dword __PAGE_TABLES_PHY             ; Dir. Fisica(PHY) - Base de la DPT.
    call    set_dir_page_table_entry      
    leave

   ; -> Inicializo entrada de la DPT 

    push    ebp
    mov     ebp, esp
    push    PAG_P_YES                           ; Presente: Indica si la página está en la memoria (P=1), generando una excepción #PF cuando se intenta acceder a una dirección de memoria que tiene al menos un descriptor con P=0 a lo largo de la estructura de tablas.
    push    PAG_RW_W                            ; Readable / Writable: Establece si la página es Read Only (0) o si puede ser escrita (1).
    push    PAG_US_SUP                          ; User / Supervisor: Privilegio de la P´agina: ’0’ Supervisor (Kernel), y ’1’ Usuario.
    push    PAG_PWT_NO                          ; Page-Level Write Through. Establece el modo de escritura que tendrá la página en el Cache.
    push    PAG_PCD_NO                          ; Page-Level Cache Disable. Establece que una página integre el tipo de memoria no cacheable.
    push    PAG_A                               ; Accedido. Se setea cada vez que la página es accedida.
    push    PAG_PS_4K                           ; Page Size: Existe solo en el DPT. Si es ’0’ la PDE corresponde a una PT de 4 Kbytes. Si es ’1’ a una página de 4Mbytes.
    push    dword __TAREA1_RODATA_VMA           ; Dir. Lineal(VMA) - Me va a dar la ubicación del PDE.  
    push    dword __PAGE_TABLES_PHY             ; Dir. Fisica(PHY) - Base de la DPT.
    call    set_dir_page_table_entry      
    leave

   ; -> Inicializo entrada de la DPT 

    push    ebp
    mov     ebp, esp
    push    PAG_P_YES                           ; Presente: Indica si la página está en la memoria (P=1), generando una excepción #PF cuando se intenta acceder a una dirección de memoria que tiene al menos un descriptor con P=0 a lo largo de la estructura de tablas.
    push    PAG_RW_W                            ; Readable / Writable: Establece si la página es Read Only (0) o si puede ser escrita (1).
    push    PAG_US_SUP                          ; User / Supervisor: Privilegio de la P´agina: ’0’ Supervisor (Kernel), y ’1’ Usuario.
    push    PAG_PWT_NO                          ; Page-Level Write Through. Establece el modo de escritura que tendrá la página en el Cache.
    push    PAG_PCD_NO                          ; Page-Level Cache Disable. Establece que una página integre el tipo de memoria no cacheable.
    push    PAG_A                               ; Accedido. Se setea cada vez que la página es accedida.
    push    PAG_PS_4K                           ; Page Size: Existe solo en el DPT. Si es ’0’ la PDE corresponde a una PT de 4 Kbytes. Si es ’1’ a una página de 4Mbytes.
    push    dword __STACK_START_32_VMA          ; Dir. Lineal(VMA) - Me va a dar la ubicación del PDE.  
    push    dword __PAGE_TABLES_PHY             ; Dir. Fisica(PHY) - Base de la DPT.
    call    set_dir_page_table_entry      
    leave

   ; -> Inicializo entrada de la DPT 

    push    ebp
    mov     ebp, esp
    push    PAG_P_YES                           ; Presente: Indica si la página está en la memoria (P=1), generando una excepción #PF cuando se intenta acceder a una dirección de memoria que tiene al menos un descriptor con P=0 a lo largo de la estructura de tablas.
    push    PAG_RW_W                            ; Readable / Writable: Establece si la página es Read Only (0) o si puede ser escrita (1).
    push    PAG_US_SUP                          ; User / Supervisor: Privilegio de la P´agina: ’0’ Supervisor (Kernel), y ’1’ Usuario.
    push    PAG_PWT_NO                          ; Page-Level Write Through. Establece el modo de escritura que tendrá la página en el Cache.
    push    PAG_PCD_NO                          ; Page-Level Cache Disable. Establece que una página integre el tipo de memoria no cacheable.
    push    PAG_A                               ; Accedido. Se setea cada vez que la página es accedida.
    push    PAG_PS_4K                           ; Page Size: Existe solo en el DPT. Si es ’0’ la PDE corresponde a una PT de 4 Kbytes. Si es ’1’ a una página de 4Mbytes.
    push    dword __TAREA1_STACK_START_VMA      ; Dir. Lineal(VMA) - Me va a dar la ubicación del PDE.  
    push    dword __PAGE_TABLES_PHY             ; Dir. Fisica(PHY) - Base de la DPT.
    call    set_dir_page_table_entry      
    leave

   ; -> Inicializo entrada de la DPT

    push    ebp
    mov     ebp, esp
    push    PAG_P_YES                           ; Presente: Indica si la página está en la memoria (P=1), generando una excepción #PF cuando se intenta acceder a una dirección de memoria que tiene al menos un descriptor con P=0 a lo largo de la estructura de tablas.
    push    PAG_RW_W                            ; Readable / Writable: Establece si la página es Read Only (0) o si puede ser escrita (1).
    push    PAG_US_SUP                          ; User / Supervisor: Privilegio de la P´agina: ’0’ Supervisor (Kernel), y ’1’ Usuario.
    push    PAG_PWT_NO                          ; Page-Level Write Through. Establece el modo de escritura que tendrá la página en el Cache.
    push    PAG_PCD_NO                          ; Page-Level Cache Disable. Establece que una página integre el tipo de memoria no cacheable.
    push    PAG_A                               ; Accedido. Se setea cada vez que la página es accedida.
    push    PAG_PS_4K                           ; Page Size: Existe solo en el DPT. Si es ’0’ la PDE corresponde a una PT de 4 Kbytes. Si es ’1’ a una página de 4Mbytes.
    push    dword __INIT_16_VMA                 ; Dir. Lineal(VMA) - Me va a dar la ubicación del PDE.  
    push    dword __PAGE_TABLES_PHY             ; Dir. Fisica(PHY) - Base de la DPT.
    call    set_dir_page_table_entry      
    leave


   ; -> Inicializo entrada de la DPT para la paginación dinámica. 
   ; Entry PDTE = 0x28
    ;push    ebp
    ;mov     ebp, esp
    ;push    PAG_P_YES                           ; Presente: Indica si la página está en la memoria (P=1), generando una excepción #PF cuando se intenta acceder a una dirección de memoria que tiene al menos un descriptor con P=0 a lo largo de la estructura de tablas.
    ;push    PAG_RW_W                            ; Readable / Writable: Establece si la página es Read Only (0) o si puede ser escrita (1).
    ;push    PAG_US_SUP                          ; User / Supervisor: Privilegio de la P´agina: ’0’ Supervisor (Kernel), y ’1’ Usuario.
    ;push    PAG_PWT_NO                          ; Page-Level Write Through. Establece el modo de escritura que tendrá la página en el Cache.
    ;push    PAG_PCD_NO                          ; Page-Level Cache Disable. Establece que una página integre el tipo de memoria no cacheable.
    ;push    PAG_A                               ; Accedido. Se setea cada vez que la página es accedida.
    ;push    PAG_PS_4K                           ; Page Size: Existe solo en el DPT. Si es ’0’ la PDE corresponde a una PT de 4 Kbytes. Si es ’1’ a una página de 4Mbytes.
    ;push    dword __PAG_DINAMICA_INIT_VMA       ; Dir. Lineal(VMA) - Le paso el inicio del NUEVO ESPACIO FISICO porque el PDE que dará como resultado es diferente a todo el resto. 
    ;push    dword __PAGE_TABLES_PHY             ; Dir. Fisica(PHY) - Base de la DPT.
    ;call    set_dir_page_table_entry      
    ;leave

    

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
    push PAG_RW_W
    push PAG_US_SUP
    push PAG_PWT_NO
    push PAG_PCD_NO
    push PAG_A
    push PAG_D
    push PAG_PAT
    push PAG_G_YES
    push dword __SYS_TABLES_PHY
    push dword __SYS_TABLES_VMA
    push dword __PAGE_TABLES_PHY
    call set_page_table_entry 
    leave

    ;xchg  bx, bx

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
    push dword __PAGE_TABLES_PHY
    push dword __PAGE_TABLES_VMA
    push dword __PAGE_TABLES_PHY
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
    push dword __FUNCTIONS_PHY
    push dword __FUNCTIONS_VMA
    push dword __PAGE_TABLES_PHY
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
    push dword __VGA_PHY
    push dword __VGA_VMA
    push dword __PAGE_TABLES_PHY
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
    push dword __TECLADO_ISR_PHY
    push dword __TECLADO_ISR_VMA
    push dword __PAGE_TABLES_PHY
    call set_page_table_entry 
    leave

    ;-----------------------------------------------------------------
    ;6° Pagina de 4K - Datos 0x0020-0000 a 0x0020-0FFF
    ; Indice en la TP = 0x200 (bits 21-12 de __DATOS_SYS32_VMA = 0x00200000)
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
    push dword __DATOS_SYS32_PHY
    push dword __DATOS_SYS32_VMA
    push dword __PAGE_TABLES_PHY
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
    push dword __DIGITS_TABLE_PHY
    push dword __DIGITS_TABLE_VMA
    push dword __PAGE_TABLES_PHY
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
    push dword __KERNEL_32_PHY
    push dword __KERNEL_32_VMA
    push dword __PAGE_TABLES_PHY
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
    push dword __TAREA1_TEXT_PHY
    push dword __TAREA1_TEXT_VMA
    push dword __PAGE_TABLES_PHY
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
    push dword __TAREA1_BSS_PHY
    push dword __TAREA1_BSS_VMA
    push dword __PAGE_TABLES_PHY
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
    push dword __TAREA1_DATA_PHY
    push dword __TAREA1_DATA_VMA
    push dword __PAGE_TABLES_PHY
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
    push dword __TAREA1_RODATA_PHY
    push dword __TAREA1_RODATA_VMA
    push dword __PAGE_TABLES_PHY
    call set_page_table_entry 
    leave

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
    push dword __STACK_START_32_PHY
    push dword __STACK_START_32_VMA
    push dword __PAGE_TABLES_PHY
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
    push dword __TAREA1_STACK_START_PHY
    push dword __TAREA1_STACK_START_VMA
    push dword __PAGE_TABLES_PHY
    call set_page_table_entry 
    leave

                          ;---------------------------
    ;----------------------TABLA DE PAGINAS 0x3FF (TP 0x3FF)----------------
                          ;----------------------------
                          ;PAGINACION DE LA ROM DE 64 KB;
    ;-----------------------------------------------------------------
    ;15° Pagina de 4K - Stack de INIT_32_VMA 
    ; Indice en la TP = 0x3F9 (bits 21-12 de __INIT_32_VMA = 0xFFFF938E que sale del .map)
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
    push dword __INIT_32_VMA
    push dword __INIT_32_VMA
    push dword __PAGE_TABLES_PHY
    call set_page_table_entry 
    leave

                          ;---------------------------
    ;----------------------TABLA DE PAGINAS 0x28 (TP 0x28)----------------
                          ;----------------------------
    ;-----------------------------------------------------------------
    ; cargo una PTE para tener inicializada la PT - Inicio de paginacion dinámica 
    ; Primer índice en la TP = 0x00 (bits 21-12 de __PAG_DINAMICA_INIT_PHY = 0x0A000000 )
    ;-----------------------------------------------------------------

  
    ;push    ebp
    ;mov     ebp, esp
    ;push PAG_P_YES
    ;push PAG_RW_W
    ;push PAG_US_SUP
    ;push PAG_PWT_NO
    ;push PAG_PCD_NO
    ;push PAG_A
    ;push PAG_D
    ;push PAG_PAT
    ;push PAG_G_YES
    ;push dword __PAG_DINAMICA_INIT_PHY
    ;push dword __PAG_DINAMICA_INIT_VMA
    ;push dword __PAGE_TABLES_PHY
    ;call set_page_table_entry 
    ;leave



    ;call carga_tp_dinamica_1024_pte  

    ;xchg  bx, bx
    ; -> Habilito la paginación
    mov   eax, cr0 
    or    eax, X86_CR0_PG
    mov   cr0, eax

    sti                     ; Habilitación de las Interrupciones

    jmp CS_SEL_32:kernel32_init ; Salto en memoria a la sección del núcleo

.guard:
    hlt
    jmp .guard



;SECTION .tablas_paginacion
;  directory_page_table        resd 1024         ; Reservo los 1024 bytes del directorio
;  page_tables                 resd 1024*504     ; Tengo 4 tablas estaticas + 500 dinamicas
   