// --------------------------------------------------------------------
// Universitat Politècnica de València
// Departamento de Ingeniería Electronica
// --------------------------------------------------------------------
// Sistemas Digitales Programables - MUISE
// Curso 2020 - 2021
// --------------------------------------------------------------------
// Práctica 1
// --------------------------------------------------------------------
// Nombre del archivo: contador.v
//
// Descripción: Este código Verilog implementa un contador de 16 bits con
// la siguiente funcionalidad de sus entradas y salidas:
//
//    Módulo por defecto: 20
//    iCLK:     reloj activo por posedge
//    iRST_n:   reset activo a nivel bajo (asíncrono)
//    con Terminal Count (oTC)
//
//    UP/DOWN (iUP_DOWN):
//    UP    si iUP_DOWN 1
//    DOWN  si iUP_DOWN 0
//
// --------------------------------------------------------------------
// Versión: V1.0 | Fecha Modificación: 13/10/2020
//
// Autores: Pablo Roig Monzón y Ángel Bellver Valera
// Ordenador de trabajo: Home
// --------------------------------------------------------------------

module contador (iCLK, iENABLE, iRST_n, oCOUNT, oTC, iUP_DOWN);
   parameter fin_cuenta = 20;

   `include "MathFun.vh"
   parameter n = CLogB2(fin_cuenta - 1);

   input 		iCLK, iENABLE, iRST_n, iUP_DOWN;
   output	   oTC;
   output reg  [n-1:0] oCOUNT;

   always @ (posedge iCLK or negedge iRST_n)
   begin
      if (!iRST_n)
         oCOUNT <= {n{1'b0}};
        
      else if (iENABLE == 1'b1)
      begin
         if (iUP_DOWN)                // modo UP
            if (oCOUNT == fin_cuenta-1)
               oCOUNT <= {n{1'b0}};
            else
               oCOUNT <= oCOUNT + 1;
         
         else                        // modo DOWN
            if (oCOUNT == 0)
               oCOUNT <= fin_cuenta-1;
            else
               oCOUNT <= oCOUNT - 1;
      end
   end
   
   assign oTC = (iUP_DOWN)?
                  ((oCOUNT == (fin_cuenta-1))?  // contar UP hasta fin_cuenta-1
                     iENABLE: 1'b0):   // TC=1 solo cuando iENABLE==1, si no, TC=0
                    
                  ((oCOUNT == 0)?               // contar DOWN hasta 0
                     iENABLE: 1'b0);   // TC=1 solo cuando iENABLE==1, si no, TC=0
endmodule

