#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>

/**********************************************************/
/* funcion MAIN                                           */
/* Orden Parametros: IP destino, puerto , mensaje         */
/*                                                        */
/**********************************************************/
int main(int argc, char *argv[])
{
  int s;
  struct sockaddr_in bs, des;
  char resp[255];

  if (argc == 4)
  {

    // Creamos el socket
    s = socket(AF_INET, SOCK_STREAM, 0);
    if (s != -1)
    {
      bs.sin_family = AF_INET;
      bs.sin_port = htons(0);                 //Asigna un puerto disponible de la maquina
      bs.sin_addr.s_addr = htonl(INADDR_ANY); //Asigna una IP de la maquina

      // Conecta el socket a la direccion local
      if (bind(s, (struct sockaddr *)&bs, sizeof(bs)) != -1)
      {
        // Se prepara el nombre de la maquina remota
        des.sin_family = AF_INET;
        des.sin_addr.s_addr = inet_addr(argv[1]);
        des.sin_port = htons(atoi(argv[2]));

        // Establece la conexion con la maquina remota
        if (connect(s, (struct sockaddr *)&des, sizeof(des)) < 0)
        {
          perror("Error en connect");
          exit(1);
        }
        // Envia el mensaje
        send(s, argv[3], strlen(argv[3]) + 1, 0);
        printf("\n\n->Enviando: %s, a: %s en el puerto: %s \n", argv[3], argv[1], argv[2]);
        // Recibe la respuesta
        recv(s, resp, sizeof(resp), 0);
        printf("<-Recibido: %s\n", resp);
        close(s);
        sleep(1);
      }
      else
      {
        printf("ERROR al conectar el socket\n");
      }
    }
    else
    {
      printf("ERROR: El socket no se ha creado correctamente!\n");
    }
  }

  else
  {
    printf("\n\nLinea de comandos: clitcp IP destino, puerto, mensaje\n\n");
  }
  return 0;
}



