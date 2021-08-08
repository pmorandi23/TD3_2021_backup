%define X86_CR0_PE      0x00000001 ; /* Protectede mode enable*/
%define X86_CR0_MP      0x00000002 ; /* Monitor coProcessor*/
%define X86_CR0_EM      0x00000004 ; /* Emulation*/
%define X86_CR0_TS      0x00000008 ; /* Task Switched*/
%define X86_CR0_ET      0x00000010 ; /* Extension Type*/
%define X86_CR0_NE      0x00000020 ; /* Numeric Error*/
%define X86_CR0_WP      0x00010000 ; /* Write Protect*/
%define X86_CR0_AM      0x00040000 ; /* Alignment Mask*/
%define X86_CR0_NW      0x20000000 ; /* Not Write-through*/
%define X86_CR0_CD      0x40000000 ; /* Cache Disable*/
%define X86_CR0_PG      0x80000000 ; /* PaGine*/
%define flag_TSS_sup    1
%define flag_TSS_us     0

;------------DTP y TP(Descriptor de Tablas de Páginas y Tabla de Páginas) flags--------------------------
PAG_PCD_YES  equ 1       ; cachable                          
PAG_PCD_NO   equ 0       ; no cachable
PAG_PWT_YES  equ 1       ; 1 se escribe en cache y ram       
PAG_PWT_NO   equ 0       ; 0 
PAG_P_YES    equ 1       ; 1 presente
PAG_P_NO     equ 0       ; 0 no presente
PAG_RW_W     equ 1       ; 1 lectura y escritura
PAG_RW_R     equ 0       ; 0 solo lectura
PAG_US_SUP   equ 0       ; 0 supervisor
PAG_US_US    equ 1       ; 1 usuario  
PAG_D        equ 0       ; modificacion en la pagina
PAG_PAT      equ 0       ; PAT                   
PAG_G_YES    equ 0       ; Global                 
PAG_A        equ 0       ; accedida
PAG_PS_4K    equ 0       ; tamaño de pagina de 4KB

; ------------ EQU Generales-----------------
SYS_HALT                EQU     0
SYS_READ                EQU     1
SYS_PRINT               EQU     2
SYS_PRINT_VGA           EQU     3
ASCII_TRUE              EQU     1
ASCII_FALSE             EQU     0