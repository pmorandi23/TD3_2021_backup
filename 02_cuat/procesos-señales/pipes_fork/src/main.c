#include "../inc/defines.h"


/* Programa que crea 2 pipes para comunicar entre procesos
 lo que se lee del teclado y lo imprime en pantalla . Finalmente muere el padre */


// pipe() devuelve 2 file descriptors
/* pfds[0] = fd de lectura
   pfds[1] = fd de escritura */

int main(void)
{
	int pfds[2], pfds_parent[2], flagMuerePadre, cantidadBytesLeida;
	char buf[30];
	pipe(pfds);		   // Creo la pipe
	pipe(pfds_parent); // Pipe para el padre

	if (!fork())
	{
		close(pfds_parent[0]); // Cierro lectura del pipe para el padre
		close(pfds_parent[1]); // Cierro escritura del pipe para el padre
		close(pfds[0]);		   // Cierro el fd de lectura de la pipe
		printf(" CHILD 1: lee de STDIN...Ingrese un texto menor a 30 caracteres\n");
		cantidadBytesLeida = read(STDIN_FILENO, buf, sizeof(buf));
		printf(" CHILD 1: Escribe en la PIPE lo leido por STDIN\n");
		write(pfds[1], buf, cantidadBytesLeida);
		printf(" CHILD 1: muriendo...\n");
		exit(0);
	}
	else
	{
		if (!fork())
		{
			close(pfds[1]); // Cierro la escritura
			cantidadBytesLeida = read(pfds[0], buf, sizeof(buf));
			printf(" CHILD 2: lee de la PIPE\n");
			printf(" CHILD 2: escribe por STDOUT\n");
			write(STDOUT_FILENO, buf, cantidadBytesLeida);
			flagMuerePadre = 1;
			printf(" CHILD 2: Aviso al padre que debe terminar.\n\r\n\r");
			write(pfds_parent[1], &flagMuerePadre, sizeof(flagMuerePadre));
			printf(" CHILD 2: muriendo...\n\r\n\r");
			exit(0);
		}
		else
		{
			printf("PARENT: esperando que terminen los hijos\n");
		}
	}

	while (1)
	{
		sleep(1);
		read(pfds_parent[0], &flagMuerePadre, sizeof(flagMuerePadre));
		if (flagMuerePadre)
		{
			printf("PARENT: CHILD 2 aviso que debo terminar...\n");
			return 0;
		}
	}
}