# Recibe argumento TAG por command line
# valores posibles TAG=NONE (o cualquier otra cosa), o TAG=LINK_TROUGH_GCC 

ASM=nasm
LD=ld
CC=gcc
SOURCE=hello-printf-64.asm
LST=$(SOURCE:.asm=.lst)
OBJ=$(SOURCE:.asm=.o)
ASM_FLAGS=-f elf64 -o$(OBJ) -l$(LST) -FDWARF -g -Wall -d$(TAG)
LD_FLAGS= -o$(SOURCE:.asm=) -lc -g --dynamic-linker /lib64/ld-linux-x86-64.so.2
CC_FLAGS= -o$(SOURCE:.asm=) -no-pie -g -Wall

all: $(OBJ)
ifeq ($(TAG),LINK_TROUGH_GCC)	
	$(CC) $(CC_FLAGS) $(OBJ)
else
	$(LD) $(LD_FLAGS) $(OBJ) 
endif

$(OBJ): $(SOURCE)
	$(ASM) $(ASM_FLAGS) $(SOURCE)

clean:
	rm -f *.o *.lst $(SOURCE:.asm=)
