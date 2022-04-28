module Edge #(
  parameter P_POSEDGE = 0
)(
  input clk, rst,
  input logic in,
  output logic out
);

  logic cntClr, cntOver;
  Counter #(
    .P_FREQ_HZ(100)          //10ms
  ) U_Counter (
    .iClr(cntClr),
    .oOver(cntOver),
    .*
  );

  logic pos;
  assign pos = P_POSEDGE ? in : ~in;

  typedef enum logic [1:0] {
    S_IDLE,
    S_WAIT_EDGE,
    S_WAIT_JITTER,
    S_EDGE
  } type_State;

  type_State state, next;

  always_ff @(posedge clk, negedge rst) begin
    if(!rst) state <= S_IDLE;
    else     state <= next;
  end

  always_comb begin
    out = 0;
    cntClr = 0;
    next = S_IDLE;
    case(state)
      S_IDLE: begin
        if(!pos) next = S_WAIT_EDGE;
        else     next = S_IDLE;
      end
      S_WAIT_EDGE: begin
        if(pos) begin
          cntClr = 1;
          next = S_WAIT_JITTER;
        end else next = S_WAIT_EDGE;
      end
      S_WAIT_JITTER: begin
        if(!pos)         next = S_IDLE;
        else if(cntOver) next = S_EDGE;
        else             next = S_WAIT_JITTER;
      end
      S_EDGE: begin
        out = 1;
        next = S_IDLE;
      end
    endcase
  end

endmodule : Edge