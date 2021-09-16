#include "../inc/funciones.h"

//-- MAIN --
int main(void)
{
	struct sigaction signal;
	signal.sa_flags = 0;				 // Flags de la señal
	signal.sa_handler = sigterm_handler; // Le asigno el handler a la señal
	sigemptyset(&signal.sa_mask);		 // Limpio todas las mascaras de señales del vector
	// Seteo la señal SIGCHLD a la señal que cree
	if (sigaction(SIGTERM, &signal, NULL) == -1)
	{
		perror("Error en el seteo de sigaction\n\r");
		exit(1);
	}
	printf("Esperando por SIGTERM...\n\r");
	kill(getpid(), SIGTERM);

}
