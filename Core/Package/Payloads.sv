import Configuration::*;
import Payloads::*;
import Enumerations::*;

package Payloads;

    // Scoreboard Entry
    typedef struct packed {
        logic [3:0] ageTag;
        logic isLoad;
        logic busy;
    } RegisterStatusEntry_;

    // Ring Buffer for Prefetch Queue
    typedef struct packed {
        logic [31:0] programCounter;
        logic [31:0] instructionData;
        logic ready;
    } RingBufferEntry_; 

    // For Upper Slot with Memory Support
    typedef struct packed {
        logic [31:0] programCounter; // dumped in OS
        logic [4:0] sourceRegister2;
        logic [4:0] sourceRegister1;
        logic [31:0] immediate;
        AluSource_ aluSource;
        MemoryOperation_ memoryOperation;
        logic [1:0] memoryWidth;
        logic memorySigned;
        BranchType_ branchType; 
        AluOperation_ aluOperation;
        JumpType_ jumpType;
        logic [3:0] ageTag;
        logic valid;
    } UpperIssuerOperandPayload_;

    // For Lower Slot
    typedef struct packed {
        logic [31:0] programCounter; // dumped in OS
        logic [4:0] sourceRegister2;
        logic [4:0] sourceRegister1;
        logic [31:0] immediate;
        AluSource_ aluSource;
        BranchType_ branchType; 
        AluOperation_ aluOperation;
        JumpType_ jumpType;
        logic [3:0] ageTag;
        logic valid;
    } LowerIssuerOperandPayload_;

    // For Upper Slot with Memory Support
    typedef struct packed {
        logic [31:0] operand1;
        logic [31:0] operand2;
        logic [31:0] extraField; // branch target, store data, etc
        AluOperation_ aluOperation;
        JumpType_ jumpType;
        BranchType_ branchType;
        MemoryOperation_ memoryOperation;
        logic [1:0] memoryWidth;
        logic memorySigned;
        logic [3:0] ageTag;
        logic valid;
    } UpperOperandExecutePayload_;

    // For Lower Slot 
    typedef struct packed {
        logic [31:0] operand1;
        logic [31:0] operand2;
        logic [31:0] extraField; // branch target, store data, etc
        AluOperation_ aluOperation;
        JumpType_ jumpType;
        BranchType_ branchType;
        logic [3:0] ageTag;
        logic valid;
    } LowerOperandExecutePayload_;

    // Upper Slot to Memory
    typedef struct packed {
        logic [31:0] address;
        logic [31:0] storeData;
        MemoryOperation_ memoryOperation;
        logic [1:0] memoryWidth;
        logic memorySigned;
        logic [3:0] ageTag;
        logic valid; // mem queue doesnt accept invalids
    } ExecuteMemoryPayload_;

    // Instruction from Pipeline to ROB
    typedef struct packed {
        logic [3:0] ageTag;
        logic [31:0] instructionResult;
        logic valid;
    } InputInstruction_;

    // Instruction from Issuer to ROB
    typedef struct packed {
        logic [31:0] programCounter;
        logic [4:0] destinationRegister;
        logic [3:0] ageTag;
        logic isStore;
        logic confirm;
    } IssuedIntruction_;

    // Queue Entry Struct
    typedef struct packed {
        logic [31:0] programCounter;
        logic [31:0] instructionResult;
        logic [4:0] destinationRegister;
        logic [3:0] ageTag;
        logic isStore;
        logic resultsReady;
    } QueueEntry_;

    // ROB Output to Regiser File
    typedef struct packed {
        logic [31:0] instructionResult;
        logic [4:0] destinationRegister;
        logic valid;
    } RetiredInstruction_;

endpackage