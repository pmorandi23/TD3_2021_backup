SECTION .functions_asm

%include "inc/processor-flags.h" 

;---------------EXTERN-------------------
EXTERN  DS_SEL_00
EXTERN  CS_SEL_00
EXTERN  DS_SEL_11
EXTERN  CS_SEL_11
EXTERN __TSS_BASICA
EXTERN  TSS_aux
EXTERN  Stack_aux
EXTERN  CR3_aux
EXTERN return_guardar_contexto
EXTERN return_leer_contexto
EXTERN primer_context_save
;--------------GLOBAL-------------------
GLOBAL init_tss
GLOBAL guardar_contexto_asm
GLOBAL leer_contexto_siguiente_asm

init_tss:

; @params
;  eax--->[ esp + 4 ]---> __TSS1_VMA                      ; TSS de la tarea
;  ebx--->[ esp + 8 ]---> __CR3_TAREA_1_PHY               ; CR3 de la tarea
;  ecx--->[ esp + 12 ]---> __TAREA1_STACK_END_VMA         ; STACK de la tarea
;  edx--->[ esp + 16 ]---> __STACK_KERNEL_TAREA1_END_VMA  ; STACK del Kernel
;  esi--->[ esp + 20 ]---> ejecutar_tarea_1               ; Dir. de inicio de la tarea

    ; -> Paso parámetros del stack a los registros.

    ;xchg bx, bx

    ; Flag de TSS de kernel
    mov edi, [ esp + 24 ] 
    ; Base de la TSS
    mov eax, [ esp + 20 ] 
    ;mov [ TSS_aux ], eax              
    ; CR3
    mov ebx, [ esp + 16 ]
    ; Stack user
    mov ecx, [ esp + 12 ]
    ; Stack Kernel 
    mov edx, [ esp + 8 ]
    ; Dir. de inicio de tarea
    mov esi, [ esp + 4 ]

    ; -> Armo la TSS con formato de Intel (podría no haberlo sido para las de las tareas. Si o si para la del CPU)

    ;Previous Task Link 
    mov [eax], dword(0) 
    ;ESP0 - Stack Pointer de Nivel 0
    mov [eax + 4], dword (edx)            ; STACK de Kernel de nivel 0
    ;SS0 - Stack Segment de Nivel 0
    mov [eax + 8], dword(DS_SEL_00)       ; Selector de nivel 0               
    ;ESP1 - Stack Pointer de Nivel 1
    mov [eax + 12], dword(0) 
    ;SS1 - Stack Segment de Nivel 1
    mov [eax + 16], dword(0) 
    ;ESP2 - Stack Pointer de Nivel 2
    mov [eax + 20], dword(ecx)            ; Stack de nivel 3
    ;SS2 - Stack Segment de Nivel 2
    mov [eax + 24], dword(DS_SEL_11 + 3)  ; Selector de datos de nivel 3
    ;CR3 - Control Register 3
    mov [eax + 28], (ebx)                 ; CR3 de la tarea
    ;EIP - Instruction Pointer
    mov [eax + 32], (esi)                 ; Dir. de inicio de la tarea
    ;EFLAGS - Status Flags
    mov [eax + 36], dword(0x202) 
    ;EAX 
    mov [eax + 40], dword(0) 
    ;ECX
    mov [eax + 44], dword(0) 
    ;EDX
    mov [eax + 48], dword(0) 
    ;EBX
    mov [eax + 52], dword(0) 
    ;ESP
    mov [eax + 56], (ecx)               ; STACK de la tarea
    ;EBP
    mov [eax + 60], (ecx)               ; STACK de la tarea 
    ;ESI
    mov [eax + 64], dword(0) 
    ;EDI
    mov [eax + 68], dword(0) 

    cmp edi, flag_TSS_sup
    je tss_nivel_0

tss_nivel_3:
    ;ES 
    mov [eax + 72], dword(DS_SEL_11 + 3)    ; Selector de nivel 3 con RPL = 3
    ;CS 
    mov [eax + 76], dword(CS_SEL_11 + 3)    ; Selector de nivel 3 con RPL = 3
    ;SS 
    mov [eax + 80], dword(DS_SEL_11 + 3)    ; Selector de nivel 3 con RPL = 3
    ;DS 
    mov [eax + 84], dword(DS_SEL_11 + 3)    ; Selector de nivel 3 con RPL = 3
    ;FS 
    mov [eax + 88], dword(DS_SEL_11 + 3)    ; Selector de nivel 3 con RPL = 3
    ;GS 
    mov [eax + 92], dword(DS_SEL_11 + 3)    ; Selector de nivel 3 con RPL = 3

    jmp fin_init_tss
