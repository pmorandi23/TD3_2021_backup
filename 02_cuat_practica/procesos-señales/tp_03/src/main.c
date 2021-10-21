#include "../inc/funciones.h"

//-- MAIN --
int main(void)
{
	int padre = 1, i = 0;
	struct sigaction signal;
	signal.sa_flags = 0;				 	// Flags de la señal
	signal.sa_handler = sigchld_handler; 	// Le asigno el handler a la señal
	sigemptyset(&signal.sa_mask); 			// Limpio todas las mascaras de señales del vector
	// Seteo la señal SIGCHLD a la señal que cree
	if (sigaction(SIGCHLD, &signal, NULL) == -1)
	{
		perror("Errir en el seteo de sigaction\n\r");
		exit(1);
	}
	for (i = 0; i < 10; i++)
	{
		if (padre)
		{
			// Creo hijos 
			if (!fork())
			{
				// Código del hijo
				padre = 0;
				i = 11; // Mato el for para los hijos
				printf("Proceso hijo ID = %d\n\r", getpid());
				sleep(1);
				printf("FINALIZA hijo ID = %d\n\r", getpid());
				exit(0);

			}
		}
	}
	if (padre)
	{
		printf("Proceso padre ID = %d\n\r", getpid());
		sleep(15);
		wait(NULL);
		printf("FINALIZA padre ID = %d\n\r", getpid());

	}
	return (0);
}
