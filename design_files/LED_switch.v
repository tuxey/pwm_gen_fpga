// --------------------------------------------------------------------
// Universitat Politècnica de València
// Departamento de Ingeniería Electronica
// --------------------------------------------------------------------
// Sistemas Digitales Programables - MUISE
// Curso 2020 - 2021
// --------------------------------------------------------------------
// Práctica 5
// --------------------------------------------------------------------
// Nombre del archivo: LED_switch.v
//
// Descripción: Asignación de salida a un cierto número de LEDs
//   (especificado mediante el parámetro number_LEDs), según el valor
//   de su switch correspondiente en la placa DE2-115.
//
//   La salida por el LED N es value_ON si el switch N está hacia arriba,
//   y 0 si no.
//
// --------------------------------------------------------------------
// Versión: V1.0 | Fecha Modificación: 05/02/2021
//
// Autores: Pablo Roig Monzón y Ángel Bellver Valera
// Ordenador de trabajo: Home y PC 8
// --------------------------------------------------------------------
module LED_switch (
    switches,
    LEDs,
    value_ON
);

parameter number_LEDs = 18;

input [number_LEDs-1:0] switches;
input value_ON;

output reg [number_LEDs-1:0] LEDs;

integer i;

always @(switches, value_ON)
begin
    for (i = 0; i< number_LEDs; i = i + 1)
    begin
        LEDs[i] = (switches[i]) ? value_ON : 0;
    end
end

endmodule