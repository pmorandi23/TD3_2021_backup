#include "../inc/funciones.h"

// Handler de señal del padre
void sigusr1_handler(int sig)
{
    flagLeerArchivo1 = 1;  // Hijo avisa al padre que debe leer archivo 1
}
// Handler de señal del hijo
void sigusr2_handler(int sig)
{
    flagLeerArchivo2 = 1; // Padre avisa al hijo que debe leer archivo 2
}

void sigint_handler(int sig)
{
}

void sigchld_handler(int sig)
{
}