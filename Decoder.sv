//TODO: adjust data path using x0
module Decoder
import CpuPkg::*;
(
  input type_CpuData ins,
  output type_RegAddr rs1, rs2, rd,
  output type_CpuData imm,
  output type_AluOp aluOp,
  output type_BranchOp branchOp,
  output logic isPcIn,
  output logic isImmIn,
  output logic isLoad,    // mem[alu]->rd
  output logic isStore,   // rs2->mem[alu]
  output logic isBranch,  // true ? alu->pc
  output logic isJump,     // alu->pc, pc+4->rd
  output logic badOpcode
);
  type_Opcode opcode;
  logic nop;
  assign opcode = getOpcode(ins);
  assign badOpcode = !(opcode inside {OP, OP_IMM, JALR, LOAD, LUI, AUIPC, STORE, BRANCH, JAL});
  assign nop = badOpcode;

  assign isLoad   = nop ? 0 : opcode inside {LOAD};
  assign isStore  = nop ? 0 : opcode inside {STORE};
  assign isBranch = nop ? 0 : opcode inside {BRANCH};
  assign isJump   = nop ? 0 : opcode inside {JAL, JALR};

  assign branchOp = getBranchOp(ins);

  /* Reg relevant */
  always_comb begin
    rs1 = 5'b0;       //x0
    rs2 = getRs2(ins);
    rd = getRd(ins);
    if(!nop && opcode != LUI) begin
      rs1 = getRs1(ins);
    end
  end

  /* Imm relevant */
  always_comb begin
    imm = 32'b0;
    if(!nop) begin
      case(opcode) inside
        OP_IMM, JALR, LOAD : begin
          if(aluOp inside {ALU_SRL, ALU_SRA, ALU_SLL})
            imm = getShAmt_OpImm(ins);
          else
            imm = getImmI(ins);
        end
        LUI, AUIPC : imm = getImmU(ins);
        STORE      : imm = getImmS(ins);
        BRANCH     : imm = getImmB(ins);
        JAL        : imm = getImmJ(ins);
      endcase
    end
  end

  /* ALU relevant */
  always_comb begin
    isPcIn = 0;
    isImmIn = 1;
    aluOp = ALU_ADD;
    if(!nop) begin
      case(opcode) inside
        OP_IMM: begin
          aluOp = getAluOp_OpImm(ins);
        end

        OP: begin
          isImmIn = 0;
          aluOp = getAluOp_Op(ins);
        end

        LUI: begin
        end

        AUIPC: begin
          isPcIn = 1;
        end

        LOAD: begin       //TODO: handle width
        end

        STORE: begin
        end

        BRANCH: begin
          isPcIn = 1;
        end

        JAL: begin
          isPcIn = 1;
        end

        JALR: begin
        end
      endcase
    end
  end

endmodule : Decoder