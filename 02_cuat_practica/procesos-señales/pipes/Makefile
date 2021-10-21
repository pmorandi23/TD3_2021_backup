SCRPATH = ./src
OBJPATH = ./obj

CC = gcc
OFLAGS = -lm -o
CFLAGS = -c -g -Wall
OUTPUT = ejecutable
OBJETO = main.o funciones.o
arg    = 5


all: $(OBJETO) 
	$(CC) $(OBJETO) $(OFLAGS) $(OUTPUT)

main.o: $(SCRPATH)/main.c
	$(CC) $< $(CFLAGS)

funciones.o: $(SCRPATH)/funciones.c
	$(CC) $< $(CFLAGS)

run:
	./$(OUTPUT) 

clean:
	rm *.o *.exe