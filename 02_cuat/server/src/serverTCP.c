#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <errno.h>
#include <sys/ipc.h>
#include <sys/shm.h>
#include <sys/sem.h>
#include "../inc/serverTCP.h"

#define MAX_CONN 10 //Nro maximo de conexiones en espera

// Variables globales
char *sharedMemPointer;
struct sembuf p = {0, -1, SEM_UNDO}; // Estructura para tomar el semáforo
struct sembuf v = {0, +1, SEM_UNDO}; // Estructura para liberar el semáforo
int clientsSemaphoreID;
int configFileSemafhoreID;
struct MPU6050_REGS *dataSensor;

/**
 * \fn int main(int argc, char *argv[])
 * \brief Servidor concurrente TCP.  Escucha peticiones HTTP o de determinado Objeto y responde con mediciones de un sensor.
 * \param argv Puerto del servidor. Numero > 1024
 * \details El servidor escucha peticiones, crea un proceso que lee del sensor y escribe en shm. 
 * \return Cuando finaliza el servidor, devuelve 0 si fue un éxito.
 * 
 **/
int main(int argc, char *argv[])
{
    int socketServer, socketAux;
    struct sockaddr_in clientAddress;
    char entrada[255];
    char ipClientAddress[20];
    int Port;
    socklen_t clientAddresslen;
    char bufferSend[100];

    //Recibo por línea de comandos el puerto del servidor.
    if (argc == 2)
    {
        // Creo 2 semáforos
        if (crear_semaforo(&clientsSemaphoreID) == -1)
        {

            return 0;
        }
        if (crear_semaforo(&configFileSemafhoreID) == -1)
        {

            return 0;
        }
        printf("--------------------------------\n");
        printf("Semáforos creados correctamente.\n");
        printf("--------------------------------\n");

        // Creo memoria compartida de 4K
        if (crear_shared_memory() == -1)
        {

            printf("Apagando creación de server TCP...\n");
            return 0;
        }
        printf("---------------------------------------\n");
        printf("Memoria compartida creada correctamente.\n");
        printf("---------------------------------------\n");

        // Apunto la struct del sensor a la memoria compartida.
        dataSensor = (struct MPU6050_REGS *)sharedMemPointer;

        // Creo el socket. Le paso el puerto obtenido por línea de comandos.
        if ((socketServer = crear_socket_server(argv[1])) != -1)
        {
            // Creo proceso hijo para leer datos del sensor y escribirlos en la shared_memory
            if (!fork())
            {
                printf("----------------------------------------------------------------------------\n");
                printf("Proceso hijo PID N° %d obteniendo data del sensor y almacenando en la shm...\n", getpid());
                printf("----------------------------------------------------------------------------\n");
                srand(getpid()); // Inicializo el rand() para simular el sensor.
                // Código del hijo
                while (1)
                {

                    //Escribo en shared mem simulando ser el sensor cada 1 seg. Con Enter se manda.
                    dataSensor->accel_xout = rand();
                    dataSensor->accel_yout = rand();
                    dataSensor->accel_zout = rand();
                    dataSensor->gyro_xout = rand();
                    dataSensor->gyro_yout = rand();
                    dataSensor->gyro_zout = rand();
                    dataSensor->temp_out = rand();
                    printf("dataSensor update.\n");
                    sleep(2);
                }
            }
            else
            {
                // Código del padre
                // Permite atender a multiples usuarios
                while (1)
                {
                    /* POR AHORA DEJO COMETANDO EL USO DE FD para el handshake de accept()
            
            
            
            fd_set readfds;
            // Crear la lista de "file descriptors" que vamos a escuchar
            FD_ZERO(&readfds);

            // Especificamos el socket, podria haber mas.
            FD_SET(s, &readfds);

            // Espera al establecimiento de alguna conexion.
            // El primer parametro es el maximo de los fds especificados en
            // las macros FD_SET + 1.
            nbr_fds = select(s + 1, &readfds, NULL, NULL, NULL);

            if ((nbr_fds < 0) && (errno != EINTR))
            {
                perror("select");
            }
            if (!FD_ISSET(s, &readfds))
            {
                continue;
            } */
                    // La funcion accept rellena la estructura address con informacion
                    // del cliente y pone en addrlen la longitud de la estructura.
                    // Aca se podria agregar codigo para rechazar clientes invalidos
                    // cerrando s_aux. En este caso el cliente fallaria con un error
                    // de "broken pipe" cuando quiera leer o escribir al socket.
                    clientAddresslen = sizeof(clientAddress);
                    if ((socketAux = accept(socketServer, (struct sockaddr *)&clientAddress, &clientAddresslen)) < 0)
                    {
                        perror("Error en accept");
                        exit(1);
                    }
                    strcpy(ipClientAddress, inet_ntoa(clientAddress.sin_addr)); // Levanta la IP del cliente.
                    Port = ntohs(clientAddress.sin_port);                       // Levanta el puerto del cliente

                    // Espera recibir mensaje del cliente...
                    if (recv(socketAux, entrada, sizeof(entrada), 0) == -1)
                    {
                        perror("Error en recv");
                        //exit(1);
                    }
                    printf("Recibido del cliente %s:%d: %s\n", ipClientAddress, Port, entrada);
                    // Envia el mensaje al cliente
                    // Armo el objeto de respuesta para el cliente.
                    sprintf(
                        bufferSend,
                        "X OUT: %d\nY OUT: %d\nZ OUT: %d\nGYRO X OUT: %d\nGYRO Y OUT: %d\nGYRO Z OUT: %d\nTEMP. OUT: %d\n",
                        dataSensor->accel_xout,
                        dataSensor->accel_yout,
                        dataSensor->accel_zout,
                        dataSensor->gyro_xout,
                        dataSensor->gyro_yout,
                        dataSensor->gyro_zout,
                        dataSensor->temp_out);

                    if (send(socketAux, strcat(bufferSend, "\0"), strlen(bufferSend) + 1, 0) == -1)
                    {
                        perror("Error en send");
                        //exit(1);
                    }
                    printf("------------------------------\n");
                    printf("Respuesta al cliente enviada!\n");
                    printf("------------------------------\n");
                    // Cierra la conexion con el cliente actual
                    close(socketAux);
                }
                // Cierra el servidor
                close(socketServer);
            };
        }
    }
    else
    {
        printf("\n\nLinea de comandos: servtcp Puerto\n\n");
    }
    return 0;
}
/**
 * \fn int crear_socket_server(char *port)
 * \brief Funcion que crea un socket, lo asocia a la IP y configura cantidad de conexiones máximas.
 * \details La función realiza socket(), bind() y listen()
 * \param port Socket a traves del cual se hace el connect-accept
 * \return int Ante exito, retorna el socket por donde se realiza la comunicacion. Retorna -1 si hubo error.
 * 
 **/
