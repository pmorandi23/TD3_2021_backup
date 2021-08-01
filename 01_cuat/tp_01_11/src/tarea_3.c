#include "../inc/tarea_3.h"


__attribute__(( section(".rodata_tarea3")))
const byte var_global_rodata_tarea3 = 1; //.rodata


__attribute__(( section(".bss_tarea3")))
byte var_global_bss_tarea3; //.bss dummy


__attribute__(( section(".data_tarea3")))
byte variable_global_inicializada_tarea3 = 0; //.data dummy

/* Tarea 3. */
__attribute__(( section(".functions_tarea_3")))
void ejecutar_tarea_3 ()
{
    asm("xchg %bx,%bx");

    while (1)
    {
        
    }
}
