module dualPort16x16(clk,we,re,waddr,raddr,wdata,rdata);

	input clk;
	input we;
	input re;
	input [3:0] waddr;
	input [3:0] raddr;
	input [15:0] wdata;
	output reg [15:0] rdata;
	
	reg [15:0] mem [15:0];		// 16 by 16 SRAM block
	
	integer indx;

	// negedge triggered memory
	always @(negedge clk) begin
		if(we)
			mem[waddr] <= wdata;
		if(re)
			rdata <= mem[raddr];
	end
	
endmodule