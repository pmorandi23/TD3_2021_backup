//Defines
#define SHM_SIZE 4096
#define SEM_1_KEY 1234
#define SEM_2_KEY 4321
#define SHM_1_KEY 4567
#define SHM_2_KEY 7384
#define RUNNING 1
#define CLOSING 0
#define TRUE 1
#define FALSE 0
#define MPU6050_PACKET_LENGTH   14

// Structs
struct MPU6050_REGS
{
    float accel_xout;
    float accel_yout;
    float accel_zout;
    float temp_out_float;
    float gyro_xout;
    float gyro_yout;
    float gyro_zout;
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
void *crear_shared_memory(key_t, int *);
int crear_semaforo(int *, key_t);
int cerrar_IPCS(void);
int atender_cliente_TCP(struct sockaddr_in, int);
int config_signals();
int leer_data_sensor();
