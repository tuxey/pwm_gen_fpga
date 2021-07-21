// --------------------------------------------------------------------
// Universitat Politècnica de València
// Departamento de Ingeniería Electronica
// --------------------------------------------------------------------
// Sistemas Digitales Programables - MUISE
// Curso 2020 - 2021
// --------------------------------------------------------------------
// Práctica 4
// --------------------------------------------------------------------
// Nombre del archivo: receptor_ADC_DOUT.v
// 
// Descripción: Módulo que implementa la recepción de la señal de salida
//   del ADC, ADC_DOUT. La señal se almacena y transmite por oX_COORD e
//   oY_COORD en función del valor del contador de módulo 80.
//
// Inputs:
//   iCLK:      Señal de reloj 50 MHz
// 	 iRST_n:    Reset asíncrono activo a nivel bajo
//   trans_en:  Bit que indica la habilitación de la comunicación
//   count_80:  Cuenta del contador de módulo 80
//   iADC_DOUT: Señal de comunicación recibida del ADC
//
// Outputs:
//   oX_COORD: Coordenada X recibida del ADC
//   oY_COORD: Coordenada Y recibida del ADC
// 
// --------------------------------------------------------------------
// Versión: V1.0 | Fecha Modificación: 7/12/2020
// 
// Autores: Pablo Roig Monzón y Ángel Bellver Valera
// Ordenador de trabajo: Home
// --------------------------------------------------------------------

module receptor_ADC_DOUT (
    iCLK,
    iRST_n,
    iADC_DOUT,
    oX_COORD,
    oY_COORD,
    trans_en,
    count_80
);

input iCLK;
input iRST_n;
input iADC_DOUT;

input [6:0] count_80;   // salida del contador modulo80
input trans_en;	// habilita la transmisión (proveniente de la FSM)

output reg [11:0]	oX_COORD;
output reg [11:0]	oY_COORD;


// hay que guardar oX_COORD y oY_COORD hasta el final del count_80


always @(posedge iCLK or negedge iRST_n)
begin
	if (!iRST_n)
		begin
			oX_COORD <= 12'h000;
			oY_COORD <= 12'h000;
		end
	else if (trans_en) // transmisión activada
		begin
			case (count_80)
			// resetear los valores solo al principio (¿es necesario?)
			0:  begin
					oX_COORD <= 12'h000;
					oY_COORD <= 12'h000;
				end

			// guardar coordenada X
			19: oX_COORD[11] <= iADC_DOUT;
			21: oX_COORD[10] <= iADC_DOUT;
			23: oX_COORD[9] <= iADC_DOUT;
			25: oX_COORD[8] <= iADC_DOUT;
			27: oX_COORD[7] <= iADC_DOUT;
			29: oX_COORD[6] <= iADC_DOUT;
			31: oX_COORD[5] <= iADC_DOUT;
			33: oX_COORD[4] <= iADC_DOUT;
			35: oX_COORD[3] <= iADC_DOUT;
			37: oX_COORD[2] <= iADC_DOUT;
			39: oX_COORD[1] <= iADC_DOUT;
			41: oX_COORD[0] <= iADC_DOUT;

			// guardar coordenada Y
			
			51: oY_COORD[11] <= iADC_DOUT;
			53: oY_COORD[10] <= iADC_DOUT;
			55: oY_COORD[9] <= iADC_DOUT;
			57: oY_COORD[8] <= iADC_DOUT;
			59: oY_COORD[7] <= iADC_DOUT;
			61: oY_COORD[6] <= iADC_DOUT;
			63: oY_COORD[5] <= iADC_DOUT;
			65: oY_COORD[4] <= iADC_DOUT;
			67: oY_COORD[3] <= iADC_DOUT;
			69: oY_COORD[2] <= iADC_DOUT;
			71: oY_COORD[1] <= iADC_DOUT;
			73: oY_COORD[0] <= iADC_DOUT;

			// en cualquier otro caso guardar
			default:
				begin
					oX_COORD <= oX_COORD;
					oY_COORD <= oY_COORD;
				end
			endcase
		end
	else // si transmisión desactivada, guardar el valor
		begin // porque el MFB comprueba justo después de acabar la transmisión
			oX_COORD <= oX_COORD;
			oY_COORD <= oY_COORD;
		end
end

endmodule