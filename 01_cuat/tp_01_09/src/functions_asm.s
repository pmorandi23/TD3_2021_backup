SECTION .functions_asm_rom
;---------------INCLUDES-----------------
%include "inc/functions_asm.h"
;---------------EXTERN-------------------

;---------------GLOBAL-------------------
GLOBAL handler_teclado
GLOBAL init_pic
GLOBAL init_timer
GLOBAL init_teclado

;--------------INIT DE PICS E INTERRUPCIONES DEL 8042----------------
;	Funcion: 	Inicializa el pic en cascada y le asigna el rango de tipo de interrupcion de 0x20 a 0x27 
;				y de 0x28 a 0x2F respectivamente.
;				PIC: Programable Interrupt Controller
;------------------------------------------------------------------------------------------------------------
init_pic:
;// Inicialización PIC N°1
  ;//ICW1: Initialization Control Word
  mov     al,0x11   ;//Establece IRQs activas x flanco, Modo cascada, e ICW4
  out     0x20,al
  ;//ICW2:
  mov     al,0x20   ;//Establece para el PIC#1 el valor base del Tipo de INT que recibi� en el registro BH = 0x20
  out     0x21,al
  ;//ICW3:
  mov     al,0x04   ;//Establece PIC#1 como Master, e indica que un PIC Slave cuya Interrupci�n ingresa por IRQ2
  out     0x21,al
  ;//ICW4
  mov     al,0x01   ;// Establece al PIC en Modo 8086
  out     0x21,al
;//Antes de inicializar el PIC N�2, deshabilitamos las Interrupciones del PIC1
  mov     al,0xFD   ;0x11111101
  out     0x21,al
;//Ahora inicializamos el PIC N�2
  ;//ICW1
  mov     al,0x11   ;//Establece IRQs activas x flanco, Modo cascada, e ICW4
  out     0xA0,al
  ;//ICW2
  mov     al,0x28    ;//Establece para el PIC#2 el valor base del Tipo de INT que recibi� en el registro BL = 0x28
  out     0xA1,al
  ;//ICW3
  mov     al,0x02   ;//Establece al PIC#2 como Slave, y le indca que ingresa su Interrupci�n al Master por IRQ2
  out     0xA1,al
  ;//ICW4
  mov     al,0x01   ;// Establece al PIC en Modo 8086
  out     0xA1,al
;Enmascaramos el resto de las Interrupciones (las del PIC#2)
  mov     al,0xFF
  out     0xA1,al
; Habilitamos la interrupcion del timer y teclado.
  mov     al,0xFC   ;0x11111100
  out     0x21,al
  ret

; Inicializar timer para que interrumpa cada 10 milisegundos.
init_timer:
  mov al,0x36         ; Canal cero. 
  out 0x43,al         ; Le escribo al PIT
  mov ax,11932        ; Dividir 11932 Hz . Tick cada 10ms (99,998Hz)
  out 0x40, al        ; Programar byte bajo del timer de 16 bits. 
  mov al, ah          
  out 0x40,al         ; Programar byte alto del timer de 16 bits.         
  ret

init_teclado:
; Inicializar controlador de teclado.
    MOV al, 0xFF         ;Enviar comando de reset al controlador
    OUT 0x64, al         ;de teclado
    MOV ecx, 256         ;Esperar que rearranque el controlador.
    LOOP $
    MOV ecx, 0x10000
ciclo1:
    IN al, 0x60          ;Esperar que termine el reset del controlador.
    TEST al, 1
    LOOPZ ciclo1
    MOV al, 0xF4         ;Habilitar el teclado.
    OUT 0x64, al
    MOV ecx, 0x10000
ciclo2:
    IN al, 0x60          ;Esperar que termine el comando.
    TEST al, 1
    LOOPZ  ciclo2
    IN al, 0x60          ;Vaciar el buffer de teclado.
    ret