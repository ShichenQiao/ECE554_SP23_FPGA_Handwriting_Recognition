module DM(clk,addr,re,we,wrt_data,rd_data,SW,LEDR);

/////////////////////////////////////////////////////////
// Data memory.  Single ported, can read or write but //
// not both in a single cycle.  Precharge on clock   //
// high, read/write on clock low.                   //
/////////////////////////////////////////////////////
input clk;
input [15:0] addr;
input re;				// asserted when instruction read desired
input we;				// asserted when write desired
input [15:0] wrt_data;	// data to be written

input [9:0] SW;
output reg [9:0] LEDR;

output reg [15:0] rd_data;	//output of data memory

reg [15:0]data_mem[0:8191];

///////////////////////////////////////////////
// Model read, data is latched on clock low //
/////////////////////////////////////////////
always @(addr,re,clk)
  if (~clk && re && ~we)
	if (~|addr[15:13])
      rd_data <= data_mem[addr];
	else if (addr == 16'hC001)
	  rd_data <= {6'b000000, SW};
	
////////////////////////////////////////////////
// Model write, data is written on clock low //
//////////////////////////////////////////////
always @(addr,we,clk)
  if (~clk && we && ~re)
	if (~|addr[15:13])
      data_mem[addr] <= wrt_data;
	else if (addr == 16'hC000)
	  LEDR <= wrt_data[9:0];

endmodule
