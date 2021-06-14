/* --------------DEFINES-----------------------*/
#define ERROR_DEFECTO 0
#define EXITO 1
/* --------------DEFINES TECLAS (Releases codes)-------------------------*/
/* #define TECLA_1     0x82
#define TECLA_2     0x83
#define TECLA_3     0x84
#define TECLA_4     0x85
#define TECLA_5     0x86
#define TECLA_6     0x87
#define TECLA_7     0x88
#define TECLA_8     0x89
#define TECLA_9     0x8A
#define TECLA_0     0x8B */

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
#define TECLA_ENTER 0x1C
/* ---------------EXTERN---------------------------- */
extern long unsigned __DIGITS_TABLE;
extern long unsigned __VGA_VMA;
/* ----------------DEFINES GENERALES---------------- */
#define MASK_PROMEDIO   0x000000000000000F
/* -------------DEFINES BUFFER TECLADO-------------- */
#define BUFFER_MAX        16
#define CANTIDAD_DIGITOS  10  
//#define LONG_TABLA  BUFFER_MAX*CANTIDAD_DATOS   //10 datos de 16 bytes cada uno.
/* -------------DEFINES BUFFER PANTALLA------------- */
#define FILAS_PANTALLA      24   //24 filas de 160 bytes cada una
#define COLUMNAS_PANTALLA   160  //80 columnas de 2 bytes cada una
#define BUFFER_MAX_VIDEO    32   //16 caracteres con sus 16 atributos cada uno

/* -----------------TYPEDEF-------------------- */
typedef unsigned char byte;
typedef unsigned int word;
typedef unsigned long dword;
typedef unsigned long long qword;

/*----------------- STRUCTS------------------------ */
typedef struct buffer_teclado
{
    byte    buffer[BUFFER_MAX];     //Buffer de 17 bytes (0 - 16)
    byte    head;                   //Posición al escribir (push)        
    byte    tail;                   //Posición al leer  (pop)
    byte    cantidad;               //Cantidad de elementos actuales.

}buffer_t;
typedef struct tabla_digitos
{
    qword tabla[CANTIDAD_DIGITOS];   //Tabla de 10 digitos
    //dword tabla [LONG_TABLA];
    byte indice_tabla;
    qword promedio_dig;
    qword sumatoria_dig;

}tabla_t;

typedef struct buffer_screen
{
    byte buffer[FILAS_PANTALLA*COLUMNAS_PANTALLA]; // Buffer para toda la pantalla 
    byte posicion; 
}buff_screen_t;


/* ----------------PROTOTIPOS DE FUNCION----------- */
byte __fast_memcpy (dword*, dword *,dword);
void determinar_tecla_presionada (byte , buffer_t*);
void limpiar_buffer (buffer_t* );
void escribir_buffer (byte , buffer_t* );
byte leer_buffer (buffer_t*);
void escribir_tabla_digitos(buffer_t* , tabla_t*,byte );
void contador_handler (qword* , tabla_t*, dword* );
void promedio_digitos_64(tabla_t* , qword* );
void sumatoria_digitos_64(tabla_t* );
void ejecutar_tarea_1 (tabla_t* );
