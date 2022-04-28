module BusCtrl
import BusPkg::*;
(
  input logic clk, rst,
  BusItf.Slave bCacheIf,    //TODO: handle two master access

  //peripherals
  output logic [15:0] oLed,
  output logic oLedWe,
  input logic [15:0] iSw,
  output logic [31:0] oSeg,
  output logic oSegWe,
  input logic iEnt,
  output logic oEntClr
);

  localparam P_MMIO_BASE = 32'h0000_7f00;
  localparam P_LED       = P_MMIO_BASE;          //[15:0]: led
  localparam P_SW        = P_MMIO_BASE + 4;      //[15:0]: sw
  localparam P_SEG       = P_MMIO_BASE + 8;      //[31:0]: seg
  localparam P_ENT       = P_MMIO_BASE + 12;     //[0:0]: enter

  logic mmio;
  assign mmio = bCacheIf.addr >= P_MMIO_BASE;

  assign oLed = bCacheIf.dataM2S[15:0];
  assign oSeg = bCacheIf.dataM2S;

  typedef enum logic [0:0] {
    S_IDLE,
    S_MMIO
  } type_State;
  type_State state, next;

  always_ff @(posedge clk, negedge rst) begin
    if(!rst) state <= S_IDLE;
    else     state <= next;
  end

  type_Data mmioOut, mmioOut_r;
  always_comb begin
    mmioOut = 32'b0;
    case(bCacheIf.addr)
      P_SW : mmioOut = {16'b0, iSw};
      P_ENT: mmioOut = {31'b0, iEnt};
    endcase
  end

  always_ff @(posedge clk) begin
    mmioOut_r <= mmioOut;
  end

  always_comb begin
    next = S_IDLE;
    bCacheIf.ready = 0;         //set deafult value so that we donnot have to set manually
    bCacheIf.dataS2M = 32'b0;
    oLedWe = 0;
    oSegWe = 0;
    oEntClr = 0;
    case(state)
      S_IDLE: begin
        bCacheIf.dataS2M = mmioOut_r;
        if(bCacheIf.valid) begin
          if(mmio) begin
            case(bCacheIf.addr)
              P_LED: if(bCacheIf.wr) oLedWe = 1;
              P_SW : ;
              P_SEG: if(bCacheIf.wr) oSegWe = 1;
              P_ENT: oEntClr = 1;
            endcase
            bCacheIf.ready = 1;

            next = S_IDLE;
          end
          else  begin    
            //TODO: handle normal memory access
          end
        end
      end
    endcase
  end
  
endmodule