module umul_16by4(A, B, OUT);

	input [15:0] A;			// 16 bit input
	input [3:0] B;			// 4 bit input
	output [19:0] OUT;		// the product of A*B

	logic [19:0] out0, out1, out2, out3;			// intermediate values

	assign out0 = B[0] ? {4'b0000, A} : 20'h00000;
	assign out1 = B[1] ? {3'b000, A, 1'b0} : 20'h00000;
	assign out2 = B[2] ? {2'b00, A, 2'b00} : 20'h00000;
	assign out3 = B[3] ? {1'b0, A, 3'b000} : 20'h00000;

	assign OUT = (out0 + out1) + (out2 + out3);

endmodule
