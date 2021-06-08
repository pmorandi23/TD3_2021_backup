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
    
    /* Teclas del 0 al 9 
        #define TECLA_1     0x02
        #define TECLA_2     0x03
        #define TECLA_3     0x04
        #define TECLA_4     0x05
        #define TECLA_5     0x06
        #define TECLA_6     0x07
        #define TECLA_7     0x08
        #define TECLA_8     0x09
        #define TECLA_9     0x0A
        #define TECLA_0     0x0B*/

    
    /* Si es un número, lo almaceno en . */
    if (teclaPresionada > 0x01 && teclaPresionada < 0x0B ){

        if (teclaPresionada == TECLA_9){
            valorReal_tecla = 0x09;
        }else{
            valorReal_tecla = teclaPresionada - 0x01;
        }

		//asm("xchg %bx,%bx");

        escribir_buffer (valorReal_tecla, buffer_vma);
        
        //asm("xchg %bx,%bx");

    }
    
    
    /* Si se escribieron 16 caracteres en el buffer y el head dio la vuelta genero un ENTER. O si se presiono ENTER. */
    if ((buffer_vma->cantidad >15 && buffer_vma->head < 1) || (teclaPresionada == TECLA_ENTER && buffer_vma->cantidad > 15)){

        //asm("xchg %bx,%bx");
        flag_rellenar_tabla = 0;
        escribir_tabla_digitos(buffer_vma, &__DIGITS_TABLE,flag_rellenar_tabla);

    }
    /* Si se presiono ENTER y no hay 16 caracteres , hay que rellenar con 0 la tabla*/
    if(buffer_vma->cantidad < 15 && teclaPresionada == TECLA_ENTER){

        //asm("xchg %bx,%bx");

        flag_rellenar_tabla = 1;
        escribir_tabla_digitos(buffer_vma, &__DIGITS_TABLE,flag_rellenar_tabla);

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
        if(buffer_vma->head == BUFFER_MAX)
        {
            buffer_vma->head = 0; //Buffer da la vuelta. Se debe insertar en tabla y limpiar.
        } 
    }else{

        limpiar_buffer(buffer_vma); //Si llegase a entrar acá
    }
}
/* Función que carga en la tabla de dígitos VMA la palabra de 64 bits con las teclas presionadas */
__attribute__(( section(".functions_c"))) 
void escribir_tabla_digitos(buffer_t* buffer_vma, tabla_t* tabla_digitos_vma, byte flag_rellenar_tabla)
{
    static int i =0;
    byte lectura_buffer;
    qword digito_64;

    asm("xchg %bx,%bx");

    /* Leo el buffer y armo el dígito de 64 bits (8 bytes) */
    for (i=0;i<BUFFER_MAX;i++)
    {
        lectura_buffer = leer_buffer(buffer_vma);

        lectura_buffer = lectura_buffer + digito_64;

        digito_64 = digito_64 * 10 ; //Desplazo el número hacia la izquierda y me quedan 0 en las 4 pos menos significativas para el nuevo numero.

    }
    asm("xchg %bx,%bx");

    return;
    /* Escribo el numero en la tabla de dígitos de 64 bits */
    
}
/* Función que lee el buffer. */
__attribute__(( section(".functions_c"))) 
byte leer_buffer (buffer_t*buffer_vma)
{
    byte lectura = 0xFF;

	if(buffer_vma->cantidad > 0)	
	{
		lectura = buffer_vma->buffer[buffer_vma->tail];
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
