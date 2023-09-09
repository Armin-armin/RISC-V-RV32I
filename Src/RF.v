`timescale 1ns / 1ps

module RF #(
    parameter depth = 32,
    parameter width = 32
    )(
    input clk,
    input rst,
    input we,
    input [$clog2(depth) - 1: 0] waddr,
    input [width - 1: 0] wdata,
    input [2:0] wstrobe,    // 100 for whole word, 010 for half word, 001 for single byte, assuming width is 32
    input [$clog2(depth) - 1: 0] raddr0,
    output [width - 1: 0] rdata0,
    input [$clog2(depth) - 1: 0] raddr1,
    output [width - 1: 0] rdata1
    );
    
    genvar i, j;
    integer k;
    
    wire [depth - 1: 0] waddro;
    reg [depth - 1: 0] w_en [0:3];
    wire [width - 1: 0] dout [0: depth - 1];
    wire strobe_byte;
    wire strobe_half;
    wire strobe_word;  
    
    assign strobe_word = we & (wstrobe == 3'b100);
    assign strobe_half = we & (wstrobe == 3'b010);
    assign strobe_byte = we & (wstrobe == 3'b001);
    
    Decoder #(
        .depth(depth)
        ) decoder (
        .waddri(waddr),
        .waddro(waddro)
        );
    
    always @(strobe_word, strobe_half, strobe_byte, waddro) begin
        for (k = 0; k < depth; k = k + 1) begin
            w_en[0][k] = waddro[k] & (strobe_word | strobe_half | strobe_byte) ? 1'b1 : 1'b0;
            w_en[1][k] = waddro[k] & (strobe_word | strobe_half) ? 1'b1 : 1'b0;
            w_en[2][k] = waddro[k] & strobe_word ? 1'b1 : 1'b0;
            w_en[3][k] = waddro[k] & strobe_word ? 1'b1 : 1'b0;
        end
    end    
    
    generate
        for (i = 0; i < depth; i = i + 1) begin                  
            for (j = 0; j < 4; j = j + 1) begin                
                Register #(
                .width(width / 4)
                ) register (
                .clk(clk),
                .rst(i == 0 ? 1'b0 : rst),
                .en(w_en[j][i]),
                .din(wdata[((j + 1) * (width / 4)) - 1: j * (width / 4)]),
                .dout(dout[i][((j + 1) * (width / 4)) - 1: j * (width / 4)])           
                );
            end                       
        end
    endgenerate
    
    assign rdata0 = dout[raddr0];
    assign rdata1 = dout[raddr1]; 
endmodule
