/**
 * \fn void MPU6050_init(void)
 * \param void No recibe nada
 * \brief Función que inicializa y configura el sensor MPU6050 
 * \return No devuelve nada
 **/
void MPU6050_init(void)
{
    uint8_t rx = 0;
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
    i2c_write_buffer(SMPLRT_DIV, 0x03, WRITE_REGISTER); // Use a 200 Hz sample rate (5ms)
    // Set gyroscope full scale range
    // Range selects FS_SEL and AFS_SEL are 0 - 3, so 2-bit values are left-shifted into positions 4:3
    i2c_write_buffer(GYRO_CONFIG, 0x00, READ_REGISTER); // Clear self-test bits [7:5]
    rx = i2c_read_buffer();
    i2c_write_buffer(GYRO_CONFIG, rx & ~0xE0, WRITE_REGISTER);       // Clear self-test bits [7:5]
    i2c_write_buffer(GYRO_CONFIG, rx & ~0x18, WRITE_REGISTER);       // Clear AFS bits [4:3]
    i2c_write_buffer(GYRO_CONFIG, rx | Gscale << 3, WRITE_REGISTER); // Set full scale range for the gyro
    // Set accelerometer configuration
    i2c_write_buffer(ACCEL_CONFIG, 0x00, READ_REGISTER); // Clear self-test bits [7:5]
    rx = i2c_read_buffer();
    i2c_write_buffer(ACCEL_CONFIG, rx & ~0xE0, WRITE_REGISTER);       // Clear self-test bits [7:5]
    i2c_write_buffer(ACCEL_CONFIG, rx & ~0x18, WRITE_REGISTER);       // Clear AFS bits [4:3]
    i2c_write_buffer(ACCEL_CONFIG, rx | Ascale << 3, WRITE_REGISTER); // Set full scale range for the accelerometer
    // Configure Interrupts and Bypass Enable
    // Set interrupt pin active high, push-pull, and clear   read of INT_STATUS, enable I2C_BYPASS_EN so additional chips
    // can join the I2C bus and all can be controlled by the Arduino as master
    i2c_write_buffer(INT_PIN_CFG, 0x02, WRITE_REGISTER);
    i2c_write_buffer(INT_ENABLE, 0x01, WRITE_REGISTER); // Enable data ready (bit 0) interrupt
    // Configure FIFO to capture accelerometer and gyro data for bias calculation
    i2c_write_buffer(USER_CTRL, 0x44, WRITE_REGISTER); // Enable FIFO and reset it
    i2c_write_buffer(FIFO_EN, 0xF8, WRITE_REGISTER);   // Enable gyro, accelerometer and temperature sensors for FIFO  (max size 1024 bytes in MPU-6050)
    msleep(100);                                       // Wait for some samples
}
/**
 * \fn uint16_t MPU6050_read_fifo_count(void)
 * \param void No recibe nada
 * \brief Función que lee la cantidad de datos (bytes) válidos en la FIFO del MPU6050
 * \return Devuelve la cantidad de bytes en la FIFO.
 **/
uint16_t MPU6050_read_fifo_count(void)
{
    uint16_t fifoCount;
    uint8_t rxTemp[2];
    // Leo la cantidad de bytes en la FIFO
    i2c_write_buffer(FIFO_COUNTH, 0x00, READ_REGISTER);
    rxTemp[0] = i2c_read_buffer();
    i2c_write_buffer(FIFO_COUNTL, 0x00, READ_REGISTER);
    rxTemp[1] = i2c_read_buffer();
    fifoCount = ((uint16_t)rxTemp[0] << 8) | rxTemp[1];
    return fifoCount;

}