int crear_socket_server(char *port)
{
    int socket_server;
    struct sockaddr_in address;

    // Creamos el socket
    if ((socket_server = socket(AF_INET, SOCK_STREAM, 0)) != -1)
    {
        // Asigna el puerto indicado y una IP de la maquina
        address.sin_family = AF_INET;
        address.sin_port = htons(atoi(port));
        address.sin_addr.s_addr = htonl(INADDR_ANY);

        // Conecta el socket a la direccion local
        if (bind(socket_server, (struct sockaddr *)&address, sizeof(address)) != -1)
        {
            printf("---------------------------------------\n");
            printf("Socket server TCP creado correctamente.\n");
            printf("---------------------------------------\n");
            printf("---------------------------------------\n");
            printf("Servidor TCP escuchando en el puerto: %s...\n", port);
            printf("---------------------------------------\n");
            // Indicar que el socket encole hasta MAX_CONN pedidos de conexion simultaneas.
            if (listen(socket_server, MAX_CONN) < 0)
            {
                perror("Error en listen");
                return -1;
            }
        }
        else
        {
            perror("ERROR al nombrar el socket\n");
            return -1;
        }
    }
    else
    {
        perror("ERROR: El socket no se ha creado correctamente!\n");
        return -1;
    }
    return (socket_server);
}

/**
 * \fn int crear_shared_memory(void)
 * \brief Crea memoria compartida de 4K 
 * \return Devuelve 0 si fue un éxito.
 * 
 **/
int crear_shared_memory(void)
{

    key_t key;
    int shmid;
    /* make the key: */
    if ((key = ftok("./src/serverTCP.c", 'R')) == -1)
    {
        perror("ftok");
        return -1;
    }
    /* connect to (and possibly create) the segment: */
    if ((shmid = shmget(key, SHM_SIZE, 0644 | IPC_CREAT)) == -1)
    {
        perror("shmget");
        return -1;
    }
    /* attach to the segment to get a pointer to it: */
    sharedMemPointer = shmat(shmid, (void *)0, 0);
    if (sharedMemPointer == (char *)(-1))
    {
        perror("shmat");
        return -1;
    }
    return 0;
}

/**
 * \fn int crear_semaforo(int* semafhoreID)
 * \brief Crea un semáforo binario. 
 * \return Devuelve 0 si fue un éxito.
 * 
 **/
int crear_semaforo(int *semafhoreID)
{
    key_t key;
    union semun
    {
        int val;
        struct semid_ds *buf;
        unsigned short *array;
    };
    //Creacion del semaforo
    if ((key = ftok("./src/serverTCP.c", 'R')) == -1)
    {
        perror("ftok");
        return -1;
    }
    *semafhoreID = semget(key, 1, 0666 | IPC_CREAT); // semget crea 1 semáforo con permisos rw rw rw
    if (*semafhoreID < 0)
    {
        perror("ERROR: No se pudo abrir el semaforo\n");
        semctl(*semafhoreID, 0, IPC_RMID); //Cierro el semaforo
        return -1;                         // Chequea que este bien creado el semáforo
    }

    union semun u; // Crea la union
    u.val = 1;     // Asigna un 1 al val
    // Inicializo el semáforo para utilizarlo
    if (semctl(*semafhoreID, 0, SETVAL, u) < 0)
    {
        perror("ERROR: No se pudo inicializar el semaforo");
        semctl(*semafhoreID, 0, IPC_RMID); //Cierro el semaforo
        return -1;
    }

    return 0;
}
/**
 * \fn int cerrar_IPCS(int *semaphoreID)
 * \brief Cierra los IPCs existentes. 
 * \return Devuelve 0 si fue un éxito.
 * 
 **/
int cerrar_IPCS(int *semaphoreID)
{
    shmdt(sharedMemPointer);                   //Separo la memoria del proceso
    semctl(*semaphoreID, 0, IPC_RMID);         //Cierro el semaforo
    shmctl(*sharedMemPointer, IPC_RMID, NULL); //Cierro la Shared Memory
    return 0;
}
