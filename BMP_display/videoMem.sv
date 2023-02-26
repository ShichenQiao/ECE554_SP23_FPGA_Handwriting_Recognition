module videoMem(clk,we,waddr,wdata,raddr,rdata);

  input clk;
  input we;
  input [18:0] waddr;
  input [8:0] wdata;
  input [18:0] raddr;		// although we only need 18 bits for our memory, the 19th bit is still needed for the rdata mux
  output reg [8:0] rdata;
  
  // we cutted the provided videoMem into half of the original size
  // to make the compiler happy. The FPGA board does not have enough
  // memory for this.
  reg [8:0]mem[0:153599];

  reg [8:0] rdata_raw;
    
  // we fill the lower half of the screen with 0x1FF, white.
  assign rdata = raddr < 19'h25800 ? rdata_raw : 9'h1FF;		// 19'h25800 == 153600
  
  always @(posedge clk) begin
    if (we && waddr<153600)
      mem[waddr] <= wdata;
    rdata_raw <= mem[raddr[17:0]];
  end

endmodule