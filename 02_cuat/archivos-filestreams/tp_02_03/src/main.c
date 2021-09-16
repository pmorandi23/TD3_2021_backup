#include "../inc/funciones.h"

int main(int argc, char *argv[])
{
    FILE *fp;
    char *file_command_line;
    int i = 0;
    double pto_flotante_doble_precision[14];
    double promedio_double_floats;

    // Si tengo algun comando ademas del directorio, lo guardo
    if (argc > 1)
    {
        file_command_line = argv[1];
    }
    else
    {
        printf("No se recibio un archivo por argv\n\r");
        return 0;
    }
    //Si el archivo puede abrirse sigo con el programa
    if (abrir_crear_archivo(&fp, file_command_line))
    {
        //Mientras sea distinto del final de datos armo el vector de doubles float
        while (getc(fp) != '$')
        {

            pto_flotante_doble_precision[i] = armo_numero_double_float(&fp);
            printf("Próximo caracter:%c\n\r\n\r",getc(fp));

            // REVISAR PORQUE EL FSSEK NO ESTA MOVIENDO BIEN EL ARCHIVO. 
            // CREO QUE PORQ ME LO REINICIA DONDE LO USO EN LA FUNCION armo_numero_double_float

            //fseek(fp,1,SEEK_CUR); // Proximo numero de 64 bits


            if (getc(fp) == ',')
            {
                printf("Numero pto flotante doble: %f\n\r\n\r", pto_flotante_doble_precision[i]);
                //i++;

            }
        
            //printf("caracter post numero:%c\n\r\n\r",getc(fp));
            //printf("Numero pto flotante doble: %f\n\r\n\r", pto_flotante_doble_precision[i]);
            //fseek(fp,1,SEEK_CUR); // Proximo numero de 64 bits
            //printf("caracter post FSEEK:%c\n\r\n\r",getc(fp));

        }

        promedio_double_floats = calculo_promedio(pto_flotante_doble_precision);

        printf("El promedio de double floats es : %f\n\r", promedio_double_floats);

        //varianza_double_floats = calculo_varianza()
    }
    return (0);
}