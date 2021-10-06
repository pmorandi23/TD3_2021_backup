#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <errno.h>
#include <sys/ipc.h>
#include <sys/shm.h>
#include <sys/sem.h>
#include <sys/wait.h>
#include <signal.h>
#include "../inc/handlers.h"


void sigusr1_handler(int sig)
{
    
}
// Señal para leer archivo de configuración
void sigusr2_handler(int sig)
{
    printf("\n======================================\n");
    printf("PID %d: Señal SIGUSR2 recibida!\n",getpid());
    printf("\n======================================\n");
    //serverRunning = CLOSING;

}
// Señal para apagar el servidor correctamente.
void sigint_handler(int sig)
{
    printf("\n==============================\n");
    printf("PID %d: Señal SIGINT recibida.\n",getpid());
    printf("\n==============================\n");
    serverRunning = CLOSING;
}

void sigchld_handler(int sig)
{
    waitpid(-1,NULL,WNOHANG); // Tengo el PID del hijo que muere
    //printf("SIGCHLD! Muere hijo con PID = %d\n",childClosed);
    printf("\n=============================\n");
	write(0, "SIGCHLD: Termina proceso hijo\n", sizeof("SIGCHLD: Termina proceso hijo \n"));
    printf("=============================\n");

}