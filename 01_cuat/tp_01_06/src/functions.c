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
/* Función que escribe el buffer. */
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
    dword digito_H = 0x00; //4 bytes mas significatvos (8 teclas)
    dword digito_L = 0x00; //4 bytes menos significativos (8 teclas)
  
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
    
    if(tabla_digitos_vma->indice_tabla < LONG_TABLA){

        tabla_digitos_vma->tabla[tabla_digitos_vma->indice_tabla]= digito_H ;
        tabla_digitos_vma->indice_tabla++; //Sumo el índice para el siguiente dígito de 32 bits (8 bytes, 16 números ingresados)
        tabla_digitos_vma->tabla[tabla_digitos_vma->indice_tabla]= digito_L ;
        tabla_digitos_vma->indice_tabla++; //Sumo el índice para el siguiente dígito de 32 bits (8 bytes, 16 números ingresados)

    }
    else{

        tabla_digitos_vma->indice_tabla = 0;    //Reseteo índice para empezar a sobreescribir la tabla por si me guardan más de 10 
    }

    limpiar_buffer(buffer_vma);                 //Limpio el buffer para la próxima entrada de datos.
    //asm("xchg %bx,%bx");

    return;
    /* Escribo el numero en la tabla de dígitos de 64 bits */
    
}
/* Función que lee el buffer. */
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
void contador_handler (dword* contador)
{ 
    if ( *contador > 0xFFFE)
    { 
        *contador = 0;
    }
    else
    { 
        *contador = *contador + 1;
    }

    return;
}