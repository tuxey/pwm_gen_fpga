// --------------------------------------------------------------------
// Universitat Politècnica de València
// Departamento de Ingeniería Electronica
// --------------------------------------------------------------------
// Sistemas Digitales Programables - MUISE
// Curso 2020 - 2021
// --------------------------------------------------------------------
// Práctica 5
// --------------------------------------------------------------------
// Nombre del archivo: porcentaje_a_caracter.v
//
// Descripción: Módulo donde se obtiene el caracter a extraer de la ROM
//   en función del porcentaje y de la fila y la columna actuales.
//   Para ello, se generan 4 zonas de caracteres en función del tamaño
//   de estos, lo que decide qué caracter se extrae: número del 0 al 9
//   o símbolo de porcentaje. Si el 0 está a la izquierda, no se muestra.
//
//   También se obtiene a la salida dos señales binarias que indican si
//   la fila y columna actual corresponde a un caracter, para evitar
//   pintar la pantalla en una zona que no corresponda.
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
// Versión: V1.0 | Fecha Modificación: 08/02/2021
//
// Autores: Pablo Roig Monzón y Ángel Bellver Valera
// Ordenador de trabajo: Home y PC 8
// --------------------------------------------------------------------

module porcentaje_a_caracter (
    columna, fila,
    porcentaje,
    digito_actual,
    col_caracter_ON, fila_caracter_ON,
    caracter,
    col_actual, fila_actual
    );

`include "MathFun.vh"

// parámetros de la pantalla, *zona visible*
parameter col_max_pantalla  = 800;
parameter fila_max_pantalla = 480;
// número de bits de:
parameter n_col = CLogB2(col_max_pantalla - 1); // columnas
parameter n_fil = CLogB2(fila_max_pantalla - 1); // filas

//-------------------------ENTRADAS------------------------------------
input [6:0] porcentaje;
input [n_col-1:0] columna;
input [n_fil-1:0] fila;

//-------------------------SALIDAS-------------------------------------
// digito actual del valor PWM en base a la columna
output reg [3:0] digito_actual; // 0-9, 10 es el %, 11 es un espacio

// si está en zona del caracter
output reg col_caracter_ON;
output     fila_caracter_ON;

// caracter a obtener de la ROM (valor entre 0 y 64)
output reg [5:0] caracter; // ej. caracter = 6'o_44;

// columna y fila referenciadas al caracter actual
output reg [n_col-1:0] col_actual;
output     [n_fil-1:0] fila_actual;

//------------------------PARAMETROS-----------------------------------
parameter potencia_tamanyo = 2;      // 0 = 8px, 1 = 16 px, 2 = 32 px, 3 = 64 px
parameter multiplicador_tamanyo = 2 ** potencia_tamanyo; // tamaño caracter = 8 px * 2^potencia_tamanyo

// ubicacion texto en la pantalla
parameter ubicacion_vertical_texto = 0.2; // 0 a 1, indica posición en la pantalla

// filas del texto
parameter integer fila_inicio_texto = ubicacion_vertical_texto * fila_max_pantalla;
parameter integer fila_fin_texto    = fila_inicio_texto + (8*multiplicador_tamanyo);

// columnas de los digitos
parameter integer col_caracter_1 = col_max_pantalla/2 - 2*(8*multiplicador_tamanyo);
parameter integer col_caracter_2 = col_max_pantalla/2 - 1*(8*multiplicador_tamanyo);
parameter integer col_caracter_3 = col_max_pantalla/2 - 0*(8*multiplicador_tamanyo);
parameter integer col_caracter_4 = col_max_pantalla/2 + 1*(8*multiplicador_tamanyo);
parameter integer col_fin_caracteres = col_max_pantalla/2 + 2*(8*multiplicador_tamanyo);

//----------------------COMBINACIONALES--------------------------------

// 1. La fila actual corresponde al caracter
assign fila_caracter_ON = (fila >= fila_inicio_texto && fila < fila_fin_texto) ? 1 : 0;
assign fila_actual = (fila_caracter_ON) ? (fila - fila_inicio_texto) : 0;

// 2. Calculo del digito actual y de la columna actual
always @(columna, porcentaje)
begin
    if (columna >= col_caracter_1 && columna < col_caracter_2)
        begin
            col_caracter_ON = 1'b1;
            col_actual = columna - col_caracter_1;

            if (porcentaje == 100)
                digito_actual = 1;
            else
                digito_actual = 11; // espacio
        end
    else if (columna >= col_caracter_2 && columna < col_caracter_3)
        begin
            col_caracter_ON = 1'b1;
            col_actual = columna - col_caracter_2;

            if (porcentaje >= 10)
                digito_actual = (porcentaje / 10) % 10;
            else
                digito_actual = 11; // espacio
        end
    else if (columna >= col_caracter_3 && columna < col_caracter_4)
        begin
            digito_actual = porcentaje % 10;
            col_caracter_ON = 1'b1;
            col_actual = columna - col_caracter_3;
        end
    else if (columna >= col_caracter_4 && columna < col_fin_caracteres)
        begin
            digito_actual = 10; // porcentaje (%)
            col_caracter_ON = 1'b1;
            col_actual = columna - col_caracter_4;
        end
    else
        begin
            digito_actual = 11; // espacio
            col_caracter_ON = 1'b0;
            col_actual = 0; // para no malgastar conmutaciones
        end
end

// 3. Convertir digito actual a caracter
always @(digito_actual)
begin
    case (digito_actual)
        0  : caracter = 6'o_60;
        1  : caracter = 6'o_61;
        2  : caracter = 6'o_62;
        3  : caracter = 6'o_63;
        4  : caracter = 6'o_64;
        5  : caracter = 6'o_65;
        6  : caracter = 6'o_66;
        7  : caracter = 6'o_67;
        8  : caracter = 6'o_70;
        9  : caracter = 6'o_71;
        10 : caracter = 6'o_45; // %
        11 : caracter = 6'o_40; //   (espacio)
        //12 : caracter = 6'o_10;
        default: caracter = 6'o_40;
    endcase
end

endmodule