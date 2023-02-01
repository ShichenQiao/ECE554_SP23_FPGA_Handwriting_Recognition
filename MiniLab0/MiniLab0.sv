module MiniLab0(clk,KEY0,LEDR,SW);

input clk;
input KEY0;
input [9:0] SW;
output [9:0] LEDR;

wire rst_n;

rst_synch irst_synch(
	.RST_n(KEY0),
	.clk(clk),
	.rst_n(rst_n)
);

cpu icpu(
	.clk(clk),
	.rst_n(rst_n),
	.LEDR(LEDR),
	.SW(SW)
);

endmodule