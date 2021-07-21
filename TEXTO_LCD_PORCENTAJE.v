// --------------------------------------------------------------------
// Universitat Politècnica de València
// Departamento de Ingeniería Electronica
// --------------------------------------------------------------------
// Sistemas Digitales Programables - MUISE
// Curso 2020 - 2021
// --------------------------------------------------------------------
// Práctica 5
// --------------------------------------------------------------------
// Nombre del archivo: TEXTO_LCD_PORCENTAJE.v
//
// Descripción: Convierte el valor del ciclo de trabajo (de 0 a 100),
//   en un texto en la pantalla, con símbolo de porcentaje al final. 
//   Los ceros a la izquierda no son mostrados.
//
// --------------------------------------------------------------------
// Versión: V1.0 | Fecha Modificación: 08/02/2021
//
// Autores: Pablo Roig Monzón y Ángel Bellver Valera
// Ordenador de trabajo: Home y PC 8
// --------------------------------------------------------------------

module TEXTO_LCD_PORCENTAJE(NCLK, fila, columna, porcentaje, letra_ON);

`include "MathFun.vh"

// parámetros de la pantalla, *zona visible*
parameter col_max_pantalla  = 800;
parameter fila_max_pantalla = 480;
// número de bits de:
parameter n_col = CLogB2(col_max_pantalla - 1); // columnas
parameter n_fil = CLogB2(fila_max_pantalla - 1); // filas

//-------------------------ENTRADAS------------------------------------
input [6:0] porcentaje;
input [n_col-1:0] columna;
input [n_fil-1:0] fila;
input NCLK; // entrada de reloj desde LCD_SYNC

//-------------------------SALIDAS-------------------------------------
output letra_ON;

//-------------------------WIRES---------------------------------------
// caracter a obtener de la ROM (valor entre 0 y 64)
wire [5:0] caracter; // ej. caracter = 6'o_44;

// digito actual del porcentaje en base a la columna actual
wire [3:0] digito_actual; // 0-9, 10 es el %, 11 es un espacio

// activar letra solo en zona de caracter
wire fila_caracter_ON;
wire col_caracter_ON;

// columna y fila referidas al caracter actual
wire [n_col-1:0] col_actual;
wire [n_fil-1:0] fila_actual;

// wire de rom a multiplexor
wire [7:0] datos_ROM;

//------------------------PARAMETROS-----------------------------------
parameter ubicacion_vertical_texto = 0.2; // 0 a 1, indica posición en la pantalla

// tamaño caracter = 8 px * 2^potencia_tamanyo
parameter potencia_tamanyo = 2;      // 0 = 8px, 1 = 16 px, 2 = 32 px, 3 = 64 px
parameter multiplicador_tamanyo = 2 ** potencia_tamanyo;

//------------------------SUBMODULOS-----------------------------------
// 1. Convertir el valor actual de PWM al caracter necesario
porcentaje_a_caracter porcentaje_a_caracter_inst
(
	.columna(columna) ,	                // input [n_col-1:0] columna
    .fila(fila) ,                       // input [n_fil-1:0] fila
	.porcentaje(porcentaje) ,	        // input [7:0] porcentaje
	.digito_actual() ,	                // output [3:0] digito_actual
	.col_caracter_ON(col_caracter_ON) ,	// output  col_caracter_ON
	.fila_caracter_ON(fila_caracter_ON),// output  fila_caracter_ON
	.caracter(caracter) ,	            // output [5:0] caracter
    .col_actual(col_actual) ,           // output [n_col-1:0] col_actual
    .fila_actual(fila_actual)           // output [n_fil-1:0] fila_actual
);
defparam porcentaje_a_caracter_inst.col_max_pantalla = col_max_pantalla;
defparam porcentaje_a_caracter_inst.fila_max_pantalla = fila_max_pantalla;
defparam porcentaje_a_caracter_inst.potencia_tamanyo = potencia_tamanyo; // 0 = 8px, 1 = 16 px, 2 = 32 px, 3 = 64 px
defparam porcentaje_a_caracter_inst.ubicacion_vertical_texto = ubicacion_vertical_texto;

// 2. Memoria ROM con los caracteres
ROM_caracteres	ROM_caracteres_inst
(
    .address ( {caracter, fila_actual[2+potencia_tamanyo : potencia_tamanyo]} ), // en base al tamanyo
    .clock ( NCLK ),
    .q ( datos_ROM )
);

//------------------------COMBINACIONALES------------------------------
// multiplexor
assign letra_ON = (fila_caracter_ON && col_caracter_ON)? // solo si estamos en la zona del caracter
                   datos_ROM[7-col_actual[2+potencia_tamanyo : potencia_tamanyo]] // en base al tamanyo
                   : 0;

endmodule
