all:
	nasm -g -f elf64 -F DWARF -oholamundo.o holamundo.asm
	gcc -no-pie -Wall -Wextra -pedantic -O0 -ggdb -oholamundo holamundo.o -v
clean:
	rm -f *.o holamundo
