SCRPATH = ./src
OBJPATH = ./obj

CC = gcc
OFLAGS = -lm -o
CFLAGS = -c -g -Wall
OUTPUT = ejecutable
OBJETO = serverTCP.o 
arg    = 5


all: $(OBJETO) 
	$(CC) $(OBJETO) $(OFLAGS) $(OUTPUT)

serverTCP.o: $(SCRPATH)/serverTCP.c
	$(CC) $< $(CFLAGS)

run:
	./$(OUTPUT) 

clean:
	rm *.o ejecutable