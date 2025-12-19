//----------------------------------------------------------------------------------------------------
// Filename: CPUCore.sv
// Author: Charles Bassani
// Description: Logical CPU Core
//----------------------------------------------------------------------------------------------------
`timescale 1ns/1ps

//----------------------------------------------------------------------------------------------------
// Module Declaration
//----------------------------------------------------------------------------------------------------
module CPUCore
(
    input clk,
    input rst
);

//----------------------------------------------------------------------------------------------------
// Module Registers
//----------------------------------------------------------------------------------------------------
logic [31:0] IF_pc;
logic        IF_pc_en;
logic        IF_stall;
logic        IF_flush;

//IF/ID
logic [31:0] IF_ID_pc;
logic [31:0] IF_ID_instruction;

//ID/EX
logic [31:0] ID_EX_pc;
logic [31:0] ID_EX_instruction;
logic        ID_EX_regDst;
logic        ID_EX_regWrite;
logic        ID_EX_aluSrc;
logic        ID_EX_branch;
logic        ID_EX_jump;
logic        ID_EX_memRead;
logic        ID_EX_memWrite;
logic        ID_EX_memToReg;
logic        ID_EX_atomic;
logic [3:0]  ID_EX_mMask;
logic        ID_EX_beq;
logic        ID_EX_jal;
logic        ID_EX_jr;
logic        ID_EX_lui;
logic        ID_EX_zeroExt;
logic [3:0]  ID_EX_aluOp;
logic        ID_EX_useSign; 
logic [31:0] ID_EX_rsData; 
logic [31:0] ID_EX_rtData;

//EX/MEM
logic [31:0] EX_MEM_pc;
logic [31:0] EX_MEM_instruction;
logic        EX_MEM_regDst;
logic        EX_MEM_regWrite;
logic        EX_MEM_branch;
logic        EX_MEM_jump;
logic        EX_MEM_memRead;
logic        EX_MEM_memWrite;
logic        EX_MEM_memToReg;
logic        EX_MEM_atomic;
logic [3:0]  EX_MEM_mMask;
logic        EX_MEM_jal;
logic        EX_MEM_jr;
logic [31:0] EX_MEM_rsData;
logic [31:0] EX_MEM_rtData;
logic [31:0] EX_MEM_aluRes;
logic [31:0] EX_MEM_branchTarget;
logic [31:0] EX_MEM_jumpTarget;

//MEM/WB
logic [31:0] MEM_WB_pc;
logic [31:0] MEM_WB_instruction;
logic        MEM_WB_regDst;
logic        MEM_WB_regWrite;
logic        MEM_WB_memToReg;
logic        MEM_WB_jal;
logic [31:0] MEM_WB_aluRes;
logic        MEM_WB_scSuccess;
logic [31:0] MEM_WB_memData;

//WB
logic        WB_en;
logic [4:0]  WB_addr;
logic [31:0] WB_data;

//Forward
logic        fwdA_en;
logic        fwdB_en;
logic [31:0] fwdA_data;
logic [31:0] fwdB_data;


//----------------------------------------------------------------------------------------------------
// Nested Modules
//----------------------------------------------------------------------------------------------------
IF_Stage ifstage_inst
(
    .clk(clk),
    .rst(rst),
    .stall(~IF_ID_en),
    .flush(IF_flush),
    
    .pc_in(IF_pc),
    .pc_out(IF_ID_pc),
    
    .instruction_out(IF_ID_instruction)
);

ID_Stage idstage_inst
(
    .clk(clk),
    .rst(rst),
    .flush(IF_flush),
    .wbEn(WB_en),
    .wbAddr(WB_addr),
    .wbData(WB_data),

    .pc_in(IF_ID_pc),
    .instruction_in(IF_ID_instruction),
    .pc_out(ID_EX_pc),
    .instruction_out(ID_EX_instruction),
    
    .regDst_out(ID_EX_regDst),
    .regWrite_out(ID_EX_regWrite),
    .aluSrc_out(ID_EX_aluSrc),
    .branch_out(ID_EX_branch),
    .jump_out(ID_EX_jump),
    .memRead_out(ID_EX_memRead),
    .memWrite_out(ID_EX_memWrite),
    .memToReg_out(ID_EX_memToReg),
    .atomic_out(ID_EX_atomic),
    .mMask_out(ID_EX_mMask),
    .beq_out(ID_EX_beq),
    .jal_out(ID_EX_jal),
    .jr_out(ID_EX_jr),
    .lui_out(ID_EX_lui),
    .zeroExt_out(ID_EX_zeroExt),
    .aluOp_out(ID_EX_aluOp),
    .useSign_out(ID_EX_useSign),
    .rsData_out(ID_EX_rsData), 
    .rtData_out(ID_EX_rtData)
);

EX_Stage exstage_inst
(
    .clk(clk),
    .rst(rst),
    .aluSrc(ID_EX_aluSrc),
    .beq(ID_EX_beq),
    .lui(ID_EX_lui),
    .zeroExt(ID_EX_zeroExt),
    .aluOp(ID_EX_aluOp),
    .useSign(ID_EX_useSign),
    .fwdA_en(fwdA_en),
    .fwdB_en(fwdB_en),
    .fwdA_data(fwdA_data),
    .fwdB_data(fwdB_data),

    .pc_in(ID_EX_pc),
    .instruction_in(ID_EX_instruction),
    .regDst_in(ID_EX_regDst),
    .regWrite_in(ID_EX_regWrite),
    .branch_in(ID_EX_branch),
    .jump_in(ID_EX_jump),
    .memRead_in(ID_EX_memRead),
    .memWrite_in(ID_EX_memWrite),
    .memToReg_in(ID_EX_memToReg),
    .atomic_in(ID_EX_atomic),
    .mMask_in(ID_EX_mMask),
    .jal_in(ID_EX_jal),
    .jr_in(ID_EX_jr),
    .rsData_in(ID_EX_rsData),
    .rtData_in(ID_EX_rtData),
    .pc_out(EX_MEM_pc),
    .instruction_out(EX_MEM_instruction),
    .regDst_out(EX_MEM_regDst),
    .regWrite_out(EX_MEM_regWrite),
    .branch_out(EX_MEM_branch),
    .jump_out(EX_MEM_jump),
    .memRead_out(EX_MEM_memRead),
    .memWrite_out(EX_MEM_memWrite),
    .memToReg_out(EX_MEM_memToReg),
    .atomic_out(EX_MEM_atomic),
    .mMask_out(EX_MEM_mMask),
    .jal_out(EX_MEM_jal),
    .jr_out(EX_MEM_jr),
    .rsData_out(EX_MEM_rsData),
    .rtData_out(EX_MEM_rtData),

    .aluRes_out(EX_MEM_aluRes),
    .branchTarget_out(EX_MEM_branchTarget),
    .jumpTarget_out(EX_MEM_jumpTarget)
);

MEM_Stage memstage_inst
(
    .clk(clk),
    .rst(rst),
    .memRead(EX_MEM_memRead),
    .memWrite(EX_MEM_memWrite),
    .mMask(EX_MEM_mMask),
    .rtData(EX_MEM_rtData),
    .atomic(EX_MEM_atomic),

    .pc_in(EX_MEM_pc),
    .instruction_in(EX_MEM_instruction),
    .regDst_in(EX_MEM_regDst),
    .regWrite_in(EX_MEM_regWrite),
    .memToReg_in(EX_MEM_memToReg),
    .jal_in(EX_MEM_jal),
    .aluRes_in(EX_MEM_aluRes),
    .pc_out(MEM_WB_pc),
    .instruction_out(MEM_WB_instruction),
    .regDst_out(MEM_WB_regDst),
    .regWrite_out(MEM_WB_regWrite),
    .memToReg_out(MEM_WB_memToReg),
    .jal_out(MEM_WB_jal),
    .aluRes_out(MEM_WB_aluRes),

    .scSuccess_out(MEM_WB_scSuccess),
    .memData_out(MEM_WB_memData)
);

WB_Stage wbstage_isnt
(
    .clk(clk),
    .rst(rst),
    .pc(MEM_WB_pc),
    .instruction(MEM_WB_instruction),
    .regDst(MEM_WB_regDst),
    .regWrite(MEM_WB_regWrite),
    .memToReg(MEM_WB_memToReg),
    .jal(MEM_WB_jal),
    .aluRes(MEM_WB_aluRes),
    .scSuccess(MEM_WB_scSuccess),
    .memData(MEM_WB_memData),
    
    .wbEn(WB_en),
    .wbAddr(WB_addr),
    .wbData(WB_data)
);

ForwardingUnit fwu_inst
(
    .EX_MEM_regWrite(EX_MEM_regWrite),
    .EX_MEM_rd(EX_MEM_regDst ? EX_MEM_instruction[15:11] : EX_MEM_instruction[20:16]),
    .EX_MEM_aluRes(EX_MEM_aluRes),
    .EX_MEM_memRead(EX_MEM_memRead),
    .MEM_WB_regWrite(MEM_WB_regWrite),
    .MEM_WB_rd(WB_addr),
    .MEM_WB_data(WB_data),
    .ID_EX_rs(ID_EX_instruction[25:21]),
    .ID_EX_rt(ID_EX_instruction[20:16]),

    .fwdA_en(fwdA_en),
    .fwdA_data(fwdA_data),
    .fwdB_en(fwdB_en),
    .fwdB_data(fwdB_data)
);

HazardUnit hazu_inst
(
    .ID_EX_memRead(ID_EX_memRead),
    .EX_MEM_memWrite(EX_MEM_memWrite),
    .ID_EX_rt(ID_EX_instruction[20:16]),
    .IF_ID_rs(IF_ID_instruction[25:21]),
    .IF_ID_rt(IF_ID_instruction[20:16]),
    
    .PCWrite(IF_pc_en),
    .IF_ID_Write(IF_ID_en),
    .ID_EX_Flush(IF_flush),
    .stall(IF_stall)
);

//----------------------------------------------------------------------------------------------------
// Module Logic
//----------------------------------------------------------------------------------------------------
always_ff @(posedge clk or posedge rst) begin
    if(rst) IF_pc <= 32'b0;
    else if (IF_pc_en) begin
        if(EX_MEM_branch) IF_pc <= EX_MEM_branchTarget;
        else if(EX_MEM_jump) IF_pc <= EX_MEM_jumpTarget;
        else if(EX_MEM_jr) IF_pc <= EX_MEM_rsData;
        else IF_pc <= IF_pc + 4;
    end
end



endmodule