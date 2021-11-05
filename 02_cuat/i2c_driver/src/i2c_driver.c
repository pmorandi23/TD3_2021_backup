#include "../inc/i2c_driver.h"

// Inicialización de la cola
volatile int wakeupCondition = 0;
wait_queue_head_t queue = __WAIT_QUEUE_HEAD_INITIALIZER(queue);
wait_queue_head_t queueTASK_UNINTERRUPTIBLE = __WAIT_QUEUE_HEAD_INITIALIZER(queueTASK_UNINTERRUPTIBLE);

static void __iomem *cmper_baseAddr, *ctlmod_baseAddr, *i2c2_baseAddr;
int virq;
int bit;
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
	int i = 0;
	uint8_t rx = 0;
	uint8_t rxTemp[2];
	uint8_t data_send[2] = {0};
	uint16_t data_receive[2] = {0}, fifoCount = 0;
	int16_t data = 0, MPU6050TempFloat = 0;

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
	iowrite32(0x33, ctlmod_baseAddr + CTRL_MODULE_UART1_CTSN);
	iowrite32(0x33, ctlmod_baseAddr + CTRL_MODULE_UART1_RTSN);
	//iowrite32(0x3B, ctlmod_baseAddr + CTRL_MODULE_UART1_CTSN);
	//iowrite32(0x3B, ctlmod_baseAddr + CTRL_MODULE_UART1_RTSN);

	// Mapeo el registro I2C2 - Paginación a partir de la dir. lineal I2C2
	//i2c2_baseAddr = of_iomap(i2c_pd->dev.of_node, 0);

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
	// ----------------------------------------------
	// ----------------------------------------------
	// Configuración de registros del I2C - pag. 4559
	// ----------------------------------------------
	// ----------------------------------------------
	// 1 - Prescaler
	iowrite32(0x0000, i2c2_baseAddr + I2C_CON); // Deshabilito I2C2
	iowrite32(0x03, i2c2_baseAddr + I2C_PSC);	// 12Mhz preescaler (48Mhz / 4)
	// 2 - Setear SCL. MAX 400khz (SCLL y SCLH). Velocidad del sensor.
	//iowrite32(0x08, i2c2_baseAddr + I2C_SCLL); // SCL_LOW = (SCLL + 7)* 1 / 12Mhz =  1,25uS   (MPU6050 -> MAX 2,5 us - MIN 0,6us)
	//iowrite32(0x14, i2c2_baseAddr + I2C_SCLH); // SCL_HIGH = (SCLH + 7)* 1 / 12Mhz = 1,666666us (MPU6050 -> MAX 2,5 us - MIN 1,3us)
	iowrite32(0x35, i2c2_baseAddr + I2C_SCLL); // SCL_LOW = 5uS
	iowrite32(0x37, i2c2_baseAddr + I2C_SCLH); // SCL_HIGH = 5uS
	// 3 - Setear dirección propia (I2C_OA)
	iowrite32(0x77, i2c2_baseAddr + I2C_OA);
	// 4 - Config. de Slave Address.
	iowrite32(MPU6050_SLAVE_ADDR, i2c2_baseAddr + I2C_SA); // Dirección del Slave MPU6050
	//iowrite32(0x76, i2c2_baseAddr + I2C_SA); // Dirección del Slave BMP280
	// 5 - Registro I2C_CON (pag. 4634)
	/*  - Bit 15: 	  I2C_EN --> 	0h = Controller in reset. FIFO are cleared and status bits are set to their default value. 
							     	1h = Module enabled
		- Bit 13-12 : OPMODE --> Operation mode selection. These two bits select module operation mode. Value after reset is 00.
								 	0h = I2C Fast/Standard mode
		- Bit 11:     STB --> Start byte mode (I2C master mode only).The start byte mode bit is set to 1 by the CPU to configure the I2C in start byte mode
		-					  	0h = Normal mode
							  	1h = Start byte mode
		- Bit 10:     MST --> Master/slave mode (I2C mode only).
						      	0h = Slave mode
							  	1h = Master mode
		- Bit 9:      TRX --> Transmitter/receiver mode (i2C master mode only).
								0h = Receiver mode
								1h = Transmitter mode
		- Bit 8:      XSA -->  0h
		- Bit 7:	  XOA0 -->  0h
		- Bit 6:      XOA1 -->  0h
		- Bit 5:      XOA2 -->  0h
		- Bit 4: 	  XOA3 -->  0h
		- Bit 1:   	  STP -->  Stop condition (I2C master mode only).  
							   	0h = No action or stop condition detected
							   	1h = Stop condition queried
		- Bit 0: 	  STT --> Start condition (I2C master mode only).
								0h = No action or start condition detected
								1h = Start condition queried
		
		Seteo bits para:
		  - Habilitación del I2C
		  - Modo Master
		  - Modo Receptor

	*/
	iowrite32(0x8000, i2c2_baseAddr + I2C_CON);
	// -------------------------------------------
	// -------------------------------------------
	// Fin configuración I2C.
	// -------------------------------------------
	//--------------------------------------------
	// -----------Inicialización MPU6050----------
	//--------------------------------------------
	//void i2c_write_buffer(uint8_t regMPU6050, uint8_t regMPU6050_value, int operation)
	rx = 0;
	i2c_write_buffer(WHO_AM_I, 0x00, READ_REGISTER);
	rx = i2c_read_buffer();
	rx = rx & 0x7E;
	pr_info("%s: Respuesta del MPU6050 -> WHO_AM_I: 0x%x\n", ID, rx);
	//  wake up device-don't need this here if using calibration function below
	i2c_write_buffer(PWR_MGMT_1, 0x00, WRITE_REGISTER); // Clear sleep mode bit (6), enable all sensors
	//i2c_write_buffer(0x00);
	msleep(100);
	// Delay 100 ms for PLL to get established on x-axis gyro; should check for PLL ready interrupt
	// get stable time source
	i2c_write_buffer(PWR_MGMT_1, 0x01, WRITE_REGISTER); // Set clock source to be PLL with x-axis gyroscope reference, bits 2:0 = 001
	rx = i2c_read_buffer();
	pr_info("%s: Respuesta del MPU6050 -> PWR_MGMT_1: 0x%x\n", ID, rx);
	// Configure Gyro and Accelerometer
	// Disable FSYNC and set accelerometer and gyro bandwidth to 44 and 42 Hz, respectively;
	// DLPF_CFG = bits 2:0 = 010; this sets the sample rate at 1 kHz for both
	i2c_write_buffer(CONFIG, 0x03, WRITE_REGISTER);
	// Set sample rate = gyroscope output rate/(1 + SMPLRT_DIV)
	i2c_write_buffer(SMPLRT_DIV, 0x04, WRITE_REGISTER); // Use a 200 Hz sample rate (5ms)
	// Set gyroscope full scale range
	// Range selects FS_SEL and AFS_SEL are 0 - 3, so 2-bit values are left-shifted into positions 4:3
	i2c_write_buffer(GYRO_CONFIG, 0x00, READ_REGISTER); // Clear self-test bits [7:5]
	rx = i2c_read_buffer();
	i2c_write_buffer(GYRO_CONFIG, rx & ~0xE0, WRITE_REGISTER);		 // Clear self-test bits [7:5]
	i2c_write_buffer(GYRO_CONFIG, rx & ~0x18, WRITE_REGISTER);		 // Clear AFS bits [4:3]
	i2c_write_buffer(GYRO_CONFIG, rx | Gscale << 3, WRITE_REGISTER); // Set full scale range for the gyro
	// Set accelerometer configuration
	i2c_write_buffer(ACCEL_CONFIG, 0x00, READ_REGISTER); // Clear self-test bits [7:5]
	rx = i2c_read_buffer();
	i2c_write_buffer(ACCEL_CONFIG, rx & ~0xE0, WRITE_REGISTER);		  // Clear self-test bits [7:5]
	i2c_write_buffer(ACCEL_CONFIG, rx & ~0x18, WRITE_REGISTER);		  // Clear AFS bits [4:3]
	i2c_write_buffer(ACCEL_CONFIG, rx | Ascale << 3, WRITE_REGISTER); // Set full scale range for the accelerometer
	// Configure Interrupts and Bypass Enable
	// Set interrupt pin active high, push-pull, and clear   read of INT_STATUS, enable I2C_BYPASS_EN so additional chips
	// can join the I2C bus and all can be controlled by the Arduino as master
	i2c_write_buffer(INT_PIN_CFG, 0x02, WRITE_REGISTER);
	i2c_write_buffer(INT_ENABLE, 0x01, WRITE_REGISTER); // Enable data ready (bit 0) interrupt
	// Configure FIFO to capture accelerometer and gyro data for bias calculation
	i2c_write_buffer(USER_CTRL, 0x44, WRITE_REGISTER); // Enable FIFO and reset it
	i2c_write_buffer(FIFO_EN, 0xF8, WRITE_REGISTER);   // Enable gyro, accelerometer and temperature sensors for FIFO  (max size 1024 bytes in MPU-6050)
	msleep(100);									   // Wait for some samples
	//MPU6050_init();

	//****************************************************************************************************
	//****************************************************************************************************
	//****************************************************************************************************
	//****************************************************************************************************
	// ESPERO A QUE LLENE LOS PRIMEROS 14 BYTES
	//i2c_write_buffer(USER_CTRL, 0x44, WRITE_REGISTER); // Enable FIFO and reset it
	// Leo la cantidad de bytes en la FIFO

	i2c_write_buffer(FIFO_COUNTH, 0x00, READ_REGISTER);
	rxTemp[0] = i2c_read_buffer();
	i2c_write_buffer(FIFO_COUNTL, 0x00, READ_REGISTER);
	rxTemp[1] = i2c_read_buffer();
	fifoCount = ((uint16_t)rxTemp[0] << 8) | rxTemp[1];
	pr_info("FIFO_COUNT LUEGO DE PRIMER LECTURA = %d \n\n\n\n", fifoCount);
	i2c_write_buffer(USER_CTRL, 0x44, WRITE_REGISTER); // Enable FIFO and reset it
	pr_info("FIFO_COUNT LUEGO DE RESET = %d \n\n\n\n", fifoCount);

	while (fifoCount < 56)
	{
		// Leo la cantidad de bytes en la FIFO
		i2c_write_buffer(FIFO_COUNTH, 0x00, READ_REGISTER);
		rxTemp[0] = i2c_read_buffer();
		i2c_write_buffer(FIFO_COUNTL, 0x00, READ_REGISTER);
		rxTemp[1] = i2c_read_buffer();
		fifoCount = ((uint16_t)rxTemp[0] << 8) | rxTemp[1];
		//pr_info("FIFO_COUNT DENTRO del while= %d \n\n",fifoCount);
	}
	pr_info("FIFO_COUNT despues del while= %d \n\n", fifoCount);
	// Leo primeros 100 bytes de la FIFO
	i2c_write_buffer(FIFO_R_W, 0x00, READ_REGISTER); // Direcciono registro de FIFO
	i2c_read_burst(56);								 //Leo 14 bytes sin STOP
	pr_info("%s: TEMP. OUT: %d °C\n", ID, (int16_t)(i2cStruct.burstRxBuffer[6] << 8 | i2cStruct.burstRxBuffer[7]) / 340 + 36);
	pr_info("%s: TEMP. OUT: %d °C\n", ID, (int16_t)(i2cStruct.burstRxBuffer[20] << 8 | i2cStruct.burstRxBuffer[21]) / 340 + 36);
	pr_info("%s: TEMP. OUT: %d °C\n", ID, (int16_t)(i2cStruct.burstRxBuffer[34] << 8 | i2cStruct.burstRxBuffer[35]) / 340 + 36);
	pr_info("%s: TEMP. OUT: %d °C\n", ID, (int16_t)(i2cStruct.burstRxBuffer[48] << 8 | i2cStruct.burstRxBuffer[49]) / 340 + 36);

	i2c_write_buffer(FIFO_COUNTH, 0x00, READ_REGISTER);
	rxTemp[0] = i2c_read_buffer();
	i2c_write_buffer(FIFO_COUNTL, 0x00, READ_REGISTER);
	rxTemp[1] = i2c_read_buffer();
	fifoCount = ((uint16_t)rxTemp[0] << 8) | rxTemp[1];
	pr_info("FIFO_COUNT LUEGO DE PRIMER LECTURA = %d \n\n\n\n", fifoCount);
	i2c_write_buffer(USER_CTRL, 0x44, WRITE_REGISTER); // Enable FIFO and reset it
	pr_info("FIFO_COUNT LUEGO DE RESET = %d \n\n\n\n", fifoCount);

	while (fifoCount < 56)
	{
		// Leo la cantidad de bytes en la FIFO
		i2c_write_buffer(FIFO_COUNTH, 0x00, READ_REGISTER);
		rxTemp[0] = i2c_read_buffer();
		i2c_write_buffer(FIFO_COUNTL, 0x00, READ_REGISTER);
		rxTemp[1] = i2c_read_buffer();
		fifoCount = ((uint16_t)rxTemp[0] << 8) | rxTemp[1];
		//pr_info("FIFO_COUNT DENTRO del while= %d \n\n",fifoCount);
	}
	pr_info("FIFO_COUNT despues del while= %d \n\n", fifoCount);
	// Leo primeros 100 bytes de la FIFO
	i2c_write_buffer(FIFO_R_W, 0x00, READ_REGISTER); // Direcciono registro de FIFO
	i2c_read_burst(56);								 //Leo 14 bytes sin STOP
	pr_info("%s: TEMP. OUT: %d °C\n", ID, (int16_t)(i2cStruct.burstRxBuffer[6] << 8 | i2cStruct.burstRxBuffer[7]) / 340 + 36);
	pr_info("%s: TEMP. OUT: %d °C\n", ID, (int16_t)(i2cStruct.burstRxBuffer[20] << 8 | i2cStruct.burstRxBuffer[21]) / 340 + 36);
	pr_info("%s: TEMP. OUT: %d °C\n", ID, (int16_t)(i2cStruct.burstRxBuffer[34] << 8 | i2cStruct.burstRxBuffer[35]) / 340 + 36);
	pr_info("%s: TEMP. OUT: %d °C\n", ID, (int16_t)(i2cStruct.burstRxBuffer[48] << 8 | i2cStruct.burstRxBuffer[49]) / 340 + 36);

	i2c_write_buffer(FIFO_COUNTH, 0x00, READ_REGISTER);
	rxTemp[0] = i2c_read_buffer();
	i2c_write_buffer(FIFO_COUNTL, 0x00, READ_REGISTER);
	rxTemp[1] = i2c_read_buffer();
	fifoCount = ((uint16_t)rxTemp[0] << 8) | rxTemp[1];
	pr_info("FIFO_COUNT LUEGO DE PRIMER LECTURA = %d \n\n\n\n", fifoCount);
	i2c_write_buffer(USER_CTRL, 0x44, WRITE_REGISTER); // Enable FIFO and reset it
	pr_info("FIFO_COUNT LUEGO DE RESET = %d \n\n\n\n", fifoCount);

	while (fifoCount < 56)
	{
		// Leo la cantidad de bytes en la FIFO
		i2c_write_buffer(FIFO_COUNTH, 0x00, READ_REGISTER);
		rxTemp[0] = i2c_read_buffer();
		i2c_write_buffer(FIFO_COUNTL, 0x00, READ_REGISTER);
		rxTemp[1] = i2c_read_buffer();
		fifoCount = ((uint16_t)rxTemp[0] << 8) | rxTemp[1];
		//pr_info("FIFO_COUNT DENTRO del while= %d \n\n",fifoCount);
	}
	pr_info("FIFO_COUNT despues del while= %d \n\n", fifoCount);
	// Leo primeros 100 bytes de la FIFO
	i2c_write_buffer(FIFO_R_W, 0x00, READ_REGISTER); // Direcciono registro de FIFO
	i2c_read_burst(56);								 //Leo 14 bytes sin STOP
	pr_info("%s: TEMP. OUT: %d °C\n", ID, (int16_t)(i2cStruct.burstRxBuffer[6] << 8 | i2cStruct.burstRxBuffer[7]) / 340 + 36);
	pr_info("%s: TEMP. OUT: %d °C\n", ID, (int16_t)(i2cStruct.burstRxBuffer[20] << 8 | i2cStruct.burstRxBuffer[21]) / 340 + 36);
	pr_info("%s: TEMP. OUT: %d °C\n", ID, (int16_t)(i2cStruct.burstRxBuffer[34] << 8 | i2cStruct.burstRxBuffer[35]) / 340 + 36);
	pr_info("%s: TEMP. OUT: %d °C\n", ID, (int16_t)(i2cStruct.burstRxBuffer[48] << 8 | i2cStruct.burstRxBuffer[49]) / 340 + 36);

	/* pr_info("ACCEL_XOUT %d\n", (int16_t)(i2cStruct.burstRxBuffer[0]<< 8 | i2cStruct.burstRxBuffer[1] * 2 / 32768));
	pr_info("ACCEL_YOUT %d\n", (int16_t)(i2cStruct.burstRxBuffer[2] << 8 | i2cStruct.burstRxBuffer[3] * 2 / 32768));
	pr_info("ACCEL_ZOUT %d\n", (int16_t)(i2cStruct.burstRxBuffer[4] << 8 | i2cStruct.burstRxBuffer[5] * 2 / 32768));
	pr_info("TEMP_OUT :%d °C\n", (int16_t)(i2cStruct.burstRxBuffer[6] << 8 | i2cStruct.burstRxBuffer[7] / 340 + 36));
	pr_info("GYRO_XOUT %d\n", (int16_t)(i2cStruct.burstRxBuffer[8] << 8 | i2cStruct.burstRxBuffer[9]));
	pr_info("GYRO_YOUT %d\n", (int16_t)(i2cStruct.burstRxBuffer[10] << 8 | i2cStruct.burstRxBuffer[11]));
	pr_info("GYRO_ZOUT %d\n", (int16_t)(i2cStruct.burstRxBuffer[12] << 8 | i2cStruct.burstRxBuffer[13])); */

	pr_info("%s: Módulo I2C configurado correctamente.\n", ID);
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
	//char config[2] = {0};
	uint8_t rxTemp[2];
	uint16_t fifoCount = 0;
	pr_alert("%s: Entrando en OPEN\n", ID);

	pr_alert("%s: Saliendo de OPEN\n", ID);
	return 0;
}
// Entra luego de un error de un close desde el user
static int fop_release(struct inode *inode, struct file *file)
{
	pr_alert("%s: REALEASE file operation\n", ID);
	// libero la pagina que tome para lectura
	//free_page((unsigned long)i2cStruct.rxData);
	return 0;
}

