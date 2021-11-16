section .data
   msg:  DB 'Hola Mundo! 0', 10
   largo EQU $ - msg
global _start
section .text
_start:
   xor esi, esi
ciclo:
   mov rax, 4     ; rax: Nro. de función (syscall). 4: Write
   mov rbx, 1     ; rbx: FIle Descriptor. 1: stdout
   mov rcx, msg   ; rcx: Puntero al Mensaje
   mov rdx, largo ; rdx: Longitud del mensaje (no incluye '\0')
   int 0x80
   inc byte [msg+largo-2]
   inc esi
   cmp esi, 10
   jnz ciclo

   mov rax, 1
   mov rbx, 0
   int 0x80
