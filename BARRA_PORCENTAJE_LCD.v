// --------------------------------------------------------------------
// Universitat Politècnica de València
// Departamento de Ingeniería Electronica
// --------------------------------------------------------------------
// Sistemas Digitales Programables - MUISE
// Curso 2020 - 2021
// --------------------------------------------------------------------
// Práctica 5
// --------------------------------------------------------------------
// Nombre del archivo: BARRA_PORCENTAJE_LCD.v
//
// Descripción: Generación de una barra de porcentaje en la pantalla LCD.
//    Con parámetros modificables de ancho, altura, espesor del marco,
//    ubicación vertical dentro de la pantalla. Aparece centrada
//    respecto a la línea central vertical de la pantalla.
//    
// Para la salida, se sacan 3 señales que dependen de la columna y fila
//    actual de la pantalla. Estas señales indican si el píxel actual es
//    de barra, de fondo o de marco.
//
// --------------------------------------------------------------------
// Versión: V1.0 | Fecha Modificación: 05/02/2021
//
// Autores: Pablo Roig Monzón y Ángel Bellver Valera
// Ordenador de trabajo: Home y PC 8
// --------------------------------------------------------------------

module BARRA_PORCENTAJE_LCD (porcentaje, fila, columna, barra_ON, marco_ON, fondo_ON);


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
output marco_ON;
output barra_ON;
output fondo_ON;

//-------------------------WIRES---------------------------------------
wire [n_col-1:0] col_fin_porcentaje;


//------------------------PARAMETROS-----------------------------------
parameter ubicacion_vertical_barra = 0.75;        // 0 a 1
parameter porcentaje_pantalla_ancho_barra = 0.85; // 0 a 1
parameter porcentaje_pantalla_alto_barra = 0.10;  // 0 a 1
parameter espesor_marco = 16; // pixeles

// parametros (B = barra indicadora)
parameter integer fila_centro_B = ubicacion_vertical_barra * fila_max_pantalla; // 360

parameter integer ancho_B = porcentaje_pantalla_ancho_barra * col_max_pantalla;  // 680 px
parameter integer alto_B  = porcentaje_pantalla_alto_barra * fila_max_pantalla; // 48 px

// filas y columnas de barra indicadora
parameter integer fila_inicio_B = fila_centro_B - alto_B/2; // 336
parameter integer fila_fin_B    = fila_centro_B + alto_B/2; // 384

parameter integer col_inicio_B = col_max_pantalla/2 - ancho_B/2; // 60
parameter integer col_fin_B    = col_max_pantalla/2 + ancho_B/2; // 740

// filas y columnas del marco de la barra indicadora
parameter integer fila_inicio_marco_top = fila_inicio_B - espesor_marco; // fila 320, por arriba
parameter integer fila_fin_marco_bottom = fila_fin_B + espesor_marco;    // fila 400, por abajo
parameter integer col_inicio_marco_left = col_inicio_B - espesor_marco;  // columna 44, por la izquierda
parameter integer col_fin_marco_right   = col_fin_B + espesor_marco;     // columna 756, por la derecha


//------------------------ASIGNACIONES---------------------------------
// calcular la columna limite en base al porcentaje
assign col_fin_porcentaje = (porcentaje * (col_fin_B - col_inicio_B)) / 100 + col_inicio_B + 2;

// definir si el pixel actual corresponde a la barra
assign barra_ON = (fila >= fila_inicio_B    &&
                   fila <= fila_fin_B       &&
                   columna >= col_inicio_B  &&
                   columna <= col_fin_porcentaje)
                   ? 1 : 0;

// definir si el pixel actual corresponde al fondo de la barra
assign fondo_ON = (fila >= fila_inicio_B    &&
                   fila <= fila_fin_B       &&
                   columna > col_fin_porcentaje  &&
                   columna < col_fin_B)
                   ? 1 : 0;

// definir si el pixel actual corresponde al marco
assign marco_ON = (barra_ON || fondo_ON)? 0 // si esta activo el fondo OR la barra, no es marco
                :
                (
                 (fila >= fila_inicio_marco_top    &&
                  fila <= fila_fin_marco_bottom    &&
                  columna >= col_inicio_marco_left &&
                  columna <= col_fin_marco_right) ?
                  1 : 0
                );

endmodule