#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <errno.h>
#include <fcntl.h>
#include <stdint.h>
#include <math.h>
#include <signal.h>
#include <stdbool.h>
#include <sys/wait.h>
#include <sys/ipc.h>
#include <sys/shm.h>
#include <sys/sem.h>
#include <sys/stat.h>
#include <sys/select.h>
#include <sys/sendfile.h>
#include "../inc/serverTCP.h"
#include "../inc/handlers.h"
#include "../inc/configFile.h"
#include "../inc/meanFilterMPU6050.h"

// Variables globales
// Semaphores
struct sembuf p = {0, -1, SEM_UNDO}; // Estructura para tomar el semáforo
struct sembuf v = {0, +1, SEM_UNDO}; // Estructura para liberar el semáforo
union semun //Beej Guide to UNIX IPC P32
{
    int val;
    struct semid_ds *buf;
    unsigned short *array;
};
union semun sem_attr;
int clientsSemaphoreID, configFileSemafhoreID;
// Shared Mem
int sharedMemDataSensorId = 0, sharedMemConfigServerId = 0;
void *sharedMemDataSensorPointer = (void *)0;
void *sharedMemConfigServerPointer = (void *)0;
// Flags
int serverRunning = RUNNING;
// Structs
struct MPU6050_REGS *dataSensor;
struct serverConfig *serverConfig;
// Ints
volatile int childsKilled = 0, childsCounter = 0;
int childSensorReader = 0;
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
    int socketServer, socketAux, nbr_fds = 0, ppid;
    bool maxConnectionsReached = false;
    struct sockaddr_in clientAddress;
    socklen_t clientAddresslen;
    struct timeval timeout;
    fd_set readfds;
    system("clear"); // Limpio la consola
    //Recibo por línea de comandos el puerto del servidor.
    if (argc != 2)
    {
        printf("\n\nPor favor, ingresar por línea de comandos el Puerto del servidor TCP.\n\n");
        return 0;
    }
    ppid = getpid();
    printf("------------------TD3 2021 - R5054-----------------\n\n");
    printf("Autor: Pablo Jonathan Morandi\n");
    printf("---------------------------------------------------\n\n");
    printf("********Bienvenido al servidor concurrente!********\n\n");
    printf("---------------------------------------------------\n\n");
    printf("---------------------------------------\n");
    printf("PPID %d: Configurando IPCS y Sockets...\n", ppid);
    printf("---------------------------------------\n");
    // Configuración de señales
    if ((config_signals()) == -1)
    {
        return 0;
    }
    printf("--------------------------------------------\n");
    printf("PPID %d: Señales configuradas correctamente.\n", ppid);
    printf("--------------------------------------------\n");
    // Creo 2 semáforos
    if (crear_semaforo(&clientsSemaphoreID, SEM_1_KEY) == -1)
    {
        return 0;
    }
    if (crear_semaforo(&configFileSemafhoreID, SEM_2_KEY) == -1)
    {
        return 0;
    }
    printf("------------------------------------------------\n");
    printf("PPID %d: Semáforo ID %d creado correctamente.\n", ppid, clientsSemaphoreID);
    printf("PPID %d: Semáforo ID %d creado correctamente.\n", ppid, configFileSemafhoreID);
    printf("------------------------------------------------\n");
    // Creo memoria compartida de 4K
    if ((sharedMemDataSensorPointer = crear_shared_memory(SHM_1_KEY, &sharedMemDataSensorId)) == (void *)-1)
    {
        return 0;
    }
    // Creo memoria compartida de 4K
    if ((sharedMemConfigServerPointer = crear_shared_memory(SHM_2_KEY, &sharedMemConfigServerId)) == (void *)-1)
    {
        return 0;
    }
    // Apunto la struct del sensor y la config del server a las memorias compartidas.
    dataSensor = (struct MPU6050_REGS *)sharedMemDataSensorPointer;
    serverConfig = (struct serverConfig *)sharedMemConfigServerPointer;

    // Cargar config de archivo
    serverConfig->serverRunning = RUNNING;
    leer_config_server(serverConfig);
    // Creo el socket. Le paso el puerto obtenido por línea de comandos.
    if ((socketServer = crear_socket_server(argv[1], serverConfig)) < 0)
    {
        return 0;
    }
    childSensorReader = fork();
    // Creo proceso hijo para leer datos del sensor y escribirlos en la shared_memory
    if (!childSensorReader)
    {
        printf("---------------------------------------------------------------\n");
        printf("PID %d obteniendo data del sensor y almacenando en la shm...\n", getpid());
        printf("---------------------------------------------------------------\n");
        // Código del hijo
        while (serverRunning)
        {
            leer_data_sensor();
            sleep(0.25); // Cada un seg consulto el sensor a través del driver.
        }
        printf("----------------------------------------------\n");
        printf("PID %d : proceso lector del sensor muriendo...\n", getpid());
        printf("----------------------------------------------\n");
        exit(1);
    }
    else
    {
        childsCounter++;
        // Código del padre. Se queda esperando conexiones entrantes con select() y accept()
        semop(configFileSemafhoreID, &p, 1); //Tomo el semaforo
        serverConfig->connections = 0;
        semop(configFileSemafhoreID, &v, 1); //Libero el semaforo
        printf("------------------------------------------\n");
        printf("PPID %d: SERVER: esperando conexiones...\n", ppid);
        printf("------------------------------------------\n");
        while (serverRunning)
        {
            // Si se superan las conexiones máximas, se espera hasta que se liberen.
            while (maxConnectionsReached && serverRunning)
            {
                semop(configFileSemafhoreID, &p, 1); //Tomo el semaforo
                if (serverConfig->connections < serverConfig->maxConnections)
                {
                    maxConnectionsReached = false;
                    printf("--------------------------------------------------------------------------------\n");
                    printf("PPID %d: SERVER : Conexiones liberadas. Vuelven a admitirse.\n", ppid);
                    printf("--------------------------------------------------------------------------------\n");
                }
                semop(configFileSemafhoreID, &v, 1); //Libero el semaforo
                sleep(1);
            }
            // Crear la lista de "file descriptors" que vamos a escuchar
            FD_ZERO(&readfds);
            // Especificamos el socket, podria haber mas.
            FD_SET(socketServer, &readfds);
            timeout.tv_sec = 1;
            timeout.tv_usec = 0;
            // Espera al establecimiento de alguna conexion. Cada un segundo bloquea el ppid en select() para no acerlo en accept()
            // El primer parametro es el maximo de los fds especificados en
            // las macros FD_SET + 1.
            //nbr_fds = select(socketServer + 1, &readfds, NULL, NULL, &timeout);
            nbr_fds = select(8, &readfds, NULL, NULL, &timeout); // Pongo 8 en NFDS a ver si funciona el select()

            if ((nbr_fds < 0) && (errno != EINTR))
            {
                perror("select");
            }
            /* if (!FD_ISSET(socketServer, &readfds))
                {
                    continue;
                }  */
            // Si tengo conexion entrante y no se alcanzaron las máximas permitidas, nbr_fds > 0 y da paso al accept()
            if (nbr_fds > 0 && !maxConnectionsReached && serverRunning)
            {
                printf("--------------------------------------------\n");
                printf("PPID %d: SERVER : Solicitud de conexión.\n", ppid);
                printf("--------------------------------------------\n");
                // La funcion accept rellena la estructura address con informacion
                // del cliente y pone en addrlen la longitud de la estructura.
                // Aca se podria agregar codigo para rechazar clientes invalidos
                // cerrando s_aux. En este caso el cliente fallaria con un error
                // de "broken pipe" cuando quiera leer o escribir al socket.
                clientAddresslen = sizeof(clientAddress);
                if ((socketAux = accept(socketServer, (struct sockaddr *)&clientAddress, &clientAddresslen)) < 0)
                {
                    perror("Error en accept");
                    return 0;
                }
                printf("--------------------------------------\n");
                printf("PPID %d: SERVER : Conexión aceptada.\n           Atendiendo cliente...\n", ppid);
                printf("--------------------------------------\n");
                // Creo un pid para cada conexión entrante
                if (!fork())
                {

                    // Sumo una conexión activa.
                    semop(configFileSemafhoreID, &p, 1); //Tomo el semaforo
                    serverConfig->connections++;
                    semop(configFileSemafhoreID, &v, 1); //Libero el semaforo
                    printf("--------------------------------------------\n");
                    printf("PID %d: Conexiones actuales  = %d\n", getpid(), serverConfig->connections);
                    printf("--------------------------------------------\n");

                    // Atiendo al cliente TCP.
                    if (atender_cliente_TCP(clientAddress, socketAux) == -1)
                    {
                        printf("---------------------------------------------\n");
                        printf("PID %d: Error en conexión TCP con cliente.\n        Cerrando child...\n", getpid());
                        printf("---------------------------------------------\n");
                    }
                    // Resto conexión activa.
                    semop(configFileSemafhoreID, &p, 1); //Tomo el semaforo
                    if (serverConfig->connections > 0)
                    {
                        serverConfig->connections--;
                    }
                    printf("-------------------------------------\n");
                    printf("PID %d: Conexiones actuales  = %d\n", getpid(), serverConfig->connections);
                    printf("-------------------------------------\n");
                    semop(configFileSemafhoreID, &v, 1); //Libero el semaforo
                    printf("-------------------\n");
                    printf("PID %d: muriendo...\n", getpid());
                    printf("-------------------\n");
                    //childsCounter--;
                    // Cierro el pid del hijo que atendió conexión entrante.
                    exit(1);
                }
                childsCounter++;
            }
            semop(configFileSemafhoreID, &p, 1); //Tomo el semaforo
            if (serverConfig->connections >= serverConfig->maxConnections)
            {
                maxConnectionsReached = true;
                printf("----------------------------------------------------------------------------\n\n\n");
                printf("PPID %d: SERVER : |WARNING| Conexiones máximas alcanzadas.\n", ppid);
                printf("                  Esperando que se liberen...\n\n\n");
                printf("----------------------------------------------------------------------------\n");
            }
            semop(configFileSemafhoreID, &v, 1); //Libero el semaforo
        }
    }
    // Parent esperando que mueran los hijos para luego morirse.
    printf("----------------------------------------------------\n");
    printf("PPID %d: SERVER : Esperando que mueran childs...\n", ppid);
    printf("----------------------------------------------------\n");
    while (1)
    {
        if (childsKilled > childsCounter - 1)
        {
            if ((close(socketServer)) == -1)
            {
                perror("Error cerrando el socket del server\n");
                return 0;
            } // Cierro el socket del server.
            if ((cerrar_IPCS()) == -1)
            {
                printf("\n\nPPID %d: No se pudieron cerrar correctamente todos los IPCS.\n\n", ppid);
                return 0;
            }
            printf("----------------------------------------------\n");
            printf("PPID %d: SERVER : IPCs cerrados correctamente.\n", ppid);
            printf("----------------------------------------------\n"); // Cierro todos los IPCS
            printf("----------------------------------------------\n");
            printf("PPID %d: SERVER : Servidor apagado correctamente.\n", ppid);
            printf("----------------------------------------------\n");
            printf("----------------------------------------------\n");
            printf("PPID %d: SERVER : muriendo...\n", ppid);
            printf("----------------------------------------------\n");
            return 0;
        }
        sleep(1);
    }
}

