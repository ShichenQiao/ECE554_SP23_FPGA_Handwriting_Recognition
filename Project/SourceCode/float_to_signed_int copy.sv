module float_to_signed_int(FP_val, signed_int_val);

    input [31:0] FP_val;						// input is 32 bit float
    output signed [31:0] signed_int_val;		// output is 32 bit signed int

    logic [22:0] M;								// mantissa
    logic [7:0] E;								// exponent

    logic [30:0] abs_int;						// unsigned value of (1.M) * 2^(E-127)

	assign M = FP_val[22:0];
	assign E = FP_val[30:23];

    // calculate the absolute value of the integer, choosing correct shift direction according to E
    assign abs_int = E >= 8'd150 ? {8'h00, 1'b1, M} << (E - 8'd150) : {8'h00, 1'b1, M} >> (8'd150 - E);

    // convert abs_int to signed_int_val with saturation/zeroing logic
    assign signed_int_val = E >= 8'd182 ? ((FP_val[31]) ? 32'h80000000 : 32'h7FFFFFFF) :			// if E too large, saturate
							E < 8'd127 ? 32'h00000000 :												// if E too small, zero
							(FP_val[31]) ? {1'b1, (~abs_int + 31'd00000001)} : {1'b0, abs_int};		// if neither of the extremes, output according to sign

endmodule
