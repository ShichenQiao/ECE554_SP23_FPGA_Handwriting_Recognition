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

	parameter WEIRD = 3;
	logic [31:0] A;
	logic [31:0] B;
	logic [31:0] OUT;
	logic ovfl;

	shortreal a, b, o;

	logic [31:0] sum;

	FP_adder iDUT(
		.A(A),
		.B(B),
		.out(OUT)
	);

	initial begin
		// One million random tests
		// reduce this number if you wanna quickly proceed to weirdos tests
		for(int i = 0; i < 1000000; i++) begin
			a = $random();
			b = $random();
			o = a + b;
			sum = $shortrealtobits(o);
			A = $shortrealtobits(a);
			B = $shortrealtobits(b);
			#1;
			// allow -1 ~ +1 difference due to shortrealtobits and shortrealtobits error
			if (OUT <= sum - 1 && OUT >= sum + 1) begin
				$display("Random test failed:");
				$display("a: %b", A);
				$display("b: %b", B);
				$display("should be: %b", sum);
				$display("but got: %b", OUT);
				$stop();
			end
		end
		#10
		$display("ALL RANDOM TESTS WERE GOOD...");
		$display("BUT MORE WEIRDOS ARE COMING ;)");
		// 256 corner cases (16 special values plus themselves)
		for(int i = 0; i < 16; i++) begin
			for(int j = 0; j < 16; j++) begin
				A = SPECIAL_VALS_ARR[i];
				a = $bitstoshortreal(A);
				B = SPECIAL_VALS_ARR[j];
				b = $bitstoshortreal(B);
				o = shortreal'(a + b);
				sum = $shortrealtobits(o);
				#1;
				if(is_NaN(sum)) begin
					if(!is_NaN(OUT)) begin
						$display("SCHMUCK! %b + %b = NaN, not %b", A, B, OUT);
						#10;
						$stop();
					end
				end
				else begin
					// allow -1 ~ +1 difference on {E,M}
					// since they represent the same number (extremely close)
					if((OUT[31] !== sum[31] ||
					  (OUT[30:0] <= sum[30:0] - 1 && OUT[30:0] >= sum[30:0] + 1)) &&
					  ~(OUT[30:0]===31'b0&&sum[30:0]===31'b0)) /* pos zero and neg zero are the same */
					begin
						// Easy... it's just Haining being self-mockery
						$display("Haha gotcha you MINDLESS SCHMUCK!");
						$display("a: %b", A);
						$display("b: %b", B);
						$display("should be: %b", sum);
						$display("but got: %b", OUT);
						#10;
						$stop();
					end
				end
			end 
		end
		$display("Hmm lukcy day for you :|");
		$stop();
	end

endmodule
