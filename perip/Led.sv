module Led
(
  input logic clk, rst,
  input logic [15:0] iLed,
  input logic iWe,
  output logic [15:0] oLed
);

  always_ff @(posedge clk, negedge rst) begin
    if(!rst)     oLed <= 16'b0;
    else if(iWe) oLed <= iLed; 
  end

endmodule : Led