SRCPATH = ./src/
OBJPATH = ./obj/
COMPATH = ./comons/

CC = gcc
OFLAGS = -lm -o   
CFLAGS = -c -Wall
OUTPUT = serverTCP
OBJETO = $(OBJPATH)serverTCP.o $(OBJPATH)handlers.o 

all: $(OBJETO) 
	$(CC) $(OBJETO) $(OFLAGS) $(OUTPUT)	

$(OBJPATH)serverTCP.o: $(SRCPATH)serverTCP.c
	$(CC) $< $(CFLAGS) -o $@

$(OBJPATH)handlers.o: $(SRCPATH)handlers.c
	$(CC) $< $(CFLAGS) -o $@
	
run:	
	./$(OUTPUT) $(arg)

clean:

	rm ./obj/*.o serverTCP



