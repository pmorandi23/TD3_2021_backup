KERNEL_SOURCE = /lib/modules/$(shell uname -r)/build
MOD_NAME = i2c_driver
PWD := $(shell pwd)

# Converts a module object in LKM
obj-m += src/$(MOD_NAME).o

#compila el modulo haciendo una llamada al Makefile que esta en '/lib/modules/$(shell uname -r)/build'
all: softclean build insmod

build:
	make -C ${KERNEL_SOURCE} M=${PWD} modules

# Hace el clean de los archivos objetos generados producto de la compilación del ko
softclean:
	make -C ${KERNEL_SOURCE} M=${PWD} clean

clean: rmmod softclean 

rebuild: rmmod all 

#revisa si el modulo esta instalado
cat:
	cat /proc/modules | grep $(MOD_NAME)

# Instala el modulo en el kernel.
insmod:
	sudo insmod src/$(MOD_NAME).ko

# Desinstala el modulo del kernel
rmmod:
	sudo rmmod src/$(MOD_NAME).ko

#muestra los mensajes (dmesg), en el ejemplo todos los printk imprimen el nombre del archivo
dmesg:
	dmesg | grep $(MOD_NAME) 

awk:
	cat /proc/devices | grep $(MOD_NAME)

# Revisa el log del sistema para chequear el estado del driver y demas
tail:
	tail -f /var/log/syslog

info:
	modinfo src/$(MOD_NAME).ko

dev:
	ls -l /dev/	| grep $(MOD_NAME)