`timescale 1ns / 1ps
`include "defines.v"

module RegFile (input clk,
                input rst,
                //mem_wb
                input wb_re,
                input wb_we,
                input [`RegAddrBus] wb_addr,
                input [`WordWidth] wb_data,
                //id
                input regfile_re1,
                input regfile_re2,
                input [`RegAddrBus] regfile_raddr1,
                input [`RegAddrBus] regfile_raddr2,
                output reg [`RegBus] regfile_rdata1,
                output reg [`RegBus] regfile_rdata2
                );

    reg [`RegBus] regs[0:`RegNum-1];

    //write data
    always @(posedge clk) begin
        if (rst == `RstEnable) begin
            regs[0] <= 0;
        end
        if(wb_we == `WriteEnable) begin
            if (wb_addr == 31'b0) begin
                regs[0] <= 0;
            end
            else begin
                regs[wb_addr] <= wb_data;
            end
        end
    end

    //read data1
    always @(*) begin
        if (regfile_re1 == `ReadEnable) begin
            if ((wb_we == `WriteEnable) && (wb_addr == regfile_raddr1)) begin
                regfile_rdata1 <= wb_data;
            end
            else begin
                regfile_rdata1 <= regs[regfile_raddr1];
            end
        end
    end

    //read data2
    always @(*) begin
        if (regfile_re2 == `ReadEnable) begin
            if ((wb_we == `WriteEnable) && (wb_addr == regfile_raddr2)) begin
                regfile_rdata2 <= wb_data;
            end
            else begin
                regfile_rdata2 <= regs[regfile_raddr2];
            end
        end
    end
    
endmodule
