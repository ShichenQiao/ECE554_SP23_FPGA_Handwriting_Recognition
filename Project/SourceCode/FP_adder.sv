////////////////////////////////////////////////////////
//
// 32-bit single-cycle floating-point adder
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

logic [7:0] diff_raw;	// EA - EB
logic [7:0] diff;		// abs(EA - EB), remains non-negative
logic [3:0] shamt;		// shift amount
logic A_small;			// set when A is to be shifter, otherwise B

logic [22:0] M_shft;	// shifted mantissa
logic [7:0] common_E;	// common exponent

logic [23:0] cMA, cMB;	// 2's comp conversion intermediates
logic [24:0] A2c, B2c;	// 2's complement of {1,MA} and {1,MB}

logic [24:0] pre_sum;	// 25-bit sum = A2c + B2c

assign SA = A[31];
assign SB = B[31];
assign EA = A[30:23];
assign EB = B[30:23];
assign MA = A[22:0];
assign MB = B[22:0];

// Compare EA and EB
// signed exponent diff
assign diff_raw = EA - EB;
// which one is smaller and to be shifted?
assign A_small = diff_raw[7];
// abs value of diff
assign diff = A_small ?
	 (~diff_raw + 8'h01) : diff_raw;
// shift amount
assign shamt = diff[4:0];

// Shift M with smaller E to the right
// This can cause precision loss
// when diff_raw[15] == 1, EB > EA, so right shift MA
// otherwise, EA > EB, so right shift MB
right_shifter rsht(.In(A_small ? MA : MB),
				   .ShAmt(shamt),
				   .Out(M_shft));
assign common_E = A_small ? EB : EA;

// 2's comp conversion
assign cMA = A[31] ?  {1'b0,~MA} + 24'b1 : {1'b1,MA};
assign cMB = B[31] ?  {1'b0,~MB} + 24'b1 : {1'b1,MB};
assign A2c = {A[31],cMA};
assign B2c = {B[31],cMB};

// 25-bit adder
assign pre_sum = A2c + B2c;


// normalization 


endmodule