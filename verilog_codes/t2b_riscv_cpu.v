// AstroTinker Bot : Task 2B : RISC-V CPU
/*
# Team ID:          2396
# Theme:            AstroTinker Bot 
# Author List:      Anirudh Bhogi, Banala Sahit Royal
# Filename:         t2b_riscv_cpu
# File Description: Top level entity of riscv cpu implemented
# Global variables: None
*/


// t2b_riscv_cpu module declaration
module t2b_riscv_cpu (
    input clk, reset,
    input Ext_MemWrite,
    input [31:0] Ext_WriteData, Ext_DataAdr,
    output MemWrite,
    output [31:0] WriteData, DataAdr, ReadData
);

// wire lines from other modules
wire [31:0] PC, Instr;
wire MemWrite_rv32;
wire [31:0] DataAdr_rv32, WriteData_rv32;

// instantiate processor and memories
riscv_cpu rvsingle (clk, reset, PC, Instr, MemWrite_rv32, DataAdr_rv32, WriteData_rv32, ReadData, flag);
instr_mem imem (PC, Instr);
data_mem dmem (clk, MemWrite, DataAdr, WriteData, ReadData);

// output assignments
assign MemWrite = (Ext_MemWrite && reset) ? 1 : MemWrite_rv32;
assign WriteData = (Ext_MemWrite && reset) ? Ext_WriteData : WriteData_rv32;
assign DataAdr = (reset) ? Ext_DataAdr : DataAdr_rv32;

endmodule

