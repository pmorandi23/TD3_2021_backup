;/**
;* Programa Hola Mundo usando la instrcción syscall para acceder al kernel.
;* syscall llama al handler de las system call del Sistema Operativo, cargando en RIP la 
;* dirección que el kernel cargó en el MSR (Model Specific Register)  IA32_LSTAR
;* Se resguarda la dirección de retorno (la instrucción siguiente a SYSCALL) en ecx/rcx y 
;* EFLAGS/RFLAGS en R11. Se recuperan automáticamente cuando se retorna desde la system call.
;* El valor de retorno se devuelve en eax/rax. El resto de los registros quedan preservados.
;*************************************************
; Para trabajar con syscall, la interfaz no es como la utilizada en INT 0x80.
; La documentación del API del kernel tiene los valores. Está en el archivo:
; /usr/src/linux-headers-4.15.0-46-generic/arch/x86/include/generated/uapi/asm/unistd_64.h 
;* Al igual que en el caso de INT 0x80 la función pasa en eax/rax (sale del archivo unistd_64.h)
;* Los parámetros pasan en el orden siguiente:
;* Param1 | Param2 | Param3 | Param4 | Param5 | Param6
;*   RDI  |   RSI  |   RDX  |   R10  |    R8  |   R9
;*/

section .data
msg 	db	'hello world!',10	;Mensaje a presentar, finaliza en CR (10)
msg_len EQU	$-msg		 		;$ Es una variable en la que se almacena 
				 				;el contador de programa interno de nasm
				 				;Soportada por cualquier ensamblador

global _start	 				;_start Etiqueta obligatoria. Es el nombre que el 
				 				;linker busca para el punto de entrada del programa
				 				;Por eso la directiva global la "exporta" fuera de este archivo
section .text
_start:
    mov     rax, 1				;rax lleva la función: sys_write () con este método es 1

; El orden de los siguientes argumentos se corresponde con el que tienen en la función write()
; man 2 write si no te lo acordás de memoria. int write (int fd, char * buffer, int cant)

    mov     rdi, 1				; rdi lleva file descriptor (fd)
    mov     rsi, msg			; rsi apunta al buffer donde está el texto (buffer)  
    mov     rdx, msg_len		; rdx tiene la cantidad de bytes de la cadena de texto (cant)

    syscall						; syscall: Fast system call. Ver comentario al inicio
								; Dirección de retorno --> RCX, 
								; RFLAGS -->R11
; en este punto RAX contiene el número de bytes escritos por sys_write().
    mov    rax, 60				; sys_exit () es 60
    mov    rdi, 0				; rdi lleva el código de retorno
    syscall
