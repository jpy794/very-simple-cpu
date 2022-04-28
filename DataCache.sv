//TODO: make it a real cache for mem
//TODO: need a bus arbiter for inscache and datacache
//cache hit : after next posedge data should be there
//cache miss : need extra one more cycle
module DataCache
#(
  localparam P_SIZE = 256,
  localparam  P_CACHE_BASE = 32'h0000_0000
)(
  input clk, rst,
  BusItf.Slave bCpuIf,
  BusItf.Master bBusIf
);
  import BusPkg::*;

  //TODO: load data dynamicly from mem to cacheBase
  type_Addr cacheBase;
  assign cacheBase = P_CACHE_BASE;

  localparam P_W_CACHE_ADDR = $clog2(P_SIZE);
  typedef logic [P_W_CACHE_ADDR-1:0] type_BramAddr;

  logic bramEn, bramWe;
  type_BramAddr bramAddr;
  type_Data bramDataIn, bramDataOut;
  Bram #(
    .P_SIZE(P_SIZE),
    .P_WIDTH(P_WDATA),
    .P_INIT("data.mem")
  ) U_Bram (
    .clk,
    .en(bramEn),
    .we(bramWe),
    .addr(bramAddr),
    .iData(bramDataIn),
    .oData(bramDataOut)
  );

  assign bramWe = bCpuIf.wr;
  assign bramDataIn = bCpuIf.dataM2S;
  assign bramAddr = type_BramAddr'((bCpuIf.addr - cacheBase) >> 2);     //rshift by 2 before access cache

  assign bBusIf.wr = bCpuIf.wr;
  assign bBusIf.dataM2S = bCpuIf.dataM2S;
  assign bBusIf.addr = bCpuIf.addr;

  logic hit;
  assign hit = bCpuIf.addr inside {[cacheBase:cacheBase + P_SIZE * 4 - 1]};         //maybe when it access 0xffff_ffff there can be bug

  typedef enum logic [1:0] {
    S_IDLE,
    S_HIT,
    S_MISS,
    S_BUS
  } type_state;
  type_state state, next;

  always_ff @(posedge clk, negedge rst) begin
    if(!rst) state <= S_IDLE;
    else     state <= next;
  end

  always_comb begin
    next = S_IDLE;
    bramEn = 0;
    bCpuIf.dataS2M = 32'b0;
    bCpuIf.ready = 0;
    
    unique case(state)
      S_IDLE: begin
        bBusIf.valid = 0;
        if(bCpuIf.valid) begin
          if(hit) begin
            bramEn = 1;
            bCpuIf.ready = 1;
            next = S_HIT;
          end else next = S_MISS;
        end
      end

      S_HIT: begin
        bBusIf.valid = 0;
        bCpuIf.dataS2M = bramDataOut;
        if(bCpuIf.valid) begin
          if(hit) begin
            bramEn = 1;
            bCpuIf.ready = 1;
            next = S_HIT;
          end else next = S_MISS;
        end else next = S_IDLE;
      end

      S_MISS: begin
        bBusIf.valid = 1;
        if(bBusIf.ready) begin
          bCpuIf.ready = 1;
          next = S_BUS;
        end else next = S_MISS;
      end

      S_BUS: begin
        bBusIf.valid = 0;
        bCpuIf.dataS2M = bBusIf.dataS2M;
        if(bCpuIf.valid) begin
          if(hit) begin
            bramEn = 1;
            bCpuIf.ready = 1;
            next = S_HIT;
          end else next = S_MISS;
        end else next = S_IDLE;
      end
    endcase
  end

endmodule : DataCache