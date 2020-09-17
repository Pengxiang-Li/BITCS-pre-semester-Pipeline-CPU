`timescale 1ns / 1ps
`include "defines.v"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/11/10 09:48:09
// Design Name: 
// Module Name: inst_rom
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module inst_rom(
    input wire ce, //使能信号
    input wire[`InstAddrBus] addr, //要读取的指令地址
    output reg[`InstBus] inst
    );

    reg[`InstBus] inst_mem[0:31];
    // reg[`InstBus] inst_mem[0:`InstMemNum-1];

    //使用文件inst_rmo.data初始化指令存储器
    initial $readmemh ("inst_rom.data", inst_mem);
    // initial $display(inst_mem[1]);

    always @(*) begin
        if (ce == `ChipDisable) begin
            inst <= `ZeroWord;
        end
        else begin
            inst <= inst_mem[addr[`InstMemNumLog2+1:2]];
        end
    end

endmodule
