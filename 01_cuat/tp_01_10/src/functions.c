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
        escribir_tabla_digitos(buffer_vma, (tabla_t*)&__DIGITS_TABLE_VMA,flag_rellenar_tabla);

    }
    /* Si se presiono ENTER y no hay 16 caracteres , hay que rellenar con 0 la tabla*/
    if(buffer_vma->cantidad < 15 && teclaPresionada == TECLA_ENTER){

        //asm("xchg %bx,%bx");

        flag_rellenar_tabla = 1;
        escribir_tabla_digitos(buffer_vma, (tabla_t*)&__DIGITS_TABLE_VMA,flag_rellenar_tabla);

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
    /* Si entra 50 (500ms) veces ejecuto hago el promedio y ejecuto Tarea 1. */
    if ( *contador > 49)
    { 
        //asm("xchg %bx,%bx");
        *contador = 0;
        
        ejecutar_tarea_1(tabla_digitos, (qword*)promedio_vma);    //Muestra en pantalla el promedio de los dígitos de 64b de la tabla ingresados por teclado
    }
    else
    { 
        *contador = *contador + 1;
    }

    return;
}
/* Función que setea el Control Register 3 */
__attribute__(( section(".functions_c")))
dword set_cr3 (dword init_dpt, byte _pcd, byte _pwt)
{
    dword cr3 = 0;

    cr3 |= (init_dpt & 0xFFFFF000);
    cr3 |= (_pcd << 4);
    cr3 |= (_pwt << 3);

    return cr3;

}
/* Función que setea una PDE. */
__attribute__(( section(".functions_c")))
void set_dir_page_table_entry (dword dir_PHY_base_dpt, dword dir_VMA, byte _ps, byte _a, byte _pcd, byte _pwt, byte _us, byte _rw, byte _p)
{
    dword dpte = 0;

    dword* dst = (dword*) dir_PHY_base_dpt; // 0x10000 - Base de el DPT - base para el CR3 
    dword entry_dtp , init_pt = 0;

    
	entry_dtp = get_entry_DTP (dir_VMA); //Bits 31-22 de la VMA (Offset del PDE)

	init_pt = (dir_PHY_base_dpt + 0x1000 ) + (0x1000*entry_dtp); //Base de la PT (Base PDT + 4K) + (4K * PDE) dependiendo del PDE

    /* Armo el DPTE */
    dpte |= (init_pt & 0xFFFFF000);
    dpte |= (_ps << 7);
    dpte |= (_a << 5);
    dpte |= (_pcd << 4);
    dpte |= (_pwt << 3);
    dpte |= (_us << 2);
    dpte |= (_rw << 1);
    dpte |= (_p << 0);


    *(dst + entry_dtp) = dpte;



}
/* Función que setea una PTE */
__attribute__(( section(".functions_c")))
void set_page_table_entry (dword dir_PHY_base_dpt, dword dir_VMA, dword dir_PHY, byte _g, byte _pat, byte _d, byte _a, byte _pcd, byte _pwt, byte _us, byte _rw, byte _p)
{

    dword pte = 0;
    dword entry_pte , init_pt, entry_dtp = 0;

    entry_dtp = get_entry_DTP (dir_VMA); //Bits 31-22 de la VMA (Offset del PDE)

	init_pt = (dir_PHY_base_dpt + 0x1000 ) + (0x1000*entry_dtp); //Base de la PT (Base PDT + 4K) + (4K * PDE) dependiendo del PDE

    dword *base_tp = (dword*)init_pt; //Dir. base de la TP

	entry_pte = get_entry_TP (dir_VMA); //Bits 21-12 de la VMA (Offset del PTE en la TP)


    pte |= (dir_PHY & 0xFFFFF000);
    pte |= (_g << 8);
    pte |= (_pat << 7);
    pte |= (_d << 6);
    pte |= (_a << 5);
    pte |= (_pcd << 4);
    pte |= (_pwt << 3);
    pte |= (_us << 2);
    pte |= (_rw << 1);
    pte |= (_p << 0);


    *(base_tp + entry_pte) = pte;

}


