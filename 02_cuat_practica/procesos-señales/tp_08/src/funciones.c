#include "../inc/funciones.h"

void sigusr1_handler(int sig)
{
	if (!ppid)
	{
		child_counter++; // Si es un hijo, suma la variable i
	}
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
	pid_t childClosed = 0;
    childClosed = waitpid(-1,NULL,WNOHANG); // Tengo el PID del hijo que muere
    //printf("SIGCHLD! Muere hijo con PID = %d\n",childClosed);
	write(0, "SIGCHLD: Termina proceso hijo \n\r", sizeof("SIGCHLD: Termina proceso hijo \n\r"));
	child_killed ++;

}