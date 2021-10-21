#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>
#include <sys/ipc.h>
#include <sys/shm.h>

#define SHM_SIZE 1024 /* make it a 1K shared memory segment */

int main()
{
    key_t key;
    int shmid;
    char *data;
    int mode;
    char buf[30];
    int enter = 0, i = 0;


    while (!enter)
    {
        buf[i] = getchar();
        if (buf[i] == '\n'){
            enter = 1;
        }   
        i++;
    }



    /* make the key: */
    if ((key = ftok("./src/main.c", 'R')) == -1)
    {
        perror("ftok");
        exit(1);
    }
    /* connect to (and possibly create) the segment: */
    if ((shmid = shmget(key, SHM_SIZE, 0644 | IPC_CREAT)) == -1)
    {
        perror("shmget");
        exit(1);
    }
    /* attach to the segment to get a pointer to it: */
    data = shmat(shmid, (void *)0, 0);
    if (data == (char *)(-1))
    {
        perror("shmat");
        exit(1);
    }
    /* read or modify the segment, based on the command line: */

    printf("writing to segment: %s \n", buf);
    strncpy(data, buf, SHM_SIZE); // Copia MAXIMO SHM_SIZE caracteres a la shared memory

    printf("segment contains: \"%s\"\n", data);
    /* detach from the segment: */
    if (shmdt(data) == -1)
    {
        perror("shmdt");
        return 0;
    }
}