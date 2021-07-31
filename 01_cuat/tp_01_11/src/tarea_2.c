#include "../inc/tarea_2.h"


__attribute__(( section(".rodata_tarea2")))
const byte var_global_rodata_tarea2 = 1; //.rodata dummy


__attribute__(( section(".bss_tarea2")))
byte var_global_bss_tarea2; //.bss dummy


__attribute__(( section(".data_tarea2")))
byte variable_global_inicializada_tarea2 = 0; //.data dummy

/* Tarea 2. */
__attribute__(( section(".functions_tarea_2")))
void ejecutar_tarea_2 ()
{
    
}
