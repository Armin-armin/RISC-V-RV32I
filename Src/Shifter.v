`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/12/2023 06:56:08 PM
// Design Name: 
// Module Name: Shifter
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


module Shifter#(parameter size = 32)(
    input [size-1:0] B,
    input [$clog2(size)-1 : 0] shamnt,
    input [1:0] S,
    input I_R,I_L,
    output [size-1:0] H
    );
    wire [size-1:0] as_out,ls_out;
    defparam ArShift.size = size;
    arithmetic_shifter ArShift(B,S[0],shamnt,as_out);
    
    defparam LoShift.size = size;
    logical_shifter LoShift(B,S[0],shamnt,ls_out);
    
    assign H = S[1]==1'b1 ? as_out : (S[1] == 1'b0 ? ls_out : 32'habcd);
    
endmodule

module logical_shifter#(parameter size = 32)(
    input [size-1:0] B,
    input selection,
    input [$clog2(size)-1 : 0] shift_amount,
    output reg [size-1:0] C
);
    always @* begin
        if (selection == 0) begin
            C = B >> shift_amount;
        end
        else
            C = B << shift_amount;
    end
endmodule

module arithmetic_shifter#(parameter size = 32)(
    input [size-1:0] B,
    input selection,
    input [$clog2(size)-1 : 0] shift_amount,
    output reg [size-1:0] C
);
    always @* begin
        if (selection == 0) 
            C = $signed(B) >>> shift_amount;
        else
            C = $signed(B) <<< shift_amount;
    end
endmodule
