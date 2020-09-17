`timescale 1ns / 1ps
`include "defines.v"

module PipeLine (input clk,
                 input rst,
                 input [`InstBus] rom_data_i,
                 output [`InstAddrBus] rom_addr_o,
                 output wire rom_ce_o);
    wire [`InstBus]  id_pc, id_inst;
    
    wire [`RegBus] ex_alu_result;
    wire [`RegAddrBus] ex_mem_regfile_waddr;
    wire [`MEMAddrBus] ex_mem_mem_addr;
    
    wire [5:0]  op;
    wire regfile_re1, regfile_re2, id_ex_mem_re, id_ex_mem_we;
    wire [`RegAddrBus] regfile_raddr1, regfile_raddr2;
    wire [`RegBus]  regfile_rdata1, regfile_rdata2;
    wire id_ex_regfile_we;
    wire [`RegAddrBus]  id_ex_regfile_waddr;
    wire [`AluOpBus] id_ex_alu_op;
    wire [`RegBus] id_ex_alu_src1, id_ex_alu_src2;
    
    wire [`AluOpBus] ex_alu_op;
    wire [`RegBus] ex_alu_src1, ex_alu_src2;
    wire [`RegAddrBus] ex_regfile_waddr;

    wire ex_mem_re, ex_mem_we;
    wire ex_mem_regfile_we;
    
    wire mem_mem_re, mem_mem_we;
    wire [`MEMAddrBus] mem_mem_addr;
    wire mem_regfile_re, mem_regfile_we;
    wire [`RegAddrBus] mem_regfile_waddr;
    wire [`WordWidth] mem_data;
    
    wire [`WordWidth] mem_wb_data;
    wire [`RegAddrBus] mem_wb_regfile_addr;
    
    wire [`RegAddrBus] wb_addr;
    wire [`WordWidth] wb_data;

    wire ex_regfile_we;
    PC  u_PC (
    .clk                            (clk),
    .rst                            (rst),
    
    .ce_o                           (rom_ce_o),
    .pc  (rom_addr_o)
    );
    
    IF_ID  u_IF_ID (
    .clk                     (clk),
    .rst                     (rst),
    .if_pc    (rom_addr_o),
    .if_inst      (rom_data_i),
    
    .id_pc    (id_pc),
    .id_inst      (id_inst)
    );
    
    
    
    ID  u_ID (
    .rst(rst),
    .id_pc(id_pc),
    .id_inst(id_inst),
    .ex_regfile_we                      (ex_mem_regfile_we),
    .ex_regfile_waddr     (ex_regfile_waddr),
    .ex_alu_result(ex_alu_result),
    .mem_wb_regfile_we(mem_wb_regfile_we),
    .mem_wb_regfile_addr(mem_wb_regfile_addr),
    .mem_wb_data(mem_wb_data),
    .regfile_re1(regfile_re1),
    .regfile_re2(regfile_re2),
    .regfile_raddr1(regfile_raddr1),
    .regfile_raddr2(regfile_raddr2),
    .regfile_rdata1(regfile_rdata1),
    .regfile_rdata2(regfile_rdata2),
    .id_ex_regfile_we(id_ex_regfile_we),
    .id_ex_mem_re(id_ex_mem_re),
    .id_ex_mem_we(id_ex_mem_we),
    .id_ex_regfile_waddr(id_ex_regfile_waddr),
    .id_ex_alu_op(id_ex_alu_op),
    .id_ex_alu_src1(id_ex_alu_src1),
    .id_ex_alu_src2(id_ex_alu_src2)
    );
    
    
    ID_EX  u_ID_EX (
    .clk                            (clk),
    .rst                            (rst),
    .id_ex_regfile_we               (id_ex_regfile_we),
    .id_ex_regfile_waddr  (id_ex_regfile_waddr),
    .id_ex_alu_op       (id_ex_alu_op),
    .id_ex_alu_src1       (id_ex_alu_src1),
    .id_ex_alu_src2       (id_ex_alu_src2),
    .id_ex_mem_re                   (id_ex_mem_re),
    .id_ex_mem_we                   (id_ex_mem_we),
    
    .ex_regfile_we            (ex_regfile_we),
    .ex_regfile_waddr     (ex_regfile_waddr),
    .ex_alu_op          (ex_alu_op),
    .ex_alu_src1          (ex_alu_src1),
    .ex_alu_src2          (ex_alu_src2),
    .ex_mem_re                      (ex_mem_re),
    .ex_mem_we                      (ex_mem_we)
    );
    
    
    EX  u_EX (
    .rst                         (rst),
    .ex_regfile_we               (ex_regfile_we),
    .ex_regfile_waddr  (ex_regfile_waddr),
    .ex_mem_re                   (ex_mem_re),
    .ex_mem_we                   (ex_mem_we),
    .ex_alu_op       (ex_alu_op),
    .ex_alu_src1       (ex_alu_src1),
    .ex_alu_src2       (ex_alu_src2),
    
    .ex_mem_mem_addr   (ex_mem_mem_addr),
    .ex_alu_result  (ex_alu_result),
    .ex_mem_regfile_we(ex_mem_regfile_we),
    .ex_mem_regfile_waddr(ex_mem_regfile_waddr)
    );
    
    
    EX_MEM  u_EX_MEM (
    .clk                                (clk),
    .rst                                (rst),
    .ex_mem_re                          (ex_mem_re),
    .ex_mem_we                          (ex_mem_we),
    .ex_mem_mem_addr           (ex_mem_mem_addr),
    .ex_mem_regfile_waddr        (ex_mem_regfile_waddr),
    .ex_alu_result               (ex_alu_result),
    .ex_mem_regfile_we                      (ex_mem_regfile_we),
    
    .mem_mem_re                         (mem_mem_re),
    .mem_mem_we                         (mem_mem_we),
    .mem_mem_addr      (mem_mem_addr),
    .mem_regfile_we                     (mem_regfile_we),
    .mem_regfile_waddr  (mem_regfile_waddr),
    .mem_data           (mem_data)
    );
    
    
    MEM  u_MEM (
    .rst                                   (rst),
    .mem_mem_re                            (mem_mem_re),
    .mem_mem_we                            (mem_mem_we),
    .mem_mem_addr            (mem_mem_addr),
    .mem_regfile_we                        (mem_regfile_we),
    .mem_regfile_waddr        (mem_regfile_waddr),
    .mem_data                 (mem_data),
    
    .mem_wb_regfile_we                     (mem_wb_regfile_we),
    .mem_wb_regfile_addr  (mem_wb_regfile_addr),
    .mem_wb_data              (mem_wb_data)
    );
    
    
    MEM_WB  u_MEM_WB (
    .clk                                (clk),
    .rst                                (rst),
    .mem_wb_regfile_we                  (mem_wb_regfile_we),
    .mem_wb_regfile_addr  (mem_wb_regfile_addr),
    .mem_wb_data           (mem_wb_data),
    
    .wb_we                              (wb_we),
    .wb_addr           (wb_addr),
    .wb_data            (wb_data)
    );
    
    RegFile  u_RegFile (
    .clk(clk),
    .rst                     (rst),
    .wb_we                   (wb_we),
    .wb_addr (wb_addr),
    .wb_data(wb_data),
    .regfile_re1(regfile_re1),
    .regfile_re2(regfile_re2),
    .regfile_raddr1(regfile_raddr1),
    .regfile_raddr2(regfile_raddr2),
    .regfile_rdata1(regfile_rdata1),
    .regfile_rdata2(regfile_rdata2)
    );
    
endmodule
