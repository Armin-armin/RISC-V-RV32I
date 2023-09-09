`timescale 1ns / 1ps

module Datapath_tb();
    parameter depth = 32;
    parameter width = 32;
    reg clk;
    reg rst;
    reg [$clog2(depth) - 1: 0] waddr;
    reg [$clog2(depth) - 1: 0] raddr0;
    reg [$clog2(depth) - 1: 0] raddr1;
    reg MB;
    reg [3:0] FS;
    reg MD;
    reg [2:0] wstrobe;
    reg we;
    reg [4:0] shamnt;
    reg [width - 1: 0] DataIn;
    reg [width - 1: 0] ConsIn;
    wire [width - 1: 0] DataOut;
    wire [width - 1: 0] AddrOut;
    wire V;
    wire C;
    wire N;
    wire Z;
    
    reg rf_we;
    reg [2:0] rf_wstrobe;    // 100 for whole word; 010 for half word; 001 for single byte; assuming width is 32
    reg [$clog2(depth) - 1: 0] rf_raddr1;
    wire [width - 1: 0] rf_rdata1;
    wire [width - 1: 0] DataIn_Net;    
    
    integer int_N = 20;
    integer int_A = 30;
    
    reg [29:0] control;
        
    Datapath #(
        depth,
        width
        ) uut (
        clk,
        rst,
        waddr,
        raddr0,
        raddr1,
        MB,
        FS,
        MD,
        wstrobe,
        we,
        shamnt,
        DataIn,
        ConsIn,
        DataOut,
        AddrOut,
        V,
        C,
        N,
        Z
        );
        
    RF #(
    depth,
    width
    ) RF (
    clk,
    rst,
    rf_we,
    AddrOut[4:0],
    DataOut,
    rf_wstrobe,
    AddrOut[4:0],
    DataIn_Net,
    rf_raddr1,
    rf_rdata1
    );                
    
    always @(*)
        DataIn = DataIn_Net;
    
    always
        #5 clk = ~clk;

    always @(*) begin
        waddr <= control[29:25];
        raddr0 <= control[24:20];
        raddr1 <= control[19:15];
        MB <= control[14];
        FS <= control[13:10];
        MD <= control[9];
        wstrobe <= control[8:6];
        we <= control[5];
        shamnt <= control[4:0];        
    end
    
    initial begin
        // first initiate the memory with N at mem addr 0x10 and A at mem addr 0x11
        // then designate reg addr 0x01 for C, and perform the operations
        
        clk = 0;
        rst = 0;
        #10 rst = 1;
        
        // Load number 0x10 into reg addr 0x01
        rf_we <= 1'b0;
        control <= {5'b00001, 5'b00000, 5'b00000, 1'b1, 4'b0000, 1'b0, 3'b100, 1'b1, 5'b00000};
        ConsIn <= 32'b10;
        #10;
        
        // Store N into memory addr pointed by reg addr 0x01
        rf_we <= 1'b1;
        rf_wstrobe <= 3'b100;   // whole word storing
        control <= {5'b00000, 5'b00001, 5'b00000, 1'b1, 4'b0000, 1'b0, 3'b100, 1'b0, 5'b00000};
        ConsIn <= int_N;
        #10;
        
        // Load number 0x11 into reg addr 0x01
        rf_we <= 1'b0;
        control <= {5'b00001, 5'b00000, 5'b00000, 1'b1, 4'b0000, 1'b0, 3'b100, 1'b1, 5'b00000};
        ConsIn <= 32'b11;
        #10;
        
        // Store A into memory addr pointed by reg addr 0x01
        rf_we <= 1'b1;
        control <= {5'b00000, 5'b00001, 5'b00000, 1'b1, 4'b0000, 1'b0, 3'b100, 1'b0, 5'b00000};
        ConsIn <= int_A;
        #10;
        
        // Load number 0x01 into reg addr 0x01
        rf_we <= 1'b0;
        control <= {5'b00001, 5'b00000, 5'b00000, 1'b1, 4'b0000, 1'b0, 3'b100, 1'b1, 5'b00000};
        ConsIn <= 32'b1;
        #10;
        
        // Shift reg addr 0x01 by 1 and load back to reg addr 0x01
        control <= {5'b00001, 5'b00000, 5'b00001, 1'b0, 4'b1101, 1'b0, 3'b100, 1'b1, 5'b00001};
        #10;
        
        // Load number 0x10 into reg addr 0x10
        control <= {5'b00010, 5'b00000, 5'b00000, 1'b1, 4'b0000, 1'b0, 3'b100, 1'b1, 5'b00000};
        ConsIn <= 32'b10;
        #10;
        
        // Load memory addr pointed by reg addr 0x10 into reg addr 0x10
        control <= {5'b00010, 5'b00010, 5'b00000, 1'b0, 4'b0000, 1'b1, 3'b100, 1'b1, 5'b00000};
        #10;
        
        // Subtract reg addr 0x10 from reg addr 0x01 and load back to reg addr 0x01
        control <= {5'b00001, 5'b00001, 5'b00010, 1'b0, 4'b0101, 1'b0, 3'b100, 1'b1, 5'b00000};
        #10;
        
        // Load number 0x11 into reg addr 0x10
        control <= {5'b00010, 5'b00000, 5'b00000, 1'b1, 4'b0000, 1'b0, 3'b100, 1'b1, 5'b00000};
        ConsIn <= 32'b11;
        #10;
        
        // Load memory addr pointed by reg addr 0x10 into reg addr 0x10
        control <= {5'b00010, 5'b00010, 5'b00000, 1'b0, 4'b0000, 1'b1, 3'b100, 1'b1, 5'b00000};
        #10;
        
        // Add reg addr 0x10 to reg addr 0x01 and load back to reg addr 0x01
        control <= {5'b00001, 5'b00001, 5'b00010, 1'b0, 4'b0010, 1'b0, 3'b100, 1'b1, 5'b00000};
        #10;
        
        // Load number 0x10 into reg addr 0x10
        control <= {5'b00010, 5'b00000, 5'b00000, 1'b1, 4'b0000, 1'b0, 3'b100, 1'b1, 5'b00000};
        ConsIn <= 32'b10;
        #10;
        
        // Load memory addr pointed by reg addr 0x10 into reg addr 0x10
        control <= {5'b00010, 5'b00010, 5'b00000, 1'b0, 4'b0000, 1'b1, 3'b100, 1'b1, 5'b00000};
        #10;
        
        // Subtract reg addr 0x10 from reg addr 0x01 and load back to reg addr 0x01
        control <= {5'b00001, 5'b00001, 5'b00010, 1'b0, 4'b0101, 1'b0, 3'b100, 1'b1, 5'b00000};
        #10;
                
        #5 $finish; 
    end
endmodule
