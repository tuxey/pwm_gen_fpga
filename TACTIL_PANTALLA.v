// --------------------------------------------------------------------
// Universitat Politècnica de València
// Departamento de Ingeniería Electronica
// --------------------------------------------------------------------
// Sistemas Digitales Programables - MUISE
// Curso 2020 - 2021
// --------------------------------------------------------------------
// Práctica 5
// --------------------------------------------------------------------
// Nombre del archivo: TACTIL_PANTALLA.v
//
// Descripción: Este módulo es el responsable de obtener los valores de
//   porcentaje (ciclo de trabajo) y frecuencia demandados por el
//   usuario al deslizar las barras.
//   Para ello, se instancia el submódulo ADC_CONTROL, que obtiene las
//   coordenadas del punto de contacto. Estas coordenadas se procesan
//   mediante los módulos OBTENER_VALORES_PWM y porcentaje_a_log_4decadas,
//   obteniendo así a la salida los valores de:
//    - ciclo de trabajo, en rango 0 a 100
//    - porcentaje de la barra de frecuencia PWM, en rango 0 a 100
//    - frecuencia PWM, en rango 0 a 10000 Hz y escala logarítmica
//
// --------------------------------------------------------------------
// Versión: V1.0 | Fecha Modificación: 08/02/2021
//
// Autores: Pablo Roig Monzón y Ángel Bellver Valera
// Ordenador de trabajo: Home y PC 8
// --------------------------------------------------------------------

module TACTIL_PANTALLA (
    // ADC
    iCLK,
    iRST_n,
    oADC_DIN,
    oADC_DCLK,
    oSCEN,
    iADC_DOUT,
    iADC_BUSY,
    iADC_PENIRQ_n,
    // señales
	duty_cycle, freq_porcentaje, freq_Hz
);

//-------------------------ENTRADAS------------------------------------
input iCLK;
input iRST_n;
input iADC_DOUT;
input iADC_PENIRQ_n;
input iADC_BUSY;


//-------------------------SALIDAS-------------------------------------
output oADC_DIN;
output oADC_DCLK;
output oSCEN;
output [6:0] duty_cycle;
output [6:0] freq_porcentaje;
output [13:0] freq_Hz;

//-------------------------WIRES---------------------------------------
wire [11:0] oX_COORD;
wire [11:0] oY_COORD;
wire fin_transmision;
wire enable_conversion;
wire iADC_PENIRQ_n_reg;

//-------------------------SUBMODULOS----------------------------------
// 0. registro doble de la interrupción iADC_PENIRQ_n, para sincronizarla con el sistema
registro_doble_1bit registro_doble_1bit_inst
(
	.CLK(iCLK) ,
	.RST_n(iRST_n) ,
	.x(iADC_PENIRQ_n) ,
	.y(iADC_PENIRQ_n_reg)
);

// 1. Control de la lectura del ADC
ADC_CONTROL ADC_CONTROL_inst
(
	.iCLK(iCLK) ,	                // input  iCLK
	.iRST_n(iRST_n) ,	            // input  iRST_n
	.oADC_DIN(oADC_DIN) ,	        // output  oADC_DIN
	.oADC_DCLK(oADC_DCLK) ,	        // output  oADC_DCLK
	.oSCEN(oSCEN) ,	                // output  oSCEN
	.iADC_DOUT(iADC_DOUT) ,	        // input  iADC_DOUT
	.iADC_BUSY(iADC_BUSY) ,	        // input  iADC_BUSY
	.iADC_PENIRQ_n(iADC_PENIRQ_n_reg) ,	// input  iADC_PENIRQ_n
	.oX_COORD(oX_COORD) ,	        // output [11:0] oX_COORD
	.oY_COORD(oY_COORD) ,	        // output [11:0] oY_COORD
    .fin_transmision(fin_transmision) // output  fin_transmision
);

// 2. FSM_TACTIL para que hasta que no se toque la pantalla los valores sean 0
FSM_TACTIL FSM_TACTIL_inst
(
	.iCLK(iCLK) ,	// input  iCLK
	.iRST_n(iRST_n) ,	// input  iRST_n
	.iFin_transmision(fin_transmision) ,	// input  iFin_transmision
	.oEnable_conversion(enable_conversion) 	// output  oEnable_conversion
);

// 3. Obtener los valores (en rango 0 a 100) de:
//     - porcentaje de la frecuencia de PWM
//     - porcentaje del ciclo de trabajo (duty cycle)
OBTENER_VALORES_PWM obtener_valores_PWM
(
	.CLK(iCLK) ,				// input  CLK
	.fin_transmision(fin_transmision) ,	// input  fin_transmision
	.enable_conversion(enable_conversion) ,	// input  enable_conversion
	.X_COORD(oX_COORD) ,	// input [11:0] X_COORD
	.Y_COORD(oY_COORD) ,	// input [11:0] Y_COORD
	.duty_cycle(duty_cycle) ,	// output [6:0] duty_cycle
	.freq_porcentaje(freq_porcentaje) 	// output [6:0] freq_porcentaje
);

// 4. convertir el valor en porcentaje de la frecuencia a Hz
//    según una escala logarítmica de 4 décadas
porcentaje_a_log_4decadas porcentaje_a_log_4decadas_inst
(
   .x(freq_porcentaje) , //input  [6:0] x
   .y(freq_Hz)			 //output [13:0] y
);

endmodule