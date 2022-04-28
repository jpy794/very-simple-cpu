task automatic runOneCycle(
  ref logic clk
);
  for(int i = 0; i < 5; i++) begin
    @(negedge clk);
  end
endtask

module tb_Top();
  import CpuPkg::*;

  localparam P_CLK_M = 100;
  localparam P_PERIOD = 10000 / P_CLK_M;

  logic clk, rst;

  //module here
  logic btnc = 1;
  Top U_Top(.clk, .rst, .sw(16'h2), .btnc(btnc));

  int j;
  type_CpuData pcOld;
  initial begin        
    clk = 0;
    rst = 1;
    
    //init

    @(negedge clk);
    rst = 0;
    @(negedge clk);
    rst = 1;


    //test here
    while(!U_Top.U_Cpu.badOpcode_ID) begin
      @(negedge clk);
      $display("pc_IF: %h", U_Top.U_Cpu.pc_IF);
      if(U_Top.U_Cpu.ir == 32'h6f) break;       //j x0, 0
      if(U_Top.U_Cpu.pc_IF == 32'h3030)
        btnc = 0;

      if(U_Top.U_Cpu.pc_IF == 32'h30a0) break;

      if(U_Top.U_Cpu.pc_IF == pcOld) j++;
      if(j > 500) begin
        $display("error loop"); 
        break;
      end
      pcOld = U_Top.U_Cpu.pc_IF;
    end

    for(int i = 0; i < 5; i++) begin
      @(negedge clk);
    end

    $finish;
  end

  always begin
    #(P_PERIOD / 2);
    clk = ~clk;
  end

endmodule