/* Linker */
ENTRY (reset)

    __EH_FRAME                  = 0x00060000; /* Exception Handler Frame para C. En ese pedazo de RAM se puede utilizar para excepciones. Sirve para mezclar C y asm */

    /* ********************************* */
    /*------------STACK DE 16 bits---------------- */
    /* ********************************* */

    __STACK_START_16            = 0x9000;
    __STACK_END_16              = 0x09FFF;
    __STACK_SIZE_32             = ((__STACK_KERNEL_END_VMA - __STACK_KERNEL_VMA) / 4); /* 32b word */

    /*  ------------------ MAPA DE MEMORIA -------------------------
        ------------------------------------------------------------
        *Direccion Física:              *Direccion Lineal:
        ------------------------------------------------------------
        *Sys_tables      0x0000-0000    *Sys_tables      0x0000-0000    
        *Tablas de Pag.  0x0001-0000    *Tablas de Pag.  0x0001-0000    
        *Rutinas         0x0005-0000    *Rutinas         0x0005-0000    
        *RAM VIDEO       0x000B-8000    *RAM VIDEO       0x00E8-0000  
        *Teclado + ISR   0x0010-0000    *Teclado + ISR   0x0010-0000    
        *Datos           0x0020-0000    *Datos           0x0120-0000
        *Digitos         0x0021-0000    *Digitos         0x0121-0000    
        *Kernel          0x0022-0000    *Kernel          0x0122-0000

        *Tarea 1 TEXT    0x0031-0000    *Tarea 1 TEXT    0x0131-0000    
        *Tarea 1 BSS     0x0032-0000    *Tarea 1 BSS     0x0132-0000    
        *Tarea 1 DATA    0x0033-0000    *Tarea 1 DATA    0x0133-0000    
        *Tarea 1 RODATA  0x0034-0000    *Tarea 1 RODATA  0x0134-0000
        
        *Tarea 2 TEXT    0x0041-1000    *Tarea 2 TEXT    0x0141-0000    
        *Tarea 2 BSS     0x0042-0000    *Tarea 2 BSS     0x0142-0000    
        *Tarea 2 DATA    0x0043-0000    *Tarea 2 DATA    0x0143-0000    
        *Tarea 2 RODATA  0x0044-0000    *Tarea 2 RODATA  0x0144-0000
        
        *Tarea 3 TEXT    0x0051-0000    *Tarea 3 TEXT    0x0151-0000    
        *Tarea 3 BSS     0x0052-0000    *Tarea 3 BSS     0x0152-0000    
        *Tarea 3 DATA    0x0053-0000    *Tarea 3 DATA    0x0153-0000    
        *Tarea 3 RODATA  0x0054-0000    *Tarea 3 RODATA  0x0154-0000
        
        *Tarea 4 TEXT    0x0061-0000    *Tarea 4 TEXT    0x0161-0000    
        *Tarea 4 BSS     0x0062-0000    *Tarea 4 BSS     0x0162-0000    
        *Tarea 4 DATA    0x0063-0000    *Tarea 4 DATA    0x0163-0000    
        *Tarea 4 RODATA  0x0064-0000    *Tarea 4 RODATA  0x0164-0000
        
        *Stack Sistema   0x1FFF-8000    *Stack Sistema   0x1FFF-8000    
        *Stack Tarea 1   0x1FFF-F000    *Stack Tarea 1   0x0078-F000    
        *Stack Tarea 2   0x3000-0000    *Stack Tarea 2   0x2FFF-1000    
        *Stack Tarea 3   0x3001-0000    *Stack Tarea 3   0x2FFF-2000    
        *Stack Tarea 4   0x3002-0000    *Stack Tarea 4   0x2FFF-3000    

        *Init ROM        0xFFFF-0000    *Init ROM        0xFFFF-0000    
        *Reset Vector    0xFFFF-FFF0    *Reset Vector    0xFFFF-FFF0 
    */

    /* ************************************************/
    /*---------------PHYSICAL ADDRESS---------------- */
    /* ************************************************/

    __SYS_TABLES_PHY                = 0x00000000;           /* GDT e IDT (Pide el enunciado) */
    /* -------- TABLAS DE PAGINAS--------- */
    __PAGE_TABLES_PHY               = 0x00010000;           /* Tablas de paginación. Es la base de la DPT (Directorio de Tablas de Página). Se carga en el CR3. (Pide el enunciado) */
    __CR3_KERNEL_PHY                = 0x00010000; 
    __CR3_TAREA_1_PHY               = 0x01000000; 
    __CR3_TAREA_2_PHY               = 0x02000000;
    __CR3_TAREA_3_PHY               = 0x03000000; 
    __CR3_TAREA_4_PHY               = 0x00050000;
    __FUNCTIONS_PHY                 = 0x00060000;           /* Rutinas (Elijo)*/
    __VGA_PHY                       = 0x000B8000;           /* VGA en RAM (Elijo) */
    __TECLADO_ISR_PHY               = 0x00100000;           /* Teclado + ISR (Pide el enunciado) */
    __DATOS_SYS32_PHY               = 0x00200000;           /* Reservado para datos. */
    __DIGITS_TABLE_PHY              = 0x00210000;           /* Tabla de dígitos de teclado (Pide el enunciado) */
    __KERNEL_32_PHY                 = 0x00220000;           /* Kernel (Pide el enunciado) */
    /* ------------- TAREAS--------------- */
    __TAREA1_TEXT_PHY               = 0x00310000;           /* TEXT de TAREA 1 (Pide el enunciado) */
    __TAREA1_BSS_PHY                = 0x00320000;           /* BSS de TAREA 1 (Pide el enunciado) */
    __TAREA1_DATA_PHY               = 0x00330000;           /* DATA de TAREA 1 (Pide el enunciado) */
    __TAREA1_RODATA_PHY             = 0x00340000;           /* RODATA de TAREA 1 (Pide el enunciado) */

    __TAREA2_TEXT_PHY               = 0x00411000;           /* TEXT de TAREA 2 (Pide el enunciado) */
    __TAREA2_BSS_PHY                = 0x00420000;           /* BSS de TAREA 2 (Pide el enunciado) */
    __TAREA2_DATA_PHY               = 0x00430000;           /* DATA de TAREA 2 (Pide el enunciado) */
    __TAREA2_RODATA_PHY             = 0x00440000;           /* RODATA de TAREA 2 (Pide el enunciado) */

    __TAREA3_TEXT_PHY               = 0x00510000;           /* TEXT de TAREA 3 (Pide el enunciado) */  
    __TAREA3_BSS_PHY                = 0x00520000;           /* BSS de TAREA 3 (Pide el enunciado) */
    __TAREA3_DATA_PHY               = 0x00530000;           /* DATA de TAREA 3 (Pide el enunciado) */
    __TAREA3_RODATA_PHY             = 0x00540000;           /* RODATA de TAREA 3 (Pide el enunciado) */

    __TAREA4_TEXT_PHY               = 0x00610000;           /* TEXT de TAREA 4 (Pide el enunciado) */          
    __TAREA4_BSS_PHY                = 0x00620000;           /* BSS de TAREA 4 (Pide el enunciado) */
    __TAREA4_DATA_PHY               = 0x00630000;           /* DATA de TAREA 4 (Pide el enunciado) */
    __TAREA4_RODATA_PHY             = 0x00640000;           /* RODATA de TAREA 4 (Pide el enunciado) */
    /* -----------PAG. DINAMICA------------*/
    __PAG_DINAMICA_INIT_PHY         = 0x0A000000;           /* Inicio para paginación dinámica cuando se produce una #PF */
    /* -------------STACKS-----------------*/
    /*  STACKS DE KERNEL */
    __STACK_KERNEL_PHY              = 0x1FFF8000;           /* Inicio de Pila del Kernel (Pide el enunciado) */
    __STACK_KERNEL_END_PHY          = 0x1FFF8FFF;           /* Fin de Pila del Kernel (Elijo)*/
    __STACK_SIZE_KERNEL             = ((__STACK_KERNEL_END_PHY - __STACK_KERNEL_PHY) / 4); /* 32b word */

    __STACK_KERNEL_TAREA1_PHY       = 0x1FFF4000;           /* Pila del Kernel para la Tarea 1 */
    __STACK_KERNEL_TAREA1_END_PHY   = 0x1FFF4FFF; 

    __STACK_KERNEL_TAREA2_PHY       = 0x1FFF5000;           /* Pila del Kernel para la Tarea 2 */
    __STACK_KERNEL_TAREA2_END_PHY   = 0x1FFF5FFF;

    __STACK_KERNEL_TAREA3_PHY       = 0x1FFF6000;           /* Pila del Kernel para la Tarea 3 */
    __STACK_KERNEL_TAREA3_END_PHY   = 0x1FFF6FFF;

    __STACK_KERNEL_TAREA4_PHY       = 0x1FFF7000;           /* Pila del Kernel para la Tarea 4 */
    __STACK_KERNEL_TAREA4_END_PHY   = 0x1FFF7FFF;

    /*  STACKS DE TAREAS */
    __TAREA1_STACK_START_PHY        = 0x1FFF0000;           /* STACK START para TAREA 1 (Pide el enunciado) */
    __TAREA1_STACK_END_PHY          = 0x1FFF0FFF;           /* STACK END para TAREA 1 (Elijo)*/
    __TAREA1_STACK_SIZE             = ((__TAREA1_STACK_END_PHY - __TAREA1_STACK_START_PHY) / 4); 

    __TAREA2_STACK_START_PHY        = 0x1FFF1000;            /* STACK START para TAREA 2 (Pide el enunciado) */        
    __TAREA2_STACK_END_PHY          = 0x1FFF1FFF;            /* STACK END para TAREA 2 (Elijo)*/
    __TAREA2_STACK_SIZE             = ((__TAREA2_STACK_END_PHY - __TAREA2_STACK_START_PHY) / 4); 
    
    __TAREA3_STACK_START_PHY        = 0x1FFF2000;            /* STACK START para TAREA 3 (Pide el enunciado) */
    __TAREA3_STACK_END_PHY          = 0x1FFF2FFF;            /* STACK END para TAREA 3 (Elijo)*/
    __TAREA3_STACK_SIZE             = ((__TAREA3_STACK_END_PHY - __TAREA3_STACK_START_PHY) / 4); 
    
    __TAREA4_STACK_START_PHY        = 0x1FFF3000;            /* STACK START para TAREA 4 (Pide el enunciado) */
    __TAREA4_STACK_END_PHY          = 0x1FFF3FFF;            /* STACK END para TAREA 4 (Elijo)*/
    __TAREA4_STACK_SIZE             = ((__TAREA4_STACK_END_PHY - __TAREA4_STACK_START_PHY) / 4); 
   
    /* *********************************************************/
    /*------------VMA (Virtual Mem. Address)-------------------*/
    /* *********************************************************/
    __SYS_TABLES_VMA                = 0x00000000;         
    __PAGE_TABLES_VMA               = 0x00010000;         
    __FUNCTIONS_VMA                 = 0x00050000;         
    __VGA_VMA                       = 0x00E80000;         
    __TECLADO_ISR_VMA               = 0x00100000;         
    __DATOS_SYS32_VMA               = 0x01200000;         
    __DIGITS_TABLE_VMA              = 0x01210000;         
    __KERNEL_32_VMA                 = 0x01220000;
    /*----------------TAREAS---------------*/
    __TAREA1_TEXT_VMA               = 0x01310000;         
    __TAREA1_BSS_VMA                = 0x01320000;         
    __TAREA1_DATA_VMA               = 0x01330000;         
    __TAREA1_RODATA_VMA             = 0x01340000;

    __TAREA2_TEXT_VMA               = 0x01410000;
    __TAREA2_BSS_VMA                = 0x01420000;
    __TAREA2_DATA_VMA               = 0x01430000;
    __TAREA2_RODATA_VMA             = 0x01440000;

    __TAREA3_TEXT_VMA               = 0x01510000;
    __TAREA3_BSS_VMA                = 0x01520000;
    __TAREA3_DATA_VMA               = 0x01530000;
    __TAREA3_RODATA_VMA             = 0x01540000;

    __TAREA4_TEXT_VMA               = 0x01610000;
    __TAREA4_BSS_VMA                = 0x01620000;
    __TAREA4_DATA_VMA               = 0x01630000;
    __TAREA4_RODATA_VMA             = 0x01640000;
    /* -----------PAG. DINAMICA------------*/
    __PAG_DINAMICA_INIT_VMA         = 0x0A000000;  
    /* -------------STACKS-----------------*/
    __STACK_KERNEL_VMA              = 0x1FFF8000; 
    __STACK_KERNEL_END_VMA          = 0x1FFF8FFF;

    /* STACKES DE KERNEL */
    __STACK_KERNEL_TAREA1_VMA       = 0x1FFF4000;              
    __STACK_KERNEL_TAREA1_END_VMA   = 0x1FFF4FFF; 

    __STACK_KERNEL_TAREA2_VMA       = 0x1FFF5000;               
    __STACK_KERNEL_TAREA2_END_VMA   = 0x1FFF5FFF;

    __STACK_KERNEL_TAREA3_VMA       = 0x1FFF6000;               
    __STACK_KERNEL_TAREA3_END_VMA   = 0x1FFF6FFF;

    __STACK_KERNEL_TAREA4_VMA       = 0x1FFF7000;               
    __STACK_KERNEL_TAREA4_END_VMA   = 0x1FFF7FFF;

    /* STACKS DE TAREAS */
    __TAREA1_STACK_START_VMA        = 0x0078F000;
    __TAREA1_STACK_END_VMA          = 0x0078FFFF;
    
    __TAREA2_STACK_START_VMA        = 0x00790000;
    __TAREA2_STACK_END_VMA          = 0x00790FFF;
    
    __TAREA3_STACK_START_VMA        = 0x00791000;
    __TAREA3_STACK_END_VMA          = 0x00791FFF;
    
    __TAREA4_STACK_START_VMA        = 0x00792000;
    __TAREA4_STACK_END_VMA          = 0x00792FFF;

    /* ----------------TSS---------------- */
    __TSS_BASICA                    = 0x00001000;           /* Para el CPU */
    __TSS1_VMA                      = 0x00001100;
    __TSS2_VMA                      = 0x00001200;
    __TSS3_VMA                      = 0x00001300;
    __TSS4_VMA                      = 0x00001400;
    /*-----------------ROM----------------*/
    __INIT_ROM_VMA                  = 0xFFFF0000;      
    __RESET_VMA                     = 0xFFFFFFF0;
    __INIT_ROM_VMA                  = __INIT_ROM_LMA;       /* Inicialización ROM (Pide el enunciado) */
    __INIT_16_VMA                   = __INIT_16_LMA;        /* Inicialización en 16 bits. */
    __VGA_INIT_VMA                  = __VGA_INIT_LMA;       /* Inicialización de pantalla VGA */
    __INIT_32_VMA                   = __INIT_32_LMA;        /* Inicialización de Modo Protegido */
    __FUNCTIONS_ROM_VMA             = __FUNCTIONS_ROM_LMA;  /* Sección de código para el ejercicio. Tenemos grado de libertad para definirlas, dentro de un lugar conveniente. */
    __RESET_VMA                     = __RESET_LMA;

    /* *********************************************************/
    /* -----------LMA (Loadable Mem. Address)------------------*/
    /* *********************************************************/

    /* VMA != LMA (se van a ejecutar en RAM) */
    __INIT_ROM_LMA                  = 0xFFFF0000;
    __SYS_TABLES_LMA                = __INIT_ROM_LMA ;
