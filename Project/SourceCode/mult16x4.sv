module mult16x4(
  input [15:0] A,
  input [3:0]  B,
  output [19:0] Y
  );
wire [19:0] A_0, A_1, A_3, A_4;

assign A_0 = B[0] ? {4'h0,A} : 20'h00000;
assign A_1 = B[1] ? {3'h0,A,1'b0} : 20'h00000;
assign A_2 = B[2] ? {2'h0,A,2'h0} : 20'h00000;
assign A_3 = B[3] ? {1'h0,A,3'h0} : 20'h00000;

assign Y = A_0 + A_1 + A_3 + A_4;
endmodule

