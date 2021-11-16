%include "hw.h"

EXTERN Gate_A20
USE16

GLOBAL	Entry

section .resetVector
Entry:				
	cli
	jmp		init
error:
	hlt
	jmp		error

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
;* Comprobamos el procesador
	test 	eax,0xFFFFFFFF	;eax debe arrancar en 0x000000000
	jnz 	error			;de otro modo a haltear
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
	je		A20_enabled
	call	Gate_A20
A20_enabled:	
	jmp	0x0:0x7C00

init_size EQU $ - init_bootstrap 

;/**
;* ¿Porque se utiliza [cs:si] para direccionar los bytes en oirgen? 
;* Luego de un Reset, lso procesadores x86 inician como un 8086. Esto es:
;* 1. Direccionan 1 Mbyte de memoria.
;* 2. El modo de trabajo es en 16 bits.
;* 3. los registros CS e IP valen: cs=0xF000, y IP = 0xFFF0, lo cual en Modo 
;*    Real lleva a la dirección de Memoria 0xFFFF0 para buscar la primer 
;*    instrucción a ejecutar.
;* Debido a 3., el diseñador de Hardware debería mapear en ese espacio una 
;* memoria de tipo No Volatil. 
;* En un procesador x86 con arquitectura IA-32, se dispone de un espacio físico
;* de 4Gbytes. Poner una ROM alrrededor de la dirección 1 Mega... no suena muy
;* apropiado.
;* Para evitarlo lso diseñadores de Intel introducen una facilidad de modo 
;* protegido disponible en modo real. Usan en modo real el registro hidden
;* del registro CS con valores default:
;* Base = 0xFFFF0000
;* Limite = 0xFFFF
;* De este modo el procesador buscará su primer instrucción en:
;*     Base: FFFF0000
;*     + 
;*       IP:     FFF0
;*    ---------------------
;*           FFFFFFF0
;* Permitiendo al procesador acceder a un área de memoria cercana a los 4Gbytes.
;* El precio es no poder cambiar CS. Ni bien se modifique su valor, se borran 
;* los valores default del regstro cache hidden asociado a CS, quedando ahora
;* restringido al primer Megabyte de memoria.
;* Por este motivo no podemos replicar esta accesibilidad a otros registros de 
;* segmento ya que sus registros hidden no están accesibles nunca en modo Real.
;* Entonces utilizamos el prefijo de segmento CS para modificar el registro de 
;* segmento que la instrucción utilizará por default utilizando a SI como 
;* offset  
;*/

