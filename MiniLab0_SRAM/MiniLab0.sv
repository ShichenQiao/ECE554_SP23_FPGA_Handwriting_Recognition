module MiniLab0(clk,RST_n,LEDR,SW);

	input clk;
	input RST_n;
	input [9:0] SW;

	output reg [9:0] LEDR;

	wire rst_n;
	wire we_out, re_out; // external enables from CPU
	wire [15:0] addr_out, wdata, rdata;

	rst_synch iRST_SYN(.*);
	cpu icpu(.*);

	assign rdata = ((addr_out == 16'hC001) & re_out) ? {6'h00,SW} : 16'h8585;

	////////// LEDR FF //////////
	always @(posedge clk, negedge rst_n)
		if(!rst_n)
			LEDR <= 10'h000;
		else if ((addr_out == 16'hC000) & we_out)
			LEDR <= wdata[9:0];

endmodule