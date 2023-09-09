`timescale 1ns / 1ps

module ID(
    input [31:0] instr,
    output [4:0] waddr,
    output [4:0] raddr0,
    output [4:0] raddr1,
    output MB,
    output [3:0] FS,
    output MD,
    output [2:0] wstrobe,
    output we,
    output [4:0] shamnt,
    output PL,
    output JB,
    output BC,
    output reg [31:0] PCOffset,
    output reg [31:0] ConsOut
    );
    
    // immediate generation is handled in this module
    
    wire [6:0] opcode;
    reg [32:0] control;
    
    assign opcode = instr[6:0];
    assign waddr = control[32:28];
    assign raddr0 = control[27:23];
    assign raddr1 = control[22:18];
    assign MB = control[17];
    assign FS = control[16:13];
    assign MD = control[12];
    assign wstrobe = control[11:9];
    assign we = control[8];
    assign shamnt = control[7:3];
    assign PL = control[2];
    assign JB = control[1];
    assign BC = control[0];   
    
    always @(*) begin
        case (opcode)
            7'b0: begin     // OP-IMM   Integer Register-Immediate Instructions
                case (instr[14:12])
                    3'b000: begin       // ADDI
                        control <= {instr[11:7], instr[19:15], 5'b0, 1'b1, 4'b0010, 1'b0, 3'b100, 1'b1, 5'b0, 1'b0, 1'b0, 1'b0};
                        ConsOut <= $signed(instr[31:20]);
                        PCOffset <= 32'b0;
                    end
                    
                    3'b001: begin       // ANDI
                        control <= {instr[11:7], instr[19:15], 5'b0, 1'b1, 4'b1000, 1'b0, 3'b100, 1'b1, 5'b0, 1'b0, 1'b0, 1'b0};
                        ConsOut <= instr[31:20];
                        PCOffset <= 32'b0;
                    end
                    
                    3'b010: begin       // ORI
                        control <= {instr[11:7], instr[19:15], 5'b0, 1'b1, 4'b1001, 1'b0, 3'b100, 1'b1, 5'b0, 1'b0, 1'b0, 1'b0};
                        ConsOut <= instr[31:20];
                        PCOffset <= 32'b0;
                    end
                    
                    3'b011: begin       // XORI
                        control <= {instr[11:7], instr[19:15], 5'b0, 1'b1, 4'b1010, 1'b0, 3'b100, 1'b1, 5'b0, 1'b0, 1'b0, 1'b0};
                        ConsOut <= instr[31:20];
                        PCOffset <= 32'b0;
                    end
                    
                    3'b100: begin       // SLLI
                        control <= {instr[11:7], 5'b0, instr[19:15], 1'b0, 4'b1101, 1'b0, 3'b100, 1'b1, instr[24:20], 1'b0, 1'b0, 1'b0};
                        ConsOut <= 32'b0;
                        PCOffset <= 32'b0;
                    end
                    
                    3'b101: begin       // SRLI or SRAI
                        control <= {instr[11:7], 5'b0, instr[19:15], 1'b0, instr[30] ? 4'b1110 : 4'b1100, 1'b0, 3'b100, 1'b1, instr[24:20], 1'b0, 1'b0, 1'b0};
                        ConsOut <= 32'b0;
                        PCOffset <= 32'b0;
                    end
                    
                    default: begin
                        control <= 33'b0;
                        ConsOut <= 32'b0;
                        PCOffset <= 32'b0;
                    end
                endcase
            end
            
            7'b1: begin         // OP   Integer Register-Register Instructions
                case (instr[14:12])
                    3'b000: begin       // ADD
                        control <= {instr[11:7], instr[19:15], instr[24:20], 1'b0, 4'b0010, 1'b0, 3'b100, 1'b1, 5'b0, 1'b0, 1'b0, 1'b0};
                        ConsOut <= 32'b0;
                        PCOffset <= 32'b0;
                    end
                    
                    3'b001: begin       // AND
                        control <= {instr[11:7], instr[19:15], instr[24:20], 1'b0, 4'b1000, 1'b0, 3'b100, 1'b1, 5'b0, 1'b0, 1'b0, 1'b0};
                        ConsOut <= 32'b0;
                        PCOffset <= 32'b0;
                    end
                    
                    3'b010: begin       // OR
                        control <= {instr[11:7], instr[19:15], instr[24:20], 1'b0, 4'b1001, 1'b0, 3'b100, 1'b1, 5'b0, 1'b0, 1'b0, 1'b0};
                        ConsOut <= 32'b0;
                        PCOffset <= 32'b0;
                    end
                    
                    3'b011: begin      // XOR
                        control <= {instr[11:7], instr[19:15], instr[24:20], 1'b0, 4'b1010, 1'b0, 3'b100, 1'b1, 5'b0, 1'b0, 1'b0, 1'b0};
                        ConsOut <= 32'b0;
                        PCOffset <= 32'b0;
                    end
                    
                    3'b110: begin      // SLL or SUB
                        control <= instr[30] 
                                 ? {instr[11:7], instr[19:15], instr[24:20], 1'b0, 4'b0101, 1'b0, 3'b100, 1'b1, 5'b0, 1'b0, 1'b0, 1'b0}
                                 : {instr[11:7], 5'b0, instr[19:15], 1'b0, 4'b1101, 1'b0, 3'b100, 1'b1, instr[24:20], 1'b0, 1'b0, 1'b0};
                        ConsOut <= 32'b0;
                        PCOffset <= 32'b0;
                    end
                    
                    3'b111: begin       // SRL or SRA
                        control <= {instr[11:7], 5'b0, instr[19:15], 1'b0, instr[30] ? 4'b1110 : 4'b1100, 1'b0, 3'b100, 1'b1, instr[24:20], 1'b0, 1'b0, 1'b0};
                        ConsOut <= 32'b0;
                        PCOffset <= 32'b0;                                    
                    end
                    
                    default: begin
                        control <= 33'b0;
                        ConsOut <= 32'b0;
                        PCOffset <= 32'b0;
                    end
                endcase                
            end
            
            7'b10: begin        // J     Unconditional Jump
                control <= {5'b0, 5'b0, 5'b0, 1'b0, 4'b0000, 1'b0, 3'b100, 1'b0, 5'b0, 1'b1, 1'b1, 1'b0};
                ConsOut <= 32'b0;
                PCOffset <= $signed({instr[31], instr[19:12], instr[20], instr[30:21]});
            end
            
            7'b11: begin        // Conditional Branch
                case (instr[14:12])
                    3'b000: begin       // BEQ
                        control <= {5'b0, instr[19:15], instr[24:20], 1'b0, 4'b0101, 1'b0, 3'b100, 1'b0, 5'b0, 1'b1, 1'b0, 1'b0};
                        ConsOut <= 32'b0;
                        PCOffset <= $signed({instr[31], instr[7], instr[30:25], instr[11:8]});
                    end
                    
                    3'b001: begin       // BLT
                        control <= {5'b0, instr[19:15], instr[24:20], 1'b0, 4'b0101, 1'b0, 3'b100, 1'b0, 5'b0, 1'b1, 1'b0, 1'b1};
                        ConsOut <= 32'b0;
                        PCOffset <= $signed({instr[31], instr[7], instr[30:25], instr[11:8]});                  
                    end
                    
                    default: begin
                        control <= 33'b0;
                        ConsOut <= 32'b0;
                        PCOffset <= 32'b0;
                    end
                endcase
            end
            
            7'b100: begin      // Load
                control <= {instr[11:7], instr[19:15], 5'b0, 1'b0, 4'b0000, 1'b1, instr[14:12], 1'b1, 5'b0, 1'b0, 1'b0, 1'b0};
                ConsOut <= 32'b0;
                PCOffset <= 32'b0;
            end
            
            7'b101: begin      // Store
                control <= {5'b0, instr[19:15], instr[24:20], 1'b0, 4'b0000, 1'b0, 3'b100, 1'b0, 5'b0, 1'b0, 1'b0, 1'b0};
                ConsOut <= 32'b0;
                PCOffset <= 32'b0;                        
            end
            
            default: begin
                control <= 33'b0;
                ConsOut <= 32'b0;
                PCOffset <= 32'b0;
            end
        endcase
    end
endmodule
