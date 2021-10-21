#include "../inc/funciones.h"

void sigchld_handler(int sig)
{
	write(0,"Entre al handler de SIGCHLD!\n", 20);
    wait(NULL);
}