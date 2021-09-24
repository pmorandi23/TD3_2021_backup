#include <stdio.h>
#include <stdlib.h>
#include <errno.h>
#include <sys/types.h>
#include <sys/ipc.h>
#include <sys/msg.h>


#define PATH "/home/pablo/repo/r5054-td3-morandi-pablo-jonathan/02_cuat/message-queues/queue_write/src/main.c"


struct my_msgbuf
{
    long mtype;
    char mtext[200];
};
int main(void)
{
    struct my_msgbuf buf;
    int msqid;
    key_t key;
    if ((key = ftok(PATH, 'B')) == -1)
    { /* same key as kirk.c */
        perror("ftok");
        exit(1);
    }
    if ((msqid = msgget(key, 0644)) == -1)
    { /* connect to the queue */
        perror("msgget");
        exit(1);
    }
    printf("spock: ready to receive messages, captain.\n");
    for (;;)
    { /* Spock never quits! */
        if (msgrcv(msqid, &buf, sizeof buf.mtext, 0, 0) == -1)
        {
            perror("msgrcv");
            exit(1);
        }
        printf("spock: \"%s\"\n", buf.mtext);
    }
    return 0;
}