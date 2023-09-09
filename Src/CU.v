`timescale 1ns / 1ps

module CU (
    input clk,
    input rst,
    input N,
    input Z,
    input [31:0] instr,
    output [4:0] waddr,
    output [4:0] raddr0,
    output [4:0] raddr1,
    output MB,
    output [3:0] FS,
    output MD,
    output [2:0] wstrobe,
    output we,
    output [4:0] shamnt,
    output [31:0] ConsOut,
    output [31:0] InstrAddr    
    );
    
    parameter width = 32;
    
    wire PL;
    wire JB;
    wire BC;
    wire [31:0] Offset;    
    
    ID ID (
        instr,
        waddr,
        raddr0,
        raddr1,
        MB,
        FS,
        MD,
        wstrobe,
        we,
        shamnt,
        PL,
        JB,
        BC,
        Offset,
        ConsOut
        );
    
    PC #(
        width
        ) PC (
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
endmodule