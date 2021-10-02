//Defines
#define SHM_SIZE       4096

// Prototipos 
int crear_socket_server(char *);
int crear_shared_memory(void);
int crear_semaforo(int* );
int cerrar_IPCS(int* );

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

