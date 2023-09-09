`timescale 1ns / 1ps

module RF_tb();
    parameter depth = 32;
    parameter width = 32;
    reg clk;
    reg rst;
    reg we;
    reg [$clog2(depth) - 1: 0] waddr;
    reg [width - 1: 0] wdata;
    reg [2:0] wstrobe;    // 100 for whole word; 010 for half word; 001 for single byte; assuming width is 32
    reg [$clog2(depth) - 1: 0] raddr0;
    wire [width - 1: 0] rdata0;
    reg [$clog2(depth) - 1: 0] raddr1;
    wire [width - 1: 0] rdata1;
    
    RF #(
    depth,
    width
    ) uut (
    clk,
    rst,
    we,
    waddr,
    wdata,
    wstrobe,
    raddr0,
    rdata0,
    raddr1,
    rdara1    
    );
    
    always
        #5 clk = ~clk;
        
    initial begin
        clk = 0;
        rst = 0;
        #10 rst = 1;
        we = 1;
        waddr = 2;
        wdata = 50;
        wstrobe = 3'b100;
        raddr0 = 2;
        raddr1 = 3;
        #20 $finish;        
    end
endmodule
