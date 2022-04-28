module tb_Top();

  localparam P_CLK_M = 100;
  localparam P_PERIOD = 10000 / P_CLK_M;

  logic clk, rst;

  //module here
  Top U_Top(.clk, .rst, .sw(16'ha));


  initial begin        
    clk = 0;
    rst = 0;
    
    //init
    U_Top.bCpuDataIf.addr = 0;
    U_Top.bCpuDataIf.valid = 0;
    U_Top.bCpuDataIf.wr = 0;
    U_Top.bCpuDataIf.dataM2S = 0;

    @(negedge clk);
    rst = 1;

    //test here

    $display("### Data Cache Begin ###");
    @(negedge clk);
    U_Top.bCpuDataIf.valid = 1;
    U_Top.bCpuDataIf.addr = 32'h0000;
    if(U_Top.bCpuDataIf.ready) $display("Ready Set");
    @(negedge clk);
    $display("Read [%h] : %h", U_Top.bCpuDataIf.addr, U_Top.bCpuDataIf.dataS2M);

    U_Top.bCpuDataIf.valid = 1;
    U_Top.bCpuDataIf.wr = 1;
    U_Top.bCpuDataIf.addr = 32'h0008;
    U_Top.bCpuDataIf.dataM2S = 32'h123;
    @(negedge clk);
    if(U_Top.U_DataCache.cache[2]==32'h123) $display("Write Success");
    else                                    $display("Write Failed");
    $display("### Data Cache end ###");

    $display("### Peripherals Begin ###");
    U_Top.bCpuDataIf.wr = 0;
    U_Top.bCpuDataIf.valid = 1;
    U_Top.bCpuDataIf.addr = 32'h7f04;
    if(U_Top.bCpuDataIf.ready) $display("Ready Set");
    @(negedge clk);
    @(negedge clk);
    $display("Read [%h] : %h", U_Top.bCpuDataIf.addr, U_Top.bCpuDataIf.dataS2M);

    U_Top.bCpuDataIf.valid = 1;
    U_Top.bCpuDataIf.wr = 1;
    U_Top.bCpuDataIf.addr = 32'h7f00;
    U_Top.bCpuDataIf.dataM2S = 32'h123;
    @(negedge clk);
    @(negedge clk);
    if(U_Top.U_DataCache.cache[2]==32'ha) $display("Write Success");
    else                              $display("Write Failed");
    $display("### Peripherals end ###");

    $finish;
  end

  always begin
    #(P_PERIOD / 2);
    clk = ~clk;
  end

endmodule