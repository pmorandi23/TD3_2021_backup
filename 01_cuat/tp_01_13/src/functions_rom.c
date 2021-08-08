#include "../inc/functions_rom.h"


__attribute__(( section(".functions_rom")))
byte __fast_memcpy_rom(dword*src,dword *dst,dword length)
{
    byte status = ERROR_DEFECTO;

    if(length>0)
    {
        while(length)
        {
            length--;
            *dst++=*src++;
        }
        status = EXITO;
    }

    return (status);
}

/* Función que setea el Control Register 3 */
__attribute__(( section(".functions_rom")))
dword set_cr3_rom (dword init_dpt, byte _pcd, byte _pwt)
{
    dword cr3 = 0;

    cr3 |= (init_dpt & 0xFFFFF000);
    cr3 |= (_pcd << 4);
    cr3 |= (_pwt << 3);

    return cr3;

}

/* Función que setea una DPTE y una PTE segun Dir. Lineal y Física recibida. Mapeo hasta la base de la Página.*/
__attribute__(( section(".functions_rom")))
void set_page_rom (dword dir_PHY_base_dpt, dword dir_VMA, dword dir_PHY,byte dpte_us, byte pte_us, byte dpte_rw, byte pte_rw){

    dword pte = 0, dpte = 0, entry_pte = 0, init_pt = 0, entry_dtp = 0;

    dword* base_dpt = (dword*) dir_PHY_base_dpt; // 0x10000 - Base del primer DPT

    entry_dtp = get_entry_DTP_rom (dir_VMA); //Bits 31-22 de la VMA (Offset del PDE)

	init_pt = (dir_PHY_base_dpt + 0x1000 ) + (0x1000*entry_dtp); //Base de la PT (Base PDT + 4K) + (4K * PDE) dependiendo del PDE

    dword *base_tp = (dword*)init_pt; //Dir. base de la TP

	entry_pte = get_entry_TP_rom (dir_VMA); //Bits 21-12 de la VMA (Offset del PTE en la TP)

    /* Armo el DPTE */
    dpte |= (init_pt & 0xFFFFF000);
    dpte |= ( PAG_PS_4K << 7);
    dpte |= ( PAG_A << 5);
    dpte |= ( PAG_PCD_NO << 4);
    dpte |= ( PAG_PWT_NO << 3);
    dpte |= ( dpte_us << 2);
    dpte |= ( dpte_rw << 1);
    dpte |= ( PAG_P_YES << 0);

    /* Cargo el contenido del PDTE (Dir. Base de la Tabla de páginas) */
    *(base_dpt + entry_dtp) = dpte;

    /* Armo el PTE */
    pte |= (dir_PHY & 0xFFFFF000);
    pte |= (PAG_G_YES << 8);
    pte |= (PAG_PAT << 7);
    pte |= (PAG_D << 6);
    pte |= (PAG_A << 5);
    pte |= (PAG_PCD_NO << 4);
    pte |= (PAG_PWT_NO << 3);
    pte |= (pte_us << 2);
    pte |= (pte_rw << 1);
    pte |= (PAG_P_YES << 0);

    /* Cargo el contenido del PTE (Dir. Base de la página) */
    *(base_tp + entry_pte) = pte;
    
}


/* Función que toma el PDE de una dirección VMA */
__attribute__((section(".functions_rom"))) 
dword get_entry_DTP_rom(dword dir_VMA) 
{
	dword PDE = 0x00;

	PDE = (dir_VMA >> 22) & 0x3FF ;//31-22 bits

	return PDE;
}
/* Función que toma el PTE de una dirección VMA */
__attribute__((section(".functions_rom"))) 
dword get_entry_TP_rom(dword dir_VMA)  
{
	dword PTE = 0x00;

	PTE = (dir_VMA >> 12) & 0x3FF ;//21-12 bits

	return PTE;

}