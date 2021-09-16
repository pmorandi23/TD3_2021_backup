#include "defines.h"




extern int count_child;
extern int ppid;
extern int child_counter;
extern int child_killed;

void sigchld_handler (int);

void sigint_handler (int);

void sigusr1_handler(int); 