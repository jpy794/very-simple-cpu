module Bram #(
  parameter P_WIDTH = 32,
  parameter P_SIZE = 256,
  parameter P_INIT = ""
)(
  input logic clk,
  input logic en, we,
  input logic [$clog2(P_SIZE)-1:0] addr,
  input logic [P_WIDTH-1:0] iData,
  output logic [P_WIDTH-1:0] oData
);

  (* ram_style = "block" *) logic [P_WIDTH-1:0] ram [P_SIZE-1:0];
  initial begin
    $readmemh(P_INIT, ram);
  end

  always_ff @(posedge clk) begin
    if(en) begin
      if (we)
        ram[addr] <= iData;
      else
        oData <= ram[addr];
    end
  end

endmodule : Bram