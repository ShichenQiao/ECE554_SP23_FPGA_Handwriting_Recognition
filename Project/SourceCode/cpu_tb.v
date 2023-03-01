module cpu_tb();

reg clk,rst_n;
wire TX, RX;
assign TX = 1'hz;
assign RX = 1'hz;
//////////////////////
// Instantiate CPU //
////////////////////
cpu iCPU(.clk(clk), .rst_n(rst_n));
MiniLab1 iDUT(.clk(clk), .RST_n(rst_n),.TX(TX),.RX(RX),.SW(10'h0000));
initial begin
  clk = 0;
  rst_n = 0;
  #2 rst_n = 1;
end
  
always
  #1 clk = ~clk;
  
endmodule