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
// Descripción: Máquina de Estados Finitos con 2 estados. Se utiliza
//   para que en el arranque del sistema exista un valor de duty cycle
//   y de frecuencia que mostrar por la pantalla.
//
//   Entrada:
//     iFin_transmision: señal proveniente de la FSM_ADC que indica el
//                       fin de la recepción de coordenadas.
//  
//   Salida:
//     oEnable_conversion: En el arranque del sistema es 0. Una vez ya
//                         se ha hecho al menos una conversión de
//                         coordenadas, esta salida se activa.
//
// --------------------------------------------------------------------
// Versión: V1.0 | Fecha Modificación: 04/02/2021
// 
// Autores: Pablo Roig Monzón y Ángel Bellver Valera
// Ordenador de trabajo: 9
// --------------------------------------------------------------------

module FSM_TACTIL (
    iCLK, iRST_n,
    iFin_transmision,
    oEnable_conversion
);

//-------------------------ENTRADAS------------------------------------
input iCLK, iRST_n;
input iFin_transmision;

//-------------------------SALIDAS-------------------------------------
output reg oEnable_conversion;

//-----------------------DEFINICION DE ESTADOS-------------------------
localparam S0 = 1'b0,
           S1 = 1'b1;

(*syn_encoding="one-hot"*) reg estado_act, estado_sig;


//-----------------------MEMORIA DE ESTADO-----------------------------
always @(posedge iCLK or negedge iRST_n)
begin
    if (!iRST_n)
        estado_act <= S0;
    else
        estado_act <= estado_sig;
end


//---------------LÓGICA DEL ESTADO SIGUIENTE Y DE SALIDA---------------
always @(estado_act, iFin_transmision)
begin
    // para no generar latch
    oEnable_conversion <= 1'b0;
    case (estado_act)
        S0:
            begin
                if (iFin_transmision)
                    begin
                        oEnable_conversion <= 1'b1;
                        estado_sig <= S1;
                    end
                else
                    begin
                        oEnable_conversion <= 1'b0;
                        estado_sig <= S0;
                    end
            end
        S1:
            begin
                oEnable_conversion <= 1'b1;
                estado_sig <= S1;
            end

        default:
            begin
                oEnable_conversion <= 1'b0;
                estado_sig <= S0;
            end
    endcase
end

endmodule