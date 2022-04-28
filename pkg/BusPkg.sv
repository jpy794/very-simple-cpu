package BusPkg;

//TODO: hadle unaligned access
parameter P_WADDR = 32;
parameter P_WDATA = 32;

typedef logic [P_WADDR-1:0] type_Addr;
typedef logic [P_WDATA-1:0] type_Data;

endpackage : BusPkg