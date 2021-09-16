SCRPATH = ./src
OBJPATH = ./obj

CC = gcc
OFLAGS = -lm -o
CFLAGS = -c -Wall
OUTPUT = ejecutable
OBJETO = main.o funciones.o


all: $(OBJETO) 
	$(CC) $(OBJETO) $(OFLAGS) $(OUTPUT)

main.o: $(SCRPATH)/main.c
	$(CC) $< $(CFLAGS)

funciones.o: $(SCRPATH)/funciones.c
	$(CC) $< $(CFLAGS)

run:
	./$(OUTPUT) $(arg)

clean:
	rm *.o *.exe