#include "../inc/tarea_1.h"


//__attribute__(( section(".bss")))


__attribute__(( section(".data")))
byte variable_global_inicializada = 0; //.data

/* Tarea cada 500ms que muestra el promedio en pantalla de digitos almacenados en memoria. */
__attribute__(( section(".functions_tarea_1")))
void ejecutar_tarea_1 (tabla_t* tabla_digitos, qword* promedio_vma)
{
    qword promedio = tabla_digitos->promedio_dig;
    
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
        mostrar_promedio64_VGA(promedio, 1, 79);
        /* Analizo si el promedio es una direccion valida menor a 512MB */
        lectura_promedio64(promedio);

    }
     
    return;

}
/* Función que lee el promedio64, analiza si es una direccion valida y pagina a una valida si no lo es. */
__attribute__(( section(".functions_tarea_1")))
void lectura_promedio64 (qword promedio)
{ 
    dword* lectura_promedio_direccion;
    dword aux_lectura;

    //Si la VMA del promedio es menor a la RAM (0x1FFFFFFF = 512MB) leo. 
    //Si la dirección es invalida, salta el #PF.
    if (promedio < 0x1FFFFFFF)
    {
        lectura_promedio_direccion = (dword*)promedio; //Guardo como puntero el promedio (dirección VMA) para luego leerla.
        /* Muestro la dir. VMA */
        mostrar_promedio64_VGA(lectura_promedio_direccion, 10, 79);
         /*Lectura del contenido de la dirección VMA. Genera #PF si no esta paginada.  */
        aux_lectura = *lectura_promedio_direccion;
        /* Limpio pantalla- */
        //*lectura_promedio_direccion = 0x14;// Escritura del contenido de la dirección VMA
        /* Muestro contenido de la dir. VMA */
        mostrar_promedio64_VGA(aux_lectura, 12, 79);
    }

}
/*Función que muestra el promedio de digitos de 64b en pantalla.*/
__attribute__(( section(".functions_tarea_1")))
void mostrar_promedio64_VGA(qword promedio, byte fila, byte columna)
{
    static int pos_caracter=0;
    byte caracter = 0;

 
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

        escribir_caracter_VGA (caracter, fila , columna - pos_caracter, ASCII_TRUE);
                                
    }

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

