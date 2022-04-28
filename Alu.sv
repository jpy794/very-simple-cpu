module Alu
import CpuPkg::*;
(
  input type_CpuData a, b,
  input type_AluOp op,
  output type_CpuData y
);
  always_comb begin
    y = 0;
    case(op)
      ALU_ADD  : y = a + b;
      ALU_SUB  : y = a - b;
      ALU_SLT  : y = $signed(a) < $signed(b);
      ALU_SLTU : y = a < b;
      ALU_AND  : y = a & b;
      ALU_OR   : y = a | b;
      ALU_XOR  : y = a ^ b;
      ALU_SLL  : y = a << b;
      ALU_SRL  : y = a >> b;
      ALU_SRA  : y = $signed(a) >>> b;   
    endcase
  end
endmodule