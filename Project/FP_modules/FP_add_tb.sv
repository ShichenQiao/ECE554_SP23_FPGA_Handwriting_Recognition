////////////////////////////////////////////////////////
//
// 32-bit single-cycle floating-point adder TESTBENCH
// 
// Designer: Justin Qiao, Haining QIU
//
// The floating point format follows IEEE 754 Standard
// Format: 1-bit sign, 8-bit exponent, 23-bit mantissa
// seee_eeee_emmm_mmmm_mmmm_mmmm_mmmm_mmmm
// FP num = (-1)^S * 2^(E-127) * {|E.M}
// When |E = 0, the exponent is denormalized to -126
//
// For details of how this module works, please
// refer to FP_adder_doc or visit our Google Drive
//
///////////////////////////////////////////////////////
// Sincere thanks to Justin for designing such a
// comprehensive and torturing set of corner cases

module FP_add_tb();

	import FP_special_values::*;

	logic [31:0] A;
	logic [31:0] B;
	logic [31:0] OUT;
	logic ovfl;

	logic [31:0] a, b;
	shortreal as, bs, os;
	shortreal o;

	logic [31:0] sum;

	FP_adder iDUT(
		.A(A),
		.B(B),
		.out(OUT)
	);

	real err;


	initial begin
		// One million random tests
		// reduce this number if you wanna quickly proceed to weirdos tests
		for(int i = 0; i < 1000000; i++) begin
			#1;
			a = $random();
			b = $random();
			as = $bitstoshortreal(a);
			bs = $bitstoshortreal(b);
			os = as + bs;
			sum = $shortrealtobits(os);
			A = a;
			B = b;
			#1;
			o = $bitstoshortreal(OUT);
			if(is_NaN(sum)) begin
				if(!is_NaN(OUT)) begin
					$display("SCHMUCK! %b + %b = NaN, not %b", A, B, OUT);
					#10;
					$stop();
				end
			end
			else if (~|sum[30:0]) begin
				if (|OUT[30:0]) begin
					$display("SCHMUCK! %b + %b = 0, not %b", A, B, OUT);
					#10;
					$stop();
				end
			end
			else if (sum === FP_POS_INF) begin
				if (OUT !== FP_POS_INF) begin
					$display("SCHMUCK! %b + %b = +INF, not %b", A, B, OUT);
					#10;
					$stop();
				end
			end
			else if (sum === FP_NEG_INF) begin
				if (OUT !== FP_NEG_INF) begin
					$display("SCHMUCK! %b + %b = -INF, not %b", A, B, OUT);
					#10;
					$stop();
				end
			end
			else begin
				err = (os - o) / os;
				//$display("os: %f", os);
				//$display("o: %f", o);
				#1;
				if ((err < 0 ? -err : err) > 0.0001) begin
					#10;
					$display("Random test failed:");
					$display("a: %x", A);
					$display("b: %x", B);
					$display("should be: %b", sum);
					$display("but got: %b", OUT);
					$stop();
				end
			end
			#1;
			/*
			if(is_NaN(sum)) begin
				if(!is_NaN(OUT)) begin
					$display("SCHMUCK! %b + %b = NaN, not %b", A, B, OUT);
					#10;
					$stop();
				end
			end
			// allow -1 ~ +1 difference due to shortrealtobits and shortrealtobits error
			else if ((OUT < sum - 2 || OUT > sum + 2)) begin
				$display("Random test failed:");
				$display("a: %b", A);
				$display("b: %b", B);
				$display("should be: %b", sum);
				$display("but got: %b", OUT);
				$stop();
			end
			*/
		end
		#10;
		$display("ALL RANDOM TESTS WERE GOOD...");
		$display("BUT MORE WEIRDOS ARE COMING ;)");
		// 256 corner cases (16 special values plus themselves)
		for(int i = 0; i < 16; i++) begin
			for(int j = 0; j < 16; j++) begin
				A = SPECIAL_VALS_ARR[i];
				as = $bitstoshortreal(A);
				B = SPECIAL_VALS_ARR[j];
				bs = $bitstoshortreal(B);
				os = as + bs;
				sum = $shortrealtobits(os);
				#1;
				o = $bitstoshortreal(OUT);
				if(is_NaN(sum)) begin
					if(!is_NaN(OUT)) begin
						$display("SCHMUCK! %b + %b = NaN, not %b", A, B, OUT);
						#10;
						$stop();
					end
				end
				else if (~|sum[30:0]) begin
					if (|OUT[30:0]) begin
						$display("SCHMUCK! %b + %b = 0, not %b", A, B, OUT);
						#10;
						$stop();
					end
				end
				else if (sum === FP_POS_INF) begin
					if (OUT !== FP_POS_INF) begin
						$display("SCHMUCK! %b + %b = +INF, not %b", A, B, OUT);
						#10;
						$stop();
					end
				end
				else if (sum === FP_NEG_INF) begin
					if (OUT !== FP_NEG_INF) begin
						$display("SCHMUCK! %b + %b = -INF, not %b", A, B, OUT);
						#10;
						$stop();
					end
				end
				else begin
					//$display("os: %f", os);
					//$display("o: %f", o);
					err = (os - o) / os;
					#1;
					if ((err < 0 ? -err : err) > 0.0001) begin
						#10;
						$display("Weird test failed:");
						$display("a: %b", A);
						$display("b: %b", B);
						$display("should be: %b", sum);
						$display("but got: %b", OUT);
					end
				end
			end 
		end
		$display("Hmm lukcy day for you :|");
		$stop();
	end

endmodule