static ssize_t fop_read(struct file *device_descriptor, char __user *user_buffer, size_t read_len, loff_t *my_loff_t)
{
	int result = 0;
	int i = 0;
	int16_t dataTemp = 0;
	//int16_t MPU6050_temperature = 0;
	uint8_t rxTemp[2];
	uint8_t bufferRx[100];
	uint8_t *MPU6050_dataBuffer;
	uint16_t fifoCount;

	pr_info("%s: File Operations: READ\n", ID);

	// Verificación de punteros.
	if (access_ok(VERIFY_WRITE, user_buffer, read_len) == 0)
	{
		pr_alert("%s: Error en el buffer del usuario.\n", ID);
		return -1;
	}
	// Verificación de que el tamaño del buffer sea menor a una página
	if (read_len > PAGE_SIZE)
	{
		pr_alert("%s: Tamaño del buffer de usuario mayor a una página de kernel.\n", ID);
		return -1;
	}
	// Limitación del tamaño del buffer por si el usuario pide de más.
	pr_info("%s: File Operations: READ --> User requiere leer %d bytes\n", ID, read_len);
	pr_info("%s: File Operations: READ --> Chequeo de tamaño del buffer de usuario. No debe ser mayor a %d.\n", ID, sizeof(MPU6050_data));
	if (read_len > sizeof(MPU6050_data))
	{
		read_len = sizeof(MPU6050_data);
	}
	// Asigno memoria dinámicamente (tiene sentido ya que una vez terminada la file operation, devuelvo memoria)
	MPU6050_dataBuffer = kmalloc(read_len * sizeof(uint8_t), GFP_KERNEL); // GFP_KERNEL: Get Free Page from Kernel. El otro argumento, el tamaño.
	pr_info("%s: File Operations: READ --> MPU6050_dataBuffer : tamaño asignado : %d bytes\n", ID, sizeof(MPU6050_dataBuffer));
	/* ------------Lectura de temperatura del MPU6050 ------------------*/
	// El usuario convierte el valor a TEMP ya que en Kernel no se pueden usar floats
	/* rxTemp[0] = 0;
	rxTemp[1] = 0;
	i2c_write_buffer(TEMP_OUT_H, 0x00, READ_REGISTER);
	rxTemp[0] = i2c_read_buffer();
	pr_info("%s: Respuesta del MPU6050 -> TEMP_OUT_H: 0x%x\n", ID, rxTemp[0]);
	i2c_write_buffer(TEMP_OUT_L, 0x00, READ_REGISTER);
	rxTemp[1] = i2c_read_buffer();
	pr_info("%s: Respuesta del MPU6050 -> TEMP_OUT_L: 0x%x\n", ID, rxTemp[1]);
	dataTemp = (rxTemp[0] << 8 | rxTemp[1]);
	pr_info("%s: Respuesta del MPU6050 -> TEMP_OUT FINAL %d °C\n", ID, dataTemp / 340 + 36);  */
	/* ----------------------------------------------------------------- */
	/* -------------Lectura de la FIFO del MPU6050---------------------- */
	// Espero a que se llene la FIFO si no tiene valores.
	// 50 muestras
	i2c_write_buffer(USER_CTRL, 0x44, WRITE_REGISTER); // Enable FIFO and reset it
	do
	{
		// Leo la cantidad de bytes en la FIFO
		i2c_write_buffer(FIFO_COUNTH, 0x00, READ_REGISTER);
		rxTemp[0] = i2c_read_buffer();
		i2c_write_buffer(FIFO_COUNTL, 0x00, READ_REGISTER);
		rxTemp[1] = i2c_read_buffer();
		fifoCount = ((uint16_t)rxTemp[0] << 8) | rxTemp[1];
		//pr_info("FIFO_COUNT DENTRO del while= %d \n\n",fifoCount);
	} while (fifoCount < 56);
	pr_info("FIFO_COUNT despues del while= %d \n\n", fifoCount);
	// Leo primeros 100 bytes de la FIFO
	i2c_write_buffer(FIFO_R_W, 0x00, READ_REGISTER); // Direcciono registro de FIFO
	i2c_read_burst(56);							 //Leo 280 bytes sin STOP
	// Muestro 20 muestras de 14 BYTES DE LA FIFO
	i = 0;
	while (i < 43)
	{
		pr_info("ACCEL_XOUT %d g\n", (int16_t)(i2cStruct.burstRxBuffer[i] << 8 | i2cStruct.burstRxBuffer[i+1]) * 2 / 32768);
		pr_info("ACCEL_YOUT %d g\n", (int16_t)(i2cStruct.burstRxBuffer[i+2] << 8 | i2cStruct.burstRxBuffer[i+3]) * 2 / 32768);
		pr_info("ACCEL_ZOUT %d g\n", (int16_t)(i2cStruct.burstRxBuffer[i+4] << 8 | i2cStruct.burstRxBuffer[i+5]) * 2 / 32768);
		pr_info("TEMP_OUT %d °C\n", (int16_t)(i2cStruct.burstRxBuffer[i+6] << 8 | i2cStruct.burstRxBuffer[i+7]) / 340 + 36);
		pr_info("GYRO_XOUT %d °/s\n", (int16_t)(i2cStruct.burstRxBuffer[i+8] << 8 | i2cStruct.burstRxBuffer[i+9]) * 250 / 32768);
		pr_info("GYRO_YOUT %d °/s\n", (int16_t)(i2cStruct.burstRxBuffer[i+10] << 8 | i2cStruct.burstRxBuffer[i+11]) * 250 / 32768);
		pr_info("GYRO_ZOUT %d °/s\n", (int16_t)(i2cStruct.burstRxBuffer[i+12] << 8 | i2cStruct.burstRxBuffer[i+13]) * 250 / 32768);
		i+= 14;
	}
	i = 0;
	/* pr_info("ACCEL_XOUT %d g\n", (int16_t)(i2cStruct.burstRxBuffer[0] << 8 | i2cStruct.burstRxBuffer[1]) * 2 / 32768);
	pr_info("ACCEL_YOUT %d g\n", (int16_t)(i2cStruct.burstRxBuffer[2] << 8 | i2cStruct.burstRxBuffer[3]) * 2 / 32768);
	pr_info("ACCEL_ZOUT %d g\n", (int16_t)(i2cStruct.burstRxBuffer[4] << 8 | i2cStruct.burstRxBuffer[5]) * 2 / 32768);
	pr_info("TEMP_OUT %d °C\n", (int16_t)(i2cStruct.burstRxBuffer[6] << 8 | i2cStruct.burstRxBuffer[7]) / 340 + 36);
	pr_info("GYRO_XOUT %d °/s\n", (int16_t)(i2cStruct.burstRxBuffer[8] << 8 | i2cStruct.burstRxBuffer[9]) * 250 / 32768);
	pr_info("GYRO_YOUT %d °/s\n", (int16_t)(i2cStruct.burstRxBuffer[10] << 8 | i2cStruct.burstRxBuffer[11]) * 250 / 32768);
	pr_info("GYRO_ZOUT %d °/s\n", (int16_t)(i2cStruct.burstRxBuffer[12] << 8 | i2cStruct.burstRxBuffer[13]) * 250 / 32768);

	pr_info("ACCEL_XOUT %d g\n", (int16_t)(i2cStruct.burstRxBuffer[14] << 8 | i2cStruct.burstRxBuffer[15]) * 2 / 32768);
	pr_info("ACCEL_YOUT %d g\n", (int16_t)(i2cStruct.burstRxBuffer[16] << 8 | i2cStruct.burstRxBuffer[17]) * 2 / 32768);
	pr_info("ACCEL_ZOUT %d g\n", (int16_t)(i2cStruct.burstRxBuffer[18] << 8 | i2cStruct.burstRxBuffer[19]) * 2 / 32768);
	pr_info("TEMP_OUT %d °C\n", (int16_t)(i2cStruct.burstRxBuffer[20] << 8 | i2cStruct.burstRxBuffer[21]) / 340 + 36);
	pr_info("GYRO_XOUT %d °/s\n", (int16_t)(i2cStruct.burstRxBuffer[22] << 8 | i2cStruct.burstRxBuffer[23]) * 250 / 32768);
	pr_info("GYRO_YOUT %d °/s\n", (int16_t)(i2cStruct.burstRxBuffer[24] << 8 | i2cStruct.burstRxBuffer[25]) * 250 / 32768);
	pr_info("GYRO_ZOUT %d °/s\n", (int16_t)(i2cStruct.burstRxBuffer[26] << 8 | i2cStruct.burstRxBuffer[27]) * 250 / 32768); */

	/* ----------------------------------------------------------------- */
	MPU6050_data.accel_xout = 1;
	MPU6050_data.accel_yout = 2;
	MPU6050_data.accel_zout = 3;
	MPU6050_data.gyro_xout = 4;
	MPU6050_data.gyro_yout = 5;
	MPU6050_data.gyro_zout = 6;
	MPU6050_data.temp_out = dataTemp;
	//MPU6050_data.temp_out = i2cStruct.burstRxBuffer[6] << 8 | i2cStruct.burstRxBuffer[7];
	if ((result = copy_to_user(user_buffer, &MPU6050_data, read_len)) > 0)
	{ //en copia correcta devuelve 0
		pr_info("%s: Falla en copia de buffer de kernel a buffer de usuario\n", ID);
		return -1;
	}

	kfree(MPU6050_dataBuffer);

	return 0;
}

