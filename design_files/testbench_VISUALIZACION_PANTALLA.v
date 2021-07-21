// --------------------------------------------------------------------
// Universitat Politècnica de València
// Departamento de Ingeniería Electronica
// --------------------------------------------------------------------
// Sistemas Digitales Programables - MUISE
// Curso 2020 - 2021
// --------------------------------------------------------------------
// Práctica 3
// --------------------------------------------------------------------
// Nombre del archivo: testbench_CARACTERES_LCD.v
// 
// Descripción: Este testbench crea las señales necesarias para comprobar
// el funcionamiento del módulo CARACTERES_LCD.
//
// Características del DUT:
//
//    Descripción: Genera las señales de sincronismo y
//    visualización necesarias para llenar la pantalla LCD de
//    repeticiones de un mismo caracter.
// 
//    Inputs:  
//			      CLK:   señal de reloj de 50 MHz
//			      RST_n: reset asíncrono a nivel bajo
//
//    Outputs: NCLK, GREST, HD, VD, DEN, R, G, B
//			      (señales de sincronismo y visualización de la pantalla)
// 
// --------------------------------------------------------------------
// Versión: V1.0 | Fecha Modificación: 15/11/2020
// 
// Autores: Pablo Roig Monzón y Ángel Bellver Valera
// Ordenador de trabajo: Home
// --------------------------------------------------------------------

`timescale 1 ns/ 1 ps

module testbench_VISUALIZACION_PANTALLA();

// input registers
reg CLK;
reg RST_n;
// wires                                               
wire [7:0]  B;
wire DEN;
wire [7:0]  G;
wire GREST;
wire HD;
wire NCLK;
wire [7:0]  R;
wire VD;

//wire PWM_value;

// parámetro del reloj
localparam T = 20;
// DEFINICION DEL RELOJ
always
   begin
      #(T/2) CLK <= ~CLK; // non-blocking
   end


// para guardar salida en fichero vga.txt
integer fd;
event cierraFichero;

// instanciacion del DUV
VISUALIZACION_PANTALLA VISUALIZACION_PANTALLA_inst
(
	.CLK(CLK) ,	// input  CLK
	.RST_n(RST_n) ,	// input  RST_n
	.duty_cycle(50) ,	// input [7:0] PWM_value
   .pwm_freq(50) ,  // input [7:0] pwm_freq
   .freq_Hz(100) , 
	.NCLK(NCLK) ,	// output  NCLK
	.GREST(GREST) ,	// output  GREST
	.HD(HD) ,	// output  HD
	.VD(VD) ,	// output  VD
	.DEN(DEN) ,	// output  DEN
	.R(R) ,	// output [7:0] R
	.G(G) ,	// output [7:0] G
	.B(B) 	// output [7:0] B
);

// ##################### ZONA DE TEST #####################
initial                                                
begin
   CLK = 1'b0;
   reset();
   $display("Running testbench");

   @(posedge VD);
   $display("Fin de la simulacion\n");
   -> cierraFichero;
   #10;
   $stop;
end

// guardado del fichero
initial
begin
   fd = $fopen("vga.txt", "w");
   @(cierraFichero);
   disable guardaFichero;
   $display("Cierro Fichero");
   $fclose(fd);
end

initial forever begin: guardaFichero
   @(posedge NCLK)
   $fwrite(fd, "%0t ps: %b %b %b %b %b %b\n", $time, HD, VD, DEN, R, G, B);
end

// ===================== ZONA DE TASK =====================

// --------------  reset ------------------
task reset();
begin
   @(negedge CLK);
      RST_n = 1'b0;
   #T;
      RST_n = 1'b1;
   $display("RESET done");
end
endtask

endmodule