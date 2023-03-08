module rf(clk,p0_addr,p1_addr,p0,p1,re0,re1,dst_addr,dst,we,hlt);
//////////////////////////////////////////////////////////////////
// Triple ported register file.  Two read ports (p0 & p1), and //
// one write port (dst).  Data is written on clock high, and  //
// read on clock low //////////////////////////////////////////
//////////////////////

	input clk;
	input [4:0] p0_addr, p1_addr;                   // two read port addresses
	input re0,re1;							// read enables (power not functionality)
	input [4:0] dst_addr;					// write address
	input [31:0] dst;						// dst bus
	input we;								// write enable
	input hlt;								// not a functional input.  Used to dump register contents when
											// test is halted. (No longer used)

	output [31:0] p0,p1;  					// output read ports

	wire r0_bypass, r1_bypass;				// RF bypass
	wire [31:0] p0_raw, p1_raw;				// raw read output from SRAM

	/////////////////////////////////////////////////////////////////////
	// Instantiate two dualport memory to create a tripple port rf	  //
	// Always write same data to both sram instance at the same time //
	//////////////////////////////////////////////////////////////////
	dualPort32x32 sram0(
		.clk(clk),
		.we(we),
		.re(re0),
		.waddr(dst_addr),
		.raddr(p0_addr),
		.wdata(dst),			
		.rdata(p0_raw)
	);
	dualPort32x32 sram1(
		.clk(clk),
		.we(we),
		.re(re1),
		.waddr(dst_addr),
		.raddr(p1_addr),
		.wdata(dst),
		.rdata(p1_raw)
	);

	// Bypass if any read register is the same as the write register and both re and we are high
	assign r0_bypass = ~|(p0_addr ^ dst_addr) & re0 & we;
	assign r1_bypass = ~|(p1_addr ^ dst_addr) & re1 & we;

	// R0 always stay at 32'h0000_0000
	assign p0 = ~|p0_addr ? 32'h0000_0000 : (r0_bypass ? dst : p0_raw);
	assign p1 = ~|p1_addr ? 32'h0000_0000 : (r1_bypass ? dst : p1_raw);

endmodule
