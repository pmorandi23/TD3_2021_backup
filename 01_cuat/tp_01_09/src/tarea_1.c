#include "../inc/tarea_1.h"



__attribute__(( section(".data")))
byte variable_global_inicializada = 0; //.data


/* Tarea cada 500ms que muestra el promedio en pantalla de digitos almacenados en memoria. */
__attribute__(( section(".functions_tarea_1")))
void ejecutar_tarea_1 (tabla_t* tabla_digitos, qword* promedio_vma)
{
    static int pos_caracter=0;

    qword promedio = tabla_digitos->promedio_dig;
    byte caracter = 0;
    //byte atributos = 0x07; //Fondo negro y letra blanca.
    //buff_screen_t* buffer_vga = &__VGA_VMA; //Dirección base de la pantalla.
    //byte offset_pantalla = 0x7E; //Offset para tener 16 caracteres en el borde superior derecho.

    /* Si tengo digitos, trabajo. Sino no. */
    if (tabla_digitos->indice_tabla > 0)
    {
        /* Sumo todos los dígitos que hay en la tabla de 64b */
        sumatoria_digitos_64(tabla_digitos);
        /* Promedio de todos los dígitos de 64b. */
        promedio_digitos_64(tabla_digitos, (qword*)promedio_vma);

        /* Titulo del promedio */
        escribir_mensaje_VGA("Promedio de digitos de 64 bits:", 0, 49, ASCII_TRUE);

        /* Escribo en pantalla caracter por caracter en el borde superior derecho. */
        for (pos_caracter=0;pos_caracter<16;pos_caracter++)
        {
            caracter = ((promedio >> 4*pos_caracter) & MASK_PROMEDIO) ; //Voy obteniendo caracteres del prom de 64 bits.

            //Tengo del 0 al 9         
             if (caracter > -1 && caracter < 10)
            {
                caracter = caracter + 48; //Convierto a ASCII (el cero es 48)
            }
            else
            {
                //Si tengo A, B, C, D, E
                if ( caracter > 9 && caracter < 16)
                {
                    caracter = caracter + 55 ; // Convierto a ASCII (la A es 65)
                } 
            } 

            escribir_caracter_VGA (caracter, 1 , 50 + pos_caracter, ASCII_TRUE);

           //buffer_vga->buffer_screen[offset_pantalla + BUFFER_MAX_VIDEO - 2*pos_caracter ] = caracter;
           //buffer_vga->buffer_screen[offset_pantalla + BUFFER_MAX_VIDEO - (2*pos_caracter - 1) ] = atributos;
                      
        }
    }
    
    return;

}
/* Función que promedia los dígitos almacenados en tabla. */
__attribute__(( section(".functions_tarea_1")))
void promedio_digitos_64(tabla_t* tabla_digitos, qword* promedio_vma)
{
    static byte i=0;
    static qword a64,b64,r64aux,a64aux;         //     Divido sumatoria de dígitos / cantidad de dígitos
    a64=tabla_digitos->sumatoria_dig;   
    b64=tabla_digitos->indice_tabla;
    r64aux=0x0000000000000000;
    a64aux=0x0000000000000000;

    for(i=0;i<64;i++)
    {
        //if
        a64aux=a64aux | ( ( a64>>(64-1-i) ) & ( 0x01 ) );
        if(a64aux>=b64)
        {
        r64aux=r64aux|0x1;            
        a64aux=a64aux-b64;
        }
        r64aux=r64aux<<1;
        a64aux=a64aux<<1;
    }
    r64aux=r64aux>>1;
    /* Guardo el promedio en la struct de la tabla. */
    tabla_digitos->promedio_dig=r64aux;
    /* Almaceno el promedio en una posicion en la seccion DATA. */
    *promedio_vma = r64aux;
}
/* Función que promedia los dígitos almacenados en tabla. */
__attribute__(( section(".functions_tarea_1")))
void sumatoria_digitos_64(tabla_t* tabla_digitos)
{
    static int i = 0;
    qword sumatoria = 0;

    for (i=0;i<tabla_digitos->indice_tabla;i++)
    {
        sumatoria = sumatoria + tabla_digitos->tabla[i];
    }
    tabla_digitos->sumatoria_dig = sumatoria;

}

