`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 18.07.2026 00:39:06
// Design Name: 
// Module Name: load_unit
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


module load_unit (
 input [1:0] load_size_in,
 input clk_in,
 input load_unsigned_in,
 input [31:0] data_in,
 input [1:0] iadder_1_to_0_in,
 input ahb_resp_in,
 output reg [31:0] lu_output
);
 reg [7:0] byte_data;
 reg [15:0] half_data;
 always @(*) begin
 case (iadder_1_to_0_in)
 2'b00: byte_data = data_in[7:0];
 2'b01: byte_data = data_in[15:8];
 2'b10: byte_data = data_in[23:16];
 2'b11: byte_data = data_in[31:24];
 default: byte_data = 8'h00;
 endcase
 case (iadder_1_to_0_in[1])
 1'b0: half_data = data_in[15:0];
 1'b1: half_data = data_in[31:16];
 default: half_data = 16'h0000;
 endcase
 case (load_size_in)
 2'b00: lu_output = (load_unsigned_in) ? {24'd0, byte_data} : {{24{byte_data[7]}}, byte_data};
 2'b01: lu_output = (load_unsigned_in) ? {16'd0, half_data} : {{16{half_data[15]}}, half_data};
 2'b10: lu_output = data_in;
 default: lu_output = 32'd0;
 endcase
 end
endmodule
