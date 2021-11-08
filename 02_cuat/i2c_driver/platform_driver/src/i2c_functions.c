void I2C_init()
{
	// ----------------------------------------------
	// Configuración de registros del I2C - pag. 4559
	// ----------------------------------------------
	// 1 - Prescaler
	iowrite32(0x0000, i2c2_baseAddr + I2C_CON); // Deshabilito I2C2
	iowrite32(0x03, i2c2_baseAddr + I2C_PSC);	// 12Mhz preescaler (48Mhz / 4)
	// 2 - Setear SCL. MAX 400khz (SCLL y SCLH). 
    // Velocidad calculada = 342Khz
	iowrite32(0x08, i2c2_baseAddr + I2C_SCLL); // SCL_LOW = (SCLL + 7)* 1 / 12Mhz =  1,25uS   (MPU6050 -> MAX 2,5 us - MIN 0,6us)
	iowrite32(0x14, i2c2_baseAddr + I2C_SCLH); // SCL_HIGH = (SCLH + 7)* 1 / 12Mhz = 1,666666us (MPU6050 -> MAX 2,5 us - MIN 1,3us)
	//iowrite32(0x35, i2c2_baseAddr + I2C_SCLL); // SCL_LOW = 5uS
	//iowrite32(0x37, i2c2_baseAddr + I2C_SCLH); // SCL_HIGH = 5uS
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
			i2cStruct.MPU6050_dataBuffer[i2cStruct.dataCount] = ioread8(i2c2_baseAddr + I2C_DATA);
            //pr_info("%s: I2C_IRQ --> MPU6050_dataBuffer[i2cStruct.dataCount] = 0x%x\n", ID, i2cStruct.MPU6050_dataBuffer[i2cStruct.dataCount]);
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