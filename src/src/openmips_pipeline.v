module openmips_pipeline (input clk,
                          input rst);
    
    
    wire   [31:0] rom_data_i;
    
    wire  [31:0] rom_addr_o;
    wire  rom_ce_o;
    
    
    PipeLine  u_PipeLine (
    .clk                       (clk),
    .rst                       (rst),
    .rom_data_i  (rom_data_i),
    
    .rom_addr_o  (rom_addr_o),
    .rom_ce_o                  (rom_ce_o)
    );
    wire [9:0] rom_addr;
    assign rom_addr = rom_addr_o[11:2];
    inst_rom inst_rom0(
    .clka(clk),    // input wire clka
    .ena(rom_ce_o),      // input wire ena
    .addra(rom_addr),  // input wire [9 : 0] addra
    .douta(rom_data_i)  // output wire [31 : 0] douta
    );
    
    
endmodule
