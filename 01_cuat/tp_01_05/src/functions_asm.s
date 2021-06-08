SECTION .functions_asm
;---------------INCLUDES-----------------
%include "inc/functions_asm.h"
;---------------EXTERN-------------------
EXTERN determinar_tecla_presionada
;---------------GLOBAL-------------------
GLOBAL handler_teclado
GLOBAL init_pic

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
  
;-------------------HANDLER DEL TECLADO DESDE LA IRQ----------------------
handler_teclado:
    ;xchg    bx, bx                        ; Breakpoint
    pushad
    xor     eax, eax
    in      al, CTRL_PORT_8042             ; Leo el puerto 0x64 (Keyboard Controller Status Register)
    and     al, 0x01                      ; Hago un AND para obtener el bit 0 (Output buffer status)
    cmp     al, 0x01                      ; Si el bit vale 1 el buffer de salida esta lleno (se puede leer)
    jnz     end_handler_teclado           ; Si está vacío me voy. Si hay algo, lo leo.
    ; ->Leo el puerto
    in      al, PORT_A_8042           ; Leo el puerto 0x60 (Keyboard Output Buffer Register)
    mov     bl, al                        ; Copio lo leído en otro registro
    and     bl, 0x80                      ; Hago un AND para obtener el bit 7 (BRK)
    cmp     bl, 0x80                      ; Si el bit vale 0 la tecla fue presionada (Make), si es 1 se dejó de presionar (Break)
    jz      end_handler_teclado           ; Si la tecla fue presionada me voy (detecto solo cuando se suelta)
    push    eax                           ; Le paso como argumento a la funcion la tecla presionada.
    call determinar_tecla_presionada
end_handler_teclado:
    popad
    ret                                   ; Vuelvo
