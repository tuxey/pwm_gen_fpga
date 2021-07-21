// --------------------------------------------------------------------
// Universitat Politècnica de València
// Departamento de Ingeniería Electronica
// --------------------------------------------------------------------
// Sistemas Digitales Programables - MUISE
// Curso 2020 - 2021
// --------------------------------------------------------------------
// Práctica 5
// --------------------------------------------------------------------
// Nombre del archivo: FSM_TACTIL.v
// 
// Descripción: registra la señal iADC_PENIRQ_n, con el fin de
//   sincronizarla con el reloj del sistema y evitar metaestabilidad en
//   otros módulos que dependan de esta si el cambio en dicha señal
//   coincidiera con el flanco de subida del reloj del sistema.
//   Además, realiza un registro doble para evitar por completo la
//   metaestabilidad, ya que en caso de producirse, solo afectaría al
//   primer flip-flop y no al segundo.
//
// --------------------------------------------------------------------
// Versión: V1.0 | Fecha Modificación: 04/02/2021
// 
// Autores: Pablo Roig Monzón y Ángel Bellver Valera
// Ordenador de trabajo: 9 y Home
// --------------------------------------------------------------------
module registro_doble_1bit (CLK, RST_n, x, y);

input CLK, RST_n;
input x;

output reg y;

reg mid;

always @(posedge CLK or negedge RST_n)
begin
    if (!RST_n)
        begin
            mid <= 0;
            y <= 0;
        end
    else
        begin
            mid <= x;
            y <= mid;
        end
end

endmodule
