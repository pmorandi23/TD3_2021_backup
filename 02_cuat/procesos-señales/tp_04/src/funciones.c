#include "../inc/funciones.h"

void sigchld_handler (int sig)
{
    while (waitpid(-1, NULL, WNOHANG) > 0)
    {
        //write(0,"Entre al SIGCHLD\n\r",20);
        printf("handler SIGCHLD %d y sig: %d\r\n", getpid(),sig);
    } 

}