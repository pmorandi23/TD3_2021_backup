USE16

GLOBAL	Entry

section .resetVector
Entry:                          
        cli
        jmp dword init 
aqui:
        hlt
        jmp aqui

align 16                
end:

resetVector_size EQU $ - Entry 

section .ROM_init
init_bootstrap:
idle:
        hlt
        jmp    idle
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
        jmp     0x0:0x7C00

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
init_size EQU $ - init_bootstrap 


%macro	DRAM_Enable 0
	nop	;* Simula la habilitación de la DRAM y su controlador que Bochs
		;* ya tiene habilitados por simulación :)
		;* Luego de esta macro usar se puede definir un stack y llamar 
		;* a las rutinas que se necesite ...
%endmacro

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

