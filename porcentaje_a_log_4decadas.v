// --------------------------------------------------------------------
// Universitat Politècnica de València
// Departamento de Ingeniería Electronica
// --------------------------------------------------------------------
// Sistemas Digitales Programables - MUISE
// Curso 2020 - 2021
// --------------------------------------------------------------------
// Práctica 5
// --------------------------------------------------------------------
// Nombre del archivo: porcentaje_a_log_4decadas.v
//
// Descripción: Módulo donde se convierte un valor de 0 a 100 (escala
//   lineal) a un valor en escala logarítmica de 4 décadas (de 1 a 10000).
//   Para ello se utiliza una simple lookup table.
//   Los valores se han generado mediante el siguiente script en Python:
//   
//   ******************************************************************
//     s = """"""
//     n = 4 # numero de decadas de la escala logaritmica
//     
//     for i in range(0, 101):
//         s += str(i) + ": y = " + str(round(10**(i*n/100))) + ";\n"
//     print(s)   
//   ******************************************************************
//
// --------------------------------------------------------------------
// Versión: V1.0 | Fecha Modificación: 08/02/2021
//
// Autores: Pablo Roig Monzón y Ángel Bellver Valera
// Ordenador de trabajo: Home y PC 8
// --------------------------------------------------------------------

module porcentaje_a_log_4decadas(
   input  [6:0]  x,
   output reg  [13:0] y
);

// Entrada X: escala lineal de 0 a 100
// Salida Y:  escala logarítmica de 4 décadas (de 1 a 10000)

always @(x)
begin
    case (x)
        0: y = 1;
        1: y = 1;
        2: y = 1;
        3: y = 1;
        4: y = 1;
        5: y = 2;
        6: y = 2;
        7: y = 2;
        8: y = 2;
        9: y = 2;
        10: y = 3;
        11: y = 3;
        12: y = 3;
        13: y = 3;
        14: y = 4;
        15: y = 4;
        16: y = 4;
        17: y = 5;
        18: y = 5;
        19: y = 6;
        20: y = 6;
        21: y = 7;
        22: y = 8;
        23: y = 8;
        24: y = 9;
        25: y = 10;
        26: y = 11;
        27: y = 12;
        28: y = 13;
        29: y = 14;
        30: y = 16;
        31: y = 17;
        32: y = 19;
        33: y = 21;
        34: y = 23;
        35: y = 25;
        36: y = 28;
        37: y = 30;
        38: y = 33;
        39: y = 36;
        40: y = 40;
        41: y = 44;
        42: y = 48;
        43: y = 52;
        44: y = 58;
        45: y = 63;
        46: y = 69;
        47: y = 76;
        48: y = 83;
        49: y = 91;
        50: y = 100;
        51: y = 110;
        52: y = 120;
        53: y = 132;
        54: y = 145;
        55: y = 158;
        56: y = 174;
        57: y = 191;
        58: y = 209;
        59: y = 229;
        60: y = 251;
        61: y = 275;
        62: y = 302;
        63: y = 331;
        64: y = 363;
        65: y = 398;
        66: y = 437;
        67: y = 479;
        68: y = 525;
        69: y = 575;
        70: y = 631;
        71: y = 692;
        72: y = 759;
        73: y = 832;
        74: y = 912;
        75: y = 1000;
        76: y = 1096;
        77: y = 1202;
        78: y = 1318;
        79: y = 1445;
        80: y = 1585;
        81: y = 1738;
        82: y = 1905;
        83: y = 2089;
        84: y = 2291;
        85: y = 2512;
        86: y = 2754;
        87: y = 3020;
        88: y = 3311;
        89: y = 3631;
        90: y = 3981;
        91: y = 4365;
        92: y = 4786;
        93: y = 5248;
        94: y = 5754;
        95: y = 6310;
        96: y = 6918;
        97: y = 7586;
        98: y = 8318;
        99: y = 9120;
        100: y = 10000;
        default: y = 0;
    endcase
end

endmodule