static long fop_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
{

	return 0;
}

static ssize_t fop_write(struct file *device_descriptor, const char __user *user_buffer, size_t write_len, loff_t *my_loff_t)
{
	return EFAULT;
}

/**
 * \fn int leer_data_sensor(void)
 * \param regMPU6050 Dirección del registro a leer / escribir
 * \param regMPU6050_value Valor del registro a escribir. 0x00 para lectura.
 * \param operation Operación a realizar . WRITE_REGISTER o READ_REGISTER
 * \brief Función que escribe el buffer del I2C en modo "Master transmitter" por IRQ
 * \return Devuelve 0 si fue un éxito, -1 si hubo un error.
 **/
void i2c_write_buffer(uint8_t regMPU6050, uint8_t regMPU6050_value, int operation)
{
	uint32_t i = 0;
	uint32_t auxRegister = 0;
	uint32_t statusEvent = 0;
	// Chequeo si la línea esta BUSY
	auxRegister = ioread32(i2c2_baseAddr + I2C_IRQSTATUS_RAW);
	while ((auxRegister >> 12) & 1)
	{
		msleep(100);
		printk(KERN_ERR "|writebyte| [ERROR] td3_i2c : Device busy\n");

		i++;

		if (i == 4)
		{
			printk(KERN_ERR "|writebyte| [ERROR] td3_i2c : busy (%s %d)\n", __FUNCTION__, __LINE__);
			return;
		}
	}
	// Cargo el registro a TX en variable aux. para cuando entre a I2C_IRQSTATUS_XRDY
	i2cStruct.dataCount = 0;
	if (operation == READ_REGISTER)
	{
		i2cStruct.operation = READ_REGISTER;
		i2cStruct.txData[0] = regMPU6050;
		// Seteo la cantidad de datos a transmitir
		iowrite32(0x01, i2c2_baseAddr + I2C_CNT);
	}
	if (operation == WRITE_REGISTER)
	{
		i2cStruct.operation = WRITE_REGISTER;
		i2cStruct.txData[0] = regMPU6050;
		i2cStruct.txData[1] = regMPU6050_value;
		// Seteo la cantidad de datos a transmitir
		iowrite32(0x02, i2c2_baseAddr + I2C_CNT);
	}
	// Seteo el registro I2C_CON para "Master Transmitter y STOP"
	auxRegister = ioread32(i2c2_baseAddr + I2C_CON);
	auxRegister |= 0x600;
	iowrite32(auxRegister, i2c2_baseAddr + I2C_CON);
	// Habilito la IRQ por TX
	iowrite32(I2C_IRQSTATUS_XRDY, i2c2_baseAddr + I2C_IRQENABLE_SET);
	// Genero condición de START
	auxRegister = ioread32(i2c2_baseAddr + I2C_CON);
	auxRegister |= I2C_CON_START;
	iowrite32(auxRegister, i2c2_baseAddr + I2C_CON);
	// Pongo el proceso UNINTERRUPTABLE (por estar escribiendo registros) a esperar a que la IRQ termine de transmitir. Al finalizar, desde la IRQ se levanta.
	//wait_event(queueTASK_UNINTERRUPTIBLE, wakeupCondition > 0);
	if ((statusEvent = wait_event_interruptible(queueTASK_UNINTERRUPTIBLE, wakeupCondition > 0)) < 0)
	{
		wakeupCondition = 0;
		printk(KERN_ERR "i2c_write_buffer ERROR :  read (%s %d)\n", __FUNCTION__, __LINE__);
		return;
	}
	wakeupCondition = 0;
	// Genero condición de STOP
	auxRegister = ioread32(i2c2_baseAddr + I2C_CON);
	auxRegister &= 0xFFFFFFFE;
	auxRegister |= I2C_CON_STOP;
	iowrite32(auxRegister, i2c2_baseAddr + I2C_CON);
	// Tiempo para que baje la línea (STOP).
	msleep(1);
	pr_info("i2c_write_buffer: Byte TX OK. \n");
}

