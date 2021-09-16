#include "../inc/funciones.h"

void sigchld_handler (int sig)
{
    write(0,"Entre al SIGCHLD\n\r",20);
    wait(NULL);
}