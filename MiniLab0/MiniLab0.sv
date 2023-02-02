module MiniLab0(clk,KEY0,LEDR,SW);

input clk;
input KEY0;
input [9:0] SW;
output reg [9:0] LEDR;

wire rst_n;
wire [15:0] addr;
wire [15:0] rdata;
wire [15:0] wdata;

rst_synch irst_synch(
	.RST_n(KEY0),
	.clk(clk),
	.rst_n(rst_n)
);

cpu icpu(
	.clk(clk),
	.rst_n(rst_n),
	.rdata(rdata),
	.addr(addr),
	.re(re),
	.we(we),
	.wdata(wdata)
);

assign rdata = ((addr == 16'hC001) & re) ? {6'b000000, SW} : 16'hDEAD;

always @(posedge clk, negedge rst_n)
	if(!rst_n)
		LEDR <= 10'h000;
	else if ((addr == 16'hC000) & we)
		LEDR <= wdata[9:0];

endmodule