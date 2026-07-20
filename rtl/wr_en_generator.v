`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 18.07.2026 01:03:03
// Design Name: 
// Module Name: wr_en_generator
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module wr_en_generator (
 input rf_wr_en_reg_in,
 output wr_en_integer_file_out
);
 assign wr_en_integer_file_out = rf_wr_en_reg_in;
endmodule
