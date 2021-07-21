// --------------------------------------------------------------------
// Universitat Politècnica de València
// Departamento de Ingeniería Electronica
// --------------------------------------------------------------------
// Sistemas Digitales Programables - MUISE
// Curso 2020 - 2021
// --------------------------------------------------------------------
// Práctica 3
// --------------------------------------------------------------------
// Nombre del archivo: LCD_SYNC.v
//
// Descripción: este módulo genera las señales de sincronismo y salida
// necesarias para controlar una pantalla LCD de 800x480 píxeles.
//
// 	Inputs:
//		CLK_50:	Señal de reloj de 50 MHz
//		RST_n:	Reset asíncrono activo a nivel bajo
//
//  Outputs:
//	   NCLK:	Clock de 25 MHz generado por un PLL a partir de CLK_50
//	   GREST:	Reset global de la pantalla LCD
//	   HD:		Señal de sincronismo horizontal;
//				se activa a nivel bajo durante 1 periodo de NCLK
//				al llegar la cuenta horizontal al final de la zona
//				visible de la pantalla
//	   VD:		Señal de sincronismo vertical;
//				se activa a nivel bajo durante 1 periodo de NCLK
//				al llegar la cuenta vertical al final de la zona
//				visible de la pantalla
//	   DEN:		Señal de habilitación de la visualización en pantalla;
//				activa siempre que la cuenta de columnas y filas esté
//				dentro de la zona visible de la pantalla
//	   columna: Valor de la columna del píxel representado en cada momento
//	   fila:	Valor de la fila del píxel representado en cada momento
//
//
//                 columna →
// 	  (0,0) ____________________________ 
// 		   |                            |
// 		   |                            |
// 	  fila |                            |
// 		↓  |                            |
// 		   |                            |
// 		   |____________________________|
//										 (480,800) (fila,columna)
// --------------------------------------------------------------------
// Versión: V1.1 | Fecha Modificación: 19/11/2020
//
// Autores: Pablo Roig Monzón y Ángel Bellver Valera
// Ordenador de trabajo: 10 y 11
// --------------------------------------------------------------------

module LCD_SYNC (
    CLK_50, RST_n,NCLK, GREST, HD, DEN, VD, columna, fila
);

`include "MathFun.vh"

// parámetros de la pantalla
parameter fin_cuenta_H = 1056;
parameter fin_cuenta_V = 525;
// número de bits de:
parameter n_H = CLogB2(fin_cuenta_H - 1); // columnas
parameter n_V = CLogB2(fin_cuenta_V - 1); // filas
// buses output de columnas y filas
output [n_H-1:0] columna;
output [n_V-1:0] fila;

// entradas y salidas de 1 bit
input CLK_50, RST_n;
output NCLK, GREST, HD, DEN, VD;

// cables de interconexión
wire TC_H;
wire TC_V;


// PLL para reducir CLK_50 a 25 MHz
pll_ltm	pll_ltm_inst (
	.inclk0 ( CLK_50 ),
	.c0 ( NCLK )
);
    
// Contador HORIZONTAL
contador HCOUNT 
(
	.iCLK(NCLK) ,	    // input  iCLK
	.iENABLE(1'b1) ,	// input  iENABLE
	.iRST_n(RST_n) ,	// input  iRST_n
	.oCOUNT(columna) ,	// output [n-1:0] oCOUNT
	.oTC(TC_H) ,	    // output  oTC
	.iUP_DOWN(1'b1) 	// input  iUP_DOWN
);
defparam HCOUNT.fin_cuenta = fin_cuenta_H;

// Contador VERTICAL
contador VCOUNT 
(
	.iCLK(NCLK) ,	    // input  iCLK
	.iENABLE(TC_H) ,	// input  iENABLE
	.iRST_n(RST_n) ,	// input  iRST_n
	.oCOUNT(fila) ,		// output [n-1:0] oCOUNT
	.oTC(TC_V) ,	    // output  oTC
	.iUP_DOWN(1'b1) 	// input  iUP_DOWN
);
defparam VCOUNT.fin_cuenta = fin_cuenta_V;

// salidas HD y VD
assign HD = !TC_H;
assign VD = !TC_V;

// global reset (GREST)
assign GREST = RST_n;

// habilitación de la visualización en pantalla (DEN)
assign DEN = ((columna>215 && columna<1016) && (fila>34 && fila<515))? 1'b1:1'b0;

endmodule