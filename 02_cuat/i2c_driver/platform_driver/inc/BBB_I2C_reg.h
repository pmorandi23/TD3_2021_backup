// Clock Module Peripheral (page 179) length = 1K -> 0x400
#define CM_PER 0x44E00000     // Start address
#define CM_PER_LEN 0x00000400 // 1K
// I2C2 clocks manager (page 1270)
#define CM_PER_I2C2_CLKCTRL 0x00000044 // This register manages the I2C2 clocks.
#define CM_PER_I2C2_CLKCTRL_MASK 0x00030003
#define CM_PER_I2C2_CLKCTRL_ENABLE 0x00000002 // 0x2 = ENABLE : Module is explicitly enabled.
// Config de Control Module (page180)
#define CTRL_MODULE_BASE 0x44E10000       // Start address
#define CTRL_MODULE_LEN 0x00002000        // 8K la datasheet dice 128k pero el fin es en 0x44E11FFF
#define CTRL_MODULE_UART1_CTSN 0x00000978 //pin 20 = sda  (page1461)
#define CTRL_MODULE_UART1_RTSN 0x0000097C //pin 19 = scl  (page1461)
#define CTRL_MODULE_UART1_MASK 0x0000007F
//Habilita capacidad de pines (page 1515)
// Reserved | Fast | Reciever Enable | Pullup Selected | Pullup/pulldown enable | I2C2_SCL
#define CTRL_MODULE_I2C_PINMODE 0x00000023 // 0010 0011b
// Config de Control Module (page183)
#define I2C2 0x4819C000
#define I2C2_LEN 0x00001000 // 4k
// Registros especificos de I2C
#define I2C_IRQSTATUS 0x00000028 // Page 4612
#define I2C_IRQSTATUS_CLR_ALL 0x00006FFF
#define I2C_IRQSTATUS_RRDY 0x00000008 // Page 4613
#define I2C_IRQSTATUS_XRDY 0x00000010 // Page 4613
#define I2C_IRQSTATUS_ARDY 0x00000004 // Page 4613
#define I2C_IRQSTATUS_RAW 0x00000024  // Page 4606
#define I2C_IRQENABLE_SET 0x0000002C  // Page 4614
#define I2C_IRQENABLE_SET_MASK 0x00006FFF
#define I2C_IRQENABLE_SET_RX 0x00000008
#define I2C_IRQENABLE_SET_TX 0x00000010
#define I2C_IRQENABLE_CLR 0x00000030 // Page 4616
#define I2C_IRQENABLE_CLR_MASK 0x00006FFF
#define I2C_IRQENABLE_CLR_ALL 0x00006FFF
#define I2C_IRQENABLE_CLR_ACK 0x00000004
#define I2C_IRQENABLE_CLR_RX 0x00000008
#define I2C_IRQENABLE_CLR_TX 0x00000010
#define I2C_CNT 0x00000098 // Page 4632
#define I2C_CNT_MASK 0x000000FF
#define I2C_DATA 0x0000009C // Page 4633
// inicializacion el I2Ci
#define I2C_CON 0x000000A4 // Page 4634
#define I2C_CON_MASK 0x0000BFF3
#define I2C_CON_DISABLE 0x00000000
#define I2C_CON_EN_MST_TX 0x00008600
#define I2C_CON_EN_MST_RX 0x00008400
#define I2C_CON_START 0x00000001 // Page 4636
#define I2C_CON_STOP 0x00000002  // Page 4636
#define I2C_OA 0x000000A8        // Page 4637
#define I2C_OA_MASK 0x000000FF
#define I2C_OA_VALUE 0x00000036 // dir random porque no uso multimaster
#define I2C_SA 0x000000AC       // Page 4638
#define I2C_SA_MASK 0x000001FF
#define I2C_SA_ADDRESS BMP280_ADDRESS
#define I2C_PSC 0x000000B0 // Page 4639, el SystemClock es 48MHz CREO
#define I2C_PSC_MASK 0x000000FF
#define I2C_PSC_VALUE 0x00000003 // divided by 3, 48MHz/4 = 12MHz (page4589)
#define I2C_SCLL 0x000000B4      // Page 4640
#define I2C_SCLL_MASK 0x000000FF
#define I2C_SCLL_400K 0x00000035 // tLOW = 1,25 uS  = (53+7)*(1/48MHz)
#define I2C_SCLL_100K 0x000000E9 // tLOW = 5 uS  = (233+7)*(1/48MHz)
#define I2C_SCLH 0x000000B8      // Page 4641
#define I2C_SCLH_MASK 0x000000FF
#define I2C_SCLL_VALUE 0xB4            // Page 4640
#define I2C_SCLH_VALUE 0xB8            // Page 4641
#define I2C_SCLH_400K 0x00000037 // tHIGH = 1,25 uS = (55+5)*(1/48MHz)
#define I2C_SCLH_100K 0x000000EB // tHIGH = 5 uS = (235+5)*(1/48MHz)
#define I2C_SYSC 0x00000010