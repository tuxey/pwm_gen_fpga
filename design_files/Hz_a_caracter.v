// --------------------------------------------------------------------
// Universitat Politècnica de València
// Departamento de Ingeniería Electronica
// --------------------------------------------------------------------
// Sistemas Digitales Programables - MUISE
// Curso 2020 - 2021
// --------------------------------------------------------------------
// Práctica 5
// --------------------------------------------------------------------
// Nombre del archivo: Hz_a_caracter.v
//
// Descripción: Obtención del carácter que se ha de sacar de la ROM
//    de caracteres, en base a la columna y fila actual, y la frecuencia
//    en Hz que proviene de la recepción táctil.
//
// Con parámetros modificables de tamaño (según potencia, es decir, 8 px,
//    16 px, 32 px, etc.) y ubicación vertical dentro de la pantalla.
//    Aparece centrado respecto a la línea central vertical de la pantalla.
//    
// También se obtiene a la salida la columna y fila actuales respecto del
//    caracter en que se encuentran.
//
// --------------------------------------------------------------------
// Versión: V1.0 | Fecha Modificación: 05/02/2021
//
// Autores: Pablo Roig Monzón y Ángel Bellver Valera
// Ordenador de trabajo: Home y PC 8
// --------------------------------------------------------------------

module Hz_a_caracter (
    columna, fila,
    freq_Hz,
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
input [13:0] freq_Hz;
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

// columnas de los digitos : 10000 Hz
//                           12345678
parameter integer col_caracter_1 = col_max_pantalla/2 - 3*(8*multiplicador_tamanyo);
parameter integer col_caracter_2 = col_max_pantalla/2 - 2*(8*multiplicador_tamanyo);
parameter integer col_caracter_3 = col_max_pantalla/2 - 1*(8*multiplicador_tamanyo);
parameter integer col_caracter_4 = col_max_pantalla/2 + 0*(8*multiplicador_tamanyo);
parameter integer col_caracter_5 = col_max_pantalla/2 + 1*(8*multiplicador_tamanyo);
parameter integer col_caracter_6 = col_max_pantalla/2 + 2*(8*multiplicador_tamanyo);
parameter integer col_caracter_7 = col_max_pantalla/2 + 3*(8*multiplicador_tamanyo);
parameter integer col_caracter_8 = col_max_pantalla/2 + 4*(8*multiplicador_tamanyo);
parameter integer col_fin_caracteres = col_max_pantalla/2 + 5*(8*multiplicador_tamanyo);

//----------------------COMBINACIONALES--------------------------------

// 1. La fila actual corresponde al caracter
assign fila_caracter_ON = (fila >= fila_inicio_texto && fila < fila_fin_texto) ? 1 : 0;
assign fila_actual = (fila_caracter_ON) ? (fila - fila_inicio_texto) : 0;

// 2. Calculo del digito actual y de la columna actual
always @(columna, freq_Hz)
begin
    // 1/8
    if (columna >= col_caracter_1 && columna < col_caracter_2)
        begin
            col_caracter_ON = 1'b1;
            col_actual = columna - col_caracter_1;

            if (freq_Hz == 10000) // no va a ser mayor que 10000 Hz
                digito_actual = 1;
            else
                digito_actual = 11; // espacio
        end

    // 2/8
    else if (columna >= col_caracter_2 && columna < col_caracter_3)
        begin
            col_caracter_ON = 1'b1;
            col_actual = columna - col_caracter_2;

            if (freq_Hz >= 1000)
                digito_actual = (freq_Hz / 1000) % 10;
            else
                digito_actual = 11; // espacio
        end

    // 3/8
    else if (columna >= col_caracter_3 && columna < col_caracter_4)
        begin
            col_caracter_ON = 1'b1;
            col_actual = columna - col_caracter_3;

            if (freq_Hz >= 100)
                digito_actual = (freq_Hz / 100) % 10;
            else
                digito_actual = 11; // espacio
        end

    // 4/8
    else if (columna >= col_caracter_4 && columna < col_caracter_5)
        begin
            col_caracter_ON = 1'b1;
            col_actual = columna - col_caracter_4;

            if (freq_Hz >= 10)
                digito_actual = (freq_Hz / 10) % 10;
            else
                digito_actual = 11; // espacio
        end

    // 5/8
    else if (columna >= col_caracter_5 && columna < col_caracter_6)
        begin
            col_caracter_ON = 1'b1;
            col_actual = columna - col_caracter_5;

            // la freq siempre va a ser mayor a 1
            digito_actual = (freq_Hz / 1) % 10;
        end

    // 6/8 (espacio)
    else if (columna >= col_caracter_6 && columna < col_caracter_7)
        begin
            digito_actual = 11; // espacio
            col_caracter_ON = 1'b1;
            col_actual = columna - col_caracter_6;
        end

    // 7/8 (H)
    else if (columna >= col_caracter_7 && columna < col_caracter_8)
        begin
            digito_actual = 12; // H
            col_caracter_ON = 1'b1;
            col_actual = columna - col_caracter_7;
        end
    
    // 8/8 (z)
    else if (columna >= col_caracter_8 && columna < col_fin_caracteres)
        begin
            digito_actual = 13; // z
            col_caracter_ON = 1'b1;
            col_actual = columna - col_caracter_8;
        end

    // cualquier otro caso
    else
        begin
            digito_actual = 11; // espacio por si acaso
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
        12 : caracter = 6'o_10; // H
        13 : caracter = 6'o_54; // z
        default: caracter = 6'o_40;
    endcase
end

endmodule