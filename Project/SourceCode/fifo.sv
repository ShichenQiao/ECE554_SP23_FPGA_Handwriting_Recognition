// A fifo queue that allows read and write at same time
module fifo(
    input clk,					// 50MHz clk
    input rst_n,				// asynch active low reset
    input w_en,                 // write enable
    input r_en,                 // read enable
    input [7:0] in_data,	    // data to be stored in queue
    output q_full,		        // indicates queue is full
    output q_empty,		        // indicates queue is empty
    output [7:0] out_data,	    // data to be read in queue
    output [3:0] contain_num    // Number of used entires in the queue
);

/////////////////////////////
// Declare reg and wires  //
///////////////////////////
reg [3:0] head_ptr, tail_ptr;  	// Insert into head, pop from tail
reg [7:0] buffer [0:7];        	// 8 entry buffer with 8bits wide data

// When all 8 entries are filled, the lower 3 bits of the pointer will be same, but the highest bit will be different
assign q_full = tail_ptr[2:0] == head_ptr[2:0] && tail_ptr[3] == ~head_ptr[3];
// When head ptr and tail ptr are same, the queue is empty
assign q_empty = tail_ptr == head_ptr;
// Number of used/filled entry in the queue
assign contain_num = head_ptr - tail_ptr;

/////////////////////////////////
// Read data from the buffer  //
///////////////////////////////
assign out_data = buffer[tail_ptr[2:0]]; 	//Constantly output the data from the tail_ptr

///////////////////////////////////
// Write data into the buffer   //
/////////////////////////////////
always_ff @(posedge clk)
  if (w_en && !q_full)
    buffer[head_ptr[2:0]] <= in_data;

///////////////////////////////
// Tail ptr control logic   //
/////////////////////////////
always_ff @(posedge clk, negedge rst_n)
  if (!rst_n)
    tail_ptr <= 4'h0;
  else if (r_en && !q_empty)  		// Increment tail_ptr when read enabled and queue is not empty
    tail_ptr <= tail_ptr + 4'h1;  	// Increment tail_ptr == pop an entry from the queue

///////////////////////////////
// Head ptr control logic   //
/////////////////////////////
always_ff @(posedge clk, negedge rst_n)
  if (!rst_n)
    head_ptr <= 4'h0;
  else if (w_en && !q_full)  		// Increment head ptr when write enabled and queue is not full
    head_ptr <= head_ptr + 4'h1;

endmodule
