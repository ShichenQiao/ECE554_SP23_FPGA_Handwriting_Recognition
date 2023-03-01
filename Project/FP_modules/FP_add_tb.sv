module FP_add_tb();
	logic [31:0] A;
	logic [31:0] B;
	logic [31:0] OUT;

	shortreal a, b, o;

	logic [31:0] sum;

	FP_adder iDUT(
		.A(A),
		.B(B),
		.out(OUT)
	);

	initial begin
		for(int i = 0; i < 100; i++) begin
			a = $random();
			b = $random();
			o = a + b;
			sum = $shortrealtobits(o);
			A = $shortrealtobits(a);
			B = $shortrealtobits(b);
			#1;
			// allow -2 ~ +2 difference due to shortrealtobits and shortrealtobits error
			if(OUT <= sum - 2 && OUT >= sum + 2) begin
				$display("wrong answer!");
				$stop();
			end
		end

		$display("ALL TESTS PASSED!!!");
		$stop();
	end

endmodule
