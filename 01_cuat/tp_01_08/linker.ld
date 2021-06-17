/* Linker */
ENTRY (reset)

    __EH_FRAME = 0x00060000; /* Exception Handler Frame para C. En ese pedazo de RAM se puede utilizar para excepciones. Sirve para mezclar C y asm */

    __STACK_START_16        = 0x9000;
    __STACK_END_16          = 0x09FFF;
    __STACK_SIZE_32         = ((__STACK_END_32 - __STACK_START_32) / 4); /* 32b word */
    __TAREA1_STACK_SIZE     = ((__TAREA1_STACK_END - __TAREA1_STACK_START) / 4); 

    /* Mapa de memoria:

        Sección                         Dirección inicial
        Tablas de sistema---------------00000000h
        Tablas de Paginación------------00010000h
        Video---------------------------000B8000h
        ISRs----------------------------00100000h
        Datos---------------------------00200000h
        Tabla de Dígitos----------------00210000h
        Kernel--------------------------00220000h
        TEXT Tarea1---------------------00310000h
        BSS Tarea 1---------------------00320000h
        Data Tarea 1--------------------00330000h
        RODATA Tarea 1------------------00340000h
        Pila Kernel---------------------1FFF8000h
        PIla Tarea 1--------------------1FFFF000h
        Secuencia inicialización ROM----FFFF0000h
        Vector de reset-----------------FFFFFFF0h
          */

    /*------------VMA---------------- */
    __SYS_TABLES_VMA        = 0x00000000; /* GDT e IDT (Pide el enunciado) */
    __PAGE_TABLES_VMA       = 0x00010000; /* Tablas de paginación. Es la base de la DPT (Directorio de Tablas de Página). Se carga en el CR3. (Pide el enunciado) */
    __FUNCTIONS_VMA         = 0x00050000; /* Rutinas (Elijo)*/
    __VGA_VMA               = 0x000B8000; /* VGA en RAM (Elijo) */
    __TECLADO_ISR_VMA       = 0x00100000; /* Teclado + ISR (Pide el enunciado) */
    __DATA_VMA              = 0x00200000; /* Reservado para datos. */
    __DIGITS_TABLE          = 0x00210000; /* Tabla de dígitos de teclado (Pide el enunciado) */
    __KERNEL_32_VMA         = 0x00220000; /* Kernel (Pide el enunciado) */
    /* __TAREA_1_VMA           = 0x00310000; */ /* TAREA 1 (Pide el enunciado) */
    __TAREA1_TEXT_VMA       = 0x00310000; /* TEXT de TAREA 1 (Pide el enunciado) */
    __TAREA1_BSS_VMA        = 0x00320000; /* BSS de TAREA 1 (Pide el enunciado) */
    __TAREA1_DATA_VMA       = 0x00330000; /* DATA de TAREA 1 (Pide el enunciado) */
    __TAREA1_RODATA_VMA     = 0x00340000; /* RODATA de TAREA 1 (Pide el enunciado) */
    __STACK_START_32        = 0x1FFF8000; /* Inicio de Pila general (Pide el enunciado) */
    __STACK_END_32          = 0x1FFF8FFF; /* Fin de Pila general (Elijo)*/
    __TAREA1_STACK_START    = 0x1FFFF000; /* STACK START para TAREA 1 (Pide el enunciado) */
    __TAREA1_STACK_END      = 0x1FFFFFFF; /* STACK END para TAREA 1 (Elijo)*/
    __INIT_16_VMA           = 0xFFFF0000; /* Inicialización ROM (Pide el enunciado) */
    __VGA_INIT_VMA          = 0xFFFF5000; /* Inicialización de pantalla VGA */
    __INIT_32_VMA           = 0xFFFFB000; /* Inicialización de Modo Protegido */
    __FUNCTIONS_ROM_VMA     = 0xFFFFFC00; /* Sección de código para el ejercicio. Tenemos grado de libertad para definirlas, dentro de un lugar conveniente. */
    __RESET_VMA             = 0xFFFFFFF0;
    /* -----------LMA----------------- */
    /* Códigos ensamblados */
    __INIT_16_LMA           = 0xFFFF0000; 
    __DATA_LMA              = 0xFFFF1000;
    __FUNCTIONS_LMA         = 0xFFFF2000; 
    __KERNEL_32_LMA         = 0xFFFF3000; 
    __TECLADO_ISR_LMA       = 0xFFFF4000;
    __VGA_INIT_LMA          = 0xFFFF5000;
    __TAREA_1_LMA           = 0xFFFF6500;
    __INIT_32_LMA           = 0xFFFFB000;
    __FUNCTIONS_ROM_LMA     = 0xFFFFFC00; 
    __SYS_TABLES_LMA        = 0xFFFFFD00;
    __RESET_LMA             = 0xFFFFFFF0;
    

/* Restricciones de MEMORY sirven para evitar errores en el mapa de memoria */

MEMORY
{
  ram (!x):        ORIGIN = 0x00000000,    LENGTH = 0xFFFF0000
  rom (rx):        ORIGIN = 0xFFFF0000,    LENGTH = 64K

}
/* Secciones ordenas por VMA */
SECTIONS
{

    .sys_tables_32 __SYS_TABLES_VMA :
        AT ( __SYS_TABLES_LMA )
        { *(.sys_tables);} > ram
    __sys_tables_size = SIZEOF(.sys_tables_32);

    .functions __FUNCTIONS_VMA :
        AT ( __FUNCTIONS_LMA )
        { *(.functions_c);
          *(.functions_asm) } > ram 
    __functions_size = SIZEOF(.functions);

   
     .handlers __TECLADO_ISR_VMA :
        AT( __TECLADO_ISR_LMA )
        { *(.teclado_and_ISR);} > ram                
    __handlers_32_size = SIZEOF(.handlers);


    .codigo_kernel32 __KERNEL_32_VMA :                  /* Ubicación en VMA (RAM) a la que deberá copiarse el código en tiempo de ejecución  */
        AT ( __KERNEL_32_LMA )                          /* Ubicación inicial del código en LMA (ROM) */
        { *(.kernel32); } > ram                         /* Toda esta sección de salida DEBE estar en RAM */
    __codigo_kernel32_size = SIZEOF(.codigo_kernel32);  /* Variable disponible utilizando EXTERN para el código */

    .data __DATA_VMA :
        AT ( __DATA_LMA )
        { *(.data);
          *(.rodata);
          *(.bss) } > ram
    __data_size = SIZEOF(.data);

    .tarea_1 __TAREA_1_VMA :
        AT (__TAREA_1_LMA)
        {*(.tarea_1);} > ram
    __codigo_tarea_01_size = SIZEOF(.tarea_1); 


/* Secciones de ROM */
    .video_init __VGA_INIT_VMA :
        AT (__VGA_INIT_LMA )
        {*(.vga_init);} > rom

    .codigo_init16 __INIT_16_VMA :
        AT ( __INIT_16_LMA )
        { *(.ROM_init); } > rom 

    .codigo_init32 __INIT_32_VMA :
        AT ( __INIT_32_LMA )
        { *(.start32); } > rom 

    .functions_rom __FUNCTIONS_ROM_VMA :
        AT ( __FUNCTIONS_ROM_LMA )
        { *(.functions_rom);
          *(.note.gnu.property)} > rom

    .codigo_reset __RESET_VMA :
        AT ( __RESET_LMA )
        { *(.resetVector); } > rom

}