// --------------------------------------------------------------------
// Universitat Politècnica de València
// Departamento de Ingeniería Electronica
// --------------------------------------------------------------------
// Sistemas Digitales Programables - MUISE
// Curso 2020 - 2021
// --------------------------------------------------------------------
// Práctica 5
// --------------------------------------------------------------------
// Nombre del archivo: VISUALIZACION_PANTALLA.v
//
// Descripción: Este módulo se encarga de generar las señales de
//   visualización a enviar a la pantalla. En la pantalla se muestran 5
//   elementos:
//       - Imagen de fondo
//       - Barra del ciclo de trabajo
//       - Texto del ciclo de trabajo
//       - Barra de la frecuencia PWM
//       - Texto de la frecuencia PWM
//
//   El funcionamiento de la visualización se ha realizado de la
//   siguiente manera:
//   Cada módulo de barra, texto o imagen de fondo genera una o varias
//   señales de salida de 1 bit, que indican si para la fila y columna
//   actual dicho elemento está activo (en el caso de las barras, tienen
//   3 señales de 1 bit: marco de la barra, barra en sí, y fondo de la
//   barra). El módulo SELEC_COLOR se encarga de elegir qué color RGB
//   enviar a la pantalla en función de estas señales, y si no hay
//   ninguna activa, el color es blanco.
//
// --------------------------------------------------------------------
// Versión: V1.0 | Fecha Modificación: 08/02/2021
//
// Autores: Pablo Roig Monzón y Ángel Bellver Valera
// Ordenador de trabajo: Home y PC 8
// --------------------------------------------------------------------


module VISUALIZACION_PANTALLA
(
    input CLK, RST_n,
    input [6:0] duty_cycle, pwm_freq,
	input [13:0] freq_Hz,
    output NCLK, GREST, HD, VD, DEN,
    output [7:0] R, G, B
);

