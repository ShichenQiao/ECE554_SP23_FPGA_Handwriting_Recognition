module rf(clk,p0_addr,p1_addr,p0,p1,re0,re1,dst_addr,dst,we,hlt);
// This Reg File uses Block SRAM

input clk;
input [3:0] p0_addr, p1_addr;			// two read port addresses
input re0,re1;							// read enables (power not functionality)
input [3:0] dst_addr;					// write address
input [15:0] dst;						// dst bus
input we;								// write enable
input hlt;								// not a functional input.  Used to dump register contents when
										// test is halted.

output reg [15:0] p0,p1;  				//output read ports

integer indx;

////////// 2-READ 1-WRITE RF //////////
reg [15:0] mem0 [1023:0];
reg [15:0] mem1 [1023:0];
// negedge r/w
always @(negedge clk)
	if (we)
		mem0[dst_addr] <= dst;

always @(negedge clk)
	if (we)
		mem1[dst_addr] <= dst;

always @(negedge clk)
	if (re0)
		p0 <= mem0[p0_addr];
		
always @(negedge clk)
	if (re1)
		p1 <= mem1[p1_addr];


//////////////////////////////////////////////////////////
// Register file will come up uninitialized except for //
// register zero which is hardwired to be zero.       //
///////////////////////////////////////////////////////
initial begin
  //$readmemh("",mem0);
  //$readmemh("",mem1);
  mem0[0] = 16'h0000;					// reg0 is always 0
  mem1[0] = 16'h0000;	
end
	
////////////////////////////////////////
// Dump register contents at program //
// halt for debug purposes          //
/////////////////////////////////////
always @(posedge hlt)
  for(indx=1; indx<16; indx = indx+1)
    $display("R%1h = %h",indx,mem0[indx]);
	
endmodule