/*  __FUNCTIONS_LMA       
    __TECLADO_ISR_LMA      
    __DATOS_LMA             
    __KERNEL_32_LMA         
    __TASK_01_TEXT_LMA      
    __TASK_01_BSS_LMA       
    __TASK_01_DATA_LMA      
    __TASK_01_RODATA_LMA
    __TASK_02_TEXT_LMA  
    __TASK_02_BSS_LMA   
    __TASK_02_DATA_LMA  
    __TASK_02_RODATA_LMA
    __TASK_03_TEXT_LMA  
    __TASK_03_BSS_LMA   
    __TASK_03_DATA_LMA  
    __TASK_03_RODATA_LMA
    __TASK_04_TEXT_LMA  
    __TASK_04_BSS_LMA   
    __TASK_04_DATA_LMA  
    __TASK_04_RODATA_LMA
      */ 

    /* VMA = LMA (se van a ejecutar en ROM) */

    __INIT_16_LMA                   = 0xFFFF9000;                       
/*  __VGA_INIT_LMA          
    __INIT_32_LMA           
    __FUNCTIONS_ROM_LMA    */ 
    __RESET_LMA                     = 0xFFFFFFF0;
             


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
          *(.functions_asm);
          ./bin/functions.elf(.note*);
          ./bin/functions.elf(.bss_functions_ram);
          ./bin/functions.elf(.data_functions_ram);
          ./bin/functions.elf(.rodata_functions_ram);
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
        { *(.data_kernel);
            *(.data)
            *(.rodata);
            *(.bss); } > ram
    __data_size = SIZEOF(.datos_sys32);

    __KERNEL_32_LMA = LOADADDR(.datos_sys32) + SIZEOF(.datos_sys32);

    .codigo_kernel32 __KERNEL_32_VMA :                  /* Ubicación en VMA (RAM) a la que deberá copiarse el código en tiempo de ejecución  */
        AT ( __KERNEL_32_LMA )                          /* Ubicación inicial del código en LMA (ROM) */
        { *(.kernel32); } > ram                         /* Toda esta sección de salida DEBE estar en RAM */
    __codigo_kernel32_size = SIZEOF(.codigo_kernel32);  /* Variable disponible utilizando EXTERN para el código */

