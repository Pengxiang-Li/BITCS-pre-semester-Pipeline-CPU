`timescale 1ns / 1ps
`include "defines.v"

module EX (input rst,
           //reg
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
    
    
    reg         hi_we;
    reg         lo_we;
    reg         hi_re;
    reg         lo_re;
    reg [`RegBus] hi_data_i, lo_data_i;
    wire [`RegBus] hi_data_o, lo_data_o;
    wire[`RegBus] src2_negative = ~(ex_alu_src2) + 1;
    wire        add_overflow = (ex_alu_op== `EXE_ADD_OP || ex_alu_op== `EXE_ADDI_OP) && ((ex_alu_src1[31] && ex_alu_src2[31] && (~ex_alu_result[31]))
                                    || ((~ex_alu_src1[31]) && (~ex_alu_src2[31]) && ex_alu_result[31]));
    wire        sub_overflow = (ex_alu_op ==`EXE_SUB_OP) && ((ex_alu_src1[31] && src2_negative[31] && (~ex_alu_result[31]))
                                    || ((~ex_alu_src1[31]) & (~src2_negative[31]) & ex_alu_result[31]));
    
    wire        over_flow = sub_overflow | add_overflow;
    wire[`RegBus] difference = ex_alu_src1 + src2_negative;
    wire[`RegBus] src1_not = ~ex_alu_src1;
    wire[`RegBus] opdata1_mult = (((ex_alu_op==`EXE_MUL_OP)||(ex_alu_op==`EXE_MULT_OP)) && (ex_alu_src1[31] == 1'b1)) ?
                                    (~ex_alu_src1 + 1) : ex_alu_src1;
    wire[`RegBus] opdata2_mult = (((ex_alu_op==`EXE_MUL_OP)||(ex_alu_op==`EXE_MULT_OP)) && (ex_alu_src2[31] == 1'b1)) ?
                                    (~ex_alu_src2 + 1) : ex_alu_src2;
    
    wire[`DoubleRegBus] hilo_temp = opdata1_mult * opdata2_mult;
    reg[`DoubleRegBus] mul_ans;
    always @(*) begin
        if (rst == `RstEnable) begin
            hi_data_i <= 0;
            lo_data_i <= 0;
            hi_we     <= `WriteDisable;
            lo_we     <= `WriteDisable;
            hi_re     <= `ReadDisable;
            lo_re     <= `ReadDisable;
            ex_alu_result <= 0;
            ex_mem_mem_addr <= 0;
            ex_mem_regfile_we <= 0;
            ex_mem_regfile_waddr <= 0;
            mul_ans <= {`ZeroWord, `ZeroWord};
        end
        else begin
            hi_data_i <= 0;
            lo_data_i <= 0;
            hi_we     <= `WriteDisable;
            lo_we     <= `WriteDisable;
            hi_re     <= `ReadDisable;
            lo_re     <= `ReadDisable;
            ex_mem_mem_addr <= 0;
            mul_ans <= {`ZeroWord, `ZeroWord};
            // ex_alu_result <= 0;
            ex_mem_regfile_waddr <= ex_regfile_waddr;
            ex_mem_regfile_we <= ex_regfile_we;
            case (ex_alu_op)
                `EXE_MOVZ_OP: begin
                    if(ex_alu_src2 == 32'b0) begin
                        ex_alu_result <= ex_alu_src1;
                    end
                    else begin
                        ex_mem_regfile_we <= `WriteDisable;
                        ex_alu_result <= 0;
                    end
                end
                `EXE_MOVN_OP: begin
                    if(ex_alu_src2 != 32'b0) begin
                        ex_alu_result <= ex_alu_src1;
                    end
                    else begin
                        ex_mem_regfile_we <= `WriteDisable;
                        ex_alu_result <= 0;
                    end
                end
                `EXE_MFHI_OP: begin
                    ex_mem_regfile_we <= `WriteEnable;
                    hi_re   <= `ReadEnable;
                    ex_alu_result <= hi_data_o;//to write into regfile
                end
                `EXE_MTHI_OP: begin
                    hi_we <= `WriteEnable;
                    hi_data_i <= ex_alu_src1;
                    ex_alu_result <= 0;
                end
                `EXE_MFLO_OP: begin
                    ex_mem_regfile_we <= `WriteEnable;
                    lo_re <= `ReadEnable;
                    ex_alu_result <= lo_data_o;//to write into regfile
                end
                `EXE_MTLO_OP: begin
                    lo_we  <= `WriteEnable;
                    lo_data_i <= ex_alu_src1;
                    ex_alu_result <= 0;
                end
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

                // Donghai Liao
                `EXE_SLT_OP, `EXE_SLTI_OP: begin
                    ex_alu_result <= (ex_alu_src1[31] & !ex_alu_src2[31]) |
                                    (~ex_alu_src1[31] & !ex_alu_src2[31] & difference[31]) |
                                    (ex_alu_src1[31] & ex_alu_src2[31] & difference[31]) ;
                end
                `EXE_SLTU_OP, `EXE_SLTIU_OP: begin
                    ex_alu_result <= (ex_alu_src1 < ex_alu_src2) ? 1 : 0;
                end

                `EXE_ADD_OP, `EXE_ADDI_OP: begin
                    ex_alu_result <= ex_alu_src1 + ex_alu_src2;
                    if(over_flow)begin
                        ex_mem_regfile_we <= `WriteDisable;
                    end
                end

                `EXE_ADDU_OP, `EXE_ADDIU_OP: begin
                    ex_alu_result <= ex_alu_src1 + ex_alu_src2;
                end

                `EXE_SUB_OP: begin
                    ex_alu_result = ex_alu_src1 + src2_negative;
                    if(over_flow)begin
                        ex_mem_regfile_we <= `WriteDisable;
                        
                    end
                end

                `EXE_SUBU_OP: begin
                    ex_alu_result <= ex_alu_src1 + src2_negative;
                end

                `EXE_CLZ_OP: begin
                    ex_alu_result <= ex_alu_src1[31]? 0 : ex_alu_src1[30]? 1 : ex_alu_src1[29]? 2 : ex_alu_src1[28]? 3 :
                                    ex_alu_src1[27]? 4 : ex_alu_src1[26]? 5 : ex_alu_src1[25]? 6 : ex_alu_src1[24]? 7 :
                                    ex_alu_src1[23]? 8 : ex_alu_src1[22]? 9 : ex_alu_src1[21]? 10 : ex_alu_src1[20]? 11 :
                                    ex_alu_src1[19]? 12 : ex_alu_src1[18]? 13 : ex_alu_src1[17]? 14 : ex_alu_src1[16]? 15 :
                                    ex_alu_src1[15]? 16 : ex_alu_src1[14]? 17 : ex_alu_src1[13]? 18 : ex_alu_src1[12]? 19 :
                                    ex_alu_src1[11]? 20 : ex_alu_src1[10]? 21 : ex_alu_src1[9]? 22 : ex_alu_src1[8]? 23 :
                                    ex_alu_src1[7]? 24 : ex_alu_src1[6]? 25 : ex_alu_src1[5]? 26 : ex_alu_src1[4]? 27 :
                                    ex_alu_src1[3]? 28 : ex_alu_src1[2]? 29 : ex_alu_src1[1]? 30 : ex_alu_src1[0]? 31 : 32;
                end

                `EXE_CLO_OP: begin
                    ex_alu_result <= src1_not[31]? 0 : src1_not[30]? 1 : src1_not[29]? 2 : src1_not[28]? 3 :
                                    src1_not[27]? 4 : src1_not[26]? 5 : src1_not[25]? 6 : src1_not[24]? 7 :
                                    src1_not[23]? 8 : src1_not[22]? 9 : src1_not[21]? 10 : src1_not[20]? 11 :
                                    src1_not[19]? 12 : src1_not[18]? 13 : src1_not[17]? 14 : src1_not[16]? 15 :
                                    src1_not[15]? 16 : src1_not[14]? 17 : src1_not[13]? 18 : src1_not[12]? 19 :
                                    src1_not[11]? 20 : src1_not[10]? 21 : src1_not[9]? 22 : src1_not[8]? 23 :
                                    src1_not[7]? 24 : src1_not[6]? 25 : src1_not[5]? 26 : src1_not[4]? 27 :
                                    src1_not[3]? 28 : src1_not[2]? 29 : src1_not[1]? 30 : src1_not[0]? 31 : 32;
                end

                `EXE_MUL_OP: begin
                    if(ex_alu_src1[31] ^ ex_alu_src2[31])begin
                        mul_ans <= ~hilo_temp + 1;
                    end
                    else begin
                        mul_ans = hilo_temp;
                    end
                    ex_alu_result <= mul_ans[31:0];
                end

                `EXE_MULT_OP: begin
                    hi_we <= `WriteEnable;
                    lo_we <= `WriteEnable;
                    if(ex_alu_src1[31] ^ ex_alu_src2[31])begin
                        mul_ans <= ~hilo_temp + 1;
                    end
                    else begin
                        mul_ans = hilo_temp;
                    end
                    hi_data_i <= mul_ans[63:32];
                    lo_data_i <= mul_ans[31:0];
                    ex_alu_result <= 0;
                end

                `EXE_MULTU_OP: begin
                    hi_we <= `WriteEnable;
                    lo_we <= `WriteEnable;
                    mul_ans = hilo_temp;
                    hi_data_i <= mul_ans[63:32];
                    lo_data_i <= mul_ans[31:0];
                    ex_alu_result <= 0;
                end


                default: begin
                    ex_alu_result <= 0;
                end
            endcase
        end
    end
    HILOReg  u_HILOReg (
        .rst                     (rst),
        .hi_we                   (hi_we),
        .lo_we                   (lo_we), 
        .hi_re                   (hi_re),
        .lo_re                   (lo_re),
        .hi_data_i     ( hi_data_i   ),
        .lo_data_i     ( lo_data_i   ),

        .hi_data_o     ( hi_data_o   ),
        .lo_data_o     ( lo_data_o   )
    );

endmodule
