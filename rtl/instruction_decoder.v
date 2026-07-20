`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 17.07.2026 23:35:17
// Design Name: 
// Module Name: instruction_decoder
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


module instruction_decoder (
 input [31:0] instr_in,
 output [6:0] opcode_out,
 output [2:0] funct3_out,
 output [6:0] funct7_out,
 output [4:0] rs1_addr_out,
 output [4:0] rs2_addr_out,
 output [4:0] rd_addr_out,
 output [31:7] instr_31_7_out
);
 wire [31:0] instr;
 assign instr = instr_in;
 assign opcode_out = instr[6:0];
 assign rd_addr_out = instr[11:7];
 assign funct3_out = instr[14:12];
 assign rs1_addr_out = instr[19:15];
 assign rs2_addr_out = instr[24:20];
 assign funct7_out = instr[31:25];
 assign instr_31_7_out = instr[31:7];
endmodule

