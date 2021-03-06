#include "../inc/tarea_1.h"


__attribute__(( section(".rodata_tarea1")))
const byte var_global_rodata_tarea1 = 1; //.rodata

__attribute__(( section(".bss_tarea1")))
qword var_global_bss_tarea1; //.bss dummy
__attribute__(( section(".bss_tarea1")))
qword dummy_bss;  // Resultado del promedio cada 500ms de los dígitos en tabla.

__attribute__(( section(".data_tarea1")))
byte variable_global_inicializada = 0; //.data

/* Tarea cada 500ms que muestra el promedio en pantalla de digitos almacenados en memoria. */
__attribute__(( section(".functions_tarea_1")))
void ejecutar_tarea_1 (void)
{
    tabla_t* tabla_digitos = &TAREA1_DIGITS_TABLE;

    if (tabla_digitos->indice_tabla > 0)
    {
        
        //promedio = tabla_digitos->promedio_dig;
        /* Sumo todos los dígitos que hay en la tabla de 64b */
        sumatoria_digitos_64(tabla_digitos);
        /* Promedio de todos los dígitos de 64b. */
        promedio_digitos_64(tabla_digitos, &resultado_promedio);
        
    }

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
        //mostrar_promedio64_VGA(lectura_promedio_direccion, 10, 79);
         /*Lectura del contenido de la dirección VMA. Genera #PF si no esta paginada.  */
        //asm("xchg %bx,%bx");

        aux_lectura = *lectura_promedio_direccion;
        /* Limpio pantalla- */
        /* Muestro contenido de la dir. VMA */
        //mostrar_promedio64_VGA(aux_lectura, 12, 79);
    }

}

/* Función que promedia los dígitos almacenados en tabla. */
__attribute__(( section(".functions_tarea_1")))
void promedio_digitos_64(tabla_t* tabla_digitos, qword* promedio_vma)
{
    byte i=0;
    qword a64,b64,r64aux,a64aux;         //     Divido sumatoria de dígitos / cantidad de dígitos
    
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
    byte i = 0;
    qword sumatoria = 0;

    //asm("xchg %bx,%bx");

    for (i=0;i<tabla_digitos->indice_tabla;i++)
    {
        sumatoria = sumatoria + tabla_digitos->tabla[i];
    }
    tabla_digitos->sumatoria_dig = sumatoria;

}

