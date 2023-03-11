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
								
output [9:0] compress_addr;		// pixel address after compression
								// ranging from 0 to 783 (28*28)

logic [13:0] block [0:27];		// 28 14-bit registers which stores
								// the sum of color bits of a block
								
logic [4:0] b_haddr;			// block column address
logic [4:0] b_vaddr;            // block row address
logic we;						// write enable of block regsiters
logic [13:0] block_out;			// block regsiter output

// determine b_haddr and b_vaddr using pix_haddr and pix_vaddr
assign b_haddr = pix_haddr[7:3];
assign b_vaddr = pix_vaddr[7:3];

// determine compress_addr using b_haddr and b_vaddr
assign compress_addr = {5'b0,b_vaddr} * 10'd28 + {5'b0,b_haddr};

// block registers and its write enable signal
// when any pix address is 0xFF, disable write
assign we = ~&pix_haddr & ~&pix_vaddr;
assign block_out = block[b_haddr];
always @(posedge clk)
	if (we)
		block[b_haddr] <= {6'b0,pix_color_in} + block_out;
		


endmodule