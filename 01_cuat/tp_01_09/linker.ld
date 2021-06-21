/* Linker */
ENTRY (reset)

    __EH_FRAME = 0x00060000; /* Exception Handler Frame para C. En ese pedazo de RAM se puede utilizar para excepciones. Sirve para mezclar C y asm */


    /* ********************************* */
    /*------------STACKs---------------- */
    /* ********************************* */

    __STACK_START_16        = 0x9000;
    __STACK_END_16          = 0x09FFF;
    __STACK_SIZE_32         = ((__STACK_END_32_VMA - __STACK_START_32_VMA) / 4); /* 32b word */
    __TAREA1_STACK_SIZE     = ((__TAREA1_STACK_END_VMA - __TAREA1_STACK_START_VMA) / 4); 


 /*     ------------------------------------------------------------
        *Direccion Fisica:              *Direccion Lineal:
        ------------------------------------------------------------
        *Sys_tables      0x00000000    *Sys_tables      0x00000000    
        *Tablas de Pag.  0x00010000    *Tablas de Pag.  0x00010000    
        *Rutinas         0x00050000    *Rutinas         0x00050000    
        *RAM VIDEO       0x000B8000    *RAM VIDEO       0x00E80000  
        *Teclado + ISR   0x00100000    *Teclado + ISR   0x00100000    
        *Datos           0x00200000    *Datos           0x01200000
        *Digitos         0x00210000    *Digitos         0x01210000    
        *Kernel          0x00220000    *Kernel          0x01220000    
        *Tarea 1 TEXT    0x00310000    *Tarea 1 TEXT    0x01310000    
        *Tarea 1 BSS     0x00320000    *Tarea 1 BSS     0x01320000    
        *Tarea 1 DATA    0x00330000    *Tarea 1 DATA    0x01330000    
        *Tarea 1 RODATA  0x00340000    *Tarea 1 RODATA  0x01340000    
        *Stack Sistema   0x1FFF8000    *Stack Sistema   0x1FFF8000    
        *Stack Tarea 1   0x1FFFF000    *Stack Tarea 1   0x0078F000    
        *Init ROM        0xFFFF0000    *Init ROM        0xFFFF0000    
        *Reset Vector    0xFFFFFFF0    *Reset Vector    0xFFFFFFF0
*/



    /* ************************************************/
    /*------------PHYSICAL ADDRESS---------------- */
    /* ************************************************/

    __SYS_TABLES_PHY            = 0x00000000;           /* GDT e IDT (Pide el enunciado) */
    __PAGE_TABLES_PHY           = 0x00010000;           /* Tablas de paginación. Es la base de la DPT (Directorio de Tablas de Página). Se carga en el CR3. (Pide el enunciado) */
    __FUNCTIONS_PHY             = 0x00050000;           /* Rutinas (Elijo)*/
    __VGA_PHY                   = 0x000B8000;           /* VGA en RAM (Elijo) */
    __TECLADO_ISR_PHY           = 0x00100000;           /* Teclado + ISR (Pide el enunciado) */
    __DATOS_SYS32_PHY           = 0x00200000;           /* Reservado para datos. */
    __DIGITS_TABLE_PHY          = 0x00210000;           /* Tabla de dígitos de teclado (Pide el enunciado) */
    __KERNEL_32_PHY             = 0x00220000;           /* Kernel (Pide el enunciado) */
    __TAREA1_TEXT_PHY           = 0x00310000;           /* TEXT de TAREA 1 (Pide el enunciado) */
    __TAREA1_BSS_PHY            = 0x00320000;           /* BSS de TAREA 1 (Pide el enunciado) */
    __TAREA1_DATA_PHY           = 0x00330000;           /* DATA de TAREA 1 (Pide el enunciado) */
    __TAREA1_RODATA_PHY         = 0x00340000;           /* RODATA de TAREA 1 (Pide el enunciado) */
    __STACK_START_32_PHY        = 0x1FFF8000;           /* Inicio de Pila general (Pide el enunciado) */
    __STACK_END_32_PHY          = 0x1FFF8FFF;           /* Fin de Pila general (Elijo)*/
    __TAREA1_STACK_START_PHY    = 0x1FFFF000;           /* STACK START para TAREA 1 (Pide el enunciado) */
    __TAREA1_STACK_END_PHY      = 0x1FFFFFFF;           /* STACK END para TAREA 1 (Elijo)*/

    /* *********************************************************/
    /*------------VMA (Virtual Mem. Address)-------------------*/
    /* *********************************************************/
    __SYS_TABLES_VMA            = 0x00000000;         
    __PAGE_TABLES_VMA           = 0x00010000;         
    __FUNCTIONS_VMA             = 0x00050000;         
    __VGA_VMA                   = 0x00E80000;         
    __TECLADO_ISR_VMA           = 0x00100000;         
    __DATOS_SYS32_VMA           = 0x01200000;         
    __DIGITS_TABLE_VMA          = 0x01210000;         
    __KERNEL_32_VMA             = 0x01220000;         
    __TAREA1_TEXT_VMA           = 0x01310000;         
    __TAREA1_BSS_VMA            = 0x01320000;         
    __TAREA1_DATA_VMA           = 0x01330000;         
    __TAREA1_RODATA_VMA         = 0x01340000; 
    __STACK_START_32_VMA        = 0x1FFF8000; 
    __STACK_END_32_VMA          = 0x1FFF8FFF;
    __TAREA1_STACK_START_VMA    = 0x0078F000; 
    __TAREA1_STACK_END_VMA      = 0x0078FFFF;          
    __INIT_ROM_VMA              = 0xFFFF0000;      
    __RESET_VMA                 = 0xFFFFFFF0;
    __INIT_ROM_VMA              = __INIT_ROM_LMA;       /* Inicialización ROM (Pide el enunciado) */
    __INIT_16_VMA               = __INIT_16_LMA;        /* Inicialización en 16 bits. */
    __VGA_INIT_VMA              = __VGA_INIT_LMA;       /* Inicialización de pantalla VGA */
    __INIT_32_VMA               = __INIT_32_LMA;        /* Inicialización de Modo Protegido */
    __FUNCTIONS_ROM_VMA         = __FUNCTIONS_ROM_LMA;  /* Sección de código para el ejercicio. Tenemos grado de libertad para definirlas, dentro de un lugar conveniente. */
    __RESET_VMA                 = __RESET_LMA;

    /* *********************************************************/
    /* -----------LMA (Loadable Mem. Address)------------------*/
    /* *********************************************************/

    /* VMA != LMA (se van a ejecutar en RAM) */
    __INIT_ROM_LMA          = 0xFFFF0000;
    __SYS_TABLES_LMA        = __INIT_ROM_LMA ;
