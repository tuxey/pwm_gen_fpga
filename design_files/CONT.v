// --------------------------------------------------------------------
// Universitat Politècnica de València
// Departamento de Ingeniería Electronica
// --------------------------------------------------------------------
// Sistemas Digitales Programables - MUISE
// Curso 2020 - 2021
// --------------------------------------------------------------------
// Práctica 5
// --------------------------------------------------------------------
// Nombre del archivo: CONT.v
//
// Descripción: Este módulo describe un contador de módulo variable (el
//   módulo es una input), utilizado para la generación de la señal PWM
//   de frecuencia variable.
//
//   Es ajustable mediante parámetros: la frecuencia del sistema, y 
//   la frecuencia mínima y la frecuencia máxima del PWM.
//	 
//   La entrada es el módulo deseado para el contador, aparte de las
//      señales de reloj y de reset.
//   La salida es la cuenta (oCOUNT).
//
// --------------------------------------------------------------------
// Versión: V1.0 | Fecha Modificación: 05/02/2021
//
// Autores: Pablo Roig Monzón y Ángel Bellver Valera
// Ordenador de trabajo: Home y PC 8
// --------------------------------------------------------------------

module CONT (
	iCLK,iRST_n,
	oCOUNT,
	module_CONT
);


//------------------------PARAMETROS-----------------------------------
`include "MathFun.vh"

parameter SYSCLK_FRQ=50000000;
parameter freq_min=1;
parameter nbits_cont=CLogB2(SYSCLK_FRQ/(2*freq_min)-1); //máx num de bits del contador


//-------------------------ENTRADAS------------------------------------
input 		iCLK, iRST_n;
input       [nbits_cont-1:0] module_CONT;


//-------------------------SALIDAS-------------------------------------
output reg  [nbits_cont-1:0] oCOUNT;


//-----------------CONTADOR DE MÓDULO VARIABLE POR INPUT---------------
always @ (posedge iCLK or negedge iRST_n)
begin
	
	if(!iRST_n)
	
	oCOUNT <= {nbits_cont{1'b0}};
	
	else
	
		if(oCOUNT==module_CONT-1)
		
			oCOUNT<= {nbits_cont{1'b0}};
			
		else
		
			oCOUNT <= oCOUNT+1;
end
	
endmodule
