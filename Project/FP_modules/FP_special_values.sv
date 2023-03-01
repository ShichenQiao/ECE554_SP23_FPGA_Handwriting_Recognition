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

	0 00000000 00000000000000000000000 = 0000 0000 = 0
	1 00000000 00000000000000000000000 = 8000 0000 = −0
	0 11111111 00000000000000000000000 = 7f80 0000 = infinity
	1 11111111 00000000000000000000000 = ff80 0000 = −infinity
*/
	localparam [31:0] FP_POS_SUB_MIN = 32'h0000_0001;
	localparam [31:0] FP_POS_SUB_MAX = 32'h007F_FFFF;
	localparam [31:0] FP_POS_MIN = 32'h0080_0000;
	localparam [31:0] FP_POS_MAX = 32'h7F7F_FFFF;

	localparam [31:0] FP_NEG_SUB_MIN = 32'h807F_FFFF;
	localparam [31:0] FP_NEG_SUB_MAX = 32'h8000_0001;
	localparam [31:0] FP_NEG_MIN = 32'hFF7F_FFFF;
	localparam [31:0] FP_NEG_MAX = 32'h8080_0000;

	localparam [31:0] FP_POS_ZERO = 32'h0000_0000;
	localparam [31:0] FP_NEG_ZERO = 32'h8000_0000;
	localparam [31:0] FP_POS_INF = 32'h7F80_0000;
	localparam [31:0] FP_NEG_INF = 32'hFF80_0000;
endpackage