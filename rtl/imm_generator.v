`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 17.07.2026 23:29:55
// Design Name: 
// Module Name: imm_generator
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


module imm_generator (
 input [31:7] instr_in,
 input [2:0] imm_type_in,
 output reg [31:0] imm_out
);
 always @(*) begin
 case (imm_type_in)
 3'b000: imm_out = {{20{instr_in[31]}}, instr_in[31:20]};
 3'b001: imm_out = {{20{instr_in[31]}}, instr_in[31:25], instr_in[11:7]};
 3'b010: imm_out = {{19{instr_in[31]}}, instr_in[31], instr_in[7], instr_in[30:25], instr_in[11:8], 1'b0};
 3'b011: imm_out = {instr_in[31:12], 12'b0};
 3'b100: imm_out = {{11{instr_in[31]}}, instr_in[31], instr_in[19:12], instr_in[20], instr_in[30:21], 1'b0};
 3'b101: imm_out = {27'b0, instr_in[19:15]};
 default: imm_out = 32'b0;
 endcase
 end
endmodule
