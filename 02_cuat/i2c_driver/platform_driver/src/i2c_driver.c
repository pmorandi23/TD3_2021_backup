#include "../inc/i2c_driver.h"
#include "MPU6050_functions.c"
#include "i2c_functions.c"

// Struct del device ID
static struct of_device_id i2c_of_device_ids[] = {
	{
		.compatible = COMPATIBLE,
	},
	{}};

MODULE_DEVICE_TABLE(of, i2c_of_device_ids);
// Struct platform_driver
static struct platform_driver i2c_pd = {
	.probe = i2c_probe,
	.remove = i2c_remove,
	.driver = {
		.name = COMPATIBLE,
		.of_match_table = of_match_ptr(i2c_of_device_ids)},
};
// Se ejecuta luego de correr insmod por consola.
static int __init i2c_init(void)
{
	int result = 0;
	pr_alert("%s: Asignando memoria al CharDevice...\n", ID);
	// cdev_alloc
	device.i2c_MPU6050_cdev = cdev_alloc();
	if (!device.i2c_MPU6050_cdev)
	{
		pr_alert("%s: No se puede asignar memoria al CharDevice.\n", ID);
	}
	pr_alert("%s: Memoria asignada correctamente al CharDevice.\n", ID);
	// alloc_chrdev_region
	if ((result = alloc_chrdev_region(&device.i2c_MPU6050, MENOR, CANT_DISP, NAME)) < 0)
	{
		pr_alert("%s: No es posible asignar el numero mayor\n", ID);
		cdev_del(device.i2c_MPU6050_cdev); // Libero memoria asignada al cdev
		return result;
	}
	pr_alert("%s: MAJOR asignado:  %d 0x%X\n", ID, MAJOR(device.i2c_MPU6050), MAJOR(device.i2c_MPU6050));
	// cdev_init - No devuelve resultado de error. Es void.
	cdev_init(device.i2c_MPU6050_cdev, &i2c_ops);
	// cdev_add - Agrega el Char Device al kernel.
	if ((result = cdev_add(device.i2c_MPU6050_cdev, device.i2c_MPU6050, CANT_DISP)) < 0)
	{
		// unregister_chrdev_region
		unregister_chrdev_region(device.i2c_MPU6050, CANT_DISP);
		pr_alert("%s: No es no es posible registrar el dispositivo\n", ID);
		return result;
	}
	// class_create
	if ((device.i2c_MPU6050_class = class_create(THIS_MODULE, CLASS_NAME)) == NULL)
	{
		pr_alert("%s: Cannot create the struct class for device\n", ID);
		cdev_del(device.i2c_MPU6050_cdev);
		unregister_chrdev_region(device.i2c_MPU6050, CANT_DISP);
		return EFAULT;
	}
	// change permission /dev/i2c_driver
	device.i2c_MPU6050_class->dev_uevent = change_permission_cdev;
	// device_create
	if ((device_create(device.i2c_MPU6050_class, NULL, device.i2c_MPU6050, NULL, COMPATIBLE)) == NULL)
	{
		pr_alert("%s: No se puede crear el dispositivo.\n", ID);
		cdev_del(device.i2c_MPU6050_cdev);
		unregister_chrdev_region(device.i2c_MPU6050, CANT_DISP);
		class_destroy(device.i2c_MPU6050_class);
		//device_destroy(device.i2c_MPU6050_class, device.i2c_MPU6050);
		return EFAULT;
	}
	pr_alert("%s: Inicializacion del módulo completada.\n", ID);
	// platform_driver_register
	if ((result = platform_driver_register(&i2c_pd)) < 0)
	{
		pr_alert("%s: No se pudo registrar el driver\n", ID);
		cdev_del(device.i2c_MPU6050_cdev);
		unregister_chrdev_region(device.i2c_MPU6050, CANT_DISP);
		device_destroy(device.i2c_MPU6050_class, device.i2c_MPU6050);
		class_destroy(device.i2c_MPU6050_class);
		return result;
	}
	pr_alert("%s: Driver I2C registrado correctamente.\n", ID);
	return 0;
}
// Se ejecuta luego de correr rmmod por consola.
static void __exit i2c_exit(void)
{
	printk(KERN_ALERT "%s: Cerrando el CharDevice\n", ID);
	// cdev_del - remove a cdev from the system - https://manned.org/cdev_del.9
	cdev_del(device.i2c_MPU6050_cdev);
	// unregister_chrdev_region - unregister a range of device numbers - https://manned.org/unregister_chrdev_region.9
	unregister_chrdev_region(device.i2c_MPU6050, CANT_DISP);
	// device_destroy
	device_destroy(device.i2c_MPU6050_class, device.i2c_MPU6050);
	// class_destroy
	class_destroy(device.i2c_MPU6050_class);
	// platform_driver_unregister
	platform_driver_unregister(&i2c_pd);
	printk(KERN_ALERT "%s: Módulo cerrado correctamente.\n", ID);
}
// Se ejecuta como evento a la llamada de platform_driver_register. Viene a buscar el driver del device.
static int i2c_probe(struct platform_device *i2c_pd)
{
	int result = 0;
	int aux;

	pr_info("%s: Ingreso a la función probe() \n", ID);
	pr_info("%s: Mapeando memoria... \n", ID);
	// Mapeo el registro CM_PER - Paginación a partir de la dir. lineal CM_PER
	if ((cmper_baseAddr = ioremap(CM_PER, CM_PER_LEN)) == NULL)
	{
		pr_alert("%s: No pudo mapear CM_PER\n", ID);
		cdev_del(device.i2c_MPU6050_cdev);
		device_destroy(device.i2c_MPU6050_class, device.i2c_MPU6050);
		class_destroy(device.i2c_MPU6050_class);
		unregister_chrdev_region(device.i2c_MPU6050, CANT_DISP);
		return 1;
	}
	pr_info("%s: cmper_baseAddr: 0x%X\n", ID, (unsigned int)cmper_baseAddr);
	// --------------------------------------------------------------------
	// -------------- Habilitacion del clock para el I2C2------------------
	// --------------------------------------------------------------------
	aux = ioread32(cmper_baseAddr + CM_PER_I2C2_CLKCTRL);
	aux |= 0x02;
	iowrite32(aux, cmper_baseAddr + CM_PER_I2C2_CLKCTRL);
	msleep(10); // Demora para asegurar que el clock este ready.
	pr_info("%s: CM_PER_I2C: 0x%X", ID, ioread32(cmper_baseAddr + CM_PER_I2C2_CLKCTRL));
	// Mapeo el registro CONTROL MODULE - Paginación a partir de la dir. lineal CTRL_MODULE_BASE
	if ((ctlmod_baseAddr = ioremap(CTRL_MODULE_BASE, CTRL_MODULE_LEN)) == NULL)
	{
		pr_alert("%s: No pudo mapear CONTROL MODULE\n", ID);
		iounmap(cmper_baseAddr);
		cdev_del(device.i2c_MPU6050_cdev);
		device_destroy(device.i2c_MPU6050_class, device.i2c_MPU6050);
		class_destroy(device.i2c_MPU6050_class);
		unregister_chrdev_region(device.i2c_MPU6050, CANT_DISP);
		return 1;
	}
	pr_info("%s: ctlmod_baseAddr: 0x%X\n", ID, (unsigned int)ctlmod_baseAddr);
	// -----------------------------------------------------
	// ----Configuración de pines SDA y SCL-----------------
	//  Fast | Reciever Enable | Pullup | Pullup/pulldown disabled
	// -----------------------------------------------------
	iowrite32(0x33, ctlmod_baseAddr + CTRL_MODULE_UART1_CTSN); // 0x3B also
	iowrite32(0x33, ctlmod_baseAddr + CTRL_MODULE_UART1_RTSN); // 0x3B also
	// Mapeo el registro I2C2 - Paginación a partir de la dir. lineal I2C2
	if ((i2c2_baseAddr = ioremap(I2C2, I2C2_LEN)) == NULL)
	{
		pr_alert("%s: No pudo mapear I2C\n", ID);
		iounmap(cmper_baseAddr);
		iounmap(ctlmod_baseAddr);
		cdev_del(device.i2c_MPU6050_cdev);
		device_destroy(device.i2c_MPU6050_class, device.i2c_MPU6050);
		class_destroy(device.i2c_MPU6050_class);
		unregister_chrdev_region(device.i2c_MPU6050, CANT_DISP);
		return 1;
	}
	pr_info("%s: i2c2_baseAddr: 0x%X\n", ID, (unsigned int)i2c2_baseAddr);
	// Configuracion de VirtualIRQ - El sistema devuelve un virtual interrupt request.
	if ((virq = platform_get_irq(i2c_pd, 0)) < 0)
	{
		iounmap(cmper_baseAddr);
		iounmap(ctlmod_baseAddr);
		iounmap(i2c2_baseAddr);
		cdev_del(device.i2c_MPU6050_cdev);
		device_destroy(device.i2c_MPU6050_class, device.i2c_MPU6050);
		class_destroy(device.i2c_MPU6050_class);
		unregister_chrdev_region(device.i2c_MPU6050, CANT_DISP);
		return 1;
	}
	// Asignación del virtual interrupt request a un handler.
	if (request_irq(virq, (irq_handler_t)i2c_irq_handler, IRQF_TRIGGER_RISING, COMPATIBLE, NULL))
	{
		pr_alert("%s: No se le pudo bindear VIRQ con handler\n", ID);
		iounmap(cmper_baseAddr);
		iounmap(ctlmod_baseAddr);
		iounmap(i2c2_baseAddr);
		cdev_del(device.i2c_MPU6050_cdev);
		device_destroy(device.i2c_MPU6050_class, device.i2c_MPU6050);
		class_destroy(device.i2c_MPU6050_class);
		unregister_chrdev_region(device.i2c_MPU6050, CANT_DISP);
		return 1;
	}
	pr_info("%s: Numero de IRQ asignado %d\n", ID, virq);
	// Inicialización del módulo I2C
	I2C_init();
	// Inicialización de parámetros del sensor MPU6050
	MPU6050_init();
	pr_info("%s: MPU6050 inicializado correctamente.\n", ID);
	pr_info("%s: Driver I2C configurado correctamente.\n", ID);
	pr_info("%s: Cerrando la función probe()...\n", ID);
	return result;
}
// Se ejecuta como evento a la llamada de platform_driver_unregister
static int i2c_remove(struct platform_device *i2c_pd)
{
	int result = 0;
	pr_alert("%s: Entrando a la función remove()...\n", ID);
	iounmap(cmper_baseAddr);
	iounmap(ctlmod_baseAddr);
	iounmap(i2c2_baseAddr);
	free_irq(virq, NULL);
	pr_alert("%s: Cerrando la función remove()...\n", ID);
	return result;
}

