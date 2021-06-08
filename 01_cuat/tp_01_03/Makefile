LINKER_OBJECTS = ./bin/init16.o ./bin/reset.o 
LINKER_SCRIPT = ./linker.ld
LINKER_DEPENDENCIES = init16 reset
#mi programa va a arrancar en la seccion "reset" en la etiqueta "reset_entry"
LINKER_ENTRY_POINT = reset_entry  
OUTPUT = mibios.bin

#-z max-page-size se usa para PAGINACION (todavía no)
$(OUTPUT): $(LINKER_DEPENDENCIES)
	@echo Generando $@...
	ld -z max-page-size=0x01000 --oformat=binary -m elf_i386 -T $(LINKER_SCRIPT) -e $(LINKER_ENTRY_POINT) $(LINKER_OBJECTS) -o ./bin/$(OUTPUT)

init16: ./src/init16.asm
	@echo Generando $@.asm...
	mkdir -p bin
	mkdir -p sup
	nasm -f elf32 ./src/$@.asm -o ./bin/$@.o -l ./sup/$@.lst

reset: ./src/reset.asm
	@echo Generando $@.asm...
	mkdir -p bin
	mkdir -p sup
	nasm -f elf32 ./src/$@.asm -o ./bin/$@.o -l ./sup/$@.lst

bless:
	bless ./bin/$(OUTPUT)

clean:
	rm -fr ./sup/*.lst ./bin/*.elf ./bin/*.o ./bin/*.bin

bochs:
	bochs -q
