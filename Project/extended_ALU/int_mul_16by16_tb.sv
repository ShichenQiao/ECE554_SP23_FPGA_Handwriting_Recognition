module int_mul_16by16_tb();

	logic [15:0] A;			// 16 bit integer input
	logic [15:0] B;			// 16 bit integer input
	logic sign;				// signed multiply when set, unsigned multiply when unsigned
	logic [31:0] OUT;		// the product of A*B

	int temp;

	int_mul_16by16 iDUT(
		.A(A),
		.B(B),
		.sign(sign),
		.OUT(OUT)
	);

	initial begin
		// test unsigned multiplication
		sign = 0;
		for(int i = 0; i < 100; i++) begin
			temp = $random();
			A = temp[31:16];
			B = temp[15:0];
			#1;
			if(OUT !== A * B) begin
				$display("wrong answer!");
				$stop();
			end
		end

		// test signed multiplication
		sign = 1;
		for(int i = 0; i < 100; i++) begin
			temp = $random();
			A = temp[31:16];
			B = temp[15:0];
			#1;
			if(signed'(OUT) !== signed'(A) * signed'(B)) begin
				$display("wrong answer!");
				$stop();
			end
		end

		$display("ALL TESTS PASSED!!!");
		$stop();
	end

endmodule