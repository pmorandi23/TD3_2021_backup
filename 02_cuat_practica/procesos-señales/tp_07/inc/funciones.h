#include "defines.h"




extern int count_child;
extern int ppid;

void sigchld_handler (int);

void sigint_handler (int);

void sigusr1_handler(int); 