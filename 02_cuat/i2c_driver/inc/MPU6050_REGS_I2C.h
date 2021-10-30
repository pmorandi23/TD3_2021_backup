/* Mapa de Registros MPU6053 */
/*
        Register Name       Addr            Serial    |  Bit7  |  Bit6  |  Bit5  |  Bit4  |  Bit3  |  Bit2  |  Bit1  |  Bit0  |
                            (Hex)           I/F
*/
#define SELF_TEST_X         0x0D            // R/W    |     XA_TEST[4-2]         |              XG_TEST[4-0]                  |
#define SELF_TEST_Y         0x0E            // R/W    |     YA_TEST[4-2]         |              YG_TEST[4-0]                  |
#define SELF_TEST_Z         0x0F            // R/W    |     ZA_TEST[4-2]         |              ZG_TEST[4-0]                  |
#define SELF_TEST_A         0x10            // R/W    |     RESERVED    |   XA_TEST[1-0]  |  YA_TEST[1-0]  |  ZA_TEST[1-0]    |
#define SMPLRT_DIV          0x19            // R/W    |                         SMPLRT_DIV[7:0]                               |
#define CONFIG              0x1A            // R/W    |    -   |   -    | EXT_SYNC_SET[2:0]        |     DLPF_CFG[2:0]        |
#define GYRO_CONFIG         0x1B            // R/W    |    -   |   -    |   -    |   FS_SEL [1:0]  |   -    |   -    |   -    |
#define ACCEL_CONFIG        0x1C            // R/W    | XA_ST  | YA_ST  |  ZA_ST |   AFS_SEL[1:0]  |   -    |   -    |   -    |

#define FIFO_EN             0x23            // R/W    | TEMP   |   XG   |   YG   |   ZG   | ACCEL  |  SLV2  |  SLV1  |  SLV0  |
                                            //        |_FIFO_EN|_FIFO_EN|_FIFO_EN|_FIFO_EN|_FIFO_EN|_FIFO_EN|_FIFO_EN|_FIFO_EN|

#define I2C_MST_CTRL        0x24            // R/W    |  MULT  |  WAIT  | SLV_3  | I2C_MST|        I2C_MST_CLK[3:0]           |
                                            //        | _MST_EN| _FOR_ES|_FIFO_EN| _P_NSR |

#define I2C_SLV0_ADDR       0x25            // R/W    |I2C_SLV0|                     I2C_SLV0_ADDR[6:0]                       |
                                            //        |  _RW   |

#define I2C_SLV0_REG        0x26            // R/W    |                           I2C_SLV0_REG[7:0]                           |

#define I2C_SLV0_CTRL       0x27            // R/W    |I2C_SLV0|I2C_SLV0|I2C_SLV0|I2C_SLV0|        I2C_SLV0_LEN[3:0]          |
                                            //        |  _EN   |_BYTE_SW|_REG_DIS|  _GRP  |

#define I2C_SLV1_ADDR       0x28            // R/W    |I2C_SLV1|                   I2C_SLV1_ADDR[6:0]                         |
                                            // R/W    |  _RW   |

#define I2C_SLV1_REG        0x29            // R/W    |                           I2C_SLV1_REG[7:0]                           |

#define I2C_SLV1_CTRL       0x2A            // R/W    |I2C_SLV1|I2C_SLV1|I2C_SLV1|I2C_SLV1|        I2C_SLV1_LEN[3:0]          |
                                            //        |  _EN   |_BYTE_SW|_REG_DIS|  _GRP  |

#define I2C_SLV2_ADDR       0x2B            // R/W    |I2C_SLV2|                   I2C_SLV2_ADDR[6:0]                         |
                                            //        |  _RW   |

#define I2C_SLV2_REG        0x2C            // R/W    |                           I2C_SLV2_REG[7:0]                           |

#define I2C_SLV2_CTRL       0x2D            // R/W    |I2C_SLV2|I2C_SLV2|I2C_SLV2|I2C_SLV2|        I2C_SLV2_LEN[3:0]          |
                                            //        |  _EN   |_BYTE_SW|_REG_DIS|  _GRP  |

#define I2C_SLV3_ADDR       0x2E            // R/W    |I2C_SLV3|                   I2C_SLV3_ADDR[6:0]                         |
                                            //        |  _RW   |


#define I2C_SLV3_REG        0x2F            // R/W    |                           I2C_SLV3_REG[7:0]                           |

#define I2C_SLV3_CTRL       0x30            // R/W    |I2C_SLV3|I2C_SLV3|I2C_SLV3|I2C_SLV3|        I2C_SLV3_LEN[3:0]          |
                                            //        |  _EN   |_BYTE_SW|_REG_DIS|  _GRP  |


