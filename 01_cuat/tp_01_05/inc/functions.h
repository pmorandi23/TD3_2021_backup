/* --------------DEFINES-----------------------*/
#define ERROR_DEFECTO 0
#define EXITO 1
/* --------------TECLAS-------------------------*/
#define TECLA_1     0x02
#define TECLA_2     0x03
#define TECLA_3     0x04
#define TECLA_4     0x05
#define TECLA_5     0x06
#define TECLA_6     0x07
#define TECLA_7     0x08
#define TECLA_8     0x09
#define TECLA_9     0x0A
#define TECLA_0     0x0B
#define TECLA_A     0x1E
#define TECLA_B     0x30
#define TECLA_C     0x2E
#define TECLA_D     0x20
#define TECLA_E     0x12
#define TECLA_F     0x21
#define TECLA_G     0x22
#define TECLA_H     0x23
#define TECLA_I     0x17
#define TECLA_J     0x24
#define TECLA_K     0x25
#define TECLA_L     0x26
#define TECLA_M     0x32
#define TECLA_N     0x31
#define TECLA_O     0x18
#define TECLA_P     0x19
#define TECLA_Q     0x10
#define TECLA_R     0x13
#define TECLA_S     0x1F
#define TECLA_T     0x14
#define TECLA_U     0x16
#define TECLA_V     0x2F
#define TECLA_W     0x11
#define TECLA_X     0x2D
#define TECLA_Y     0x15
#define TECLA_Z     0x2C
/* -----------------TYPEDEF-------------------- */
typedef unsigned char byte;
typedef unsigned long dword;
/* ----------------PROTOTIPOS DE FUNCION----------- */
byte __fast_memcpy_rom (dword*, dword *,dword);
byte __fast_memcpy (dword*, dword *,dword);
void determinar_tecla_presionada (dword *);
