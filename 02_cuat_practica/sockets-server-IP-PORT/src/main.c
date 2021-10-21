#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <errno.h>
#define MAX_CONN 10 //Nro maximo de conexiones en espera

/**********************************************************/
/* funcion MAIN                                           */
/* Orden Parametros: Puerto                               */
/*                                                        */
/**********************************************************/
int main(int argc, char *argv[])
{
  int s, s_aux, nbr_fds;
  struct sockaddr_in address;
  char entrada[255];
  char ipAddr[20];
  int Port;
  socklen_t addrlen;

  if (argc == 2)
  {
    // Creamos el socket
    s = socket(AF_INET, SOCK_STREAM,0);
    if (s != -1)
    {
      // Asigna el puerto indicado y una IP de la maquina
      address.sin_family = AF_INET;
      address.sin_port = htons(atoi(argv[1]));
      address.sin_addr.s_addr = htonl(INADDR_ANY);

      // Conecta el socket a la direccion local
      if( bind(s, (struct sockaddr*)&address, sizeof(address)) != -1)
      {
        printf("\n\aServidor ACTIVO escuchando en el puerto: %s\n",argv[1]);
        // Indicar que el socket encole hasta MAX_CONN pedidos
        // de conexion simultaneas.
        if (listen(s, MAX_CONN) < 0)
        {
          perror("Error en listen");
          exit(1);
        }
        // Permite atender a multiples usuarios
        while (1)
        {
          fd_set readfds;

          // Crear la lista de "file descriptors" que vamos a escuchar
          FD_ZERO(&readfds);

          // Especificamos el socket, podria haber mas.
          FD_SET(s, &readfds);

          // Espera al establecimiento de alguna conexion.
          // El primer parametro es el maximo de los fds especificados en
          // las macros FD_SET + 1.
          nbr_fds = select(s+1, &readfds, NULL, NULL, NULL);

          if ((nbr_fds<0) && (errno!=EINTR))
          {
            perror("select");
          }
          if (!FD_ISSET(s,&readfds))
          {
            continue;
          }

          // La funcion accept rellena la estructura address con informacion
          // del cliente y pone en addrlen la longitud de la estructura.
          // Aca se podria agregar codigo para rechazar clientes invalidos
          // cerrando s_aux. En este caso el cliente fallaria con un error
          // de "broken pipe" cuando quiera leer o escribir al socket.
          addrlen = sizeof(address);
          if ((s_aux = accept (s, (struct sockaddr*) &address, &addrlen)) < 0)
          {
            perror("Error en accept");
            exit(1);
          }
          strcpy(ipAddr, inet_ntoa(address.sin_addr));
          Port = ntohs(address.sin_port);
          // Recibe el mensaje del cliente
          if (recv(s_aux, entrada, sizeof(entrada), 0) == -1)
          {
            perror("Error en recv");
//            exit(1);
          }
          printf("Recibido del cliente %s:%d: %s\n", ipAddr, Port, entrada);
          // Envia el mensaje al cliente
          if (send(s_aux, strcat(entrada,"\0"), strlen(entrada)+1, 0) == -1)
          {
            perror("Error en send");
//            exit(1);
          }
          // Cierra la conexion con el cliente actual
          close(s_aux);
        }
        // Cierra el servidor
        close(s);
      }
      else
      {
        printf("ERROR al nombrar el socket\n");
      }
    }
    else
    {
      printf("ERROR: El socket no se ha creado correctamente!\n");
    }
  }
  else
  {
    printf("\n\nLinea de comandos: servtcp Puerto\n\n");
  }
  return 0;
}
