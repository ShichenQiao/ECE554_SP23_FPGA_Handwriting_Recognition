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
	logic REPRESENTABLE;
	logic [4:0] product_trailing_zeros;
	logic [4:0] shift_amount;

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
	assign REPRESENTABLE = DENORMALIZED && (EA > 8'd126 || EB > 8'd126);
	assign shift_amount = product_trailing_zeros + 5'h01;

	assign EO = DENORMALIZED ? (REPRESENTABLE ? (|EA ? EA - shift_amount : EB - shift_amount) : 8'h00) : (EA + EB + (prod_M[47] ? 8'h01 : 8'h00) - 8'd127);

	assign prod_M = MA * MB;
	assign MO = DENORMALIZED ? (REPRESENTABLE ? prod_M[47:24] : 23'h000000) :
				prod_M[47] ? prod_M[47:24] : prod_M[46:23];

	always_comb begin
		casex(prod_M[47:24])
			24'b1xxx_xxxx_xxxx_xxxx_xxxx_xxxx: product_trailing_zeros = 5'h00;
			24'b01xx_xxxx_xxxx_xxxx_xxxx_xxxx: product_trailing_zeros = 5'h01;
			24'b001x_xxxx_xxxx_xxxx_xxxx_xxxx: product_trailing_zeros = 5'h02;
			24'b0001_xxxx_xxxx_xxxx_xxxx_xxxx: product_trailing_zeros = 5'h03;
			24'b0000_1xxx_xxxx_xxxx_xxxx_xxxx: product_trailing_zeros = 5'h04;
			24'b0000_01xx_xxxx_xxxx_xxxx_xxxx: product_trailing_zeros = 5'h05;
			24'b0000_001x_xxxx_xxxx_xxxx_xxxx: product_trailing_zeros = 5'h06;
			24'b0000_0001_xxxx_xxxx_xxxx_xxxx: product_trailing_zeros = 5'h07;
			24'b0000_0000_1xxx_xxxx_xxxx_xxxx: product_trailing_zeros = 5'h08;
			24'b0000_0000_01xx_xxxx_xxxx_xxxx: product_trailing_zeros = 5'h09;
			24'b0000_0000_001x_xxxx_xxxx_xxxx: product_trailing_zeros = 5'h0A;
			24'b0000_0000_0001_xxxx_xxxx_xxxx: product_trailing_zeros = 5'h0B;
			24'b0000_0000_0000_1xxx_xxxx_xxxx: product_trailing_zeros = 5'h0C;
			24'b0000_0000_0000_01xx_xxxx_xxxx: product_trailing_zeros = 5'h0D;
			24'b0000_0000_0000_001x_xxxx_xxxx: product_trailing_zeros = 5'h0E;
			24'b0000_0000_0000_0001_xxxx_xxxx: product_trailing_zeros = 5'h0F;
			24'b0000_0000_0000_0000_1xxx_xxxx: product_trailing_zeros = 5'h10;
			24'b0000_0000_0000_0000_01xx_xxxx: product_trailing_zeros = 5'h11;
			24'b0000_0000_0000_0000_001x_xxxx: product_trailing_zeros = 5'h12;
			24'b0000_0000_0000_0000_0001_xxxx: product_trailing_zeros = 5'h13;
			24'b0000_0000_0000_0000_0000_1xxx: product_trailing_zeros = 5'h14;
			24'b0000_0000_0000_0000_0000_01xx: product_trailing_zeros = 5'h15;
			24'b0000_0000_0000_0000_0000_001x: product_trailing_zeros = 5'h16;
			24'b0000_0000_0000_0000_0000_0001: product_trailing_zeros = 5'h17;
			default:	product_trailing_zeros = 5'h18;		// should never happen
		endcase
	end

	assign OUT = (NaN || (ZERO && INF)) ? {SO, 8'hFF, 23'hFFFFFF} :		// if any of the lower 23 bits is set, value is NaN, so we just pick this one
				 ZERO ? {SO, 8'h00, 23'h000000} :
				 INF ? {SO, 8'hFF, 23'h000000} :
				 {SO, EO, MO[22:0]};

endmodule
