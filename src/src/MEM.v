`timescale 1ns / 1ps
`include "defines.v"

module MEM (input rst,
            //mem
            input mem_mem_re,
            input mem_mem_we,
            input [`MEMAddrBus] mem_mem_addr,
            //reg
            input mem_regfile_re,
            input ex_mem_regfile_we,
            input [`RegAddrBus] mem_regfile_waddr,
            output reg mem_wb_regfile_re,
            output reg mem_wb_regfile_we,
            output reg[`RegAddrBus] mem_wb_regfile_addr,
            
            input [`WordWidth] mem_data,
            output reg [`WordWidth] mem_wb_data
            );

            always @(*) begin
                mem_wb_regfile_re <= mem_regfile_re;
                mem_wb_regfile_we <= ex_mem_regfile_we;
                mem_wb_regfile_addr <= mem_regfile_waddr;
                mem_wb_data <= mem_data;
            end
    
endmodule
