out=mibios.bin
NASM=nasm
NFLAGS=-o $(out) -fbin -l$(LIST) -Wall
OBJS=
BIN=mibios.bin
SOURCES=memcopy.asm
LIST=memcopy.lst
$(out): $(SOURCES) Makefile
	$(NASM) $(NFLAGS) $(SOURCES) -o$@ 
bochs:
	bochs -q
clean:
	rm -fr $(out) *.lst