static int fop_open(struct inode *inode, struct file *file)
{
	uint8_t rx;
	pr_info("---------------------------------------\n", ID);
	pr_info("%s: File Operation OPEN --> Entrando...\n", ID);
	rx = 0;
	i2c_write_buffer(WHO_AM_I, 0x00, READ_REGISTER);
	rx = i2c_read_buffer();
	rx = rx & 0x7E;
	if (rx != 0x68)
	{
		pr_alert("Error en el sensor! No responde correctamente\n");
		return -1;
	}
	pr_info("%s: Respuesta del MPU6050 -> WHO_AM_I: 0x%x\n", ID, rx);

	pr_info("%s: File Operation OPEN --> Cerrando..\n", ID);
	return 0;
}
// Entra luego de un error de un close desde el user
static int fop_release(struct inode *inode, struct file *file)
{
	pr_alert("%s: REALEASE file operation --> Cerrando...\n", ID);
	pr_info("--------------------------------------------\n", ID);
	return 0;
}

static ssize_t fop_read(struct file *device_descriptor, char __user *user_buffer, size_t read_len, loff_t *my_loff_t)
{
	int result = 0;
	uint16_t fifoCount;

	pr_info("\n\n\n%s: File Operations: READ --> Abriendo\n", ID);

	// Verificación de punteros.
	if (access_ok(VERIFY_WRITE, user_buffer, read_len) == 0)
	{
		pr_alert("%s: File Operations: READ --> Error en el buffer del usuario.\n", ID);
		return -1;
	}
	// Chequeo si los bytes solicitados son multiplo de 14 (1 paquete de datos del MPU6050)
	if (read_len % 14 != 0)
	{
		pr_alert("%s: File Operations: READ --> Bytes solicitados (%d) no son múltiplos de 14!\n", ID, read_len);
		return -1;
	}
	// Verificación de que el tamaño del buffer sea menor a la cantidad máxima de bytes validos dentro de la FIFO
	if (read_len > MAX_BYTES_TO_READ)
	{
		pr_alert("%s: File Operations: READ --> Tamaño del buffer de usuario mayor a lo que puede entregar el sensor.\nSe limita a 1022 bytes (73 paquetes)\n", ID);
		read_len = MAX_BYTES_TO_READ;
	}
	pr_info("%s: File Operations: READ --> User requiere leer %d bytes\n", ID, read_len);
	/* ----------------------------------------------------------------- */
	/* -------------Lectura de la FIFO del MPU6050---------------------- */
	/* ----------------------------------------------------------------- */
	// Espero a que se llene la FIFO si no tiene valores.
	// Si no es mayor a la cantidad que solicita el usuario, la lleno. Sino, ya tengo data para devolverle
	i2c_write_buffer(USER_CTRL, 0x44, WRITE_REGISTER); // Enable FIFO and reset it
	do
	{
		msleep(5);
		// Leo la cantidad de bytes en la FIFO
		fifoCount = MPU6050_read_fifo_count();
		//pr_info("FIFO_COUNT DENTRO del while= %d \n\n",fifoCount);
	} while (fifoCount < read_len);
	if (fifoCount > 1022)
	{
		pr_alert("File Operations: READ --> FIFO_COUNT overflow= %d \n\n", fifoCount);
		return -1;
	}
	// Asigno memoria dinámicamente (tiene sentido ya que una vez terminada la file operation, devuelvo memoria)
	i2cStruct.MPU6050_dataBuffer = (uint8_t *)kmalloc(read_len * sizeof(uint8_t), GFP_KERNEL); // GFP_KERNEL: Get Free Page from Kernel. El otro argumento, el tamaño.
	// Leo primeros 100 bytes de la FIFO
	i2c_write_buffer(FIFO_R_W, 0x00, READ_REGISTER); // Direcciono registro de FIFO
	i2c_read_burst(read_len);						 //Leo 280 bytes sin STOP
	pr_info("%s: File Operations: READ --> %d bytes leidos correctamente. Copiando a usuario...\n", ID, read_len);
	// Le respondo al usuario con data del sensor.
	if ((result = copy_to_user(user_buffer, i2cStruct.MPU6050_dataBuffer, read_len)) > 0)
	{ //en copia correcta devuelve 0
		pr_info("%s: File Operations: READ --> Falla en copia de buffer de kernel a buffer de usuario\n", ID);
		return -1;
	}
	// Libero memoria
	kfree(i2cStruct.MPU6050_dataBuffer);
	pr_info("%s: File Operations: READ --> Cerrando ...\n\n\n", ID, read_len);

}

static long fop_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
{
	return EFAULT;
}

static ssize_t fop_write(struct file *device_descriptor, const char __user *user_buffer, size_t write_len, loff_t *my_loff_t)
{
	return EFAULT;
}

static int change_permission_cdev(struct device *dev, struct kobj_uevent_env *env)
{
	add_uevent_var(env, "DEVMODE=%#o", 0666);
	return 0;
}

// Al correr insmod por consola, corre module_init y toma como parametro el puntero a función y la ejecuta.
module_init(i2c_init);
// Al correr rmmod por consola, corre module_exit y toma como parametro el puntero a función y la ejecuta.
module_exit(i2c_exit);
