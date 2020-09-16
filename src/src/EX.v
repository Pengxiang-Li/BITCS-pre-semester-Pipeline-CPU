`timescale 1ns / 1ps
`include "defines.v"

module EX (input rst,
           //reg
           input ex_regfile_re,
           input ex_regfile_we,
           input [`RegAddrBus] ex_regfile_waddr,
           
           //mem
           input ex_mem_re,
           input ex_mem_we,
           output reg [`MEMAddrBus] ex_mem_mem_addr,

           //alu
           input [`AluOpBus] ex_alu_op,
           input [`RegBus] ex_alu_src1,
           input [`RegBus] ex_alu_src2,
           output reg[`RegBus] ex_alu_result,
           output reg ex_mem_regfile_we,
           output reg[`RegAddrBus] ex_mem_regfile_waddr
           );
    
    always @(*) begin
        ex_mem_regfile_waddr <= ex_regfile_waddr;
        ex_mem_regfile_we <= ex_regfile_we;
        case (ex_alu_op)
            `EXE_OR_OP: begin
                ex_alu_result <= ex_alu_src1 | ex_alu_src2;
            end
            `EXE_AND_OP: begin 
                ex_alu_result <= ex_alu_src1 & ex_alu_src2;
            end
            `EXE_XOR_OP: begin
                ex_alu_result <= ex_alu_src1 ^ ex_alu_src2;
            end
            `EXE_NOR_OP: begin
                ex_alu_result <= ~(ex_alu_src1 | ex_alu_src2);
            end
            `EXE_SLL_OP: begin
                ex_alu_result <= ex_alu_src2 << ex_alu_src1;
            end
            `EXE_SRL_OP: begin
                ex_alu_result <= ex_alu_src2 >> ex_alu_src1;
            end
            `EXE_SRA_OP: begin
                ex_alu_result <= ({32{ex_alu_src2[31]}} << 6'd32 - {1'b0, ex_alu_src1[4:0]}) 
                                    | (ex_alu_src2 >> ex_alu_src1);
            end
            default: begin
                
            end
        endcase
    end
    
endmodule
