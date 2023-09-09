`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/11/2023 10:40:16 PM
// Design Name: 
// Module Name: ADDER
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


module ADDER#(parameter size = 32)(
    input  [size-1:0] X,Y,
    output [size-1:0] S,
    input S1,S0,
    input C_in,
    output V,C,N,Z);
    
    wire [size-1:0] res_add,res_sub,neg_y,res_subf;
    wire [1:0]selector;
    wire c_out_add, c_out_sub,c_out_subf,c_in_sub;
    wire less_than,equal_to,greater_than;
    assign neg_y = ~Y;
    assign selector = {S1,S0};
    
    defparam adder.size = size;
    RCA adder(X,Y,C_in,c_out_add,res_add);
    
    defparam subtractor.size = size;
    RCA subtractor(X,neg_y,1'b0 ,c_out_sub,res_sub);
    
    assign c_in_sub = (less_than | equal_to) ? 1'b1 : 1'b0;
    defparam f_subtractor.size = size;
    RCA f_subtractor(X, neg_y, 1'b1, c_out_subf, res_subf);    
    
    defparam comparator.size = size;
    Comparator comparator(X,Y,less_than,equal_to,greater_than);
    
    assign S = (selector == 2'b10) ? res_subf :
                (selector == 2'b01) ? res_add : 
                  (selector == 2'b00 )? Y : 
                    (selector == 2'b11) ? Y : 32'h2222; 
    assign V = (S[size-1]^X[size-1]) & ~(X[size-1]^Y[size-1]);
    assign N = ( selector == 2'b10 ? ( less_than == 1'b1 ? 1'b1 : 1'b0) : 1'b0);
    assign Z = ( selector == 2'b00 ? ( Y == 32'h0000 ? 1'b1 : 1'b0) : ( selector == 2'b01 ? ( res_add == 32'h0000 ? 1'b1 : 1'b0) : ( selector == 2'b10 ? ( res_subf == 32'h0000 ? 1'b1 : 1'b0 ) : ( selector == 2'b11 ? ( Y == 32'h0000 ? 1'b1 : 1'b0): 1'b0))));
    assign C = ( selector == 2'b00 ?  1'b0 : ( selector == 2'b01 ? c_out_add : ( selector == 2'b10 ? c_out_subf : ( selector == 2'b11 ? 1'b0 : 1'b0)))); 
    
   
endmodule

module Comparator#(parameter size = 32) (
    input [size-1:0] a,
    input [size-1:0] b,
    output reg less_than,
    output reg equal_to,
    output reg greater_than
);

always @(*) begin
    if ($signed(a) < $signed(b)) begin
        less_than = 1'b1;
        equal_to = 1'b0;
        greater_than = 1'b0;
    end else if ($unsigned(a) == $unsigned(b)) begin
        less_than = 1'b0;
        equal_to = 1'b1;
        greater_than = 1'b0;
    end else begin // a > b
        less_than = 1'b0;
        equal_to = 1'b0;
        greater_than = 1'b1;
    end
end

endmodule

module RCA#(parameter size = 32)(
    input [31:0] a,
    input [31:0] b,
    input carry_in,
    output carry_out,
    output [31:0] c
);
    wire [31:0] carry;

    genvar i;
    generate
        for (i=0; i<32; i=i+1) begin : adder_chain
            FA FA_gen (
                .a(a[i]),
                .b(b[i]),
                .carry_in(i==0 ? carry_in : carry[i-1]),
                .sum(c[i]),
                .carry_out(carry[i])
            );
        end
    endgenerate

    assign carry_out = carry[31];
   
endmodule

module FA (
    input a,
    input b,
    input carry_in,
    output sum,
    output carry_out
);
    assign sum = a ^ b ^ carry_in;
    assign carry_out = (a & b) | (carry_in & (a ^ b));
endmodule

