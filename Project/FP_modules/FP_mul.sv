module FP_mul(A, B, OUT);
	// FP format
	// SEEE EEEE EMMM MMMM MMMM MMMM MMMM MMMM
	// value = (-1)^S * 2^(E-127) * (1.M)
	// when |E = 0, value = (-1)^S * 2^(E-127) * (0.M)
	// +0 = 32'h0000_0000, -0 = 32'h8000_0000
	// +INF = 32'h7F80_0000, -INF = 32'hFF80_0000

	input [31:0] A;			// 16 bit input
	input [31:0] B;			// 4 bit input
	output [31:0] OUT;		// the product of A*B

	logic    	 SA, SB, SO;
	logic [7:0]  EA, EB, EO;
	logic [23:0] MA, MB, MO;

	logic [7:0]  EA_eff, EB_eff;

	logic [47:0] prod_M;
	logic have_zero;

	assign have_zero = ~|A[30:0] || ~|B[30:0];

	assign SA = A[31];
	assign SB = B[31];
	assign EA = A[30:23];
	assign EB = B[30:23];

	assign EA_eff = |EA ? EA - 8'd127 : 8'h00;
	assign EB_eff = |EB ? EB - 8'd127 : 8'h00;

	assign MA = {|EA ? 1'b1 : 1'b0, A[22:0]};
	assign MB = {|EB ? 1'b1 : 1'b0, B[22:0]};

	assign SO = SA ^ SB;
	assign EO = have_zero ? 8'h00 : EA_eff + EB_eff + (prod_M[47] ? 8'h01 : 8'h00) + 8'd127;

	assign prod_M = MA * MB;
	assign MO = prod_M[47] ? prod_M[47:24] : prod_M[46:23];

	assign OUT = {SO, EO, MO[22:0]};

endmodule
