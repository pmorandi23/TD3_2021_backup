.PHONY: clean

BINPATH = ./bin/
DOCPATH = ./doc/
INCPATH = ./inc/
LIBPATH = ./lib/
SRCPATH = ./src/
SUPPATH = ./sup/

AC = nasm
CC = gcc
AFLAGS = -f elf32
CFLAGS = -c -m32 -fno-stack-protector -fno-asynchronous-unwind-tables -Wall -fno-PIC

LDFLAGS = -z max-page-size=0x01000 --oformat=binary -m elf_i386

LDSCRIPT = linker.ld
ODFLAGS = -CprsSx --prefix-addresses
#en objs guardo todos mis objetos elf
OBJS = $(BINPATH)init32.elf $(BINPATH)reset.elf $(BINPATH)init16.elf $(BINPATH)main.elf  $(BINPATH)functions_asm.elf $(BINPATH)functions_rom.elf $(BINPATH)handlers_32.elf $(BINPATH)functions.elf $(BINPATH)sys_tables.elf $(BINPATH)init_screen.elf

SRC_NAME = mibios

all: $(BINPATH)$(SRC_NAME).bin $(BINPATH)$(SRC_NAME).elf bochs
	mkdir -p doc
	hexdump -C $(BINPATH)$(SRC_NAME).bin > $(DOCPATH)$(SRC_NAME)_hexdump.txt
	objdump $(ODFLAGS) $(BINPATH)$(SRC_NAME).elf > $(DOCPATH)$(SRC_NAME)_objdump.txt
	readelf -a $(BINPATH)$(SRC_NAME).elf > $(DOCPATH)$(SRC_NAME)_readelf.txt


$(BINPATH)$(SRC_NAME).bin: $(OBJS)
	ld $(LDFLAGS) -T $(LDSCRIPT) $(OBJS) -o $@ -Map $(SRC_NAME).map

$(BINPATH)$(SRC_NAME).elf: $(OBJS)
	ld -z max-page-size=0x01000 -m elf_i386 -T $(LDSCRIPT) $(OBJS) -o $@

$(BINPATH)main.elf: $(SRCPATH)main.s
	@echo Generando $@
	mkdir -p bin
	$(AC) $(AFLAGS) $< -o $@ -l $@.lst

$(BINPATH)reset.elf: $(SRCPATH)reset.s
	@echo Generando $@
	mkdir -p bin
	$(AC) $(AFLAGS) $< -o $@ -l $@.lst

$(BINPATH)init16.elf: $(SRCPATH)init16.s
	@echo Generando $@
	mkdir -p bin
	$(AC) $(AFLAGS) $< -o $@ -l $@.lst

$(BINPATH)init_screen.elf: $(SRCPATH)init_screen.s
	@echo Generando $@
	mkdir -p bin
	$(AC) $(AFLAGS) $< -o $@ -l $@.lst

$(BINPATH)init32.elf: $(SRCPATH)init32.s
	@echo Generando $@
	mkdir -p bin
	$(AC) $(AFLAGS) $< -o $@ -l $@.lst

$(BINPATH)functions_rom.elf: $(SRCPATH)functions_rom.c
	@echo Generando $@
	mkdir -p bin
	$(CC) $(CFLAGS) $< -o $@

$(BINPATH)functions.elf: $(SRCPATH)functions.c
	@echo Generando $@
	mkdir -p bin
	$(CC) $(CFLAGS) $< -o $@

$(BINPATH)handlers_32.elf: $(SRCPATH)handlers_32.s
	@echo Generando $@
	mkdir -p bin
	$(AC) $(AFLAGS) $< -o $@ -l $@.lst

$(BINPATH)functions_asm.elf: $(SRCPATH)functions_asm.s
	@echo Generando $@
	mkdir -p bin
	$(AC) $(AFLAGS) $< -o $@ -l $@.lst

$(BINPATH)sys_tables.elf: $(SRCPATH)sys_tables.s
	@echo Generando $@
	mkdir -p bin
	$(AC) $(AFLAGS) $< -o $@ -l $@.lst


bochs:

	bochs -q 

clean:

	rm $(BINPATH)*.bin $(BINPATH)*.elf $(BINPATH)*.lst *.map