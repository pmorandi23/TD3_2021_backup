#include "../inc/main.h"

int main(int argc, char *argv[])
{
    FILE *fp;
    char *buffer_read, *file_command_line;
    char msg_error[128];
    int file_size = 0;

    if (argc > 1)
    {
        file_command_line = argv[1];
    }

    fp = fopen(file_command_line, "r"); // Abro el archivo de este código para leerlo

    if (fp == NULL){

        strerror_r(errno, msg_error, sizeof(msg_error));
        printf("Error %d : %s \n\r",errno, msg_error);
        return (-1);
    }

    fseek(fp, 0, SEEK_END); // Setea el cursor en el final del archivo

    file_size = ftell(fp); // Guardo la posición final del archivo obteniendo asi su tamaño

    rewind(fp); // Vuelvo el cursor al principio

    buffer_read = malloc(file_size * sizeof(char)); //Ask for memory according to the file size

    if (buffer_read == NULL)
    {
        fputs("No se pudo asignar memoria",stderr);
        exit(2); 
    }
    // Leo este código y lo guardo en el buffer_read y analizo si fue exitosa la misma
    if (file_size != fread(buffer_read, 1, file_size, fp)){

        fputs("Error de lectura del archivo",stderr);
        exit(3);
    } 

    write(STDOUT_FILENO, buffer_read, file_size); // Muestro el código en pantalla
    // Cierro el archivo y pregunto si fue exitosa la operación
    if (fclose(fp)){
        strerror_r(errno,msg_error,sizeof(msg_error));
        printf("Error al cerrar el archivo %d: %s \r\n",errno,msg_error);
    } 

    free(buffer_read); //Libero la memoria asignada con malloc

    return (0);
}