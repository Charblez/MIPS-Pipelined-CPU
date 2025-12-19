//----------------------------------------------------------------------------------------------------
// Filename: ID_Stage.sv
// Author: Charles Bassani
// Description: Decodes Instructions
//----------------------------------------------------------------------------------------------------
`timescale 1ns/1ps

//----------------------------------------------------------------------------------------------------
// Module Declaration
//----------------------------------------------------------------------------------------------------
module ID_Stage
(
    //Absorbed
    input  logic        clk,
    input  logic        rst,
    input  logic        flush,
    input  logic        wbEn,
    input  logic [4:0]  wbAddr,
    input  logic [31:0] wbData,

    //Direct Connections
    input  logic [31:0] pc_in,
    input  logic [31:0] instruction_in,

    output logic [31:0] pc_out,
    output logic [31:0] instruction_out,
    
    //Combinational Outputs
    output logic        regDst_out,
    output logic        regWrite_out,
    output logic        aluSrc_out,
    output logic        branch_out,
    output logic        jump_out,
    output logic        memRead_out,
    output logic        memWrite_out,
    output logic        memToReg_out,
    output logic        atomic_out,
    output logic [3:0]  mMask_out,
    output logic        beq_out,
    output logic        jal_out,
    output logic        jr_out,
    output logic        lui_out,
    output logic        zeroExt_out,
    output logic [3:0]  aluOp_out,
    output logic        useSign_out,
    output logic [31:0] rsData_out, 
    output logic [31:0] rtData_out
);

//----------------------------------------------------------------------------------------------------
// Module Registers
//----------------------------------------------------------------------------------------------------
logic        regDst;
logic        regWrite;
logic        aluSrc;
logic        branch;
logic        jump;
logic        memRead;
logic        memWrite;
logic        memToReg;
logic        atomic;
logic [3:0]  mMask;
logic        beq;
logic        jal;
logic        jr;
logic        lui;
logic        zeroExt;
logic [3:0]  aluOp;
logic        useSign;
logic [31:0] rsData; 
logic [31:0] rtData;

//----------------------------------------------------------------------------------------------------
// Nested Modules
//----------------------------------------------------------------------------------------------------
MainControlUnit mcu_inst
(
    .instruction_in(instruction_in),
    .regDst(regDst),
    .regWrite(regWrite),
    .aluSrc(aluSrc),
    .branch(branch),
    .jump(jump),
    .memRead(memRead),
    .memWrite(memWrite),
    .memToReg(memToReg),
    .atomic(atomic),
    .mMask(mMask),
    .beq(beq),
    .jal(jal),
    .jr(jr),
    .lui(lui),
    .zeroExt(zeroExt)
);

ALUControlUnit alucu_inst
(
    .instruction_in(instruction_in),
    .aluOp(aluOp),
    .useSign(useSign)
);

RegisterFile rf_inst
(
    .clk(clk),
    .rst(rst),
    .writeEn(wbEn),
    .writeAddr(wbAddr),
    .writeData(wbData),
    .readAddr1(instruction_in[25:21]),
    .readAddr2(instruction_in[20:16]),
    .readData1(rsData),
    .readData2(rtData)
);

//----------------------------------------------------------------------------------------------------
// Module Logic
//----------------------------------------------------------------------------------------------------
always_ff @(posedge clk or posedge rst) begin
    if(rst) begin
        pc_out <= 32'b0;
        instruction_out <= 32'b0;
        regDst_out <= 1'b0;
        regWrite_out <= 1'b0;
        aluSrc_out <= 1'b0;
        branch_out <= 1'b0;
        jump_out <= 1'b0;
        memRead_out <= 1'b0;
        memWrite_out <= 1'b0;
        memToReg_out <= 1'b0;
        atomic_out <= 1'b0;
        mMask_out <= 4'h0;
        beq_out <= 1'b0;
        jal_out <= 1'b0;
        jr_out <= 1'b0;
        lui_out <= 1'b0;
        zeroExt_out <= 1'b0;
        aluOp_out <= 4'h0;
        useSign_out <= 1'b0;
        rsData_out <= 32'd0;
        rtData_out <= 32'd0;
    end
    else if(flush) begin
        pc_out <= 32'b0;
        instruction_out <= 32'b0;
        regDst_out <= 1'b0;
        regWrite_out <= 1'b0;
        aluSrc_out <= 1'b0;
        branch_out <= 1'b0;
        jump_out <= 1'b0;
        memRead_out <= 1'b0;
        memWrite_out <= 1'b0;
        memToReg_out <= 1'b0;
        atomic_out <= 1'b0;
        mMask_out <= 4'h0;
        beq_out <= 1'b0;
        jal_out <= 1'b0;
        jr_out <= 1'b0;
        lui_out <= 1'b0;
        zeroExt_out <= 1'b0;
        aluOp_out <= 4'h0;
        useSign_out <= 1'b0;
        rsData_out <= 32'd0;
        rtData_out <= 32'd0;
    end
    else begin
        //Direct Connections
        pc_out <= pc_in;
        instruction_out <= instruction_in;

        //Combinational Outputs
        regDst_out <= regDst;
        regWrite_out <= regWrite;
        aluSrc_out <= aluSrc;
        branch_out <= branch;
        jump_out <= jump;
        memRead_out <= memRead;
        memWrite_out <= memWrite;
        memToReg_out <= memToReg;
        atomic_out <= atomic;
        mMask_out <= mMask;
        beq_out <= beq;
        jal_out <= jal;
        jr_out <= jr;
        lui_out <= lui;
        zeroExt_out <= zeroExt;
        aluOp_out <= aluOp;
        useSign_out <= useSign;
        rsData_out <= rsData;
        rtData_out <= rtData;
    end
end

endmodule