#define I2C_SLV4_ADDR       0x31            // R/W    |I2C_SLV4|                   I2C_SLV3_ADDR[6:0]                         |
                                            //        |  _RW   |

#define I2C_SLV4_REG        0x32            // R/W    |                           I2C_SLV4_REG[7:0]                           |

#define I2C_SLV4_DO         0x33            // R/W    |                           2C_SLV4_DO[7:0]                             |

#define I2C_SLV4_CTRL       0x34            // R/W    |I2C_SLV4|I2C_SLV4|I2C_SLV4|             I2C_MST_DLY[4:0]              |
                                            //        |  _EN   |_INT_EN |_REG_DIS|

#define I2C_SLV4_DI         0x35            // R      |                           I2C_SLV4_DI[7:0]                            |

#define I2C_MST_STATUS      0x36            // R      |  PASS_ |I2C_SLV4|I2C_LOST|I2C_SLV4|I2C_SLV3|I2C_SLV2|I2C_SLV1|I2C_SLV0|
                                            //        |THROUGH | _DONE  |  _ARB  | _NACK  | _NACK  | _NACK  | _NACK  | _NACK  |

#define INT_PIN_CFG         0x37            // R/W    |INT_LEVEL|INT_OPEN| LATCH | INT_RD | FSYNC_ |  FSYNC |  I2C   |   -    |
                                            //        |    -   |   -    | _INT_EN| _CLEAR |INT_LEVEL|_INT_EN|_BYPASS_EN|   -    |

#define INT_ENABLE          0x38            // R/W    |    -   |   -    |   -    |  FIFO  | I2C_MST |   -    |   -    | DATA   |
                                            //        |    -   |   -    |   -    |_OFLOW_EN| _INT_EN|   -    |   -    | _RDY_EN|

#define INT_STATUS          0x3A            // R      |    -   |   -    |   -    |  FIFO    | I2C_MST |   -    |   -    | DATA   |
                                            //        |    -   |   -    |   -    |_OFLOW_INT| _INT    |   -    |   -    |_RDY_INT|

#define ACCEL_XOUT_H        0x3B            // R      |                             ACCEL_XOUT[15:8]                          |
#define ACCEL_XOUT_L        0x3C            // R      |                             ACCEL_XOUT[7:0]                           |
#define ACCEL_YOUT_H        0x3D            // R      |                             ACCEL_YOUT[15:8]                          |
#define ACCEL_YOUT_L        0x3E            // R      |                             ACCEL_YOUT[7:0]                           |
#define ACCEL_ZOUT_H        0x3F            // R      |                             ACCEL_ZOUT[15:8]                          |
#define ACCEL_ZOUT_L        0x40            // R      |                             ACCEL_ZOUT[7:0]                           |
#define TEMP_OUT_H          0x41            // R      |                             TEMP_OUT[15:8]                            |
#define TEMP_OUT_L          0x42            // R      |                             TEMP_OUT[7:0]                             |
#define GYRO_XOUT_H         0x43            // R      |                             GYRO_XOUT[15:8]                           |
#define GYRO_XOUT_L         0x44            // R      |                             GYRO_XOUT[7:0]                            |
#define GYRO_YOUT_H         0x45            // R      |                             GYRO_YOUT[15:8]                           |
#define GYRO_YOUT_L         0x46            // R      |                             GYRO_YOUT[7:0]                            |
#define GYRO_ZOUT_H         0x47            // R      |                             GYRO_ZOUT[15:8]                           |
#define GYRO_ZOUT_L         0x48            // R      |                             GYRO_ZOUT[7:0]                            |

