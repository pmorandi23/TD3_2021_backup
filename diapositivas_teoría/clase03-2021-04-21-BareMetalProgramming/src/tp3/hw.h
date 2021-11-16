;/**
;*\file hw.h
;*\brief Header para hw.asm
;*\details Aquí vamos a definir macros y demás entidades de uso en hw.asm
;*\author Alejandro Furfaro afurfaro@electron.frba.utn.edu.ar
;*\date 2019-04-10
;*/

%define     _8042_PORT_A		0x60	;Puerto A de E/S del 8042
%define     _8042_CONTROL_PORT	0x64	;Puerto de Estado del 8042
%define     _8042_KEYB_DISABLE	0xAD	;Deshabilita teclado con Command Byte
%define     _8042_KEYB_ENABLE	0xAE	;Habilita teclado con Command Byte
%define     READ_8042_OUT_PORT	0xD0	;Copia en 0x60 el estado de OUT
%define     WRITE_8042_OUT_PORT	0xD1	;Escribe en OUT lo almacenado en 0x60
%define		_8042_OUT_BUF_FULL	0x01	;Buffer de salida del 8042 está lleno
										;Debe ser '1' antes de leer 0x60
%define		_8042_IN_BUF_FULL	0x02	;Buffer de entrada del 8042 está lleno
										;Debe ser '0' antes de escribir 0x60
										;o 0x64