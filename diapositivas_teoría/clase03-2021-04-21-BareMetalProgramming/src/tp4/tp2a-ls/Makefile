ENSAMBLADOR=nasm
LINKER=ld
OBJOUT=mibios.bin
EFLAGS=-Wall -felf32 -l$(OBJOUT:.bin=.lst)
LDFLAGS=-z max-page-size=4096 -m elf_i386 -T$(OBJOUT:.bin=2.ls) -e reset -Map $(OBJOUT:.bin=.map)  --oformat=binary 

$(OBJOUT): $(OBJOUT:.bin=.elf)
	echo "Linkeando "$< ...
	$(LINKER) $(LDFLAGS) $< -o $@

%.elf: %.asm Makefile
	echo "Ensamblando "$< ...
	$(ENSAMBLADOR) $(EFLAGS) $< -o $@

clean:
	rm *.elf *.bin *.map *.lst

bochs:
	bochs -q
	
