module DM(clk,addr,re,we,wrt_data,rd_data,
		  mm_re, mm_we);

/////////////////////////////////////////////////////////
// Data memory.  Single ported, can read or write but //
// not both in a single cycle.  Precharge on clock   //
// high, read/write on clock low.                   //
/////////////////////////////////////////////////////
input clk;
input [15:0] addr;
input re;				// asserted when instruction read desired
input we;				// asserted when write desired
input [15:0] wrt_data;	// internal data to be written

output reg [15:0] rd_data;	// internal output of data memory

reg [15:0]data_mem[0:8191];

output mm_re, mm_we;
wire DM_we; // external enables and internal write enable

assign mm_re = |addr[15:13] & re;
assign mm_we = |addr[15:13] & we;
assign DM_we = ~|addr[15:13] & we;

///////////////////////////////////////////////
// Model read, data is latched on clock low //
/////////////////////////////////////////////
always @(negedge clk)
  if (re && ~DM_we) // change to qualified internal write enable
    rd_data <= data_mem[addr];
	
	
////////////////////////////////////////////////
// Model write, data is written on clock low //
//////////////////////////////////////////////
always @(negedge clk)
  if (DM_we && ~re)
    data_mem[addr] <= wrt_data;

endmodule