module Counter
#(
  parameter P_FREQ_HZ = 25
)(
  input logic clk, rst,
  input logic iClr,
  output logic oOver
);

  localparam P_DIV_CNT = 100_000_000 / P_FREQ_HZ;

  logic [$clog2(P_DIV_CNT)-1:0] divCnt;
  assign oOver = divCnt == P_DIV_CNT - 1;

  always_ff @(posedge clk, negedge rst) begin
    if(!rst)       divCnt <= 0;
    else if(iClr)  divCnt <= 0;
    else if(oOver) divCnt <= 0;
    else           divCnt <= divCnt + 1;
  end

endmodule : Counter

