module BMP_display_tb();

reg clk,rst_n;
reg VGA_CLK;

//////////////////////
// Instantiate CPU //
////////////////////
BMP_display_sim iDUT(.clk(clk), .VGA_CLK(VGA_CLK), .RST_n(rst_n));

initial begin
  clk = 0;
  rst_n = 0;
  VGA_CLK = 0;
  #2 rst_n = 1;
  #10000 $stop();
end
  
always
  #1 clk = ~clk;

always@(posedge clk)
  VGA_CLK <= ~VGA_CLK;
  
endmodule