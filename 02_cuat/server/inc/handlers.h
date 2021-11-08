
// Defines
#define RUNNING         1
#define CLOSING         0
#define TRUE        1
#define FALSE       0

// Externs
extern volatile  int serverRunning;
extern volatile int updateServerConfig;
extern volatile int childsKilled;
// Prototipos de función
void sigusr2_handler(int);

void sigint_handler (int);

void sigchld_handler(int sig);