uint8_t i2c_read_buffer(void)
{
	uint32_t i = 0;
	uint32_t auxRegister = 0;
	uint32_t statusEvent = 0;
	uint8_t byteRx;

	//pr_info("i2c_read_buffer \n");

	// Chequeo si la línea esta BUSY
	auxRegister = ioread32(i2c2_baseAddr + I2C_IRQSTATUS_RAW);
	while ((auxRegister >> 12) & 1)
	{
		msleep(100);
		printk(KERN_ERR "|readbyte| [ERROR] td3_i2c : Device busy\n");
		i++;
		if (i >= 4)
		{
			printk(KERN_ERR "|readbyte| [ERROR] td3_i2c : busy (%s %d)\n", __FUNCTION__, __LINE__);
			return -1;
		}
	}
	i2cStruct.dataCount = 0;
	i2cStruct.dataToRead = BYTES_TO_TX;
	// Pido memoria para el buffer de RX según cantidad de bytes
	//i2cStruct.rxData = kmalloc(BYTES_TO_TX * sizeof(uint8_t), GFP_KERNEL); // GFP_KERNEL: Get Free Page from Kernel. El otro argumento, el tamaño.
	// Asigo cantidad de datos a leer
	//i2cStruct.dataToRead = BYTES_TO_TX;
	// Seteo la cantidad de datos a recibir
	iowrite32(BYTES_TO_TX, i2c2_baseAddr + I2C_CNT);
	// Seteo el registro I2C_CON para "Master Receiver"
	auxRegister = ioread32(i2c2_baseAddr + I2C_CON);
	auxRegister = 0x8400;
	iowrite32(auxRegister, i2c2_baseAddr + I2C_CON);
	// Habilito la IRQ por RX
	iowrite32(I2C_IRQSTATUS_RRDY, i2c2_baseAddr + I2C_IRQENABLE_SET);
	// Genero condición de START
	auxRegister = ioread32(i2c2_baseAddr + I2C_CON);
	auxRegister &= 0xFFFFFFFC;
	auxRegister |= I2C_CON_START;
	iowrite32(auxRegister, i2c2_baseAddr + I2C_CON);
	// Espero a que la recepción finalice poniendo en espera el proceso. Puede ser INTERRUPTABLE.
	if ((statusEvent = wait_event_interruptible(queue, wakeupCondition > 0)) < 0)
	{
		wakeupCondition = 0;
		printk(KERN_ERR "|writebyte| [ERROR] td3_i2c : read (%s %d)\n", __FUNCTION__, __LINE__);
		return statusEvent;
	}
	wakeupCondition = 0;
	// Genero condición de STOP
	auxRegister = ioread32(i2c2_baseAddr + I2C_CON);
	auxRegister &= 0xFFFFFFFE;
	auxRegister |= I2C_CON_STOP;
	iowrite32(auxRegister, i2c2_baseAddr + I2C_CON);
	// Leo el buffer que se lleno en la IRQ.
	byteRx = i2cStruct.rxData;
	msleep(1);
	//pr_info("%s: i2c_read_buffer : Byte recibido: 0x%x \n", ID, byteRx);
	return byteRx;
}

