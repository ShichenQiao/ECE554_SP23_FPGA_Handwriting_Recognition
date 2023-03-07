module extended_ALU(clk, src0, src1, func, dst_EX_DM, ov, zr, neg);
	// Encoding of func[2:0] is as follows: //
	// 000 ==> MUL
	// 001 ==> UMUL
	// 010 ==> ADDF
	// 011 ==> SUBF
	// 100 ==> MULF
	// 101 ==> ITF
	// 110 ==> FTI
	// 111 ==> undefined

	input clk;
	input [31:0] src0, src1;
	input [2:0] func;				// selects function to perform
	output reg [31:0] dst_EX_DM;
	output ov, zr, neg;

endmodule
