module dualPort16x16(clk,we,re,waddr,raddr,wdata,rdata);

	input clk;					// system clock
	input we;					// write enable
	input re;					// read enable
	input [3:0] waddr;			// write address
	input [3:0] raddr;			// read address
	input [15:0] wdata;			// data to write
	output reg [15:0] rdata;	// read data output
	
	reg [15:0] mem [15:0];		// 16 by 16 SRAM block

	// negedge triggered memory
	always @(negedge clk) begin
		if(we)
			mem[waddr] <= wdata;
		if(re)
			rdata <= mem[raddr];
	end
	
endmodule
