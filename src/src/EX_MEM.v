`timescale 1ns / 1ps
`include "defines.v"

module EX_MEM (input clk,
               input rst,
               //mme
               input ex_mem_re,
               input ex_mem_we,
               input [`MEMAddrBus] ex_mem_mem_addr,
               input [`RegAddrBus] ex_mem_regfile_waddr,
               input [`RegBus] ex_alu_result,
               output reg mem_mem_re,
               output reg mem_mem_we,
               output reg[`MEMAddrBus] mem_mem_addr,

               //reg
               input ex_mem_regfile_we,
               output reg mem_regfile_we,
               output reg[`RegAddrBus] mem_regfile_waddr,


               output reg[`WordWidth] mem_data
               );
    
    always @(posedge clk) begin
        
        mem_mem_re <= ex_mem_re;
        mem_mem_we <= ex_mem_we;
        mem_mem_addr <= ex_mem_mem_addr;

        mem_regfile_we <= ex_mem_regfile_we;

        mem_data <= ex_alu_result;
        mem_regfile_waddr <= ex_mem_regfile_waddr;
    end

endmodule
