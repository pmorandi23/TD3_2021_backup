#include "../inc/funciones.h"

//-- MAIN --

int main(void)
{
	int pfds[2];
	char buf[30];
	if (pipe(pfds) == -1)
	{
		perror("pipe");
		exit(1);
	}
	printf("writing to file descriptor #%d\n", pfds[1]);
	write(pfds[1], "test", 5);
	printf("reading from file descriptor #%d\n", pfds[0]);
	read(pfds[0], buf, 5);
	printf("read \"%s\"\n", buf);
	return 0;
}