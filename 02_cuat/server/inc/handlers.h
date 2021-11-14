
// Defines
#define RUNNING         1
#define CLOSING         0
#define TRUE        1
#define FALSE       0

// Externs
extern int serverRunning;
extern volatile int childsKilled;
extern volatile int childsCounter;
extern int configFileSemafhoreID;
extern struct sembuf p;
extern struct sembuf v;
extern struct serverConfig *serverConfig;
extern int childSensorReader;
extern int pipeServer[2];

// Prototipos de función
void sigusr2_handler(int);

void sigint_handler (int);

void sigchld_handler(int sig);
