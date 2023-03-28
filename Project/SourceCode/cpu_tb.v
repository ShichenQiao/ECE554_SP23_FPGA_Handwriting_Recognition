module cpu_tb();

reg clk,rst_n;
wire TX, RX;
assign TX = 1'hz;
assign RX = 1'hz;
//////////////////////
// Instantiate CPU //
////////////////////
cpu iCPU(.clk(clk), .rst_n(rst_n),.rdata(),.addr(),.re(),.we(),.wdata());
initial begin
  clk = 0;
  rst_n = 0;
  #2 rst_n = 1;
end
  
always
  #1 clk = ~clk;
  
endmodule