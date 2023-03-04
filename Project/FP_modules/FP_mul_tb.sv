module FP_mul_tb();

	import FP_special_values::*;

	logic [31:0] A;
	logic [31:0] B;
	logic [31:0] OUT;

	shortreal a, b, o;
	int temp;

	logic [31:0] product;

	FP_mul iDUT(
		.A(A),
		.B(B),
		.OUT(OUT)
	);

	initial begin
		/////////////////////////////////////////////////////////////////
		// test multiplication of FP_POS_ZERO with non-special values //
		///////////////////////////////////////////////////////////////
		a = $bitstoshortreal(FP_POS_ZERO);
		A = FP_POS_ZERO;
		b = 1.2345;					// test arbitrary, non-special positive value
		B = $shortrealtobits(b);
		#1;
		if(OUT !== FP_POS_ZERO) begin
			$display("wrong answer!");
			$stop();
		end
		a = -5.4321;				// test arbitrary, non-special negative value
		A = $shortrealtobits(b);
		b = $bitstoshortreal(FP_POS_ZERO);
		B = FP_POS_ZERO;
		#1;
		if(OUT !== FP_POS_ZERO) begin
			$display("wrong answer!");
			$stop();
		end

		/////////////////////////////////////////////////////////////////
		// test multiplication of FP_NEG_ZERO with non-special values //
		///////////////////////////////////////////////////////////////
		a = $bitstoshortreal(FP_NEG_ZERO);
		A = FP_NEG_ZERO;
		b = 1.0101;					// test arbitrary, non-special positive value
		B = $shortrealtobits(b);
		#1;
		if(OUT !== FP_NEG_ZERO) begin
			$display("wrong answer!");
			$stop();
		end
		a = -0.9876;				// test arbitrary, non-special negative value
		A = $shortrealtobits(b);
		b = $bitstoshortreal(FP_NEG_ZERO);
		B = FP_NEG_ZERO;
		#1;
		if(OUT !== FP_NEG_ZERO) begin
			$display("wrong answer!");
			$stop();
		end

		////////////////////////////////////////////////////////////////
		// test multiplication of FP_POS_INF with non-special values //
		//////////////////////////////////////////////////////////////
		a = $bitstoshortreal(FP_POS_INF);
		A = FP_POS_INF;
		b = 3.1415;					// test arbitrary, non-special positive value
		B = $shortrealtobits(b);
		#1;
		if(OUT !== FP_POS_INF) begin
			$display("wrong answer!");
			$stop();
		end
		a = -1.4413;				// test arbitrary, non-special negative value
		A = $shortrealtobits(b);
		b = $bitstoshortreal(FP_POS_INF);
		B = FP_POS_INF;
		#1;
		if(OUT !== FP_POS_INF) begin
			$display("wrong answer!");
			$stop();
		end

		////////////////////////////////////////////////////////////////
		// test multiplication of FP_NEG_INF with non-special values //
		//////////////////////////////////////////////////////////////
		a = $bitstoshortreal(FP_NEG_INF);
		A = FP_NEG_INF;
		b = 7.1234;				// test arbitrary, non-special positive value
		B = $shortrealtobits(b);
		#1;
		if(OUT !== FP_NEG_INF) begin
			$display("wrong answer!");
			$stop();
		end
		a = -8.4633;			// test arbitrary, non-special negative value
		A = $shortrealtobits(b);
		b = $bitstoshortreal(FP_NEG_INF);
		B = FP_NEG_INF;
		#1;
		if(OUT !== FP_NEG_INF) begin
			$display("wrong answer!");
			$stop();
		end

		///////////////////////////////////////////////////////////////////////////////////////////////
		// random tests, note that the chance of a random number being a special value is very low  //
		/////////////////////////////////////////////////////////////////////////////////////////////
		for(int i = 0; i < 1000; i++) begin
			a = $random();
			b = $random();
			o = a * b;
			product = $shortrealtobits(o);
			A = $shortrealtobits(a);
			B = $shortrealtobits(b);
			#1;
			// allow -2 ~ +2 difference (on the LSBs of M) due to shortrealtobits and bitstoshortreal error
			if(OUT[31:23] !== product[31:23] || (OUT[22:0] <= product[22:0] - 2 && OUT[22:0] >= product[22:0] + 2)) begin
				$display("wrong answer!");
				$stop();
			end
		end

		///////////////////////////////////////////////////////////////////////////
		// test overflow (E too large, so that product is around +INF or -INF)  //
		/////////////////////////////////////////////////////////////////////////

		// (+2^64) * (+2^64) = +INF
		A = {1'b0, 8'hBF, 23'h000000};		// +2^64
		B = {1'b0, 8'hBF, 23'h000000};		// +2^64
		#1;
		if(OUT !== FP_POS_INF) begin
			$display("wrong answer!");
			$stop();
		end

		// (+2^127) * (-2) = -INF
		A = {1'b0, 8'hFE, 23'h000000};		// +2^127
		B = {1'b1, 8'hBF, 23'h000000};		// -2
		#1;
		if(OUT !== FP_NEG_INF) begin
			$display("wrong answer!");
			$stop();
		end

		// (-2^100) * (-2^28) = +INF
		A = {1'b1, 8'hE3, 23'h000000};		// -2^100
		B = {1'b1, 8'h9B, 23'h000000};		// -2^28
		#1;
		if(OUT !== FP_POS_INF) begin
			$display("wrong answer!");
			$stop();
		end

		// (1.99999988079) * (+2^127) should not reach +INF
		A = {1'b0, 8'h7F, 23'hFFFFFF};		// largest representable number below 2
		B = {1'b0, 8'hFE, 23'h000000};		// +2^127
		#1;
		if(OUT === FP_POS_INF) begin
			$display("wrong answer!");
			$stop();
		end

		// (-1.99999988079) * (+2^127) should not reach -INF
		A = {1'b1, 8'h7F, 23'hFFFFFF};		// largest representable number (abs value) below 2
		B = {1'b0, 8'hFE, 23'h000000};		// +2^127
		#1;
		if(OUT === FP_NEG_INF) begin
			$display("wrong answer!");
			$stop();
		end

		// when reach +INF, M of out put should be all zero
		A = {1'b0, 8'hBF, 23'h123456};		// +2^64 * 1.<something on zero>
		B = {1'b0, 8'hBF, 23'h789ABC};		// +2^64 * 1.<something on zero>
		#1;
		if(OUT !== FP_POS_INF) begin
			$display("wrong answer!");
			$stop();
		end

		// when reach +INF, M of out put should be all zero, even if <something on zero> is tiny
		A = {1'b0, 8'hBF, 23'h000000};		// +2^64
		B = {1'b0, 8'hBF, 23'h000001};		// +2^64 * 1.00000000000000000000001
		#1;
		if(OUT !== FP_POS_INF) begin
			$display("wrong answer!");
			$stop();
		end

		// when reach -INF, M of out put should be all zero
		A = {1'b0, 8'hBF, 23'hFEDCBA};		// +2^64 * 1.<something on zero>
		B = {1'b1, 8'hBF, 23'h987654};		// -2^64 * 1.<something on zero>
		#1;
		if(OUT !== FP_NEG_INF) begin
			$display("wrong answer!");
			$stop();
		end

		// when reach -INF, M of out put should be all zero, even if <something on zero> is tiny
		A = {1'b1, 8'hBF, 23'h000001};		// -2^64 * 1.00000000000000000000001
		B = {1'b0, 8'hBF, 23'h000000};		// +2^64
		#1;
		if(OUT !== FP_NEG_INF) begin
			$display("wrong answer!");
			$stop();
		end

		/////////////////////////////////////////////////////////////////
		// test all 256 combinations of special value multiplication  //
		///////////////////////////////////////////////////////////////
		for(int i = 0; i < 16; i++) begin
			for(int j = 0; j < 16; j++) begin
				A = SPECIAL_VALS_ARR[i];
				a = $bitstoshortreal(A);
				B = SPECIAL_VALS_ARR[j];
				b = $bitstoshortreal(B);
				o = shortreal'(a * b);
				product = $shortrealtobits(o);
				#1;
				if(is_NaN(product)) begin
					if(!is_NaN(OUT)) begin
						$display("wrong answer! %b * %b = NaN, not %b", A, B, OUT);
						$stop();
					end
				end
				else begin
					// allow -2 ~ +2 difference (on the LSBs of M) due to shortrealtobits and bitstoshortreal error
					if(OUT[31:23] !== product[31:23] || (OUT[22:0] <= product[22:0] - 2 && OUT[22:0] >= product[22:0] + 2)) begin
						// also allow the difference between FP_POS_MIN(1.1754943508 × 10^−38) and 0, same for their negative counterpart, because of shortreal rounding
						if(OUT[31] !== product[31] || (~((product[30:0] === FP_POS_MIN[30:0]) && ~|OUT[30:0]) && ~((OUT[30:0] === FP_POS_MIN[30:0]) && ~|product[30:0]))) begin
							$display("wrong answer! %b * %b = %b, not %b", A, B, product, OUT);
							$stop();
						end
					end
				end
			end
		end

		$display("ALL TESTS PASSED!!!");
		$stop();
	end

endmodule
