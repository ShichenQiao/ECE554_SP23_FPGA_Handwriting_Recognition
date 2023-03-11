module top_tb();

reg clk, rst_n;

ImageRecog iDUT(
	.ref_clk(clk),
	.RST_n(rst_n)
);

initial begin
  clk = 0;
  rst_n = 0;
  #2 rst_n = 1;
end
  
always
  #1 clk = ~clk;
  
endmodule