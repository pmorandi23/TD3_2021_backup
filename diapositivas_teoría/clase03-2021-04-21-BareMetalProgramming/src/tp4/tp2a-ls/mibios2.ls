SECTIONS
{
	. = 0xFF000;          /*'.' es el location counter. 
				Al inicio del comando SECTIONS su valor es 0.
				Se incrementa con el tamaño de las secciones.*/
	.data : {*(.data)}   /*Seccion de salida : lista de las secciones de 
				entrada. 
				La lista es {archivo(sección)}. El '*' indica 
				cualquier archivo de entrada. Entre paréntesis
				el nombre de la sección.
				Esta líne colecta todas las secciones .data de 
				todos los archivos de entrada y las combina en 
				una unica sección .data en el archivo de salida*/

	. = 0xFFFF0;
	.text : AT ( 0xFFFF0 )
		{*(.resetVector)}	
}