/* ********************************* */
/* Secciones de salida de la Tareas */
/* ********************************* */
/* --------------TAREA 1------------ */
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
        {./bin/tarea_1.elf(.bss_tarea1);} > ram
    __tarea_1_bss_size = SIZEOF(.tarea_1_bss); 

    __TAREA1_DATA_LMA = LOADADDR(.tarea_1_bss) + SIZEOF(.tarea_1_bss);
/* Variables inicializadas */
    .tarea_1_data __TAREA1_DATA_VMA :
        AT (__TAREA1_DATA_LMA)
        {./bin/tarea_1.elf(.data_tarea1);} > ram
    __tarea_1_data_size = SIZEOF(.tarea_1_data); 

    __TAREA1_RODATA_LMA = LOADADDR(.tarea_1_data) + SIZEOF(.tarea_1_data);  
/* Variables de solo lectura. */
    .tarea_1_rodata __TAREA1_RODATA_VMA :
        AT (__TAREA1_RODATA_LMA)
        {./bin/tarea_1.elf(.rodata_tarea1);} > ram
    __tarea_1_rodata_size = SIZEOF(.tarea_1_rodata); 

/* --------------TAREA 2------------ */
    __TAREA2_TEXT_LMA = LOADADDR(.tarea_1_rodata) + SIZEOF(.tarea_1_rodata);
