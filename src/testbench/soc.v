`timescale 1ns / 1ps
`include "defines.v"

module soc ();
    // CPU Parameters
    parameter PERIOD = 10;
    
    
    // CPU Inputs
    reg   clk               = 0 ;
    reg   rst               = `RstEnable ;
    wire   [31:0] rom_data_i ;
    
    // CPU Outputs
    wire  [31:0] rom_addr_o             ;
    wire  rom_ce_o                             ;
    
    
    initial
    begin
        forever #(PERIOD/2)  clk = ~clk;
    end
    
    always @(posedge clk) begin
        rst <= `RstDisable;
    end
    
    PipeLine  u_PipeLine (
    .clk                       (clk),
    .rst                       (rst),
    .rom_data_i  (rom_data_i),
    
    .rom_addr_o  (rom_addr_o),
    .rom_ce_o                  (rom_ce_o)
    );
    
    inst_rom inst_rom0(
    .ce(rom_ce_o),
    .addr(rom_addr_o),
    .inst(rom_data_i)
    );
    
    initial begin
        $readmemh("E:\\short_semester\\teaching\\insturction.txt", inst_rom0.inst_mem);
        $readmemh("E:\\short_semester\\code\\PipeLine\\src\\testbench\\data\\regfile.txt", u_PipeLine.u_RegFile.regs);
    end
    
    
endmodule
