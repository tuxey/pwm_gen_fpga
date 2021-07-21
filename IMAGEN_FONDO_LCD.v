// --------------------------------------------------------------------
// Universitat Politècnica de València
// Departamento de Ingeniería Electronica
// --------------------------------------------------------------------
// Sistemas Digitales Programables - MUISE
// Curso 2020 - 2021
// --------------------------------------------------------------------
// Práctica 5
// --------------------------------------------------------------------
// Nombre del archivo: IMAGEN_FONDO_LCD.v
//
// Descripción: Obtención de una salida que indica si el píxel actual
//   ha de ser encendido o no, con el fin de representar una imagen de
//   fondo generada mediante el conversor de BMP a MIF de Ricardo Colom.
//   Esta imagen está en Blanco y Negro para ahorrar memoria.
//
// --------------------------------------------------------------------
// Versión: V1.0 | Fecha Modificación: 05/02/2021
//
// Autores: Pablo Roig Monzón y Ángel Bellver Valera
// Ordenador de trabajo: Home y PC 8
// --------------------------------------------------------------------

module IMAGEN_FONDO_LCD
(
    CLK, RST_n,
    NCLK, DEN,
	fila, columna,
	fondo_pantalla_ON
);

`include "MathFun.vh"

//------------------------PARAMETROS-----------------------------------
// parámetros de la pantalla, *ZONA VISIBLE*
parameter col_max_pantalla  = 800;
parameter fila_max_pantalla = 480;
// número de bits de:
parameter n_col = CLogB2(col_max_pantalla - 1); // columnas
parameter n_fil = CLogB2(fila_max_pantalla - 1); // filas

parameter color_depth = 1; // black and white

parameter words_rom = (2**n_col) * fila_max_pantalla; // direccionamiento XY
parameter address_bus_bits = CLogB2(words_rom - 1); // para 491520 words -> 19 bits

//-------------------------ENTRADAS------------------------------------
input CLK, RST_n, NCLK, DEN;

input [n_col-1:0] columna;
input [n_fil-1:0] fila;

//-------------------------SALIDAS-------------------------------------
output fondo_pantalla_ON;

//------------------------WIRES----------------------------------------
wire [address_bus_bits-1:0] address_ROM; // cable direccionamiento -> memoria

//------------------------COMBINACIONALES------------------------------
assign address_ROM = (DEN)? {fila, columna} : 0; // concatenar para direccionamiento XY


// --------------------- BLOQUES DEL DISENYO --------------------------
// MEMORIA ROM con la imagen
// cada palabra 1 bit (1 pixel de la imagen, blanco y negro)
ROM_image	ROM_image_inst (
	.address ( address_ROM ),
	.clock ( NCLK ),
	.q ( fondo_pantalla_ON )
);

/*
tamanyo ROM: 2^n x Y
n = ceil(log2(X))

imagen de X=800, Y=480 pixels
n = 10
tamanyo ROM: 2^n*Y = 491520 words, 1 bit cada una 
*/


endmodule