tss_nivel_0:
    ;ES 
    mov [eax + 72], dword(DS_SEL_00)    ; Selector de nivel 3
    ;CS 
    mov [eax + 76], dword(CS_SEL_00)    ; Selector de nivel 3
    ;SS 
    mov [eax + 80], dword(DS_SEL_00)    ; Selector de nivel 3
    ;DS 
    mov [eax + 84], dword(DS_SEL_00)    ; Selector de nivel 3
    ;FS 
    mov [eax + 88], dword(DS_SEL_00)    ; Selector de nivel 3
    ;GS 
    mov [eax + 92], dword(DS_SEL_00)    ; Selector de nivel 3
    

fin_init_tss:

    ;LDTR
    mov [eax + 96], dword(0) 
    ;Bitmap E/S
    mov [eax + 100], dword(0)

    ret
    
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;CONTEXT SWITCH;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ; Función que lee de memoria el contexto de registros para la tarea próxima a ejecutarse.
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
leer_contexto_siguiente_asm:

    ;xchg bx, bx
  
    ; CR3 de la próxima tarea
    mov eax, [CR3_aux]
    mov cr3, eax

    ;Cargo los registros de segmento
    mov eax, [TSS_aux]         
    mov es, [eax + 0x48]            ;Recupero es     
    mov ds, [eax + 0x54]            ;Recupero ds   
    mov fs, [eax + 0x58]            ;Recupero fs   
    mov gs, [eax + 0x5C]            ;Recupero gs    
    
    ; Stack de nivel 0 de la tarea

    mov ebx, [eax + 0x04]           ;Recupero ESP0
    mov [Stack_aux], ebx
    mov ebx, [eax + 0x08]           ;Recupero SS0
    mov [Stack_aux + 4], ebx

    ;LSS --> load stack segment
    lss esp, [Stack_aux]

    ; Cargo Stack de nivel 3 de la tarea
    mov ebx, [eax + 0x18]      ;Recupero SS2
    push ebx
    mov ebx, [eax + 0x14]      ;Recupero ESP2
    push ebx
    mov ebx, [eax + 0x24]      ;Recupero EFLAGS
    push ebx
    mov ebx, [eax + 0x4C]      ;Recupero CS
    push ebx
    mov ebx, [eax + 0x20]      ;Recupero EIP
    push ebx

    ;Registros de Proposito general
    mov ecx, [eax + 0x2C]
    mov edx, [eax + 0x30]
    mov ebx, [eax + 0x34]       
    mov esi, [eax + 0x40]
    mov edi, [eax + 0x44]
    mov eax, [eax + 0x28]     ; Debe estar último

    ; Cargo la TSS
    push dword [TSS_aux]
    call cargar_TSS_CPU
    add esp,4

    jmp return_leer_contexto

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;CONTEXT SAVE;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ; Función que guarda en memoria el contexto de registros de la tarea que es suspendida.
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
guardar_contexto_asm:

    ;xchg bx, bx
    ; Recupero de la pila los registros generales
    popad
    ;Registros Generales
    mov [TSS_aux + 40],   eax      ;Guardo EAX
    mov [TSS_aux + 44],   ecx      ;Guardo ECX
    mov [TSS_aux + 48],   edx      ;Guardo EDX
    mov [TSS_aux + 52],   ebx      ;Guardo EBX
    ;mov [TSS_aux + 56],  esp      ;Guardo ESP
    mov [TSS_aux + 60],   ebp      ;Guardo EBP 
    mov [TSS_aux + 64],   esi      ;Guardo ESI
    mov [TSS_aux + 68],   edi      ;Guardo EDI 
    ;Registros de Segmento
    mov [TSS_aux + 72],   es       ;Guardo ES
    ;mov [TSS_aux + 76],  cs        ;Guardo CS        
    ;mov [TSS_aux + 80],  ss      ;Guardo SS
    mov [TSS_aux + 84],   ds       ;Guardo DS   
    mov [TSS_aux + 88],   fs       ;Guardo FS       
    mov [TSS_aux + 92],   gs       ;Guardo GS    
    mov eax, cr3                  ;Guardo CR3
    mov [TSS_aux + 28],   eax 
    ;Registros del Stack

    cmp byte[primer_context_save], 1
    je no_guardo_stack_user

    ;xchg bx, bx
    pop eax                             
    ;mov eax, [esp + 12]                ;Guardo EIP
    mov [TSS_aux + 32],   eax  
    pop eax
    ;mov eax, [esp + 20]                ;Guardo EFLAGS
    mov [TSS_aux + 36],   eax  
    pop eax                             ;Guardo ESP2      
    mov [TSS_aux + 20],   eax
    pop eax                             ;Guardo SS2      
    mov [TSS_aux + 24],   eax

    jmp fin_guardar_contexto

