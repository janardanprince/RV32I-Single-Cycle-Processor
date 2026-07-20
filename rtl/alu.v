`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 17.07.2026 22:46:10
// Design Name: 
// Module Name: alu
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


module alu (
 input wire [31:0] op_1_in,
 input wire [31:0] op_2_in,
 input wire [3:0] alu_ctrl_in,
 input wire lui_sel_in,
 output reg [31:0] result_out,
 output wire eq_out,
 output wire lt_out,
 output wire ltu_out
);
 localparam FUNCT3_ADD_SUB = 3'b000;
 localparam FUNCT3_SLL = 3'b001;
 localparam FUNCT3_SLT = 3'b010;
 localparam FUNCT3_SLTU = 3'b011;
 localparam FUNCT3_XOR = 3'b100;
 localparam FUNCT3_SRL_SRA = 3'b101;
 localparam FUNCT3_OR = 3'b110;
 localparam FUNCT3_AND = 3'b111;
 wire signed [31:0] signed_op1;
 wire signed [31:0] signed_op2;
 wire [31:0] minus_op2;
 wire [31:0] adder_op2;
 wire [31:0] add_sub_result;
 wire [31:0] sll_result;
 wire [31:0] srl_result;
 wire [31:0] sra_result;
 wire [31:0] shr_result;
 wire slt_result;
 wire sltu_result;
 assign signed_op1 = op_1_in;
 assign signed_op2 = op_2_in;
 assign minus_op2 = ~op_2_in + 32'd1;
 assign adder_op2 = (alu_ctrl_in[3]) ? minus_op2 : op_2_in;
 assign add_sub_result = op_1_in + adder_op2;
 assign sll_result = op_1_in << op_2_in[4:0];
 assign srl_result = op_1_in >> op_2_in[4:0];
 assign sra_result = signed_op1 >>> op_2_in[4:0];
 assign shr_result = (alu_ctrl_in[3]) ? sra_result : srl_result;
 assign eq_out = (op_1_in == op_2_in);
 assign ltu_out = (op_1_in < op_2_in);
 assign lt_out = (signed_op1 < signed_op2);
 assign sltu_result = ltu_out;
 assign slt_result = lt_out;
 always @(*) begin
 if (lui_sel_in) begin
 result_out = op_2_in;
 end
 else begin
 case (alu_ctrl_in[2:0])
 FUNCT3_ADD_SUB : result_out = add_sub_result;
 FUNCT3_SLL : result_out = sll_result;
 FUNCT3_SLT : result_out = {31'b0, slt_result};
 FUNCT3_SLTU : result_out = {31'b0, sltu_result};
 FUNCT3_XOR : result_out = op_1_in ^ op_2_in;
 FUNCT3_SRL_SRA : result_out = shr_result;
 FUNCT3_OR : result_out = op_1_in | op_2_in;
 FUNCT3_AND : result_out = op_1_in & op_2_in;
 default : result_out = 32'b0;
 endcase
 end
 end
endmodule