/* Funciones de la tarea 2 */
    .tarea_2_text __TAREA2_TEXT_VMA :
        AT (__TAREA2_TEXT_LMA)
        {*(.functions_tarea_2);
        ./bin/tarea_2.elf(.note*);} > ram
    __tarea_02_size = SIZEOF(.tarea_2_text); 

    __TAREA2_BSS_LMA = LOADADDR(.tarea_2_text) + SIZEOF(.tarea_2_text);
/* Variables no inicializadas de la tarea 2 */
    .tarea_2_bss __TAREA2_BSS_VMA :
        AT (__TAREA2_BSS_LMA)
        {./bin/tarea_2.elf(.bss_tarea2);} > ram
    __tarea_2_bss_size = SIZEOF(.tarea_2_bss); 

    __TAREA2_DATA_LMA = LOADADDR(.tarea_2_bss) + SIZEOF(.tarea_2_bss);
/* Variables inicializadas de la tarea 2*/
    .tarea_2_data __TAREA2_DATA_VMA :
        AT (__TAREA2_DATA_LMA)
        {./bin/tarea_2.elf(.data_tarea2);} > ram
    __tarea_2_data_size = SIZEOF(.tarea_2_data); 

    __TAREA2_RODATA_LMA = LOADADDR(.tarea_2_data) + SIZEOF(.tarea_2_data);  
