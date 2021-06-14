#include "../inc/functions.h"

/* Función que copia memoria desde una fuente a un destino en RAM */
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
/* Función que inicializa el buffer para el teclado */
__attribute__(( section(".functions_c"))) 
void limpiar_buffer (buffer_t* buffer_vma){

    static int i = 0;

    buffer_vma->head = 0;
    buffer_vma->tail = 0;
    buffer_vma->cantidad = 0;
    for(i=0; i<BUFFER_MAX; i++)
	{
	    buffer_vma->buffer[i] = 0;
	}  

}
/*  Función que determina que tecla fue presionada. */
__attribute__(( section(".functions_c"))) 
void determinar_tecla_presionada (byte teclaPresionada, buffer_t* buffer_vma)
{
    byte valorReal_tecla;
    byte flag_rellenar_tabla = 0;
        
    //asm("xchg %bx,%bx");

    /* Si es un número, lo almaceno en el buffer reservado. */
    if (teclaPresionada > 0x01 && teclaPresionada < 0x0C )
    {
        valorReal_tecla = teclaPresionada - 0x01;

        if (teclaPresionada == TECLA_9)
        {
            valorReal_tecla = 0x09;
        }
        if (teclaPresionada == TECLA_0)
        {
            valorReal_tecla = 0x00;
        }       
        escribir_buffer (valorReal_tecla, buffer_vma);      
    }
    /* Si se escribieron 16 caracteres en el buffer y el head dio la vuelta genero un ENTER. O si se presiono ENTER. */
    if ((buffer_vma->cantidad >15 && buffer_vma->head < 1) || (teclaPresionada == TECLA_ENTER && buffer_vma->cantidad > 15)){

        //asm("xchg %bx,%bx");
        flag_rellenar_tabla = 0;
        escribir_tabla_digitos(buffer_vma, (tabla_t*)&__DIGITS_TABLE,flag_rellenar_tabla);

    }
    /* Si se presiono ENTER y no hay 16 caracteres , hay que rellenar con 0 la tabla*/
    if(buffer_vma->cantidad < 15 && teclaPresionada == TECLA_ENTER){

        //asm("xchg %bx,%bx");

        flag_rellenar_tabla = 1;
        escribir_tabla_digitos(buffer_vma, (tabla_t*)&__DIGITS_TABLE,flag_rellenar_tabla);

    }

    return;
}
/* Función que escribe el buffer de teclado. */
__attribute__(( section(".functions_c"))) 
void escribir_buffer (byte tecla, buffer_t* buffer_vma){

    if(buffer_vma->cantidad < BUFFER_MAX)
    {
        buffer_vma->buffer[buffer_vma->head] = tecla;
        buffer_vma->cantidad++;
        buffer_vma->head++;
        if(buffer_vma->head == BUFFER_MAX )
        {
            buffer_vma->head = 0; //Buffer da la vuelta. Se debe insertar en tabla y limpiar.
        } 
    }
    else
    {
        limpiar_buffer(buffer_vma); //Si llegase a entrar acá
    }
}
/* Función que carga en la tabla de dígitos VMA la palabra de 64 bits con las teclas presionadas */
__attribute__(( section(".functions_c"))) 
void escribir_tabla_digitos(buffer_t* buffer_vma, tabla_t* tabla_digitos_vma, byte flag_rellenar_tabla)
{
    static int i =0;
    byte lectura_buffer;
    qword digito_H = 0x00; //4 bytes mas significatvos (8 teclas)
    qword digito_L = 0x00; //4 bytes menos significativos (8 teclas)
    qword digito_64 = 0;   // Para la tabla.
  
    /* Leo el buffer con la cantidad de numeros ingresados. Las pos. restantes deberían ser 0 por el limpiar_buffer */
    for (i=0;i<BUFFER_MAX;i++)
    {
        lectura_buffer = leer_buffer(buffer_vma); //Comienzo a leerlo desde la última posición [16]
        if(i<8)
        {
            digito_L = digito_L + (lectura_buffer << 4*i);
        }
        else
        {
            digito_H = digito_H + (lectura_buffer << 4*i);
        } 
    }

    digito_64 = (digito_H << 32) | digito_L;

    /* Le fijo 10 posiciones a la tabla para tener 10 digitos */
    if(tabla_digitos_vma->indice_tabla < 10){

        tabla_digitos_vma->tabla[tabla_digitos_vma->indice_tabla]= digito_64 ;
        tabla_digitos_vma->indice_tabla++; //Sumo el índice para el siguiente dígito de 32 bits (8 bytes, 16 números ingresados)
        //tabla_digitos_vma->tabla[tabla_digitos_vma->indice_tabla]= digito_L ;
        //tabla_digitos_vma->indice_tabla++; //Sumo el índice para el siguiente dígito de 32 bits (8 bytes, 16 números ingresados)

    }
    else{

        tabla_digitos_vma->indice_tabla = 0;    //Reseteo índice para empezar a sobreescribir la tabla por si me guardan más de 10 
    }

    limpiar_buffer(buffer_vma);                 //Limpio el buffer para la próxima entrada de datos.
    //asm("xchg %bx,%bx");


    /*  Si tengo mas 3 elementos, hago un promedio. 
    if (tabla_digitos_vma->indice_tabla > 2)
    {
        for(i=0;i<3;i++)
        { 
            tabla_digitos_vma->sumatoria_dig += tabla_digitos_vma->tabla[i];
        }

        asm("xchg %bx,%bx");
    } */

    return;    
}
/* Función que lee el buffer de teclado. */
__attribute__(( section(".functions_c"))) 
byte leer_buffer (buffer_t*buffer_vma)
{
    byte lectura = 0x00;

	if(buffer_vma->cantidad > 0)	
	{
        /* Leo el buffer desde la primer tecla ingresada para guardarlo en orden. No uso el tail.*/
		lectura = buffer_vma->buffer[buffer_vma->cantidad - 1];
		buffer_vma->cantidad--;
		buffer_vma->tail++;
		if(buffer_vma->tail == BUFFER_MAX)
		{
			buffer_vma->tail = 0;
		}
		return lectura;
	}
	else
	{	
		return lectura;				//Buffer vacio
	}

}
/* Función que cuenta las veces que interrumpe el timer y resetea el contador si se va de rango. */
__attribute__(( section(".functions_c"))) 
void contador_handler (qword* promedio_vma, tabla_t*tabla_digitos, dword* contador)
{ 

    /* PRUEBAS DE QWORD DE 64 BITS
    static int i = 0;
    qword digitos[4] = { 0x1234567812345678,0x1234567812345678,0x1234567812345678,0x1234567812345678 };
    qword digito_64_prom    = 0;
    qword digito_64_aux     = 0;
    qword digito_64_aux2    = 0;
    byte cantidad_digitos   = 2;


    dword digito_1_L = 0x12345678;
    dword digito_1_H = 0x12345678;

    dword digito_2_L = 0x87654321;
    dword digito_2_H = 0x87654321;

    digito_64_aux = (digito_1_H << 32) | digito_1_L;
    digito_64_aux2 = (digito_2_H << 32) | digito_2_L;

    for (i=0;i<4;i++)
    {
        digito_64_prom = (digito_64_prom | digitos[i]);  
    }
    digito_64_prom = digito_64_prom << 3; // 2= div 4 3 = div /

    asm("xchg %bx,%bx"); */

    /* Si entra 50 veces ejecuto hago el promedio y ejecuto Tarea 1. */
    if ( *contador > 49)
    { 
        //asm("xchg %bx,%bx");
        *contador = 0;
        sumatoria_digitos_64(tabla_digitos);
        promedio_digitos_64(tabla_digitos, (qword*)promedio_vma);
        ejecutar_tarea_1(tabla_digitos);    //Muestra en pantalla el promedio.
    }
    else
    { 
        *contador = *contador + 1;
    }

    return;
}
/* Función que promedia los dígitos almacenados en tabla. */
__attribute__(( section(".functions_c")))
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
__attribute__(( section(".functions_c")))
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
/* Tarea cada 500ms que muestra el promedio en pantalla de digitos almacenados en memoria. */
__attribute__(( section(".tarea_1")))
void ejecutar_tarea_1 (tabla_t* tabla_digitos)
{
     /* ESCRITURA EN PANTALLA

    80 caracteres por linea. Cada caracter tiene 2 bytes. 
    24 filas.
    Entonces cada 160 bytes tengo una linea nueva. 
    mov eax, 0xB8000                       ; Buffer de video pos 0 en memoria
    mov byte [eax], 'H'                    ; Le cago el caractér
    inc eax                                ; Incremento eax
    mov byte [eax], 0x07                   ; Seteo Fondo negro y letra blanca */
    static int pos_caracter=0;
    qword promedio = tabla_digitos->promedio_dig;
    byte caracter = 0;
    byte atributos = 0x07; //Fondo negro y letra blanca.
    buff_screen_t* buffer_vga = &__VGA_VMA;
    byte offset_pantalla = 0x7E; //Offset para tener 16 caracteres en el borde superior derecho.


    /* Si tengo digitos, empiezo a escribir. Sino no. */
    if (tabla_digitos->indice_tabla > 0)
    {
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
        
           buffer_vga->buffer[offset_pantalla + BUFFER_MAX_VIDEO - 2*pos_caracter ] = caracter;
           buffer_vga->buffer[offset_pantalla + BUFFER_MAX_VIDEO - (2*pos_caracter - 1) ] = atributos;
                      
            //escribir_caracter_pantalla((buff_screen_t*)&__VGA_VMA, caracter, atributos);
        }
    }
    
    return;

}
