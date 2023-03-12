module image_mem(clk,we,waddr,wdata,raddr,rdata);

  input clk;
  input we;
  input [9:0] waddr;
  input [7:0] wdata;
  input [9:0] raddr;
  output reg [7:0] rdata;
  
  reg [7:0]mem[0:783];   //The current video mem is 7bit x (28x28), grayscale for each pixel

  always @(negedge clk) begin
    if (we)
      mem[waddr] <= wdata;
  rdata <= mem[raddr];
  end

endmodule
