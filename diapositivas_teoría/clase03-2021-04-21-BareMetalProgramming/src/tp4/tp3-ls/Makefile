ENSAMBLADOR=nasm
LINKER=ld
OBJOUT=mibios.bin
EFLAGS=-Wall -felf32 -l$(OBJOUT:.bin=.lst)
#Eliminamos de los flags del linker el -e. El entry point lo definimos en el linker script
LDFLAGS=-z max-page-size=0x1000 -m elf_i386 -T$(OBJOUT:.bin=.ls) -Map $(OBJOUT:.bin=.map)  --oformat=binary 

$(OBJOUT): $(OBJOUT:.bin=.elf)
	@echo "Linkeando "$< ...
	$(LINKER) $(LDFLAGS) $< -o $@

%.elf: %.asm Makefile
	@echo "Ensamblando "$< ...
	$(ENSAMBLADOR) $(EFLAGS) $< -o $@

clean:
	rm *.elf *.bin *.map *.lst

bochs:
	bochs -q
	
