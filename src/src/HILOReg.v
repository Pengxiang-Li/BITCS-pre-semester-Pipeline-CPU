`timescale 1ns / 1ps
`include "defines.v"


module HILOReg (input rst,
                input we,
                input [`RegBus] hi_data_i,
                input [`RegBus] lo_data_i,
                output reg [`RegBus] hi_data_o,
                output reg [`RegBus] lo_data_o);
    
    always @(*) begin
        if (rst == `RstEnable) begin
            hi_data_o <= `ZeroWord;
            lo_data_o <= `ZeroWord;
        end
        else if (we == `WriteEnable) begin
            hi_data_o <= hi_data_i;
            lo_data_o <= lo_data_i;
        end
    end
            
endmodule
