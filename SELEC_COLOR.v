// --------------------------------------------------------------------
// Universitat Politècnica de València
// Departamento de Ingeniería Electronica
// --------------------------------------------------------------------
// Sistemas Digitales Programables - MUISE
// Curso 2020 - 2021
// --------------------------------------------------------------------
// Práctica 5
// --------------------------------------------------------------------
// Nombre del archivo: SELEC_COLOR.v
//
// Descripción: Elige qué color RGB enviar a la pantalla en función de
//   las señales enviadas por los submódulos de barras y textos, y si
//   no hay ninguna señal activa, el color es el de fondo (blanco).
//
// --------------------------------------------------------------------
// Versión: V1.0 | Fecha Modificación: 08/02/2021
//
// Autores: Pablo Roig Monzón y Ángel Bellver Valera
// Ordenador de trabajo: Home y PC 8
// --------------------------------------------------------------------

module SELEC_COLOR (
    pixel_info,
    fondo_pantalla_ON,
    R, G, B
    );

//------------------------PARAMETROS-----------------------------------
parameter num_inputs  = 2; // en verdad este parámetro no es modificable por si solo
                           // habría que modificar el always de bajo
parameter n_datos = 4 * num_inputs; // cada input son 4 datos


//-------------------------ENTRADAS------------------------------------
input [n_datos-1:0] pixel_info;
/* 
 * cada medio byte de pixel_info contiene los siguientes bits:
 *
 *       3       2       1       0
 *     marco   barra   fondo   letra
 *
*/
input fondo_pantalla_ON;

//-------------------------SALIDAS-------------------------------------
output reg [7:0] R, G, B; // colores RGB

//------------------------COLORES--------------------------------------
    // 1. COLOR MARCO
    parameter [23:0] RGB_marco1 = 24'h_000000; // negro
    parameter [23:0] RGB_marco2 = 24'h_000000; // negro

    // 2. COLOR BARRA
    parameter [23:0] RGB_barra1 = 24'h_19ff19; // verde
    // parameter [23:0] RGB_barra2 = 24'h_fcb103; // naranja
    parameter [23:0] RGB_barra2 = 24'h_f23030; // rojo

    // 3. COLOR FONDO BARRA
    parameter [23:0] RGB_fondo_barra1 = 24'h_c0f0ef; // azul clarito
    parameter [23:0] RGB_fondo_barra2 = 24'h_fbffc9; // amarillo clarito

    // 4. COLOR LETRA
    parameter [23:0] RGB_letra1 = 24'h_188B39; // verde oscurito
    parameter [23:0] RGB_letra2 = 24'h_2618f0; // azul

    // 5. COLOR FONDO PANTALLA
    parameter [23:0] RGB_fondo = 24'h_FFFFFF; // blanco

//------------------------ASIGNACIONES---------------------------------
always @(pixel_info, fondo_pantalla_ON)
begin
    case (pixel_info)
        // DUTY CYCLE
        8'b_0001_0000: {R, G, B} = RGB_letra2;
        8'b_0010_0000: {R, G, B} = RGB_fondo_barra1;
        8'b_0100_0000: {R, G, B} = RGB_barra1;
        8'b_1000_0000: {R, G, B} = RGB_marco1;
        
        // PWM FREQUENCY
        8'b_0000_0001: {R, G, B} = RGB_letra2;
        8'b_0000_0010: {R, G, B} = RGB_fondo_barra1;
        8'b_0000_0100: {R, G, B} = RGB_barra2;
        8'b_0000_1000: {R, G, B} = RGB_marco2;

        default: {R, G, B} = (~fondo_pantalla_ON)? RGB_marco1: RGB_fondo; // el 1 del .mif es blanco
    endcase
end

endmodule