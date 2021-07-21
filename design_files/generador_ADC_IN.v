// --------------------------------------------------------------------
// Universitat Politècnica de València
// Departamento de Ingeniería Electronica
// --------------------------------------------------------------------
// Sistemas Digitales Programables - MUISE
// Curso 2020 - 2021
// --------------------------------------------------------------------
// Práctica 4
// --------------------------------------------------------------------
// Nombre del archivo: generador_ADC_IN.v
// 
// Descripción: Módulo que genera las señales a enviar al ADC, de
//   petición de coordenadas X e Y. En base a la cuenta de un contador
//	 de módulo 80 (input), dado que el ADC necesita una temporización
//   concreta de estas señales.
//
// Inputs:
//   iCLK:     Señal de reloj 50 MHz
// 	 iRST_n:   Reset asíncrono activo a nivel bajo
//   trans_en: Bit que indica la habilitación de la comunicación
//   count_80: Cuenta del contador de módulo 80
//
// Outputs:
//   oADC_DIN: Señal a enviar al ADC con la temporización correcta
//   		   de las peticiones de coordenadas X e Y
//
// --------------------------------------------------------------------
// Versión: V1.0 | Fecha Modificación: 7/12/2020
// 
// Autores: Pablo Roig Monzón y Ángel Bellver Valera
// Ordenador de trabajo: 9
// --------------------------------------------------------------------

module generador_ADC_IN (
    iCLK,
    iRST_n,
    oADC_DIN,
    trans_en,
    count_80
);

input iCLK;
input iRST_n;
input trans_en;
input [6:0] count_80;   // salida del contador modulo80
output reg oADC_DIN;

// senyales de control a enviar al ADC
parameter [7:0] X_control = 8'b10010010;
parameter [7:0] Y_control = 8'b11010010;

always @(posedge iCLK or negedge iRST_n)
begin
	if (!iRST_n)
		oADC_DIN <= 1'b0;
	else if (trans_en) // si estamos en estado de transmision
	begin
		case (count_80)
			// pedir coordenada X
			0: oADC_DIN <= X_control[7];
			1: oADC_DIN <= X_control[7];
			2: oADC_DIN <= X_control[6];
			3: oADC_DIN <= X_control[6];
			4: oADC_DIN <= X_control[5];
			5: oADC_DIN <= X_control[5];
			6: oADC_DIN <= X_control[4];
			7: oADC_DIN <= X_control[4];
			8: oADC_DIN <= X_control[3];
			9: oADC_DIN <= X_control[3];
			10: oADC_DIN <= X_control[2];
			11: oADC_DIN <= X_control[2];
			12: oADC_DIN <= X_control[1];
			13: oADC_DIN <= X_control[1];
			14: oADC_DIN <= X_control[0];
			15: oADC_DIN <= X_control[0];

			// pedir coordenada Y
			32: oADC_DIN <= Y_control[7];
			33: oADC_DIN <= Y_control[7];
			34: oADC_DIN <= Y_control[6];
			35: oADC_DIN <= Y_control[6];
			36: oADC_DIN <= Y_control[5];
			37: oADC_DIN <= Y_control[5];
			38: oADC_DIN <= Y_control[4];
			39: oADC_DIN <= Y_control[4];
			40: oADC_DIN <= Y_control[3];
			41: oADC_DIN <= Y_control[3];
			42: oADC_DIN <= Y_control[2];
			43: oADC_DIN <= Y_control[2];
			44: oADC_DIN <= Y_control[1];
			45: oADC_DIN <= Y_control[1];
			46: oADC_DIN <= Y_control[0];
			47: oADC_DIN <= Y_control[0];
			
			// en cualquier otro caso
			default: oADC_DIN <= 1'b0;
		endcase
	end
end

endmodule