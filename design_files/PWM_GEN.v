// --------------------------------------------------------------------
// Universitat Politècnica de València
// Departamento de Ingeniería Electronica
// --------------------------------------------------------------------
// Sistemas Digitales Programables - MUISE
// Curso 2020 - 2021
// --------------------------------------------------------------------
// Práctica 5
// --------------------------------------------------------------------
// Nombre del archivo: PWM_GEN.v
//
// Descripción: Módulo que obtiene la señal PWM aplicada a los LEDS a
// partir de los valores de frecuencia y duty requeridos. Para ello,
// emplea un contador de módulo variable y un nivel de comparación que
// pone la señal a nivel alto si el valor de la cuenta es menor que 
// el comparador y viceversa.
//
// --------------------------------------------------------------------
// Versión: V1.0 | Fecha Modificación: 08/02/2021
//
// Autores: Pablo Roig Monzón y Ángel Bellver Valera
// Ordenador de trabajo: Home y PC 8
// --------------------------------------------------------------------

module PWM_GEN (
	iCLK,iRST_n,
	PWM_freq,
	duty_cycle,
	out_comp
);

//------------------------PARAMETROS-----------------------------------
`include "MathFun.vh"

parameter freq_min=1;
parameter freq_max=10000;
parameter SYSCLK_FRQ=50000000;

parameter nbits_freq=CLogB2(freq_max);	//máx num de bits de PWM_freq

parameter nbits_cont=CLogB2(SYSCLK_FRQ/(2*freq_min)-1); //máx num de bits de los wires intermedios

//-------------------------ENTRADAS------------------------------------
input       [6:0] duty_cycle;
input       [nbits_freq-1:0] PWM_freq;
input 		iCLK, iRST_n;

//-------------------------SALIDAS-------------------------------------
output      out_comp;

//-------------------------WIRES---------------------------------------
wire [nbits_cont-1:0] oCOUNT;
wire [nbits_cont-1:0] module_CONT;
wire [(nbits_cont+7)-1:0] PWM_comp;

//-------------------------SUBMODULOS----------------------------------
// contador módulo variable mediante input
CONT CONT_inst
(
	.iCLK(iCLK) ,	// input  iCLK
	.iRST_n(iRST_n) ,	// input  iRST_n
	.oCOUNT(oCOUNT) ,	// output [nbits_cont-1:0] oCOUNT
	.module_CONT(module_CONT) 	// input [nbits_cont-1:0] module_CONT
);
defparam CONT_inst.SYSCLK_FRQ = SYSCLK_FRQ;
defparam CONT_inst.freq_min = freq_min;
defparam CONT_inst.nbits_cont = nbits_cont;


//------------------------ASIGNACIONES---------------------------------
assign module_CONT=SYSCLK_FRQ/(2*PWM_freq);

assign PWM_comp= (duty_cycle*(module_CONT-1))/100;
	
assign out_comp = (oCOUNT>PWM_comp) ? 1'b0 : 1'b1; 

endmodule
