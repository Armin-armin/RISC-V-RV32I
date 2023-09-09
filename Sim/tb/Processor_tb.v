`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// University: Istanbul Technical University
// Group Members: Armin Asgharifard, Behiç Erdem
// 
// Completion Date: 06/13/2023
// Design Name: RISC-V RV32I Microprocessor
// Description: Consists of a Control Unit, a Datapath,
//              an Instruction Memory, and a Data Memory.
//////////////////////////////////////////////////////////////////////////////////

module Processor_tb();
    parameter depth = 32;
    parameter width = 32;
    reg clk;
    reg rst_proc;
    wire [31:0] DataIn;
    reg [31:0] DataIn_reg;
    wire [31:0] AddrOut;
    reg [31:0] AddrOut_reg;    
    wire [31:0] DataOut;
    reg [31:0] DataOut_reg;
    wire [31:0] instr;
    reg [31:0] instr_reg;
    wire [31:0] InstrAddr;    
    reg rst_rf;
    reg instr_we;
    reg data_we;
    reg [$clog2(depth) - 1: 0] instr_waddr;
    reg [31:0] instr_wdata;
    reg [31:0] instr_init [0:31];
    reg [31:0] data_init [0:31];
    integer i;   
    
    Processor #(
        .depth(depth),
        .width(width)
        ) RISCV (
        .clk(clk),
        .rst(rst_proc),
        .Instruction(instr_reg),
        .DataIn(DataIn_reg),
        .AddrOut(AddrOut),
        .DataOut(DataOut),
        .InstrAddr(InstrAddr)
        );
    
    RF #(
        .depth(depth),
        .width(width)
        ) data_mem (
        .clk(clk),
        .rst(rst_rf),
        .we(data_we),
        .waddr(AddrOut_reg),
        .wdata(DataOut_reg),
        .wstrobe(3'b100),
        .raddr0(AddrOut_reg),
        .rdata0(DataIn)       
        );
    
    RF #(
        .depth(depth),
        .width(width)
        ) instr_mem (
        .clk(clk),
        .rst(rst_rf),
        .we(instr_we),
        .waddr(instr_waddr),
        .wdata(instr_wdata),
        .wstrobe(3'b100),
        .raddr0(InstrAddr[$clog2(depth) - 1: 0]),
        .rdata0(instr)
        );
    
    always
        #5 clk <= ~clk;        

    always @(*) begin
        DataIn_reg <= DataIn;
        AddrOut_reg <= AddrOut;
        DataOut_reg <= DataOut;
        instr_reg <= instr;
    end
    
    initial begin
        clk <= 0;
        rst_proc <= 0;
        rst_rf <= 0;
        #10 rst_proc <= 1;
        rst_rf <= 1;
        $readmemb("instr_init.mem", instr_init);
        $readmemb("data_init.mem", data_init);
        instr_we = 1'b1;
        data_we = 1'b1;
        for (i = 1; i <= 32; i = i + 1) begin
            #10 instr_waddr <= i;
            instr_wdata <= instr_init[i - 1];
            AddrOut_reg <= i;
            DataOut_reg <= data_init[i - 1];
        end
        #10 instr_we <= 1'b0;        
        data_we <= 1'b0;
        rst_proc <= 0;
        #10 rst_proc <= 1;
        #5000 $finish;
    end
endmodule
