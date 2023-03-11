module extended_ALU(clk, src1, src0, func, dst_EX_DM, ov, zr, neg);
	// Encoding of func[2:0] is as follows: //
	// 000 ==> MUL
	// 001 ==> UMUL
	// 010 ==> ADDF
	// 011 ==> SUBF
	// 100 ==> MULF
	// 101 ==> ITF
	// 110 ==> FTI
	// 111 ==> undefined

	`include "common_params.inc"

	input clk;
	input [31:0] src1, src0;
	input [2:0] func;				// selects function to perform
	output reg [31:0] dst_EX_DM;
	output ov, zr, neg;

	logic [31:0] ifadd_OUT, ifmul_OUT, iftoi_OUT, iitof_OUT, iimul_OUT;

	logic [31:0] OUT;

	///////////////////////
	// compute modules  //
	/////////////////////

	FP_adder ifadd(
		.A(src1),
		.B(func==SUBF ? {~src0[31], src0[30:0]} : src0),	// flip second operand if doing A - B
		.out(ifadd_OUT)
	);

	FP_mul ifmul(
		.A(src1),
		.B(src0),
		.OUT(ifmul_OUT)
	);

	float_to_signed_int iftoi(
		.FP_val(src1),
		.signed_int_val(iftoi_OUT)
	);

	signed_int_to_float iitof(
		.signed_int_val(src1),
		.FP_val(iitof_OUT)
	);

	int_mul_16by16 iimul(
		.A(src1),
		.B(src0),
		.sign(~func[0]),			// 0 ==> MUL 1 ==> UMUL
		.OUT(iimul_OUT)
	);

	///////////////////////////////////
	// Multiplexing function of ALU //
	/////////////////////////////////
	assign OUT = (func==MUL || func==UMUL) ? iimul_OUT :
				 (func==ADDF || func==SUBF) ? ifadd_OUT :
				 (func==MULF) ? ifmul_OUT :
				 (func==ITF) ? iitof_OUT :
				 (func==FTI) ? iftoi_OUT :
				 32'hDEADDEAD;		// undefined behavior

	/////////////////////////
	// Set flag variables //
	///////////////////////
	// these 7 instructions can NEVER overflow (FP operations are saturating following their own rules)
	assign ov = 1'b0;
	
	// assign zero flag according to if output is in normal format or FP format
	assign zr = (func==MUL || func==UMUL || func==FTI) ? ~|OUT : ~|OUT[30:0];

	// assign neg flag according to if output is signed or unsigned
	assign neg = (func==UMUL) ? 1'b0 : OUT[31];

	//////////////////////////
	// Flop the ALU result //
	////////////////////////
	always @(posedge clk)
		dst_EX_DM <= OUT;

endmodule
