USE32

SECTION .start32

%include "inc/processor-flags.h" 

; Selectores de segmento
EXTERN CS_SEL_00
EXTERN DS_SEL_32_prim
EXTERN TSS_SEL
; Stack 32 bits
EXTERN __STACK_END_32_VMA
__STACK_KERNEL_END_VMA
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
EXTERN set_cr3_rom
EXTERN ejecutar_tarea_1
EXTERN ejecutar_tarea_2
EXTERN ejecutar_tarea_3
EXTERN ejecutar_tarea_4
EXTERN set_page_rom
EXTERN init_tss
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
EXTERN __TAREA2_BSS_LMA
EXTERN __TAREA2_DATA_LMA
EXTERN __TAREA2_TEXT_LMA
EXTERN __TAREA2_RODATA_LMA
EXTERN __TAREA3_BSS_LMA
EXTERN __TAREA3_DATA_LMA
EXTERN __TAREA3_TEXT_LMA
EXTERN __TAREA3_RODATA_LMA
EXTERN __TAREA4_BSS_LMA
EXTERN __TAREA4_DATA_LMA
EXTERN __TAREA4_TEXT_LMA
EXTERN __TAREA4_RODATA_LMA
; Direcciones VMA
EXTERN __DIGITS_TABLE_VMA
EXTERN __TAREA1_BSS_VMA
EXTERN __TAREA1_DATA_VMA
EXTERN __TAREA1_TEXT_VMA
EXTERN __TAREA1_RODATA_VMA
EXTERN __TAREA2_BSS_VMA
EXTERN __TAREA2_DATA_VMA
EXTERN __TAREA2_TEXT_VMA
EXTERN __TAREA2_RODATA_VMA
EXTERN __TAREA3_BSS_VMA
EXTERN __TAREA3_DATA_VMA
EXTERN __TAREA3_TEXT_VMA
EXTERN __TAREA3_RODATA_VMA
EXTERN __TAREA4_BSS_VMA
EXTERN __TAREA4_DATA_VMA
EXTERN __TAREA4_TEXT_VMA
EXTERN __TAREA4_RODATA_VMA
EXTERN __STACK_KERNEL_VMA
EXTERN __TAREA1_STACK_START_VMA
EXTERN __TAREA2_STACK_START_VMA
EXTERN __TAREA3_STACK_START_VMA
EXTERN __TAREA4_STACK_START_VMA
EXTERN __TAREA1_STACK_END_VMA
EXTERN __TAREA2_STACK_END_VMA
EXTERN __TAREA3_STACK_END_VMA
EXTERN __TAREA4_STACK_END_VMA
EXTERN __STACK_KERNEL_TAREA1_END_VMA
EXTERN __STACK_KERNEL_TAREA2_END_VMA
EXTERN __STACK_KERNEL_TAREA3_END_VMA
EXTERN __STACK_KERNEL_TAREA4_END_VMA
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
EXTERN __TSS4_VMA
EXTERN __TSS3_VMA
EXTERN __TSS2_VMA
EXTERN __TSS1_VMA
EXTERN __TSS_BASICA
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
EXTERN __TAREA2_TEXT_PHY  
EXTERN __TAREA2_BSS_PHY   
EXTERN __TAREA2_DATA_PHY  
EXTERN __TAREA2_RODATA_PHY
EXTERN __TAREA3_TEXT_PHY  
EXTERN __TAREA3_BSS_PHY   
EXTERN __TAREA3_DATA_PHY  
EXTERN __TAREA3_RODATA_PHY
EXTERN __TAREA4_TEXT_PHY  
EXTERN __TAREA4_BSS_PHY   
EXTERN __TAREA4_DATA_PHY  
EXTERN __TAREA4_RODATA_PHY
EXTERN __STACK_KERNEL_PHY    
EXTERN __TAREA1_STACK_START_PHY
EXTERN __TAREA2_STACK_START_PHY
EXTERN __TAREA3_STACK_START_PHY
EXTERN __TAREA4_STACK_START_PHY
EXTERN __INIT_ROM_PHY          
EXTERN __RESET_PHY             
EXTERN __STACK_KERNEL_END_PHY
EXTERN __PAG_DINAMICA_INIT_PHY
EXTERN __CR3_KERNEL_PHY
EXTERN __CR3_TAREA_1_PHY
EXTERN __CR3_TAREA_2_PHY
EXTERN __CR3_TAREA_3_PHY
EXTERN __CR3_TAREA_4_PHY
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
EXTERN __tarea_02_size
EXTERN __tarea_2_bss_size
EXTERN __tarea_2_data_size
EXTERN __tarea_2_rodata_size
EXTERN __tarea_03_size
EXTERN __tarea_3_bss_size
EXTERN __tarea_3_data_size
EXTERN __tarea_3_rodata_size
EXTERN __tarea_04_size
EXTERN __tarea_4_bss_size
EXTERN __tarea_4_data_size
EXTERN __tarea_4_rodata_size
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
  mov     esp, __STACK_KERNEL_END_PHY
  xor     eax, eax
  ; -> Limpio la pila
  mov     ecx, __STACK_SIZE_32 ; Cargo el tamaño del stack en el registro counter.
