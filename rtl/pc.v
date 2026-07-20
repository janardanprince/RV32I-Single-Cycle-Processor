`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 17.07.2026 22:49:41
// Design Name: 
// Module Name: pc
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


module pc (
 input rst_in,
 input branch_taken_in,
 input [31:1] iaddr_in,
 input [31:0] pc_in,
 output [31:0] pc_plus_4_out,
 output reg [31:0] pc_out,
 output [31:0] i_addr_out
);
 wire [31:0] branch_target;
 assign branch_target = {iaddr_in, 1'b0};
 assign pc_plus_4_out = pc_in + 32'd4;
 always @(*) begin
 if (rst_in) begin
 pc_out = 32'h00000000;
 end else begin
  pc_out = (branch_taken_in) ? branch_target : pc_plus_4_out;

 end
 end
 assign i_addr_out = pc_out;
endmodule
