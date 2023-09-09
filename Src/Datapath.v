`timescale 1ns / 1ps

module Datapath #(
    parameter depth = 32,
    parameter width = 32
    )(    
    input clk,
    input rst,
    input [$clog2(depth) - 1: 0] waddr,
    input [$clog2(depth) - 1: 0] raddr0,
    input [$clog2(depth) - 1: 0] raddr1,
    input MB,
    input [3:0] FS,
    input MD,
    input [2:0] wstrobe,
    input we,
    input [4:0] shamnt,
    input [width - 1: 0] DataIn,
    input [width - 1: 0] ConsIn,
    output [width - 1: 0] DataOut,
    output [width - 1: 0] AddrOut,
    output V,
    output C,
    output N,
    output Z
    );
    
    wire [width - 1: 0] Adata;
    wire [width - 1: 0] Bdata;
    wire [width - 1: 0] B;
    wire [width - 1: 0] Ddata;
    wire [3:0] GSelect;
    wire [1:0] HSelect;
    wire MFSelect;
    wire [width - 1: 0] F;
    
    assign GSelect = FS;
    assign HSelect = FS[1:0];
    assign MFSelect = FS[3] & FS[2];    
    assign B = MB ? ConsIn : Bdata;
    assign Ddata = MD ? DataIn : F;
    assign AddrOut = Adata;
    assign DataOut = B;
    
    RF #(
        .width(width),
        .depth(depth)
        ) RF (
        .clk(clk),
        .rst(rst),
        .we(we),
        .waddr(waddr),
        .wdata(Ddata),
        .wstrobe(wstrobe),
        .raddr0(raddr0),
        .rdata0(Adata),
        .raddr1(raddr1),
        .rdata1(Bdata)
        );
    
    FU #(
        .size(width)
        ) FU (
        .A(Adata),
        .B(B),
        .G_select(GSelect),
        .H_select(HSelect),
        .shamnt(shamnt),
        .MF_select(MFSelect),
        .F(F),
        .V(V),
        .C(C),
        .N(N),
        .Z(Z)
        );
endmodule