.stack_init:
  push    eax ; Pusheo ceros en el stack.
  loop    .stack_init
  mov     esp, __STACK_KERNEL_END_PHY ; Lo apunto al final

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
  ; -> Desempaquetamiento de la ROM (copia del .text de la TAREA_2 a RAM)
  push    ebp
  mov     ebp, esp 
  push    __tarea_02_size
  push    __TAREA2_TEXT_PHY
  push    __TAREA2_TEXT_LMA
  call    __fast_memcpy
  leave
  cmp     eax, 1 ; Analizo el valor de retorno de memcopy (1 Exito , 0 Fallo)
  jne     .guard
  ; -> Desempaquetamiento de la ROM (copia del .bss de la TAREA _2 a RAM)
  push    ebp
  mov     ebp, esp 
  push    __tarea_2_bss_size
  push    __TAREA2_BSS_PHY
  push    __TAREA2_BSS_LMA
  call    __fast_memcpy
  leave
  cmp     eax, 1 ; Analizo el valor de retorno de memcopy (1 Exito , 0 Fallo)
  jne     .guard
  ; -> Desempaquetamiento de la ROM (copia del .data de la TAREA _2 a RAM)
  push    ebp
  mov     ebp, esp 
  push    __tarea_2_data_size
  push    __TAREA2_DATA_PHY
  push    __TAREA2_DATA_LMA
  call    __fast_memcpy
  leave
  cmp     eax, 1 ; Analizo el valor de retorno de memcopy (1 Exito , 0 Fallo)
  jne     .guard
  ; -> Desempaquetamiento de la ROM (copia del .rodata de la TAREA _2 a RAM)
  push    ebp
  mov     ebp, esp 
  push    __tarea_2_rodata_size
  push    __TAREA2_RODATA_PHY
  push    __TAREA2_RODATA_LMA
  call    __fast_memcpy
  leave
  cmp     eax, 1 ; Analizo el valor de retorno de memcopy (1 Exito , 0 Fallo)
  jne     .guard
  ; -> Desempaquetamiento de la ROM (copia del .text de la TAREA_3 a RAM)
  push    ebp
  mov     ebp, esp 
  push    __tarea_03_size
  push    __TAREA3_TEXT_PHY
  push    __TAREA3_TEXT_LMA
  call    __fast_memcpy
  leave
  cmp     eax, 1 ; Analizo el valor de retorno de memcopy (1 Exito , 0 Fallo)
  jne     .guard
  ; -> Desempaquetamiento de la ROM (copia del .bss de la TAREA _3 a RAM)
  push    ebp
  mov     ebp, esp 
  push    __tarea_3_bss_size
  push    __TAREA3_BSS_PHY
  push    __TAREA3_BSS_LMA
  call    __fast_memcpy
  leave
  cmp     eax, 1 ; Analizo el valor de retorno de memcopy (1 Exito , 0 Fallo)
  jne     .guard
  ; -> Desempaquetamiento de la ROM (copia del .data de la TAREA_3 a RAM)
  push    ebp
  mov     ebp, esp 
  push    __tarea_3_data_size
  push    __TAREA3_DATA_PHY
  push    __TAREA3_DATA_LMA
  call    __fast_memcpy
  leave
  cmp     eax, 1 ; Analizo el valor de retorno de memcopy (1 Exito , 0 Fallo)
  jne     .guard
  ; -> Desempaquetamiento de la ROM (copia del .rodata de la TAREA _3 a RAM)
  push    ebp
  mov     ebp, esp 
  push    __tarea_3_rodata_size
  push    __TAREA3_RODATA_PHY
  push    __TAREA3_RODATA_LMA
  call    __fast_memcpy
  leave
  cmp     eax, 1 ; Analizo el valor de retorno de memcopy (1 Exito , 0 Fallo)
  jne     .guard
  ; -> Desempaquetamiento de la ROM (copia del .text de la TAREA_4 a RAM)
  push    ebp
  mov     ebp, esp 
  push    __tarea_04_size
  push    __TAREA4_TEXT_PHY
  push    __TAREA4_TEXT_LMA
  call    __fast_memcpy
  leave
  cmp     eax, 1 ; Analizo el valor de retorno de memcopy (1 Exito , 0 Fallo)
  jne     .guard
  ; -> Desempaquetamiento de la ROM (copia del .bss de la TAREA_4 a RAM)
  push    ebp
  mov     ebp, esp 
  push    __tarea_4_bss_size
  push    __TAREA4_BSS_PHY
  push    __TAREA4_BSS_LMA
  call    __fast_memcpy
  leave
  cmp     eax, 1 ; Analizo el valor de retorno de memcopy (1 Exito , 0 Fallo)
  jne     .guard
  ; -> Desempaquetamiento de la ROM (copia del .data de la TAREA_4 a RAM)
  push    ebp
  mov     ebp, esp 
  push    __tarea_4_data_size
  push    __TAREA4_DATA_PHY
  push    __TAREA4_DATA_LMA
  call    __fast_memcpy
  leave
  cmp     eax, 1 ; Analizo el valor de retorno de memcopy (1 Exito , 0 Fallo)
  jne     .guard
  ; -> Desempaquetamiento de la ROM (copia del .rodata de la TAREA_4 a RAM)
  push    ebp
  mov     ebp, esp 
  push    __tarea_4_rodata_size
  push    __TAREA4_RODATA_PHY
  push    __TAREA4_RODATA_LMA
  call    __fast_memcpy
  leave
  cmp     eax, 1 ; Analizo el valor de retorno de memcopy (1 Exito , 0 Fallo)
  jne     .guard

  ;-> Cargo la IDT y la GDT ya copiada en RAM
  lgdt [_gdtr_32]
  lidt [_idtr_32]  

  ; -> Init PIC , IRQ y config. Timer y teclado
  call init_teclado       ; Inicializo controlador de teclado
  call init_timer         ; Configuro Timer tick para 100ms
  call init_pic           ; Inicializo los PICs e interrupciones de Timer y Teclado

  ;----------------------------------------------
  ;-----------------PAGINACIÓN-------------------
  ;----------------------------------------------

  ; -> Inicializo CR3 con la dirección base del DPT correspondiente al Kernel.
  push    ebp
  mov     ebp, esp
  push    PAG_PWT_YES
  push    PAG_PCD_YES
  push    dword __CR3_KERNEL_PHY
  call    set_cr3_rom
  mov     cr3, eax
  leave

  ;--------------------------------------------
  ;-----------Mapeo del Kernel-----------------
  ;--------------------------------------------
  ;------------CR3_KERNEL                       = Base del DTP del Kernel
  ;------------CR3_KERNEL + 0x1000              = Tamaño del DTP
  ;-----------(CR3 KERNEL + 0x1000)+0x1000*DPTE = Bases de las TP

  ; HANDLERS, VGA, SYS_TABLES, KERNEL_32, DIGITS_TABLE, DATA_SYS, STACK_SYS, INIT_32 (este código), __TSS_BASICA, TSS_1, TSS_2, TSS_3

  ;------__TECLADO_ISR_PHY-----------
  ; ->Cargo DPTE y PTE
  push    ebp
  mov     ebp, esp
  push    PAG_RW_R          ; Permisos R/W para el PTE
  push    PAG_RW_W          ; Permisos R/W para el DPTE
  push    PAG_US_SUP        ; Permisos de Supervisor/Usuario para el PTE
  push    PAG_US_SUP        ; Permisos de Supervisor/Usuario para el DPTE
  push    __TECLADO_ISR_PHY
  push    __TECLADO_ISR_VMA 
  push    __CR3_KERNEL_PHY  ; Base del DPT del Kernel 
  call    set_page_rom
  leave

;------__VGA_PHY-----------
; ->Cargo DPTE y PTE
  push    ebp
  mov     ebp, esp 
  push    PAG_RW_W          ; Permisos R/W para el PTE
  push    PAG_RW_W          ; Permisos R/W para el DPTE
  push    PAG_US_SUP        ; Permisos de Supervisor/Usuario para el PTE
  push    PAG_US_SUP        ; Permisos de Supervisor/Usuario para el DPTE
  push    __VGA_PHY
  push    __VGA_VMA 
  push    __CR3_KERNEL_PHY  ; Base del DPT del Kernel 
  call    set_page_rom
  leave

;------__SYS_TABLES_PHY-----------
  ; ->Cargo DPTE y PTE
  push    ebp
  mov     ebp, esp 
  push    PAG_RW_R          ; Permisos R/W para el PTE
  push    PAG_RW_W          ; Permisos R/W para el DPTE
  push    PAG_US_SUP        ; Permisos de Supervisor/Usuario para el PTE
  push    PAG_US_SUP        ; Permisos de Supervisor/Usuario para el DPTE
  push    __SYS_TABLES_PHY
  push    __SYS_TABLES_VMA 
  push    __CR3_KERNEL_PHY  ; Base del DPT del Kernel 
  call    set_page_rom
  leave

;------__KERNEL_32_PHY-----------
  ; ->Cargo DPTE y PTE
  push    ebp
  mov     ebp, esp 
  push    PAG_RW_R          ; Permisos R/W para el PTE
  push    PAG_RW_W          ; Permisos R/W para el DPTE
  push    PAG_US_SUP        ; Permisos de Supervisor/Usuario para el PTE
  push    PAG_US_SUP        ; Permisos de Supervisor/Usuario para el DPTE
  push    __KERNEL_32_PHY
  push    __KERNEL_32_VMA 
  push    __CR3_KERNEL_PHY  ; Base del DPT del Kernel 
  call    set_page_rom
  leave


;------__FUNCTIONS_PHY-----------
  ; ->Cargo DPTE y PTE
  push    ebp
  mov     ebp, esp 
  push    PAG_RW_R          ; Permisos R/W para el PTE
  push    PAG_RW_W          ; Permisos R/W para el DPTE
  push    PAG_US_SUP        ; Permisos de Supervisor/Usuario para el PTE
  push    PAG_US_SUP        ; Permisos de Supervisor/Usuario para el DPTE
  push    __FUNCTIONS_PHY
  push    __FUNCTIONS_VMA 
  push    __CR3_KERNEL_PHY  ; Base del DPT del Kernel 
  call    set_page_rom
  leave

