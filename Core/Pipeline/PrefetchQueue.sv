import Configuration::*;
import Payloads::*;
import Enumerations::*;

module PrefetchQueue (

    // Standard
    input logic clock,
    input logic reset,

    // Control Signals
    input logic redirect,
    input logic [31:0] redirectVector,

    // Instruction Inputs
    input logic [127:0] instructionFetchData,
    input logic instructionFetchDataValid,

    // Address Lines
    output logic [31:0] alignedAddress,

    // Decode Communication
    output logic [31:0] instruction1,
    output logic instructionReady1,
    output logic [31:0] instruction2,
    output logic instructionReady2,
    input logic instructionConsumed1,
    input logic instructionConsumed2
);

    // Ring Buffer Declaration
    RingBufferEntry_ ringBuffer [0:3];

    // Pointer Declaration
    logic [1:0] headPointer;

    // Cannonical PC
    logic [31:0] programCounter;
    // needs to be speculatively incrimented, not based on pc
    // assign alignedAddress = {programCounter[31:4], 2'd0000}

    // Outgoing Address
    logic [31:0] outgoingAddress;

    // Instruction Output Assignments
    assign instruction1 = ringBuffer[headPointer].instructionData;
    assign instruction2 = ringBuffer[headPointer + 2'b1].instructionData;
    assign instructionReady1 = ringBuffer[headPointer].ready;
    assign instructionReady2 = ringBuffer[headPointer + 2'b1].ready;

    always_ff @(posedge clock) begin
        // Reset State
        if (reset || redirect) begin
            // Determine PC
            if (reset) begin
                programCounter <= resetVector;
                alignedAddress <= {resetVector[31:4], 4'd0};
            end else begin
                programCounter <= redirectVector;
                alignedAddress <= {redirectVector[31:4], 4'd0};
            end
            // Clear Queue
            headPointer <= '0;
            // Allocate New Entries
            for (logic [1:0] i = 2'd0; i < 2'd4; i++) begin
                ringBuffer[i].ready <= 1'b0;
                ringBuffer[i].instructionData <= '0; // can be removed
                ringBuffer[i].programCounter <= (reset ? resetVector : redirectVector) + {28'd0, i, 2'd0};
            end
        end else begin
            // Latch Outgoing Address
            outgoingAddress <= alignedAddress;
            // Data Fill
            if (instructionFetchDataValid) begin
                for (int j = 0; j < 4; j++) begin
                    if (!ringBuffer[j].ready && (ringBuffer[j].programCounter[31:4] == outgoingAddress[31:4])) begin
                        unique case (ringBuffer[j].programCounter[3:2])
                            2'd0: ringBuffer[j].instructionData <= instructionFetchData[31:0];
                            2'd1: ringBuffer[j].instructionData <= instructionFetchData[63:32];
                            2'd2: ringBuffer[j].instructionData <= instructionFetchData[95:64];
                            2'd3: ringBuffer[j].instructionData <= instructionFetchData[127:96];
                        endcase
                        ringBuffer[j].ready <= 1'b1;
                    end
                end
            end
            // PC Incriment
            if (instructionConsumed1 && instructionConsumed2) begin
                // Both Instructions Accepted
                programCounter <= programCounter + 32'd8;
                headPointer <= headPointer + 2'd2;
                // Allocates New Entries
                ringBuffer[headPointer + 2'd1].ready <= 1'b0;
                ringBuffer[headPointer + 2'd1].instructionData <= 32'b0;
                ringBuffer[headPointer + 2'd1].programCounter <= programCounter + 32'd20;
                ringBuffer[headPointer].ready <= 1'b0;
                ringBuffer[headPointer].instructionData <= 32'b0;
                ringBuffer[headPointer].programCounter <= programCounter + 32'd16;
            end else if (instructionConsumed1) begin
                // One Instruction Accepted
                programCounter <= programCounter + 32'd4;
                headPointer <= headPointer + 2'd1;
                // Allocates New Entry
                ringBuffer[headPointer].ready <= 1'b0;
                ringBuffer[headPointer].instructionData <= 32'b0;
                ringBuffer[headPointer].programCounter <= programCounter + 32'd16;
            end
        end
    end
endmodule

// entry creation is internal. use state to select from word at bus. hold until queue is full and then increment
// head pointer entry must always equal pc
// decode controls pc, prefetch always feeds pc and pc+4