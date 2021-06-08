USE32
;----------------GLOBAL--------------------
EXTERN DS_SEL_32
EXTERN CS_SEL_32
EXTERN __TECLADO_ISR_VMA
EXTERN handler_teclado
;----------------EXTERN--------------------
GLOBAL L_ISR00_Handler_DE
GLOBAL L_ISR02_Handler_NMI
GLOBAL L_ISR03_Handler_BP
GLOBAL L_ISR04_Handler_OF
GLOBAL L_ISR05_Handler_BR
GLOBAL L_ISR06_Handler_UD
GLOBAL L_ISR07_Handler_NM
GLOBAL L_ISR08_Handler_DF
GLOBAL L_ISR10_Handler_TS
GLOBAL L_ISR11_Handler_NP
GLOBAL L_ISR12_Handler_SS
GLOBAL L_ISR13_Handler_GP
GLOBAL L_ISR14_Handler_PF
GLOBAL L_ISR16_Handler_MF
GLOBAL L_ISR17_Handler_AC
GLOBAL L_ISR18_Handler_MC
GLOBAL L_ISR19_Handler_XM
GLOBAL L_IRQ01_Handler
;----------------EQU--------------------
VMA_ISR_TECLADO     EQU 0x00100000
; Parte baja de las direcciones de los Handlers 
L_ISR00_Handler_DE  EQU ISR00_Handler_DE    - VMA_ISR_TECLADO 
L_ISR01_Handler_DB  EQU ISR01_Handler_DB    - VMA_ISR_TECLADO 
L_ISR02_Handler_NMI EQU ISR02_Handler_NMI   - VMA_ISR_TECLADO 
L_ISR03_Handler_BP  EQU ISR03_Handler_BP    - VMA_ISR_TECLADO 
L_ISR04_Handler_OF  EQU ISR04_Handler_OF    - VMA_ISR_TECLADO 
L_ISR05_Handler_BR  EQU ISR05_Handler_BR    - VMA_ISR_TECLADO 
L_ISR06_Handler_UD  EQU ISR06_Handler_UD    - VMA_ISR_TECLADO 
L_ISR07_Handler_NM  EQU ISR07_Handler_NM    - VMA_ISR_TECLADO 
L_ISR08_Handler_DF  EQU ISR08_Handler_DF    - VMA_ISR_TECLADO   
L_ISR10_Handler_TS  EQU ISR10_Handler_TS    - VMA_ISR_TECLADO 
L_ISR11_Handler_NP  EQU ISR11_Handler_NP    - VMA_ISR_TECLADO 
L_ISR12_Handler_SS  EQU ISR12_Handler_SS    - VMA_ISR_TECLADO 
L_ISR13_Handler_GP  EQU ISR13_Handler_GP    - VMA_ISR_TECLADO 
L_ISR14_Handler_PF  EQU ISR14_Handler_PF    - VMA_ISR_TECLADO 
L_ISR16_Handler_MF  EQU ISR16_Handler_MF    - VMA_ISR_TECLADO 
L_ISR17_Handler_AC  EQU ISR17_Handler_AC    - VMA_ISR_TECLADO 
L_ISR18_Handler_MC  EQU ISR18_Handler_MC    - VMA_ISR_TECLADO 
L_ISR19_Handler_XM  EQU ISR19_Handler_XM    - VMA_ISR_TECLADO 
L_IRQ01_Handler     EQU IRQ01_Handler       - VMA_ISR_TECLADO

;----------------SECTION-----------------------
SECTION .teclado_and_ISR
;----------HANDLER IRQ TECLADO-----------------
IRQ01_Handler:
    ;xchg    bx, bx                      ; Breakpoint
    pushad                              ; Guardo todos los registros  para asegurarme que no se rompa el estado actual.
    mov     dl,0x21                     ; Guardo la interrupcion en el registro DX
    call    handler_teclado             ; Voy a leer el puerto y analizar tecla presionada.
    mov     al, 0x20                    ; ACK de la IRQ para el PIC 
    out     0x20, al
    popad                               ; Recupero registros
    iret                                ; Retorno de la IRQ

;-----------HANDLERs DE EXCEPTIONS-------------
;#DE (Divide Error)
ISR00_Handler_DE:
    xchg    bx,bx
    mov     dl,0x00
    iret

ISR01_Handler_DB:
    mov dl,0x01
    hlt

ISR02_Handler_NMI:
    mov dl,0x02
    hlt

ISR03_Handler_BP:
    mov dl,0x03
    hlt

ISR04_Handler_OF:
    mov dl,0x04
    hlt

ISR05_Handler_BR:
    mov dl,0x05
    hlt
;#UD (Invalid Opcode Fetch) 
ISR06_Handler_UD:
    xchg    bx,bx
    mov dl,0x06
    hlt

ISR07_Handler_NM:
    mov dl,0x07
    hlt

ISR08_Handler_DF:
    mov dl,0x08
    hlt

ISR10_Handler_TS:
    mov dl,0x0A
    hlt

ISR11_Handler_NP:
    mov dl,0x0B
    hlt

ISR12_Handler_SS:
    mov dl,0x0C
    hlt

ISR13_Handler_GP:
    mov dl,0x0D
    hlt
    iret

ISR14_Handler_PF:
    mov dl,0x0E
    hlt

ISR15_Handler_RES:
    mov dl,0x0F
    hlt

ISR16_Handler_MF:
    mov dl,0x10
    hlt

ISR17_Handler_AC:
    mov dl,0x11
    hlt

ISR18_Handler_MC:
    mov dl,0x12
    hlt

ISR19_Handler_XM:
    mov dl,0x13
    hlt
