;/**
;\file hw.asm
;\brief Rutinas de acceso al hardware de la PC
;\details Aqu� vamos a definir los tipos de estructuras que vamos a utilizar en los diferentes ejemplos. Son declaraciones. Las estructuras se instancian luego en los programas.
;\author Alejandro Furfaro afurfaro@electron.frba.utn.edu.ar
;\date 2012-07-05
; *

%include "hw.h"

GLOBAL ReprogramarPICs
GLOBAL Gate_A20
GLOBAL hora
GLOBAL fecha

;/**
;-----------------------------
;\fn ReprogamarPICs
;\brief Reprograma la base de interrupciones de los PICs
;\details Corre la base de los tipos de interrupci�n de ambos PICs 8259A de la PC a los 8 tipos consecutivos a partir de los valores base que recibe en BH para el PIC#1 y BL para el PIC#2.A su retorno las Interrupciones de ambos PICs est�n deshabilitadas.
;\author Alejandro Furfaro afurfaro@electron.frba.utn.edu.ar
;\date 2012-07-05
;------------------------------
;*/

ReprogramarPICs:
;// Inicializaci�n PIC N�1
  ;//ICW1:
  mov     al,0x11;//Establece IRQs activas x flanco, Modo cascada, e ICW4
  out     0x20,al
  ;//ICW2:
  mov     al,bh	;//Establece para el PIC#1 el valor base del Tipo de INT que recibi� en el registro BH
  out     0x21,al
  ;//ICW3:
  mov     al,0x04;//Establece PIC#1 como Master, e indica que un PIC Slave cuya Interrupci�n ingresa por IRQ2
  out     0x21,al
  ;//ICW4
  mov     al,0x01;// Establece al PIC en Modo 8086
  out     0x21,al
;//Antes de inicializar el PIC N�2, deshabilitamos las Interrupciones del PIC1
  mov     al,0xFF
  out     0x21,al
;//Ahora inicializamos el PIC N�2
  ;//ICW1
  mov     al,0x11;//Establece IRQs activas x flanco, Modo cascada, e ICW4
  out     0xA0,al
  ;//ICW2
  mov     al,bl	 ;//Establece para el PIC#2 el valor base del Tipo de INT que recibi� en el registro BL
  out     0xA1,al
  ;//ICW3
  mov     al,0x02;//Establece al PIC#2 como Slave, y le indca que ingresa su Interrupci�n al Master por IRQ2
  out     0xA1,al
  ;//ICW4
  mov     al,0x01;// Establece al PIC en Modo 8086
  out     0xA1,al
