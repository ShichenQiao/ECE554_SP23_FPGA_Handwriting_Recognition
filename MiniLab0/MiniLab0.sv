module MiniLab0(clk,KEY0,LEDR,SW);

input clk;
input KEY0;
input [9:0] SW;
output reg [9:0] LEDR;

wire rst_n;
wire [15:0] addr;
wire [15:0] rdata;
wire [15:0] wdata;
wire update_LED;

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

assign rdata = ((addr == 16'hC001) & re) ? {6'b000000, SW} : 16'hDEAD;			// If external addr invalid, put DEAD on data line

assign update_LED = (addr == 16'hC000) & we;

always @(posedge clk, negedge rst_n)
	if(!rst_n)
		LEDR <= 10'h000;
	else if (update_LED)
		LEDR <= wdata[9:0];						// data is 16 bit, but only have 10 LEDs, use lower bits

endmodule