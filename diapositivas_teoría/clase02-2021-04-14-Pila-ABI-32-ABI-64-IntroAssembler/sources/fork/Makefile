exec=fork-example
all:
	nasm -f elf64 fork-example.asm -l fork-example.lst
	ld -o $(exec) fork-example.o
clean:
	rm -f *.lst *.o $(exec)
