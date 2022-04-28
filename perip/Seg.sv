module Seg
#(
  parameter P_FREQ_HZ = 400
)(
  input logic clk, rst,
  input logic [31:0] iSeg,
  input logic iWe,
  output logic [7:0] oAn,
  output logic [7:0] oSeg
);
  logic [31:0] iSeg_r;
  always_ff @(posedge clk, negedge rst) begin
    if(!rst)     iSeg_r <= 32'b0;
    else if(iWe) iSeg_r <= iSeg;
  end

  logic [7:0] oAn_n;
  logic [7:0] oSeg_n;

  assign oAn = ~oAn_n;
  assign oSeg = ~oSeg_n;

  logic over_c;
  Counter #(
    .P_FREQ_HZ(P_FREQ_HZ)
  )U_Counter(
    .iClr(0),
    .oOver(over_c),
    .*
  );
  
  always_ff @(posedge clk, negedge rst) begin
    if(!rst) oAn_n <= 8'b1;
    else if(over_c) oAn_n <= {oAn_n[6:0], oAn_n[7]};
  end

  logic [3:0] iSeg_part;
  always_comb begin
    iSeg_part = 4'b0;
    unique case(1'b1)
      oAn_n[0]: iSeg_part = iSeg_r[0*4+:4];
      oAn_n[1]: iSeg_part = iSeg_r[1*4+:4];
      oAn_n[2]: iSeg_part = iSeg_r[2*4+:4];
      oAn_n[3]: iSeg_part = iSeg_r[3*4+:4];
      oAn_n[4]: iSeg_part = iSeg_r[4*4+:4];
      oAn_n[5]: iSeg_part = iSeg_r[5*4+:4];
      oAn_n[6]: iSeg_part = iSeg_r[6*4+:4];
      oAn_n[7]: iSeg_part = iSeg_r[7*4+:4];
    endcase
  end

  always_comb begin
    oSeg_n = 8'b0;
    unique case(iSeg_part)
      4'd0:   oSeg_n = 8'd63;
      4'd1:   oSeg_n = 8'd6;
      4'd2:   oSeg_n = 8'd91;
      4'd3:   oSeg_n = 8'd79;
      4'd4:   oSeg_n = 8'd102;
      4'd5:   oSeg_n = 8'd109;
      4'd6:   oSeg_n = 8'd125;
      4'd7:   oSeg_n = 8'd7;
      4'd8:   oSeg_n = 8'd127;
      4'd9:   oSeg_n = 8'd111;
      4'd10:  oSeg_n = 8'd119;
      4'd11:  oSeg_n = 8'd124;
      4'd12:  oSeg_n = 8'd57;
      4'd13:  oSeg_n = 8'd94;
      4'd14:  oSeg_n = 8'd121;
      4'd15:  oSeg_n = 8'd113;
    endcase
  end

endmodule : Seg