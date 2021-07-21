// Funcionamiento de las coordenadas de la pantalla:
//
// 		    ____________________________ (FFF,FFF) (x,y)
// 		   |                            |
// 		   |                            |
// 		↑  |                            | fila
// 		x  |                            |  ↓
// 		   |                            |
// 		   |____________________________|
//		(0,0)          y →               (480,800) (fila,columna)
//                  columna →

module testbench_OBTENER_VALORES_PWM ();

`timescale 1ns/1ps

//-------------------------SEÑALES DEL DUT------------------------------
reg CLK;

reg fin_transmision;
reg [11:0] X_COORD; // 12'h_000 a 12'h_FFF
reg [11:0] Y_COORD; // 12'h_000 a 12'h_FFF
wire [6:0] duty_cycle;
wire [6:0] freq_porcentaje;


//-----------------------DEFINICION DEL RELOJ---------------------------
localparam T = 20;
always
   begin
      #(T/2) CLK <= ~CLK; // non-blocking
   end

//-----------------------DEVICE UNDER TEST------------------------------
OBTENER_VALORES_PWM OBTENER_VALORES_PWM_inst
(
	.ADC_DCLK(CLK) ,	// input  ADC_DCLK
	.fin_transmision(fin_transmision) ,	// input  fin_transmision
	.X_COORD(X_COORD) ,	// input [11:0] X_COORD
	.Y_COORD(Y_COORD) ,	// input [11:0] Y_COORD
	.duty_cycle(duty_cycle) ,	// output [6:0] duty_cycle
	.freq_porcentaje(freq_porcentaje) 	// output [6:0] freq_porcentaje
);

//-------------------------CASOS DE TEST--------------------------------

initial
begin
    CLK = 1'b0;
    // tocar_pantalla(70,50);
    // #T;
    
    tocar_pantalla(55,33); // barra duty
    #T;

    tocar_pantalla(20,50); // barra freq
    #T;

    $display("Fin del test!");
    $stop();
end

//-------------------------ZONA DE TASK---------------------------------
// tocar en zona fuera de barras, los valores se han de mantener
task tocar_pantalla(input [6:0] x_p, y_p);
begin
    @(negedge CLK);
    $display("\t\tX=%d%%, Y=%d%%", x_p, y_p);
    X_COORD = (x_p * 12'h_FFF)/100;
    Y_COORD = (y_p * 12'h_FFF)/100;
    
    $display("X_COORD = %d (%H)", X_COORD, X_COORD);
    $display("Y_COORD = %d (%H)", Y_COORD, Y_COORD);
    #T;
    fin_transmision = 1'b1;
    display_resultados();
    #T;
    fin_transmision = 1'b0;
end
endtask


// SUBTAREAS
// display resultados
task display_resultados();
begin
    //@(posedge fin_transmision);
    #T;
    $display("%% Duty cycle obtenido:  %D", duty_cycle);
    $display("%% Frecuencia obtenido:  %D\n", freq_porcentaje);
end
endtask

endmodule