;Enmascaramos el resto de las Interrupciones (las del PIC#2)
  mov     al,0xFF
  out     0xA1,al
  ret

;******************************************************************************
;
; FUNCIONES DE ACCESO AL CONTROLADOR DE TECLADO PARA ACTIVAR A20
;
;******************************************************************************

;**
;* \fn CHECK_A20:
;* \brief Chequea si A20 est� activado
;* \details Es obvio que en un sistema bare metal A20 estar� deshabilitado.
;* Sin embargo, de acuerdo a como se compile bochs (nuestro emulador de PC), A20
;* puede estar habilitado.
;* Para hacerlo vamos a escribir en una direcci�n de memoria en los primeros 64K
;* y chequear el valor escrito utilizando una combinaci�n de segmento:desplaza-
;* miento tal que si Gate A20 est� habilitada acceda mas all� de los 64K, y sino,
;* coincida con la direcci�n que utilizamos para guardarla.
;* Las dos direcciones son 0x0000:0x1000, y 0xFFFF:0x1010.
;* En modo real el segmento se multiplica por 16 (se agrega un en cero en su d�-
;* gito menos significativo extiendiendo su tama�o a 20 bits), y al resultado se
;* suma el desplazamiento. El resultado en cada caso es:
;*  00000    FFFF0
;* + 1000   + 1010
;* -------  -------
;*  01000   101000
;*          ^
;*          -----Este '1' corresponde a A20. 
;* Si utilizando la segunda direcci�n leemos lo mismo que con la primera, A20 no
;* estar� habilitada. De lo contrario lo est�, en cuyo caso no es necesario in-
;* vocar a la funci�n que la activa

A20_check:
	
           

;**
;*--------------------------------
;* \fn GATE_A20:
;* \brief Habilita o deshabilita la l�nea Gate de A20, para habilitar direciones
;* > 1Mbyte.
;* \details Controla la se�al que maneja la compuerta del bit de direcciones A20.
;* La compuerta del bit A20 toma una salida del procesador de teclado 8042, que 
;* regula si A20 pasa o si pone un '0' l�gico permanente en esa l�nea.
;* Cuando se planea acceder en Modo Protegido a direcciones de memoria mas all� 
;* del 1er. Mbyte, debe activarse a trav�s del hardware mencionado la se�al que 
;* controla la compuerta de la l�nea A20.
;* En la direcci�n de E/S 0x60h se lee el scan code de la �ltima tecla pulsada
;* (make code), o liberada (break code) por el operador de la PC. En modo 
;* escritura en esta misma direcci�n, tiene funciones muy espec�ficas, las 
;* mismas se establecen bit a bit: En particular seteando el Bit 1 se activa el 
;* Gate de A20 y si lo pone en 0 se lo desactiva.
;* Por otra parte el port 64h es el registro de comandos/estados seg�n se 
;* escriba o lea respectivamente.
;* Con el tiempo aparecieron otros medios para habilitar el Gate de A20. En los 
;* BIOS nuevos aparece un servicio accesible mediante software por INT 15h, que 
;* invocado con AX=0x2400 lo deshabilita, o con EAX=0x2401 lo habilita.
;*-----------------------------------------------------------------------------
;* Esta funci�n Gate_A20 trabaja con el controlador original para asegurar su 
;* compatibilidad en cualquier plataforma de hardware:
;* \args : 
;*		AH = 0DDh, si se desea apagar esta se�al. (A20 siempre cero).
;*              AL = 0DFh, si se desea disparar esta se�al. (x86 controla A20)
;*\return :     AL = 00, si hubo exito. El 8042 acepto el comando.
;*              AL = 02, si fallo. El 8042 no acepto el comando.
;*\author Alejandro Furfaro afurfaro@electron.frba.utn.edu.ar
;*\date 2012-07-05
;--------------------------------
;*/

Gate_A20:
	cli						;//Mientras usa el 8042, no INTR
	call    _8042_empty?	;//Ve si buffer del 8042 vac�o.
	jnz     gate_a20_exit	;//No lo est�?=>retorna con AL=2.

	mov     al,_8042_WRITE_OUT		;//Comando Write port del 8042..
	out     _8042_CONTROL_PORT,al	;//...se env�a al port 64h.

	call    _8042_empty?	;//Espera se acepte el comando.
	jnz     gate_a20_exit	;//Si no se acepta, Ret con AL=2
	mov     al,ah		;//Pone en AL el dato a escribir.
	out     _8042_PORT_A,al	;//Lo env�a al 8042.
	call    _8042_empty?	;//Espera que se acepte el comando.

gate_a20_exit:
	ret

;/**
;*--------------------------------
;*\fn 8042_empty?:
;*\brief Espera que se vac�e el buffer del 8042. 
;*\args:   Nada.
;*\return:     AL = 00, el buffer del 8042 est� vac�o.(ZF = 1)
;              AL = 02, time out. El buffer del 8042 sigue lleno. (ZF = 0)
;*\author Alejandro Furfaro afurfaro@electron.frba.utn.edu.ar
;*\date 2012-07-05
;*--------------------------------
;*/

_8042_empty?:
	push    cx		;//salva CX.
	sub     cx,cx	;//CX = 0 : valor de time out.

empty_8042_01:  
	in      al,_8042_CONTROL_PORT	;//Lee port de estado del 8042.
	and     al,00000010b	;//si el bit 1 est� seteado o...
	loopnz  empty_8042_01	;//no alcanz� time out, espera.
	pop     cx		;//recupera cx
	ret			;//retorna con AL=0, si se limpi� bit 1, o AL=2 si no.


;******************************************************************************
;
;FUNCIONES DE ACCESO AL RTC PARA ESTABLECER FECHA Y HORA
;
;******************************************************************************

;/**
;--------------------------------
;\fn hora
;\brief Obtiene la hora del sistema desde el RTC
;\args: Nada
;\return:	AL: Segundos
;		AH: Minutos
;		DL: Hora
;\author Alejandro Furfaro afurfaro@electron.frba.utn.edu.ar
;\date 2012-07-05
;--------------------------------
;*/
hora:
		call	RTC_disponible	;//asegura que no est� actualiz�ndose el RTC
		mov	al,4
		out	70h,al		;//Selecciona Registro de Hora
		in	al,71h		;//lee la hora desde el registro
		mov	dl,al
		
		mov	al,2
		out	70h,al		;//Selecciona Registro de Minutos
		in	al,71h		;//lee los minutos desde el registro
		mov	ah,al
		
		xor	al,al
		out	70h,al		;//Selecciona Registro de Segundos
		in	al,71h		;//lee los segundos desde el registro
		
		ret

;/**
;--------------------------------
;\fn fecha
;\brief Obtiene la fecha del sistema desde el RTC
;\args: Nada
;\return:	AL: Dia de la Semana
;		AH: Fecha del Mes
;		DL: Mes
;		DH: A�o
;\author Alejandro Furfaro afurfaro@electron.frba.utn.edu.ar
;\date 2012-07-05
;--------------------------------
;*/
fecha:
		call	RTC_disponible	;//asegura que no est� actualiz�ndose el RTC
		mov	al,9
		out	70h,al		;//Selecciona Registro de A�o
		in	al,71h		;//lee el a�o desde el registro
		mov	dh,al
		
		mov	al,8
		out	70h,al		;//Selecciona Registro de Mes
		in	al,71h		;//lee el mes desde el registro
		mov	dl,al
		
		mov	al,7
		out	70h,al		;//Selecciona Registro de Fecha
		in	al,71h		;//lee la Fecha del mes desde el registro
		mov	ah,al
		
		mov	al,6
		out	70h,al		;//Selecciona Registro de D�a 
		in	al,71h		;/lee el d�a de la semana desde el registro
		
		ret

;/**
;--------------------------------
;\fn RTC_disponible
;\brief Verifica en el Status Register A que el RTC no est� actualizando fecha y hora. Retorna cuando el RTC est� disponible.
;\args : Nada
;\return: Nada
;\author Alejandro Furfaro afurfaro@electron.frba.utn.edu.ar
;\date 2012-07-05
;--------------------------------

RTC_disponible:
		mov	al,0Ah
		out	70h,al	;//Selecciona registro de status A
wait_for_free:
		in	al,71h	;//lee Status
		test	al,80h	;//El bit 7 indica si est� en 1 que el RTC se est� actualizando
		jnz	wait_for_free
		ret
