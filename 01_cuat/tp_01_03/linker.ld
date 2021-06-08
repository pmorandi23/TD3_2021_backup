SECTIONS
{
    /* 
    Contenido posición física (VMA (Virtual Memory Address))
    
    En ROM:
   
    Binario copiado                 00007C00h
    Pila                            00068000h
    Secuencia inicialización ROM    FFFF0000h
    Vector de reset                 FFFFFFF0h    
    */

    /* Init 16 section @VMA = 0xF0000 */
    .init16 0xFFFF0000 : /* VMA (Virtual Memory Address) */
        AT( 0xFFFF0000 ) /* LMA (Local Memory Address) */
    {
        *(.init16);
    }
    /* Reset section @VMA = 0xFFFF0 */
    .reset 0xFFFFFFF0 : /* VMA */
        AT( 0xFFFFFFF0 ) /* LMA */
    {
        *(.reset);
    }
}
