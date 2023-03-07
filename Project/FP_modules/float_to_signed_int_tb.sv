module float_to_signed_int_tb();

    logic [31:0] FP_val;						// input is 32 bit float
    logic signed [31:0] signed_int_val;			// output is 32 bit signed int

	int exp_val;
	int precision;

	float_to_signed_int iDUT(
		.FP_val(FP_val),
		.signed_int_val(signed_int_val)
	);

	task automatic test_float_to_signed_int(shortreal test_val);
		FP_val = $shortrealtobits(test_val);
		exp_val = $rtoi(test_val);
		precision = int'(FP_val[30:23] - 8'd127);
		#1;
		if((signed_int_val >>> precision) > (exp_val >>> precision) + 1 ||
		   (signed_int_val >>> precision) < (exp_val >>> precision) - 1) begin
			$display("WRONG ANSWER! %b  %b", signed_int_val >>> precision, exp_val >>> precision);
			$stop();
		end
	endtask

	initial begin
		// random tests
		for(int i = 0; i < 100; i++) begin
			test_float_to_signed_int($random());
		end

		$display("ALL TESTS PASSED!!!");
		$stop();
	end

endmodule
