out=mibios.bin
ENSAMBLADOR=nasm
NFLAGS=-o $(out) -l$(LIST) -fbin -Wall
BIN=mibios.bin
SOURCES=mibios.asm
LIST=mibios.lst
$(out): $(SOURCES) Makefile
	$(ENSAMBLADOR) $(NFLAGS) $(SOURCES) -o$@
bochs:
	bochs -q
clean:
	rm -fr $(out) *.lst
