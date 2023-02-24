module videoMem(clk,we,waddr,wdata,raddr,rdata);

  input clk;
  input we;
  input [18:0] waddr;
  input [8:0] wdata;
  input [18:0] raddr;
  output reg [8:0] rdata;
  
  reg [8:0]mem[0:153599];
  
  reg [8:0] rdata_raw;
  assign rdata = raddr < 153600 ? rdata_raw : 9'h1FF;
  
  always @(posedge clk) begin
    if (we && waddr<153600)
      mem[waddr] <= wdata;
    rdata_raw <= mem[raddr[17:0]];
  end

endmodule