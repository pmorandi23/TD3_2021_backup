#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <sys/types.h>
#include <sys/ipc.h>
#include <sys/sem.h>

#define KEY 0x1111

union semun {
    int val;                             
    struct semid_ds *buf;               
    unsigned short  *array;
};

struct sembuf p = { 0, -1, SEM_UNDO};  // Estructura para tomar el semáforo
struct sembuf v = { 0, +1, SEM_UNDO};  // Estructura para liberar el semáforo

int main()
{
    int id = semget(KEY, 1, 0666 | IPC_CREAT); // semget crea 1 semáforo con permisos rw rw rw
    if(id < 0)
    {
        perror("semget"); exit(11);   // Chequea que este bien creado el semáforo
    }
    union semun u;   // Crea la union 
    u.val = 1;       // Asigna un 1 al val 
    // Inicializo el semáforo para utilizarlo
    if(semctl(id, 0, SETVAL, u) < 0)
    {
        perror("semctl"); exit(12);
    }

    int pid;
    pid =  fork();
    srand(pid); // Inicializa generador de numeros random. Podria haberle pasado cualquier número.
    if(pid < 0)
    {
        perror("fork"); exit(1);
    }
    else if(pid)
    {
        char *s = "abcdefgh";
        int l = strlen(s);
        for(int i = 0; i < l; ++i)
        {
            // Toma el semáforo primero
            if(semop(id, &p, 1) < 0)
            {
                perror("semop p"); exit(13);
            }
            write(STDOUT_FILENO, "\nFATHER: pudo tomar el semaforo...\n\n", sizeof("\nFATHER: pudo tomar el semaforo...\n\n"));
            fflush(stdout);
            putchar(s[i]);
            fflush(stdout);
            sleep(rand() % 2);
            putchar(s[i]);
            fflush(stdout);
            write(STDOUT_FILENO, "FATHER: libera el semaforo...\n",sizeof("FATHER: libera el semaforo...\n"));
            if(semop(id, &v, 1) < 0)
            {
                perror("semop p"); exit(14);
            }
            fflush(stdout);
            sleep(rand() % 2);
        }
    }
    else
    {
        char *s = "ABCDEFGH";
        int l = strlen(s);
        for(int i = 0; i < l; ++i)
        {
            if(semop(id, &p, 1) < 0)
            {
                perror("semop p"); exit(15);
            }
            write(STDOUT_FILENO, "\nHIJO: pudo tomar el semaforo...\n\n", sizeof("\nHIJO: pudo tomar el semaforo...\n\n"));
            fflush(stdout);
            putchar(s[i]);
            fflush(stdout);
            sleep(rand() % 2);
            putchar(s[i]);
            fflush(stdout);
            write(STDOUT_FILENO, "HIJO: libera el semaforo...\n",sizeof("HIJO: libera el semaforo...\n"));
            if(semop(id, &v, 1) < 0)
            {
                perror("semop p"); exit(16);
            }
            fflush(stdout);
            sleep(rand() % 2);
        }
    }
    wait(NULL);
    semctl(id, 0, IPC_RMID);   // Destruyo el semaforo en el kernel
}