void i2c_read_burst(int bytesToRead)
{
	uint32_t i = 0;
	uint32_t auxRegister = 0;
	uint32_t statusEvent = 0;
	uint8_t byteRx;

	pr_info("i2c_read_burst \n");

	// Chequeo si la línea esta BUSY
	auxRegister = ioread32(i2c2_baseAddr + I2C_IRQSTATUS_RAW);
	while ((auxRegister >> 12) & 1)
	{
		msleep(100);
		printk(KERN_ERR "|readbyte| [ERROR] td3_i2c : Device busy\n");
		i++;
		if (i >= 4)
		{
			printk(KERN_ERR "|readbyte| [ERROR] td3_i2c : busy (%s %d)\n", __FUNCTION__, __LINE__);
			return -1;
		}
	}
	i2cStruct.dataCount = 0;
	i2cStruct.dataToRead = bytesToRead;
	// Seteo la cantidad de datos a recibir
	iowrite32(bytesToRead, i2c2_baseAddr + I2C_CNT);
	// Seteo el registro I2C_CON para "Master Receiver"
	auxRegister = ioread32(i2c2_baseAddr + I2C_CON);
	auxRegister = 0x8400;
	iowrite32(auxRegister, i2c2_baseAddr + I2C_CON);
	// Habilito la IRQ por RX
	iowrite32(I2C_IRQSTATUS_RRDY, i2c2_baseAddr + I2C_IRQENABLE_SET);
	// Genero condición de START
	auxRegister = ioread32(i2c2_baseAddr + I2C_CON);
	auxRegister &= 0xFFFFFFFC;
	auxRegister |= I2C_CON_START;
	iowrite32(auxRegister, i2c2_baseAddr + I2C_CON);
	pr_info("i2c_read_burst: Esperando fin de RX... \n");
	// Espero a que la recepción finalice poniendo en espera el proceso. Puede ser INTERRUPTABLE.
	if ((statusEvent = wait_event_interruptible(queue, wakeupCondition > 0)) < 0)
	{
		wakeupCondition = 0;
		printk(KERN_ERR "|writebyte| [ERROR] td3_i2c : read (%s %d)\n", __FUNCTION__, __LINE__);
		return statusEvent;
	}
	wakeupCondition = 0;
	// Genero condición de STOP
	auxRegister = ioread32(i2c2_baseAddr + I2C_CON);
	auxRegister &= 0xFFFFFFFE;
	auxRegister |= I2C_CON_STOP;
	iowrite32(auxRegister, i2c2_baseAddr + I2C_CON);
	return;
}

