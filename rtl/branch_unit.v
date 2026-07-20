`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 17.07.2026 23:46:51
// Design Name: 
// Module Name: branch_unit
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


module branch_unit (
 input [4:0] opcode_6_to_2_in,
 input [2:0] funct3_in,
 input [31:0] rs1_in,
 input [31:0] rs2_in,
 output reg branch_taken_out
);
 wire signed [31:0] rs1_signed = rs1_in;
 wire signed [31:0] rs2_signed = rs2_in;
always @(*) begin
    branch_taken_out = 1'b0;
    if (opcode_6_to_2_in == 5'b11000) begin
        case (funct3_in)
            3'b000: branch_taken_out = (rs1_in == rs2_in);
            3'b001: branch_taken_out = (rs1_in != rs2_in);
            3'b100: branch_taken_out = (rs1_signed < rs2_signed);
            3'b101: branch_taken_out = (rs1_signed >= rs2_signed);
            3'b110: branch_taken_out = (rs1_in < rs2_in);
            3'b111: branch_taken_out = (rs1_in >= rs2_in);
            default: branch_taken_out = 1'b0;
        endcase
    end else if (opcode_6_to_2_in == 5'b11011 || opcode_6_to_2_in == 5'b11001) begin
        // JAL (1101111) / JALR (1100111): unconditional redirect
        branch_taken_out = 1'b1;
    end
end
endmodule
