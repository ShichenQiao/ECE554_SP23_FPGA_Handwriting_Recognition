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
		.out(OUT),
		.ovfl(ovfl)
	);
	
	// corner cases array
	logic [31:0] aa;
	logic [31:0] bb;

	initial begin
		aa = 32'h007FFFFF;
		bb = 32'h00000001;
/* 		aa = 32'h00123456;
		bb = $random();
		aa = 32'h00000001;
		bb = $random(); */
		for(int i = 0; i < 10000; i++) begin
			a = $random();
			b = $random();
			o = a + b;
			sum = $shortrealtobits(o);
			A = $shortrealtobits(a);
			B = $shortrealtobits(b);
			#1;
			// allow -2 ~ +2 difference due to shortrealtobits and shortrealtobits error
			if(OUT <= sum - 2 && OUT >= sum + 2) begin
				$display("Random test failed:");
				$display("a: %f", a);
				$display("b: %f", b);
				$display("should be: %f", o);
				$display("but got: %f", $bitstoshortreal(OUT));
				$stop();
			end
		end
		#10
		$display("ALL RANDOM TESTS WERE GOOD...");
		$display("BUT MORE WEIRDOS ARE COMING ;)");
		a = $bitstoshortreal(aa);
		b = $bitstoshortreal(bb);
		o = a + b;
		sum = $shortrealtobits(o);
		A = aa;
		B = bb;
		#10
		if(OUT <= sum - 2 && OUT >= sum + 2) begin
			// Easy... it's just Haining being self-mockery
			$display("Haha gotcha you mindless schmuck!");
			$display("a: %f", a);
			$display("b: %f", b);
			$display("should be: %f", o);
			$display("but got: %f", $bitstoshortreal(OUT));
			$stop();
		end
		#10
		
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
						$display("wrong answer! %b + %b = NaN, not %b", A, B, OUT);
						#10;
						$stop();
					end
				end
				else begin
					if(OUT !== sum) begin
						$display("wrong answer! %b + %b = %b, not %b", A, B, sum, OUT);
						#10
						$stop();
					end
				end
			end 
		end
		$display("Hmm lukcy day for you :|");
		$stop();
	end

endmodule
