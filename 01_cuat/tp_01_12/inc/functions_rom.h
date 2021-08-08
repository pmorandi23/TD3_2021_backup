/* --------------DEFINES-----------------------*/
#define ERROR_DEFECTO 0
#define EXITO 1

typedef unsigned char byte;
typedef unsigned long dword;



//------------DTP y TP(Descriptor de Tablas de Páginas y Tabla de Páginas) flags--------------------------
#define PAG_PCD_YES   1       // cachable                          
#define PAG_PCD_NO    0       // no cachable
#define PAG_PWT_YES   1       // 1 se escribe en cache y ram       
#define PAG_PWT_NO    0       // 0 
#define PAG_P_YES     1       // 1 presente
#define PAG_P_NO      0       // 0 no presente
#define PAG_RW_W      1       // 1 lectura y escritura
#define PAG_RW_R      0       // 0 solo lectura
#define PAG_US_SUP    0       // 0 supervisor
#define PAG_US_US     1       // 1 usuario  
#define PAG_D         0       // modificacion en la pagina
#define PAG_PAT       0       // PAT                   
#define PAG_G_YES     0       // Global                 
#define PAG_A         0       // accedida
#define PAG_PS_4K     0       // tamaño de pagina de 4KB


byte __fast_memcpy_rom (dword*, dword *,dword);
dword set_cr3_rom (dword , byte , byte );
void set_page_rom (dword , dword , dword ,byte , byte , byte , byte );
dword get_entry_DTP_rom(dword ); 
dword get_entry_TP_rom(dword );  

