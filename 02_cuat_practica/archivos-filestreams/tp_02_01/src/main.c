#include "../inc/main.h"

int main()
{
    FILE *fp;
    char caracter;
    char* buffer_read;
    int file_size = 0;

    fp = fopen("./src/main.c", "r"); // Abro el archivo de este código para leerlo

    fseek(fp, 0, SEEK_END); // Setea el cursor en el final del archivo

    file_size = ftell(fp); // Guardo la posición final del archivo obteniendo asi su tamaño

    rewind(fp); // Vuelvo el cursor al principio

    buffer_read = malloc(file_size * sizeof(char)); //Ask for memory according to the file size

    fread(buffer_read,1,file_size,fp); // Leo este código y lo guardo en el buffer

    write(STDOUT_FILENO, buffer_read, file_size); // Muestro el código en pantalla

    fclose(fp);  // Cierro el archivo

    free(buffer_read); //Libero la memoria asignada con malloc

    return (0);
}