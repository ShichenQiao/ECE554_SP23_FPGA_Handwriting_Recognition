////////////////////////////////////////////////////////
//
// Image Compressor
// 
// Designer: Haining QIU
//
// This image compressor takes a 224*224 8-bit image from
// DRAM and compress it into a 28*28 8-bit image by taking
// the average color among an 8*8 block. Within one cycle,
// only one pixel is taken and only one pixel is out.
//
///////////////////////////////////////////////////////
module image_compressor(clk,rst_n,start,pix_color_in,pix_haddr,pix_vaddr,
						pix_color_out,compress_addr,sram_wr);

input clk, rst_n;				// 25MHz clk and rst_n
input start;					// signals a valid pixel input
								// starting from address 0
input [7:0] pix_color_in;		// 8-bit pixel color
input [7:0] pix_haddr;			// pixel column address 0 to 223
input [7:0] pix_vaddr;			// pixel row address 0 to 223

output sram_wr;					// SRAM write enable
output [7:0] pix_color_out;		// 8-bit pixel color output
								// that's averaged from 8*8 block
								
output logic [9:0] compress_addr;	// pixel address after compression
									// ranging from 0 to 783 (28*28)
								
logic clr_block;				// set when current block should be cleared
logic [13:0] accum;				// accumulated sum of a block
logic [13:0] block [0:27];		// 28 14-bit registers which stores
								// the sum of color bits of a block
								
logic [4:0] b_haddr;			// block column address
logic we;						// write enable of block regsiters
logic [13:0] block_out;			// accumulated block output

// compressor address ff & SRAM write enable
assign sram_wr = (&pix_haddr[2:0]) & // enable a write when an end-of-block
				 (&pix_vaddr[2:0]) & // occurs, but not when 0x3FF,0x3FF
				 we &	 			 // or when address exceeds image size
				 ~(compress_addr == 10'd784);

always @(posedge clk, negedge rst_n)
	if (!rst_n)
		compress_addr <= 10'd784;
	else if (start)		// start from 0
		compress_addr <= 10'h000;
	else if (sram_wr)	// increment when current block written to SRAM
		compress_addr <= compress_addr + 10'b1;

// determine b_haddr and b_vaddr using pix_haddr and pix_vaddr
assign b_haddr = pix_haddr[7:3];

// block registers and its write enable signal
// when any pix address is 0xFF, disable write
assign we = ~&pix_haddr & ~&pix_vaddr;
// clear block when both pixel addresses are multiples of 8
assign clr_block = ~|pix_haddr[2:0] & ~|pix_vaddr[2:0];
assign block_out = clr_block ? 14'b0 : block[b_haddr];
assign accum = {6'b0,pix_color_in} + block_out;
// block ff
always @(posedge clk)
	if (we)
		block[b_haddr] <= accum;
		
// compressed average output
assign pix_color_out = accum[13:6];

endmodule