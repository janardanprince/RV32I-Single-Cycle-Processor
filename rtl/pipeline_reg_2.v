`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 18.07.2026 00:11:05
// Design Name: 
// Module Name: pipeline_reg_2
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


module pipeline_reg_2 (
 input [4:0] rd_addr_in,
 input [31:0] rs1_in,
 input [31:0] rs2_in,
 input [31:0] pc_in,
 input [31:0] pc_plus_4_in,
 input [31:0] iadder_in,
 input [31:0] imm_in,
 input [3:0] alu_ctrl_in,
 input lui_sel_in,
 input [1:0] load_size_in,
 input [2:0] wb_mux_sel_in,
 input load_unsigned_in,
 input alu_src_in,
 input rf_wr_en_in,
 input branch_taken_in,
 input clk_in,
 input reset_in,
 output reg [4:0] rd_addr_reg_out,
 output reg [31:0] rs1_reg_out,
 output reg [31:0] rs2_reg_out,
 output reg [31:0] pc_reg_out,
 output reg [31:0] pc_plus_4_reg_out,
 output reg [31:0] iadder_out_reg_out,
 output reg [31:0] imm_reg_out,
 output reg [3:0] alu_ctrl_reg_out,
 output reg lui_sel_reg_out,
 output reg [1:0] load_size_reg_out,
 output reg [2:0] wb_mux_sel_reg_out,
 output reg load_unsigned_reg_out,
 output reg alu_src_reg_out,
 output reg rf_wr_en_reg_out
);
 always @(posedge clk_in or posedge reset_in) begin
 if (reset_in) begin
 rd_addr_reg_out <= 5'd0;
 rs1_reg_out <= 32'd0;
 rs2_reg_out <= 32'd0;
 pc_reg_out <= 32'd0;
 pc_plus_4_reg_out <= 32'd0;
 iadder_out_reg_out <= 32'd0;
 imm_reg_out <= 32'd0;
 alu_ctrl_reg_out <= 4'd0;
 lui_sel_reg_out <= 1'b0;
 load_size_reg_out <= 2'd0;
 wb_mux_sel_reg_out <= 3'd0;
 load_unsigned_reg_out <= 1'b0;
 alu_src_reg_out <= 1'b0;
 rf_wr_en_reg_out <= 1'b0;
 end else begin
 rd_addr_reg_out <= rd_addr_in;
 rs1_reg_out <= rs1_in;
 rs2_reg_out <= rs2_in;
 pc_reg_out <= pc_in;
 pc_plus_4_reg_out <= pc_plus_4_in;
 iadder_out_reg_out <= iadder_in;
 imm_reg_out <= imm_in;
 alu_ctrl_reg_out <= alu_ctrl_in;
 lui_sel_reg_out <= lui_sel_in;
 load_size_reg_out <= load_size_in;
 wb_mux_sel_reg_out <= wb_mux_sel_in;
 load_unsigned_reg_out <= load_unsigned_in;
 alu_src_reg_out <= alu_src_in;
 rf_wr_en_reg_out <= rf_wr_en_in;
 end
 end
endmodule
