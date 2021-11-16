ENTRY (Entry)

/*
El comando MEMORY permite definir nuestro mapar de memoria
*/
MEMORY
{
	RAM (!rx): ORIGIN = 0, LENGTH = 0xFFFFF000  /* desde 0x00000000 hasta 0xFFFFEFFF*/
	ROM (rx) : ORIGIN = 0XFFFFF000, LENGTH = 0x1000 /*desde 0xFFFFF000 hasta 0xFFFFFFFF*/
}

SECTIONS
{
	. = 0xFFFFFFF0;
	.resetVector 0xFFFFFFF0 : AT ( 0xFFFFFFF0 ) {*(.resetVector);} >ROM

	. = 0xFFFFF000;
	.ROM_init 0xFFFFF000 : AT ( 0xFFFFF000 ) {*(.ROM_init);} >ROM
}
