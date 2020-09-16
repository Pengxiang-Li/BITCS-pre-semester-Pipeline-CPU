`timescale 1ns / 1ps
`include "defines.v"

`timescale 1ns / 1ps
`include "defines.v"

module ID_EX (input clk,
              input rst,
              //reg
              input id_ex_regfile_we,
              input [`RegAddrBus] id_ex_regfile_waddr,
              input [`AluOpBus] id_ex_alu_op,
              input [`RegBus] id_ex_alu_src1,
              input [`RegBus] id_ex_alu_src2,
              output reg ex_regfile_we,
              output reg [`RegAddrBus] ex_regfile_waddr,
              output reg [`AluOpBus] ex_alu_op,
              output reg [`RegBus] ex_alu_src1,
              output reg [`RegBus] ex_alu_src2,
              //mem
              input id_ex_mem_re,
              input id_ex_mem_we,
              output reg ex_mem_re,
              output reg ex_mem_we);
    

    always @(posedge clk) begin
        if (rst == `RstEnable) begin
            ex_regfile_we <= `WriteDisable;
            ex_alu_op <= `EXE_NOP_OP;
            ex_mem_we <= `WriteDisable;
            ex_mem_re <= `ReadDisable;
        end
        else begin
            ex_regfile_we <= id_ex_regfile_we;
            ex_regfile_waddr <= id_ex_regfile_waddr;
            ex_alu_op <= id_ex_alu_op;
            ex_alu_src1 <= id_ex_alu_src1;
            ex_alu_src2 <= id_ex_alu_src2;

            ex_mem_re <= id_ex_mem_re;
            ex_mem_we <= id_ex_mem_we;
        end

    end


endmodule
