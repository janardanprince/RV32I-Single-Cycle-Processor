`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 18.07.2026 00:08:24
// Design Name: 
// Module Name: pipeline_reg_1
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


module pipeline_reg_1 (
 input clk_in,
 input rst_in,
 input [31:0] pc_mux_in,
 output reg [31:0] pc_out
);
 always @(posedge clk_in or posedge rst_in) begin
 if (rst_in)
 pc_out <= 32'h00000000;
 else
 pc_out <= pc_mux_in;
 end
endmodule

