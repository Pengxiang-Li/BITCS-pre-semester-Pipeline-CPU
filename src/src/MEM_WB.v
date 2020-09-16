`timescale 1ns / 1ps
`include "defines.v"

module MEM_WB (input clk,
               input rst,
               input mem_wb_regfile_re,
               input mem_wb_regfile_we,
               input [`RegAddrBus] mem_wb_regfile_addr,
               input [`WordWidth] mem_wb_data,
               output reg wb_re,
               output reg wb_we,
               output reg[`RegAddrBus] wb_addr,
               output reg[`WordWidth] wb_data);
    
    always @(posedge clk) begin
        wb_re   <= mem_wb_regfile_re;
        wb_we   <= mem_wb_regfile_we;
        wb_addr <= mem_wb_regfile_addr;
        wb_data <= mem_wb_data;
    end
    
endmodule
