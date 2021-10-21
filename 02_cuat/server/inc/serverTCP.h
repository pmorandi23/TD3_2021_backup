//Defines
#define SHM_SIZE    4096
#define SEM_1_KEY   1234
#define SEM_2_KEY   4321
#define SHM_1_KEY   4567
#define SHM_2_KEY   7384
#define RUNNING     1
#define CLOSING     0
#define TRUE        1
#define FALSE       0

// Structs
struct MPU6050_REGS
{
    uint16_t accel_xout;
    uint16_t accel_yout;
    uint16_t accel_zout;
    int16_t temp_out;
    uint16_t gyro_xout;
    uint16_t gyro_yout;
    uint16_t gyro_zout;
};

// Structs
struct serverConfig
{
    int maxConnections;
    int backlog;
    int meanSamples;
    int connections;
};


// Prototipos
int crear_socket_server(char *, struct serverConfig *);
void* crear_shared_memory(key_t , int* );
int crear_semaforo(int *, key_t);
int cerrar_IPCS(void);
int atender_cliente_TCP(struct sockaddr_in, int);
int config_signals();
int leer_data_sensor();

