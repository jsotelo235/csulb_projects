`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    19:56:34 04/27/2017 
// Design Name: 
// Module Name:    one_shot 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module one_shot(clk_in, reset, D_in, D_out);

     input     D_in, clk_in, reset;
     output    D_out;
     wire      D_out;
     
     reg       q9, q8, q7, q6, q5, q4, q3, q2, q1, q0;
     
     always @ (posedge clk_in or posedge reset)
          if(reset == 1'b1)
               { q9, q8, q7, q6, q5, q4, q3, q2, q1, q0} <= 10'b0;
          else begin
               q9 <= q8; q8 <= q7; q7 <= q6; q6 <= q5; q5 <= q4;
               q4 <= q3; q3 <= q2; q2 <= q1; q1 <= q0; q0 <= D_in;
          end
          
     assign D_out = !q9 & q8 & q7 & q6 & q5 &
                     q4 & q3 & q2 & q1 & q0;
endmodule
