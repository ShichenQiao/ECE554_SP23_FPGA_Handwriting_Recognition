module DPRAM120x16(clk,we,waddr,wdata,raddr,rdata);

  input clk;
  input we;
  input [6:0] waddr;
  input [15:0] wdata;
  input [6:0] raddr;
  output reg [15:0] rdata;
  
  reg [15:0]mem[0:119];
  
  always @(posedge clk) begin
    if (we)
	  mem[waddr] <= wdata;
	rdata <= mem[raddr];
  end

endmodule