
// Defines
#define RUNNING         1
#define CLOSING         0

// Externs

extern int serverRunning;
// Prototipos de función
void sigusr2_handler(int);

void sigint_handler (int);

void sigchld_handler(int sig);
