all:
	nasm -g -f elf64 -F DWARF -ohola64.o hola64.asm
	ld hola64.o -o holamundo -g

clean:
	rm -f *.o holamundo
