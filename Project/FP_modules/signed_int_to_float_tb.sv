module signed_int_to_float_tb();

    logic signed [31:0] signed_int_val;
    logic [31:0] FP_val;

	shortreal temp;
	logic [31:0] exp_val;

	signed_int_to_float iDUT(
		.signed_int_val(signed_int_val),
		.FP_val(FP_val)
	);

	task automatic test_signed_int_to_float(int test_val);
		signed_int_val = test_val;
		temp = $itor(signed_int_val);
		exp_val = $shortrealtobits(temp);
		#1;
		// if signs do not match, doom to fail!
		if(FP_val[31] !== exp_val[31]) begin
			$display("WRONG ANSWER! %d should be converted to %b, not %b", signed_int_val, exp_val, FP_val);
			$stop();
		end

		// for normalized FP numbers (all 32-bits signed ints are), consider {S, E + 1, 23'h00000000} the same as {S, E, 23'h7FFFFFFF} due to rounding errors of itor and shortrealtobits
		if(&FP_val[22:0] && (FP_val[30:23] == exp_val[30:23] - 8'h01) ||
		   &exp_val[22:0] && (exp_val[30:23] == FP_val[30:23] - 8'h01)) begin
			return;
		end

		// allow -1 ~ +1 difference (on the LSBs of M) due to shortrealtobits and bitstoshortreal error
		if((FP_val[30:23] === exp_val[30:23]) &&
		   (signed'({2'b00, FP_val[22:0]}) >= signed'({2'b00, exp_val[22:0]}) - signed'(25'h000001)) &&
		   (signed'({2'b00, FP_val[22:0]}) <= signed'({2'b00, exp_val[22:0]}) + signed'(25'h000001))) begin
		    return;
		end

		// if not fall into any of the 2 categories above, testcase FAILED
		$display("WRONG ANSWER! %d should be converted to %b, not %b", signed_int_val, exp_val, FP_val);
		$stop();
	endtask

	initial begin

		// test zero
		test_signed_int_to_float(32'h00000000);

		// test largest positive signed int
		test_signed_int_to_float(32'h7FFFFFFF);

		// test most negative signed int
		test_signed_int_to_float(32'h80000000);

		// random tests
		for(int i = 0; i < 1000; i++) begin
			test_signed_int_to_float($random());
		end

		$display("ALL TESTS PASSED!!!");
		$stop();
	end

endmodule
