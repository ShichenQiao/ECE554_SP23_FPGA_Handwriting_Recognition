/////////////////////////////////////////////////////////
// Data memory designed for superscalar. It takes control
// signals from two instructions and provides two-port
// read/write. 
/////////////////////////////////////////////////////////
module DM(clk,addr0,addr1,re0,re1,we0,we1,
		  wrt_data0,wrt_data1,rd_data0,rd_data1);
// two inst, either re or we for each
// addr0 before addr1
// addr0 == addr1, we0, re1, rd_data1 <= wrt_data0
// addr0 == addr1, re0, we1, RAM_2p will read old data
// addr0 == addr1, we0, we1, write later one wrt_data1
input clk;
input [12:0] addr0;
input [12:0] addr1;
input re0;						// asserted when instruction0 read desired
input re1;						// asserted when instruction1 read desired
input we0;						// asserted when instruction0 write desired
input we1;						// asserted when instruction1 write desired
input [31:0] wrt_data0;			// data0 to be written
input [31:0] wrt_data1;			// data1 to be written

output reg [31:0] rd_data0;		// output0 of data memory
output reg [31:0] rd_data1;		// output1 of data memory

logic pwren_a;					// processed write enable a
logic [31:0] raw_q_b;			// unprocessed output b

logic same_addr;				// two instructions perform operation
								// on the same address location
assign same_addr = (addr0 == addr1);
// bypass data when write-first-then-read on the same address
assign rd_data1 = same_addr&we0&re1 ? wrt_data0 : raw_q_b;
// turn off wren_a when two writes on the same address
// just write the second data to DM
assign pwren_a = ~(same_addr&we0&we1) & (we0&~re0);

// Thanks Intel.
eightKRAM_2p baKRAM(.address_a(addr0),
					.address_b(addr1),
					.clock(clk),
					.data_a(wrt_data0),
					.data_b(wrt_data1),
					.wren_a(pwren_a),
					.wren_b(we1&~re1),
					.q_a(rd_data0),
					.q_b(raw_q_b));
					
assign 
					


endmodule
