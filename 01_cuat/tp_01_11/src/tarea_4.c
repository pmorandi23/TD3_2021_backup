#include "../inc/tarea_4.h"


__attribute__(( section(".rodata_tarea4")))
const byte var_global_rodata_tarea4 = 1; //.rodata


__attribute__(( section(".bss_tarea4")))
byte var_global_bss_tarea4; //.bss dummy


__attribute__(( section(".data_tarea4")))
byte variable_global_inicializada_tarea4 = 0; //.data dummy

/* Tarea 4. */
__attribute__(( section(".functions_tarea_4")))
void ejecutar_tarea_4 ()
{
    asm("xchg %bx,%bx");

}
