#include "../inc/main.h"

//-- MAIN --
int main(void)
{
	int padre = 1, pid = 0, i = 0;

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
				sleep(5);
				printf("FINALIZA hijo ID = %d\n\r", getpid());
				exit(0);

			}
		}
	}
	if (padre)
	{
		printf("Proceso padre ID = %d\n\r", getpid());
		sleep(15);
		printf("FINALIZA padre ID = %d\n\r", getpid());

	}

	return (0);
}
