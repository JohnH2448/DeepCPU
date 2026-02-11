import Configuration::*;
import Payloads::*;
import Enumerations::*;

module InstructionMemory (

    // Standard
    input logic clock,
    input logic reset,
    input logic redirect,

    // Read Interface
    input logic [31:0] readAddress,
    output logic [127:0] readData,
    output logic readValid
);

    // 256 x 128-bit instruction memory
    logic [127:0] memory [0:255];

    // Registered index
    logic [7:0] readIndex_q;

    // Memory Load for Sim
    initial $readmemh("Instructions.hex", memory);

    always_ff @(posedge clock) begin
        if (reset || redirect) begin
            readValid <= 1'b0;
            readData <= '0;
            readIndex_q <= '0;
        end else begin
            readIndex_q <= readAddress[11:4];
            readData <= memory[readIndex_q];
            readValid <= 1'b1;
        end
    end


endmodule
