#include "../inc/funciones.h"

void sigusr1_handler(int sig)
{
	int pid;
	pid = fork();
	if (pid == 0)
	{
		//Código del hijo
		printf("Proceso hijo ID creado en SIGUSR1 = %d\n\r", getpid());
		sleep(10);
		kill(getpid(),SIGKILL); // Mato al hijo si no entro el padre

	}
	else
	{
		printf("Soy el padre en el handler SIGUSR1 con PID: %d\n\r", getpid());
	}
	//count_child++;
}

void sigint_handler(int sig)
{
	if(getpid() == ppid)
	{
		write(0, "SIGINT interceptada con proceso padre!!\n\r", sizeof("SIGINT interceptada con proceso padre!!\n\r"));
	}
	else
	{
		write(0, "SIGINT interceptada con proceso HIJO!!\n\r", sizeof("SIGINT interceptada con proceso HIJO!!\n\r"));
	}
	//printf("SIGINT interceptada!!CON PID: %d\n\r", getpid());
}

void sigchld_handler(int sig)
{
	write(0, "SIGCHLD: Termina proceso hijo \n\r", sizeof("SIGCHLD: Termina proceso hijo \n\r"));
	wait(NULL);
}