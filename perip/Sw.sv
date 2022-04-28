module Sw
(
  input logic clk, rst,
  input logic [15:0] iSw,
  output logic [15:0] oSw
);

  always_ff @(posedge clk, negedge rst) begin
    if(!rst) oSw <= 16'b0;
    else     oSw <= iSw; 
  end

endmodule : Sw