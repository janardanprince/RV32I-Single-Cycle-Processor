`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 18.07.2026 21:31:19
// Design Name: 
// Module Name: riscv32_tb
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


module riscv32_tb;

    reg clk;
    reg rst;

    wire [31:0] imaddr;
    reg  [31:0] instr;

    wire [31:0] dmaddr;
    wire [31:0] dmdata_out;
    wire        dmwr_req;
    wire [3:0]  dmwr_mask;
    reg  [31:0] data_in;
    reg         data_hready;
    reg         hresp;
    wire [1:0]  data_htrans;

    integer i;
    integer cp_r, cp_i, cp_u, cp_ls, cp_b, cp_jal, cp_total;
    initial begin
        cp_r = 0; cp_i = 0; cp_u = 0; cp_ls = 0; cp_b = 0; cp_jal = 0; cp_total = 0;
    end

    // ---------------------------------------------------------------
    // DUT
    // ---------------------------------------------------------------
    riscv32_top #(.BOOT_ADDRESS(32'h00000000)) dut (
        .riscv32_clk_in       (clk),
        .riscv32_rst_in       (rst),
        .riscv32_imaddr_out   (imaddr),
        .riscv32_instr_in     (instr),
        .riscv32_dmaddr_out   (dmaddr),
        .riscv32_dmdata_out   (dmdata_out),
        .riscv32_dmwr_req_out (dmwr_req),
        .riscv32_dmwr_mask_out(dmwr_mask),
        .riscv32_data_in      (data_in),
        .riscv32_data_hready_in(data_hready),
        .riscv32_hresp_in     (hresp),
        .riscv32_data_htrans_out(data_htrans)
    );

    // ---------------------------------------------------------------
    // Clock
    // ---------------------------------------------------------------
    initial clk = 0;
    always #5 clk = ~clk;

    
    reg [31:0] rom [0:511];
    initial begin
        rom[0] = 32'h03200093;
        rom[1] = 32'h01400113;
        rom[2] = 32'h002081B3;
        rom[3] = 32'h40208233;
        rom[4] = 32'h001112B3;
        rom[5] = 32'h0020D333;
        rom[6] = 32'h4020D3B3;
        rom[7] = 32'h00112433;
        rom[8] = 32'h001134B3;
        rom[9] = 32'h0020C533;
        rom[10] = 32'h0020E5B3;
        rom[11] = 32'h0020F633;
        rom[12] = 32'h04600F13;
        rom[13] = 32'h01E18463;
        rom[14] = 32'h001F8F93;
        rom[15] = 32'h01E00F13;
        rom[16] = 32'h01E20463;
        rom[17] = 32'h001F8F93;
        rom[18] = 32'h00500F37;
        rom[19] = 32'h01E28463;
        rom[20] = 32'h001F8F93;
        rom[21] = 32'h00000F13;
        rom[22] = 32'h01E30463;
        rom[23] = 32'h001F8F93;
        rom[24] = 32'h01E38463;
        rom[25] = 32'h001F8F93;
        rom[26] = 32'h00100F13;
        rom[27] = 32'h01E40463;
        rom[28] = 32'h001F8F93;
        rom[29] = 32'h01E48463;
        rom[30] = 32'h001F8F93;
        rom[31] = 32'h02600F13;
        rom[32] = 32'h01E50463;
        rom[33] = 32'h001F8F93;
        rom[34] = 32'h03600F13;
        rom[35] = 32'h01E58463;
        rom[36] = 32'h001F8F93;
        rom[37] = 32'h01000F13;
        rom[38] = 32'h01E60463;
        rom[39] = 32'h001F8F93;
        rom[40] = 32'h0DF02423;
        rom[41] = 32'h00100B13;
        rom[42] = 32'h004B1B93;
        rom[43] = 32'h41700F33;
        rom[44] = 32'hFF000693;
        rom[45] = 32'h01E68463;
        rom[46] = 32'h001F8F93;
        rom[47] = 32'h00500793;
        rom[48] = 32'h00A7A813;
        rom[49] = 32'h00A7B893;
        rom[50] = 32'h0037A913;
        rom[51] = 32'h0067C993;
        rom[52] = 32'h0067EA13;
        rom[53] = 32'h0067FA93;
        rom[54] = 32'hFF800C13;
        rom[55] = 32'h001C5C93;
        rom[56] = 32'h401C5D13;
        rom[57] = 32'h00100F13;
        rom[58] = 32'h01E80463;
        rom[59] = 32'h001F8F93;
        rom[60] = 32'h01E88463;
        rom[61] = 32'h001F8F93;
        rom[62] = 32'h00000F13;
        rom[63] = 32'h01E90463;
        rom[64] = 32'h001F8F93;
        rom[65] = 32'h00300F13;
        rom[66] = 32'h01E98463;
        rom[67] = 32'h001F8F93;
        rom[68] = 32'h00700F13;
        rom[69] = 32'h01EA0463;
        rom[70] = 32'h001F8F93;
        rom[71] = 32'h00400F13;
        rom[72] = 32'h01EA8463;
        rom[73] = 32'h001F8F93;
        rom[74] = 32'h01000F13;
        rom[75] = 32'h01EB8463;
        rom[76] = 32'h001F8F93;
        rom[77] = 32'h80000F37;
        rom[78] = 32'hFFCF0F13;
        rom[79] = 32'h01EC8463;
        rom[80] = 32'h001F8F93;
        rom[81] = 32'hFFC00F13;
        rom[82] = 32'h01ED0463;
        rom[83] = 32'h001F8F93;
        rom[84] = 32'h0DF02623;
        rom[85] = 32'h123450B7;
        rom[86] = 32'h11108093;
        rom[87] = 32'h12345F37;
        rom[88] = 32'h111F0F13;
        rom[89] = 32'h01E08463;
        rom[90] = 32'h001F8F93;
        rom[91] = 32'h00000117;
        rom[92] = 32'h16C00F13;
        rom[93] = 32'h01E10463;
        rom[94] = 32'h001F8F93;
        rom[95] = 32'h0DF02823;
        rom[96] = 32'h123450B7;
        rom[97] = 32'h67808093;
        rom[98] = 32'h00102023;
        rom[99] = 32'h00000103;
        rom[100] = 32'h00100183;
        rom[101] = 32'h00300203;
        rom[102] = 32'h00004283;
        rom[103] = 32'h00001303;
        rom[104] = 32'h00201383;
        rom[105] = 32'h00205403;
        rom[106] = 32'h07800F13;
        rom[107] = 32'h01E10463;
        rom[108] = 32'h001F8F93;
        rom[109] = 32'h05600F13;
        rom[110] = 32'h01E18463;
        rom[111] = 32'h001F8F93;
        rom[112] = 32'h01200F13;
        rom[113] = 32'h01E20463;
        rom[114] = 32'h001F8F93;
        rom[115] = 32'h07800F13;
        rom[116] = 32'h01E28463;
        rom[117] = 32'h001F8F93;
        rom[118] = 32'h00005F37;
        rom[119] = 32'h678F0F13;
        rom[120] = 32'h01E30463;
        rom[121] = 32'h001F8F93;
        rom[122] = 32'h00001F37;
        rom[123] = 32'h234F0F13;
        rom[124] = 32'h01E38463;
        rom[125] = 32'h001F8F93;
        rom[126] = 32'h01E40463;
        rom[127] = 32'h001F8F93;
        rom[128] = 32'h818284B7;
        rom[129] = 32'h38448493;
        rom[130] = 32'h00902223;
        rom[131] = 32'h00400503;
        rom[132] = 32'h00404583;
        rom[133] = 32'h00401603;
        rom[134] = 32'h00405683;
        rom[135] = 32'h00700703;
        rom[136] = 32'h00601783;
        rom[137] = 32'hF8400F13;
        rom[138] = 32'h01E50463;
        rom[139] = 32'h001F8F93;
        rom[140] = 32'h08400F13;
        rom[141] = 32'h01E58463;
        rom[142] = 32'h001F8F93;
        rom[143] = 32'hFFFF8F37;
        rom[144] = 32'h384F0F13;
        rom[145] = 32'h01E60463;
        rom[146] = 32'h001F8F93;
        rom[147] = 32'h00008F37;
        rom[148] = 32'h384F0F13;
        rom[149] = 32'h01E68463;
        rom[150] = 32'h001F8F93;
        rom[151] = 32'hF8100F13;
        rom[152] = 32'h01E70463;
        rom[153] = 32'h001F8F93;
        rom[154] = 32'hFFFF8F37;
        rom[155] = 32'h182F0F13;
        rom[156] = 32'h01E78463;
        rom[157] = 32'h001F8F93;
        rom[158] = 32'h0000B837;
        rom[159] = 32'hAAA80813;
        rom[160] = 32'h01001223;
        rom[161] = 32'h00402883;
        rom[162] = 32'h8182BF37;
        rom[163] = 32'hAAAF0F13;
        rom[164] = 32'h01E88463;
        rom[165] = 32'h001F8F93;
        rom[166] = 32'h0EE00913;
        rom[167] = 32'h01200223;
        rom[168] = 32'h00402983;
        rom[169] = 32'h8182BF37;
        rom[170] = 32'hAEEF0F13;
        rom[171] = 32'h01E98463;
        rom[172] = 32'h001F8F93;
        rom[173] = 32'h0DF02A23;
        rom[174] = 32'h00500A13;
        rom[175] = 32'h00500A93;
        rom[176] = 32'h00900B13;
        rom[177] = 32'hFFF00B93;
        rom[178] = 32'h00100C13;
        rom[179] = 32'h015A0463;
        rom[180] = 32'h001F8F93;
        rom[181] = 32'h016A0463;
        rom[182] = 32'h0080006F;
        rom[183] = 32'h001F8F93;
        rom[184] = 32'h016A1463;
        rom[185] = 32'h001F8F93;
        rom[186] = 32'h015A1463;
        rom[187] = 32'h0080006F;
        rom[188] = 32'h001F8F93;
        rom[189] = 32'h018BC463;
        rom[190] = 32'h001F8F93;
        rom[191] = 32'h018BE463;
        rom[192] = 32'h0080006F;
        rom[193] = 32'h001F8F93;
        rom[194] = 32'h017C5463;
        rom[195] = 32'h001F8F93;
        rom[196] = 32'h017C7463;
        rom[197] = 32'h0080006F;
        rom[198] = 32'h001F8F93;
        rom[199] = 32'h0DF02C23;
        rom[200] = 32'h00800CEF;
        rom[201] = 32'h001F8F93;
        rom[202] = 32'h32000F13;
        rom[203] = 32'h004F0F13;
        rom[204] = 32'h01EC8463;
        rom[205] = 32'h001F8F93;
        rom[206] = 32'h34000D67;
        rom[207] = 32'h001F8F93;
        rom[208] = 32'h33800F13;
        rom[209] = 32'h004F0F13;
        rom[210] = 32'h01ED0463;
        rom[211] = 32'h001F8F93;
        rom[212] = 32'h0DF02E23;
        rom[213] = 32'h0FF02E23;
        rom[214] = 32'h0000006F;
    end

    always @(posedge clk or posedge rst) begin
        if (rst)
            instr <= rom[0];
        else
            instr <= rom[imaddr[10:2]];
    end


    reg [31:0] dmem [0:255];
    initial begin
        for (i = 0; i < 256; i = i + 1) dmem[i] = 32'h0;
        data_hready = 1'b1;
        hresp       = 1'b0;
        data_in     = 32'h0;
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            data_in <= 32'h0;
        end else if (data_htrans == 2'b10) begin
            if (dmwr_req) begin
                if (dmwr_mask[0]) dmem[dmaddr[9:2]][7:0]   <= dmdata_out[7:0];
                if (dmwr_mask[1]) dmem[dmaddr[9:2]][15:8]  <= dmdata_out[15:8];
                if (dmwr_mask[2]) dmem[dmaddr[9:2]][23:16] <= dmdata_out[23:16];
                if (dmwr_mask[3]) dmem[dmaddr[9:2]][31:24] <= dmdata_out[31:24];
            end else begin
                data_in <= dmem[dmaddr[9:2]];
            end
        end
    end

    initial begin
        rst = 1'b1;
        repeat (3) @(posedge clk);
        rst = 1'b0;

        repeat (250) @(posedge clk);

        cp_r     = dmem[50];   // addr 200
        cp_i     = dmem[51];   // addr 204
        cp_u     = dmem[52];   // addr 208
        cp_ls    = dmem[53];   // addr 212
        cp_b     = dmem[54];   // addr 216
        cp_jal   = dmem[55];   // addr 220
        cp_total = dmem[63];   // addr 252 (final)

        $display("====================================================");
        $display(" RISCV32 TOP - PER-TYPE REGRESSION RESULT");
        $display("====================================================");
        $display(" R-type  (ALU reg-reg)      : %s  (fails=%0d)", (cp_r==0)              ? "PASS" : "FAIL", cp_r);
        $display(" I-type  (ALU reg-imm)      : %s  (fails=%0d)", (cp_i-cp_r==0)         ? "PASS" : "FAIL", cp_i-cp_r);
        $display(" U-type  (LUI/AUIPC)        : %s  (fails=%0d)", (cp_u-cp_i==0)         ? "PASS" : "FAIL", cp_u-cp_i);
        $display(" Load/Store (I-type/S-type) : %s  (fails=%0d)", (cp_ls-cp_u==0)        ? "PASS" : "FAIL", cp_ls-cp_u);
        $display(" B-type  (branches)         : %s  (fails=%0d)", (cp_b-cp_ls==0)        ? "PASS" : "FAIL", cp_b-cp_ls);
        $display(" JAL/JALR                   : %s  (fails=%0d)", (cp_jal-cp_b==0)       ? "PASS" : "FAIL", cp_jal-cp_b);
        $display("----------------------------------------------------");
        if (cp_total == 0)
            $display(" OVERALL: PASS -- all 41 checks passed");
        else
            $display(" OVERALL: FAIL -- %0d check(s) failed out of 41", cp_total);
        $display("====================================================");
        $finish;
    end

    // Optional cycle-by-cycle trace -- define VERBOSE_TRACE (e.g. add
    // `define VERBOSE_TRACE as the first line of this file) to enable.
    `ifdef VERBOSE_TRACE
    always @(posedge clk) begin
        if (!rst)
            $display("t=%0t pc=%h instr=%h htrans=%b wr_req=%b dmaddr=%h data_in=%h",
                      $time, dut.pc, instr, data_htrans, dmwr_req, dmaddr, data_in);
    end
    `endif

endmodule
