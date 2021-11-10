#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <errno.h>
#include <fcntl.h>
#include <stdint.h>
#include <math.h>
#include <signal.h>
#include <stdbool.h>
#include <sys/wait.h>
#include <sys/ipc.h>
#include <sys/shm.h>
#include <sys/sem.h>
#include <sys/stat.h>
#include <sys/select.h>
#include <sys/sendfile.h>
#include "../inc/serverTCP.h"
#include "../inc/meanFilterMPU6050.h"

struct MPU6050_REGS filtro_MPU6050(uint8_t * _dataMPU6050_fifo, int _MPU6050fifoPacketsForMeanFilter, int _bytesToReadFromMPU6050FIFO)
{
    int16_t aux16Bits;
    int i = 0;
    volatile struct MPU6050_REGS _dataSensorAvg = {0};


    // FILTRO DE MEDIA : segun el valor de la ventana, sumar las N mediciones y dividir por N.
    while (i < _bytesToReadFromMPU6050FIFO)
    {
        aux16Bits = (int16_t)(_dataMPU6050_fifo[i] << 8 | _dataMPU6050_fifo[i + 1]);
        _dataSensorAvg.accel_xout += (float)aux16Bits * 2 / 32768 - 0.020;
        //auxFloat += (float)aux16Bits * 2 / 32768;
        //_dataSensorAvg.accel_xout = auxFloat / _MPU6050fifoPacketsForMeanFilter;

        aux16Bits = (int16_t)(_dataMPU6050_fifo[i + 2] << 8 | _dataMPU6050_fifo[i + 3]);
        _dataSensorAvg.accel_yout += (float)aux16Bits * 2 / 32768 + 0.060;

        aux16Bits = (int16_t)(_dataMPU6050_fifo[i + 4] << 8 | _dataMPU6050_fifo[i + 5]);
        _dataSensorAvg.accel_zout += (float)aux16Bits * 2 / 32768 - 0.05;

        //TEMPERATURE
        aux16Bits = (int16_t)(_dataMPU6050_fifo[i + 6] << 8 | _dataMPU6050_fifo[i + 7]);
        _dataSensorAvg.temp_out_float += (float)aux16Bits / 340 + 36.53;

        // GYRO
        aux16Bits = (int16_t)(_dataMPU6050_fifo[i + 8] << 8 | _dataMPU6050_fifo[i + 9]);
        _dataSensorAvg.gyro_xout += (float)aux16Bits * 250 / 32768 - 4.75;

        aux16Bits = (int16_t)(_dataMPU6050_fifo[i + 10] << 8 | _dataMPU6050_fifo[i + 11]);
        _dataSensorAvg.gyro_yout += (float)aux16Bits * 250 / 32768 - 2.5;

        aux16Bits = (int16_t)(_dataMPU6050_fifo[i + 12] << 8 | _dataMPU6050_fifo[i + 13]);
        _dataSensorAvg.gyro_zout += (float)aux16Bits * 250 / 32768 - 0.6;
        i += 14;
    }
    // Calculo promedios
    _dataSensorAvg.accel_xout = _dataSensorAvg.accel_xout / _MPU6050fifoPacketsForMeanFilter;
    _dataSensorAvg.accel_yout = _dataSensorAvg.accel_yout / _MPU6050fifoPacketsForMeanFilter;
    _dataSensorAvg.accel_zout = _dataSensorAvg.accel_zout / _MPU6050fifoPacketsForMeanFilter;
    _dataSensorAvg.temp_out_float = _dataSensorAvg.temp_out_float / _MPU6050fifoPacketsForMeanFilter;
    _dataSensorAvg.gyro_xout = _dataSensorAvg.gyro_xout / _MPU6050fifoPacketsForMeanFilter;
    _dataSensorAvg.gyro_yout = _dataSensorAvg.gyro_yout / _MPU6050fifoPacketsForMeanFilter;
    _dataSensorAvg.gyro_zout = _dataSensorAvg.gyro_zout / _MPU6050fifoPacketsForMeanFilter;

    return _dataSensorAvg;
}