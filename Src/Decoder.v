`timescale 1ns / 1ps

module Decoder #(
    parameter depth = 128
    )(
    input [$clog2(depth) - 1 : 0] waddri,
    output [depth - 1 : 0] waddro
    );

    assign waddro = {{(depth - 1){1'b0}}, {1'b1}} << waddri;
endmodule
