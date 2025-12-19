//----------------------------------------------------------------------------------------------------
// Filename: CPUCore_tb.sv
// Author: Charles Bassani
// Description: Basic functional testbench for CPUCore pipeline
//----------------------------------------------------------------------------------------------------
`timescale 1ns/1ps

module CPUCore_tb;

//----------------------------------------------------------------------------------------------------
// Testbench Signals
//----------------------------------------------------------------------------------------------------
logic clk;
logic rst;

//----------------------------------------------------------------------------------------------------
// DUT
//----------------------------------------------------------------------------------------------------
CPUCore dut (
    .clk(clk),
    .rst(rst)
);

//----------------------------------------------------------------------------------------------------
// Clock Generation
//----------------------------------------------------------------------------------------------------
initial begin
    clk = 0;
    forever #5 clk = ~clk;  // 100MHz equivalent
end

//----------------------------------------------------------------------------------------------------
// Reset & Stimulus
//----------------------------------------------------------------------------------------------------
initial begin
    // Dump waveform
    $dumpfile("build/CPUCore_tb_wave.vcd");
    $dumpvars(0, CPUCore_tb);

    // Reset
    rst = 1;
    #20;
    rst = 0;

    // Let it run a few cycles
    repeat (40) @(posedge clk);

    // Dump registers at end
    $display("\n-----------------------------------------");
    $display("Register File Contents at End of Simulation");
    $display("-----------------------------------------");
    for (int i = 0; i < 32; i++) begin
        $display("R[%0d] = 0x%08h", i, dut.idstage_inst.rf_inst.regs[i]);
    end
    $display("-----------------------------------------\n");

    $finish;
end

//----------------------------------------------------------------------------------------------------
// Program Load
//----------------------------------------------------------------------------------------------------
initial begin
    string filename;
    if(!$value$plusargs("IMEM_FILE=%s", filename)) filename = "programs/imem_init.hex";
    $readmemh(filename, dut.ifstage_inst.imem_inst.mem);
end

//----------------------------------------------------------------------------------------------------
// Optional Monitors
//----------------------------------------------------------------------------------------------------
initial begin
    $display("Time\tPC\t\tInstruction\tWB_en\tWB_addr\tWB_data");
    forever begin
        @(posedge clk);
        $display("%0t\t%h\t%h\t%b\t%0d\t%h",
                 $time,
                 dut.IF_pc,
                 dut.IF_ID_instruction,
                 dut.WB_en,
                 dut.WB_addr,
                 dut.WB_data);
    end
end

endmodule
