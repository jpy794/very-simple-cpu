module Branch
import CpuPkg::*;
(
  input type_CpuData a, b,
  input type_BranchOp op,
  output logic y
);

always_comb begin
  y = 0;
  case(op)
    BEQ  : y = (a == b);
    BNE  : y = (a != b); 
    BLT  : y = ($signed(a) < $signed(b)); 
    BLTU : y = (a < b);
    BGE  : y = ($signed(a) >= $signed(b)); 
    BGEU : y = (a >= b);  
  endcase
end

endmodule : Branch