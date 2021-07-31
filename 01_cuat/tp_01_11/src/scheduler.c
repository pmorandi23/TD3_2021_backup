#include "../inc/scheduler.h"

__attribute__(( section(".data_kernel"))) 
byte tarea_RUNNING = TAREA_4;       // Inicialmente estoy en la Tarea 4 haciendo HLT
byte tarea_READY = TAREA_4;         // Inicialmente estoy en la Tarea 4 haciendo HLT
byte tarea_SUSPENDING = TAREA_4;    // Inicialmente estoy en la Tarea 4 haciendo HLT
byte time_frame_100ms = 0;
byte time_frame_10ms = 0;
byte primer_context_save = 1;  //Primera vez que se guarda un contexto

/* Función que cuenta las veces que interrumpe el timer y resetea el contador si se va de rango. */
__attribute__(( section(".functions_c"))) 
void scheduler_c (dword* contador)
{ 
    // Base de tiempo

    //asm("xchg %bx,%bx");

    // Sumo al contador del Time Frame. Primera vez = Primeros 10ms
    *contador = *contador + 1;
    if ( *contador > 0)
    {   *contador = 0;                  // Reinicio contador.
        time_frame_10ms ++;

            //asm("xchg %bx,%bx");

        if (time_frame_10ms > 9)
        {
            //asm("xchg %bx,%bx");

            time_frame_100ms ++;        // Sumo al Time Frame
            time_frame_10ms = 0;        // Reinicio Time Frame de 10ms
            if (time_frame_100ms > 5)
            {
                time_frame_100ms = 0;   // Reinicio Time Frame de 100ms
            }
        }  
    }

    // Determino los estados de las tareas
    // Si pasaron 100ms o mas, corren tareas 1, 2 y 3
    if (time_frame_100ms > 0)
    {

        /* Tarea 1 - Promedio de dígitos en tabla y muestra en pantalla- 500ms (10msx50) */
        if ( time_frame_100ms > 4 && tarea_RUNNING != TAREA_1)
        {
            //Suspendo tarea que esta corriendo actualmente. Su contexto debe ser guardado
            tarea_SUSPENDING = tarea_RUNNING;
            // Asigno próxima tarea a ejecutarse. Debo leer su contexto de memoria y asignarselo a la TSS_BASICA del CPU.
            tarea_READY = TAREA_1;
        }
    
        /* Tarea 2 - Suma de dígitos dentro de la tabla - 100ms (10msx10) */
        if ( time_frame_100ms > 0 && tarea_RUNNING != TAREA_2)
        {
            
            //Suspendo tarea que esta corriendo actualmente. Su contexto debe ser guardado
            tarea_SUSPENDING = tarea_RUNNING;
            // Asigno próxima tarea a ejecutarse. Debo leer su contexto de memoria y asignarselo a la TSS_BASICA del CPU.
            tarea_READY = TAREA_2;
        }

        /* Tarea 3 - Suma de dígitos dentro de la tabla - 200ms (10msx20) */
        if ( time_frame_100ms > 1 && tarea_RUNNING != TAREA_3)
        {
            //asm("xchg %bx,%bx");
            if (primer_context_save)
            {
                primer_context_save = 0; // Apago flag de primer guardado de contexto para habilitar guardar el stack de nivel 3 en asm
            }
            //Suspendo tarea que esta corriendo actualmente. Su contexto debe ser guardado
            tarea_SUSPENDING = tarea_RUNNING;
            // Asigno próxima tarea a ejecutarse. Debo leer su contexto de memoria y asignarselo a la TSS_BASICA del CPU.
            tarea_READY = TAREA_3;
        }
    }
    else
    {
        if ( tarea_RUNNING != TAREA_4)
        {   
            // Suspendo tarea que esta corriendo actualmente. Su contexto debe ser guardado
            tarea_SUSPENDING = tarea_RUNNING;
            // Asigno próxima tarea a ejecutarse. Debo leer su contexto de memoria y asignarselo a la TSS_BASICA del CPU.
            tarea_READY = TAREA_4;
            
        } 
    }
    return;
}

__attribute__(( section(".functions_c"))) 
void determinar_TSS_a_leer(byte* tarea_siguiente)
{
    if (*tarea_siguiente == TAREA_1)
    {
        TSS_aux = (dword*)&__TSS1_VMA;
        CR3_aux = (dword*)&__CR3_TAREA_1_PHY;
    }
    if (*tarea_siguiente == TAREA_2)
    {
        TSS_aux = (dword*)&__TSS2_VMA;
        CR3_aux = (dword*)&__CR3_TAREA_2_PHY;
    }
    if (*tarea_siguiente == TAREA_3)
    {
        TSS_aux = (dword*)&__TSS3_VMA;
        CR3_aux = (dword*)&__CR3_TAREA_3_PHY;
    }
    if (*tarea_siguiente == TAREA_4)
    {
        //asm("xchg %bx,%bx");
        TSS_aux = (dword*)&__TSS4_VMA;
        CR3_aux = (dword*)&__CR3_TAREA_4_PHY;
    }
}

__attribute__(( section(".functions_c"))) 
void determinar_TSS_a_guardar(byte* tarea_actual)
{
    if (*tarea_actual == TAREA_1)
    {
        TSS_aux = (dword*)&__TSS1_VMA;
    }
    if (*tarea_actual == TAREA_2)
    {
        TSS_aux = (dword*)&__TSS2_VMA;
    }
    if (*tarea_actual == TAREA_3)
    {
        TSS_aux = (dword*)&__TSS3_VMA;
    }
    if (*tarea_actual == TAREA_4)
    {
        //asm("xchg %bx,%bx");
        TSS_aux = (dword*)&__TSS4_VMA;
    }
}

