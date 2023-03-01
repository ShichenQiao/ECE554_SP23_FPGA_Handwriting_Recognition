module FP_mul(A, B, OUT);
	// FP format
	// SEEE EEEE EMMM MMMM MMMM MMMM MMMM MMMM
	// value = (-1)^S * 2^(E-127) * (1.M)
	// when |E = 0, value = (-1)^S * 2^(E-127) * (0.M)
	// +0 = 32'h00000000, -0 = 32'h80000000

	input [31:0] A;			// 16 bit input
	input [31:0] B;			// 4 bit input
	output [31:0] OUT;		// the product of A*B

	logic    	 SA, SB, SO;
	logic [7:0] EA, EB, EO;
	logic [23:0] MA, MB, MO;

	logic [47:0] prod_M;

	assign SA = A[31];
	assign SB = B[31];
	assign EA = A[30:23];
	assign EB = B[30:23];
	assign MA = {|EA ? 1'b1 : 1'b0, A[22:0]};
	assign MB = {|EB ? 1'b1 : 1'b0, B[22:0]};

	assign SO = SA ^ SB;
	assign EO = (EA - 8'd127) + (EB - 8'd127) + (prod_M[47] ? 8'h01 : 8'h00) + 8'd127;

	assign prod_M = MA * MB;
	assign MO = prod_M[47] ? prod_M[47:24] : prod_M[46:23];

	assign OUT = {SO, EO, MO[22:0]};

/*
	always begin
		casex(prod_M)
			32'b1xxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx: shift_amount = 6'h00;
			32'b01xx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx: shift_amount = 6'h01;
			32'b001x_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx: shift_amount = 6'h02;
			32'b0001_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx: shift_amount = 6'h03;
			32'b0000_1xxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx: shift_amount = 6'h04;
			32'b0000_01xx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx: shift_amount = 6'h05;
			32'b0000_001x_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx: shift_amount = 6'h06;
			32'b0000_0001_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx: shift_amount = 6'h07;
			32'b0000_0000_1xxx_xxxx_xxxx_xxxx_xxxx_xxxx: shift_amount = 6'h08;
			32'b0000_0000_01xx_xxxx_xxxx_xxxx_xxxx_xxxx: shift_amount = 6'h09;
			32'b0000_0000_001x_xxxx_xxxx_xxxx_xxxx_xxxx: shift_amount = 6'h0A;
			32'b0000_0000_0001_xxxx_xxxx_xxxx_xxxx_xxxx: shift_amount = 6'h0B;
			32'b0000_0000_0000_1xxx_xxxx_xxxx_xxxx_xxxx: shift_amount = 6'h0C;
			32'b0000_0000_0000_01xx_xxxx_xxxx_xxxx_xxxx: shift_amount = 6'h0D;
			32'b0000_0000_0000_001x_xxxx_xxxx_xxxx_xxxx: shift_amount = 6'h0E;
			32'b0000_0000_0000_0001_xxxx_xxxx_xxxx_xxxx: shift_amount = 6'h0F;
			32'b0000_0000_0000_0000_1xxx_xxxx_xxxx_xxxx: shift_amount = 6'h10;
			32'b0000_0000_0000_0000_01xx_xxxx_xxxx_xxxx: shift_amount = 6'h11;
			32'b0000_0000_0000_0000_001x_xxxx_xxxx_xxxx: shift_amount = 6'h12;
			32'b0000_0000_0000_0000_0001_xxxx_xxxx_xxxx: shift_amount = 6'h13;
			32'b0000_0000_0000_0000_0000_1xxx_xxxx_xxxx: shift_amount = 6'h14;
			32'b0000_0000_0000_0000_0000_01xx_xxxx_xxxx: shift_amount = 6'h15;
			32'b0000_0000_0000_0000_0000_001x_xxxx_xxxx: shift_amount = 6'h16;
			32'b0000_0000_0000_0000_0000_0001_xxxx_xxxx: shift_amount = 6'h17;
			32'b0000_0000_0000_0000_0000_0000_1xxx_xxxx: shift_amount = 6'h18;
			32'b0000_0000_0000_0000_0000_0000_01xx_xxxx: shift_amount = 6'h19;
			32'b0000_0000_0000_0000_0000_0000_001x_xxxx: shift_amount = 6'h1A;
			32'b0000_0000_0000_0000_0000_0000_0001_xxxx: shift_amount = 6'h1B;
			32'b0000_0000_0000_0000_0000_0000_0000_1xxx: shift_amount = 6'h1C;
			32'b0000_0000_0000_0000_0000_0000_0000_01xx: shift_amount = 6'h1D;
			32'b0000_0000_0000_0000_0000_0000_0000_001x: shift_amount = 6'h1E;
			32'b0000_0000_0000_0000_0000_0000_0000_0001: shift_amount = 6'h1F;
			default:	shift_amount = 6'h20;		// should never happen
		endcase
	end
*/

endmodule
