module rf(clk,p0_addr,p1_addr,p0,p1,re0,re1,dst_addr,dst,we,hlt);
//////////////////////////////////////////////////////////////////
// Triple ported register file.  Two read ports (p0 & p1), and //
// one write port (dst).  Data is written on clock high, and  //
// read on clock low //////////////////////////////////////////
//////////////////////

	input clk;
	input [3:0] p0_addr, p1_addr;			// two read port addresses
	input re0,re1;							// read enables (power not functionality)
	input [3:0] dst_addr;					// write address
	input [15:0] dst;						// dst bus
	input we;								// write enable
	input hlt;								// not a functional input.  Used to dump register contents when
											// test is halted.

	output [15:0] p0,p1;  					// output read ports
	
	wire r0_bypass, r1_bypass;				// RF bypass
	wire [15:0] p0_raw,p1_raw;				// read output from SRAM

	dualPort16x16 sram0(
		.clk(clk),
		.we(we && |dst_addr),
		.re(re0),
		.waddr(dst_addr),
		.raddr(p0_addr),
		.wdata(dst),
		.hlt(hlt),
		.rdata(p0_raw)
	);

	dualPort16x16 sram1(
		.clk(clk),
		.we(we && |dst_addr),
		.re(re1),
		.waddr(dst_addr),
		.raddr(p1_addr),
		.wdata(dst),
		.hlt(hlt),	
		.rdata(p1_raw)
	);

	// bypass if any read register is the same as the write register and both re and we are high
	assign r0_bypass = ~|(p0_addr ^ dst_addr) & we & |dst_addr & re0;
	assign r1_bypass = ~|(p1_addr ^ dst_addr) & we & |dst_addr & re1;

	assign p0 = r0_bypass ? dst : p0_raw;
	assign p1 = r1_bypass ? dst : p1_raw;
	
endmodule
  

