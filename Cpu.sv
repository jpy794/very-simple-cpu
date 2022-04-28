module Cpu
(
  input clk,rst,
  BusItf.Master bInsCacheIf,
  BusItf.Master bDataCacheIf
);
  import CpuPkg::*;
  import BusPkg::*;

  /* Reg */
  type_RegAddr rs1, rs2, rd;
  type_CpuData rdData;
  logic rWe;
  type_CpuData rs1Data, rs2Data;
  Register U_Register (
    .we(rWe),
    .*
  );

  /* IF */
  logic cacheReady_IF;
  assign cacheReady_IF = bInsCacheIf.valid ? bInsCacheIf.ready : 1;

  type_CpuData pc_IF;
  assign bInsCacheIf.addr = pc_IF;
  assign bInsCacheIf.wr = 0;
  assign bInsCacheIf.valid = 1;

  /* ID */
  typedef enum logic [3:0] {     
    DEFAULT     = 4'b0001,
    ALUOUT_MEM  = 4'b0010,
    MEMOUT      = 4'b0100,
    ALUOUT_WB   = 4'b1000
  }type_ForwardMux;

  logic badOpcode_ID;

  logic isIrHold;
  type_CpuData ir, ir_r;
  assign ir = isIrHold ? ir_r : bInsCacheIf.dataS2M;

  type_CpuData pc_ID;
  type_CpuData rs1Data_ID, rs2Data_ID;
  type_RegAddr rs1_ID, rs2_ID, rd_ID;
  type_CpuData imm_ID;
  type_CpuData a_ID, b_ID;
  type_AluOp aluOp_ID;
  type_BranchOp branchOp_ID;
  logic isPcIn_ID;
  logic isImmIn_ID;
  logic isLoad_ID;
  logic isStore_ID;
  logic isBranch_ID;
  logic isJump_ID;
  type_ForwardMux aMux_ID, bMux_ID;
  type_ForwardMux rs1DataMux_ID, rs2DataMux_ID;

  assign rs1Data_ID = rs1Data;
  assign rs2Data_ID = rs2Data;
  assign rs1 = rs1_ID;
  assign rs2 = rs2_ID;

  assign a_ID = isPcIn_ID ? pc_ID : rs1Data_ID;
  assign b_ID = isImmIn_ID ? imm_ID : rs2Data_ID;

  Decoder U_Decoder (
    .ins(ir),
    .rs1(rs1_ID),
    .rs2(rs2_ID),
    .rd(rd_ID),
    .imm(imm_ID),
    .aluOp(aluOp_ID),
    .branchOp(branchOp_ID),
    .isPcIn(isPcIn_ID),
    .isImmIn(isImmIn_ID),
    .isLoad(isLoad_ID),
    .isStore(isStore_ID),
    .isBranch(isBranch_ID),
    .isJump(isJump_ID),
    .badOpcode(badOpcode_ID)
  );

  /* EX */
  logic branchOut;
  
  type_CpuData a_EX, b_EX;
  type_ForwardMux aMux_EX, bMux_EX;
  type_CpuData rs1Data_EX, rs2Data_EX;
  type_ForwardMux rs1DataMux_EX, rs2DataMux_EX;
  type_AluOp aluOp_EX;
  type_BranchOp branchOp_EX;

  type_CpuData pc_EX;
  type_CpuData rs1DataForwarded_EX, rs2DataForwarded_EX;
  type_RegAddr rd_EX;
  type_CpuData aluOut_EX;
  logic isLoad_EX;
  logic isStore_EX;
  logic isBranch_EX;
  logic isJump_EX;

  type_CpuData aIn, bIn;
  always_comb begin
    unique case(aMux_EX)
      DEFAULT:    aIn = a_EX;
      ALUOUT_MEM: aIn = aluOut_MEM;
      MEMOUT:     aIn = memOut;
      ALUOUT_WB:  aIn = aluOut_WB;
    endcase
  end

  always_comb begin
    unique case(bMux_EX)
      DEFAULT:    bIn = b_EX;
      ALUOUT_MEM: bIn = aluOut_MEM;
      MEMOUT:     bIn = memOut;
      ALUOUT_WB:  bIn = aluOut_WB;
    endcase
  end

  // rs1Data / rs2Data for store / branch
  always_comb begin
    unique case(rs1DataMux_EX)
      DEFAULT:    rs1DataForwarded_EX = rs1Data_EX;
      ALUOUT_MEM: rs1DataForwarded_EX = aluOut_MEM;
      MEMOUT:     rs1DataForwarded_EX = memOut;
      ALUOUT_WB:  rs1DataForwarded_EX = aluOut_WB;
    endcase
  end

  always_comb begin
    unique case(rs2DataMux_EX)
      DEFAULT:    rs2DataForwarded_EX = rs2Data_EX;
      ALUOUT_MEM: rs2DataForwarded_EX = aluOut_MEM;
      MEMOUT:     rs2DataForwarded_EX = memOut;
      ALUOUT_WB:  rs2DataForwarded_EX = aluOut_WB;
    endcase
  end

  Alu U_Alu (
    .a(aIn),
    .b(bIn),
    .y(aluOut_EX),
    .op(aluOp_EX)
  );

  Branch U_Branch (
    .a(rs1DataForwarded_EX),
    .b(rs2DataForwarded_EX),
    .y(branchOut),
    .op(branchOp_EX)
  );

  /* MEM */
  type_CpuData rs2DataForwarded_MEM;
  logic cacheReady_MEM;

  type_CpuData pc_MEM;
  type_RegAddr rd_MEM;
  type_CpuData aluOut_MEM;
  logic isLoad_MEM;
  logic isStore_MEM;
  logic isBranch_MEM;
  logic isJump_MEM;

  assign bDataCacheIf.addr = aluOut_MEM;
  assign bDataCacheIf.wr = isStore_MEM;
  assign bDataCacheIf.dataM2S = rs2DataForwarded_MEM;

  assign bDataCacheIf.valid = (isStore_MEM || isLoad_MEM);
  assign cacheReady_MEM = bDataCacheIf.valid ? bDataCacheIf.ready : 1;

  /* WB */
  type_CpuData memOut;
  assign memOut = bDataCacheIf.dataS2M;

  type_CpuData pc_WB;
  type_RegAddr rd_WB;
  type_CpuData aluOut_WB;
  logic isLoad_WB;
  logic isStore_WB;
  logic isBranch_WB;
  logic isJump_WB;

  assign rd = rd_WB;

  always_comb begin
    rWe = 0;
    rdData = 32'b0;
    if(!isStore_WB && !isBranch_WB) begin
      rWe = 1;
      if(isLoad_WB)        rdData = memOut;
      else if(isJump_WB)   rdData = pc_WB + 4;
      else                 rdData = aluOut_WB;
    end
  end

  /* Update pc_IF */
  type_CpuData pcNext_IF;
  always_comb begin
    pcNext_IF = pc_IF;
    if(isBranch_EX) begin
      if(branchOut) pcNext_IF = aluOut_EX;
      else          pcNext_IF = pc_IF;
    end else if(isJump_EX) begin
      pcNext_IF = aluOut_EX;
    end else
      pcNext_IF = pc_IF + 4;
  end

  /* Pipeline */
  logic awaitCache;
  assign awaitCache = !cacheReady_IF || !cacheReady_MEM;

  logic branchHazard, loadUseHazard;
  assign branchHazard = (isBranch_ID || isJump_ID);
  always_comb begin
    loadUseHazard = 0;
    if(isBranch_ID || isStore_ID) begin        // branch / store use pc and imm but still need to handle load-use hazard first
      loadUseHazard = (rd_EX == rs1_ID && rd_EX != 0 && isLoad_EX)
                    ||(rd_EX == rs2_ID && rd_EX != 0 && isLoad_EX);
    end else begin
      loadUseHazard = (rd_EX == rs1_ID && rd_EX != 0 && isLoad_EX && !isPcIn_ID)
                    ||(rd_EX == rs2_ID && rd_EX != 0 && isLoad_EX && !isImmIn_ID);
    end
  end

  typedef enum logic [2:0] {
    S_IDLE = 3'b001,
    S_BRANCH_0 = 3'b010,
    S_BRANCH_1 = 3'b100
  } type_State;
  type_State state, next;

  always_ff @(posedge clk, negedge rst) begin
    if(!rst)             state <= S_IDLE;
    else if(!awaitCache) state <= next;
  end

  logic stall_IF, stall_ID, flush_EX;
  always_comb begin
    next = S_IDLE;
    stall_IF = 0;
    stall_ID = 0;
    flush_EX = 0;
    case(state)
      S_IDLE: begin                       //load-use hazard can happened in branch hazard
        if(loadUseHazard) begin           //so consider load-use hazard first
          stall_IF = 1;
          stall_ID = 1;
          flush_EX = 1;
        end else if(branchHazard) begin
          stall_IF = 1;
          stall_ID = 1;
          next = S_BRANCH_0;
        end
      end
      S_BRANCH_0: begin
        stall_ID = 1;
        flush_EX = 1;
        next = S_BRANCH_1;
      end
      S_BRANCH_1: begin
        flush_EX = 1;
        next = S_IDLE;
      end
    endcase
  end

  /* Forward */
  // do this in two stages to avoid timing fault
  always_comb begin
    aMux_ID = DEFAULT;
    if(!isPcIn_ID && rd_EX == rs1_ID && rd_EX != 5'b0) begin
      aMux_ID = ALUOUT_MEM;
    end else if(!isPcIn_ID && rd_MEM == rs1_ID && rd_MEM != 5'b0) begin
      if(isLoad_MEM)
        aMux_ID = MEMOUT;
      else
        aMux_ID = ALUOUT_WB;
    end
  end

  always_comb begin
    bMux_ID = DEFAULT;
    if(!isImmIn_ID && rd_EX == rs2_ID && rd_EX != 5'b0) begin
      bMux_ID = ALUOUT_MEM;
    end else if(!isImmIn_ID && rd_MEM == rs2_ID && rd_MEM != 5'b0) begin
      if(isLoad_MEM)
        bMux_ID = MEMOUT;
      else
        bMux_ID = ALUOUT_WB;
    end
  end

  always_comb begin
    rs1DataMux_ID = DEFAULT;
    if(rd_EX == rs1_ID && rd_EX != 5'b0) begin
      rs1DataMux_ID = ALUOUT_MEM;
    end else if(rd_MEM == rs1_ID && rd_MEM != 5'b0) begin
      if(isLoad_MEM)
        rs1DataMux_ID = MEMOUT;
      else
        rs1DataMux_ID = ALUOUT_WB;
    end
  end

  always_comb begin
    rs2DataMux_ID = DEFAULT;
    if(rd_EX == rs2_ID && rd_EX != 5'b0) begin
      rs2DataMux_ID = ALUOUT_MEM;
    end else if(rd_MEM == rs2_ID && rd_MEM != 5'b0) begin
      if(isLoad_MEM)
        rs2DataMux_ID = MEMOUT;
      else
        rs2DataMux_ID = ALUOUT_WB;
    end
  end

  /* SegReg */
  always_ff @(posedge clk, negedge rst) begin
    if(!rst) begin
      /* IF */
      pc_IF <= P_PC_INIT;

      /* ID */
      isIrHold <= 1;
      ir_r <= P_NOP;

      /* EX */
      aMux_EX <= DEFAULT;
      bMux_EX <= DEFAULT;
      rd_EX <= 5'b0;
      isLoad_EX <= 0;
      isStore_EX <= 0;
      isBranch_EX <= 0;
      isJump_EX <= 0;

      /* MEM */
      rd_MEM <= 5'b0;
      isLoad_MEM <= 0;
      isStore_MEM <= 0;
      isBranch_MEM <= 0;
      isJump_MEM <= 0;

      /* WB */
      rd_WB <= 5'b0;
      isLoad_WB <= 0;
      isStore_WB <= 0;
      isBranch_WB <= 0;
      isJump_WB <= 0;
    end else begin
      /* IF */
      if(!awaitCache && !stall_IF)
        pc_IF <= pcNext_IF;

      /* IF to ID */
      if(awaitCache || stall_ID) begin
        if(!isIrHold) begin
          isIrHold <= 1;
          ir_r <= ir;
        end
      end else begin
        isIrHold <= 0;
        pc_ID <= pc_IF;
      end

      /* ID to EX */
      if(!awaitCache) begin
        if(!flush_EX) begin
          a_EX <= a_ID;
          b_EX <= b_ID;
          aluOp_EX <= aluOp_ID;
          branchOp_EX <= branchOp_ID;

          rs1Data_EX <= rs1Data_ID;
          rs2Data_EX <= rs2Data_ID;
          aMux_EX <= aMux_ID;
          bMux_EX <= bMux_ID;
          rs1DataMux_EX <= rs1DataMux_ID;
          rs2DataMux_EX <= rs2DataMux_ID;

          pc_EX <= pc_ID;
          rd_EX <= rd_ID;
          isLoad_EX <= isLoad_ID;
          isStore_EX <= isStore_ID;
          isBranch_EX <= isBranch_ID;
          isJump_EX <= isJump_ID;
        end else begin
          a_EX <= 32'b0;
          b_EX <= 32'b0;
          aluOp_EX <= ALU_ADD;
          branchOp_EX <= branchOp_ID;

          aMux_EX <= DEFAULT;
          bMux_EX <= DEFAULT;

          rd_EX <= 5'b0;
          isLoad_EX <= 0;
          isStore_EX <= 0;
          isBranch_EX <= 0;
          isJump_EX <= 0;
        end
      end

      /* EX to MEM */
      if(!awaitCache) begin
        rs2DataForwarded_MEM <= rs2DataForwarded_EX;

        pc_MEM <= pc_EX;
        rd_MEM <= rd_EX;
        aluOut_MEM <= aluOut_EX;
        isLoad_MEM <= isLoad_EX;
        isStore_MEM <= isStore_EX;
        isBranch_MEM <= isBranch_EX;
        isJump_MEM <= isJump_EX;
      end

      /* MEM to WB */
      if(!awaitCache) begin
        pc_WB <= pc_MEM;
        rd_WB <= rd_MEM;
        aluOut_WB <= aluOut_MEM;
        isLoad_WB <= isLoad_MEM;
        isStore_WB <= isStore_MEM;
        isBranch_WB <= isBranch_MEM;
        isJump_WB <= isJump_MEM;
      end
    end
  end

endmodule : Cpu