// 8-bit 1920-stage shift register with 3 taps

module grey_buffer
#(parameter WIDTH=12, parameter TAPDIST=640, parameter LENGTH=640*3)
(
	input clk, rst, enable, iEdge,
	input [WIDTH-1:0] sr_in,
	output [WIDTH-1:0] sr_tap_one, sr_tap_two, sr_out,
	output valid, oEdge
);

	// Declare the shift register
	reg [WIDTH+1:0] sr [LENGTH-1:0];

	// Declare an iterator
	integer n;

	always @ (posedge clk or negedge rst)
	begin
		if (~rst)
		begin
			for (n = 0; n<LENGTH; n = n+1)
			begin
				sr[n] <= 0;
			end
		end
		else
		begin
			if (enable == 1'b1)
			begin
				// Shift everything over, load the incoming data
				for (n = LENGTH-1; n>0; n = n-1)
				begin
					sr[n] <= sr[n-1];
				end

				// Shift one position in
				sr[0] <= {1'b1,~iEdge,sr_in};
			end
		end
	end

	assign sr_tap_one = sr[TAPDIST-1][WIDTH-1:0];
	assign sr_tap_two = sr[2*TAPDIST-1][WIDTH-1:0];

	// Catch the outgoing data
	assign sr_out = sr[LENGTH-1][WIDTH-1:0];
	assign oEdge = sr[2*TAPDIST-1][WIDTH];
	assign valid = sr[LENGTH-1][WIDTH+1];

endmodule
