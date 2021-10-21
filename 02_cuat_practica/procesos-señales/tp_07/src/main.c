#include "../inc/funciones.h"

int count_child, ppid;
//-- MAIN --

int main(int argc, char *argv[])
{
	int i = 0;
	struct sigaction signal_1, signal_2, signal_3;
	// Recibo por línea de comandos la cantidad de procesos hijos a crearse
	count_child = atoi(argv[1]);
	// Configuro señal SIGUSR1
	signal_1.sa_flags = 0;				 // Flags de la señal
	signal_1.sa_handler = sigusr1_handler; // Le asigno el handler a la señal
	sigemptyset(&signal_1.sa_mask);		 // Limpio todas las mascaras de señales del vector
	// Seteo la señal SIGUSR1 a la señal que cree
	if (sigaction(SIGUSR1, &signal_1, NULL) == -1)
	{
		perror("Error en el seteo de sigaction\n\r");
		exit(1);
	}
	// Configuro señal SIGINT
	signal_2.sa_flags = 0;				 // Flags de la señal
	signal_2.sa_handler = sigint_handler; // Le asigno el handler a la señal
	sigemptyset(&signal_2.sa_mask);		 // Limpio todas las mascaras de señales del vector
	// Seteo la señal SIGCHLD a la señal que cree
	if (sigaction(SIGINT, &signal_2, NULL) == -1)
	{
		perror("Error en el seteo de sigaction\n\r");
		exit(1);
	}
	// Configuro señal SIGCHLD
	signal_3.sa_flags = 0;				 // Flags de la señal
	signal_3.sa_handler = sigchld_handler; // Le asigno el handler a la señal
	sigemptyset(&signal_3.sa_mask);		 // Limpio todas las mascaras de señales del vector
	// Seteo la señal SIGCHLD a la señal que cree
	if (sigaction(SIGCHLD, &signal_3, NULL) == -1)
	{
		perror("Error en el seteo de sigaction\n\r");
		exit(1);
	}
	//Otra forma de generar los 10 procesos hijos en el handler, automaticamente.
	for (i = 0; i < count_child; i++)
	{
		raise(SIGUSR1); // Genero la señal
	}
	ppid = getpid(); // ID del padre 
	printf("Soy el proceso padre PID: %d esperando que terminen los VAGUITOS\n\r",getpid());
	wait(NULL);
	printf("Fin proceso padre ID = %d\n\r", getpid());
	return 0;
	
	/* 
	while (count_child != -1)
	{
		if (count_child > -1)
		{
			wait(NULL);
			printf("Fin proceso padre ID = %d\n\r", getpid());
			return 0;
		}
		count_child --;
	}
	 */
	
}