no_guardo_stack_user:

    ;xchg bx, bx

    mov eax, [esp]
    mov [TSS_aux + 32],   eax      ; Guardo EIP
    mov eax, [ esp + 4 ]
    mov [TSS_aux + 76],   eax      ; Guardo CS
    mov eax, [ esp + 8 ]
    mov [TSS_aux + 36],   eax      ; Guardo EFLAGS
    mov [TSS_aux + 8],    ss       ; Guardo SS0
    mov [TSS_aux + 4],    esp      ; Guardo ESP0 

fin_guardar_contexto:
    jmp return_guardar_contexto

        
cargar_TSS_CPU:

    mov ebx, [esp + 4]
    ;backlink
    mov eax, [ebx]

    mov [__TSS_BASICA], eax 
    ;ESP0
    mov eax, [ebx+0x04]
    mov [__TSS_BASICA+0x04], eax
    ;SS0
    mov eax, [ebx+0x08]
    mov [__TSS_BASICA+0x08], eax
    ;ESP1
    mov eax, [ebx+0x0C]
    mov [__TSS_BASICA+0x0C], eax 
    ;SS1
    mov eax, [ebx+0x10]
    mov [__TSS_BASICA+0x10], eax
    ;ESP2
    mov eax, [ebx+0x14]
    mov [__TSS_BASICA+0x14], eax 
    ;SS2
    mov eax, [ebx+0x18]
    mov [__TSS_BASICA+0x18], eax 
    ;CR3
    mov eax, [ebx+0x1C]
    mov [__TSS_BASICA+0x1C], eax
    ;EIP
    mov eax, [ebx+0x20]
    mov [__TSS_BASICA+0x20], eax 
    ;EFLAGS
    mov eax, [ebx+0x24]
    mov [__TSS_BASICA+0x24], eax 
    ;EAX
    mov eax, [ebx+0x28]
    mov [__TSS_BASICA+0x28], eax 
    ;ECX
    mov eax, [ebx+0x2C]
    mov [__TSS_BASICA+0x2C], eax 
    ;EDX
    mov eax, [ebx+0x30]
    mov [__TSS_BASICA+0x30], eax 
    ;EBX
    mov eax, [ebx+0x34]
    mov [__TSS_BASICA+0x34], eax 
    ;ESP
    mov eax, [ebx+0x38]
    mov [__TSS_BASICA+0x38], eax
    ;EBP
    mov eax, [ebx+0x3C]
    mov [__TSS_BASICA+0x3C], eax
    ;ESI
    mov eax, [ebx+0x40]
    mov [__TSS_BASICA+0x40], eax
    ;EDI
    mov eax, [ebx+0x44]
    mov [__TSS_BASICA+0x44], eax
    ;ES
    mov eax, [ebx+0x48]
    mov [__TSS_BASICA+0x48], eax
    ;CS
    mov eax, [ebx+0x4C]
    mov [__TSS_BASICA+0x4C], eax
    ;SS
    mov eax, [ebx+0x50]
    mov [__TSS_BASICA+0x50], eax
    ;DS
    mov eax, [ebx+0x54]
    mov [__TSS_BASICA+0x54], eax
    ;FS
    mov eax, [ebx+0x58]
    mov [__TSS_BASICA+0x58], eax
    ;GS
    mov eax, [ebx+0x5C]
    mov [__TSS_BASICA+0x5C], eax
    ;LDTR
    mov eax, [ebx+0x60]
    mov [__TSS_BASICA+0x60], eax
    ;Bitmap E/S
    mov eax, [ebx+0x64]
    mov [__TSS_BASICA+0x64], eax

    ret