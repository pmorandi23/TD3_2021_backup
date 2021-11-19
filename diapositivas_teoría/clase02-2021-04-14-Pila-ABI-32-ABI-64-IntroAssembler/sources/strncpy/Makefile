all:
	gcc -o cpstr cpstr.o strcpasm.o -g -Wall

spdtr.o:
	gcc -c -o cpstr.o copiarstrings.c -g -Wall

strcpasm.o:
	nasm -g -f elf64 -F DWARF -ostrcpasm.o strncp.asm

clean:
	rm -f *.o cpstr	