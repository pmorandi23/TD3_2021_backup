%include "hw.h"

USE16

GLOBAL	Entry

section .resetVector
Entry:				
	cli
	jmp		dword init
aqui:
	hlt
	jmp		aqui

	align 16		
	end:

resetVector_size EQU $ - Entry 

section .ROM_init
init_bootstrap:

idle:
	hlt
	jmp	idle

;**
;* \fn CHECK_A20:
;* \brief Chequea si A20 está activado
;* \details Es obvio que en un sistema bare metal A20 estará deshabilitado.
;* Sin embargo, de acuerdo a como se compile bochs (nuestro emulador de PC), A20
;* puede estar habilitado.
;* Para hacerlo vamos a escribir en una dirección de memoria en los primeros 64K
;* y chequear el valor escrito utilizando una combinación de segmento:desplaza-
;* miento tal que si Gate A20 está habilitada acceda mas allá de los 64K, y sino,
;* coincida con la dirección que utilizamos para guardarla.
;* Las dos direcciones son 0x0000:0x1000, y 0xFFFF:0x1010.
;* En modo real el segmento se multiplica por 16 (se agrega un en cero en su dí-
;* gito menos significativo extiendiendo su tamaño a 20 bits), y al resultado se
;* suma el desplazamiento. El resultado en cada caso es:
;*  00000    FFFF0
;* + 1000   + 1010
;* -------  -------
;*  01000   101000
;*          ^
;*          -----Este '1' corresponde a A20. 
;* Si utilizando la segunda dirección leemos lo mismo que con la primera, A20 no
;* estará habilitada. De lo contrario lo está, en cuyo caso no es necesario in-
;* vocar a la función que la activa
;* La función retorna un valor en ax
;* AX = 0xFFFF => A20 Deshabilitada.
;* AX = 0x0000 => A20 Habilitada
;*/

A20_check:
	xor		ax,ax
	mov		es,ax	; es=0x0000
	not		ax
	mov		ds,ax	; ds=0xFFFF
;/* NO tengo memoria RAM en uso aún excepto a partir de 0x0FC00 en donde copié
;* nuestro código por lo tanto 0x01000 es una zona segura en donde escribir sin
;* temor a romper nada
;*/
	mov		si,0x1010
	mov		di,0x1000
;/* Aseguramos que con ambos punteros escribiremos datos diferentes */
	mov		byte [es:di],0x55
	mov		byte [si],0xAA
;/* Si A20 no está activada, con [es:di] debería leer 0xAA debido al rollover */
	cmp		byte [es:di],0x55
	jne 	A20_disabled
	xor		ax,ax	;//Por este punto pasa si A20 está habilitada, retorna 0	
A20_disabled:
	ret
           

;**
;*--------------------------------
;* \fn GATE_A20:
;* \brief Habilita o deshabilita la línea Gate de A20, para habilitar direciones
;* > 1Mbyte.
;* \details Controla la señal que maneja la compuerta del bit de direcciones A20.
;* La compuerta del bit A20 toma una salida del procesador de teclado 8042, que 
;* regula si A20 pasa o si pone un '0' lógico permanente en esa línea.
;* Cuando se planea acceder en Modo Protegido a direcciones de memoria mas allá 
;* del 1er. Mbyte, debe activarse a través del hardware mencionado la señal que 
;* controla la compuerta de la línea A20.
;* En la dirección de E/S 0x60h se lee el scan code de la última tecla pulsada
;* (make code), o liberada (break code) por el operador de la PC. En modo 
;* escritura en esta misma dirección, tiene funciones muy específicas, las 
;* mismas se establecen bit a bit: En particular seteando el Bit 1 se activa el 
;* Gate de A20 y si lo pone en 0 se lo desactiva.
;* Por otra parte el port 64h es el registro de comandos/estados según se 
;* escriba o lea respectivamente.
;* Con el tiempo aparecieron otros medios para habilitar el Gate de A20. En los 
;* BIOS nuevos aparece un servicio accesible mediante software por INT 15h, que 
;* invocado con AX=0x2400 lo deshabilita, o con EAX=0x2401 lo habilita.
;*-----------------------------------------------------------------------------
;* \author Alejandro Furfaro afurfaro@electron.frba.utn.edu.ar
;* \date 2019-04-17
;--------------------------------
;*/

