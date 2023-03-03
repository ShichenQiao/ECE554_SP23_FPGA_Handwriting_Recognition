////////////////////////////////////////////////////////
//
// 32-bit single-cycle floating-point adder
// 
// Designer: Haining QIU
//
// The floating point format follows IEEE 754 Standard
// Format: 1-bit sign, 8-bit exponent, 23-bit mantissa
// seee_eeee_emmm_mmmm_mmmm_mmmm_mmmm_mmmm
// FP num = (-1)^S * 2^(E-127) * {|E.M}
// When |E = 0, the exponent is denormalized to -126
//
// For details of how this module works, please
// refer to FP_adder_doc or visit our Google Drive
//
///////////////////////////////////////////////////////
module FP_adder(A, B, out);

input [31:0] A;		// FP number A
input [31:0] B;		// FP number B
output [31:0] out;	// FP sum = A + B

logic [7:0] EA, EB;		// 8-bit exponent of A and B
logic [22:0] MA, MB;	// 23-bit mantissa of A and B
logic SA, SB;			// sign of A and B
logic A0, B0;			// set when A/B represents 0
						// note 0x00000000 and 0x80000000
						// are both +0 and -0

logic [8:0] diff_raw;	// EA - EB, one bit longer for 2's comp
logic [8:0] diff;		// abs(EA - EB), remains non-negative
logic [4:0] shamt;		// shift amount
logic A_shft;			// set when A is to be shifted
						// otherwise B is to be shifted

logic [23:0] M_shft;	// shifted mantissa
logic [7:0] common_E;	// common exponent

logic [23:0] cA, cB;	// 2's comp conversion intermediates
logic [24:0] A2c, B2c;	// 2's complement of A and B

logic [24:0] pre_sum;	// 25-bit sum = A2c + B2c
logic [24:0] shft_sum;	// 25-bit shifted pre_sum
logic [24:0] shft_temp;	// 25-bit shifted inverted temp
logic [23:0] sum_man;	// mantissa of sum, back to unsigned
logic [23:0] norm_sum;	// normalized sum {1,mantissa}
logic [22:0] norm_man;	// normalized mantissa
logic [7:0] norm_exp;	// normalized exponent
logic exp_inc;			// signal for exponent increment
logic [4:0] sum_shft;	// normalization shift amount


assign SA = A[31];
assign SB = B[31];
assign EA = A[30:23];
assign EB = B[30:23];
assign MA = A[22:0];
assign MB = B[22:0];
assign A0 = |A[30:0];
assign B0 = |B[30:0];

