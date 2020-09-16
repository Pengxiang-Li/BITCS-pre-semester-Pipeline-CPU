`timescale 1ns / 1ps
`include "defines.v"

module PC (input clk,
           input rst,
           output reg ce_o,
           output reg[`InstAddrBus] pc
           );
    
    always @(posedge clk) begin
        
        if (rst == `RstEnable) begin
            ce_o        <= `ReadDisable;
        end
        
        else begin
            ce_o <= `ReadEnable;
        end
    
    end

    always @(posedge clk) begin
        if (ce_o == `ReadDisable) begin
            pc <= `ZeroWord;
        end
        else begin
            pc <= pc + 4;
        end
    end
    
endmodule