;------__DIGITS_TABLE_PHY-----------
  ; ->Cargo DPTE y PTE
  push    ebp
  mov     ebp, esp 
  push    PAG_RW_W          ; Permisos R/W para el PTE
  push    PAG_RW_W          ; Permisos R/W para el DPTE
  push    PAG_US_SUP        ; Permisos de Supervisor/Usuario para el PTE
  push    PAG_US_SUP        ; Permisos de Supervisor/Usuario para el DPTE
  push    __DIGITS_TABLE_PHY
  push    __DIGITS_TABLE_VMA 
  push    __CR3_KERNEL_PHY  ; Base del DPT del Kernel 
  call    set_page_rom
  leave

;------__DATOS_SYS32_PHY-----------
  ; ->Cargo DPTE y PTE
  push    ebp
  mov     ebp, esp 
  push    PAG_RW_W          ; Permisos R/W para el PTE
  push    PAG_RW_W          ; Permisos R/W para el DPTE
  push    PAG_US_SUP        ; Permisos de Supervisor/Usuario para el PTE
  push    PAG_US_SUP        ; Permisos de Supervisor/Usuario para el DPTE
  push    __DATOS_SYS32_PHY
  push    __DATOS_SYS32_VMA 
  push    __CR3_KERNEL_PHY  ; Base del DPT del Kernel 
  call    set_page_rom
  leave


;------__STACK_KERNEL_VMA-----------
  ; ->Cargo DPTE y PTE
  push    ebp
  mov     ebp, esp 
  push    PAG_RW_W          ; Permisos R/W para el PTE
  push    PAG_RW_W          ; Permisos R/W para el DPTE
  push    PAG_US_SUP        ; Permisos de Supervisor/Usuario para el PTE
  push    PAG_US_SUP        ; Permisos de Supervisor/Usuario para el DPTE
  push    __STACK_KERNEL_PHY
  push    __STACK_KERNEL_VMA 
  push    __CR3_KERNEL_PHY  ; Base del DPT del Kernel 
  call    set_page_rom
  leave


;------__INIT_32_VMA-----------
  ; ->Cargo DPTE y PTE
  push    ebp
  mov     ebp, esp 
  push    PAG_RW_R          ; Permisos R/W para el PTE
  push    PAG_RW_W          ; Permisos R/W para el DPTE
  push    PAG_US_SUP        ; Permisos de Supervisor/Usuario para el PTE
  push    PAG_US_SUP        ; Permisos de Supervisor/Usuario para el DPTE
  push    __INIT_32_VMA     ; Identitty Mapping para que pueda funcionar este código luego de prender paginación.
  push    __INIT_32_VMA 
  push    __CR3_KERNEL_PHY  ; Base del DPT del Kernel 
  call    set_page_rom
  leave

;------__TSS_BASICA-----------
  ; ->Cargo DPTE y PTE
  push    ebp
  mov     ebp, esp 
  push    PAG_RW_W          ; Permisos R/W para el PTE
  push    PAG_RW_W          ; Permisos R/W para el DPTE
  push    PAG_US_SUP        ; Permisos de Supervisor/Usuario para el PTE
  push    PAG_US_SUP        ; Permisos de Supervisor/Usuario para el DPTE
  push    __TSS_BASICA        ; Identitty Mapping
  push    __TSS_BASICA 
  push    __CR3_KERNEL_PHY  ; Base del DPT del Kernel 
  call    set_page_rom
  leave

;------TSS_1-----------
  ; ->Cargo DPTE y PTE
  push    ebp
  mov     ebp, esp 
  push    PAG_RW_W          ; Permisos R/W para el PTE
  push    PAG_RW_W          ; Permisos R/W para el DPTE
  push    PAG_US_SUP        ; Permisos de Supervisor/Usuario para el PTE
  push    PAG_US_SUP        ; Permisos de Supervisor/Usuario para el DPTE
  push    __TSS1_VMA          ; Identitty Mapping
  push    __TSS1_VMA 
  push    __CR3_KERNEL_PHY  ; Base del DPT del Kernel 
  call    set_page_rom
  leave

