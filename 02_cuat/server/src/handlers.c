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
#include "../inc/configFile.h"

// Señal para leer archivo de configuración
void sigusr2_handler(int sig)
{
    printf("==========================================================\n");
    printf("PID %d: Señal SIGUSR2 recibida! Abriendo archivo de cfg...\n", getpid());
    printf("==========================================================\n");
    semop(configFileSemafhoreID, &p, 1); //Tomo el semaforo
    leer_config_server(serverConfig);
    semop(configFileSemafhoreID, &v, 1); //Libero el semaforo
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
    childDead = waitpid(-1, NULL, WNOHANG);

    if (childDead > 0)
    {
        if (childDead == childSensorReader)
        {
            // Si muere el proceso lector del sensor a traves del driver, apago el servidor.
            printf("---------------------------------------------------------------------\n");
            printf("SIGCHLD: Murio proceso lector del sensor %d a traves del driver\nApagando servidor... \n", childDead);
            printf("---------------------------------------------------------------------\n");
            serverRunning = CLOSING;
            write(pipeServer[1], &serverRunning, sizeof(serverRunning));
            childsKilled++;
        }
        else
        {
            printf("-----------------------------------------\n");
            printf("SIGCHLD: Termina proceso hijo PID %d\n", childDead);
            printf("-----------------------------------------\n");
            childsKilled++;
        }
        printf("SIGCHLD: childsKilled = %d\n", childsKilled);
        printf("SIGCHLD: childsCounter = %d\n", childsCounter);
    }
}