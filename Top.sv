module Top
(
  input clk, rst,
  output [15:0] led,
  input [15:0] sw,
  input btnc,
  output [7:0] an,
  output [7:0] seg
);

  BusItf bCpuDataIf(), bCpuInsIf(), bCacheBusIf();
  BusItf bNoneIf();   //TODO: fix this

  Cpu U_Cpu(
    .bDataCacheIf(bCpuDataIf),
    .bInsCacheIf(bCpuInsIf),
    .*
  );
  DataCache U_DataCache(
    .bCpuIf(bCpuDataIf),
    .bBusIf(bCacheBusIf),
    .*
  );
  InsCache U_InsCache(
    .bCpuIf(bCpuInsIf),
    .bBusIf(bNoneIf),
    .*
  );

  logic [15:0] led_p;
  logic ledWe_p;
  logic [15:0] sw_p;
  logic [31:0] seg_p;
  logic segWe_p;
  logic ent_p, entClr_p;
  BusCtrl U_BusCtrl(
    .bCacheIf(bCacheBusIf),
    .oLed(led_p),
    .oLedWe(ledWe_p),
    .iSw(sw_p),
    .oSeg(seg_p),
    .oSegWe(segWe_p),
    .iEnt(ent_p),
    .oEntClr(entClr_p),
    .*
  );

  Sw U_Sw(
    .iSw(sw),
    .oSw(sw_p),
    .*
  );

  Led U_Led(
    .iLed(led_p),
    .iWe(ledWe_p),
    .oLed(led),
    .*
  );

  Seg U_Seg (
    .iSeg(seg_p),
    .iWe(segWe_p),
    .oAn(an),
    .oSeg(seg),
    .*
  );

  Enter U_Enter (
    .iBtn(btnc),
    .iClr(entClr_p),
    .oEnt(ent_p),
    .*
  );

endmodule