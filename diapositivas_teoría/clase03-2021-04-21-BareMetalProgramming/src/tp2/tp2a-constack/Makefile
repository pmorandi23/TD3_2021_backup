out=mibios.bin
NASM=nasm
NFLAGS=-o $(out) -fbin -l$(LIST) -Wall
OBJS=
BIN=mibios.bin
SOURCES=memcopy_test.asm
LIST=memcopy_test.lst
$(out): $(SOURCES) Makefile
	$(NASM) $(NFLAGS) $(SOURCES) -o$@ 
bochs:
	bochs -q
clean:
	rm -fr $(out) *.lst
