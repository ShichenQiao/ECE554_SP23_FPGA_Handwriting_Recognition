module float_to_signed_int_tb();

	import FP_special_values::*;

    logic [31:0] FP_val;						// input is 32 bit float
    logic signed [31:0] signed_int_val;			// output is 32 bit signed int

	int exp_val;
	int precision_right_shift;

	float_to_signed_int iDUT(
		.FP_val(FP_val),
		.signed_int_val(signed_int_val)
	);

	task automatic test_float_to_signed_int(shortreal test_val);
		FP_val = $shortrealtobits(test_val);
		exp_val = $rtoi(test_val);
		precision_right_shift = FP_val[30:23] <= 8'd150 ? 0 :
					FP_val[30:23] < 8'd181 ? int'(FP_val[30:23] - 8'd150) :
					0;
		#1;
		// if FP_val's abs value is too large, PASS if saturated
		if((FP_val[30:23] >= 8'd182) && (signed_int_val[31] ? signed_int_val === 32'h80000000 : signed_int_val === 32'h7FFFFFFF) ) begin
			return;
		end

		// if FP_val's abs value is between zero and one, PASS if zeroed
		if((FP_val[30:23] < 8'd127) && ~|signed_int_val) begin
			return;
		end

		// allow -1 ~ +1 difference on the scale of valid precision due to shortrealtobits and rtoi error
		// if E in FP input is too large or too small, this if check will automatically let it PASS, since the converted int is meaningless anyways
		if((signed_int_val >>> precision_right_shift) > (exp_val >>> precision_right_shift) + 1 ||
		   (signed_int_val >>> precision_right_shift) < (exp_val >>> precision_right_shift) - 1) begin
			$display("WRONG ANSWER! %b  %b", signed_int_val >>> precision_right_shift, exp_val >>> precision_right_shift);
			$stop();
		end
	endtask

	initial begin
		// random tests
		for(int i = 0; i < 1000; i++) begin
			test_float_to_signed_int($random());			// intentionally not casting to use the 32 random bits as shortreal
		end

		// random tests of small integers
		for(int i = 0; i < 1000; i++) begin
			test_float_to_signed_int($itor($random() % 100000));
		end

		// special FP value tests
		for(int i = 0; i < 16; i++) begin
			test_float_to_signed_int($bitstoshortreal(SPECIAL_VALS_ARR[i]));
		end

		$display("ALL TESTS PASSED!!!");
		$stop();
	end

endmodule
