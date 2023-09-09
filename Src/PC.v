`timescale 1ns / 1ps

module PC #(
    parameter width = 32
    )(
    input clk,
    input rst,
    input PL,
    input JB,
    input BC,
    input N,
    input Z,
    input signed [31:0] Offset,
    output reg [31:0] InstrAddr
    );
    
    // if PL = 0, increment by 1; otherwise,
    // if JB = 1, increment by Offset; otherwise,
    // if BC = 0, increment by Offset if Z == 1; otherwise, increment by 1.
    // else if BC = 1, increment by Offset if N == 1; otherwise, increment by 1.
    
    reg [31:0] nextInstr;

    always @(*) begin
        if (!PL)
            nextInstr = InstrAddr + 1;
        else if (JB)
            nextInstr = InstrAddr + Offset;
        else begin
            if (BC)
                nextInstr = InstrAddr + (N ? Offset : 1);
            else
                nextInstr = InstrAddr + (Z ? Offset : 1);
        end
    end
    
    // Register
    always @(posedge clk, negedge rst) begin
        if (!rst)
            InstrAddr = 0;
        else
            InstrAddr = nextInstr;
    end
    
endmodule
