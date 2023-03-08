module FP_mul_tb();

	import FP_special_values::*;

	logic [31:0] A;
	logic [31:0] B;
	logic [31:0] OUT;

	shortreal a, b, o;

	logic [31:0] product;		// expected product of A*B, converted from o

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
			$display("WRONG ANSWER! FP_POS_ZERO times any positive non-INF should be FP_POS_ZERO");
			$stop();
		end
		a = -5.4321;				// test arbitrary, non-special negative value
		A = $shortrealtobits(a);
		b = $bitstoshortreal(FP_POS_ZERO);
		B = FP_POS_ZERO;
		#1;
		if(OUT !== FP_NEG_ZERO) begin
			$display("WRONG ANSWER! FP_POS_ZERO times any negative non-INF should be FP_NEG_ZERO");
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
			$display("WRONG ANSWER! FP_NEG_ZERO times any positive non-INF should be FP_NEG_ZERO");
			$stop();
		end
		a = -0.9876;				// test arbitrary, non-special negative value
		A = $shortrealtobits(a);
		b = $bitstoshortreal(FP_NEG_ZERO);
		B = FP_NEG_ZERO;
		#1;
		if(OUT !== FP_POS_ZERO) begin
			$display("WRONG ANSWER! FP_NEG_ZERO times any negative non-INF should be FP_POS_ZERO");
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
			$display("WRONG ANSWER! FP_POS_INF times any positive non-ZERO should be FP_POS_INF");
			$stop();
		end
		a = -1.4413;				// test arbitrary, non-special negative value
		A = $shortrealtobits(a);
		b = $bitstoshortreal(FP_POS_INF);
		B = FP_POS_INF;
		#1;
		if(OUT !== FP_NEG_INF) begin
			$display("WRONG ANSWER! FP_POS_INF times any negative non-ZERO should be FP_NEG_INF");
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
			$display("WRONG ANSWER! FP_NEG_INF times any positive non-ZERO should be FP_NEG_INF");
			$stop();
		end
		a = -8.4633;			// test arbitrary, non-special negative value
		A = $shortrealtobits(a);
		b = $bitstoshortreal(FP_NEG_INF);
		B = FP_NEG_INF;
		#1;
		if(OUT !== FP_POS_INF) begin
			$display("WRONG ANSWER! FP_NEG_INF times any negative non-ZERO should be FP_POS_INF");
			$stop();
		end

		///////////////////////////////////////////////////////////////////////////////////////////////
		// random tests, note that the chance of a random number being a special value is very low  //
		/////////////////////////////////////////////////////////////////////////////////////////////
		for(int i = 0; i < 1000; i++) begin
			a = $random();						// intentionally not casting to use the 32 random bits as shortreal
			b = $random();						// intentionally not casting to use the 32 random bits as shortreal
			o = a * b;
			product = $shortrealtobits(o);
			A = $shortrealtobits(a);
			B = $shortrealtobits(b);
			#1;
			// allow -2 ~ +2 difference (on the LSBs of M) due to shortrealtobits and bitstoshortreal error
			if((OUT[30:23] !== product[30:23]) ||
			   (signed'({2'b00, OUT[22:0]}) < signed'({2'b00, product[22:0]}) - signed'(25'h000002)) ||
			   (signed'({2'b00, OUT[22:0]}) > signed'({2'b00, product[22:0]}) + signed'(25'h000002))) begin
				$display("WRONG ANSWER! %b * %b = %b, not %b", A, B, product, OUT);
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
			$display("WRONG ANSWER! (+2^64) * (+2^64) = +INF");
			$stop();
		end

		// (+2^127) * (-2) = -INF
		A = {1'b0, 8'hFE, 23'h000000};		// +2^127
		B = {1'b1, 8'hBF, 23'h000000};		// -2
		#1;
		if(OUT !== FP_NEG_INF) begin
			$display("WRONG ANSWER! (+2^127) * (-2) = -INF");
			$stop();
		end

		// (-2^100) * (-2^28) = +INF
		A = {1'b1, 8'hE3, 23'h000000};		// -2^100
		B = {1'b1, 8'h9B, 23'h000000};		// -2^28
		#1;
		if(OUT !== FP_POS_INF) begin
			$display("WRONG ANSWER! (-2^100) * (-2^28) = +INF");
			$stop();
		end

		// (1.99999988079) * (+2^127) should not reach +INF
		A = {1'b0, 8'h7F, 23'hFFFFFF};		// largest representable number below 2
		B = {1'b0, 8'hFE, 23'h000000};		// +2^127
		#1;
		if(OUT === FP_POS_INF) begin
			$display("WRONG ANSWER! 1.99999988079) * (+2^127) should not reach +INF");
			$stop();
		end

		// (-1.99999988079) * (+2^127) should not reach -INF
		A = {1'b1, 8'h7F, 23'hFFFFFF};		// largest representable number (abs value) below 2
		B = {1'b0, 8'hFE, 23'h000000};		// +2^127
		#1;
		if(OUT === FP_NEG_INF) begin
			$display("WRONG ANSWER! (-1.99999988079) * (+2^127) should not reach -INF");
			$stop();
		end

		// when reach +INF, M of out put should be all zero
		A = {1'b0, 8'hBF, 23'h123456};		// +2^64 * 1.<something nonzero>
		B = {1'b0, 8'hBF, 23'h789ABC};		// +2^64 * 1.<something nonzero>
		#1;
		if(OUT !== FP_POS_INF) begin
			$display("WRONG ANSWER! when reach +INF, M of out put should be all zero");
			$stop();
		end

		// when reach +INF, M of out put should be all zero, even if <something nonzero> is tiny
		A = {1'b0, 8'hBF, 23'h000000};		// +2^64
		B = {1'b0, 8'hBF, 23'h000001};		// +2^64 * 1.00000000000000000000001
		#1;
		if(OUT !== FP_POS_INF) begin
			$display("WRONG ANSWER! when reach +INF, M of out put should be all zero");
			$stop();
		end

		// when reach -INF, M of out put should be all zero
		A = {1'b0, 8'hBF, 23'hFEDCBA};		// +2^64 * 1.<something nonzero>
		B = {1'b1, 8'hBF, 23'h987654};		// -2^64 * 1.<something nonzero>
		#1;
		if(OUT !== FP_NEG_INF) begin
			$display("WRONG ANSWER! when reach -INF, M of out put should be all zero");
			$stop();
		end

		// when reach -INF, M of out put should be all zero, even if <something nonzero> is tiny
		A = {1'b1, 8'hBF, 23'h000001};		// -2^64 * 1.00000000000000000000001
		B = {1'b0, 8'hBF, 23'h000000};		// +2^64
		#1;
		if(OUT !== FP_NEG_INF) begin
			$display("WRONG ANSWER! when reach -INF, M of out put should be all zero");
			$stop();
		end

		///////////////////////////////////////////////////////////////////////////
		// test underflow (E too small, so that product is around +/- 2^(-149)  //
		/////////////////////////////////////////////////////////////////////////

		// (+2^(-64)) * (+2^(-86)) = +0 because not representable with 32 bit float
		A = {1'b0, 8'h3F, 23'h000001};		// +2^(-64) * 1.<smallest nonzero M>
		B = {1'b0, 8'h29, 23'h000000};		// +2^(-86)
		#1;
		if(OUT !== FP_POS_ZERO) begin
			$display("WRONG ANSWER! (+2^(-64)) * (+2^(-86)) = +0 because not representable with 32 bit float");
			$stop();
		end

		// (+2^(-38)) * (-2^(-112)) = -0 because not representable with 32 bit float
		A = {1'b0, 8'h59, 23'hFFFFFF};		// +2^(-38) * 1.<largest M>
		B = {1'b1, 8'h0F, 23'hFFFFFF};		// -2^(-112) * 1.<largest M>
		#1;
		if(OUT !== FP_NEG_ZERO) begin
			$display("WRONG ANSWER! (+2^(-38)) * (-2^(-112)) = -0 because not representable with 32 bit float");
			$stop();
		end

		// however, 2^(-149), which is FP_NEG_SUB_MAX, is representable with denormalized format
		A = {1'b0, 8'h59, 23'h000000};		// +2^(-38)
		B = {1'b1, 8'h10, 23'h000000};		// -2^(-111)
		#1;
		if(OUT !== FP_NEG_SUB_MAX) begin
			$display("WRONG ANSWER! 2^(-149), which is FP_NEG_SUB_MAX, is representable with denormalized format");
			$stop();
		end

		// when the precise product is greater than or equal to 2^(-149), but smaller than 2^(−126),
		// the product of two normalized numbers can be denormalized
		A = {1'b0, 8'h01, 23'h000000};		// +2^(-126)
		B = {1'b0, 8'h72, 23'h000000};		// +2^(-13)
		a = $bitstoshortreal(A);
		b = $bitstoshortreal(B);
		o = a * b;
		product = $shortrealtobits(o);
		#1;
		if(OUT !== product) begin
			$display("WRONG ANSWER! the product of two normalized numbers can be denormalized");
			$stop();
		end

		// but M does make a difference on this edge cases, here the answer is denormalized
		A = {1'b1, 8'h01, 23'h123456};		// -2^(-126) * 1.<something nonzero>
		B = {1'b0, 8'h7E, 23'h123456};		// +2^(-1) * 1.<something nonzero>
		a = $bitstoshortreal(A);
		b = $bitstoshortreal(B);
		o = a * b;
		product = $shortrealtobits(o);
		#1;
		// allow -2 ~ +2 difference (on the LSBs of M) due to shortrealtobits and bitstoshortreal error
		if((OUT[30:23] !== product[30:23]) ||
		   (signed'({2'b00, OUT[22:0]}) < signed'({2'b00, product[22:0]}) - signed'(25'h000002)) ||
		   (signed'({2'b00, OUT[22:0]}) > signed'({2'b00, product[22:0]}) + signed'(25'h000002))) begin
    		$display("WRONG ANSWER! the product of two normalized numbers can be denormalized");
			$stop();
		end

		// but with this M, should not denormalize (square root of 2 is the edge)
		A = {1'b1, 8'h01, 23'h123456};		// -2^(-126) * 1.<something nonzero>
		B = {1'b0, 8'h7E, 23'h765432};		// +2^(-1) * 1.<something nonzero>
		a = $bitstoshortreal(A);
		b = $bitstoshortreal(B);
		o = a * b;
		product = $shortrealtobits(o);
		#1;
		if(OUT !== product) begin
			$display("WRONG ANSWER! this produt should not be denormalized");
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
						$display("WRONG ANSWER! %b * %b = NaN, not %b", A, B, OUT);
						$stop();
					end
				end
				else begin		// expected product is not NaN
					// check Sign
					if(OUT[31] !== product[31]) begin
						$display("WRONG ANSWER! %b * %b = %b, not %b", A, B, product, OUT);
						$stop();
					end
					else begin		// S in product is correct
						// allow -2 ~ +2 difference (on the LSBs of M) due to shortrealtobits and bitstoshortreal error
						if((OUT[30:23] === product[30:23]) &&
						   (signed'({2'b00, OUT[22:0]}) >= signed'({2'b00, product[22:0]}) - signed'(25'h000002)) &&
						   (signed'({2'b00, OUT[22:0]}) <= signed'({2'b00, product[22:0]}) + signed'(25'h000002))) begin
							continue;
						end
						// also allow the difference between 2^(-126) and 2^−126 × (1 − 2^−23) due to same conversion error
						if(((OUT[30:0] === FP_POS_MIN[30:0]) && (product[30:0] === FP_POS_SUB_MAX[30:0])) ||
						   ((product[30:0] === FP_POS_MIN[30:0]) && (OUT[30:0] === FP_POS_SUB_MAX[30:0]))) begin
							continue;
						end
						// again, we also have to let 00000000011111111111111111111111 * 00111111100000000000000000000001 and other 7 similar combinations PASS
						// because modelsim round the former value to 00000000100000000000000000000000 and the later to perfect 1, which introduced a new 100% error
						// our answer to the above example, 00000000001111111111111111111111, is more precise per the IEEE definition
						if(((A[30:0] === FP_POS_SUB_MAX[30:0]) && (B[30:0] === FP_SLT_ONE[30:0])) ||
						   ((B[30:0] === FP_POS_SUB_MAX[30:0]) && (A[30:0] === FP_SLT_ONE[30:0]))) begin
							continue;
						end

						// if not fall into any of the 3 categories above, testcase FAILED
						$display("WRONG ANSWER! %b * %b = %b, not %b", A, B, product, OUT);
						$stop();
					end
				end
			end
		end

		$display("ALL TESTS PASSED!!!");
		$stop();
	end

endmodule
