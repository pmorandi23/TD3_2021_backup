;--------------------------------------------------------------------
; holamundo en assembly de 64 bits, usando printf() de libC
;
; Equivalente a:
;       #include <stdio.h>
;       char msg[] = "Hola, Mundo";
;       int main() 
;       {
;               printf("%s\n", msg);
;               return 0;
;       }
;
; Salida de texto básica utilizando printf(), en modo 64-bit.
; Está organizado para linkearlo con ld en forma directa para delegar en gcc
; la lamada al linker. 
; En el primer caso necesitamso tener definida la etiqueta _start como punto 
; de entrada del programa. De otro modo ld dara error. 
; En el segundo caso debemos omitirla ya que el gcc involucrará a la libc en 
; la compilación además de uan serie de objetos que se intercalan al objeto 
; de cualquier programa al inicio y luego de que este finalice.
; Los objetos en una distro Ubuntu 18.04 con kernel 4.15.0-91-generic son:
; /usr/lib/x86_64-linux-gnu/crt1.o: Se intercala entre la libc y nuestro objeto
; Bueca una etiqueta llamada min en nuestro objeto a la que toma como punto de 
; entrada y posee en forma local la etiqueta _start que busca el linker.
; por eso cuando gcc invoca al linker incluye este archivo en el bulk de argumentos
; que le pasa (modificar el Makefile y agregar a la líne gcc el flag -v (por verbose)
; para ver este y otros objetos, terminados en .o que son incluidos)
; Si hacen: objdump -t /usr/lib/x86_64-linux-gnu/crt1.o podrán ver la etiqueta global
; _start declarada junto con una etiqueta main Undefined (o sea externa). El path de 
; este archivo lo busque con el comando locate crt1.o.
; Si compilamos con gcc el final del archivo no llama a la syscall exit sino que 
; pone 0 en EAX (código de retorno), y ejecuta ret (esto es return en C)
; En cambio si linkeamos directo con ld, necesitamos la etiqueta start y
; finalizar con la llamada a INT 0x80 ya que si bien incluimos a libc en los 
; flags del linker cuando ponemos -lc, no estamos involucrando a los .o 
; adicionales que incluyó el gcc.
; Para resolverlo se invoca a MAKE pasandole una variable por línea de comandos
; La variable TAG que puede valer cualquier cosa o LINK_TROUGH_GCC.
; En el caso que tenga ese valor controla flujo dentro de Makefile quien la incluye
; como etqueta en la línea de nasm mediante el flag -d LINK_TRIUGH_GCC, y se usa
; mas abajo para seleccionar si poner o no _start, y para salir con ret o con 
; INT0x80h 
;--------------------------------------------------------------------

SECTION .data
msg:    db "Hola, mundo,", 0
msg2:   db "...y adiós!", 0
fmt:    db "%s", 10, 0

SECTION .text
extern printf
global main

%ifndef LINK_TROUGH_GCC
global _start
_start:
%endif

main:
        mov esi, msg    ;orden de pasaje en 64-bit ABI: edi, esi, ...
        mov edi, fmt    ;
        mov eax, 0      ;printf tiene argumentos varios, EAX cuenta #
                        ;de argumentos  no-enteros que están pasando
        call printf

        mov esi, msg2   ;orden de pasaje en 64-bit ABI: edi, esi, ...
        mov edi, fmt    ;
        mov eax, 0      ;printf tiene argumentos varios, EAX cuenta #
                        ;de argumentos  no-enteros que están pasando
        call printf
%ifndef LINK_TROUGH_GCC
        mov ebx, 0      ; exit code salida normal
        mov eax, 1      ; servicio de finalización del proceso
        int 0x80        ; Llamada a linux kernel
%endif

%ifdef LINK_TROUGH_GCC 
	mov eax,1
	ret
%endif
;--------------------------------------------------------------------
