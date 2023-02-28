module umul_16by4_tb();
	logic [15:0] A;			// 16 bit input
	logic [3:0] B;			// 4 bit input
	logic [19:0] OUT;		// the product of A*B

	umul_16by4 iDUT(
		.A(A),
		.B(B),
		.OUT(OUT)
	);

	logic [19:0] O;
	assign O = A * B;
	int randnum;

	initial begin
		A = 16'hFFFF;
		B = 4'hF;
		#1;
		if(OUT !== O) begin
			$display("wrong answer!");
			$stop();
		end

		for(int i = 0; i < 30; i++) begin
			randnum = $random();
			A = randnum[15:0];
			B = randnum[19:16];
			#1;
			if(OUT !== O) begin
				$display("wrong answer!");
				$stop();
			end
		end

		$display("ALL TESTS PASSED!!!");
		$stop();
	end

endmodule
