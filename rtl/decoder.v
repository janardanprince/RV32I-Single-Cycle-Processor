`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 17.07.2026 23:51:33
// Design Name: 
// Module Name: decoder
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


module decoder (
 input [6:0] opcode_in,
 input funct7_5_in,
 input [2:0] funct3_in,
 output reg [3:0] alu_ctrl_out,
 output reg lui_sel_out,
 output reg mem_wr_req_out,
 output reg mem_rd_req_out,
 output reg [1:0] load_size_out,
 output reg load_unsigned_out,
 output reg alu_src_out,
 output reg iadder_src_out,
 output reg rf_wr_en_out,
 output reg [2:0] wb_mux_sel_out,
 output reg [2:0] imm_type_out,
 output reg illegal_instr_out
);
 localparam WB_ALU = 3'b000;
 localparam WB_LU = 3'b001;
 localparam WB_IMM = 3'b010;
 localparam WB_IADDER_OUT = 3'b011;
 localparam WB_PC_PLUS = 3'b101;
 always @(*) begin
 alu_ctrl_out = 4'b0000;
 lui_sel_out = 1'b0;
 mem_wr_req_out = 1'b0;
 mem_rd_req_out = 1'b0; 
 load_size_out = 2'b10;
 load_unsigned_out = 1'b0;
 alu_src_out = 1'b0;
 iadder_src_out = 1'b0;
 rf_wr_en_out = 1'b0;
 wb_mux_sel_out = WB_ALU;
 imm_type_out = 3'b000;
 illegal_instr_out = 1'b0;
 case (opcode_in)
 7'b0110011: begin
 rf_wr_en_out = 1'b1;
 wb_mux_sel_out = WB_ALU;
 alu_src_out = 1'b0;
 alu_ctrl_out = {funct7_5_in, funct3_in};
 end
 7'b0010011: begin
 rf_wr_en_out = 1'b1;
 wb_mux_sel_out = WB_ALU;
 alu_src_out = 1'b1;
 imm_type_out = 3'b000;
 alu_ctrl_out = (funct3_in == 3'b101) ? {funct7_5_in, funct3_in} : {1'b0, funct3_in};
 end
 7'b0000011: begin
 rf_wr_en_out = 1'b1;
 wb_mux_sel_out = WB_LU;
 alu_src_out = 1'b1;
 iadder_src_out = 1'b1;
 imm_type_out = 3'b000;
 mem_rd_req_out = 1'b1;
 alu_ctrl_out = 4'b0000;
 case (funct3_in)
 3'b000: begin load_size_out = 2'b00; load_unsigned_out = 1'b0; end
 3'b001: begin load_size_out = 2'b01; load_unsigned_out = 1'b0; end
 3'b010: begin load_size_out = 2'b10; load_unsigned_out = 1'b0; end
 3'b100: begin load_size_out = 2'b00; load_unsigned_out = 1'b1; end
 3'b101: begin load_size_out = 2'b01; load_unsigned_out = 1'b1; end
 default: illegal_instr_out = 1'b1;
 endcase
 end
 7'b0100011: begin
 mem_wr_req_out = 1'b1;
 alu_src_out = 1'b1;
 iadder_src_out = 1'b1;
 imm_type_out = 3'b001;
 alu_ctrl_out = 4'b0000;
 case (funct3_in)
 3'b000: load_size_out = 2'b00;
 3'b001: load_size_out = 2'b01;
 3'b010: load_size_out = 2'b10;
 default: illegal_instr_out = 1'b1;
 endcase
 end
 7'b1100011: begin
 imm_type_out = 3'b010;
 iadder_src_out = 1'b0;
 end
 7'b1101111: begin
 rf_wr_en_out = 1'b1;
 wb_mux_sel_out = WB_PC_PLUS;
 imm_type_out = 3'b100;
 iadder_src_out = 1'b0;
 end
 7'b1100111: begin
 rf_wr_en_out = 1'b1;
 wb_mux_sel_out = WB_PC_PLUS;
 imm_type_out = 3'b000;
 iadder_src_out = 1'b1;
 end
 7'b0110111: begin
 rf_wr_en_out = 1'b1;
 wb_mux_sel_out = WB_ALU;
 imm_type_out = 3'b011;
 alu_src_out = 1'b1;
 lui_sel_out = 1'b1;
 alu_ctrl_out = 4'b0000;
 end
 7'b0010111: begin
 rf_wr_en_out = 1'b1;
 wb_mux_sel_out = WB_IADDER_OUT;
 imm_type_out = 3'b011;
 iadder_src_out = 1'b0;
 end
 default: illegal_instr_out = 1'b1;
 endcase
 end
endmodule
