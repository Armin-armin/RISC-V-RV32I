`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// University: Istanbul Technical University
// Group Members: Armin Asgharifard, Behiç Erdem
// 
// Completion Date: 06/13/2023
// Design Name: RISC-V RV32I Microprocessor
// Description: Consists of a Control Unit and a Datapath
//              Instruction Memory and Data Memory are
//              instantiated in testbench.
//////////////////////////////////////////////////////////////////////////////////


module Processor #(
    parameter depth = 32,
    parameter width = 32
    )(
    input clk,
    input rst,
    input [31:0] Instruction,   // instruction received from instruction memory 
    input [31:0] DataIn,        // data input from data memory
    output [31:0] AddrOut,      // address output to store in data memory
    output [31:0] DataOut,      // data output to store in data memory
    output [31:0] InstrAddr     // address given to the instruction memory
    );
        
    wire [4:0] waddr;
    wire [4:0] raddr0;
    wire [4:0] raddr1;
    wire MB;
    wire [3:0] FS;
    wire MD;
    wire [2:0] wstrobe;
    wire we;
    wire [4:0] shamnt;    
    wire [31:0] ConsIn;
    wire V;
    wire C;
    
    CU CU (
        .clk(clk),
        .rst(rst),
        .N(N),
        .Z(Z),
        .instr(Instruction),
        .waddr(waddr),
        .raddr0(raddr0),
        .raddr1(raddr1),
        .MB(MB),
        .FS(FS),
        .MD(MD),
        .wstrobe(wstrobe),
        .we(we),
        .shamnt(shamnt),
        .ConsOut(ConsIn),
        .InstrAddr(InstrAddr)
        );
    
    Datapath #(
        .depth(depth),
        .width(width)
        ) Datapath (    
        .clk(clk),
        .rst(rst),
        .waddr(waddr),
        .raddr0(raddr0),
        .raddr1(raddr1),
        .MB(MB),
        .FS(FS),
        .MD(MD),
        .wstrobe(wstrobe),
        .we(we),
        .shamnt(shamnt),
        .DataIn(DataIn),
        .ConsIn(ConsIn),
        .DataOut(DataOut),
        .AddrOut(AddrOut),
        .V(V),
        .C(C),
        .N(N),
        .Z(Z)
        );        
endmodule