Gate_A20:
;* Espera que el 8042 vacíe el buffer de entrada. No hay comando en proceso
		call	wait4_Input_Buffer
;* deshabilita teclado en el  controlador 8042
		mov		al, _8042_KEYB_DISABLE
		out		_8042_CONTROL_PORT,al
;* Espera que el 8042 vacíe el buffer de entrada. Indica que procesó el comando
		call	wait4_Input_Buffer
;* Selecciona para leer el Puerto de salida del 8042 (leerá port A = 0x60)
		mov		al, READ_8042_OUT_PORT
		out		_8042_CONTROL_PORT,al
;* Espera que el 8042 tenga datos en el buffer de entrada. Indica que 
;* puede leer el registro de estado de la configuración 
		call	wait4_Output_Buffer
;* Lee el Port de salida del contolador 8042
		in 		al, _8042_PORT_A
		push	ax					;// Reserva valor leído en la pila
;* Espera que el 8042 vacíe el buffer de entrada. Indica que procesó el 
;* último comando
		call	wait4_Input_Buffer
;* Envía comando escribir en el Puerto de Salida del 8042
		mov	al, WRITE_8042_OUT_PORT
		out	_8042_PORT_A, al
;* Espera que el 8042 vacíe el buffer de entrada. Indica que procesó el 
;* último comando
		call	wait4_Input_Buffer
;* Recupera el estado leído, setea el bit de Habilitación A20 y lo envía al 
;* port de Salida del 8042
		pop	ax		;//Recupera el valor leído 
		or 	ax,2	;//Setea el bit 1. Esto activará A20
		out		_8042_PORT_A, al
;* Espera que el 8042 vacíe el buffer de entrada. Indica que procesó el 
;* último comando
		call	wait4_Input_Buffer
;* Procesada la habillitación de A20 queda habilitar el teclado nuevamente
		mov	al,_8042_KEYB_ENABLE
		out	_8042_CONTROL_PORT,al
;* Espera que el 8042 vacíe el buffer de entrada. Indica que procesó el 
;* último comando y luego retorna.
		call	wait4_Input_Buffer
		ret				

;/**
;* \fn wait4_Input_Buffer
;*/

wait4_Input_Buffer:
		in	al,_8042_CONTROL_PORT	;//Leemos el registro de status (0x64)
		test	al,_8042_IN_BUF_FULL	;//Si el bit 1 es '1' el buffer de 
		jnz 	wait4_Input_Buffer		;//entrada aún está lleno => loopea
		ret								;//Aquí el buffer se vació. Puede seguir

;/**
;* \fn wait4_Output_Buffer
;*/

wait4_Output_Buffer:
		in		al,_8042_CONTROL_PORT	;//Leemos el registro de status (0x64)
		test	al,_8042_OUT_BUF_FULL	;//Si el bit 0 es '0' el buffer de 
		jz 		wait4_Output_Buffer		;//salida aún está vacío => loopea
		ret								;//Aquí el buffer tiene información

;* Subrutina: memcopy
;* Recibe:
;*  es:di la dirección lógica de destino (a donde quiero copiar)
;*  cs:si la dirección lógica de origen (lo que quiero copiar)
;*  cx la cantidad de bytes a copiar
;* Retorna:
;*  NULL si hubo error
;*  puntero a la dirección de inicio de la nueva copia
memcopy:
next:
	mov     al,byte[cs:si]  ; ver commentario al final
	stosb                   ;[es:di]<-al , di++
	inc     si              ;apuntamos al siguiente byte en la ROM
	loop    next            ;cx--, if(FLAGS.ZF==0) goto next 
	ret
init:
;* Se activa la DRAM y su controlador
	DRAM_Enable
;* Seteamos un stack
	mov 	sp,0x3000
	mov     ax,0
	mov     es,ax
	mov     di,0x7c00
	mov     si,init_bootstrap
	mov     cx,init_size
	call    memcopy
	call	A20_check
	cmp	ax,0
	je	A20_enabled
	call	Gate_A20
A20_enabled:	
	jmp	0x0:0x7C00

init_size EQU $ - init_bootstrap 

