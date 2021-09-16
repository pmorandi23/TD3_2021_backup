#include "../inc/main.h"




typedef struct punto_flotante{
    char signo;               // 1 bit
    int exponente;            // 11 bits
    long long int fraccion;   // 52 bits
      
}punto_flotante_t;

// Prototipos de función
int abrir_crear_archivo(FILE** ,char* );
double armo_numero_double_float(FILE** );
double calculo_promedio(double* vector_double_float);

