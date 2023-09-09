`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/11/2023 10:26:35 PM
// Design Name: 
// Module Name: ALU
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


module ALU#(parameter size = 32)(
    input [size -1:0] A,B, 
    input S2,S1,S0, //mode select operation selects
    input C_in, //carry input
    output [size-1:0]Y,
    output V,C,N,Z // v = overflow C=carry N=negative Z=zero
    );
    
    wire [size-1:0] au_out, lu_out, alu_out;
    wire v,c,n,au_z,lu_z,alu_z;
    
    defparam AU.size = size;
    arithmetic_unit AU(A,B,S1,S0,C_in,au_out,v,c,n,au_z);
    
    defparam LU.size = size;
    logic_unit LU(A,B,S0,C_in,lu_out,lu_z);
    
    defparam MUX_S.size = size;
    MUX MUX_S(au_out,lu_out,S2,alu_out);
    
    defparam MUX_Z.size = 1;
    MUX MUX_Z(au_z,lu_z,S2,alu_z);
    
    assign Y = alu_out;
    assign Z = alu_z;
    assign V = v;
    assign N = n;
    assign C = c;
    
endmodule

module arithmetic_unit#(parameter size = 32)(
    input [size -1:0] A,B,
    input S1,S0,C_in,
    output [size-1:0] S,
    output V,C,N,Z );
    
    defparam add_sub.size = size ;
    ADDER add_sub(A,B,S,S1,S0,C_in,V,C,N,Z);
    
    
endmodule

module logic_unit#(parameter size = 32)(
    input [size -1:0] A,B,
    input S0,C_in,
    output [size-1:0] S,
    output Z );
    
    wire [size-1:0] res_and,res_xor,res_or;
    wire [1:0] selector;
    assign selector = {S0,C_in};
    
    assign res_and = A & B;
    assign res_or = A | B;
    assign res_xor = A ^ B;
    
    assign S = ( selector == 2'b00 ? res_and : ( selector == 2'b01 ? res_or : ( selector == 2'b10 ? res_xor : 32'h0000))); 
    assign Z = ( S == 32'h0000 ? 1'b1 : 1'b0);
    
endmodule

module MUX #(parameter size = 32)(
    input [size -1:0] A,B,
    input S2,
    output [size -1:0] S );
    
    assign S = ( S2 == 1'b1 ? B : ( S2 == 1'b0 ? A : 32'hAAAA)); //setted AAAA to control  
endmodule