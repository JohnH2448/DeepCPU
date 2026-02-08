import Configuration::*;
import Payloads::*;
import Enumerations::*;

package Enumerations;

    typedef enum logic [2:0] {
        BR_NONE = 3'd0,
        BR_EQ = 3'd1,
        BR_NE = 3'd2,
        BR_LT = 3'd3,
        BR_GE = 3'd4,
        BR_LTU = 3'd5,
        BR_GEU = 3'd6
    } BranchType_;

    typedef enum logic [6:0] {
        OPCODE_ALU_REG = 7'b0110011,
        OPCODE_MISC_MEM = 7'b0001111,
        OPCODE_ALU_IMM = 7'b0010011,
        OPCODE_LOAD = 7'b0000011,
        OPCODE_STORE = 7'b0100011,
        OPCODE_BRANCH = 7'b1100011,
        OPCODE_LUI = 7'b0110111,
        OPCODE_AUIPC = 7'b0010111,
        OPCODE_JAL = 7'b1101111,
        OPCODE_JALR = 7'b1100111,
        OPCODE_SYSTEM = 7'b1110011
    } Opcode_;

    typedef enum logic [1:0] {
        MEM_NONE = 2'b00,
        MEM_LOAD = 2'b01,
        MEM_STORE = 2'b10
    } MemoryOperation_;

    typedef enum logic [1:0] {
        JUMP_NONE = 2'b00,
        JUMP_JAL = 2'b01,
        JUMP_JALR = 2'b10
    } JumpType_;

    typedef enum logic [3:0] {
        ALU_ADD = 4'd0,
        ALU_SUB = 4'd1,
        ALU_AND = 4'd2,
        ALU_OR = 4'd3,
        ALU_XOR = 4'd4,
        ALU_SLL = 4'd5,
        ALU_SRL = 4'd6,
        ALU_SRA = 4'd7,
        ALU_SLT = 4'd8,
        ALU_SLTU = 4'd9
    } AluOperation_;

    typedef enum logic [1:0] {
        ALU_RS1_RS2 = 2'b00,
        ALU_RS1_IMM = 2'b01,
        ALU_PC_IMM = 2'b10,
        ALU_ZERO_IMM = 2'b11
    } AluSource_;

endpackage