/* Función que escribe un caracter en una posición determinada de la pantalla. */
__attribute__(( section(".functions_c")))
void escribir_caracter_VGA (char caracter, byte fila, byte columna, byte flag_ASCII)
{
    static int pos_msg = 0;
    buff_screen_t* VGA = (buff_screen_t*)&__VGA_VMA;    // Dirección base de la pantalla en el borde superior izquierdo.
    byte atributos = 0x07;              // Fondo negro y letra blanca.

    /* Filas = 24 (y)
       Columnas = 80 (x) */
    
    /* Si no es ASCII, lo convierto. */
    if (!flag_ASCII)
    {
        caracter= convertir_ASCII (caracter);
    }

    VGA->buffer_screen[2*fila][2*columna + 2*pos_msg ] = caracter;
    VGA->buffer_screen[2*fila][2*columna +(2*pos_msg + 1) ] = atributos;

    

}
/* Función que escribe un mensaje en el borde superior izquierdo de la pantalla */
__attribute__(( section(".functions_c")))
void escribir_mensaje_VGA (char* msg, byte fila, byte columna, byte flag_ASCII)
{
    static int pos_msg = 0;
    buff_screen_t* VGA = (buff_screen_t*)&__VGA_VMA;    // Dirección base de la pantalla en el borde superior izquierdo.
    byte atributos = 0x07;                              // Fondo negro y letra blanca.

    /* Filas = 24 (y)
       Columnas = 80 (x) */

    /* Escribe el mensaje en pantalla en la pos. deseada hasta encontrar el NULL del vector. */
    for (pos_msg = 0; *(msg + pos_msg) != 0; pos_msg++)
    {
        /* Si no es ASCII, lo convierto. */
        if (!flag_ASCII)
        {
            *(msg + pos_msg) = convertir_ASCII (*(msg + pos_msg));
        }

        VGA->buffer_screen[2*fila][2*columna + 2*pos_msg ] = *(msg + pos_msg);
        VGA->buffer_screen[2*fila][2*columna +(2*pos_msg + 1) ] = atributos;

    }

}
/* Función que convierte un byte en ASCII */
__attribute__(( section(".functions_c")))
byte convertir_ASCII (byte caracter)
{
    //Si es un número:       
    if (caracter > -1 && caracter < 10)
    {
    caracter = caracter + 48; //Convierto a ASCII (el cero es 48)
    }
    else
    {
        //Si es una letra:
        if ( caracter > 9 && caracter < 91)
        {
            caracter = caracter + 65 ; // Convierto a ASCII (la A es 65)
        } 

    }
    return caracter;

}
/* Función que inicializa o reinicia la pantalla con un mensaje fijo.  */
 __attribute__(( section(".functions_c")))
void msg_bienvenida_VGA (buff_screen_t* VGA)
{
    escribir_mensaje_VGA("------------------------------------", 0, 0, ASCII_TRUE);
    escribir_mensaje_VGA("Bienvenido a x86-OS - CPU: Intel 386", 1, 0, ASCII_TRUE);
    escribir_mensaje_VGA("------------------------------------", 2, 0, ASCII_TRUE);
    escribir_mensaje_VGA("Ingrese digitos de hasta 10 numeros.", 3, 0, ASCII_TRUE);
    escribir_mensaje_VGA("------------------------------------", 22, 0, ASCII_TRUE);
    escribir_mensaje_VGA("Ej.10 - Paginacion Real - TD3 2021 ", 23, 0, ASCII_TRUE);
    escribir_mensaje_VGA("------------------------------------", 24, 0, ASCII_TRUE);

} 
/* Función que limpia la pantalla borrando todo lo que tenga escrito. */
 __attribute__(( section(".functions_c")))
 void limpiar_VGA (buff_screen_t* VGA)
 {
    static int i = 0;
    static int j = 0;

    for (i = 0; i < 25; i++) 
    {
        for (j = 0; j < 80; j++) 
        {
            escribir_caracter_VGA(' ', i, j, ASCII_TRUE);      
        }
    } 
 }
/* Función que toma el PDE de una dirección VMA */
__attribute__((section(".functions_c"))) 
dword get_entry_DTP(dword dir_VMA) 
{
	dword PDE = 0x00;

	PDE = (dir_VMA >> 22) & 0x3FF ;//31-22 bits

	return PDE;
}

/* Función que toma el PTE de una dirección VMA */
__attribute__((section(".functions_c"))) 
dword get_entry_TP(dword dir_VMA)  
{
	dword PTE = 0x00;

	PTE = (dir_VMA >> 12) & 0x3FF ;//21-12 bits

	return PTE;

}

/*Función que muestra un numero de 32 bits en pantalla.*/
__attribute__(( section(".functions_c")))
void mostrar_numero32_VGA(dword numero32, byte fila, byte columna)
{
    static int pos_caracter=0;
    byte caracter = 0;

    /* Recorro la palabra de 32 bits (4 bytes = 8 numeros HEX) */
    for (pos_caracter=0;pos_caracter<8;pos_caracter++)
    {
        caracter = ((numero32 >> 4*pos_caracter) & MASK_MEDIO_BYTE_32B) ; //Voy obteniendo caracteres del prom de 64 bits.

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

        escribir_caracter_VGA (caracter, fila , columna - pos_caracter , ASCII_TRUE);
                                
    }

}


