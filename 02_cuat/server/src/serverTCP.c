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
#include <signal.h>
#include <sys/wait.h>
#include "../inc/serverTCP.h"
#include "../inc/handlers.h"

/* TD3 - faltantes (al 05/10/21):
- Archivo de cfg
- Borrar apagar_servidor() del accept() porque ya funciona bien el select() 
- Cerrar semaforos y shared memory correctamente*/

#define MAX_CONN 10 //Nro maximo de conexiones en espera

// Variables globales
char *sharedMemPointer;
struct sembuf p = {0, -1, SEM_UNDO}; // Estructura para tomar el semáforo
struct sembuf v = {0, +1, SEM_UNDO}; // Estructura para liberar el semáforo
int clientsSemaphoreID;
int configFileSemafhoreID;
int serverRunning = RUNNING;
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
    int socketServer, socketAux, nbr_fds, sharedMemId;
    struct sockaddr_in clientAddress;
    socklen_t clientAddresslen;
    system("clear"); // Limpio la consola
    //Recibo por línea de comandos el puerto del servidor.
    if (argc == 2)
    {
        printf("---------------------------------------------------\n");
        printf("---------------------------------------------------\n");
        printf("********Bienvenido al servidor concurrente!********\n");
        printf("---------------------------------------------------\n");
        printf("------------------------------\n");
        printf("Configurando IPCS y Sockets...\n");
        printf("------------------------------\n");
        // Creo 2 semáforos
        if (crear_semaforo(&clientsSemaphoreID, SEM_1_KEY) == -1)
        {
            return 0;
        }
        if (crear_semaforo(&configFileSemafhoreID, SEM_2_KEY) == -1)
        {
            return 0;
        }
        printf("-------------------------------------\n");
        printf("Semáforo ID: %d creado correctamente.\n", clientsSemaphoreID);
        printf("Semáforo ID: %d creado correctamente.\n", configFileSemafhoreID);
        printf("-------------------------------------\n");
        // Creo memoria compartida de 4K
        if ((sharedMemId = crear_shared_memory(SHM_1_KEY)) == -1)
        {
            return 0;
        }
        printf("---------------------------------------\n");
        printf("Memoria compartida ID: %d creada correctamente.\n", sharedMemId);
        printf("---------------------------------------\n");
        // Apunto la struct del sensor a la memoria compartida.
        dataSensor = (struct MPU6050_REGS *)sharedMemPointer;
        // Creo el socket. Le paso el puerto obtenido por línea de comandos.
        if ((socketServer = crear_socket_server(argv[1])) < 0)
        {
            return 0;
        }

        if ((config_signals()) == -1)
        {

            return 0;
        }
        printf("-----------------------------------\n");
        printf("Señales configuradas correctamente.\n");
        printf("-----------------------------------\n");

        // Creo proceso hijo para leer datos del sensor y escribirlos en la shared_memory
        if (!fork())
        {
            printf("----------------------------------------------------------------------------\n");
            printf("Proceso hijo PID N° %d obteniendo data del sensor y almacenando en la shm...\n", getpid());
            printf("----------------------------------------------------------------------------\n");
            srand(getpid()); // Inicializo el rand() para simular el sensor.
            // Código del hijo
            while (serverRunning)
            {
                semop(clientsSemaphoreID, &p, 1); //Tomo el semaforo
                //Escribo en shared mem simulando ser el sensor cada 1 seg. Con Enter se manda.
                dataSensor->accel_xout = rand();
                dataSensor->accel_yout = rand();
                dataSensor->accel_zout = rand();
                dataSensor->gyro_xout = rand();
                dataSensor->gyro_yout = rand();
                dataSensor->gyro_zout = rand();
                dataSensor->temp_out = rand();
                semop(clientsSemaphoreID, &v, 1); //Libero el semaforo
                printf("PID %d :dataSensor update.\n", getpid());
                sleep(5);
            }
            printf("-----------------------------------------------\n");
            printf("PID %d : HIJO LECTOR DEL SENSOR MURIENDO!.\n", getpid());
            printf("-----------------------------------------------\n");
            exit(1);
        }
        else
        {
            // Código del padre. Se queda esperando conexiones entrantes con select() y accept()
            // Permite atender a multiples usuarios
            while (serverRunning)
            {
                fd_set readfds;
                // Crear la lista de "file descriptors" que vamos a escuchar
                FD_ZERO(&readfds);
                // Especificamos el socket, podria haber mas.
                FD_SET(socketServer, &readfds);
                // Espera al establecimiento de alguna conexion.
                // El primer parametro es el maximo de los fds especificados en
                // las macros FD_SET + 1.
                printf("Antes de select(), nbr_fds = %d\n\n\n", nbr_fds);
                nbr_fds = select(socketServer + 1, &readfds, NULL, NULL, NULL);

                if ((nbr_fds < 0) && (errno != EINTR))
                {
                    perror("select");
                }
                if (!FD_ISSET(socketServer, &readfds))
                {
                    continue;
                }
                // Si tengo conexion entrante, nbr_fds > 0 y da paso al accept()
                if (nbr_fds > 0)
                {

                    printf("Antes de accept(), nbr_fds = %d\n\n\n", nbr_fds);
                    // La funcion accept rellena la estructura address con informacion
                    // del cliente y pone en addrlen la longitud de la estructura.
                    // Aca se podria agregar codigo para rechazar clientes invalidos
                    // cerrando s_aux. En este caso el cliente fallaria con un error
                    // de "broken pipe" cuando quiera leer o escribir al socket.
                    clientAddresslen = sizeof(clientAddress);
                    if ((socketAux = accept(socketServer, (struct sockaddr *)&clientAddress, &clientAddresslen)) < 0)
                    {
                        if (serverRunning)
                        {
                            perror("Error en accept");
                            return 0;
                        }
                        apagar_server(socketServer); // Apago el servidor correctamente.
                        return 0;
                    }
                    // Creo un pid para cada conexión entrante
                    if (!fork())
                    {
                        if (atender_cliente_TCP(clientAddress, socketAux) == -1)
                        {

                            return 0;
                        }
                        printf("-------------------\n");
                        printf("PID %d: muriendo...\n", getpid());
                        printf("-------------------\n");
                        // Cierro el pid del hijo que atendió conexión entrante.
                        exit(1);
                    }
                }
            }
            apagar_server(socketServer);
        };
    }
    else
    {
        printf("\n\nLinea de comandos: servtcp Puerto\n\n");
    }
    return 0;
}