#define EXT_SENS_DATA_00    0x49            // R      |                          EXT_SENS_DATA_00[7:0]                        |
#define EXT_SENS_DATA_01    0x4A            // R      |                          EXT_SENS_DATA_01[7:0]                        |
#define EXT_SENS_DATA_02    0x4B            // R      |                          EXT_SENS_DATA_02[7:0]                        |
#define EXT_SENS_DATA_03    0x4C            // R      |                          EXT_SENS_DATA_03[7:0]                        |
#define EXT_SENS_DATA_04    0x4D            // R      |                          EXT_SENS_DATA_04[7:0]                        |
#define EXT_SENS_DATA_05    0x4E            // R      |                          EXT_SENS_DATA_05[7:0]                        |
#define EXT_SENS_DATA_06    0x4F            // R      |                          EXT_SENS_DATA_06[7:0]                        |
#define EXT_SENS_DATA_07    0x50            // R      |                          EXT_SENS_DATA_07[7:0]                        |
#define EXT_SENS_DATA_08    0x51            // R      |                          EXT_SENS_DATA_08[7:0]                        |
#define EXT_SENS_DATA_09    0x52            // R      |                          EXT_SENS_DATA_09[7:0]                        |
#define EXT_SENS_DATA_10    0x53            // R      |                          EXT_SENS_DATA_10[7:0]                        |
#define EXT_SENS_DATA_11    0x54            // R      |                          EXT_SENS_DATA_11[7:0]                        |
#define EXT_SENS_DATA_12    0x55            // R      |                          EXT_SENS_DATA_12[7:0]                        |
#define EXT_SENS_DATA_13    0x56            // R      |                          EXT_SENS_DATA_13[7:0]                        |
#define EXT_SENS_DATA_14    0x57            // R      |                          EXT_SENS_DATA_14[7:0]                        |
#define EXT_SENS_DATA_15    0x58            // R      |                          EXT_SENS_DATA_15[7:0]                        |
#define EXT_SENS_DATA_16    0x59            // R      |                          EXT_SENS_DATA_16[7:0]                        |
#define EXT_SENS_DATA_17    0x5A            // R      |                          EXT_SENS_DATA_17[7:0]                        |
#define EXT_SENS_DATA_18    0x5B            // R      |                          EXT_SENS_DATA_18[7:0]                        |
#define EXT_SENS_DATA_19    0x5C            // R      |                          EXT_SENS_DATA_19[7:0]                        |
#define EXT_SENS_DATA_20    0x5D            // R      |                          EXT_SENS_DATA_20[7:0]                        |
#define EXT_SENS_DATA_21    0x5E            // R      |                          EXT_SENS_DATA_21[7:0]                        |
#define EXT_SENS_DATA_22    0x5F            // R      |                          EXT_SENS_DATA_22[7:0]                        |
#define EXT_SENS_DATA_23    0x60            // R      |                          EXT_SENS_DATA_23[7:0]                        |

#define I2C_SLV0_DO         0x63            // R/W    |                             2C_SLV0_DO[7:0]                           |
#define I2C_SLV1_DO         0x64            // R/W    |                             2C_SLV1_DO[7:0]                           |
#define I2C_SLV2_DO         0x65            // R/W    |                             2C_SLV2_DO[7:0]                           |
#define I2C_SLV3_DO         0x66            // R/W    |                             2C_SLV3_DO[7:0]                           |

#define I2C_MST_DELAY_CTRL  0x67            // R/W    |DELAY_ES|   -    |   -    |I2C_SLV4|I2C_SLV3|I2C_SLV2|I2C_SLV1|I2C_SLV0|
                                            //        |_SHADOW |        |        | _DLY_EN| _DLY_EN| _DLY_EN| _DLY_EN| _DLY_EN|

#define SIGNAL_PATH_RESET   0x68            // R/W    |    -   |   -    |   -    |   -    |   -    |  GYRO  |  ACCEL | TEMP   |
                                            //                          |        |        |        | _RESET | _RESET | _RESET |

#define USER_CTRL           0x6A            // R/W    |    -   | FIFO_EN| 2C_MST |  2C_IF |   -    |  FIFO  | I2C_MST|SIG_COND|
                                            //                          |   _EN  |  _DIS  |        | _RESET | _RESET | _RESET | 

#define PWR_MGMT_1          0x6B            // R/W    | DEVICE |  SLEEP |  CYCLE |   -    |TEMP_DIS|        CLKSEL[2:0]       |
                                            //        | _RESET |

#define PWR_MGMT_2          0x6C            // R/W    |LP_WAKE_CTRL[1:0]| STBY_XA| STBY_YA| STBY_ZA| STBY_XG| STBY_YG| STBY_ZG|
#define FIFO_COUNTH         0x72            // R/W    |                             FIFO_COUNT[15:8]                          |
#define FIFO_COUNTL         0x73            // R/W    |                             FIFO_COUNT[7:0]                           |
#define FIFO_R_W            0x74            // R/W    |                             FIFO_DATA[7:0]                            |
#define WHO_AM_I            0x75            // R      |    -   |                     WHO_AM_I[6:1]                   |   -    |
#define MPU6050_SLAVE_ADDR  0x68


  // Valores iniciales
   enum Ascale {
     AFS_2G = 0,
     AFS_4G,
     AFS_8G,
     AFS_16G
   };

   enum Gscale {
     GFS_250DPS = 0,
     GFS_500DPS,
     GFS_1000DPS,
     GFS_2000DPS
   };

   enum Aaxis {
     AXIS_X = 1,
     AXIS_Y,
     AXIS_Z
   };


// Asigno valores iniciales
   int Gscale = GFS_250DPS;
   int Ascale = AFS_2G;
   int Aaxis = AXIS_X;