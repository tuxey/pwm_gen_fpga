// --------------------------------------------------------------------
// Universitat Politècnica de València
// Departamento de Ingeniería Electronica
// --------------------------------------------------------------------
// Sistemas Digitales Programables - MUISE
// Curso 2020 - 2021
// --------------------------------------------------------------------
// Práctica 4
// --------------------------------------------------------------------
// Nombre del archivo: ADC_CONTROL.v
// 
// Descripción: Módulo que implementa la generación de las señales de
//   control necesarias para pedir al ADC de la pantalla táctil TerAsic
//   las coordenadas X e Y del punto de contacto, y la correspondiente
//   recepción de dichas señales.
//   Además, incorpora un retardo entre lecturas de puntos de contacto,
//   con el objetivo de generar una lectura más espaciada y no saturar
//   el ADC.
//
// Inputs:
//   iCLK:          Señal de reloj 50 MHz
//   iRST_n:        Reset asíncrono activo a nivel bajo
//   iADC_DOUT:     Señal serie recibida del ADC
//   iADC_PENIRQ_n: Interrupción generada por el ADC cuando se
//                  detecta el contacto
//   iADC_BUSY:     Señal activa mientras el ADC esté ocupado realizando
//                  una conversión
//
// Outputs:
//   oADC_DIN:  Salida al ADC, señal serie mediante la cual se realiza
//              la petición de los datos
//   oADC_DCLK: Señal de reloj 70 kHz para el ADC
//   oSCEN:     Chip Select entre la visualización LCD y la conversión
//              del punto de contacto por el ADC (no pueden trabajar a
//              la vez)
//   oX_COORD:     Coordenada X leída por el ADC
//   oY_COORD:     Coordenada Y leída por el ADC
// 
// Funcionamiento de las coordenadas de la pantalla:
//
// 		    ___________________ (FFF,FFF) (x,y)
// 		   |                   |
// 		   |                   |
// 		↑  |                   |
// 		x  |                   |
// 		   |                   |
// 		   |___________________|
//		(0,0)        y →
//
//
// --------------------------------------------------------------------
// Versión: V1.0 | Fecha Modificación: 1/12/2020
// 
// Autores: Pablo Roig Monzón y Ángel Bellver Valera
// Ordenador de trabajo: 9
// --------------------------------------------------------------------

module ADC_CONTROL(
					iCLK,
					iRST_n,
					oADC_DIN,
					oADC_DCLK,
					oSCEN,
					iADC_DOUT,
					iADC_BUSY,
					iADC_PENIRQ_n,
					oX_COORD,
					oY_COORD,
					fin_transmision
					);

parameter SYSCLK_FRQ	= 50000000;
parameter ADC_DCLK_FRQ	= 70000;
parameter ADC_DCLK_CNT	= SYSCLK_FRQ/(ADC_DCLK_FRQ*2); // 358

input					iCLK;
input					iRST_n;
input					iADC_DOUT;
input					iADC_PENIRQ_n;
input					iADC_BUSY;
output 				oADC_DIN;
output				oADC_DCLK;
output				oSCEN;
output [11:0]	oX_COORD;
output [11:0]	oY_COORD;
output fin_transmision;

wire trans_en;	// habilita la transmisión (proveniente de la FSM)
wire dclk;  	// señal de clock DCLK a 70 kHz
wire fin_80;	// fin de cuenta del contador modulo80
wire [6:0] count_80;   // salida del contador modulo80

// contador para espera de la FSM
wire wait_en;
wire wait_irq;


// senyales de control a enviar al ADC
parameter [7:0] X_control = 8'b10010010;
parameter [7:0] Y_control = 8'b11010010;


// -------------- BLOQUES DEL DISENYO -----------------
// 1. Contador DCLK_CNT a 70 kHz
contador div_freq 
(
	.iCLK(iCLK) ,	    // input  iCLK
	.iENABLE(trans_en) ,// input  iENABLE
	.iRST_n(iRST_n) ,	// input  iRST_n
	.oCOUNT() ,			// output [n-1:0] oCOUNT
	.oTC(dclk) ,	    // output  oTC
	.iUP_DOWN(1'b1) 	// input  iUP_DOWN
);
defparam div_freq.fin_cuenta = ADC_DCLK_CNT; // 358


// 2. Contador modulo 80
contador modulo80 
(
	.iCLK(iCLK) ,	    // input  iCLK
	.iENABLE(dclk) ,	// input  iENABLE
	.iRST_n(iRST_n) ,	// input  iRST_n
	.oCOUNT(count_80) ,	// output [n-1:0] oCOUNT
	.oTC(fin_80) ,	    // output  oTC
	.iUP_DOWN(1'b1) 	// input  iUP_DOWN
);
defparam modulo80.fin_cuenta = 80;

// 3. ADC_DCLK como assign
assign oADC_DCLK = count_80[0];

// 4. generador de ADC_DIN
generador_ADC_IN generador_ADC_IN_inst
(
	.iCLK(iCLK) ,			// input  iCLK
	.iRST_n(iRST_n) ,		// input  iRST_n
	.oADC_DIN(oADC_DIN) ,	// output  oADC_DIN
	.trans_en(trans_en) ,	// input  trans_en
	.count_80(count_80) 	// input [6:0] count_80
);
defparam generador_ADC_IN_inst.X_control = X_control;
defparam generador_ADC_IN_inst.Y_control = Y_control;


// 5. receptor de ADC_DOUT
receptor_ADC_DOUT receptor_ADC_DOUT_inst
(
	.iCLK(iCLK) ,			// input  iCLK
	.iRST_n(iRST_n) ,		// input  iRST_n
	.iADC_DOUT(iADC_DOUT) ,	// input  iADC_DOUT
	.oX_COORD(oX_COORD) ,	// output [11:0] oX_COORD
	.oY_COORD(oY_COORD) ,	// output [11:0] oY_COORD
	.trans_en(trans_en) ,	// input  trans_en
	.count_80(count_80) 	// input  [7:0] count_80
);

// 6. FSM de controlpath
FSM_ADC FSM_ADC_inst
(
	.iCLK(iCLK) ,					// input  iCLK
	.iRST_n(iRST_n) ,				// input  iRST_n
	.idclk(dclk) ,					// input  idclk
	.ifin_80(fin_80) ,				// input  ifin_80
	.oADC_CS(oSCEN) ,				// output  oADC_CS
	.iADC_PENIRQ_n(iADC_PENIRQ_n) ,	// input  iADC_PENIRQ_n
	.oEna_Trans(trans_en) ,			// output  oEna_Trans
	.oFin_Trans(fin_transmision),   // output  oFin_Trans
	.wait_en(wait_en),
	.wait_irq(wait_irq)
);

// 7. contador para lectura espaciada de los puntos de contacto
contador espera_estado 
(
	.iCLK(iCLK) ,	    // input  iCLK
	.iENABLE(wait_en) , // input  iENABLE
	.iRST_n(iRST_n) ,	// input  iRST_n
	.oCOUNT() ,			// output [n-1:0] oCOUNT
	.oTC(wait_irq) ,	// output  oTC
	.iUP_DOWN(1'b1) 	// input  iUP_DOWN
);
defparam espera_estado.fin_cuenta = 5000000; // retardo de 0.1 s

	
endmodule
