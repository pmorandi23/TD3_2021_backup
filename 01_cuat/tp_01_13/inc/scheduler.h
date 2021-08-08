#include "../inc/functions.h"

//------------DEFINES--------------------------
#define TAREA_1         1
#define TAREA_2         2
#define TAREA_3         3
#define TAREA_4         4
#define CORRIENDO       1
#define SUSPENDIENDO    0

//---------------EXTERN LINKER------------------------
extern long unsigned __TSS_BASICA;
extern long unsigned __TSS1_VMA;
extern long unsigned __TSS2_VMA;  
extern long unsigned __TSS3_VMA;  
extern long unsigned __TSS4_VMA;  
extern long unsigned __CR3_KERNEL_PHY; 
extern long unsigned __CR3_TAREA_1_PHY;
extern long unsigned __CR3_TAREA_2_PHY;
extern long unsigned __CR3_TAREA_3_PHY;
extern long unsigned __CR3_TAREA_4_PHY;
//-----------------EXTERN VARIABLES-------------------
extern dword TSS_aux;
extern dword CR3_aux;

//------------PROTOTIPOS DE FUNCION-------------
void scheduler_c (void );
void determinar_TSS_a_leer(byte*);
void determinar_TSS_a_guardar(byte*);


