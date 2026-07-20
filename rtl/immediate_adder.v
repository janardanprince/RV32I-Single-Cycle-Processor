`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 17.07.2026 23:38:26
// Design Name: 
// Module Name: immediate_adder
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


module immediate_adder (
 input [31:0] pc_in,
 input [31:0] rs1_in,
 input [31:0] imm_in,
 input iadder_src_in,
 output [31:0] iadder_out
);
 assign iadder_out = (iadder_src_in) ? (rs1_in + imm_in) : (pc_in + imm_in);
endmodule
