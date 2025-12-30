# MIPS 32-bit Pipelined Processor (Verilog)

## Overview
This project implements a 32-bit MIPS pipelined processor using Icarus Verilog, following the class 5-stage pipeline architecture:
1. Instruction Fetch (IF)
2. Intruction Decode (ID)
3. Execute (EX)
4. Memory Access (MEM)
5. Write Back (WB)

## Pipeline Architecture

### Pipeline Stages
- **IF**: Fetches instruction from memory using the Program Counter (PC)
- **ID**: Decodes instructions, reads registers, generates control signals
- **EX**: ALU operations, branch comparison, address calculation
- **MEM**: Access data memory for load/store instructions
- **WB**: Writes results back into register file

### Pipeline Registers
- IF/ID
- ID/EX
- EX/MEM
- MEM/WB

## Supported Instructions
- R-Type: `add` `addu` `and` `jr` `nor` `or` `slt` `sltu` `sll` `srl` `sub` `subu`
- I-Type: `addi` `addiu` `andi` `beq` `bne` `lbu` `lhu` `ll` `lui` `lw` `ori` `slti` `sltiu` `sb` `sc` `sh` `sw` 
- J-Type: `j` `jal`

## Hazard Handling

### Data Hazards
- Forwarding implemented to resolve
  - EX -> EX hazards
  - MEM -> EX hazards

## Core Modules
 
### Control Unit
The Control Unit generates signals for:
- Register write
- ALU operation
- Memory read/write
- Branch and jump control
- Mem-to-Register selection

Control signals are propgated throught the pipeline registers

### ALU
- Supports arithmetic and logical operations
- Controlled bia ALU Control module derived from opecode/funct fields

### Register File
- 32 registers
- `$0` hardwires to zero
- Two read ports, one write port

### Memory
- Instruction Memory: Read-only
- Data Memory: Supports all load and store opcaodes

### Reset and Clock
- Synchronous reset
- All pipeline registers cleared on reset

## Testing
- At the project root, run `make test CPUCore <testname>` where testname is the .hex for the bytecode to run
- Similarly, to open gtkwave as well use `make simulate CPUCore <testname>`

## Known Limitations
- No floating point support
- No exception handling
