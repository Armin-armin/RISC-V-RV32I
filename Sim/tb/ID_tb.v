`timescale 1ns / 1ps

module ID_tb();
    parameter depth = 32;
    parameter width = 32;
    reg clk;
    reg rst;
    reg [31:0] instr;    
    wire [$clog2(depth) - 1: 0] waddr;
    wire [$clog2(depth) - 1: 0] raddr0;
    wire [$clog2(depth) - 1: 0] raddr1;
    wire MB;
    wire [3:0] FS;
    wire MD;
    wire [2:0] wstrobe;
    wire we;
    wire [4:0] shamnt;
    wire [width - 1: 0] DataIn;
    wire [width - 1: 0] ConsIn;    
    wire [width - 1: 0] DataOut;
    wire [width - 1: 0] AddrOut;
    wire V;
    wire C;
    wire N;
    wire Z;    
    wire PL;
    wire JB;
    wire BC;
    wire [31:0] PCOffset;    
    reg rf_we;
    reg [2:0] rf_wstrobe;    // 100 for whole word; 010 for half word; 001 for single byte; assuming width is 32
    reg [$clog2(depth) - 1: 0] rf_raddr1;
    wire [width - 1: 0] rf_rdata1;
    
    wire [11:0] int_N = 30;
    wire [11:0] int_A = 58;
        
    ID uut (
        instr,
        waddr,
        raddr0,
        raddr1,
        MB,
        FS,
        MD,
        wstrobe,
        we,
        shamnt,
        PL,
        JB,
        BC,
        PCOffset,
        ConsIn
        );
            
    Datapath #(
        depth,
        width
        ) Datapath (
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
        DataIn,
        rf_raddr1,
        rf_rdata1
        );     
    
    always
        #5 clk = ~clk;    
    
    initial begin
        // first initiate the memory with N at mem addr 0x10 and A at mem addr 0x11
        // then designate reg addr 0x01 for C, and perform the operations
        
        clk = 0;
        rst = 0;
        #10 rst = 1;
        
        // Load number 0x10 into reg addr 0x01                                          ADDI r1, r0, #2
        rf_we <= 1'b0;
        instr <= {12'b10, 5'b0, 3'b0, 5'b1, 7'b0};
        #10;
        
        // Load N into reg addr 0x10                                                    ADDI r2, r0, #N
        instr <= {int_N, 5'b0, 3'b0, 5'b10, 7'b0};
        #10;
        
        // Store reg addr 0x10 into memory addr pointed by reg addr 0x01                STORE r2, (r1)
        rf_we <= 1'b1;
        rf_wstrobe <= 3'b100;   // whole word storing
        instr <= {7'b0, 5'b10, 5'b1, 3'b100, 5'b0, 7'b101};
        #10;                
        
        // Load number 0x11 into reg addr 0x01                                          ADDI r1, r0, #3
        rf_we <= 1'b0;
        instr <= {12'b11, 5'b0, 3'b0, 5'b1, 7'b0};
        #10;
        
        // Load A into reg addr 0x10                                                    ADDI r2, r0, #A
        instr <= {int_A, 5'b0, 3'b0, 5'b10, 7'b0};
        #10;
        
        // Store reg addr 0x10 into memory addr pointed by reg addr 0x01                STORE r2, (r1)
        rf_we <= 1'b1;
        instr <= {7'b0, 5'b10, 5'b1, 3'b100, 5'b0, 7'b101};
        #10;
        
        // Load number 0x01 into reg addr 0x01                                          ADDI r1, r0, #1
        rf_we <= 1'b0;
        instr <= {12'b1, 5'b0, 3'b0, 5'b1, 7'b0};
        #10;
        
        // Shift reg addr 0x01 by 1 and load back to reg addr 0x01                      SLLI r1, r1, #1
        instr <= {7'b0, 5'b1, 5'b1, 3'b100, 5'b1, 7'b0};
        #10;
        
        // Load number 0x10 into reg addr 0x10                                          ADDI r2, r0, #2
        instr <= {12'b10, 5'b0, 3'b0, 5'b10, 7'b0};
        #10;
        
        // Load memory addr pointed by reg addr 0x10 into reg addr 0x10                 LOAD r2, (r2)
        instr <= {12'b0, 5'b10, 3'b100, 5'b10, 7'b100};
        #10;
        
        // Subtract reg addr 0x10 from reg addr 0x01 and load back to reg addr 0x01     SUB r1, r1, r2
        instr <= {7'b0100000, 5'b10, 5'b1, 3'b110, 5'b1, 7'b1};
        #10;
        
        // Load number 0x11 into reg addr 0x10                                          ADDI r2, r0, #3
        instr <= {12'b11, 5'b0, 3'b0, 5'b10, 7'b0};
        #10;
        
        // Load memory addr pointed by reg addr 0x10 into reg addr 0x10                 LOAD r2, (r2)
        instr <= {12'b0, 5'b10, 3'b100, 5'b10, 7'b100};
        #10;
        
        // Add reg addr 0x10 to reg addr 0x01 and load back to reg addr 0x01            ADD r1, r1, r2
        instr <= {7'b0, 5'b10, 5'b1, 3'b0, 5'b1, 7'b1};
        #10;
        
        // Load number 0x10 into reg addr 0x10                                          ADDI r2, r0, #2
        instr <= {12'b10, 5'b0, 3'b0, 5'b10, 7'b0};
        #10;
        
        // Load memory addr pointed by reg addr 0x10 into reg addr 0x10                 LOAD r2, (r2)
        instr <= {12'b0, 5'b10, 3'b100, 5'b10, 7'b100};
        #10;
        
        // Subtract reg addr 0x10 from reg addr 0x01 and load back to reg addr 0x01     SUB r1, r1, r2
        instr <= {7'b0100000, 5'b10, 5'b1, 3'b110, 5'b1, 7'b1};
        #10;
        
        #5 $finish; 
    end
endmodule
