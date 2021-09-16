#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>

//-- MAIN --
int main (void) 
{
int var = 0, i = 0;
int pid;

    for ( i=0; i<CANTIDAD_HIJOS; < i++)
    {

    }
	pid = fork();
	if (pid == 0) 
	{
		//Código del hijo
		var++;
		printf("Proceso hijo ID = %d, Variable = %d \n\r", getpid(), var);
		sleep(5);
	}
	else if(pid > 0) 
	{
	    //Código del padre
		printf("Proceso padre ID = %d, Variable = %d \n\r", getpid(), var);
		sleep(5);
	}
	else 
	{
	    //Error
        printf("Error en en la creación del proceso\n\r");
		
    }

	return(0);
} 
