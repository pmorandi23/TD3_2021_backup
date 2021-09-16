#include "../inc/funciones.h"

int count_child;
//-- MAIN --
int main(void)
{
	int i = 0;
	struct sigaction signal;
	signal.sa_flags = 0;				 // Flags de la señal
	signal.sa_handler = sigusr1_handler; // Le asigno el handler a la señal
	sigemptyset(&signal.sa_mask);		 // Limpio todas las mascaras de señales del vector
	// Seteo la señal SIGUSR1 a la señal que cree
	if (sigaction(SIGUSR1, &signal, NULL) == -1)
	{
		perror("Error en el seteo de sigaction\n\r");
		exit(1);
	}

	/* Otra forma de generar los 10 procesos hijos en eel handler, automaticamente.

	for (i = 0; i < 10; i++)
	{
		raise(SIGUSR1); // Genero la señal
	} 
	wait(NULL);
	printf("Fin proceso padre ID = %d\n\r", getpid());
	return 0;
	*/
	while (1)
	{
		if (count_child > 9)
		{
			wait(NULL);
			printf("Fin proceso padre ID = %d\n\r", getpid());
			return 0;
		}
	}
}
