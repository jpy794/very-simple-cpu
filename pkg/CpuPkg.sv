package CpuPkg;

localparam P_PC_INIT = 32'h0000_3000;
localparam P_NOP = 32'b000000000000_00000_111_00000_0010011;    //ADDI x0, x0, 0

typedef logic [4:0] type_RegAddr;
typedef logic [31:0] type_CpuData;

typedef logic [2:0] type_Funct3;
typedef logic [6:0] type_Funct7;

typedef enum logic [6:0] {
  OP_IMM = 7'b0010011,        //I
  LUI    = 7'b0110111,        //U   off->rd
  AUIPC  = 7'b0010111,        //U   pc+off->rd
  OP     = 7'b0110011,        //R
  JAL    = 7'b1101111,        //J   pc+off->pc, pc+4->rd
  JALR   = 7'b1100111,        //I   rs1+off->pc(lsb=0), pc+4->rd
  BRANCH = 7'b1100011,        //B   true ? pc+off->pc
  LOAD   = 7'b0000011,        //I   mem[rs1+off]->rd
  STORE  = 7'b0100011         //S   rs2->mem[rs1+off]
} type_Opcode;

/* OP_IMM */
typedef enum logic [2:0] {
  ADDI  = 3'b000,
  SLTI  = 3'b010,
  SLTIU = 3'b011,
  ANDI  = 3'b111,
  ORI   = 3'b110,
  XORI  = 3'b100,

  SLLI  = 3'b001,
  SRLI_SRAI   = 3'b101
} type_Funct3_OpImm;

//also used in OP
typedef enum logic [0:0] {
  ShRL = 1'b0,
  ShRA = 1'b1
} type_ShRType;

function automatic type_ShRType getShRType_OpImm(type_CpuData ins);
  return type_ShRType'(ins[30]);
endfunction

typedef logic [4:0] type_ShAmt;
function automatic type_CpuData getShAmt_OpImm(type_CpuData ins);
  return type_CpuData'({{27{1'b0}},ins[24:20]});
endfunction

/* OP */
typedef enum logic [2:0] {
  ADD_SUB  = 3'b000,
  SLT  = 3'b010,
  SLTU = 3'b011,
  AND  = 3'b111,
  OR   = 3'b110,
  XOR  = 3'b100,
  SLL  = 3'b001,
  SRL_SRA   = 3'b101
} type_Funct3_Op;

typedef enum logic [0:0] {
  ADD = 1'b0,
  SUB = 1'b1
} type_AddType;

function automatic type_AddType getAddType_Op(type_Funct7 funct7);
  return type_AddType'(funct7[5]);
endfunction

function automatic type_ShRType getShRType_Op(type_Funct7 funct7);
  return type_ShRType'(funct7[5]);
endfunction

/* BRANCH */
typedef enum logic [2:0] {
  BEQ  = 3'b000,
  BNE  = 3'b001,
  BLT  = 3'b100,
  BLTU = 3'b110,
  BGE  = 3'b101,
  BGEU = 3'b111
} type_BranchOp;

function automatic type_BranchOp getBranchOp(type_CpuData ins);
  return type_BranchOp'(ins[14:12]);
endfunction

/* LOAD */
typedef enum logic [2:0] {
  LB  = 3'b000,
  LH  = 3'b001,
  LW  = 3'b010,
  LBU = 3'b100,
  LHU = 3'b101
} type_LoadWidth;

function automatic type_LoadWidth getLoadWidth(type_CpuData ins);
  return type_LoadWidth'(ins[14:12]);
endfunction

/* STORE */
typedef enum logic [2:0] {
  SB  = 3'b000,
  SH  = 3'b001,
  SW  = 3'b010
} type_StoreWidth;

function automatic type_StoreWidth getStoreWidth(type_CpuData ins);
  return type_StoreWidth'(ins[14:12]);
endfunction

/* MISC */
function automatic type_Funct3 getFunct3(type_CpuData ins);
  return ins[14:12];
endfunction

function automatic type_Funct7 getFunct7(type_CpuData ins);
  return ins[31:25];
endfunction

function automatic type_Opcode getOpcode(type_CpuData ins);
  return type_Opcode'(ins[6:0]);
endfunction

function automatic type_RegAddr getRs1(type_CpuData ins);
  return ins[19:15];
endfunction

function automatic type_RegAddr getRs2(type_CpuData ins);
  return ins[24:20];
endfunction

function automatic type_RegAddr getRd(type_CpuData ins);
  return ins[11:7];
endfunction

function automatic type_CpuData getImmI(type_CpuData ins);
  return {{21{ins[31]}}, ins[30:20]};
endfunction

function automatic type_CpuData getImmS(type_CpuData ins);
  return {{21{ins[31]}}, ins[30:25], ins[11:7]};
endfunction

function automatic type_CpuData getImmB(type_CpuData ins);
  return {{20{ins[31]}}, ins[7], ins[30:25], ins[11:8], 1'b0};
endfunction

function automatic type_CpuData getImmU(type_CpuData ins);
  return {ins[31:12], {12{1'b0}}};
endfunction

function automatic type_CpuData getImmJ(type_CpuData ins);
  return {{12{ins[31]}}, ins[19:12], ins[20], ins[30:21], 1'b0};
endfunction

/* ALU relevant */
typedef enum logic [3:0] {
  ALU_ADD  = 4'b0000,
  ALU_SUB  = 4'b1000,
  ALU_SLT  = 4'b0010,
  ALU_SLTU = 4'b0011,
  ALU_AND  = 4'b0111,
  ALU_OR   = 4'b0110,
  ALU_XOR  = 4'b0100,
  ALU_SLL  = 4'b0001,
  ALU_SRL  = 4'b0101,
  ALU_SRA  = 4'b1101
}type_AluOp;

function automatic type_AluOp getAluOp_Op(type_CpuData ins);
  return type_AluOp'({ins[30], ins[14:12]});
endfunction

function automatic type_AluOp getAluOp_OpImm(type_CpuData ins);
  if(type_Funct3_OpImm'(ins[14:12] == SRLI_SRAI))
    return type_AluOp'({ins[30], ins[14:12]});
  else
    return type_AluOp'({1'b0, ins[14:12]});
endfunction

endpackage