#include "../inc/functions.h"


__attribute__(( section(".functions_c"))) 
byte __fast_memcpy(dword*src,dword *dst,dword length)
{
    byte status = ERROR_DEFECTO;

    if(length>0)
    {
        while(length)
        {
            length--;
            *dst++=*src++;
        }
        status = EXITO;
    }

    return (status);
}
__attribute__(( section(".functions_c"))) 
void determinar_tecla_presionada (dword *teclaPresionada)
{

    byte a = 0;
    
    switch ((dword)teclaPresionada)
    {
    // #UD (Invalid Opcode Exception)
    case TECLA_U:

        asm("UD2");                                       

        break;
    // #DF (Double Fault Exception)
    case TECLA_I:

    /* Ver como hacerla */


        break;
    // #SS (Stack Segment)
    case TECLA_S: 

        asm("mov $0,%esp");
        asm("push %eax");           

        break;
    // #DE (Divide Error Exception) 
    case TECLA_A:

        a /= 0;

        break;
    
    default:

        break;
    }
    return;
}
