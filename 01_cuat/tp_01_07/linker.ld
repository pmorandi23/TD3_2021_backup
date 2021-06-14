/* Linker */
ENTRY (reset)

    __EH_FRAME = 0x00060000; /* Exception Handler Frame para C. En ese pedazo de RAM se puede utilizar para excepciones. Sirve para mezclar C y asm */

    __STACK_START_16        = 0x9000;
    __STACK_END_16          = 0x09FFF;
    __STACK_SIZE_32         = ((__STACK_END_32 - __STACK_START_32) / 4); /* 32b word */

    /* Mapa de memoria:

        Tablas de sistema------------0x00000000
        Rutina de teclado e ISR------0x00100000
        Tabla de dígitos-------------0x00200000
        Kernel-----------------------0x00202000
        Datos------------------------0x00210000
        Tarea 1----------------------0x00300000
        Pila-------------------------0x2FFF8000
        Inicialización ROM-----------0xFFFF0000
        Vector de reset--------------0xFFFFFFFF
          */

    /*------------VMA---------------- */
    __SYS_TABLES_VMA        = 0x00000000; /* GDT e IDT (Pide el enunciado) */
    __FUNCTIONS_VMA         = 0x00010000; /* Rutinas (Elijo)*/
    __VGA_VMA               = 0x000B8000; /* VGA en RAM (Elijo) */
    __TECLADO_ISR_VMA       = 0x00100000; /* Teclado + ISR (Pide el enunciado) */
    __DIGITS_TABLE          = 0x00200000; /* Tabla de dígitos de teclado (Pide el enunciado) */
    __KERNEL_32_VMA         = 0x00202000; /* Kernel (Pide el enunciado) */
    __DATA_VMA              = 0x00210000; /* Reservado para datos. */
    __TAREA_1_VMA           = 0x00300000; /* Tarea 1 (Pide el enunciado) */
    __STACK_START_32        = 0x2FFF8000; /* Inicio de Pila (Pide el enunciado) */
    __STACK_END_32          = 0x2FFF8FFF; /* Fin de Pila (lo elijo) 4KB -1 de stack en modo protegido */
    __INIT_16_VMA           = 0xFFFF0000; /* Inicialización ROM (Pide el enunciado) */
    __VGA_INIT_VMA          = 0xFFFF5000; /* Inicialización de pantalla VGA */
    __INIT_32_VMA           = 0xFFFFF800; /* Inicialización de Modo Protegido */
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
    __INIT_32_LMA           = 0xFFFFF800;
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