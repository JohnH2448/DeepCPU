import Configuration::*;
import Payloads::*;
import Enumerations::*;

module ReorderBuffer (

    // Standard
    input logic clock,
    input logic reset,

    // Instruction Inputs
    input InputInstruction_ completedMemory,
    input InputInstruction_ completedInstruction1,
    input InputInstruction_ completedInstruction2,
    input IssuedIntruction_ issuedInstruction1,
    input IssuedIntruction_ issuedInstruction2,

    // Writeback Output
    output RetiredInstruction_ resolvedInstruction1,
    output RetiredInstruction_ resolvedInstruction2,
    output logic triggerStore,

    // Issuer Control Signals For Decisions
    output logic [4:0] nextFreeSlots
);

    // Retired Instructions Per Cycle
    logic [1:0] retireCount;

    // Full Buffer Declaration
    QueueEntry_ reorderBuffer [0:15];

    // Free Slots
    logic [4:0] freeSlots;
    assign nextFreeSlots = freeSlots + {3'b000, retireCount};

    // Youngest Open Slot
    logic [4:0] nextTailPointer;
    assign nextTailPointer = 5'd16 - nextFreeSlots;

    // Next Free Slots Signals
    logic [4:0] calculatedNextFreeSlots;
    assign calculatedNextFreeSlots = freeSlots + {3'b000, retireCount} - 
        {4'b0000, issuedInstruction1.confirm} - {4'b0000, issuedInstruction2.confirm};

    always_ff @(posedge clock) begin
        // Reset Clear
        if (reset) begin
            for (int i=0; i<16; i++) begin
                reorderBuffer[i] <= '0;
            end
            freeSlots <= 5'd16;
        end else begin
            // Queue Steps
            unique case (retireCount)
                // No Retirement
                2'b00: begin

                end
                // Single Retirement
                2'b01: begin
                    // Shift Buffer
                    for (int i=0; i<15; i++) begin
                        reorderBuffer[i] <= reorderBuffer[i+1];
                    end
                end
                // Dual Retirement
                2'b10: begin
                    // Shift Buffer
                    for (int i=0; i<14; i++) begin
                        reorderBuffer[i] <= reorderBuffer[i+2];
                    end
                end
            endcase
            // Accept Instructions
            if (issuedInstruction1.confirm) begin
                reorderBuffer[nextTailPointer].programCounter <= issuedInstruction1.programCounter;
                reorderBuffer[nextTailPointer].destinationRegister <= issuedInstruction1.destinationRegister;
                reorderBuffer[nextTailPointer].ageTag <= issuedInstruction1.ageTag;
                reorderBuffer[nextTailPointer].isStore <= issuedInstruction1.isStore;
                reorderBuffer[nextTailPointer].resultsReady <= 1'b0;
            end
            if (issuedInstruction2.confirm) begin
                reorderBuffer[nextTailPointer + 5'd1].programCounter <= issuedInstruction2.programCounter;
                reorderBuffer[nextTailPointer + 5'd1].destinationRegister <= issuedInstruction2.destinationRegister;
                reorderBuffer[nextTailPointer + 5'd1].ageTag <= issuedInstruction2.ageTag;
                reorderBuffer[nextTailPointer + 5'd1].isStore <= issuedInstruction2.isStore;
                reorderBuffer[nextTailPointer + 5'd1].resultsReady <= 1'b0;
            end
            // Update Available Free Slots
            freeSlots <= calculatedNextFreeSlots;
        end
    end

endmodule

// EX to EX bypass cross stage
// forward else
// mem ops must detect illegal before buffer
// store buffer and forward to in progress loads
// try and be conservative with issue rules
// unified load and store memory queue
// no dual branch issues
// Wait for the head to be a store, 
// then fire it, and then wait for it to come back, 
// and only then continue to commit more
// store uses completedMemory with rd = 0
// for age tags distance = (B - A) mod ROB_SIZE
// 16 entry rob 4 bit age tag
// all depdendencies can be resolved without stall through forwarding
// except dependency on non ready loads. store "isLoad" in RST and block 
// issue. all other instructions should be able to issue
// ignore all resolved instructions into ROB without a valid bit 
// all backend pipeline instructions should never get invalidated
// from control. Invalidation (ie branch) comes from clearing ROB
// entries corresponding to age tag. Anything "invalid" in pipeline
// should not have a ROB entry allocated. Every entry should have
// a real, permenantly valid corresponding instruction in flight 
// or commited. Goal is no backend stalls ever. stall comes from
// issue refusal. There should be no bubbles corresponding to valid
// entries in ROB. flushing should be rare and specific, no drop-ins.
// On flush, clear ROB entries and also invalidate in flight. do both
// to prevent age tag edge case mistnterpretation. 
// all ROB entries are implicitly valid
// no forwarding from store to loads. not much optimization and complex
// use Dhrystone for IPC estimates