`include "MathFun.vh"

//------------------------PARAMETROS-----------------------------------
// parámetros de la pantalla, *TOTAL*
parameter fin_cuenta_H = 1056;
parameter fin_cuenta_V = 525;
// número de bits de:
parameter n_H = CLogB2(fin_cuenta_H - 1); // columnas
parameter n_V = CLogB2(fin_cuenta_V - 1); // filas

// parámetros de la pantalla, *ZONA VISIBLE*
parameter col_max_pantalla  = 800;
parameter fila_max_pantalla = 480;
// número de bits de:
parameter n_col = CLogB2(col_max_pantalla - 1); // columnas
parameter n_fil = CLogB2(fila_max_pantalla - 1); // filas


//------------------------WIRES----------------------------------------
// wires de columnas y filas
wire [n_H-1:0] columna;
wire [n_V-1:0] fila;
// wires de columnas y filas referidas a 800x480
wire [n_col-1:0] columna_VISIBLE;
wire [n_fil-1:0] fila_VISIBLE;
// wires de conexion entre modulos
	// 1. duty cycle
	wire barra_duty_ON, marco_duty_ON, fondo_duty_ON, letra_duty_ON;
	// 2. pwm frequency
	wire barra_freq_ON, marco_freq_ON, fondo_freq_ON, letra_freq_ON;
	// 3. imagen de fondo a selec_color
	wire fondo_pantalla_ON;


//------------------------COMBINACIONALES------------------------------
// convertir filas y columnas totales a visibles
assign columna_VISIBLE = (DEN)? (columna - 216) : 0;
assign fila_VISIBLE    = (DEN)? (fila    -  35) : 0;


//------------------------SUBMODULOS-----------------------------------
// 1. LCD_SYNC
LCD_SYNC LCD_SYNC_inst
(
	.CLK_50(CLK) ,	// input  CLK_50
	.RST_n(RST_n) ,	// input  RST_n
	.NCLK(NCLK) ,	// output  NCLK
	.GREST(GREST) ,	// output  GREST
	.HD(HD) ,	// output  HD
	.DEN(DEN) ,	// output  DEN
	.VD(VD) ,	// output  VD
	.columna(columna) ,	// output [n_H-1:0] columna
	.fila(fila) 	// output [n_V-1:0] fila
);
defparam LCD_SYNC_inst.fin_cuenta_H = fin_cuenta_H;
defparam LCD_SYNC_inst.fin_cuenta_V = fin_cuenta_V;


// >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> DUTY CYCLE
// 2. BARRA para mostrar el Duty Cycle
BARRA_PORCENTAJE_LCD BARRA_dutycycle
(
	.porcentaje(duty_cycle) ,	// input [6:0] duty_cycle
	.fila(fila_VISIBLE) ,		// input [n_fil-1:0] fila
	.columna(columna_VISIBLE) ,	// input [n_col-1:0] columna
	.barra_ON(barra_duty_ON) ,	// output  barra_ON
	.marco_ON(marco_duty_ON) ,	// output  marco_ON
    .fondo_ON(fondo_duty_ON)    // output  fondo_ON
);
defparam BARRA_dutycycle.col_max_pantalla = col_max_pantalla;
defparam BARRA_dutycycle.fila_max_pantalla = fila_max_pantalla;
defparam BARRA_dutycycle.ubicacion_vertical_barra = 0.45; // 0=arriba, 1=abajo
defparam BARRA_dutycycle.porcentaje_pantalla_ancho_barra = 0.85;
defparam BARRA_dutycycle.porcentaje_pantalla_alto_barra = 0.1;
defparam BARRA_dutycycle.espesor_marco = 4; // numero par por favor

// 3. TEXTO_LCD para mostrar el Duty Cycle
TEXTO_LCD_PORCENTAJE TEXTO_LCD_dutycycle
(
	.NCLK(NCLK) ,	// input  NCLK
	.fila(fila_VISIBLE) ,	// input [n_fil-1:0] fila
	.columna(columna_VISIBLE) ,	// input [n_col-1:0] columna
	.porcentaje(duty_cycle) ,	// input [6:0] percent
	.letra_ON(letra_duty_ON) 	// output  letra_ON
);
defparam TEXTO_LCD_dutycycle.col_max_pantalla = col_max_pantalla;
defparam TEXTO_LCD_dutycycle.fila_max_pantalla = fila_max_pantalla;
defparam TEXTO_LCD_dutycycle.ubicacion_vertical_texto = 0.3;
defparam TEXTO_LCD_dutycycle.potencia_tamanyo = 2; // 0 = 8px, 1 = 16 px, 2 = 32 px, 3 = 64 px

// >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> PWM FREQUENCY
// 4. BARRA para mostrar la frecuencia del PWM
BARRA_PORCENTAJE_LCD BARRA_pwmfreq
(
	.porcentaje(pwm_freq) ,	// input [6:0] duty_cycle
	.fila(fila_VISIBLE) ,		// input [n_fil-1:0] fila
	.columna(columna_VISIBLE) ,	// input [n_col-1:0] columna
	.barra_ON(barra_freq_ON) ,	// output  barra_ON
	.marco_ON(marco_freq_ON) ,	// output  marco_ON
    .fondo_ON(fondo_freq_ON)    // output  fondo_ON
);
defparam BARRA_pwmfreq.col_max_pantalla = col_max_pantalla;
defparam BARRA_pwmfreq.fila_max_pantalla = fila_max_pantalla;
defparam BARRA_pwmfreq.ubicacion_vertical_barra = 0.8; // 0=arriba, 1=abajo
defparam BARRA_pwmfreq.porcentaje_pantalla_ancho_barra = 0.85;
defparam BARRA_pwmfreq.porcentaje_pantalla_alto_barra = 0.1;
defparam BARRA_pwmfreq.espesor_marco = 4; // numero par por favor

// 5. TEXTO_LCD para mostrar la frecuencia del PWM
TEXTO_LCD_Hz TEXTO_LCD_pwmfreq
(
	.NCLK(NCLK) ,	// input  NCLK
	.fila(fila_VISIBLE) ,	// input [n_fil-1:0] fila
	.columna(columna_VISIBLE) ,	// input [n_col-1:0] columna
	.freq_Hz(freq_Hz) ,	// input [13:0] freq_Hz
	.letra_ON(letra_freq_ON) 	// output  letra_ON
);
defparam TEXTO_LCD_pwmfreq.col_max_pantalla = col_max_pantalla;
defparam TEXTO_LCD_pwmfreq.fila_max_pantalla = fila_max_pantalla;
defparam TEXTO_LCD_pwmfreq.ubicacion_vertical_texto = 0.65;
defparam TEXTO_LCD_pwmfreq.potencia_tamanyo = 2; // 0 = 8px, 1 = 16 px, 2 = 32 px, 3 = 64 px

// 6. imagen de fondo
IMAGEN_FONDO_LCD IMAGEN_LCD_inst
(
	.CLK(CLK) ,	// input  CLK
	.RST_n(RST_n) ,	// input  RST_n
	.NCLK(NCLK) ,	// input  NCLK
	.DEN(DEN) ,	// input  DEN
	.fila(fila_VISIBLE) ,	// input [n_fil-1:0] fila
	.columna(columna_VISIBLE) ,	// input [n_col-1:0] columna
	.fondo_pantalla_ON(fondo_pantalla_ON)
);
defparam IMAGEN_LCD_inst.col_max_pantalla = col_max_pantalla;
defparam IMAGEN_LCD_inst.fila_max_pantalla = fila_max_pantalla;


// 7. selección de salida
SELEC_COLOR SELEC_COLOR_inst
(
	.pixel_info( // {marco, barra, fondo, letra}
				{
				marco_duty_ON, barra_duty_ON, fondo_duty_ON, letra_duty_ON,
				marco_freq_ON, barra_freq_ON, fondo_freq_ON, letra_freq_ON
				}
				) ,	// input  pixel_info
	.fondo_pantalla_ON(fondo_pantalla_ON) ,
	.R(R) ,	// output [7:0] R
	.G(G) ,	// output [7:0] G
	.B(B) 	// output [7:0] B
);
defparam SELEC_COLOR_inst.num_inputs = 2;

endmodule