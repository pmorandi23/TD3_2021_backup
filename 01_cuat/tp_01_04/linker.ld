/* 
Linker básico
 */
ENTRY (reset)

/* Labels donde puedo definir direcciones BASE*/
    __EH_FRAME = 0x00060000; /* Exception Handler Frame para C. En ese pedazo de RAM se puede utilizar para excepciones. Sirve para mezclar C y asm */

    __STACK_START_16 = 0x9000;
    __STACK_END_16 = 0x09FFF;
    __STACK_START_32 = 0x2FFF8000; /* Inicio de Pila (Pide el enunciado) */
    __STACK_END_32 = 0x2FFF8FFF; /* Fin de Pila (lo elijo) 4KB -1 de stack en modo protegido */
    __STACK_SIZE_32 = ((__STACK_END_32 - __STACK_START_32) / 4); /* 32b word */

    /*------------VMA---------------- */
    /* Se van a ejecutar en RAM (VMA != LMA) */
    __FUNCTIONS_VMA         = 0x00010000; /* Rutinas (Pide el enunciado) */
    __KERNEL_32_VMA         = 0x00020200; /* Kernel (Pide el enunciado) */
    /*  Se ejecutan directo de la ROM (VMA = LMA) */
    __INIT_16_VMA           = 0xFFFF0000; /* Inicialización ROM (Pide el enunciado) */
    __INIT_32_VMA           = 0xFFFFF800;
    __FUNCTIONS_ROM_VMA     = 0xFFFFFC00; /* Sección de código para el ejercicio. Tenemos grado de libertad para definirlas, dentro de un lugar conveniente. */
    __SYS_TABLES_VMA        = 0xFFFFFD00;
    __RESET_VMA             = 0xFFFFFFF0;
    /* -----------LMA----------------- */
    /* Códigos ensamblados */
    __INIT_16_LMA           = 0xFFFF0000; 
    /* Se van a ejecutar en RAM (VMA != LMA) */
    __FUNCTIONS_LMA         = 0xFFFF1000; /* 4KB */
    __KERNEL_32_LMA         = 0xFFFF2000; 
    /*  Se ejecutan directo de la ROM (VMA = LMA) */
    __INIT_32_LMA           = 0xFFFFF800;
    __FUNCTIONS_ROM_LMA     = 0xFFFFFC00; 
    __SYS_TABLES_LMA        = 0xFFFFFD00;
    __RESET_LMA             = 0xFFFFFFF0;
    

/* Restricciones de MEMORY sirven para evitar errores en el mapa de memoria */

MEMORY
{
  ram (rwx):        ORIGIN = 0x00000000,    LENGTH = 0xFFFF0000
  rom (rx):         ORIGIN = 0xFFFF0000,    LENGTH = 64K

}

/* VMA: Virtual Memory Address. Es la dir a la cual todas las ref de memoria van a estar dirigidas
   LMA: Load Memory Address. Es el luga físico en donde se va a ensamblar la RAM */

SECTIONS
{
    /* Entrada: LMA ---- Salida: VMA */
    .codigo_kernel32 __KERNEL_32_VMA :  /* Ubicación en VMA (RAM) a la que deberá copiarse el código en tiempo de ejecución  */
        AT ( __KERNEL_32_LMA ) /* Ubicación inicial del código en LMA (ROM) */
        { *(.kernel32); } > ram /* Toda esta sección de salida DEBE estar en RAM */
    __codigo_kernel32_size = SIZEOF(.codigo_kernel32); /* Variable disponible utilizando EXTERN para el código */

    .functions __FUNCTIONS_VMA :
        AT ( __FUNCTIONS_LMA )
        { *(.functions); } > ram 
    __functions_size = SIZEOF(.functions);

    .codigo_init16 __INIT_16_VMA :
        AT ( __INIT_16_LMA )
        { *(.ROM_init); } > rom 

    .codigo_init32 __INIT_32_VMA :
        AT ( __INIT_32_LMA )
        { *(.start32); } > rom 

    .functions_rom __FUNCTIONS_ROM_VMA :
        AT ( __FUNCTIONS_ROM_LMA )
        { *(.functions_rom*);
          *(.note.gnu.property); } > rom

    .data __SYS_TABLES_VMA :
        AT ( __SYS_TABLES_LMA )
        { *(.sys_tables*); } > rom

    .codigo_reset __RESET_VMA :
        AT ( __RESET_LMA )
        { *(.resetVector); } > rom

}