// Compare EA and EB
// 2's comp signed exponent diff
assign diff_raw = {1'b0,EA} - {1'b0,EB};
// which one is to be shifted?
assign A_shft = diff_raw[8];
// abs value of diff
assign diff = A_shft ?
	 (~diff_raw + 9'b1) : diff_raw;
// shift amount
assign shamt = diff[4:0];

// Append |E in front of M and then
// shift M with smaller E to the right
// This can cause precision loss
// when diff_raw[8] == 1, EB > EA, so right shift MA
// otherwise, EA > EB, so right shift MB
right_shifter rsht(.In(A_shft ? {|EA,MA} : {|EB,MB}),
				   .ShAmt(shamt),
				   .Out(M_shft));
assign common_E = A_shft ? EB : EA;

// 2's comp conversion
assign cA = A_shft ? (A[31] ? ~M_shft + 24'b1 : M_shft) :
					 (A[31] ? ~{1'b1,MA} + 24'b1 : {1'b1,MA});
assign cB = A_shft ? (B[31] ? ~{1'b1,MB} + 24'b1 : {1'b1,MB}) :
					 (B[31] ? ~M_shft + 24'b1 : M_shft);
// 25-bit 2's comp values with common exponent		 
assign A2c = {A[31],cA};
assign B2c = {B[31],cB};

// 25-bit adder
assign pre_sum = A2c + B2c;
// two positive number addition results in negative OR
// two negative number addition results in positive
// increment common exponent
assign exp_inc = (~A2c[24] & ~B2c[24] & pre_sum[24]) |
				 (A2c[24] & B2c[24] & ~pre_sum[24]);
assign shft_sum = exp_inc ?	// overflowed?
			{~pre_sum[24],pre_sum[24:1]} : pre_sum;
// Convert 25-bit 2's comp back into 25-bit signed number
// {sign,24-bit unsigned}
// sum_man holds the 24-bit unsigned value
assign shft_temp = ~(shft_sum - 25'b1);
assign sum_man = shft_sum[24] ?	// is this sum negative?
			shft_temp[23:0] : shft_sum[23:0];

// big case to determine the number of leading zero(s)
always_comb begin
	casex(sum_man)
		24'b1xxx_xxxx_xxxx_xxxx_xxxx_xxxx: sum_shft = 5'h00;
		24'b01xx_xxxx_xxxx_xxxx_xxxx_xxxx: sum_shft = 5'h01;
		24'b001x_xxxx_xxxx_xxxx_xxxx_xxxx: sum_shft = 5'h02;
		24'b0001_xxxx_xxxx_xxxx_xxxx_xxxx: sum_shft = 5'h03;
		24'b0000_1xxx_xxxx_xxxx_xxxx_xxxx: sum_shft = 5'h04;
		24'b0000_01xx_xxxx_xxxx_xxxx_xxxx: sum_shft = 5'h05;
		24'b0000_001x_xxxx_xxxx_xxxx_xxxx: sum_shft = 5'h06;
		24'b0000_0001_xxxx_xxxx_xxxx_xxxx: sum_shft = 5'h07;
		24'b0000_0000_1xxx_xxxx_xxxx_xxxx: sum_shft = 5'h08;
		24'b0000_0000_01xx_xxxx_xxxx_xxxx: sum_shft = 5'h09;
		24'b0000_0000_001x_xxxx_xxxx_xxxx: sum_shft = 5'h0A;
		24'b0000_0000_0001_xxxx_xxxx_xxxx: sum_shft = 5'h0B;
		24'b0000_0000_0000_1xxx_xxxx_xxxx: sum_shft = 5'h0C;
		24'b0000_0000_0000_01xx_xxxx_xxxx: sum_shft = 5'h0D;
		24'b0000_0000_0000_001x_xxxx_xxxx: sum_shft = 5'h0E;
		24'b0000_0000_0000_0001_xxxx_xxxx: sum_shft = 5'h0F;
		24'b0000_0000_0000_0000_1xxx_xxxx: sum_shft = 5'h10;
		24'b0000_0000_0000_0000_01xx_xxxx: sum_shft = 5'h11;
		24'b0000_0000_0000_0000_001x_xxxx: sum_shft = 5'h12;
		24'b0000_0000_0000_0000_0001_xxxx: sum_shft = 5'h13;
		24'b0000_0000_0000_0000_0000_1xxx: sum_shft = 5'h14;
		24'b0000_0000_0000_0000_0000_01xx: sum_shft = 5'h15;
		24'b0000_0000_0000_0000_0000_001x: sum_shft = 5'h16;
		24'b0000_0000_0000_0000_0000_0001: sum_shft = 5'h17;
		default:	sum_shft = 5'h18;	// should never happen
	endcase
end
// if the 25-bit sum overflows, increment the exponent
// otherwise decrement exponent by the number of
// leading zero(s) of the 24-bit unsigned number sum_man
assign norm_exp = exp_inc ? // increment exponent?
			common_E + 8'b1 : common_E - {3'b0,sum_shft};
left_shifter lsht(.In(sum_man),
				  .ShAmt(sum_shft),
				  .Out(norm_sum));
// normalized mantissa is lower 23-bit of the unsigned number
// note that these two number should be the same
// but just to be safe...
assign norm_man = exp_inc ? sum_man[23:1] : norm_sum[22:0];
// final output concatination
assign out = {pre_sum[24],norm_exp,norm_man};

endmodule