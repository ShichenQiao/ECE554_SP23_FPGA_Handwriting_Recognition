package FP_special_values;
/*
	Reference: IEEE-754 Floating Point

	0 00000000 00000000000000000000001 = 0000 0001 = 2^−126 × 2^−23 = 2^−149 ≈ 1.4012984643 × 10^−45
													   (smallest positive subnormal number)
	0 00000000 11111111111111111111111 = 007f ffff = 2^−126 × (1 − 2^−23) ≈ 1.1754942107 ×10^−38
													   (largest subnormal number)
	0 00000001 00000000000000000000000 = 0080 0000 = 2^−126 ≈ 1.1754943508 × 10^−38
													   (smallest positive normal number)
	0 11111110 11111111111111111111111 = 7f7f ffff = 2^127 × (2 − 2^−23) ≈ 3.4028234664 × 10^38
													   (largest normal number)
	0 01111111 00000000000000000000001 = 3f80 0001 = 1 + 2^−23 ≈ 1.00000011920928955
													   (smallest number larger than one)
	0 01111110 11111111111111111111111 = 3f7f ffff = 2^-1 * (2 - 2^-23) ≈ 0.999999940395
													   (largest nuber smaller than one)

	0 00000000 00000000000000000000000 = 0000 0000 = 0
	1 00000000 00000000000000000000000 = 8000 0000 = −0
	0 11111111 00000000000000000000000 = 7f80 0000 = infinity
	1 11111111 00000000000000000000000 = ff80 0000 = −infinity

	x 11111111 <if any bit is set>	   = NaN
*/
	localparam [31:0] FP_POS_SUB_MIN = 32'h0000_0001;
	localparam [31:0] FP_POS_SUB_MAX = 32'h007F_FFFF;
	localparam [31:0] FP_POS_MIN = 32'h0080_0000;
	localparam [31:0] FP_POS_MAX = 32'h7F7F_FFFF;

	localparam [31:0] FP_NEG_SUB_MIN = 32'h807F_FFFF;
	localparam [31:0] FP_NEG_SUB_MAX = 32'h8000_0001;
	localparam [31:0] FP_NEG_MIN = 32'hFF7F_FFFF;
	localparam [31:0] FP_NEG_MAX = 32'h8080_0000;

	localparam [31:0] FP_SLT_ONE = 32'h3F80_0001;
	localparam [31:0] FP_LST_ONE = 32'h3F7F_FFFF;
	localparam [31:0] FP_SLT_NEG_ONE = 32'hBF7F_FFFF;
	localparam [31:0] FP_LST_NEG_ONE = 32'hBF80_0001;

	localparam [31:0] FP_POS_ZERO = 32'h0000_0000;
	localparam [31:0] FP_NEG_ZERO = 32'h8000_0000;
	localparam [31:0] FP_POS_INF = 32'h7F80_0000;
	localparam [31:0] FP_NEG_INF = 32'hFF80_0000;

	function bit is_NaN(input logic [31:0] FP_val);
		is_NaN = &FP_val[30:23] && |FP_val[22:0];
	endfunction

	// used for exhaustive testing among special values above
	localparam [31:0] SPECIAL_VALS_ARR [0:15] = '{
		FP_POS_SUB_MIN,
		FP_POS_SUB_MAX,
		FP_POS_MIN,
		FP_POS_MAX,
		FP_NEG_SUB_MIN,
		FP_NEG_SUB_MAX,
		FP_NEG_MIN,
		FP_NEG_MAX,
		FP_SLT_ONE,
		FP_LST_ONE,
		FP_SLT_NEG_ONE,
		FP_LST_NEG_ONE,
		FP_POS_ZERO,
		FP_NEG_ZERO,
		FP_POS_INF,
		FP_NEG_INF
	};
endpackage
