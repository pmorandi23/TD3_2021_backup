USE16

SECTION .resetVector

EXTERN start16
GLOBAL reset


reset:
    cli
    cld    
    jmp start16
halted:
    hlt 
    jmp halted
    ALIGN 16; Directiva de pre procesador que rellena con operaciones "nop (0x90)" hasta la próxima dirección multiplo de 16bytes 
