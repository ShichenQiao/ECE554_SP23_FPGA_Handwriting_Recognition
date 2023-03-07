module float_to_signed_int_tb();

    logic [31:0] FP_val;						// input is 32 bit float
    logic signed [31:0] signed_int_val;			// output is 32 bit signed int

	int exp_val;

	float_to_signed_int iDUT(
		.FP_val(FP_val),
		.signed_int_val(signed_int_val)
	);

	task automatic test_float_to_signed_int(shortreal test_val);
		FP_val = $shortrealtobits(test_val);
		exp_val = $rtoi(test_val);
		#1;

		// allow -1 ~ +1 difference due to shortrealtobits and rtoi error
		if(signed_int_val >= exp_val - 1 && signed_int_val <= exp_val + 1) begin
		    return;
		end

		$display("WRONG ANSWER!");
		$stop();
	endtask

	initial begin
		// random tests
		for(int i = 0; i < 100; i++) begin
			test_float_to_signed_int($random());
		end
	end

endmodule
