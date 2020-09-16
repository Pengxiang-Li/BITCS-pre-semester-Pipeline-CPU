`timescale 1ns / 1ps
`include "defines.v"


module ID (input rst,
           input [`InstAddrBus] id_pc,
           input [`InstBus] id_inst,

           input ex_regfile_we,
           input [`RegAddrBus] ex_regfile_waddr,
           input [`RegBus] ex_alu_result,

           input mem_wb_regfile_we,
           input [`RegAddrBus] mem_wb_regfile_addr,
           input [`RegBus] mem_wb_data,

           //regfile read/write
           output reg regfile_re1,
           output reg regfile_re2,
           output reg [`RegAddrBus] regfile_raddr1,
           output reg [`RegAddrBus] regfile_raddr2,
           input wire[`RegBus] regfile_rdata1,
           input wire[`RegBus] regfile_rdata2,
           //id_ex
           output reg id_ex_regfile_we,

           //mem read/write
           output reg id_ex_mem_re,
           output reg id_ex_mem_we,

           //alu
           output reg[`RegAddrBus] id_ex_regfile_waddr,
           output reg[`AluOpBus] id_ex_alu_op,
           output reg[`RegBus] id_ex_alu_src1,
           output reg[`RegBus] id_ex_alu_src2);
    
    wire [5:0] op = id_inst[31:26];
    wire [5:0] funct = id_inst[5:0];
    reg [31:0] imm;
    
    
    /****************instruction decode******************/
    always @(*) begin
      
        if (rst == `RstEnable) begin
            id_ex_alu_op <= `EXE_NOP_OP;
            id_ex_regfile_we <= `WriteDisable;
            regfile_re1 <= `ReadDisable;
            regfile_re2 <= `ReadDisable;
            imm <= `ZeroWord;
        end
        else begin
            id_ex_alu_op <= `EXE_NOP_OP;
            id_ex_regfile_we <= `WriteDisable;
            id_ex_regfile_waddr <= id_inst[15:11];

            regfile_re1 <= `ReadDisable;
            regfile_re2 <= `ReadDisable;
            regfile_raddr1 <= id_inst[25:21];
            regfile_raddr2 <= id_inst[20:16];

            imm <= `ZeroWord;

            case (op)
                `EXE_SPECIAL_INST: begin
                    case (funct)
                        `EXE_MOVZ: begin
                            id_ex_alu_op <= `EXE_MOVZ_OP;
                            id_ex_regfile_we <= `WriteEnable;

                            regfile_re1 <= `ReadEnable;
                            regfile_re2 <= `ReadEnable;
                        end
                        `EXE_MOVN: begin
                            id_ex_alu_op <= `EXE_MOVN_OP;
                            id_ex_regfile_we <= `WriteEnable;
                            regfile_re1 <= `ReadEnable;
                            regfile_re2 <= `ReadEnable;
                            imm <= `ZeroWord;
                        end
                        `EXE_MFHI: begin
                            id_ex_alu_op <= `EXE_MFHI_OP;
                            id_ex_regfile_we <= `WriteEnable;
                            regfile_re1 <= `ReadDisable;
                            regfile_re2 <= `ReadDisable;
                        end
                        `EXE_MTHI: begin
                            id_ex_alu_op <= `EXE_MTHI_OP;
                            id_ex_regfile_we <= `WriteDisable;
                            regfile_re1 <= `ReadEnable;
                            regfile_re2 <= `ReadDisable;
                        end
                        `EXE_MFLO: begin
                            id_ex_alu_op <= `EXE_MFLO_OP;
                            id_ex_regfile_we <= `WriteEnable;
                            regfile_re1 <= `ReadDisable;
                            regfile_re2 <= `ReadDisable;
                        end
                        `EXE_MTLO: begin
                            id_ex_alu_op <= `EXE_MTLO_OP;
                            id_ex_regfile_we <= `WriteDisable;
                            regfile_re1 <= `ReadEnable;
                            regfile_re2 <= `ReadDisable;
                        end
                        `EXE_OR: begin//pass
                            id_ex_alu_op <= `EXE_OR_OP;
                            id_ex_regfile_we <= `WriteEnable;
                            regfile_re1    <= `ReadEnable;
                            regfile_re2    <= `ReadEnable;
                        end
                        `EXE_AND: begin//pass
                            id_ex_alu_op <= `EXE_AND_OP;
                            id_ex_regfile_we <= `WriteEnable;
                            regfile_re1    <= `ReadEnable;
                            regfile_re2    <= `ReadEnable;
                        end
                        `EXE_XOR: begin//pass
                            id_ex_alu_op <= `EXE_XOR_OP;
                            id_ex_regfile_we <= `WriteEnable;
                            regfile_re1    <= `ReadEnable;
                            regfile_re2    <= `ReadEnable;
                        end
                        `EXE_NOR: begin//pass
                            id_ex_alu_op <= `EXE_NOR_OP;
                            id_ex_regfile_we <= `WriteEnable;
                            regfile_re1    <= `ReadEnable;
                            regfile_re2    <= `ReadEnable;
                        end
                        `EXE_SLL:begin//pass
                            //alu_result = alu_src2 << alusrc1;
                            id_ex_alu_op <= `EXE_SLL_OP;
                            id_ex_regfile_we <= `WriteEnable;

                            regfile_re1    <= `ReadDisable;
                            regfile_re2    <= `ReadEnable;
                            imm <= {27'b0, id_inst[10:6]};
                        end
                        `EXE_SLLV: begin
                            id_ex_alu_op <= `EXE_SLL_OP;
                            id_ex_regfile_we <= `WriteEnable;

                            regfile_re1    <= `ReadEnable;
                            regfile_re2    <= `ReadEnable;
                        end
                        `EXE_SRL: begin//pass
                            id_ex_alu_op <= `EXE_SRL_OP;
                            id_ex_regfile_we <= `WriteEnable;

                            regfile_re1    <= `ReadDisable;
                            regfile_re2    <= `ReadEnable;
                            imm <= {27'b0, id_inst[10:6]};
                        end
                        `EXE_SRLV: begin//pass
                            id_ex_alu_op <= `EXE_SRL_OP;
                            id_ex_regfile_we <= `WriteEnable;

                            regfile_re1    <= `ReadEnable;
                            regfile_re2    <= `ReadEnable;
                        end
                        `EXE_SRA: begin//pass
                            id_ex_alu_op <= `EXE_SRA_OP;
                            id_ex_regfile_we <= `WriteEnable;

                            regfile_re1    <= `ReadDisable;
                            regfile_re2    <= `ReadEnable;
                            imm <= {27'b0, id_inst[10:6]};
                        end
                        // `EXE_SYNC: begin
                        //     id_ex_regfile_we <= `WriteDisable;
                        //     id_ex_alu_op <= `EXE_NOP_OP;

                        //     regfile_re1 <= `ReadDisable;
                        //     regfile_re2 <= `ReadDisable;
                        // end
                        default: begin
                            
                        end
                    endcase
                end
                `EXE_ORI: begin//pass
                    id_ex_alu_op <= `EXE_OR_OP;
                    id_ex_regfile_we <= `WriteEnable;
                    regfile_re1    <= `ReadEnable;
                    regfile_re2    <= `ReadDisable;
                    imm        <= {16'b0, id_inst[15:0]};
                    id_ex_regfile_waddr <= id_inst[20:16];
                    regfile_raddr1    <= id_inst[26:21];
                    regfile_raddr2    <= id_inst[15:11];
                end
                `EXE_ANDI: begin//pass
                    id_ex_alu_op <= `EXE_AND_OP;
                    id_ex_regfile_we <= `WriteEnable;
                    regfile_re1    <= `ReadEnable;
                    regfile_re2    <= `ReadDisable;
                    imm        <= {16'b0, id_inst[15:0]};
                    id_ex_regfile_waddr <= id_inst[20:16];
                    regfile_raddr1    <= id_inst[26:21];
                    regfile_raddr2    <= id_inst[15:11];
                end
                `EXE_LUI: begin//pass
                    /*
                    * attention
                    * you must set alu_op as `EXE_OR_OP for that alu_result is the data
                    * which should be written into regfile.
                    * Because we immplement DATA PUSH, we may need the alu_result to avoid
                    * Data Related.
                    */
                    id_ex_alu_op <= `EXE_OR_OP;
                    id_ex_regfile_we <= `WriteEnable;
                    id_ex_regfile_waddr <= id_inst[20:16];
                    regfile_re1    <= `ReadEnable;
                    regfile_re2    <= `ReadDisable;
                    imm <= {id_inst[15:0], 16'b0};
                end
                
                default: begin
                    
                end
            endcase
        end
    end
    
    /******************first source operand*************************/
    always @(*) begin
        if (regfile_re1 == `ReadEnable) begin
            if((ex_regfile_waddr == regfile_raddr1) && (ex_regfile_we == `WriteEnable)) begin 
                id_ex_alu_src1 <= ex_alu_result;
            end
            else if((mem_wb_regfile_addr == regfile_raddr1) && (mem_wb_regfile_we == `WriteEnable)) begin
                 id_ex_alu_src1 <= mem_wb_data;
            end
            else begin
                id_ex_alu_src1 <= regfile_rdata1;
            end
        end
        else begin
            id_ex_alu_src1 <= imm;
        end
    end
    
    /******************second source operand****************/
    always @(*) begin
        if (regfile_re2 == `ReadEnable) begin
            if((ex_regfile_waddr == regfile_raddr2) && (ex_regfile_we == `WriteEnable)) begin 
                id_ex_alu_src2 <= ex_alu_result;
            end
            else if((mem_wb_regfile_addr == regfile_raddr2) && (mem_wb_regfile_we == `WriteEnable)) begin
                 id_ex_alu_src2 <= mem_wb_data;
            end
            else begin
                id_ex_alu_src2 <= regfile_rdata2;
            end
        end
        else begin
            id_ex_alu_src2 <= imm;
        end
    end
    
    
endmodule
