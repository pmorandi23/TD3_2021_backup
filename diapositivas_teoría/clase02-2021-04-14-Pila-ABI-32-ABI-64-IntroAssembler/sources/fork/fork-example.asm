section .text
global  _start
_start:
	mov eax, 2 ; identificador de la SYS_FORK
	int 0x80
	cmp eax, 0 ;Si deuelve 0 => child process
	jz child

parent:
; Si legamos a este label estamos en el proceso padre
	mov edx, len ;edx = longitud del mensaje
	mov ecx, msg ;ecx = puntero al mensaje
	call print ;Llama a print (En realidad es sys_write() )
	call exit ;llama a sys_exit()

child:
;Esta parte es el proceso child (viene de la instrución de salto)
	mov edx,cLen ;Idem...
	mov ecx,cMsg
	call print
	call exit

print:
	mov     ebx,1  ;file handle (stdout)
	mov     eax,4  ;Nro. de system call (SYS_WRITE)
	int     0x80
	ret

exit:
	mov     ebx,0 ; Exit code
	mov     eax,1 ; sus_exit ()
	int     0x80

section .data
	msg db      "Luke .... I am your father!",0xa,0xa	;Mensaje del proceso padre
	len equ     $ - msg							; Longitud del mensajej del proceso padre
	cMsg db     "Soy el proceso hijo ",0xa,0xa		;Mensaje del proceso hijo
	cLen equ    $ - cMsg             ;y su longitud
