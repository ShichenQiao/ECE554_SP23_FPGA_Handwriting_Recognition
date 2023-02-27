module dualPort32x32(clk,we,re,waddr,raddr,wdata,rdata);

	input clk;					// system clock
	input we;					// write enable
	input re;					// read enable
	input [4:0] waddr;			// write address
	input [4:0] raddr;			// read address
	input [31:0] wdata;			// data to write
	output reg [31:0] rdata;	// read data output
	
	reg [31:0] mem [31:0];		// 32 by 32 SRAM block

	// negedge triggered memory
	always @(negedge clk) begin
		if(we)
			mem[waddr] <= wdata;
		if(re)
			rdata <= mem[raddr];
	end
	
endmodule
