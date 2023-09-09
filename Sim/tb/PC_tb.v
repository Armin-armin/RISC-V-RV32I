`timescale 1ns / 1ps

module PC_tb();
    parameter width = 32;
    reg clk;
    reg rst;
    reg PL;
    reg JB;
    reg BC;
    reg N;
    reg Z;
    reg signed [31:0] Offset;
    wire [31:0] InstrAddr;
    
    PC #(
        width
        ) uut (        
        clk,
        rst,
        PL,
        JB,
        BC,
        N,
        Z,
        Offset,
        InstrAddr
        );
    
    always
        #5 clk = ~clk;
    
    initial begin
        clk = 0;
        rst = 0;
        #10 rst = 1;
        
        PL <= 0;
        JB <= 0;
        BC <= 0;
        N <= 0;
        Z <= 0;
        Offset <= 0;
        
        #50 PL <= 1;
        JB <= 1;
        Offset <= 8;
        
        #10 PL <= 1;
        JB <= 0;
        BC <= 0;
        Z <= 0;
        Offset <= 20;
        #10 Z <= 1;
        
        #10 BC <= 1;
        Z <= 0;
        N <= 0;
        Offset <= -15;
        #10 N <= 1;
        
        #20 PL <= 0;
        #10 $finish;
    end
endmodule
