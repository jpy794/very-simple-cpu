module Register
import CpuPkg::*;
(
  input clk,
  input type_RegAddr rs1, rs2, rd,
  input type_CpuData rdData,
  input we,
  output type_CpuData rs1Data, rs2Data
);

  (* ram_style = "distributed" *) type_CpuData regFile [31:0];
`ifdef SIMULATION
  initial begin
    $readmemh("reg", regFile);
  end
`endif

  always_comb begin
    if(rs1 == rd && rs1 != 5'b0 && we) rs1Data = rdData;
    else                         rs1Data = regFile[rs1];
  end

  always_comb begin
    if(rs2 == rd && rs2 != 5'b0 && we) rs2Data = rdData;
    else                         rs2Data = regFile[rs2];
  end

  always @(posedge clk) begin
    if(we && rd != 5'b0) regFile[rd] <= rdData;    //forbid to write x0
  end

endmodule