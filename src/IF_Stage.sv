//----------------------------------------------------------------------------------------------------
// Filename: IF_Stage.sv
// Author: Charles Bassani
// Description: Fetches Instructions
//----------------------------------------------------------------------------------------------------
`timescale 1ns/1ps

//----------------------------------------------------------------------------------------------------
// Module Declaration
//----------------------------------------------------------------------------------------------------
module IF_Stage
(
    //Abosorbed
    input  logic        clk,
    input  logic        rst,
    input  logic        stall,
    input  logic        flush,

    //Direct Connections
    input  logic [31:0] pc_in,

    output logic [31:0] pc_out,
    
    //Combinational Outputs
    output logic [31:0] instruction_out
);

//----------------------------------------------------------------------------------------------------
// Module Registers
//----------------------------------------------------------------------------------------------------
logic [31:0] instruction;

//----------------------------------------------------------------------------------------------------
// Nested Modules
//----------------------------------------------------------------------------------------------------
Memory imem_inst
(
    .clk(clk),
    .rst(1'b0),
    .writeEn(1'b0),
    .mMask(4'hF),
    .writeAddr(12'b0),
    .writeData(32'b0),
    .readAddr(pc_in),
    .readData(instruction)
);

//----------------------------------------------------------------------------------------------------
// Module Logic
//----------------------------------------------------------------------------------------------------
always_ff @(posedge clk or posedge rst) begin
    if(rst) begin
        pc_out <= 32'b0;
        instruction_out <= 32'b0;
    end
    else if(flush) begin
        pc_out <= 32'b0;
        instruction_out <= 32'b0;
    end
    else if(!stall) begin
        pc_out <= pc_in;
        instruction_out <= instruction;
    end
end


endmodule