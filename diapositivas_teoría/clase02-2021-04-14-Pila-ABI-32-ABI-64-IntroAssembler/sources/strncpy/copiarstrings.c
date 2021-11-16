#include<stdio.h>
#include<string.h>
#include<stdlib.h>

extern char * strncpy_asm64 (char * dest, char* src, size_t n);


int main (int argc, char * argv[])
{
	char * destino1,* destino2; //punteros a strings destino 
	int strmembytes;//cantida de memoria que ocupará la string (en bytes)
	if (argc != 2)
	{
		fprintf (stderr,"Argumentos insuficientes. Invocar: %s [cadena de texto]\n\n",argv[0]);
		exit (1);
	}
	printf ("Cadena origen: %s\n", argv[1]);
	printf ("----------------------------\n\n");

	// Definimos 
	strmembytes = strlen (argv[1]) + 1; //Calculamos la cantidad de bytes que usa la string origen.
	destino1 = malloc ( strmembytes * sizeof(char) ); //Reservamos la memoria que utilizará la string destino.
	destino2 = malloc ( strmembytes * sizeof(char) ); //Reservamos la memoria que utilizará la string destino.

	puts ("copiando texto con strncpy");
	strncpy(destino1,argv[1],strmembytes);
	printf ("cadena destino => \"%s\"\n\n",destino1);
	printf ("----------------------------\n\n");

	puts ("copiando texto con strncpy_asm64");
	strncpy_asm64 (destino2,argv[1],strmembytes);
	printf ("cadena destino => \"%s\"\n\n",destino2);
	printf ("----------------------------\n\n");

	free (destino1);
	free (destino2);
	exit (0);
}