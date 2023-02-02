module dualPort16x16(clk,we,re,waddr,raddr,wdata,rdata,hlt);

	input clk;
	input we;
	input re;
	input [3:0] waddr;
	input [3:0] raddr;
	input [15:0] wdata;
	input hlt;
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
	
	////////////////////////////////////////
	// Dump register contents at program //
	// halt for debug purposes          //
	/////////////////////////////////////
	always @(posedge hlt)
	  for(indx=1; indx<16; indx = indx+1)
		$display("R%1h = %h",indx,mem[indx]);
	
endmodule