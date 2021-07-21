// --------------------------------------------------------------------
// Universitat Politècnica de València
// Departamento de Ingeniería Electronica
// --------------------------------------------------------------------
// Sistemas Digitales Programables - MUISE
// Curso 2020 - 2021
// --------------------------------------------------------------------
// Práctica 5
// --------------------------------------------------------------------
// Nombre del archivo: PWM_LED.v
//
// Descripción: Diseño final de la asignatura.
//
//  Se genera una señal PWM aplicada a los LEDs rojos de la placa DE2-115.
//  Los LEDs se encienden en función del switch inmediatamente debajo de
//  cada uno de ellos.
//
//  Para elegir las características de la señal PWM (duty cycle y
//  frecuencia), se visualizan en la pantalla dos barras de porcentaje,
//  donde se puede desplazar el dedo para cambiar su valor. Además, los
//  valores de duty cycle y frecuencia PWM son mostrados encima de las
//  mencionadas barras.
//
// --------------------------------------------------------------------
// Versión: V1.0 | Fecha Modificación: 08/02/2021
//
// Autores: Pablo Roig Monzón y Ángel Bellver Valera
// Ordenador de trabajo: Home y PC 8
// --------------------------------------------------------------------

module PWM_LED(
	iCLK, iRST_n,
	iADC_DOUT, iADC_BUSY, iADC_PENIRQ_n,
	oADC_DIN, oADC_DCLK, oSCEN,
	NCLK, GREST, HD, VD, DEN,
	R, G, B,
    SW0, SW1, SW2, SW3, SW4, SW5, SW6, SW7, SW8, SW9, SW10, SW11, SW12, SW13, SW14, SW15, SW16, SW17, 
    LED0, LED1, LED2, LED3, LED4, LED5, LED6, LED7, LED8, LED9, LED10, LED11, LED12, LED13, LED14, LED15, LED16, LED17
);

//-------------------------ENTRADAS------------------------------------
// clock y reset global
input iCLK, iRST_n;
// ADC TACTIL
input iADC_DOUT, iADC_BUSY, iADC_PENIRQ_n;
// switches
input SW0, SW1, SW2, SW3, SW4, SW5, SW6, SW7, SW8, SW9, SW10, SW11, SW12, SW13, SW14, SW15, SW16, SW17;

//-------------------------SALIDAS-------------------------------------
// ADC TACTIL
output oADC_DIN, oADC_DCLK, oSCEN;
// PANTALLA
output NCLK, GREST, HD, VD, DEN;
output [7:0] R, G, B;
// LEDs
output LED0, LED1, LED2, LED3, LED4, LED5, LED6, LED7, LED8, LED9, LED10, LED11, LED12, LED13, LED14, LED15, LED16, LED17;

//-------------------------WIRES---------------------------------------
wire [6:0] duty_cycle;
wire [6:0] freq_porcentaje;
wire [13:0] freq_Hz;
wire PWM_signal;

//------------------------SUBMODULOS-----------------------------------
// 1. TACTIL_PANTALLA
TACTIL_PANTALLA tactil_pantalla
(
	.iCLK(iCLK) ,	// input  iCLK
	.iRST_n(iRST_n) ,	// input  iRST_n
	.oADC_DIN(oADC_DIN) ,	// output  oADC_DIN
	.oADC_DCLK(oADC_DCLK) ,	// output  oADC_DCLK
	.oSCEN(oSCEN) ,	// output  oSCEN
	.iADC_DOUT(iADC_DOUT) ,	// input  iADC_DOUT
	.iADC_BUSY(iADC_BUSY) ,	// input  iADC_BUSY
	.iADC_PENIRQ_n(iADC_PENIRQ_n) ,	// input  iADC_PENIRQ_n
	.duty_cycle(duty_cycle) ,	// output [6:0] duty_cycle
	.freq_porcentaje(freq_porcentaje) ,	// output [6:0] freq_porcentaje
	.freq_Hz(freq_Hz) 	// output [13:0] freq_Hz
);


// 2. VISUALIZACION_PANTALLA
VISUALIZACION_PANTALLA visual_pantalla
(
	.CLK(iCLK) ,	// input  CLK
	.RST_n(iRST_n) ,	// input  RST_n
	.duty_cycle(duty_cycle) ,	// input [6:0] PWM_value
    .pwm_freq(freq_porcentaje) ,  // input [6:0] pwm_freq
    .freq_Hz(freq_Hz) ,  // input [13:0] freq_Hz
	.NCLK(NCLK) ,	// output  NCLK
	.GREST(GREST) ,	// output  GREST
	.HD(HD) ,	// output  HD
	.VD(VD) ,	// output  VD
	.DEN(DEN) ,	// output  DEN
	.R(R) ,	// output [7:0] R
	.G(G) ,	// output [7:0] G
	.B(B) 	// output [7:0] B
);


// 3. PWM_GEN
PWM_GEN PWM_GEN_inst
(
	.iCLK(iCLK) ,	// input  iCLK
	.iRST_n(iRST_n) ,	// input  iRST_n
	.PWM_freq(freq_Hz) ,	// input [nbits_freq-1:0] PWM_freq
	.duty_cycle(duty_cycle) ,	// input [6:0] duty_cycle
	.out_comp(PWM_signal) 	// output  out_comp
);
defparam PWM_GEN_inst.freq_max = 10000;
defparam PWM_GEN_inst.freq_min = 1;
defparam PWM_GEN_inst.SYSCLK_FRQ = 50000000;


