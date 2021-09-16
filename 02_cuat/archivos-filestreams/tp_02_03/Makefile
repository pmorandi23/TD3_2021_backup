CC=gcc
SRCPATH=./src/
OUTFILE=ej_02_03
FILE=file.txt

all:
	$(CC) -o $(OUTFILE) $(SRCPATH)main.c $(SRCPATH)funciones.c -g -lm -Wall

run:
	./$(OUTFILE) $(FILE)

debug:
	gdb ./$(OUTFILE) $(FILE)


clean:
		rm $(OUTFILE) 