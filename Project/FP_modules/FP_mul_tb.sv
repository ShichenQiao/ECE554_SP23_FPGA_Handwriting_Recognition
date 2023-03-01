module FP_mul_tb();
	logic [31:0] A;
	logic [31:0] B;
	logic [31:0] OUT;

	shortreal a, b, o;

	logic [31:0] product;

	FP_mul iDUT(
		.A(A),
		.B(B),
		.OUT(OUT)
	);

	initial begin
		// test +0 and -0
		a = 0;
		b = $random();
		A = $shortrealtobits(a);
		B = $shortrealtobits(b);
		#1;
		if(OUT !== 32'h00000000) begin
			$display("wrong answer!");
			$stop();
		end

		// random tests
		for(int i = 0; i < 100; i++) begin
			a = $random();
			b = $random();
			o = a * b;
			product = $shortrealtobits(o);
			A = $shortrealtobits(a);
			B = $shortrealtobits(b);
			#1;
			// allow -2 ~ +2 difference due to shortrealtobits and shortrealtobits error
			if(OUT <= product - 2 && OUT >= product + 2) begin
				$display("wrong answer!");
				$stop();
			end
		end

		$display("ALL TESTS PASSED!!!");
		$stop();
	end

endmodule
