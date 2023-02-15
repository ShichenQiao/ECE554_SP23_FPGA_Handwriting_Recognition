module MiniLab0_tb();

	logic clk;
	logic KEY0;
	logic [9:0] SW;
	logic [9:0] LEDR;
	logic halt;
	
	assign halt = iDUT.icpu.hlt_DM_WB;			// extract hlt signal from icpu

	MiniLab0 iDUT(
		.clk(clk),
		.KEY0(KEY0),
		.LEDR(LEDR),
		.SW(SW)
	);

	initial begin
		clk = 1'b0;
		KEY0 = 1'b0;
		@(posedge clk);
		@(negedge clk) KEY0 = 1'b1;
		
		// run random test 30 times
		for(int i = 0; i < 30; i++) begin
			@(negedge clk) SW = $random;		// randomly choose a SW pattern
			if(SW === 10'b11_1111_1111)			// if, unfortunately, hit all 1s, break out to test halting feature in advance
				break;
			@(negedge iDUT.update_LED)			// wait until LEDs are updated
			if(LEDR !== SW) begin				// check if LED reflects the state of SW
				$display("ERROR: LED failed to reflect SW state!");
				$stop();
			end
		end
		
		// test halting feature (when all SWs are ON, program should halt for good)
		@(negedge clk) SW = 10'b11_1111_1111;
		wait4sig(halt, 20);					// assert timeout error if do not see halt in 20 cycles after all SW pulled up
		repeat(3)@(posedge clk);			// just to get a prettier waveform

		$display("ALL TESTS PASSED!!!");
		$stop();
	end

	// task to check timeouts of waiting the posedge of a given status signal
	task automatic wait4sig(ref sig, input int clks2wait);
		fork
			begin: timeout
				repeat(clks2wait) @(posedge clk);
				$display("ERROR: timed out waiting for sig in wait4sig");
				$stop();
			end
			begin
				@(posedge sig)
				disable timeout;
			end
		join
	endtask

	always
		#5 clk = ~clk;

endmodule