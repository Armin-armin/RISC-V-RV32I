`timescale 1ns / 1ps

module Register #(
    parameter width = 32
    )(
    input clk,
    input rst,
    input en,
    input [width - 1 : 0] din,
    output reg [width - 1 : 0] dout
    );
    
    always @(posedge clk, negedge rst) begin
        if (!rst)
            dout = 0;
        else if (en)
            dout = din;
    end
endmodule