/* Variables de solo lectura de la tarea 2 */
    .tarea_2_rodata __TAREA2_RODATA_VMA :
        AT (__TAREA2_RODATA_LMA)
        {./bin/tarea_2.elf(.rodata_tarea2);} > ram
    __tarea_2_rodata_size = SIZEOF(.tarea_2_rodata); 

/* --------------TAREA 3------------ */
    __TAREA3_TEXT_LMA = LOADADDR(.tarea_2_rodata) + SIZEOF(.tarea_2_rodata);
/* Funciones de la tarea 3 */
    .tarea_3_text __TAREA3_TEXT_VMA :
        AT (__TAREA3_TEXT_LMA)
        {*(.functions_tarea_3);
        ./bin/tarea_3.elf(.note*);} > ram
    __tarea_03_size = SIZEOF(.tarea_3_text); 

    __TAREA3_BSS_LMA = LOADADDR(.tarea_3_text) + SIZEOF(.tarea_3_text);
/* Variables no inicializadas de la tarea 3 */
    .tarea_3_bss __TAREA3_BSS_VMA :
        AT (__TAREA3_BSS_LMA)
        {./bin/tarea_3.elf(.bss_tarea3);} > ram
    __tarea_3_bss_size = SIZEOF(.tarea_3_bss); 

    __TAREA3_DATA_LMA = LOADADDR(.tarea_3_bss) + SIZEOF(.tarea_3_bss);
