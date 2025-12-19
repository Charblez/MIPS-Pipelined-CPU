// Filename: MEM_Stage.sv
// Author: Charles Bassani
// Description: Data memory interface stage
//----------------------------------------------------------------------------------------------------
`timescale 1ns/1ps

//----------------------------------------------------------------------------------------------------
// Module Declaration
//----------------------------------------------------------------------------------------------------
module MEM_Stage
(
    //Absorbed
    input  logic        clk,
    input  logic        rst,
    input  logic        memRead,
    input  logic        memWrite,
    input  logic [3:0]  mMask,
    input  logic [31:0] rtData,
    input  logic        atomic,
    
    //Direct Connections
    input  logic [31:0] pc_in,
    input  logic [31:0] instruction_in,
    input  logic        regDst_in,
    input  logic        regWrite_in,
    input  logic        memToReg_in,
    input  logic        jal_in,
    input  logic [31:0] aluRes_in,
    
    output logic [31:0] pc_out,
    output logic [31:0] instruction_out,
    output logic        regDst_out,
    output logic        regWrite_out,
    output logic        memToReg_out,
    output logic        jal_out,
    output logic [31:0] aluRes_out,

    //Combinational Outputs
    output logic        scSuccess_out,
    output logic [31:0] memData_out
);

//----------------------------------------------------------------------------------------------------
// Module Registers
//----------------------------------------------------------------------------------------------------
logic        linkActive;
logic [31:0] linkAddr;

logic        scSuccess;
logic [31:0] memData;

//----------------------------------------------------------------------------------------------------
// Nested Modules
//----------------------------------------------------------------------------------------------------
Memory dmem_inst
(
    .clk(clk),
    .rst(rst),
    .writeEn(memWrite && (!atomic || (atomic && linkActive && (linkAddr == aluRes_in)))),
    .mMask(mMask),
    .writeAddr(aluRes_in),
    .writeData(rtData),
    .readAddr(aluRes_in),
    .readData(memData)
);

//----------------------------------------------------------------------------------------------------
// Module Logic
//----------------------------------------------------------------------------------------------------
always_ff @(posedge clk or posedge rst) begin
    if(rst) begin
        linkActive <= 1'b0;
        linkAddr   <= 32'd0;
        scSuccess  <= 1'b0;
    end 
    else begin
        scSuccess  <= 1'b0;
        //Load Linked
        if(memRead && atomic) begin
            linkActive <= 1'b1;
            linkAddr   <= aluRes_in;
            scSuccess  <= 1'b0;
        end
        //Store Conditional
        else if(memWrite && atomic) begin
            if(linkActive && (linkAddr == aluRes_in)) begin
                scSuccess  <= 1'b1;
                linkActive <= 1'b0;
            end 
            else begin
                scSuccess <= 1'b0;
            end
        end
    end
end

always_ff @(posedge clk or posedge rst) begin
    if(rst) begin
        pc_out <= 32'd0;
        instruction_out <= 32'd0;
        regDst_out <= 1'b0;
        regWrite_out <= 1'b0;
        memToReg_out <= 1'b0;
        jal_out <= 1'b0;
        aluRes_out <= 32'd0;
        scSuccess_out <= 1'b0;
    end
    else begin
        //Direct Connections
        pc_out <= pc_in;
        instruction_out <= instruction_in;
        regDst_out <= regDst_in;
        regWrite_out <= regWrite_in;
        memToReg_out <= memToReg_in;
        jal_out <= jal_in;
        aluRes_out <= aluRes_in;

        //Combinational Outputs
        scSuccess_out <= scSuccess;
        memData_out <= memData;
    end
end

endmodule