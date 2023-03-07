module signed_int_to_float_tb();

    logic signed [31:0] signed_int_val;
    logic [31:0] FP_val;

	shortreal a;
	logic [31:0] exp_val;

	signed_int_to_float iDUT(
		.signed_int_val(signed_int_val),
		.FP_val(FP_val)
	);

	initial begin

		for(int i = 0; i < 100; i++) begin
			signed_int_val = $random();
			a = $itor(signed_int_val);
			exp_val = $shortrealtobits(a);
			#1;
			if((FP_val[30:23] !== exp_val[30:23]) ||
			   (signed'({2'b00, FP_val[22:0]}) < signed'({2'b00, exp_val[22:0]}) - signed'(25'h000001)) ||
		       (signed'({2'b00, FP_val[22:0]}) > signed'({2'b00, exp_val[22:0]}) + signed'(25'h000001))) begin
				$display("WRONG ANSWER!");
				$stop();
			end
		end

		$display("ALL TESTS PASSED!!!");
		$stop();
	end

endmodule
