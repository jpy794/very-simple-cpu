module Enter
(
  input logic clk, rst,
  input iBtn,
  input logic iClr,
  output logic oEnt
);

  logic edgeOut;      //negedge
  Edge U_Edge (
    .in(iBtn),
    .out(edgeOut),
    .*
  );

  always_ff @(posedge clk, negedge rst) begin
    if(!rst) oEnt <= 0;
    else begin
      if(edgeOut)   oEnt <= 1;
      else if(iClr) oEnt <= 0;
    end
  end

endmodule : Enter