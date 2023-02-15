module MiniLab0(clk,KEY0,LEDR,SW);

	input clk;
	input KEY0;					// master reset button
	input [9:0] SW;				// 10 switches, external address = 0xC001
	output reg [9:0] LEDR;		// 10 LEDs, external address = 0xC000

	wire rst_n;					// synchronized active low reset
	wire [15:0] addr;			// dst_EX_DM, result from ALU
	wire [15:0] rdata;			// exteral data input from the switches, 16'hDEAD if addr != 16'hC001
	wire [15:0] wdata;			// data from cpu that will reflect on LEDs if addr == 16'hC000 during write
	wire update_LED;			// update LED status if addr == 16'hC000 and we is set

	// push button input synchronization
	rst_synch irst_synch(
		.RST_n(KEY0),
		.clk(clk),
		.rst_n(rst_n)
	);

	// iDUT
	cpu icpu(
		.clk(clk),
		.rst_n(rst_n),
		.rdata(rdata),
		.addr(addr),
		.re(re),
		.we(we),
		.wdata(wdata)
	);

	assign rdata = ((addr == 16'hC001) & re) ? {6'b000000, SW} : 16'hDEAD;			// If external addr invalid, put 0xDEAD on data line

	assign update_LED = (addr == 16'hC000) & we;			// make testbench more straight forward

	// Considering LED as a "memory", so picked negedge trigged flops
	always @(negedge clk, negedge rst_n)
		if(!rst_n)
			LEDR <= 10'h000;				// LED output default to all OFF
		else if (update_LED)
			LEDR <= wdata[9:0];				// data is 16 bit, but only have 10 LEDs, use lower bits

endmodule