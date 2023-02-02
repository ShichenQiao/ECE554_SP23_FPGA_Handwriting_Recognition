module rst_synch(
	input RST_n,
	input clk,
	output reg rst_n
);
	
	reg ff1;
	
	// asynch reset when RST_n asserted, other wise, double flop 1'b1 to deassert rst_n on negedge clk
	always_ff @(negedge clk, negedge RST_n)
		if(!RST_n) begin
			ff1 <= 1'b0;
			rst_n <= 1'b0;
		end
		else begin
			ff1 <= 1'b1;
			rst_n <= ff1;
		end

endmodule