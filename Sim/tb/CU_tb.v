`timescale 1ns / 1ps

module CU_tb();
    parameter width = 32;
    parameter depth = 32;
    reg clk;
    reg rst_cu_dp;
    reg rst_mem;
    reg instr_we;
    reg [$clog2(depth) - 1: 0] instr_waddr;
    reg [width - 1: 0] instr_wdata;
    wire [31:0] instr;
    wire [$clog2(depth) - 1: 0] raddr_tmp;
    wire [width - 1: 0] rdata_tmp;
    
    reg data_we;
    wire [$clog2(depth) - 1: 0] data_waddr;
    reg [$clog2(depth) - 1: 0] data_waddr_reg;
    wire [width - 1: 0] data_wdata;
    reg [width - 1: 0] data_wdata_reg;
    wire [$clog2(depth) - 1: 0] data_raddr;
    wire [width - 1: 0] data_rdata;
    wire [$clog2(depth) - 1: 0] raddr_tmp2;
    wire [width - 1: 0] rdata_tmp2;
    
    wire N;
    wire Z;
    wire V;
    wire C;
    wire [4:0] waddr;
    wire [4:0] raddr0;
    wire [4:0] raddr1;
    wire MB;
    wire [3:0] FS;
    wire MD;
    wire [2:0] wstrobe;
    wire we;
    wire [4:0] shamnt;
    wire [31:0] ConsOut;
    wire [31:0] InstrAddr;
    
    reg [31:0] instr_init [0:31];
    reg [31:0] data_init [0:31];
    integer i;
    
    RF #(
        depth,
        width
        ) instr_mem (
        clk,
        rst_mem,
        instr_we,
        instr_waddr,
        instr_wdata,
        3'b100,
        InstrAddr[4:0],
        instr,
        raddr_tmp,
        rdata_tmp
        );
    
    RF #(
        depth,
        width
        ) data_mem (
        clk,
        rst_mem,
        data_we,
        data_waddr_reg,
        data_wdata_reg,
        3'b100,
        data_waddr_reg,
        data_rdata,
        raddr_tmp2,
        rdata_tmp2
        );
    
    CU CU (
        clk,
        rst_cu_dp,
        N,
        Z,
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
        ConsOut,
        InstrAddr
        );
    
    Datapath #(
        depth,
        width
        ) Datapath (
        clk,
        rst_cu_dp,
        waddr,
        raddr0,
        raddr1,
        MB,
        FS,
        MD,
        wstrobe,
        we,
        shamnt,
        data_rdata,
        ConsOut,
        data_wdata,
        data_waddr,
        V,
        C,
        N,
        Z
        );
    
    always
        #5 clk <= ~clk;        

    always @(*) begin
        data_waddr_reg <= data_waddr;
        data_wdata_reg <= data_wdata;
    end
    
    initial begin
        clk <= 0;
        rst_cu_dp <= 0;
        rst_mem <= 0;
        #10 rst_cu_dp <= 1;
        rst_mem <= 1;
        $readmemb("instr_init.mem", instr_init);
        $readmemb("data_init.mem", data_init);
        instr_we = 1'b1;
        data_we = 1'b1;
        for (i = 1; i <= 32; i = i + 1) begin
            #10 instr_waddr <= i;
            instr_wdata <= instr_init[i - 1];
            data_waddr_reg <= i;
            data_wdata_reg <= data_init[i - 1];
        end
        #10 instr_we <= 1'b0;        
        data_we <= 1'b0;
        rst_cu_dp <= 0;
        #10 rst_cu_dp <= 1;
        #200 $finish;
    end
            
endmodule
