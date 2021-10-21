#include "../inc/funciones.h"

int abrir_crear_archivo(FILE **fp, char *file_command_line)
{
    char msg_error[128];
    *fp = fopen(file_command_line, "r"); // Abro el archivo que me llega por línea de comando

    // Analizo si el
    if (*fp == NULL)
    {
        strerror_r(errno, msg_error, sizeof(msg_error));
        printf("Error %d : %s \n\r", errno, msg_error);
        return (-1);
    }
    return 1;
}

double armo_numero_double_float(FILE** fp)
{
    punto_flotante_t valor_ptoFlotanteDouble;
    double pto_flotante_doble_precision;
    float suma_de_productos = 0;
    int i = 0, k = 0;
    char bit_read = 0;

    for (i = 0; i < 64; i++)
    {
        fseek(*fp, i, SEEK_SET);   // Me voy desplazando char a char en el archivo
        bit_read = getc(*fp);      // Leo de a un caracter
        bit_read = bit_read - 48; // Lo convierto a decimal

        //printf("Caracter leido: %c\n\r",getc(*fp));

        // Guardo bit del signo
        if (i == 0)
        {
            valor_ptoFlotanteDouble.signo = bit_read;
        }
        // Guardo bit del exponente
        if (i > 0 && i < 12)
        {
            valor_ptoFlotanteDouble.exponente |= bit_read << (12 - i);
        }
        // Guardo bit de la fracción
        if (i > 11 && i < 64)
        {
            valor_ptoFlotanteDouble.fraccion |= bit_read << (52 + 11 - i);
        }
        //Armo el número en punto flotante de doble precisión
        if (i > 61)
        {
            //printf("El signo es es %d\n\r", valor_ptoFlotanteDouble.signo);
            //printf("El exponente es es %d\n\r", valor_ptoFlotanteDouble.exponente);
            //printf("La fracción es es %lld\n\r", valor_ptoFlotanteDouble.fraccion);

            //Obtengo la sumatoria de productos de la fracción
            for (k = 0; k < 52; k++)
            {
                suma_de_productos += ((valor_ptoFlotanteDouble.fraccion >> k) & 0x01) * pow(2, -k); // Hago la operación bit a bit en la fracción
            }
            //printf("La suma de prod de la fracción es es %f\n\r", suma_de_productos);

            k = 0;
            pto_flotante_doble_precision = pow(-1, valor_ptoFlotanteDouble.signo) * (1 + suma_de_productos) * pow(2, valor_ptoFlotanteDouble.exponente - 1023);


            return pto_flotante_doble_precision;
        }
    }
    return 0;
}

double calculo_promedio(double* vector_double_float)
{
    double suma, promedio;
    int i = 0;

    for(i=0; vector_double_float[i] != '\0' ; i++)
    {
        suma += vector_double_float[i];
    }
    promedio = suma / i;

    return promedio;
}
