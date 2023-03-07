module float_to_signed_int(FP_val, signed_int_val);

    input [31:0] FP_val;						// input is 32 bit float
    output signed [31:0] signed_int_val;		// output is 32 bit signed int

    logic [22:0] M;								// mantissa
    logic [7:0] E;								// exponent

    logic [30:0] abs_int;						// unsigned value of (1.M) * 2^(E-127)

	assign M = FP_val[22:0];
	assign E = FP_val[30:23];

    // calculate the absolute value of the integer
    assign abs_int = {8'h00, |E, M} << (E - 8'd127);

    // set the sign of the integer based on the sign bit of the floating-point value
    assign signed_int_val = (FP_val[31]) ? {1'b1, (~abs_int + 31'd00000001)} : {1'b0, abs_int};

endmodule
