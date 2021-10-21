#include "../inc/funciones.h"

void sigusr1_handler (int sig)
{
   int pid;
   pid = fork();
	if (pid == 0) 
	{
		//Código del hijo
		printf("Proceso hijo ID creado en SIGUSR1 = %d\n\r", getpid());
		sleep(10);
      exit(0);
	}
   count_child++;
	
}