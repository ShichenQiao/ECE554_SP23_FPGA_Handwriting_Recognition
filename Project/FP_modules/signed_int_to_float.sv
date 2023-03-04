module signed_int_to_float(signed_int_val, FP_val);

    input signed [31:0] signed_int_val;
    output [31:0] FP_val;

    logic [30:0] abs_int;
    logic [22:0] M;
    logic [7:0] E;

	logic [4:0] shift_amount;

    // get the absolute value of the input integer
    assign abs_int = signed_int_val[31] ? (~signed_int_val[30:0] + 1) : signed_int_val[30:0];

    // calculate the exponent based on the number of leading zeros in the absolute value
    assign E = |abs_int ? 8'h00 : 127 + shift_amount;

    // shift the absolute value to align with the MSB of the mantissa
    assign M = {1'b1, abs_int[29:8]} >> (31 - E);

    // concatenate S, E, M to form output FP value
    assign FP_val = {signed_int_val[31], E, M};

	// find how much abs_int needed to be shifted to the right for FP normalization
	always begin
		casex(abs_int)
			31'b1xx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx: shift_amount = 5'h1E;
			31'b01x_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx: shift_amount = 5'h1D;
			31'b001_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx: shift_amount = 5'h1C;
			31'b000_1xxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx: shift_amount = 5'h1B;
			31'b000_01xx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx: shift_amount = 5'h1A;
			31'b000_001x_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx: shift_amount = 5'h19;
			31'b000_0001_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx: shift_amount = 5'h18;
			31'b000_0000_1xxx_xxxx_xxxx_xxxx_xxxx_xxxx: shift_amount = 5'h17;
			31'b000_0000_01xx_xxxx_xxxx_xxxx_xxxx_xxxx: shift_amount = 5'h16;
			31'b000_0000_001x_xxxx_xxxx_xxxx_xxxx_xxxx: shift_amount = 5'h15;
			31'b000_0000_0001_xxxx_xxxx_xxxx_xxxx_xxxx: shift_amount = 5'h14;
			31'b000_0000_0000_1xxx_xxxx_xxxx_xxxx_xxxx: shift_amount = 5'h13;
			31'b000_0000_0000_01xx_xxxx_xxxx_xxxx_xxxx: shift_amount = 5'h12;
			31'b000_0000_0000_001x_xxxx_xxxx_xxxx_xxxx: shift_amount = 5'h11;
			31'b000_0000_0000_0001_xxxx_xxxx_xxxx_xxxx: shift_amount = 5'h10;
			31'b000_0000_0000_0000_1xxx_xxxx_xxxx_xxxx: shift_amount = 5'h0F;
			31'b000_0000_0000_0000_01xx_xxxx_xxxx_xxxx: shift_amount = 5'h0E;
			31'b000_0000_0000_0000_001x_xxxx_xxxx_xxxx: shift_amount = 5'h0D;
			31'b000_0000_0000_0000_0001_xxxx_xxxx_xxxx: shift_amount = 5'h0C;
			31'b000_0000_0000_0000_0000_1xxx_xxxx_xxxx: shift_amount = 5'h0B;
			31'b000_0000_0000_0000_0000_01xx_xxxx_xxxx: shift_amount = 5'h0A;
			31'b000_0000_0000_0000_0000_001x_xxxx_xxxx: shift_amount = 5'h09;
			31'b000_0000_0000_0000_0000_0001_xxxx_xxxx: shift_amount = 5'h08;
			31'b000_0000_0000_0000_0000_0000_1xxx_xxxx: shift_amount = 5'h07;
			31'b000_0000_0000_0000_0000_0000_01xx_xxxx: shift_amount = 5'h06;
			31'b000_0000_0000_0000_0000_0000_001x_xxxx: shift_amount = 5'h05;
			31'b000_0000_0000_0000_0000_0000_0001_xxxx: shift_amount = 5'h04;
			31'b000_0000_0000_0000_0000_0000_0000_1xxx: shift_amount = 5'h03;
			31'b000_0000_0000_0000_0000_0000_0000_01xx: shift_amount = 5'h02;
			31'b000_0000_0000_0000_0000_0000_0000_001x: shift_amount = 5'h01;
			31'b000_0000_0000_0000_0000_0000_0000_0001: shift_amount = 5'h00;
			default:	shift_amount = 5'h1F;		// this case means input is 0, don't care this value
		endcase
	end

endmodule
