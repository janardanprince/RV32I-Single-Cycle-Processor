`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 18.07.2026 00:48:07
// Design Name: 
// Module Name: store_unit
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


module store_unit (
input [1:0] funct3_in,
input ahb_ready_in,
input [31:0] iadder_in,
input [31:0] rs2_in,
input mem_wr_req_in,
input mem_rd_req_in,
output reg [31:0] data_out,
output reg [31:0] d_addr_out,
output reg [3:0] wr_mask_out,
output reg wr_req_out,
output reg [1:0] ahb_htrans_out
);
always @(*) begin
d_addr_out = iadder_in;
data_out = 32'd0;
wr_mask_out = 4'b0000;
wr_req_out = 1'b0;
ahb_htrans_out = 2'b00;
if ((mem_wr_req_in || mem_rd_req_in) && ahb_ready_in) begin
ahb_htrans_out = 2'b10;
if (mem_wr_req_in) begin
wr_req_out = 1'b1;
case (funct3_in)
2'b00: begin
case (iadder_in[1:0])
2'b00: begin data_out = {24'd0, rs2_in[7:0]}; wr_mask_out = 4'b0001; end
2'b01: begin data_out = {16'd0, rs2_in[7:0], 8'd0}; wr_mask_out = 4'b0010; end
2'b10: begin data_out = {8'd0, rs2_in[7:0], 16'd0}; wr_mask_out = 4'b0100; end
2'b11: begin data_out = {rs2_in[7:0], 24'd0}; wr_mask_out = 4'b1000; end
endcase
end
2'b01: begin
case (iadder_in[1])
1'b0: begin data_out = {16'd0, rs2_in[15:0]}; wr_mask_out = 4'b0011; end
1'b1: begin data_out = {rs2_in[15:0], 16'd0}; wr_mask_out = 4'b1100; end
endcase
end
2'b10: begin
data_out = rs2_in;
wr_mask_out = 4'b1111;
end
default: begin
data_out = 32'd0;
wr_mask_out = 4'b0000;
wr_req_out = 1'b0;
end
endcase
end
end
end
endmodule
