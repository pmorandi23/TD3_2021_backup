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
#include <signal.h>
#include <sys/wait.h>
#include "../inc/handlers.h"

// Señal para leer archivo de configuración
void sigusr2_handler(int sig)
{
    printf("==========================================================\n");
    printf("PID %d: Señal SIGUSR2 recibida! Abriendo archivo de cfg...\n", getpid());
    printf("==========================================================\n");
    updateServerConfig = TRUE;
}
// Señal para apagar el servidor correctamente.
void sigint_handler(int sig)
{
    serverRunning = CLOSING;
}
// Señal a la que entran childs que hacen exit().
void sigchld_handler(int sig)
{
    pid_t childDead;
    // Que el padre espere a los hijos si o solo si se envio SIGINT para apagar el server.
    if (!serverRunning)
    {
        while ((childDead = waitpid(-1, NULL, WNOHANG)) != -1)
        {
            if (childDead > 0)
            {
                childsKilled++;
                printf("-----------------------------------------\n");
                printf("SIGCHLD: Termina proceso hijo PID %d\n", childDead);
                printf("-----------------------------------------\n");
            }
        }
    }
}