/* Variables inicializadas de la tarea 3*/
    .tarea_3_data __TAREA3_DATA_VMA :
        AT (__TAREA3_DATA_LMA)
        {./bin/tarea_3.elf(.data_tarea3);} > ram
    __tarea_3_data_size = SIZEOF(.tarea_3_data); 

    __TAREA3_RODATA_LMA = LOADADDR(.tarea_3_data) + SIZEOF(.tarea_3_data);  
/* Variables de solo lectura de la tarea 3 */
    .tarea_3_rodata __TAREA3_RODATA_VMA :
        AT (__TAREA3_RODATA_LMA)
        {./bin/tarea_3.elf(.rodata_tarea3);} > ram
    __tarea_3_rodata_size = SIZEOF(.tarea_3_rodata); 

/* --------------TAREA 4------------ */
    __TAREA4_TEXT_LMA = LOADADDR(.tarea_3_rodata) + SIZEOF(.tarea_3_rodata);
/* Funciones de la tarea 4 */
    .tarea_4_text __TAREA4_TEXT_VMA :
        AT (__TAREA4_TEXT_LMA)
        {*(.functions_tarea_4);
        ./bin/tarea_4.elf(.note*);} > ram
    __tarea_04_size = SIZEOF(.tarea_4_text); 

    __TAREA4_BSS_LMA = LOADADDR(.tarea_4_text) + SIZEOF(.tarea_4_text);
/* Variables no inicializadas de la tarea 4 */
    .tarea_4_bss __TAREA4_BSS_VMA :
        AT (__TAREA4_BSS_LMA)
        {./bin/tarea_4.elf(.bss_tarea4);} > ram
    __tarea_4_bss_size = SIZEOF(.tarea_4_bss); 

    __TAREA4_DATA_LMA = LOADADDR(.tarea_4_bss) + SIZEOF(.tarea_4_bss);
/* Variables inicializadas de la tarea 4*/
    .tarea_4_data __TAREA4_DATA_VMA :
        AT (__TAREA4_DATA_LMA)
        {./bin/tarea_4.elf(.data_tarea4);} > ram
    __tarea_4_data_size = SIZEOF(.tarea_4_data); 

    __TAREA4_RODATA_LMA = LOADADDR(.tarea_4_data) + SIZEOF(.tarea_4_data);  
/* Variables de solo lectura de la tarea 4 */
    .tarea_4_rodata __TAREA4_RODATA_VMA :
        AT (__TAREA4_RODATA_LMA)
        {./bin/tarea_4.elf(.rodata_tarea4);} > ram
    __tarea_4_rodata_size = SIZEOF(.tarea_4_rodata); 

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
          ./bin/functions_rom.elf(.data_functions_rom);
          ./bin/functions_rom.elf(.bss_functions_rom);
          ./bin/functions_rom.elf(.rodata_functions_rom)} > rom

    .codigo_reset __RESET_VMA :
        AT ( __RESET_LMA )
        { *(.resetVector); } > rom


}