`timescale 1ns / 1ps
`include "defines.v"


module HILOReg (input rst,
                input hi_we,
                input lo_we,
                input hi_re,
                input lo_re,
                input [`RegBus] hi_data_i,
                input [`RegBus] lo_data_i,
                output reg [`RegBus] hi_data_o,
                output reg [`RegBus] lo_data_o);
    reg [`RegBus] hi;
    reg [`RegBus] lo;
    always @(*) begin
        if (rst == `RstEnable) begin
            hi_data_o <= `ZeroWord;
            lo_data_o <= `ZeroWord;
            hi <= 0;
            lo <= 0;
        end
        else  begin
            hi_data_o <= `ZeroWord;
            lo_data_o <= `ZeroWord;
            if (hi_we == `WriteEnable) begin
                // hi_data_o <= hi_data_i;
                // lo_data_o <= lo_data_i;
                hi <= hi_data_i;
                
            end
            if(lo_we == `WriteEnable) begin
                lo <= lo_data_i;
            end
            
            if(hi_re == `ReadEnable) begin
                hi_data_o <= hi;
            end

            if(lo_re == `ReadEnable) begin
                lo_data_o <= lo;
            end
        end
    end
            
endmodule