// 4. SALIDA POR LEDS
LED_switch LED_switch_inst
(
	.switches(
        {SW0, SW1, SW2, SW3, SW4, SW5, SW6, SW7, SW8, SW9, SW10, SW11, SW12, SW13, SW14, SW15, SW16, SW17}
        ) ,	// input [number_LEDs-1:0] switches
	.LEDs(
        {LED0, LED1, LED2, LED3, LED4, LED5, LED6, LED7, LED8, LED9, LED10, LED11, LED12, LED13, LED14, LED15, LED16, LED17}
        ) ,	// output [number_LEDs-1:0] LEDs
	.value_ON(PWM_signal) 	// input  value_ON
);
defparam LED_switch_inst.number_LEDs = 18;





//---------------------PARAMETROS PARA LOS SUBMODULOS-------------------
// modificar aquí

// PARAMETROS DE LAS BARRAS
    // DUTY CYCLE
    parameter ubicacion_vertical_barra_DUTY = 0.45;        // 0=arriba, 1=abajo
    parameter porcentaje_pantalla_ancho_barra_DUTY = 0.85; // 0 a 1
    parameter porcentaje_pantalla_alto_barra_DUTY = 0.1;  // 0 a 1
    parameter espesor_marco_DUTY = 4; // pixeles, numero par

    // FRECUENCIA PWM
    parameter ubicacion_vertical_barra_FREQ = 0.8;        // 0 a 1
    parameter porcentaje_pantalla_ancho_barra_FREQ = 0.85; // 0 a 1
    parameter porcentaje_pantalla_alto_barra_FREQ = 0.1;  // 0 a 1
    parameter espesor_marco_FREQ = 4; // pixeles, numero par

// PARAMETROS DE LOS TEXTOS
    // DUTY CYCLE
    defparam visual_pantalla.TEXTO_LCD_dutycycle.ubicacion_vertical_texto = 0.2;
    defparam visual_pantalla.TEXTO_LCD_dutycycle.potencia_tamanyo = 2; // 0 = 8px, 1 = 16 px, 2 = 32 px, 3 = 64 px
    // FRECUENCIA PWM
    defparam visual_pantalla.TEXTO_LCD_pwmfreq.ubicacion_vertical_texto = 0.65;
    defparam visual_pantalla.TEXTO_LCD_pwmfreq.potencia_tamanyo = 2; // 0=8px, 1=16 px, 2=32 px, 3=64 px



//-----------------------PARAMETROS DEPENDIENTES (SUBMODULOS)-----------

// 1. OBTENCION DE PUNTO TACTIL
    defparam tactil_pantalla.obtener_valores_PWM.ubicacion_vertical_barra_DUTY = ubicacion_vertical_barra_DUTY;
    defparam tactil_pantalla.obtener_valores_PWM.porcentaje_pantalla_ancho_barra_DUTY = porcentaje_pantalla_ancho_barra_DUTY;
    defparam tactil_pantalla.obtener_valores_PWM.porcentaje_pantalla_alto_barra_DUTY = porcentaje_pantalla_alto_barra_DUTY;

    defparam tactil_pantalla.obtener_valores_PWM.ubicacion_vertical_barra_FREQ = ubicacion_vertical_barra_FREQ;
    defparam tactil_pantalla.obtener_valores_PWM.porcentaje_pantalla_ancho_barra_FREQ = porcentaje_pantalla_ancho_barra_FREQ;
    defparam tactil_pantalla.obtener_valores_PWM.porcentaje_pantalla_alto_barra_FREQ = porcentaje_pantalla_alto_barra_FREQ;

// 2. VISUALIZACION EN PANTALLA
    // PARAMETROS DE LAS BARRAS
        // DUTY CYCLE
        defparam visual_pantalla.BARRA_dutycycle.ubicacion_vertical_barra = ubicacion_vertical_barra_DUTY; // 0=arriba, 1=abajo
        defparam visual_pantalla.BARRA_dutycycle.porcentaje_pantalla_ancho_barra = porcentaje_pantalla_ancho_barra_DUTY;
        defparam visual_pantalla.BARRA_dutycycle.porcentaje_pantalla_alto_barra = porcentaje_pantalla_alto_barra_DUTY;
        defparam visual_pantalla.BARRA_dutycycle.espesor_marco = espesor_marco_DUTY; // numero par
        // FRECUENCIA PWM
        defparam visual_pantalla.BARRA_pwmfreq.ubicacion_vertical_barra = ubicacion_vertical_barra_FREQ; // 0=arriba, 1=abajo
        defparam visual_pantalla.BARRA_pwmfreq.porcentaje_pantalla_ancho_barra = porcentaje_pantalla_ancho_barra_FREQ;
        defparam visual_pantalla.BARRA_pwmfreq.porcentaje_pantalla_alto_barra = porcentaje_pantalla_alto_barra_FREQ;
        defparam visual_pantalla.BARRA_pwmfreq.espesor_marco = espesor_marco_FREQ; // numero par

endmodule
