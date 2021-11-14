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
#include <stdbool.h>
#include "../comons/config.h"
#include "../inc/serverTCP.h"
#include "../inc/configFile.h"

/**
 * \fn void leer_config_server(struct serverConfig *serverConf)
 * \param serverConf Struct con parámetros del servidor
 * \brief Lee de la SHM los parámetros del server.
 * \return No devuelve nada.
 **/
void leer_config_server(struct serverConfig *serverConf)
{
    t_config *config;
    //Leo el archivo de configuracion
    config = config_create(CONFIG_PATH);
    if (config != NULL)
    {
        //El archivo existe, lo leo.
        if (config_has_property(config, "CONEXIONES_MAX") == true)
        {
            serverConf->maxConnections = config_get_int_value(config, "CONEXIONES_MAX");
        }
        else
        {
            serverConf->maxConnections = CANT_CONEX_MAX_DEFAULT;
        }
        if (config_has_property(config, "BACKLOG") == true)
        {
            serverConf->backlog = config_get_int_value(config, "BACKLOG");
        }
        else
        {
            serverConf->backlog = BACKLOG_DEFAULT;
        }
        if (config_has_property(config, "MUESTREO_SENSOR") == true)
        {
            serverConf->meanSamples = config_get_int_value(config, "MUESTREO_SENSOR");
        }
        else
        {
            serverConf->meanSamples = MUESTREO_SENSOR;
        }
    }
    else
    {
        //No existe el archivo de configuracion, utilizo valores por default
        printf("No existe el archivo de configuracion\n");
        serverConf->backlog = BACKLOG_DEFAULT;
        serverConf->maxConnections = CANT_CONEX_MAX_DEFAULT;
        serverConf->meanSamples = MUESTREO_SENSOR;
    }

    //serverConf->connections = 0;

    printf("*******************************************************\n");
    printf("PID % d: Update desde archivo de config. del server\n",getpid());
    printf("*******************************************************\n");
    printf("Cantidad maxima de conexiones      = %d                \n", serverConf->maxConnections);
    printf("Backlog                            = %d                \n", serverConf->backlog);
    printf("Muestreo del filtro                = %d                \n", serverConf->meanSamples);
    printf("Cantidad de conexiones actuales    = %d                \n", serverConf->connections);
    printf("*******************************************************\n");
    printf("*******************************************************\n");
}

/**
 * \fn void apagar_server(struct serverConfig * _serverConfig)
 * \param _serverConfig Struct con parámetros del servidor
 * \brief Escribe en la SHM de los parámetros del server un 0 en el flag "serverRunning"
 * \return No devuelve nada.
 **/
void apagar_server(struct serverConfig * _serverConfig)
{
    _serverConfig->serverRunning = CLOSING;
}