#include "../inc/funciones.h"

/* Programa que crea 2 pipes para comunicar entre procesos
 lo que se lee del teclado y lo imprime en pantalla . Finalmente muere el padre */

// pipe() devuelve 2 file descriptors
/* pfds[0] = fd de lectura
   pfds[1] = fd de escritura */

sig_atomic_t flagLeerArchivo2 = 0; // int que puede modificarse y no puede ser interceptado por señales
sig_atomic_t flagLeerArchivo1 = 0;

int main(void)
{
	int pid_child, file_size, childYaLeyoData2 = 0, padreYaLeyoData1 = 1, contador = 0;
	FILE *fp1, *fp2;
	char buffer_read[50] = "Contador: ";
	char contador_char[10];
	//pipe(pfds);		   	// Creo la pipe
	//pipe(pfds_parent); 	// Pipe para el padre
	system("clear"); // Limpio la consola
	signal(SIGUSR1, sigusr1_handler); // SIGUSR1 para el padre
	signal(SIGUSR2, sigusr2_handler); // SIGUSR2 para el hijo
	pid_child = fork();
	// Código del hijo - Proceso 2
	if (pid_child == 0)
	{
		while (1)
		{
			sleep(3); // Para no consumir tanto CPU
			if (childYaLeyoData2)
			{
				childYaLeyoData2 = 0;
				// 4 - Escribo el archivo DATA1 lo que leyo de DATA2
				fp1 = fopen("./files/data1", "w"); // Abro/ creo el archivo data1
				printf("Hijo escribe archivo DATA1\n");
				fwrite(buffer_read, sizeof(buffer_read), 1, fp1);
				fclose(fp1);
				// 5 - Envío señal SIGUSR1 que la recibe el PADRE
				kill(getppid(), SIGUSR1);
			}
			if (flagLeerArchivo2)
			{
				flagLeerArchivo2 = 0;
				printf("-------------------------\n");
				printf("Hijo lee archivo DATA2\n");
				printf("-------------------------\n");
				// 3 - Leo el archivo DATA2
				fp2 = fopen("./files/data2", "r");
				fseek(fp2, 0, SEEK_END);									// Setea el cursor en el final del archivo
				file_size = ftell(fp2);										// Guardo la posición final del archivo obteniendo asi su tamaño
				rewind(fp2);
				fread(buffer_read, file_size, 1, fp2); // Leo lo que tengo escrito en el archivo
				fclose(fp2);												// Cierro el archivo DATA1
				printf("Contenido del archivo DATA2: %s\n\n\r",buffer_read);
				childYaLeyoData2 = 1;										// Habilito al proceso para escribir el archivo DATA 1
			}
		}
	}
	// Código del padre - Proceso 1
	while (1)
	{
		sleep(3); // Para no consumir tanto CPU
		if (padreYaLeyoData1)
		{
			contador++;
			if (contador > 100)
			{
				contador = 0;
			}
			padreYaLeyoData1 = 0;
			sprintf(contador_char, "%d", contador); // Convierto el PID a char
			strcat(buffer_read, contador_char);
			// 4 - Escribo el archivo DATA2 lo que leyo de DATA1
			fp2 = fopen("./files/data2", "w"); // Abro/ creo el archivo data1
			printf("Padre escribe archivo DATA2\n");
			fwrite(buffer_read, sizeof(buffer_read), 1, fp2);
			fclose(fp2);
			// 5 - Envío señal SIGUSR2 que la recibe el HIJO
			kill(pid_child, SIGUSR2); // Cierro el archivo
		}
		if (flagLeerArchivo1)
		{
			flagLeerArchivo1 = 0;
			printf("-------------------------\n");
			printf("Padre lee archivo DATA1\n");
			printf("-------------------------\n");
			// 3 - Leo el archivo DATA 1
			fp1 = fopen("./files/data1", "r");							// Abro/ creo el archivo data1
			fseek(fp1, 0, SEEK_END);									// Setea el cursor en el final del archivo
			file_size = ftell(fp1);										// Guardo la posición final del archivo obteniendo asi su tamaño
			rewind(fp1);
			fread(buffer_read, file_size, 1, fp1); // Leo lo que tengo escrito en el archivo
			fclose(fp1);												// Cierro el archivo DATA1
			printf("Contenido del archivo DATA1: %s\n\n\r",buffer_read);
			padreYaLeyoData1 = 1;										// Habilito al padre para escribir el archivo DATA2
		}
	}
}

