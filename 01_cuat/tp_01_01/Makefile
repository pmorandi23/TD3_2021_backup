out=./bin/mibios.bin
NASM=nasm
NFLAGS=-fbin -l$(LIST) -Wall
OBJS=
BIN=mibios.bin
SOURCES=./src/mboot4k.asm
LIST=./sup/mboot4k.lst

all: $(SOURCES) Makefile
	mkdir -p bin  
	$(NASM) $(NFLAGS) $(SOURCES) -o ./bin/$(BIN) 	
bochs:
	bochs -q
clean:
	rm -fr ./sup/*.lst ./bin/*.elf ./bin/*.o ./bin/*.bin
