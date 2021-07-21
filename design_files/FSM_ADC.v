// --------------------------------------------------------------------
// Universitat Politècnica de València
// Departamento de Ingeniería Electronica
// --------------------------------------------------------------------
// Sistemas Digitales Programables - MUISE
// Curso 2020 - 2021
// --------------------------------------------------------------------
// Práctica 4
// --------------------------------------------------------------------
// Nombre del archivo: FSM_ADC.v
// 
// Descripción: Máquina de Estados Finitos como ControlPath del módulo
//   ADC_CONTROl.
//   Esta FSM espera a la interrupción iADC_PENIRQ_n para activar las
//   señales oEna_Trans y oADC_CS. Una vez acabada la recepción de los
//   datos, habilita la salida oFin_Trans, desactiva las anteriores
//   señales y espera un retardo antes de volver a comenzar el ciclo,
//   para que la lectura de puntos de contacto con la pantalla sea
//   espaciada.
//   
// Inputs:
//   iCLK:          Señal de reloj 50 MHz
//   iRST_n:        Reset asíncrono activo a nivel bajo
//   idclk:         Señal de reloj del ADC, 70 kHz
//   ifin_80:       Fin de cuenta del contador módulo 80
//   iADC_PENIRQ_n: Interrupción de contacto con la pantalla
//
// Outputs:
//   oADC_CS:    Chip Select entre el ADC (1) y la visualización LCD (0)
//   oEna_Trans: Bit que habilita la transmisión y recepción de señales
//               hacia y del ADC
//   oFin_Trans: Bit que indica que la finalización de la comunicación
//
// --------------------------------------------------------------------
// Versión: V1.0 | Fecha Modificación: 1/12/2020
// 
// Autores: Pablo Roig Monzón y Ángel Bellver Valera
// Ordenador de trabajo: 9
// --------------------------------------------------------------------

module FSM_ADC (
    iCLK,
    iRST_n,
    idclk,
    ifin_80,
    oADC_CS,
    iADC_PENIRQ_n,
    oEna_Trans,
    oFin_Trans,
    wait_irq,
    wait_en
);

input   iCLK;
input   iRST_n;
input   idclk;
input   ifin_80;
input   iADC_PENIRQ_n;

output reg oADC_CS;
output reg oEna_Trans;
output reg oFin_Trans;

input wait_irq;
output reg wait_en;

localparam S0 = 4'b0000,
           S1 = 4'b0001,
           S2 = 4'b0010,
           S3 = 4'b0100,
           S4 = 4'b1000;

(*syn_encoding="one-hot"*) reg [3:0] estado_act, estado_sig;

// memoria de estado
always @(posedge iCLK or negedge iRST_n)
begin
    if (!iRST_n)
        estado_act <= S0;
    else
        estado_act <= estado_sig;
end

// lógica del estado siguiente y de salida
always @(estado_act, idclk, ifin_80, iADC_PENIRQ_n, wait_irq)
begin
    // para no generar latch
    oADC_CS <= 1'b0;
    oEna_Trans <= 1'b0;
    oFin_Trans <= 1'b0;
    wait_en <= 1'b0;
    case (estado_act)
        S0:
            begin
                // determinación de salidas
                oEna_Trans <= 1'b0;
                oADC_CS <= 1'b0;
                oFin_Trans <= 1'b0;

                // espera ciclos
                wait_en <= 1'b0;

                // determinación del estado siguiente
                estado_sig <= S1;
            end
        S1:
            begin
                // determinación de salidas
                oEna_Trans <= 1'b0;
                oADC_CS <= 1'b0;
                oFin_Trans <= 1'b0;

                // espera ciclos
                wait_en <= 1'b0;

                // determinación del estado siguiente
                if (iADC_PENIRQ_n)
                    estado_sig <= S1;
                else // activo a nivel bajo
                    estado_sig <= S2;
            end

        S2:
            begin
                // determinación de salidas
                oEna_Trans <= 1'b1;
                oADC_CS <= 1'b1;
                oFin_Trans <= 1'b0;

                // espera ciclos
                wait_en <= 1'b0;

                // determinación del estado siguiente
                if (idclk && ifin_80)
                    estado_sig <= S3;
                else
                    estado_sig <= S2;
            end

        S3:
            begin
                // determinación de salidas
                oEna_Trans <= 1'b0;
                oADC_CS <= 1'b0;
                oFin_Trans <= 1'b1;

                // espera ciclos
                wait_en <= 1'b0;

                // determinación del estado siguiente
                estado_sig <= S4;
            end

        S4:
            begin
                // determinación de salidas
                oEna_Trans <= 1'b0;
                oADC_CS <= 1'b0;
                oFin_Trans <= 1'b0; // estaba a 1 antes

                // espera ciclos
                wait_en <= 1'b1;

                // determinación del estado siguiente
                if (wait_irq)
                    estado_sig <= S1;
                else
                    estado_sig <= S4;
            end
        
        default:
            begin
                oADC_CS <= 1'b0;
                oEna_Trans <= 1'b0;
                oFin_Trans <= 1'b0;
                estado_sig <= S0;
                wait_en <= 0;
            end
    endcase
end

endmodule