module right_shifter(In, ShAmt, Out);

input  [22:0] In; 	// Input operand
input  [4:0] ShAmt;	// Amount to shift/rotate
output [22:0] Out; 	// Result of shift/rotate

wire [22:0] shft_stg1, shft_stg2, shft_stg3, shft_stg4;

assign shft_stg1 = ShAmt[0] ? {1'b0,In[22:1]} : {In};
assign shft_stg2 = ShAmt[1] ? {2'b0,shft_stg1[22:2]} : {shft_stg1};
assign shft_stg3 = ShAmt[2] ? {4'b0,shft_stg2[22:4]} : {shft_stg2};
assign shft_stg3 = ShAmt[3] ? {8'b0,shft_stg2[22:8]} : {shft_stg3};
assign Out = ShAmt[4] ? {16'b0,shft_stg3[22:16]} : {shft_stg4};

endmodule