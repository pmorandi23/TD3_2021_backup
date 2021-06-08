out=./bin/mibios.bin
NASM=nasm
NFLAGS=-fbin -l$(LIST) -Wall
OBJS=
BIN=mibios.bin
SOURCES=./src/memcopy.asm
LIST=./sup/memcopy.lst

all: $(SOURCES) Makefile
	mkdir -p bin  
	mkdir -p sup
	$(NASM) $(NFLAGS) $(SOURCES) -o ./bin/$(BIN) 	
bochs:
	bochs -q
clean:
	rm -fr ./sup/*.lst ./bin/*.elf ./bin/*.o ./bin/*.bin
bless:
	bless ./bin/mibios.bin