/*  __FUNCTIONS_LMA       
    __TECLADO_ISR_LMA      
    __DATOS_LMA             
    __KERNEL_32_LMA         
    __TASK_01_TEXT_LMA      
    __TASK_01_BSS_LMA       
    __TASK_01_DATA_LMA      
    __TASK_01_RODATA_LMA  */ 

    /* VMA = LMA (se van a ejecutar en ROM) */

    __INIT_16_LMA           = 0xFFFF8000;                       
/*  __VGA_INIT_LMA          
    __INIT_32_LMA           
    __FUNCTIONS_ROM_LMA    */ 
    __RESET_LMA             = 0xFFFFFFF0;
             


/* ********************************* */
/* MEMORY Restrictions*/
/* ********************************* */
MEMORY
{
  ram (!x):        ORIGIN = 0x00000000,    LENGTH = 0xFFFF0000
  rom (rx):        ORIGIN = 0xFFFF0000,    LENGTH = 64K

}

/* ********************************* */
/* --------------SECTIONS------------*/
/* ********************************* */

SECTIONS
{
/* ********************************* */
/* Secciones de RAM (VMA != LMA)*/
/* ********************************* */

    .sys_tables_32 __SYS_TABLES_VMA :
        AT ( __SYS_TABLES_LMA )
        { *(.sys_tables);} > ram
    __sys_tables_size = SIZEOF(.sys_tables_32);

    __FUNCTIONS_LMA = LOADADDR(.sys_tables_32) + SIZEOF(.sys_tables_32);

    .functions __FUNCTIONS_VMA :
        AT ( __FUNCTIONS_LMA )
        { *(.functions_c);
          ./bin/functions.elf(.note*);
          ./bin/functions.elf(.bss);
          ./bin/functions.elf(.data);
          ./bin/functions.elf(.rodata);
        } > ram 
    __functions_size = SIZEOF(.functions);

    __TECLADO_ISR_LMA = LOADADDR(.functions) + SIZEOF(.functions);
 
     .handlers_ISR __TECLADO_ISR_VMA :
        AT( __TECLADO_ISR_LMA )
        { *(.teclado_and_ISR);} > ram                
    __handlers_32_size = SIZEOF(.handlers_ISR);

    __DATOS_SYS32_LMA = LOADADDR(.handlers_ISR) + SIZEOF(.handlers_ISR);

/* La sección de entrada la tengo en el archivo main.s, debajo de la sección kernel32 */
    .datos_sys32 __DATOS_SYS32_VMA :
        AT ( __DATOS_SYS32_LMA )
        { ./bin/main.elf(.data);} > ram
    __data_size = SIZEOF(.datos_sys32);

    __KERNEL_32_LMA = LOADADDR(.datos_sys32) + SIZEOF(.datos_sys32);

    .codigo_kernel32 __KERNEL_32_VMA :                  /* Ubicación en VMA (RAM) a la que deberá copiarse el código en tiempo de ejecución  */
        AT ( __KERNEL_32_LMA )                          /* Ubicación inicial del código en LMA (ROM) */
        { *(.kernel32); } > ram                         /* Toda esta sección de salida DEBE estar en RAM */
    __codigo_kernel32_size = SIZEOF(.codigo_kernel32);  /* Variable disponible utilizando EXTERN para el código */

/* ********************************* */
/* Secciones de salida de la TAREA 1 */
/* ********************************* */
    __TAREA1_TEXT_LMA = LOADADDR(.codigo_kernel32) + SIZEOF(.codigo_kernel32);

/* Funciones de la tarea 1 */
    .tarea_1_text __TAREA1_TEXT_VMA :
        AT (__TAREA1_TEXT_LMA)
        {*(.functions_tarea_1);
        ./bin/tarea_1.elf(.note*);} > ram
    __tarea_01_size = SIZEOF(.tarea_1_text); 

    __TAREA1_BSS_LMA = LOADADDR(.tarea_1_text) + SIZEOF(.tarea_1_text);
/* Variables no inicializadas de la tarea 1 */
    .tarea_1_bss __TAREA1_BSS_VMA :
        AT (__TAREA1_BSS_LMA)
        {./bin/tarea_1.elf(.bss);} > ram
    __tarea_1_bss_size = SIZEOF(.tarea_1_bss); 

    __TAREA1_DATA_LMA = LOADADDR(.tarea_1_bss) + SIZEOF(.tarea_1_bss);
/* Variables inicializadas */
    .tarea_1_data __TAREA1_DATA_VMA :
        AT (__TAREA1_DATA_LMA)
        {./bin/tarea_1.elf(.data);} > ram
    __tarea_1_data_size = SIZEOF(.tarea_1_data); 

    __TAREA1_RODATA_LMA = LOADADDR(.tarea_1_data) + SIZEOF(.tarea_1_data);  
/* Variables de solo lectura. */
    .tarea_1_rodata __TAREA1_RODATA_VMA :
        AT (__TAREA1_RODATA_LMA)
        {./bin/tarea_1.elf(.rodata);} > ram
    __tarea_1_rodata_size = SIZEOF(.tarea_1_rodata); 

/* ********************************* */
/* Secciones de ROM (VMA = LMA)*/
/* ********************************* */

    .codigo_init16 __INIT_16_VMA :
        AT ( __INIT_16_LMA )
        { *(.ROM_init); } > rom 

    __VGA_INIT_LMA = LOADADDR(.codigo_init16) + SIZEOF(.codigo_init16);

    .video_init __VGA_INIT_VMA :
        AT (__VGA_INIT_LMA )
        {*(.vga_init);} > rom


    __INIT_32_LMA = LOADADDR(.video_init) + SIZEOF(.video_init);

    .codigo_init32 __INIT_32_VMA :
        AT ( __INIT_32_LMA )
        { *(.start32); } > rom 

    __FUNCTIONS_ROM_LMA = LOADADDR(.codigo_init32) + SIZEOF(.codigo_init32);


    .functions_rom __FUNCTIONS_ROM_VMA :
        AT ( __FUNCTIONS_ROM_LMA )
        { *(.functions_rom);
          *(.functions_asm_rom);
          *(.note.gnu.property);
          ./bin/functions_rom.elf(.note*);
          ./bin/functions_rom.elf(.data);
          ./bin/functions_rom.elf(.bss);
          ./bin/functions_rom.elf(.rodata)} > rom

    .codigo_reset __RESET_VMA :
        AT ( __RESET_LMA )
        { *(.resetVector); } > rom

/* 
    .fill_rom :
        { FILL(0x90);
          . = ORIGIN(rom) + LENGTH(rom)-1;      
          BYTE(0x90);
        } > rom */

}