;------__TSS_2-----------
  ; ->Cargo DPTE y PTE
  push    ebp
  mov     ebp, esp 
  push    PAG_RW_W          ; Permisos R/W para el PTE
  push    PAG_RW_W          ; Permisos R/W para el DPTE
  push    PAG_US_SUP        ; Permisos de Supervisor/Usuario para el PTE
  push    PAG_US_SUP        ; Permisos de Supervisor/Usuario para el DPTE
  push    __TSS2_VMA          ; Identitty Mapping
  push    __TSS2_VMA 
  push    __CR3_KERNEL_PHY  ; Base del DPT del Kernel 
  call    set_page_rom
  leave

  ;------__TSS_3-----------
  ; ->Cargo DPTE y PTE
  push    ebp
  mov     ebp, esp 
  push    PAG_RW_W          ; Permisos R/W para el PTE
  push    PAG_RW_W          ; Permisos R/W para el DPTE
  push    PAG_US_SUP        ; Permisos de Supervisor/Usuario para el PTE
  push    PAG_US_SUP        ; Permisos de Supervisor/Usuario para el DPTE
  push    __TSS3_VMA          ; Identitty Mapping
  push    __TSS3_VMA 
  push    __CR3_KERNEL_PHY  ; Base del DPT del Kernel 
  call    set_page_rom
  leave

  ;------__TSS_4-----------
  ; ->Cargo DPTE y PTE
  push    ebp
  mov     ebp, esp 
  push    PAG_RW_W          ; Permisos R/W para el PTE
  push    PAG_RW_W          ; Permisos R/W para el DPTE
  push    PAG_US_SUP        ; Permisos de Supervisor/Usuario para el PTE
  push    PAG_US_SUP        ; Permisos de Supervisor/Usuario para el DPTE
  push    __TSS4_VMA          ; Identitty Mapping
  push    __TSS4_VMA 
  push    __CR3_KERNEL_PHY  ; Base del DPT del Kernel 
  call    set_page_rom
  leave



  ;--------------------------------------------
  ;-----------Mapeo de la Tarea 1 -------------
  ;--------------------------------------------
  ;------------__CR3_TAREA_1_PHY                            = Base del DTP de la Tarea 1
  ;------------__CR3_TAREA_1_PHY + 0x1000                   = Tamaño del DTP
  ;-----------(CR3 __CR3_TAREA_1_PHY + 0x1000)+0x1000*DPTE  = Bases de las TP

  ;------__TECLADO_ISR_PHY-----------
  ; ->Cargo DPTE y PTE
  push    ebp
  mov     ebp, esp 
  push    PAG_RW_R            ; Permiso ReadOnly para el PTE del código de los Handlers EXCEP. e IRQ
  push    PAG_RW_W            ; Permiso de Write para el DPTE que apunta a la TP
  push    PAG_US_SUP          ; Permisos de Supervisor para el PTE
  push    PAG_US_US           ; Permisos de Usuario para el DPTE
  push    __TECLADO_ISR_PHY     
  push    __TECLADO_ISR_VMA 
  push    __CR3_TAREA_1_PHY   ; Base del DPT de la Tarea 1 
  call    set_page_rom
  leave
  ;------__VGA_PHY-----------
  ; ->Cargo DPTE y PTE
  push    ebp
  mov     ebp, esp 
  push    PAG_RW_W            ; Permisos R/W para el PTE
  push    PAG_RW_W            ; Permisos R/W para el DPTE
  push    PAG_US_SUP          ; Permisos de Supervisor/Usuario para el PTE
  push    PAG_US_US           ; Permisos de Supervisor/Usuario para el DPTE
  push    __VGA_PHY     
  push    __VGA_VMA 
  push    __CR3_TAREA_1_PHY    ; Base del DPT de la Tarea 1 
  call    set_page_rom
  leave

  ;------__FUNCTIONS_PHY-----------
  ; ->Cargo DPTE y PTE
  push    ebp
  mov     ebp, esp 
  push    PAG_RW_R            ; Permisos R/W para el PTE
  push    PAG_RW_W            ; Permisos R/W para el DPTE
  push    PAG_US_SUP          ; Permisos de Supervisor/Usuario para el PTE
  push    PAG_US_US           ; Permisos de Supervisor/Usuario para el DPTE
  push    __FUNCTIONS_PHY     
  push    __FUNCTIONS_VMA 
  push    __CR3_TAREA_1_PHY    ; Base del DPT de la Tarea 1 
  call    set_page_rom
  leave

  ;------__DATOS_SYS32_PHY-----------
  ; ->Cargo DPTE y PTE
  push    ebp
  mov     ebp, esp 
  push    PAG_RW_W            ; Permisos R/W para el PTE
  push    PAG_RW_W            ; Permisos R/W para el DPTE
  push    PAG_US_SUP          ; Permisos de Supervisor/Usuario para el PTE
  push    PAG_US_US           ; Permisos de Supervisor/Usuario para el DPTE
  push    __DATOS_SYS32_PHY     
  push    __DATOS_SYS32_VMA 
  push    __CR3_TAREA_1_PHY    ; Base del DPT de la Tarea 1 
  call    set_page_rom
  leave

  ;------__DIGITS_TABLE_PHY-----------
  ; ->Cargo DPTE y PTE
  push    ebp
  mov     ebp, esp 
  push    PAG_RW_W            ; Permisos R/W para el PTE
  push    PAG_RW_W            ; Permisos R/W para el DPTE
  push    PAG_US_SUP          ; Permisos de Supervisor/Usuario para el PTE
  push    PAG_US_US           ; Permisos de Supervisor/Usuario para el DPTE
  push    __DIGITS_TABLE_PHY     
  push    __DIGITS_TABLE_VMA 
  push    __CR3_TAREA_1_PHY    ; Base del DPT de la Tarea 1 
  call    set_page_rom
  leave

  ;------__SYS_TABLES_PHY-----------
  ; ->Cargo DPTE y PTE
  push    ebp
  mov     ebp, esp 
  push    PAG_RW_R            ; Permisos R/W para el PTE
  push    PAG_RW_W            ; Permisos R/W para el DPTE
  push    PAG_US_SUP          ; Permisos de Supervisor/Usuario para el PTE
  push    PAG_US_US           ; Permisos de Supervisor/Usuario para el DPTE
  push    __SYS_TABLES_PHY     
  push    __SYS_TABLES_VMA 
  push    __CR3_TAREA_1_PHY    ; Base del DPT de la Tarea 1 
  call    set_page_rom
  leave

  ;------__TAREA1_TEXT_PHY-----------
  ; ->Cargo DPTE y PTE
  push    ebp
  mov     ebp, esp 
  push    PAG_RW_R            ; Permisos R/W para el PTE
  push    PAG_RW_W            ; Permisos R/W para el DPTE
  push    PAG_US_US           ; Permisos de Supervisor/Usuario para el PTE
  push    PAG_US_US           ; Permisos de Supervisor/Usuario para el DPTE
  push    __TAREA1_TEXT_PHY     
  push    __TAREA1_TEXT_VMA 
  push    __CR3_TAREA_1_PHY    ; Base del DPT de la Tarea 1 
  call    set_page_rom
  leave

  ;------__TAREA1_BSS_PHY-----------
  ; ->Cargo DPTE y PTE
  push    ebp
  mov     ebp, esp 
  push    PAG_RW_W            ; Permisos R/W para el PTE
  push    PAG_RW_W            ; Permisos R/W para el DPTE
  push    PAG_US_US           ; Permisos de Supervisor/Usuario para el PTE
  push    PAG_US_US           ; Permisos de Supervisor/Usuario para el DPTE
  push    __TAREA1_BSS_PHY     
  push    __TAREA1_BSS_VMA 
  push    __CR3_TAREA_1_PHY    ; Base del DPT de la Tarea 1 
  call    set_page_rom
  leave

  ;------__TAREA1_DATA_PHY-----------
  ; ->Cargo DPTE y PTE
  push    ebp
  mov     ebp, esp 
  push    PAG_RW_W            ; Permisos R/W para el PTE
  push    PAG_RW_W            ; Permisos R/W para el DPTE
  push    PAG_US_US           ; Permisos de Supervisor/Usuario para el PTE
  push    PAG_US_US           ; Permisos de Supervisor/Usuario para el DPTE
  push    __TAREA1_DATA_PHY     
  push    __TAREA1_DATA_VMA 
  push    __CR3_TAREA_1_PHY    ; Base del DPT de la Tarea 1 
  call    set_page_rom
  leave
  
  ;------__TAREA1_STACK_START_PHY-----------
  ; ->Cargo DPTE y PTE
  push    ebp
  mov     ebp, esp 
  push    PAG_RW_W            ; Permisos R/W para el PTE
  push    PAG_RW_W            ; Permisos R/W para el DPTE
  push    PAG_US_US           ; Permisos de Supervisor/Usuario para el PTE
  push    PAG_US_US           ; Permisos de Supervisor/Usuario para el DPTE
  push    __TAREA1_STACK_START_PHY     
  push    __TAREA1_STACK_START_VMA 
  push    __CR3_TAREA_1_PHY    ; Base del DPT de la Tarea 1 
  call    set_page_rom
  leave

  ;------__STACK_KERNEL_PHY-----------
  ; ->Cargo DPTE y PTE
  push    ebp
  mov     ebp, esp 
  push    PAG_RW_W             ; Permisos R/W para el PTE
  push    PAG_RW_W             ; Permisos R/W para el DPTE
  push    PAG_US_SUP           ; Permisos de Supervisor/Usuario para el PTE
  push    PAG_US_US            ; Permisos de Supervisor/Usuario para el DPTE
  push    __STACK_KERNEL_PHY     
  push    __STACK_KERNEL_VMA 
  push    __CR3_TAREA_1_PHY    ; Base del DPT de la Tarea 1 
  call    set_page_rom
  leave

  ;------__TSS_1-----------
  ; ->Cargo DPTE y PTE
  push    ebp
  mov     ebp, esp 
  push    PAG_RW_W          ; Permisos R/W para el PTE
  push    PAG_RW_W          ; Permisos R/W para el DPTE
  push    PAG_US_SUP        ; Permisos de Supervisor/Usuario para el PTE
  push    PAG_US_US         ; Permisos de Supervisor/Usuario para el DPTE
  push    __TSS1_VMA          ; Identitty Mapping
  push    __TSS1_VMA 
  push    __CR3_TAREA_1_PHY  ; Base del DPT del Kernel 
  call    set_page_rom
  leave
  ;------____TSS_BASICA-----------
  ; Se mapea en todas las DTP de las Tareas para que el CPU puedas ir a buscar
  ; las pilas de nivel 0.
  ; ->Cargo DPTE y PTE
  push    ebp
  mov     ebp, esp 
  push    PAG_RW_W          ; Permisos R/W para el PTE
  push    PAG_RW_W          ; Permisos R/W para el DPTE
  push    PAG_US_SUP        ; Permisos de Supervisor/Usuario para el PTE
  push    PAG_US_US         ; Permisos de Supervisor/Usuario para el DPTE
  push    __TSS_BASICA        ; Identitty Mapping
  push    __TSS_BASICA 
  push    __CR3_TAREA_1_PHY  ; Base del DPT del Kernel 
  call    set_page_rom
  leave

  ;--------------------------------------------
  ;-----------Mapeo de la Tarea 2 -------------
  ;--------------------------------------------
  ;------------__CR3_TAREA_2_PHY                            = Base del DTP de la Tarea 2
  ;------------__CR3_TAREA_2_PHY + 0x1000                   = Tamaño del DTP
  ;-----------(__CR3_TAREA_2_PHY + 0x1000)+0x1000*DPTE      = Bases de las TP

  ;------__TECLADO_ISR_PHY-----------
  ; ->Cargo DPTE y PTE
  push    ebp
  mov     ebp, esp 
  push    PAG_RW_R            ; Permiso ReadOnly para el PTE del código de los Handlers EXCEP. e IRQ
  push    PAG_RW_W            ; Permiso de Write para el DPTE que apunta a la TP
  push    PAG_US_SUP          ; Permisos de Supervisor para el PTE
  push    PAG_US_US           ; Permisos de Usuario para el DPTE
  push    __TECLADO_ISR_PHY     
  push    __TECLADO_ISR_VMA 
  push    __CR3_TAREA_2_PHY   ; Base del DPT de la Tarea 1 
  call    set_page_rom
  leave
  ;------__VGA_PHY-----------
  ; ->Cargo DPTE y PTE
  push    ebp
  mov     ebp, esp 
  push    PAG_RW_W            ; Permisos R/W para el PTE
  push    PAG_RW_W            ; Permisos R/W para el DPTE
  push    PAG_US_SUP          ; Permisos de Supervisor/Usuario para el PTE
  push    PAG_US_US           ; Permisos de Supervisor/Usuario para el DPTE
  push    __VGA_PHY     
  push    __VGA_VMA 
  push    __CR3_TAREA_2_PHY    ; Base del DPT de la Tarea 1 
  call    set_page_rom
  leave

  ;------__FUNCTIONS_PHY-----------
  ; ->Cargo DPTE y PTE
  push    ebp
  mov     ebp, esp 
  push    PAG_RW_R            ; Permisos R/W para el PTE
  push    PAG_RW_W            ; Permisos R/W para el DPTE
  push    PAG_US_SUP          ; Permisos de Supervisor/Usuario para el PTE
  push    PAG_US_US           ; Permisos de Supervisor/Usuario para el DPTE
  push    __FUNCTIONS_PHY     
  push    __FUNCTIONS_VMA 
  push    __CR3_TAREA_2_PHY    ; Base del DPT de la Tarea 1 
  call    set_page_rom
  leave

  ;------__DATOS_SYS32_PHY-----------
  ; ->Cargo DPTE y PTE
  push    ebp
  mov     ebp, esp 
  push    PAG_RW_W            ; Permisos R/W para el PTE
  push    PAG_RW_W            ; Permisos R/W para el DPTE
  push    PAG_US_SUP          ; Permisos de Supervisor/Usuario para el PTE
  push    PAG_US_US           ; Permisos de Supervisor/Usuario para el DPTE
  push    __DATOS_SYS32_PHY     
  push    __DATOS_SYS32_VMA 
  push    __CR3_TAREA_2_PHY    ; Base del DPT de la Tarea 1 
  call    set_page_rom
  leave

  ;------__DIGITS_TABLE_PHY-----------
  ; ->Cargo DPTE y PTE
  push    ebp
  mov     ebp, esp 
  push    PAG_RW_W            ; Permisos R/W para el PTE
  push    PAG_RW_W            ; Permisos R/W para el DPTE
  push    PAG_US_SUP          ; Permisos de Supervisor/Usuario para el PTE
  push    PAG_US_US           ; Permisos de Supervisor/Usuario para el DPTE
  push    __DIGITS_TABLE_PHY     
  push    __DIGITS_TABLE_VMA 
  push    __CR3_TAREA_2_PHY    ; Base del DPT de la Tarea 1 
  call    set_page_rom
  leave

  ;------__SYS_TABLES_PHY-----------
  ; ->Cargo DPTE y PTE
  push    ebp
  mov     ebp, esp 
  push    PAG_RW_R            ; Permisos R/W para el PTE
  push    PAG_RW_W            ; Permisos R/W para el DPTE
  push    PAG_US_SUP          ; Permisos de Supervisor/Usuario para el PTE
  push    PAG_US_US           ; Permisos de Supervisor/Usuario para el DPTE
  push    __SYS_TABLES_PHY     
  push    __SYS_TABLES_VMA 
  push    __CR3_TAREA_2_PHY    ; Base del DPT de la Tarea 1 
  call    set_page_rom
  leave

  ;------__TAREA2_TEXT_PHY-----------
  ; ->Cargo DPTE y PTE
  push    ebp
  mov     ebp, esp 
  push    PAG_RW_R            ; Permisos R/W para el PTE
  push    PAG_RW_W            ; Permisos R/W para el DPTE
  push    PAG_US_US           ; Permisos de Supervisor/Usuario para el PTE
  push    PAG_US_US           ; Permisos de Supervisor/Usuario para el DPTE
  push    __TAREA2_TEXT_PHY     
  push    __TAREA2_TEXT_VMA 
  push    __CR3_TAREA_2_PHY    ; Base del DPT de la Tarea 1 
  call    set_page_rom
  leave

  ;------__TAREA2_BSS_PHY-----------
  ; ->Cargo DPTE y PTE
  push    ebp
  mov     ebp, esp 
  push    PAG_RW_W            ; Permisos R/W para el PTE
  push    PAG_RW_W            ; Permisos R/W para el DPTE
  push    PAG_US_US           ; Permisos de Supervisor/Usuario para el PTE
  push    PAG_US_US           ; Permisos de Supervisor/Usuario para el DPTE
  push    __TAREA2_BSS_PHY     
  push    __TAREA2_BSS_VMA 
  push    __CR3_TAREA_2_PHY    ; Base del DPT de la Tarea 1 
  call    set_page_rom
  leave

  ;------__TAREA2_DATA_PHY-----------
  ; ->Cargo DPTE y PTE
  push    ebp
  mov     ebp, esp 
  push    PAG_RW_W            ; Permisos R/W para el PTE
  push    PAG_RW_W            ; Permisos R/W para el DPTE
  push    PAG_US_US           ; Permisos de Supervisor/Usuario para el PTE
  push    PAG_US_US           ; Permisos de Supervisor/Usuario para el DPTE
  push    __TAREA2_DATA_PHY     
  push    __TAREA2_DATA_VMA 
  push    __CR3_TAREA_2_PHY    ; Base del DPT de la Tarea 1 
  call    set_page_rom
  leave
  
  ;------__TAREA1_STACK_START_PHY-----------
  ; ->Cargo DPTE y PTE
  push    ebp
  mov     ebp, esp 
  push    PAG_RW_W            ; Permisos R/W para el PTE
  push    PAG_RW_W            ; Permisos R/W para el DPTE
  push    PAG_US_US           ; Permisos de Supervisor/Usuario para el PTE
  push    PAG_US_US           ; Permisos de Supervisor/Usuario para el DPTE
  push    __TAREA2_STACK_START_PHY     
  push    __TAREA2_STACK_START_VMA 
  push    __CR3_TAREA_2_PHY    ; Base del DPT de la Tarea 1 
  call    set_page_rom
  leave

  ;------__STACK_KERNEL_PHY-----------
  ; ->Cargo DPTE y PTE
  push    ebp
  mov     ebp, esp 
  push    PAG_RW_W             ; Permisos R/W para el PTE
  push    PAG_RW_W             ; Permisos R/W para el DPTE
  push    PAG_US_SUP           ; Permisos de Supervisor/Usuario para el PTE
  push    PAG_US_US            ; Permisos de Supervisor/Usuario para el DPTE
  push    __STACK_KERNEL_PHY     
  push    __STACK_KERNEL_VMA 
  push    __CR3_TAREA_2_PHY    ; Base del DPT de la Tarea 1 
  call    set_page_rom
  leave

  ;------TSS_2-----------
  ; ->Cargo DPTE y PTE
  push    ebp
  mov     ebp, esp 
  push    PAG_RW_W          ; Permisos R/W para el PTE
  push    PAG_RW_W          ; Permisos R/W para el DPTE
  push    PAG_US_SUP        ; Permisos de Supervisor/Usuario para el PTE
  push    PAG_US_US         ; Permisos de Supervisor/Usuario para el DPTE
  push    __TSS2_VMA          ; Identitty Mapping
  push    __TSS2_VMA 
  push    __CR3_TAREA_2_PHY  ; Base del DPT del Kernel 
  call    set_page_rom
  leave
  ;------____TSS_BASICA-----------
  ; Se mapea en todas las DTP de las Tareas para que el CPU puedas ir a buscar
  ; las pilas de nivel 0.
  ; ->Cargo DPTE y PTE
  push    ebp
  mov     ebp, esp 
  push    PAG_RW_W          ; Permisos R/W para el PTE
  push    PAG_RW_W          ; Permisos R/W para el DPTE
  push    PAG_US_SUP        ; Permisos de Supervisor/Usuario para el PTE
  push    PAG_US_US         ; Permisos de Supervisor/Usuario para el DPTE
  push    __TSS_BASICA        ; Identitty Mapping
  push    __TSS_BASICA 
  push    __CR3_TAREA_2_PHY  ; Base del DPT del Kernel 
  call    set_page_rom
  leave


  ;--------------------------------------------
  ;-----------Mapeo de la Tarea 3 -------------
  ;--------------------------------------------
  ;------------__CR3_TAREA_3_PHY                            = Base del DTP de la Tarea 3
  ;------------__CR3_TAREA_3_PHY + 0x1000                   = Tamaño del DTP
  ;-----------(__CR3_TAREA_3_PHY + 0x1000)+0x1000*DPTE      = Bases de las TP

  ;------__TECLADO_ISR_PHY-----------
  ; ->Cargo DPTE y PTE
  push    ebp
  mov     ebp, esp 
  push    PAG_RW_R            ; Permiso ReadOnly para el PTE del código de los Handlers EXCEP. e IRQ
  push    PAG_RW_W            ; Permiso de Write para el DPTE que apunta a la TP
  push    PAG_US_SUP          ; Permisos de Supervisor para el PTE
  push    PAG_US_US           ; Permisos de Usuario para el DPTE
  push    __TECLADO_ISR_PHY     
  push    __TECLADO_ISR_VMA 
  push    __CR3_TAREA_3_PHY   ; Base del DPT de la Tarea 3 
  call    set_page_rom
  leave
  ;------__VGA_PHY-----------
  ; ->Cargo DPTE y PTE
  push    ebp
  mov     ebp, esp 
  push    PAG_RW_W            ; Permisos R/W para el PTE
  push    PAG_RW_W            ; Permisos R/W para el DPTE
  push    PAG_US_SUP          ; Permisos de Supervisor/Usuario para el PTE
  push    PAG_US_US           ; Permisos de Supervisor/Usuario para el DPTE
  push    __VGA_PHY     
  push    __VGA_VMA 
  push    __CR3_TAREA_3_PHY    ; Base del DPT de la Tarea 3 
  call    set_page_rom
  leave

  ;------__FUNCTIONS_PHY-----------
  ; ->Cargo DPTE y PTE
  push    ebp
  mov     ebp, esp 
  push    PAG_RW_R            ; Permisos R/W para el PTE
  push    PAG_RW_W            ; Permisos R/W para el DPTE
  push    PAG_US_SUP          ; Permisos de Supervisor/Usuario para el PTE
  push    PAG_US_US           ; Permisos de Supervisor/Usuario para el DPTE
  push    __FUNCTIONS_PHY     
  push    __FUNCTIONS_VMA 
  push    __CR3_TAREA_3_PHY    ; Base del DPT de la Tarea 3 
  call    set_page_rom
  leave

  ;------__DATOS_SYS32_PHY-----------
  ; ->Cargo DPTE y PTE
  push    ebp
  mov     ebp, esp 
  push    PAG_RW_W            ; Permisos R/W para el PTE
  push    PAG_RW_W            ; Permisos R/W para el DPTE
  push    PAG_US_SUP          ; Permisos de Supervisor/Usuario para el PTE
  push    PAG_US_US           ; Permisos de Supervisor/Usuario para el DPTE
  push    __DATOS_SYS32_PHY     
  push    __DATOS_SYS32_VMA 
  push    __CR3_TAREA_3_PHY    ; Base del DPT de la Tarea 3 
  call    set_page_rom
  leave

  ;------__DIGITS_TABLE_PHY-----------
  ; ->Cargo DPTE y PTE
  push    ebp
  mov     ebp, esp 
  push    PAG_RW_W            ; Permisos R/W para el PTE
  push    PAG_RW_W            ; Permisos R/W para el DPTE
  push    PAG_US_SUP          ; Permisos de Supervisor/Usuario para el PTE
  push    PAG_US_US           ; Permisos de Supervisor/Usuario para el DPTE
  push    __DIGITS_TABLE_PHY     
  push    __DIGITS_TABLE_VMA 
  push    __CR3_TAREA_3_PHY    ; Base del DPT de la Tarea 3 
  call    set_page_rom
  leave

  ;------__SYS_TABLES_PHY-----------
  ; ->Cargo DPTE y PTE
  push    ebp
  mov     ebp, esp 
  push    PAG_RW_R            ; Permisos R/W para el PTE
  push    PAG_RW_W            ; Permisos R/W para el DPTE
  push    PAG_US_SUP          ; Permisos de Supervisor/Usuario para el PTE
  push    PAG_US_US           ; Permisos de Supervisor/Usuario para el DPTE
  push    __SYS_TABLES_PHY     
  push    __SYS_TABLES_VMA 
  push    __CR3_TAREA_3_PHY    ; Base del DPT de la Tarea 3 
  call    set_page_rom
  leave

  ;------__TAREA3_TEXT_PHY-----------
  ; ->Cargo DPTE y PTE
  push    ebp
  mov     ebp, esp 
  push    PAG_RW_R            ; Permisos R/W para el PTE
  push    PAG_RW_W            ; Permisos R/W para el DPTE
  push    PAG_US_US           ; Permisos de Supervisor/Usuario para el PTE
  push    PAG_US_US           ; Permisos de Supervisor/Usuario para el DPTE
  push    __TAREA3_TEXT_PHY     
  push    __TAREA3_TEXT_VMA 
  push    __CR3_TAREA_3_PHY    ; Base del DPT de la Tarea 3 
  call    set_page_rom
  leave

  ;------__TAREA3_BSS_PHY-----------
  ; ->Cargo DPTE y PTE
  push    ebp
  mov     ebp, esp 
  push    PAG_RW_W            ; Permisos R/W para el PTE
  push    PAG_RW_W            ; Permisos R/W para el DPTE
  push    PAG_US_US           ; Permisos de Supervisor/Usuario para el PTE
  push    PAG_US_US           ; Permisos de Supervisor/Usuario para el DPTE
  push    __TAREA3_BSS_PHY     
  push    __TAREA3_BSS_VMA 
  push    __CR3_TAREA_3_PHY    ; Base del DPT de la Tarea 3 
  call    set_page_rom
  leave

  ;------__TAREA3_DATA_PHY-----------
  ; ->Cargo DPTE y PTE
  push    ebp
  mov     ebp, esp 
  push    PAG_RW_W            ; Permisos R/W para el PTE
  push    PAG_RW_W            ; Permisos R/W para el DPTE
  push    PAG_US_US           ; Permisos de Supervisor/Usuario para el PTE
  push    PAG_US_US           ; Permisos de Supervisor/Usuario para el DPTE
  push    __TAREA3_DATA_PHY     
  push    __TAREA3_DATA_VMA 
  push    __CR3_TAREA_3_PHY    ; Base del DPT de la Tarea 3 
  call    set_page_rom
  leave
  
  ;------__TAREA1_STACK_START_PHY-----------
  ; ->Cargo DPTE y PTE
  push    ebp
  mov     ebp, esp 
  push    PAG_RW_W            ; Permisos R/W para el PTE
  push    PAG_RW_W            ; Permisos R/W para el DPTE
  push    PAG_US_US           ; Permisos de Supervisor/Usuario para el PTE
  push    PAG_US_US           ; Permisos de Supervisor/Usuario para el DPTE
  push    __TAREA3_STACK_START_PHY     
  push    __TAREA3_STACK_START_VMA 
  push    __CR3_TAREA_3_PHY    ; Base del DPT de la Tarea 3 
  call    set_page_rom
  leave

  ;------__STACK_KERNEL_PHY-----------
  ; ->Cargo DPTE y PTE
  push    ebp
  mov     ebp, esp 
  push    PAG_RW_W             ; Permisos R/W para el PTE
  push    PAG_RW_W             ; Permisos R/W para el DPTE
  push    PAG_US_SUP           ; Permisos de Supervisor/Usuario para el PTE
  push    PAG_US_US            ; Permisos de Supervisor/Usuario para el DPTE
  push    __STACK_KERNEL_PHY     
  push    __STACK_KERNEL_VMA 
  push    __CR3_TAREA_3_PHY    ; Base del DPT de la Tarea 3 
  call    set_page_rom
  leave

  ;------TSS_3-----------
  ; ->Cargo DPTE y PTE
  push    ebp
  mov     ebp, esp 
  push    PAG_RW_W          ; Permisos R/W para el PTE
  push    PAG_RW_W          ; Permisos R/W para el DPTE
  push    PAG_US_SUP        ; Permisos de Supervisor/Usuario para el PTE
  push    PAG_US_US         ; Permisos de Supervisor/Usuario para el DPTE
  push    __TSS3_VMA          ; Identitty Mapping
  push    __TSS3_VMA 
  push    __CR3_TAREA_3_PHY  ; Base del DPT de la Tarea 3 
  call    set_page_rom
  leave

  ;------__TSS_BASICA-----------
  ; Se mapea en todas las DTP de las Tareas para que el CPU puedas ir a buscar
  ; las pilas de nivel 0.
  ; ->Cargo DPTE y PTE
  push    ebp
  mov     ebp, esp 
  push    PAG_RW_W          ; Permisos R/W para el PTE
  push    PAG_RW_W          ; Permisos R/W para el DPTE
  push    PAG_US_SUP        ; Permisos de Supervisor/Usuario para el PTE
  push    PAG_US_US         ; Permisos de Supervisor/Usuario para el DPTE
  push    __TSS_BASICA        ; Identitty Mapping
  push    __TSS_BASICA 
  push    __CR3_TAREA_3_PHY  ; Base del DPT del Kernel 
  call    set_page_rom
  leave



  ;--------------------------------------------
  ;-----------Mapeo de la Tarea 4 -------------
  ;--------------------------------------------
  ;------------__CR3_TAREA_4_PHY                            = Base del DTP de la Tarea 4
  ;------------__CR3_TAREA_4_PHY + 0x1000                   = Tamaño del DTP
  ;-----------(__CR3_TAREA_4_PHY + 0x1000)+0x1000*DPTE      = Bases de las TP

  ;------__TECLADO_ISR_PHY-----------
  ; ->Cargo DPTE y PTE
  push    ebp
  mov     ebp, esp 
  push    PAG_RW_R            ; Permiso ReadOnly para el PTE del código de los Handlers EXCEP. e IRQ
  push    PAG_RW_W            ; Permiso de Write para el DPTE que apunta a la TP
  push    PAG_US_SUP          ; Permisos de Supervisor para el PTE
  push    PAG_US_US           ; Permisos de Usuario para el DPTE
  push    __TECLADO_ISR_PHY     
  push    __TECLADO_ISR_VMA 
  push    __CR3_TAREA_4_PHY   ; Base del DPT de la Tarea 4 
  call    set_page_rom
  leave
  ;------__VGA_PHY-----------
  ; ->Cargo DPTE y PTE
  push    ebp
  mov     ebp, esp 
  push    PAG_RW_W            ; Permisos R/W para el PTE
  push    PAG_RW_W            ; Permisos R/W para el DPTE
  push    PAG_US_SUP          ; Permisos de Supervisor/Usuario para el PTE
  push    PAG_US_US           ; Permisos de Supervisor/Usuario para el DPTE
  push    __VGA_PHY     
  push    __VGA_VMA 
  push    __CR3_TAREA_4_PHY    ; Base del DPT de la Tarea 4 
  call    set_page_rom
  leave

  ;------__FUNCTIONS_PHY-----------
  ; ->Cargo DPTE y PTE
  push    ebp
  mov     ebp, esp 
  push    PAG_RW_R            ; Permisos R/W para el PTE
  push    PAG_RW_W            ; Permisos R/W para el DPTE
  push    PAG_US_SUP          ; Permisos de Supervisor/Usuario para el PTE
  push    PAG_US_US           ; Permisos de Supervisor/Usuario para el DPTE
  push    __FUNCTIONS_PHY     
  push    __FUNCTIONS_VMA 
  push    __CR3_TAREA_4_PHY    ; Base del DPT de la Tarea 4 
  call    set_page_rom
  leave

  ;------__DATOS_SYS32_PHY-----------
  ; ->Cargo DPTE y PTE
  push    ebp
  mov     ebp, esp 
  push    PAG_RW_W            ; Permisos R/W para el PTE
  push    PAG_RW_W            ; Permisos R/W para el DPTE
  push    PAG_US_SUP          ; Permisos de Supervisor/Usuario para el PTE
  push    PAG_US_US           ; Permisos de Supervisor/Usuario para el DPTE
  push    __DATOS_SYS32_PHY     
  push    __DATOS_SYS32_VMA 
  push    __CR3_TAREA_4_PHY    ; Base del DPT de la Tarea 4 
  call    set_page_rom
  leave

  ;------__DIGITS_TABLE_PHY-----------
  ; ->Cargo DPTE y PTE
  push    ebp
  mov     ebp, esp 
  push    PAG_RW_W            ; Permisos R/W para el PTE
  push    PAG_RW_W            ; Permisos R/W para el DPTE
  push    PAG_US_SUP          ; Permisos de Supervisor/Usuario para el PTE
  push    PAG_US_US           ; Permisos de Supervisor/Usuario para el DPTE
  push    __DIGITS_TABLE_PHY     
  push    __DIGITS_TABLE_VMA 
  push    __CR3_TAREA_4_PHY    ; Base del DPT de la Tarea 4 
  call    set_page_rom
  leave

  ;------__SYS_TABLES_PHY-----------
  ; ->Cargo DPTE y PTE
  push    ebp
  mov     ebp, esp 
  push    PAG_RW_R            ; Permisos R/W para el PTE
  push    PAG_RW_W            ; Permisos R/W para el DPTE
  push    PAG_US_SUP          ; Permisos de Supervisor/Usuario para el PTE
  push    PAG_US_US           ; Permisos de Supervisor/Usuario para el DPTE
  push    __SYS_TABLES_PHY     
  push    __SYS_TABLES_VMA 
  push    __CR3_TAREA_4_PHY    ; Base del DPT de la Tarea 4 
  call    set_page_rom
  leave

  ;------__TAREA4_TEXT_PHY-----------
  ; ->Cargo DPTE y PTE
  push    ebp
  mov     ebp, esp 
  push    PAG_RW_R            ; Permisos R/W para el PTE
  push    PAG_RW_W            ; Permisos R/W para el DPTE
  push    PAG_US_US           ; Permisos de Supervisor/Usuario para el PTE
  push    PAG_US_US           ; Permisos de Supervisor/Usuario para el DPTE
  push    __TAREA4_TEXT_PHY     
  push    __TAREA4_TEXT_VMA 
  push    __CR3_TAREA_4_PHY    ; Base del DPT de la Tarea 4 
  call    set_page_rom
  leave

  ;------__TAREA4_BSS_PHY-----------
  ; ->Cargo DPTE y PTE
  push    ebp
  mov     ebp, esp 
  push    PAG_RW_W            ; Permisos R/W para el PTE
  push    PAG_RW_W            ; Permisos R/W para el DPTE
  push    PAG_US_US           ; Permisos de Supervisor/Usuario para el PTE
  push    PAG_US_US           ; Permisos de Supervisor/Usuario para el DPTE
  push    __TAREA4_BSS_PHY     
  push    __TAREA4_BSS_VMA 
  push    __CR3_TAREA_4_PHY    ; Base del DPT de la Tarea 4 
  call    set_page_rom
  leave

  ;------__TAREA4_DATA_PHY-----------
  ; ->Cargo DPTE y PTE
  push    ebp
  mov     ebp, esp 
  push    PAG_RW_W            ; Permisos R/W para el PTE
  push    PAG_RW_W            ; Permisos R/W para el DPTE
  push    PAG_US_US           ; Permisos de Supervisor/Usuario para el PTE
  push    PAG_US_US           ; Permisos de Supervisor/Usuario para el DPTE
  push    __TAREA4_DATA_PHY     
  push    __TAREA4_DATA_VMA 
  push    __CR3_TAREA_4_PHY    ; Base del DPT de la Tarea 4 
  call    set_page_rom
  leave
  
  ;------__TAREA4_STACK_START_PHY-----------
  ; ->Cargo DPTE y PTE
  push    ebp
  mov     ebp, esp 
  push    PAG_RW_W            ; Permisos R/W para el PTE
  push    PAG_RW_W            ; Permisos R/W para el DPTE
  push    PAG_US_US           ; Permisos de Supervisor/Usuario para el PTE
  push    PAG_US_US           ; Permisos de Supervisor/Usuario para el DPTE
  push    __TAREA4_STACK_START_PHY     
  push    __TAREA4_STACK_START_VMA 
  push    __CR3_TAREA_4_PHY    ; Base del DPT de la Tarea 4 
  call    set_page_rom
  leave

  ;------__STACK_KERNEL_PHY-----------
  ; ->Cargo DPTE y PTE
  push    ebp
  mov     ebp, esp 
  push    PAG_RW_W             ; Permisos R/W para el PTE
  push    PAG_RW_W             ; Permisos R/W para el DPTE
  push    PAG_US_SUP           ; Permisos de Supervisor/Usuario para el PTE
  push    PAG_US_US            ; Permisos de Supervisor/Usuario para el DPTE
  push    __STACK_KERNEL_PHY     
  push    __STACK_KERNEL_VMA 
  push    __CR3_TAREA_4_PHY    ; Base del DPT de la Tarea 3 
  call    set_page_rom
  leave

  ;------TSS_4-----------
  ; ->Cargo DPTE y PTE
  push    ebp
  mov     ebp, esp 
  push    PAG_RW_W          ; Permisos R/W para el PTE
  push    PAG_RW_W          ; Permisos R/W para el DPTE
  push    PAG_US_SUP        ; Permisos de Supervisor/Usuario para el PTE
  push    PAG_US_US         ; Permisos de Supervisor/Usuario para el DPTE
  push    __TSS4_VMA          ; Identitty Mapping
  push    __TSS4_VMA 
  push    __CR3_TAREA_4_PHY  ; Base del DPT de la Tarea 4 
  call    set_page_rom
  leave
  
  ;------____TSS_BASICA-----------
  ; Se mapea en todas las DTP de las Tareas para que el CPU puedas ir a buscar
  ; las pilas de nivel 0.
  ; ->Cargo DPTE y PTE
  push    ebp
  mov     ebp, esp 
  push    PAG_RW_W          ; Permisos R/W para el PTE
  push    PAG_RW_W          ; Permisos R/W para el DPTE
  push    PAG_US_SUP        ; Permisos de Supervisor/Usuario para el PTE
  push    PAG_US_US         ; Permisos de Supervisor/Usuario para el DPTE
  push    __TSS_BASICA        ; Identitty Mapping
  push    __TSS_BASICA 
  push    __CR3_TAREA_4_PHY  ; Base del DPT del Kernel 
  call    set_page_rom
  leave

  ;--------------------------------------------
  ;-----------FIN PAGINACIÓN-------------------
  ;--------------------------------------------

  ; -> Habilito la paginación
  mov   eax, cr0 
  or    eax, X86_CR0_PG
  mov   cr0, eax

  ; ------------- HASTA ACA ANDA, PAGINA BIEN. HUBO QUE CAMBIAR BASES DE LOS CR3 PORQUE SE PISABAN.--------------
  ;-----------------------------------------------------------------------------------------------

  ;--------------------------------------------
  ;-> Inicializo las TSS de las Tareas
  ;--------------------------------------------
  ; __TSS_BASICA                    = 0x40000000;
  ; __TSS1_VMA                      = 0x40001000;
  ; __TSS2_VMA                      = 0x40002000;
  ; __TSS3_VMA                      = 0x40003000;
  ; __TSS4_VMA                      = 0x40004000;

  ; -------------TSS_1--------------
  push    ebp
  mov     ebp, esp 
  push    __TSS1_VMA                      ; TSS de la tarea
  push    __CR3_TAREA_1_PHY               ; CR3 de la tarea
  push    __TAREA1_STACK_END_VMA          ; STACK de la tarea
  push    __STACK_KERNEL_TAREA1_END_VMA   ; STACK del Kernel
  push    ejecutar_tarea_1                ; Dir. de inicio de la tarea
  call init_tss
  leave

  ; -------------TSS_2--------------
  push    ebp
  mov     ebp, esp 
  push     __TSS2_VMA                      ; TSS de la tarea
  push     __CR3_TAREA_2_PHY               ; CR3 de la tarea
  push     __TAREA2_STACK_END_VMA          ; STACK de la tarea
  push     __STACK_KERNEL_TAREA2_END_VMA   ; STACK del Kernel
  push     ejecutar_tarea_2                ; Dir. de inicio de la tarea
  call init_tss
  leave

  ; -------------TSS_3--------------
  push    ebp
  mov     ebp, esp 
  push     __TSS3_VMA                      ; TSS de la tarea
  push     __CR3_TAREA_3_PHY               ; CR3 de la tarea
  push     __TAREA3_STACK_END_VMA          ; STACK de la tarea
  push     __STACK_KERNEL_TAREA3_END_VMA   ; STACK del Kernel
  push     ejecutar_tarea_3                ; Dir. de inicio de la tarea
  call init_tss
  leave

  ; -------------TSS_4--------------
  push    ebp
  mov     ebp, esp 
  push    __TSS4_VMA                      ; TSS de la tarea
  push    __CR3_TAREA_4_PHY               ; CR3 de la tarea
  push    __TAREA4_STACK_END_VMA          ; STACK de la tarea
  push    __STACK_KERNEL_TAREA4_END_VMA   ; STACK del Kernel
  push    ejecutar_tarea_4                ; Dir. de inicio de la tarea
  call init_tss
  leave

  ; -------------TSS_BASICA para el CPU--------------
  push    ebp
  mov     ebp, esp 
  push    __TSS_BASICA                    ; TSS para el CPU
  push    __CR3_KERNEL_PHY                ; CR3 del Kernel
  push    __TAREA4_STACK_END_VMA          ; STACK de la tarea que primero corre. (la TAREA 4 - HALT)
  push    __STACK_KERNEL_TAREA4_END_VMA   ; STACK del Kernel
  push    kernel32_init                   ; Dir. de inicio del Kernel
  call    init_tss
  leave

 ;-> Cargo Selector de la TSS_BASICA
  mov     ax, TSS_SEL
  ltr     ax

  ; -> Habilito interrupciones
  sti                                   
  jmp CS_SEL_00:kernel32_init             ; Salto en memoria a la sección del Kernel

.guard:
  hlt
  jmp .guard


