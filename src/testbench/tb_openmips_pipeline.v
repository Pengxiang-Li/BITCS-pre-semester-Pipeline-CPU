`timescale  1ns / 1ps

module tb_openmips_pipeline();
    
    // openmips_pipeline Parameters
    parameter PERIOD = 10;
    
    
    // openmips_pipeline Inputs
    reg   clk = 0 ;
    reg   rst = 1 ;
    
    // openmips_pipeline Outputs
    
    
    
    initial
    begin
        forever #(PERIOD/2)  clk = ~clk;
    end
    
    always @(posedge clk) begin
        rst <= 0;
    end
    
    openmips_pipeline  u_openmips_pipeline (
    .clk                     (clk),
    .rst                     (rst)
    );
    
    initial begin
        // $readmemh("E:\\short_semester\\teaching\\insturction.txt", inst_rom0.inst_mem);
        $readmemh("E:\\short_semester\\code\\PipeLine\\src\\testbench\\data\\regfile.txt", u_openmips_pipeline.u_PipeLine.u_RegFile.regs);
    end
    
    
endmodule
