module MiniLab0_tb();

	logic clk;
	logic KEY0;
	logic [9:0] SW;
	logic [9:0] LEDR;
	
	MiniLab0 iDUT(
		.clk(clk),
		.KEY0(KEY0),
		.LEDR(LEDR),
		.SW(SW)
	);

	initial begin
		clk = 1'b0;
		for(int i = 0; i < 10; i++) begin
			@(negedge clk) KEY0 = 1'b0;
			SW = $random;					// randomly choose a SW pattern
			@(posedge clk);
			@(negedge clk) KEY0 = 1'b1;
			repeat(15)@(posedge clk);
			if(LEDR !== SW) begin			// should show up on LEDs after a few instructions
				$display("ERROR: LED failed to reflect SW state!");
				$stop();
			end
		end
		$display("ALL TESTS PASSED!!!");
		$stop();
	end

	always
		#5 clk = ~clk;

endmodule
