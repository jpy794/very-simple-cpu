`timescale 100ps/10ps

localparam P_TEST_ADDR = 8'hff;
localparam P_TEST_DATA = 32'hffffffff;

task automatic WriteMem();
  @(negedge tb.clk)
  tb.bBusIf.we = 1;
  tb.bBusIf.addr = P_TEST_ADDR;
  tb.bBusIf.dataM2S = P_TEST_DATA;
  @(negedge tb.clk)
  tb.bBusIf.we = 0;
endtask

task automatic ReadMem();
  @(negedge tb.clk);
  tb.bBusIf.addr = P_TEST_ADDR;
  @(negedge tb.clk);
  if(tb.bBusIf.dataS2M == P_TEST_DATA)
    $display("MemTest Passed : 0x%h", tb.bBusIf.dataS2M);
  else
    $fatal(1, "MemTest Failed");
endtask

module tb();
  import BusPkg::*;

  localparam P_CLK_M = 100;
  localparam P_PERIOD = 10000 / P_CLK_M;
  
  logic clk, rst;

  //module here
  BusItf bBusIf();
  Mem mem(.*);
  
  initial begin        
    clk = 0;
    rst = 0;
    
    //init
    bBusIf.addr = 0;
    bBusIf.dataM2S = 0;
    bBusIf.we = 0;

    @(negedge clk);
    rst = 1;

    //test here
    WriteMem();
    ReadMem();
    
    $finish;
  end

  always begin
    #(P_PERIOD / 2);
    clk = ~clk;
  end
endmodule