int apagar_server(int _socketServer)
{
    printf("---------------------------------\n");
    printf("PID PARENT %d: Apagando servidor.\n", getpid());
    printf("---------------------------------\n");
    // Cierra el servidor
    close(_socketServer);
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
            printf("------------------------------------------\n");
            printf("Servidor TCP escuchando en el puerto %s...\n", port);
            printf("------------------------------------------\n");
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
 * \param key Llave única para la creación de la shm.
 * \brief Crea memoria compartida de 4K 
 * \return Devuelve el ID de la shm si fue un éxito, -1 si hubo error.
 * 
 **/
int crear_shared_memory(key_t key)
{

    int shmid;
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
    return shmid;
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
 * \fn int cerrar_IPCS(int *semaphoreID)
 * \param semaphoreID ID del semáforo a cerrar.
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
    char buffeRxClient[255];
    char bufferTxServer[100];

    //atender_cliente_TCP();
    strcpy(ipClientAddress, inet_ntoa(clientAddress.sin_addr)); // Levanta la IP del cliente.
    clientPort = ntohs(clientAddress.sin_port);                 // Levanta el puerto del cliente
    // Espera recibir mensaje del cliente...
    if (recv(socketAux, buffeRxClient, sizeof(buffeRxClient), 0) == -1)
    {
        perror("Error en recv");
        return -1;
    }
    printf("\n++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n");
    printf("PID %d : Recibido del cliente %s:%d: %s\n", getpid(), ipClientAddress, clientPort, buffeRxClient);
    printf("++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n");

    // Envia el mensaje al cliente
    // Armo el objeto de respuesta para el cliente.
    semop(clientsSemaphoreID, &p, 1); //Tomo el semaforo
    sprintf(
        bufferTxServer,
        "X OUT: %d\nY OUT: %d\nZ OUT: %d\nGYRO X OUT: %d\nGYRO Y OUT: %d\nGYRO Z OUT: %d\nTEMP. OUT: %d\n",
        dataSensor->accel_xout,
        dataSensor->accel_yout,
        dataSensor->accel_zout,
        dataSensor->gyro_xout,
        dataSensor->gyro_yout,
        dataSensor->gyro_zout,
        dataSensor->temp_out);
    semop(clientsSemaphoreID, &v, 1); //Libero el semaforo
    if (send(socketAux, strcat(bufferTxServer, "\0"), strlen(bufferTxServer) + 1, 0) == -1)
    {
        perror("Error en send");
        return -1;
    }
    printf("\n*************************************\n");
    printf("PID %d: Respuesta al cliente enviada!\n", getpid());
    printf("*************************************\n");
    // Cierra la conexion con el cliente actual
    close(socketAux);
    printf("\n-----------------------------------\n");
    printf("PID %d: Socket auxiliar cerrado OK.\n", getpid());
    printf("-----------------------------------\n");
    // Cierro el pid del hijo que atendió conexión entrante.
    //exit(1);
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