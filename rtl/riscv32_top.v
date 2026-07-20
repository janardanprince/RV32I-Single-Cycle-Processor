`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 18.07.2026 01:10:27
// Design Name: 
// Module Name: riscv32_top
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


module riscv32_top #(
parameter BOOT_ADDRESS = 32'h00000000
)(
input riscv32_clk_in,
input riscv32_rst_in,
output [31:0] riscv32_imaddr_out,
input [31:0] riscv32_instr_in,
output [31:0] riscv32_dmaddr_out,
output [31:0] riscv32_dmdata_out,
output riscv32_dmwr_req_out,
output [3:0] riscv32_dmwr_mask_out,
input [31:0] riscv32_data_in,
input riscv32_data_hready_in,
input riscv32_hresp_in,
output [1:0] riscv32_data_htrans_out
);
wire [31:0] pc, pc_plus_4, pc_mux;
wire [6:0] opcode;
wire [2:0] funct3;
wire [6:0] funct7;
wire [4:0] rs1_addr, rs2_addr, rd_addr;
wire [31:7] instr_31_to_7;
wire [31:0] rs1, rs2, imm, iaddr;
wire [3:0] alu_ctrl;
wire lui_sel, mem_wr_req, mem_rd_req;
wire [1:0] load_size;
wire load_unsigned, alu_src, iadder_src, rf_wr_en;
wire [2:0] wb_mux_sel, imm_type;
wire illegal_instr, branch_taken;
wire [4:0] rd_addr_reg;
wire [31:0] rs1_reg, rs2_reg, pc_reg2, pc_plus_4_reg, iadder_out_reg, imm_reg;
wire [3:0] alu_ctrl_reg;
wire lui_sel_reg;
wire [1:0] load_size_reg;
wire [2:0] wb_mux_sel_reg;
wire load_unsigned_reg, alu_src_reg, rf_wr_en_reg;
wire [31:0] lu_output, alu_result, wb_mux_out, alu_2nd_src_mux;
wire integer_wr_en_reg_file;
wire eq_out, lt_out, ltu_out;
wire [1:0] pc_src;
pc PC (
.rst_in(riscv32_rst_in),
.branch_taken_in(branch_taken),
.iaddr_in(iaddr[31:1]),.pc_in(pc),
.pc_plus_4_out(pc_plus_4),
.pc_out(pc_mux),
.i_addr_out(riscv32_imaddr_out)
);
pipeline_reg_1 REG1 (
.clk_in(riscv32_clk_in),
.rst_in(riscv32_rst_in),
.pc_mux_in(pc_mux),
.pc_out(pc)
);
instruction_decoder ID (
.instr_in(riscv32_instr_in),
.opcode_out(opcode),
.funct3_out(funct3),
.funct7_out(funct7),
.rs1_addr_out(rs1_addr),
.rs2_addr_out(rs2_addr),
.rd_addr_out(rd_addr),
.instr_31_7_out(instr_31_to_7)
);
decoder DEC (
.opcode_in(opcode),
.funct7_5_in(funct7[5]),
.funct3_in(funct3),
.alu_ctrl_out(alu_ctrl),
.lui_sel_out(lui_sel),
.mem_wr_req_out(mem_wr_req),
.mem_rd_req_out(mem_rd_req),
.load_size_out(load_size),
.load_unsigned_out(load_unsigned),
.alu_src_out(alu_src),
.iadder_src_out(iadder_src),
.rf_wr_en_out(rf_wr_en),
.wb_mux_sel_out(wb_mux_sel),
.imm_type_out(imm_type),
.illegal_instr_out(illegal_instr)
);
imm_generator IMG (
.instr_in(instr_31_to_7),
.imm_type_in(imm_type),
.imm_out(imm)
);
immediate_adder IMM_ADDER (
.pc_in(pc),.rs1_in(rs1),
.imm_in(imm),
.iadder_src_in(iadder_src),
.iadder_out(iaddr)
);
branch_unit BU (
.opcode_6_to_2_in(opcode[6:2]),
.funct3_in(funct3),
.rs1_in(rs1),
.rs2_in(rs2),
.branch_taken_out(branch_taken)
);
register_file RF (
.riscv32_clk_in(riscv32_clk_in),
.riscv32_rst_in(riscv32_rst_in),
.rs_1_addr_in(rs1_addr),
.rs_2_addr_in(rs2_addr),
.rs_1_out(rs1),
.rs_2_out(rs2),
.rd_addr_in(rd_addr_reg),
.wr_en_in(integer_wr_en_reg_file),
.rd_in(wb_mux_out)
);
store_unit SU (
.funct3_in(funct3[1:0]),
.ahb_ready_in(riscv32_data_hready_in),
.iadder_in(iaddr),
.rs2_in(rs2),
.mem_wr_req_in(mem_wr_req),
.mem_rd_req_in(mem_rd_req),
.data_out(riscv32_dmdata_out),
.d_addr_out(riscv32_dmaddr_out),
.wr_mask_out(riscv32_dmwr_mask_out),
.wr_req_out(riscv32_dmwr_req_out),
.ahb_htrans_out(riscv32_data_htrans_out)
);
pipeline_reg_2 REG2 (
.rd_addr_in(rd_addr),
.rs1_in(rs1),
.rs2_in(rs2),
.pc_in(pc),
.pc_plus_4_in(pc_plus_4),
.iadder_in(iaddr),
.imm_in(imm),
.alu_ctrl_in(alu_ctrl),.lui_sel_in(lui_sel),
.load_size_in(load_size),
.wb_mux_sel_in(wb_mux_sel),
.load_unsigned_in(load_unsigned),
.alu_src_in(alu_src),
.rf_wr_en_in(rf_wr_en),
.branch_taken_in(branch_taken),
.clk_in(riscv32_clk_in),
.reset_in(riscv32_rst_in),
.rd_addr_reg_out(rd_addr_reg),
.rs1_reg_out(rs1_reg),
.rs2_reg_out(rs2_reg),
.pc_reg_out(pc_reg2),
.pc_plus_4_reg_out(pc_plus_4_reg),
.iadder_out_reg_out(iadder_out_reg),
.imm_reg_out(imm_reg),
.alu_ctrl_reg_out(alu_ctrl_reg),
.lui_sel_reg_out(lui_sel_reg),
.load_size_reg_out(load_size_reg),
.wb_mux_sel_reg_out(wb_mux_sel_reg),
.load_unsigned_reg_out(load_unsigned_reg),
.alu_src_reg_out(alu_src_reg),
.rf_wr_en_reg_out(rf_wr_en_reg)
);
load_unit LU (
.load_size_in(load_size_reg),
.clk_in(riscv32_clk_in),
.load_unsigned_in(load_unsigned_reg),
.data_in(riscv32_data_in),
.iadder_1_to_0_in(iadder_out_reg[1:0]),
.lu_output(lu_output),
.ahb_resp_in(riscv32_hresp_in)
);
alu ALU (
.op_1_in(rs1_reg),
.op_2_in(alu_2nd_src_mux),
.alu_ctrl_in(alu_ctrl_reg),
.lui_sel_in(lui_sel_reg),
.result_out(alu_result),
.eq_out(eq_out),
.lt_out(lt_out),
.ltu_out(ltu_out)
);
wb_mux_sel_unit WBMUX (.wb_mux_sel_reg_in(wb_mux_sel_reg),
.alu_result_in(alu_result),
.lu_output_in(lu_output),
.imm_reg_in(imm_reg),
.iadder_out_reg_in(iadder_out_reg),
.pc_plus_4_reg_in(pc_plus_4_reg),
.rs2_reg_in(rs2_reg),
.alu_source_reg_in(alu_src_reg),
.wb_mux_out(wb_mux_out),
.alu_2nd_src_mux_out(alu_2nd_src_mux)
);
wr_en_generator WREN (
.rf_wr_en_reg_in(rf_wr_en_reg),
.wr_en_integer_file_out(integer_wr_en_reg_file)
);
endmodule
