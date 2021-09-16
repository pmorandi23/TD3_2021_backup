#include "../inc/funciones.h"

int count_child, ppid, child_counter = 0, child_killed = 0;
//-- MAIN --

int main(int argc, char *argv[])
{
	int i = 0, pid;
	struct sigaction signal_1, signal_2, signal_3;
	FILE *fp;
	char folder[10] = "./files/";
	char file[100];
	char pid_char[10];

	// Recibo por línea de comandos la cantidad de procesos hijos a crearse
	count_child = atoi(argv[1]);
	// Configuro señal SIGUSR1
	signal_1.sa_flags = 0;				   // Flags de la señal
	signal_1.sa_handler = sigusr1_handler; // Le asigno el handler a la señal
	sigemptyset(&signal_1.sa_mask);		   // Limpio todas las mascaras de señales del vector
	// Seteo la señal SIGUSR1 a la señal que cree
	if (sigaction(SIGUSR1, &signal_1, NULL) == -1)
	{
		perror("Error en el seteo de sigaction\n\r");
		exit(1);
	}
	// Configuro señal SIGINT
	signal_2.sa_flags = 0;				  // Flags de la señal
	signal_2.sa_handler = sigint_handler; // Le asigno el handler a la señal
	sigemptyset(&signal_2.sa_mask);		  // Limpio todas las mascaras de señales del vector
	// Seteo la señal SIGCHLD a la señal que cree
	if (sigaction(SIGINT, &signal_2, NULL) == -1)
	{
		perror("Error en el seteo de sigaction\n\r");
		exit(1);
	}
	// Configuro señal SIGCHLD
	signal_3.sa_flags = 0;				   // Flags de la señal
	signal_3.sa_handler = sigchld_handler; // Le asigno el handler a la señal
	sigemptyset(&signal_3.sa_mask);		   // Limpio todas las mascaras de señales del vector
	// Seteo la señal SIGCHLD a la señal que cree
	if (sigaction(SIGCHLD, &signal_3, NULL) == -1)
	{
		perror("Error en el seteo de sigaction\n\r");
		exit(1);
	}
	ppid = getpid(); // PID del padre
	//Otra forma de generar procesos hijos en el handler, automaticamente.
	for (i = 0; i < count_child; i++)
	{
		pid = fork();
		if (pid == 0)
		{
			//Código del hijo
			while (1)
			{
				printf("Proceso hijo creado ID = %d\n\n", getpid());
				sleep(10); // Espero 10 segundos
				sprintf(file, "%s", folder);		// Armo la ruta de la carpeta donde voy a guardar los archivos
				sprintf(pid_char, "%d", getpid()); // Convierto el PID a char
				strcat(file, pid_char);			   // Obtengo el path
				fp = fopen(file, "w");			   // Abro el archivo de este código para escribirlo
				//fwrite(buffer_write, sizeof(char),sizeof(buffer_write),fp);
				fprintf(fp, "Proceso hijo ID=%d, mi padre es ID=%d, mi grupo ID=%d, child_counter=%d\r\n", getpid(), getppid(), getpgrp(), child_counter);
				//printf("Soy el hijo ID = %d. Mi padre es ID = %d. Mi GroupID es = %d\n\r", getpid(), getppid(), getpgrp());
				fclose(fp);
			}
		}
	}

	while (1)
	{
		sleep(1); // Padre esperando
		if (child_killed > count_child - 1)
		{
			printf("Finaliza proceso padre\n\r");
			return 0;
		}
	}

	/* 
	while (count_child != -1)
	{
		if (count_child > -1)
		{
			wait(NULL);
			printf("Fin proceso padre ID = %d\n\r", getpid());
			return 0;
		}
		count_child --;
	}
	 */
}
