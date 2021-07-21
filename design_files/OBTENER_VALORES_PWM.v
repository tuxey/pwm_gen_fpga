// --------------------------------------------------------------------
// Universitat Politècnica de València
// Departamento de Ingeniería Electronica
// --------------------------------------------------------------------
// Sistemas Digitales Programables - MUISE
// Curso 2020 - 2021
// --------------------------------------------------------------------
// Práctica 5
// --------------------------------------------------------------------
// Nombre del archivo: OBTENER_VALORES_PWM.v
//
// Descripción: Módulo donde se obtienen los valores de PWM
//   (duty cycle y frecuencia), según las coordenadas del contacto con
//   la pantalla LCD.
//   El decidir si las coordenadas pertenecen a duty cycle, a frecuencia o
//   a ninguno viene dado por los parámetros, que son los mismos que se
//   le pasan a la visualización de las barras correspondientes en la
//   pantalla.
//
//   Si aún no se ha producido ningún toque en la pantalla, los valores
//   fijados son del 50%. Cuando se produce un toque en la pantalla, se
//   procesan esos valores, y mientras no se produzca un nuevo toque se
//   mantienen los últimos valores obtenidos.
//
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
//
// --------------------------------------------------------------------
// Versión: V1.0 | Fecha Modificación: 05/02/2021
//
// Autores: Pablo Roig Monzón y Ángel Bellver Valera
// Ordenador de trabajo: Home y PC 8
// --------------------------------------------------------------------



module OBTENER_VALORES_PWM (
    CLK, fin_transmision,
    enable_conversion,
    X_COORD, Y_COORD,
    duty_cycle, freq_porcentaje
);

//-------------------------ENTRADAS------------------------------------
input CLK;
input fin_transmision;
input enable_conversion; // de la FSM
input [11:0] X_COORD; // 12'h_000 a 12'h_FFF
input [11:0] Y_COORD; // 12'h_000 a 12'h_FFF

//-------------------------SALIDAS-------------------------------------
output reg [6:0] duty_cycle;
output reg [6:0] freq_porcentaje;


//-------------------------PARAMETROS BARRA DUTY CYCLE-----------------
parameter ubicacion_vertical_barra_DUTY = 0.45;        // 0 a 1
parameter porcentaje_pantalla_ancho_barra_DUTY = 0.85; // 0 a 1
parameter porcentaje_pantalla_alto_barra_DUTY = 0.10;  // 0 a 1

// parametros (B = barra indicadora)
parameter integer X_centro_B_DUTY = (1 - ubicacion_vertical_barra_DUTY) * 12'h_FFF; // fila y X van al contrario
parameter integer ancho_B_DUTY = porcentaje_pantalla_ancho_barra_DUTY * 12'h_FFF + 10;
parameter integer alto_B_DUTY  = porcentaje_pantalla_alto_barra_DUTY * 12'h_FFF;

// filas y columnas de barra indicadora
parameter integer X_inicio_B_DUTY = X_centro_B_DUTY - alto_B_DUTY/2;
parameter integer X_fin_B_DUTY    = X_centro_B_DUTY + alto_B_DUTY/2;

parameter integer Y_inicio_B_DUTY = (12'h_FFF - ancho_B_DUTY)/2;
parameter integer Y_fin_B_DUTY    = (12'h_FFF + ancho_B_DUTY)/2;


//-------------------------PARAMETROS BARRA FREQUENCY------------------
parameter ubicacion_vertical_barra_FREQ = 0.8;        // 0 a 1
parameter porcentaje_pantalla_ancho_barra_FREQ = 0.85; // 0 a 1
parameter porcentaje_pantalla_alto_barra_FREQ = 0.10;  // 0 a 1

// parametros (B = barra indicadora)
parameter integer X_centro_B_FREQ = (1 - ubicacion_vertical_barra_FREQ) * 12'h_FFF; // fila y X van al contrario
parameter integer ancho_B_FREQ = porcentaje_pantalla_ancho_barra_FREQ * 12'h_FFF + 10;
parameter integer alto_B_FREQ  = porcentaje_pantalla_alto_barra_FREQ * 12'h_FFF;

// filas y columnas de barra indicadora
parameter integer X_inicio_B_FREQ = X_centro_B_FREQ - alto_B_FREQ/2; 
parameter integer X_fin_B_FREQ    = X_centro_B_FREQ + alto_B_FREQ/2;

parameter integer Y_inicio_B_FREQ = 12'h_FFF/2 - ancho_B_FREQ/2;
parameter integer Y_fin_B_FREQ    = 12'h_FFF/2 + ancho_B_FREQ/2;


//-------------------------COMBINACIONALES------------------------------

// la ubicación en Y no depende del tamaño de la pantalla, sino que
// la coordenada FFF es el final de la horizontal de la pantalla
always @(posedge CLK)
begin
    if (enable_conversion)
        begin
                // barra DUTY CYCLE
            if (fin_transmision
                &&
                X_COORD >= X_inicio_B_DUTY && X_COORD <= X_fin_B_DUTY // fila
                &&
                Y_COORD >= Y_inicio_B_DUTY && Y_COORD <= Y_fin_B_DUTY) // columna
                begin
                    // actualizar DUTY y mantener freq
                    duty_cycle <= ((Y_COORD - Y_inicio_B_DUTY) * 100) / ancho_B_DUTY;
                    freq_porcentaje <= freq_porcentaje;
                    $display("actualizando DUTY");
                    $display("\tY_COORD = %D", Y_COORD);
                    $display("\tY_inicio_B_DUTY = %D", Y_inicio_B_DUTY);
                    $display("\tancho_B_DUTY = %D", ancho_B_DUTY);
                    $display("\tduty_cycle = %D", duty_cycle);
                    $display("\tfreq_porcentaje = %D\n", freq_porcentaje);
                end

            // barra FRECUENCIA PWM
            else if (fin_transmision
                &&
                X_COORD >= X_inicio_B_FREQ && X_COORD <= X_fin_B_FREQ // fila
                &&
                Y_COORD >= Y_inicio_B_FREQ && Y_COORD <= Y_fin_B_FREQ) // columna
                begin
                    // actualizar FREQ y mantener duty
                    freq_porcentaje <= ((Y_COORD - Y_inicio_B_FREQ) * 100) / ancho_B_FREQ;
                    duty_cycle <= duty_cycle;
                    $display("actualizando FREQ");
                    $display("\tY_COORD = %D", Y_COORD);
                    $display("\tduty_cycle = %D", duty_cycle);
                    $display("\tfreq_porcentaje = %D\n", freq_porcentaje);
                end
            else
                // mantener si no se ha recibido un nuevo fin_transmision
                begin
                    duty_cycle <= duty_cycle;
                    freq_porcentaje <= freq_porcentaje;
                end
        end
    else // not enable_conversion
        begin
            duty_cycle <= 50;
            freq_porcentaje <= 50;
        end 
end


endmodule