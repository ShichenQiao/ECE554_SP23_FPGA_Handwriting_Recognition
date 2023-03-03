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

	logic [47:0] prod_M;
	logic ZERO;
	logic INF;
	logic NaN;
	logic DENORMALIZED;		// a denormalized number times any number <= 1 is denormalized, same when sign is involved

	assign SA = A[31];
	assign SB = B[31];
	assign EA = A[30:23];
	assign EB = B[30:23];

	assign ZERO = ~|A[30:0] || ~|B[30:0];
	assign INF = (&EA && ~|A[22:0]) || (&EB && ~|B[22:0]);
	assign NaN = (&EA && |A[22:0]) || (&EB && |B[22:0]);

	assign MA = {|EA, A[22:0]};			// FP value is denormalized when E = 0
	assign MB = {|EB, B[22:0]};			// FP value is denormalized when E = 0

	assign SO = SA ^ SB;

	assign DENORMALIZED = (~|EA && (EB < 8'd127 || (EB == 8'd127 && ~|B[22:0]))) || (~|EB && (EA < 8'd127 || (EA == 8'd127 && ~|A[22:0])));
	assign EO = DENORMALIZED ? 8'h00 : (EA + EB + (prod_M[47] ? 8'h01 : 8'h00) - 8'd127);

	assign prod_M = MA * MB;
	assign MO = prod_M[47] ? prod_M[47:24] : prod_M[46:23];

	assign OUT = (NaN || (ZERO && INF)) ? {SO, 8'hFF, 23'hFFFFFF} :		// if any of the lower 23 bits is set, value is NaN, so we just pick this one
				 ZERO ? {SO, 8'h00, 23'h000000} :
				 INF ? {SO, 8'hFF, 23'h000000} :
				 {SO, EO, MO[22:0]};

endmodule
