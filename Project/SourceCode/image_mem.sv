module image_mem(clk,we,waddr,wdata,raddr,rdata);

  input clk;
  input we;
  input [9:0] waddr;
  input [7:0] wdata;
  input [9:0] raddr;
  output reg [7:0] rdata;
  
  reg [7:0]mem[0:1023];   // for CNN padded image is 32 by 32

  always @(negedge clk) begin
    if (we)
      mem[waddr] <= wdata < 50 ? 0 :wdata;
  rdata <= mem[raddr];
  end

endmodule
