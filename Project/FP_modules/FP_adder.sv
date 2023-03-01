////////////////////////////////////////////////////////
//
// 24-bit single-cycle floating-point adder
// 
// format: 1-bit sign, 8-bit exponent, 23-bit mantissa
// seee_eeee_emmm_mmmm_mmmm_mmmm_mmmm_mmmm
//
/* normalize(S, E, M) function - using shifters to ensure S, E, M
follow FP definitionFP Addition V1 + V2.
1. Shift the smaller number to the right until the exponents of
both numbers are the same. Increment the exponent of the smaller
number after each shift. E' represents the common E (the larger one)
2. Add M of each number as an integer calculation, 
M’ is the result of this step
3. S' is determined by the number with larger abs
4. Vout = normalize(S', E', M') */

///////////////////////////////////////////////////////
module FP_adder(A, B, out);

input [31:0] A;		// FP number A
input [31:0] B;		// FP number B
output [31:0] out;	// FP sum = A + B

logic [7:0] EA, EB;		// 8-bit exponent of A and B
logic [22:0] MA, MB;	// 23-bit mantissa of A and B
logic SA, SB;			// sign of A and B
logic A0, B0;			// set when A is 0 / B is 0

logic [8:0] diff_raw;	// EA - EB, one bit longer for 2's comp result
logic [8:0] diff;		// abs(EA - EB), remains non-negative
logic [4:0] shamt;		// shift amount
logic A_shft;			// set when A is to be shifted, otherwise B

logic [22:0] M_shft;	// shifted mantissa
logic [7:0] common_E;	// common exponent

logic [23:0] cA, cB;	// 2's comp conversion intermediates
logic [24:0] A2c, B2c;	// 2's complement of A and B

logic [24:0] pre_sum;	// 25-bit sum = A2c + B2c
logic [23:0] sum_man;	// mantissa of sum, converted back to unsigned
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
assign A0 = |EA;
assign B0 = |EB;

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

// Shift M with smaller E to the right
// This can cause precision loss
// when diff_raw[15] == 1, EB > EA, so right shift MA
// otherwise, EA > EB, so right shift MB
right_shifter rsht(.In(A_shft ? {1'b1,MA} : {1'b1,MB}),
				   .ShAmt(shamt),
				   .Out(M_shft));
assign common_E = A_shft ? EB : EA;

// 2's comp conversion
assign cA = A_shft ? (A[31] ? ~M_shft + 24'b1 : M_shft)
					 (A[31] ? {1'b0,~MA} + 24'b1 : {1'b1,MA});
assign cB = A_shft ? (B[31] ? {1'b0,~MB} + 24'b1 : {1'b1,MB}) :
					 (B[31] ? ~M_shft + 24'b1 : M_shft);
					 
assign A2c = {A[31],cA};
assign B2c = {B[31],cB};

// 25-bit adder
assign pre_sum = A2c + B2c;
assign sum_man = pre_sum[24] ? ~(pre_sum - 25'b1)[23:0] : pre_sum[23:0];
// two positive number addition results in negative OR
// two negative number addition results in positive
// increment common exponent
assign exp_inc = (~A2c[24] & ~B2c[24] & pre_sum[24]) |
				 (A2c[24] & B2c[24] & ~pre_sum[24]);

// normalization 
always begin
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
		default:	sum_shft = 5'h18;		// should never happen
	endcase
end

assign norm_exp = exp_inc ? common_E + 8'b1 : common_E - {3'b0,sum_shft};
left_shifter lsht(.In(sum_man),
				  .ShAmt(sum_shft),
				  .Out(norm_sum));
assign norm_man = exp_inc ? {1'b1,sum_man[22:1]} : norm_sum[22:0];
assign out = {pre_sum[24],norm_exp,norm_man};

endmodule