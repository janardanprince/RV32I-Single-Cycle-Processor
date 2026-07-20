`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 18.07.2026 01:05:45
// Design Name: 
// Module Name: wr_mux_sel_unit
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


module wb_mux_sel_unit (
 input [2:0] wb_mux_sel_reg_in,
 input [31:0] alu_result_in,
 input [31:0] lu_output_in,
 input [31:0] imm_reg_in,
 input [31:0] iadder_out_reg_in,
 input [31:0] pc_plus_4_reg_in,
 input [31:0] rs2_reg_in,
 input alu_source_reg_in,
 output reg [31:0] wb_mux_out,
 output [31:0] alu_2nd_src_mux_out
);
 localparam WB_ALU = 3'b000;
 localparam WB_LU = 3'b001;
 localparam WB_IMM = 3'b010;
 localparam WB_IADDER_OUT = 3'b011;
 localparam WB_PC_PLUS = 3'b101;
 assign alu_2nd_src_mux_out = (alu_source_reg_in) ? imm_reg_in : rs2_reg_in;
 always @(*) begin
 case (wb_mux_sel_reg_in)
 WB_ALU: wb_mux_out = alu_result_in;
 WB_LU: wb_mux_out = lu_output_in;
 WB_IMM: wb_mux_out = imm_reg_in;
 WB_IADDER_OUT: wb_mux_out = iadder_out_reg_in;
 WB_PC_PLUS: wb_mux_out = pc_plus_4_reg_in;
 default: wb_mux_out = 32'd0;
 endcase
 end
endmodule
