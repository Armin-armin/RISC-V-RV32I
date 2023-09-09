`timescale 1ns / 1ps

module FU#(parameter size = 32)(
    input [size-1:0] A,B,
    input [3:0]G_select, //s2,s1,s0,c_in
    input [1:0]H_select,
    input [$clog2(size)-1 : 0] shamnt,
    input MF_select,
    input I_R, I_L,
    output [size-1:0] F,
    output V,C,N,Z
    );
    
    wire alu_v,alu_c,alu_z,alu_n,sh_v,sh_c,sh_n,sh_z;
    wire [size-1:0] g,h;
    
    defparam alu.size = size;
    ALU alu(A,B,G_select[3],G_select[2],G_select[1],G_select[0],g,alu_v,alu_c,alu_n,alu_z);
    
    defparam shifter.size = size;
    Shifter shifter(B,shamnt,H_select,I_R,I_L,h);
                    
    defparam MUX_F.size = size;                
    MUX MUX_F(g,h,MF_select,F);
    
    assign Z = alu_z;
    assign C = alu_c;
    assign N = alu_n;
    assign V = alu_v;
    
                    
endmodule
