interface BusItf;
  import BusPkg::*;

  type_Addr addr;
  type_Data dataM2S, dataS2M;
  logic valid, wr, ready;

  modport Master(output addr,dataM2S,valid,wr, input dataS2M, ready);
  modport Slave(input addr,dataM2S,valid,wr, output dataS2M, ready);
endinterface : BusItf