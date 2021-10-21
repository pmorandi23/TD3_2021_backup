SRCPATH = ./src/
OBJPATH = ./obj/
COMPATH = ./comons/

CC = gcc
OFLAGS = -lm -o   
CFLAGS = -c -Wall
OUTPUT = serverTCP
OBJETO = $(OBJPATH)serverTCP.o $(OBJPATH)handlers.o $(OBJPATH)configFile.o $(OBJPATH)config.o $(OBJPATH)string.o $(OBJPATH)dictionary.o 

all: $(OBJETO) 
	$(CC) $(OBJETO) $(OFLAGS) $(OUTPUT)	

$(OBJPATH)serverTCP.o: $(SRCPATH)serverTCP.c
	$(CC) $< $(CFLAGS) -o $@

$(OBJPATH)handlers.o: $(SRCPATH)handlers.c
	$(CC) $< $(CFLAGS) -o $@

$(OBJPATH)configFile.o: $(SRCPATH)configFile.c
	$(CC) $< $(CFLAGS) -o $@

$(OBJPATH)config.o: $(COMPATH)config.c 
	$(CC) $< $(CFLAGS) -o $@

$(OBJPATH)string.o: $(COMPATH)string.c 
	$(CC) $< $(CFLAGS) -o $@

$(OBJPATH)dictionary.o: $(COMPATH)collections/dictionary.c
	$(CC) $< $(CFLAGS) -o $@
	
run:	
	./$(OUTPUT) $(arg)

clean:

	rm ./obj/*.o serverTCP



