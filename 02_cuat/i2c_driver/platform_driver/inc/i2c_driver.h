//-------------------------------------------------------------------
//-----------------------------INCLUDES------------------------------
//-------------------------------------------------------------------
#include <linux/init.h>
#include <linux/kernel.h>
#include <linux/kdev_t.h>		   //agregar en /dev
#include <linux/device.h>		   //agregar en /dev
#include <linux/cdev.h>			   // Char device: File operation struct,
#include <linux/fs.h>			   // Header for the Linux file system support (alloc_chrdev_region y unregister_chrdev_region)
#include <linux/module.h>		   // Core header for loading LKMs into the kernel
#include <linux/of_address.h>	   // of_iomap
#include <linux/platform_device.h> // platform_device
#include <linux/of.h>			   // of_match_ptr
#include <linux/io.h>			   // ioremap
#include <linux/interrupt.h>	   // request_irq
#include <linux/delay.h>		   // msleep, udelay y ndelay
#include <linux/uaccess.h>		   // copy_to_user - copy_from_user
#include <linux/types.h>		   // typedefs varios
#include <linux/slab.h>			   // kmalloc
#include <linux/ioctl.h>
#include "../inc/BBB_I2C_reg.h"
#include "../inc/MPU6050_REGS_I2C_.h"
//-------------------------------------------------------------------
//-----------------------------DEFINES--------------------------------
//-------------------------------------------------------------------
#define MENOR          0
#define CANT_DISP      1
#define ID    		   "i2c_driver"
#define CLASS_NAME     "i2c_td3_driver_class"
#define COMPATIBLE	   "P.Morandi,i2c_td3_driver"
#define NAME		   "P.Morandi,i2c_td3_driver"
//I2C
#define XRDY			0
#define ARDY			1
#define RRDY			2
#define BYTES_TO_TX		1
#define WRITE_REGISTER  1
#define READ_REGISTER	2
#define READ_BYTE		1
#define READ_1024_BYTES	2
#define GENERATE_STOP 	1
#define NOT_STOP		2
// MPU6050
#define MAX_BYTES_TO_READ	1022
//-------------------------------------------------------------------
//-----------------------------PROTOTIPOS----------------------------
//-------------------------------------------------------------------
static int i2c_probe(struct platform_device * i2c_pd);
static int i2c_remove(struct platform_device * i2c_pd);
static int fop_open(struct inode *inode, struct file *file);
static int fop_release(struct inode *inode, struct file *file);
static ssize_t fop_read (struct file * device_descriptor, char __user * user_buffer, size_t read_len, loff_t * my_loff_t);
static ssize_t fop_write (struct file * device_descriptor, const char __user * user_buffer, size_t write_len, loff_t * my_loff_t);
static long fop_ioctl(struct file *file, unsigned int cmd, unsigned long arg);
irqreturn_t i2c_irq_handler(int irq, void *dev_id, struct pt_regs *regs);
static int change_permission_cdev(struct device *dev, struct kobj_uevent_env *env);
int i2c_write_buffer(uint8_t regMPU6050, uint8_t regMPU6050_value, int operation);
uint8_t i2c_read_buffer(void);
int i2c_read_burst(int bytesToRead);
void MPU6050_init(void);
void I2C_init(void);
uint16_t MPU6050_read_fifo_count(void);





//-------------------------------------------------------------------
//-----------------VARIABLES GLOBALES--------------------------------
//-------------------------------------------------------------------
volatile int wakeupCondition = 0;
wait_queue_head_t queue = __WAIT_QUEUE_HEAD_INITIALIZER(queue);
wait_queue_head_t queueTASK_UNINTERRUPTIBLE = __WAIT_QUEUE_HEAD_INITIALIZER(queueTASK_UNINTERRUPTIBLE);
static void __iomem *cmper_baseAddr, *ctlmod_baseAddr, *i2c2_baseAddr;
int virq;
//-------------------------------------------------------------------
//-----------------------------STRUCTS--------------------------------
//-------------------------------------------------------------------
// Char device - I2C
static struct {
	dev_t i2c_MPU6050;  // Tipo de cdev 
	struct cdev * i2c_MPU6050_cdev; // cdev
	struct device * i2c_MPU6050_device; // device
	struct class * i2c_MPU6050_class; // class
} device;
// Data transfer - I2C
static struct {
	uint8_t rxData;
	uint8_t burstRxBuffer[100];
	uint8_t* MPU6050_dataBuffer;
	uint8_t txData[2];
	int dataCount;
	int operation;
	int dataToRead;

} i2cStruct;
// Data sensor MPU6050
/* static struct MPU6050_REGS
{
    int16_t accel_xout;
    int16_t accel_yout;
    int16_t accel_zout;
    int16_t temp_out;
    int16_t gyro_xout;
    int16_t gyro_yout;
    int16_t gyro_zout;
}MPU6050_data; */


// File operations
struct file_operations i2c_ops = {
	.owner = THIS_MODULE,
	.open = fop_open,
	.read = fop_read,
	.write = fop_write,
	.release = fop_release,
	.unlocked_ioctl = fop_ioctl
};
//-------------------------------------------------------------------
//-----------------------MODULE - MACROS-----------------------------
//-------------------------------------------------------------------
MODULE_LICENSE("Dual BSD/GPL");
MODULE_AUTHOR("Pablo Jonathan Morandi R5054");
MODULE_VERSION("1.0");
MODULE_DESCRIPTION("TD3_MYI2C LKM");