// Handler de IRQ del I2C2
/* 
• Receive interrupt/status (RRDY) is generated when there is received data ready to be read by the CPU
from the I2C_DATA register (see the FIFO Management subsection for a complete description of
required conditions for interrupt generation). The CPU can alternatively poll this bit to read the received
data from the I2C_DATA register.

• Transmit interrupt/status (XRDY) is generated when the CPU needs to put more data in the I2C_DATA
register after the transmitted data has been shifted out on the SDA pin (see the FIFO Management
subsection for a complete description of required conditions for interrupt generation). The CPU can
alternatively poll this bit to write the next transmitted data into the I2C_DATA register.
*/
irqreturn_t i2c_irq_handler(int irq, void *devid, struct pt_regs *regs)
{
	uint32_t irq_status;
	uint32_t auxRegister;
	// Leo el estado de la IRQ
	irq_status = ioread32(i2c2_baseAddr + I2C_IRQSTATUS);
	// I2C RX
	if (irq_status & I2C_IRQSTATUS_RRDY)
	{
		if (i2cStruct.dataToRead > 1)
		{
			i2cStruct.burstRxBuffer[i2cStruct.dataCount] = ioread8(i2c2_baseAddr + I2C_DATA);
		}
		else
		{
			// Leo el dato que llego por SDA (I2C_DATA)
			i2cStruct.rxData = ioread8(i2c2_baseAddr + I2C_DATA);
		}

		// Sumo una RX. Si es igual al total de RX, termina.
		i2cStruct.dataCount++;

		if (i2cStruct.dataCount == i2cStruct.dataToRead)
		{
			i2cStruct.dataCount = 0;
			i2cStruct.dataToRead = 0;
			// Deshabilito IRQ por RX
			auxRegister = ioread32(i2c2_baseAddr + I2C_IRQENABLE_CLR);
			auxRegister |= I2C_IRQSTATUS_RRDY;
			iowrite32(auxRegister, i2c2_baseAddr + I2C_IRQENABLE_CLR);
			// Levanto el proceso en espera
			wakeupCondition = 1;
			wake_up_interruptible(&queue);
		}
		// Limpio flags de la IRQ
		auxRegister = ioread32(i2c2_baseAddr + I2C_IRQSTATUS);
		auxRegister |= 0x27;
		iowrite32(auxRegister, i2c2_baseAddr + I2C_IRQSTATUS);
	}
	// I2C_TX
	if (irq_status & I2C_IRQSTATUS_XRDY)
	{
		if (i2cStruct.operation == READ_REGISTER)
		{
			pr_info("+ IRQ I2C: Direccionando registro 0x%x (MPU6050) a leer... \n", i2cStruct.txData[0]);
			// Escribo el byte (registro) en I2C_DATA para transmitir.
			iowrite8(i2cStruct.txData[0], i2c2_baseAddr + I2C_DATA);
			// Levanto el proceso que quedó en espera.
			wakeupCondition = 1;
			wake_up(&queue);
		}
		if (i2cStruct.operation == WRITE_REGISTER)
		{
			if (i2cStruct.dataCount > 0)
			{
				pr_info("+ IRQ I2C: Valor registro: 0x%x (MPU6050)\n", i2cStruct.txData[1]);
				iowrite8(i2cStruct.txData[1], i2c2_baseAddr + I2C_DATA);
				i2cStruct.dataCount = 0;
				// Levanto el proceso que quedó en espera.
				// Deshabilito IRQ por TX
				auxRegister = ioread32(i2c2_baseAddr + I2C_IRQENABLE_CLR);
				auxRegister |= I2C_IRQSTATUS_XRDY;
				iowrite32(auxRegister, i2c2_baseAddr + I2C_IRQENABLE_CLR);
				wakeupCondition = 1;
				wake_up(&queueTASK_UNINTERRUPTIBLE);
			}
			else
			{
				pr_info(" + IRQ I2C: Direccionando registro 0x%x (MPU6050) a escribir.\n", i2cStruct.txData[0]);
				iowrite8(i2cStruct.txData[0], i2c2_baseAddr + I2C_DATA);
				i2cStruct.dataCount++;
			}
		}
		// Limpio flags de la IRQ
		auxRegister = ioread32(i2c2_baseAddr + I2C_IRQSTATUS);
		auxRegister |= 0x36;
		iowrite32(auxRegister, i2c2_baseAddr + I2C_IRQSTATUS);
	}

	if (irq_status & I2C_IRQSTATUS_ARDY)
	{
		pr_info("IRQ I2C: --------------ACK ----------------\n");
	}

	// Limpio todos los flags de la IRQ antes de retornar.
	irq_status = ioread32(i2c2_baseAddr + I2C_IRQSTATUS);
	//irq_status |= 0x3E;
	irq_status |= 0x3F;
	iowrite32(irq_status, i2c2_baseAddr + I2C_IRQSTATUS);
	return (irqreturn_t)IRQ_HANDLED;
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