/**
 * \fn int crear_socket_server(char *port, struct serverConfig * _serverConfig)
 * \brief Funcion que crea un socket, lo asocia a la IP y configura cantidad de conexiones máximas.
 * \details La función realiza socket(), bind() y listen()
 * \param port Socket a traves del cual se hace el connect-accept
 * \return int Ante exito, retorna el socket por donde se realiza la comunicacion. Retorna -1 si hubo error.
 * 
 **/
int crear_socket_server(char *port, struct serverConfig *_serverConfig)
{
    int socket_server;
    struct sockaddr_in address;
    pid_t ppid;
    struct timeval tv;
    tv.tv_sec = 10; //  10 segundos de timeout a las operaciones de RECV
    tv.tv_usec = 0;
    ppid = getpid();
    // Creamos el socket
    if ((socket_server = socket(AF_INET, SOCK_STREAM, 0)) != -1)
    {
        // Configuro un timeout para los RECV de clientes
        if (setsockopt(socket_server, SOL_SOCKET, SO_RCVTIMEO, (const char *)&tv, sizeof tv) == -1)
        {
            perror("setsockopt");
            return -1;
        }

        // Asigna el puerto indicado y una IP de la maquina
        address.sin_family = AF_INET;
        address.sin_port = htons(atoi(port));
        address.sin_addr.s_addr = htonl(INADDR_ANY);

        // Conecta el socket a la direccion local
        if (bind(socket_server, (struct sockaddr *)&address, sizeof(address)) != -1)
        {
            printf("------------------------------------------------\n");
            printf("PPID %d: Socket server TCP creado correctamente.\n", ppid);
            printf("------------------------------------------------\n");
            printf("------------------------------------------------\n");
            printf("PPID %d: Servidor TCP escuchando en el puerto %s...\n", ppid, port);
            printf("------------------------------------------------\n");
            // Indicar que el socket encole hasta MAX_CONN pedidos de conexion simultaneas.
            if (listen(socket_server, _serverConfig->backlog) < 0)
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
 * \param key Llave única para la creación de la shm.
 * \brief Crea memoria compartida de 4K 
 * \return Devuelve el ID de la shm si fue un éxito, -1 si hubo error.
 * 
 **/
void *crear_shared_memory(key_t key, int *shmid)
{
    //int shmid;
    void *shmPointer = (void *)0;

    /* connect to (and possibly create) the segment: */
    if ((*shmid = shmget(key, SHM_SIZE, 0666 | IPC_CREAT)) == -1)
    {
        perror("shmget");
        return (void *)-1;
    }
    /* attach to the segment to get a pointer to it: */
    shmPointer = shmat(*shmid, (void *)0, 0);
    if (shmPointer == (char *)(-1))
    {
        perror("shmat");
        return (void *)-1;
    }
    printf("--------------------------------------------------\n");
    printf("PPID %d: Mem. compartida creada. ID: %d.\n", getpid(), *shmid);
    printf("--------------------------------------------------\n");
    return shmPointer;
}

/**
 * \fn int crear_semaforo(int* semafhoreID)
 * \param semaphoreID ID del semáforo a crear.
 * \param key Llave única para la creación del semáforo.
 * \brief Crea un semáforo binario. 
 * \return Devuelve 0 si fue un éxito.
 * 
 **/
int crear_semaforo(int *semafhoreID, key_t key)
{
    union semun
    {
        int val;
        struct semid_ds *buf;
        unsigned short *array;
    };
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
 * \fn int cerrar_IPCS(void)
 * \param void No recibe nada.
 * \brief Cierra los IPCs existentes. 
 * \return Devuelve 0 si fue un éxito.
 * 
 **/
int cerrar_IPCS(void)
{
    semctl(clientsSemaphoreID, 0, IPC_RMID);    // Cierro el semaforo de sensor / clientes
    semctl(configFileSemafhoreID, 0, IPC_RMID); // Cierro el semaforo de la configuracion
    if ((shmdt(sharedMemDataSensorPointer)) == -1)
    {
        perror("ERROR al detach la shm\n");
        return -1;
    } // Separo la memoria del sensor / clientes del proceso
    if ((shmctl(sharedMemDataSensorId, IPC_RMID, NULL)) == -1)
    {
        return -1;
    } // Cierro la Shared Memory de sensor / clientes
    if ((shmdt(sharedMemConfigServerPointer)) == -1)
    {
        perror("ERROR al detach la shm\n");
        return -1;
    } // Separo la memoria de la configuracion del proceso
    if ((shmctl(sharedMemConfigServerId, IPC_RMID, NULL)) == -1)
    {
        perror("ERROR al destruir la shm %d\n");
        return -1;
    } // Cierro la Shared Memory de la configuracion
    return 0;
}

/**
 * \fn void atender_cliente_TCP(struct sockaddr_in clientAddress, int socketAux)
 * \param clientAddress Struct con los datos del cliente.
 * \param socketAux Socket auxiliar para el cliente.
 * \brief Atiende conexiones TCP entrantes de clientes. Recibe petición y devuelve objeto con data del sensor.
 * \return Devuelve 0 si fue un éxito, -1 si hubo un error.
 **/
int atender_cliente_TCP(struct sockaddr_in clientAddress, int socketAux)
{
    int clientPort;
    char ipClientAddress[20];
    char bufferRxClient[255];
    char bufferTxServer[1024];

    //atender_cliente_TCP();
    strcpy(ipClientAddress, inet_ntoa(clientAddress.sin_addr)); // Levanta la IP del cliente.
    clientPort = ntohs(clientAddress.sin_port);                 // Levanta el puerto del cliente

    // Armo el msg.
    sprintf(bufferTxServer, "OK");
    printf("++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n");
    printf("PID %d : SEND to %s:%d > OK\n", getpid(), ipClientAddress, clientPort);
    printf("++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n");
    // Le respondo "OK" al connect() que realizo el cliente.
    if (send(socketAux, bufferTxServer, strlen(bufferTxServer), 0) == -1)
    {
        perror("Error en send");
        return -1;
    }
    // Espera recibir mensaje del cliente...
    if (recv(socketAux, bufferRxClient, sizeof(bufferRxClient), 0) == -1)
    {
        printf(" ------- TIMEOUT EN RECV---------\n");
        printf("- PID %d                          \n", getpid());
        printf("- Client IP : %s                  \n", ipClientAddress);
        printf("- Client port : %d                \n", clientPort);
        perror("- Error en recv");
        return -1;
    }
    // Verifico que el cliente haya respondido AKN
    if (!memcmp(bufferRxClient, "AKN", 3))
    {
        printf("++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n");
        printf("PID %d : RECV from %s:%d > AKN\n", getpid(), ipClientAddress, clientPort);
        printf("++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n");
    }
    else
    {
        printf("******************************************\n");
        printf("PID %d : Rta del cliente incorrecta.\n", getpid());
        printf("         Cerrando conexión...\n");
        printf("******************************************\n");
        return 0;
    }
    // Armo el msg.
    sprintf(bufferTxServer, "OK");
    printf("++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n");
    printf("PID %d : SEND to %s:%d > OK\n", getpid(), ipClientAddress, clientPort);
    printf("++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n");
    // Le respondo "OK" al connect() que realizo el cliente.
    if (send(socketAux, bufferTxServer, strlen(bufferTxServer), 0) == -1)
    {
        perror("Error en send");
        return -1;
    }
    // Espera recibir mensaje del cliente...
    if (recv(socketAux, bufferRxClient, sizeof(bufferRxClient), 0) == -1)
    {
        printf(" ------- TIMEOUT EN RECV---------\n");
        printf(" PID %d                          \n", getpid());
        printf(" Client IP : %s                  \n", ipClientAddress);
        printf(" Client port : %d                \n", clientPort);
        perror("Error en recv");
        return -1;
    }
    // Verifico que el cliente haya respondido KA
    if (!memcmp(bufferRxClient, "KA", 2))
    {
        printf("++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n");
        printf("PID %d : RECV from %s:%d > KA\n", getpid(), ipClientAddress, clientPort);
        printf("++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n");
    }
    else
    {
        printf("******************************************\n");
        printf("PID %d : Rta del cliente incorrecta.\n", getpid());
        printf("         Cerrando conexión...\n");
        printf("******************************************\n");
        return -1;
    }
    // Me quedo en un while hasta que el cliente me envie END. Siempre y cuando el server no se este apagando.
    printf("++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n");
    printf("PID %d : Entrando el loop.\n", getpid());
    printf("PID %d : SEND to %s:%d > dataSensor\n", getpid(), ipClientAddress, clientPort);
    printf("++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n");
    do
    {
        // Leo la SHM Mem. y armo la trama
        semop(clientsSemaphoreID, &p, 1); //Tomo el semaforo
        sprintf(bufferTxServer, "%.1f\n%.1f\n%.1f\n%.1f\n%.1f\n%.1f\n%.2f\n", dataSensor->accel_xout,
                dataSensor->accel_yout,
                dataSensor->accel_zout,
                dataSensor->gyro_xout,
                dataSensor->gyro_yout,
                dataSensor->gyro_zout,
                dataSensor->temp_out_float);
        semop(clientsSemaphoreID, &v, 1); //Libero el semaforo
        // Le respondo al cliente con los datos.
        if (send(socketAux, bufferTxServer, strlen(bufferTxServer), 0) == -1)
        {
            perror("Error en send");
            return -1;
        }
        // Espera recibir mensaje del cliente...
        if (recv(socketAux, bufferRxClient, sizeof(bufferRxClient), 0) == -1)
        {
            printf(" ------- TIMEOUT EN RECV---------\n");
            printf(" PID %d                          \n", getpid());
            printf(" Client IP : %s                  \n", ipClientAddress);
            printf(" Client port : %d                \n", clientPort);
            perror("Error en recv");
            return -1;
        }
        // Analizo rta del cliente. Siempre deberia mandar "KA". Si manda "END", termina la conexión
        if (!memcmp(bufferRxClient, "END", 3))
        {
            printf("++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n");
            printf("PID %d :RECV %s:%d > END\n", getpid(), ipClientAddress, clientPort);
            printf("++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n");
        }
        //Demora para leer la SHMMEM
        sleep(0.5);
        // Analizo si murio el proceso lector... de ser asi debo cortar todos los childs con conexiones TCP activas
        semop(configFileSemafhoreID, &p, 1); //Tomo el semaforo
        serverRunning = serverConfig->serverRunning;
        semop(configFileSemafhoreID, &v, 1); //Libero el semaforo

    } while (memcmp(bufferRxClient, "END", 3) && serverRunning);

    return 0;
}

/**
 * \fn void config_señales(void)
 * \param void No recibe nada.
 * \brief Configura las señales a utilizar.
 * \return Devuelve 0 si fue un éxito, -1 si hubo un error.
 **/
int config_signals()
{
    struct sigaction signal_1, signal_2, signal_3;
    // Configuro señal SIGUSR1 para leer al archivo de configuración
    signal_1.sa_flags = 0;                 // Flags de la señal
    signal_1.sa_handler = sigusr2_handler; // Le asigno el handler a la señal
    sigemptyset(&signal_1.sa_mask);        // Limpio todas las mascaras de señales del vector
    // Seteo la señal SIGUSR1 a la señal que cree
    if (sigaction(SIGUSR2, &signal_1, NULL) == -1)
    {
        perror("Error en el seteo de sigaction\n\r");
        return -1;
    }
    // Configuro señal SIGINT para apagar el server.
    signal_2.sa_flags = 0;                // Flags de la señal
    signal_2.sa_handler = sigint_handler; // Le asigno el handler a la señal
    sigemptyset(&signal_2.sa_mask);       // Limpio todas las mascaras de señales del vector
    // Seteo la señal SIGUSR1 a la señal que cree
    if (sigaction(SIGINT, &signal_2, NULL) == -1)
    {
        perror("Error en el seteo de sigaction\n\r");
        return -1;
    }
    // Configuro señal SIGCHLD para controlar que mueran los hijos.
    signal_3.sa_flags = 0;                 // Flags de la señal
    signal_3.sa_handler = sigchld_handler; // Le asigno el handler a la señal
    sigemptyset(&signal_3.sa_mask);        // Limpio todas las mascaras de señales del vector
    // Seteo la señal SIGCHLD a la señal que cree
    if (sigaction(SIGCHLD, &signal_3, NULL) == -1)
    {
        perror("Error en el seteo de sigaction\n\r");
        return -1;
    }

    return 0;
}

/**
 * \fn int leer_data_sensor(void)
 * \param void No recibe nada.
 * \brief Comunica con el driver asociado al sensor por I2C y lee sus valores.
 * \return Devuelve 0 si fue un éxito, -1 si hubo un error.
 **/
int leer_data_sensor()
{
    int fd, MPU6050fifoPacketsForMeanFilter, bytesToReadFromMPU6050FIFO;
    uint8_t *dataMPU6050_fifo;
    struct MPU6050_REGS dataSensorAvg;

    // Cantidad de paquetes de datos a traer de la FIFO del MPU6050
    MPU6050fifoPacketsForMeanFilter = serverConfig->meanSamples;
    // Cantidad de bytes totales a leer de la FIFO del MPU6050
    if (MPU6050fifoPacketsForMeanFilter > 73)
    {
        printf("PID %d : Paquetes para filtro exceden capacidad de FIFO. Se limitan a 72.\n\n", getpid());
        bytesToReadFromMPU6050FIFO = 72 * MPU6050_PACKET_LENGTH;
    }
    else
    {
        bytesToReadFromMPU6050FIFO = MPU6050fifoPacketsForMeanFilter * MPU6050_PACKET_LENGTH;
    }
    // Le pido al driver que traiga "meanSamples" muestras sin procesar para realizar el filtro de media móvil
    dataMPU6050_fifo = (uint8_t *)malloc(bytesToReadFromMPU6050FIFO * sizeof(uint8_t));
    //printf("PID %d : leer_data_sensor\n", getpid());
    // File operation: OPEN
    if ((fd = open("/dev/P.Morandi,i2c_td3_driver", O_RDWR)) < 0)
    {
        printf("PID %d : No es posible abrir el driver del I2C\n\n", getpid());
        return -1;
    }
    // File operation : READ
    if (read(fd, dataMPU6050_fifo, bytesToReadFromMPU6050FIFO) < 0)
    {
        printf("PID %d : No es posible leer el driver del I2C\n\n", getpid());
        return -1;
    }
    // File operation : RELEASE
    close(fd);
    // Promedio con el buffer
    dataSensorAvg = filtro_MPU6050(dataMPU6050_fifo, MPU6050fifoPacketsForMeanFilter, bytesToReadFromMPU6050FIFO);
    // Escribo en la SHM MEM
    sem_attr.val = 0;    
    semctl(clientsSemaphoreID, 0, SETVAL, sem_attr); // Tomo el semáforo

    dataSensor->accel_xout = dataSensorAvg.accel_xout;
    dataSensor->accel_yout = dataSensorAvg.accel_yout;
    dataSensor->accel_zout = dataSensorAvg.accel_zout;
    dataSensor->temp_out_float = dataSensorAvg.temp_out_float;
    dataSensor->gyro_xout = dataSensorAvg.gyro_xout;
    dataSensor->gyro_yout = dataSensorAvg.gyro_yout;
    dataSensor->gyro_zout = dataSensorAvg.gyro_zout;

    sem_attr.val = 1;    
    semctl(clientsSemaphoreID, 0, SETVAL, sem_attr); // Libero el semáforo
    // Libero memoria
    free(dataMPU6050_fifo);

    return 0;
}

