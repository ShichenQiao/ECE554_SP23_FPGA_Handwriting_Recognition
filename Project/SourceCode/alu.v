module alu(clk,src0,src1,shamt,func,dst,dst_EX_DM,ov,zr,neg);
///////////////////////////////////////////////////////////
// ALU.  Performs ADD, SUB, AND, NOR, SLL, SRL, or SRA  //
// based on func input.  Provides OV and ZR outputs.   //
// Arithmetic is saturating.                          //
///////////////////////////////////////////////////////
// Encoding of func[2:0] is as follows: //
// 000 ==> ADD
// 001 ==> SUB
// 010 ==> AND
// 011 ==> NOR
// 100 ==> SLL
// 101 ==> SRL
// 110 ==> SRA
// 111 ==> reserved (implemented as LHB)

//////////////////////
// include defines //
////////////////////
`include "common_params.inc"

input clk;
input [31:0] src0,src1;
input [2:0] func;			// selects function to perform
input [4:0] shamt;			// shift amount

output [31:0] dst;			// ID_EX version for branch/jump targets
output reg [31:0] dst_EX_DM;
output ov,zr,neg;

wire [31:0] sum;		// output of adder
wire [31:0] sum_sat;	// saturated sum
wire [31:0] src0_2s_cmp;
wire cin;
wire [31:0] shft_l1,shft_l2,shft_l4,shft_l8,shft_l;		// intermediates for shift left
wire [31:0] shft_r1,shft_r2,shft_r4,shft_r8,shft_r;		// intermediates for shift right

/////////////////////////////////////////////////
// Implement 2s complement logic for subtract //
///////////////////////////////////////////////
assign src0_2s_cmp = (func==SUB) ? ~src0 : src0;	// use 2's comp for sub
assign cin = (func==SUB) ? 1'b1 : 1'b0;					// which is invert and add 1
//////////////////////
// Implement adder //
////////////////////
assign sum = src1 + src0_2s_cmp + cin;
///////////////////////////////
// Now for saturation logic //
/////////////////////////////
assign sat_neg = (src1[31] && src0_2s_cmp[31] && ~sum[31]) ? 1'b1 : 1'b0;
assign sat_pos = (~src1[31] && !src0_2s_cmp[31] && sum[31]) ? 1'b1 : 1'b0;
assign sum_sat = (sat_pos) ? 32'h7FFF_FFFF :
                 (sat_neg) ? 32'h8000_0000 :
				 sum;
				 
assign ov = sat_pos | sat_neg;
				 
///////////////////////////
// Now for left shifter //
/////////////////////////
assign shft_l1 = (shamt[0]) ? {src1[30:0],1'b0} : src1;
assign shft_l2 = (shamt[1]) ? {shft_l1[29:0],2'b00} : shft_l1;
assign shft_l4 = (shamt[2]) ? {shft_l2[27:0],4'h0} : shft_l2;
assign shft_l8 = (shamt[3]) ? {shft_l4[23:0],8'h00} : shft_l4;
assign shft_l = (shamt[4]) ? {shft_l8[15:0],16'h0000} : shft_l8;

////////////////////////////
// Now for right shifter //
//////////////////////////
assign shft_in = (func==SRA) ? src1[31] : 0;
assign shft_r1 = (shamt[0]) ? {shft_in,src1[31:1]} : src1;
assign shft_r2 = (shamt[1]) ? {{2{shft_in}},shft_r1[31:2]} : shft_r1;
assign shft_r4 = (shamt[2]) ? {{4{shft_in}},shft_r2[31:4]} : shft_r2;
assign shft_r8 = (shamt[3]) ? {{8{shft_in}},shft_r4[31:8]} : shft_r4;
assign shft_r = (shamt[4]) ? {{16{shft_in}},shft_r8[31:16]} : shft_r8;

///////////////////////////////////////////
// Now for multiplexing function of ALU //
/////////////////////////////////////////
assign dst = (func==AND) ? src1 & src0 :
			 (func==NOR) ? ~(src1 | src0) :
			 (func==SLL) ? shft_l :
			 ((func==SRL) || (func==SRA)) ? shft_r :
			 (func==LHB) ? {src1[15:0],src0[15:0]} : sum_sat;	 
			 
assign zr = ~|dst;
assign neg = dst[31];

//////////////////////////
// Flop the ALU result //
////////////////////////
always @(posedge clk)
  dst_EX_DM <= dst;

endmodule
