//////////////////////////////////////////////////////////////////////////////////
// Company: 	UW-Madison
// Engineer: 	Justin Qiao, Harry Zhao
// 
// Create Date:   2/21/2023
// Design Name:    SPART
// Module Name:    spart 
// Project Name:   MiniLab1
// Target Devices: DE1_SOC board
// Tool versions: Unknown
// Description: The spart module extends based on UART protocol. It has a rx buffer and tx buffer
//              to provide the ability of queuing multiple send/recieve requests.
//
// Dependencies: UART_tx, UART_rx, fifo
//
// Revision: 
// Revision 0.01 - File Created
// Revision 1.01 - File Finished
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module spart(
    input clk,				// 50MHz clk
    input rst_n,			// asynch active low reset
    input iocs_n,			// active low chip select (decode address range)
    input iorw_n,			// high for read, low for write
    output tx_q_full,		// indicates transmit queue is full
    output rx_q_empty,		// indicates receive queue is empty
    input [1:0] ioaddr,		// Read/write 1 of 4 internal 8-bit registers
    inout [7:0] databus,	// bi-directional data bus
    output TX,				// UART TX line
    input RX				// UART RX line
);

	/////////////////////////////
	// Declare reg and wires  //
	///////////////////////////
	reg  [12:0] div_buffer;              // Store the division buffer for baud rate control
	wire [7:0] out_data;                 // Data sent to the processor, assigned based on the address
	wire [7:0] rx_data;                  // Data from receiver
	wire [7:0] rx_q_data;                // Data from RX buffer
	wire [7:0] tx_data;                  // Data to transmiter
	wire [3:0] tx_empty_num;             // Number of empty entries in tx queue
	wire [3:0] rx_used_num, tx_used_num; // Number of filled/used enttries in rx queue and tx queue
	wire trmt;                           // Starts transmit in UART_TX
	wire tx_q_empty;                     // TX queue empty
	wire tx_done;                        // UART_TX finished transmiting an 8bits data
	wire rx_rdy;						 // UART_RX received a byte
	wire tx_q_we;						 // write enable of TX buffer
	wire rx_q_re;						 // read enable of RX buffer

	// Calculate tx_empty_num by subtracting tx_used num from 8, need 4 bits to avoid overflow
	assign tx_empty_num = 4'h8 - tx_used_num;

	// Databus flow control. If chip is enabled(chip select) and read enabled, then assign the read data to databus.
	// Otherwise, keep the data bus on high z to receive data.
	assign databus = !iocs_n && iorw_n ? out_data : 8'hz; 

	// Function for each ioaddr:
	// 00 : Transmit Buffer (IOR/W = 0) Receive Buffer (IOR/W=1)
	// 01 : Status Register (IOR/W = 1)
	// 10 : DB(Low) Division Buffer
	// 11 : DB(High) Division Buffer
	assign out_data = ioaddr[1] ? (ioaddr[0] ? {3'h0,div_buffer[12:8]} :    // Read higher bits from division buffer
					  div_buffer[7:0]) :                                    // Read lower bits from division buffer
					  ioaddr[0] ? {tx_empty_num, rx_used_num} :             // Read Status Register
					  rx_q_data;                                            // Read data from Receive Buffer
		

	///////////////////////////////////
	// Write into Division Buffer   //
	/////////////////////////////////
	always_ff @(posedge clk, negedge rst_n) begin
	  if (!rst_n)
		div_buffer <= 13'h01B2;			// default baud rate is 115200
	  else if (ioaddr == 2'b10 && !iocs_n && !iorw_n) 		// Write into the lower bits of div_buffer
		div_buffer <= {div_buffer[12:8],databus};
	  else if (ioaddr == 2'b11 && !iocs_n && !iorw_n) 		// Write into the higher bits of div_buffer
		div_buffer <= {databus[4:0],div_buffer[7:0]};
	end

	///////////////////////////////
	// TX Buffer control logic  //
	/////////////////////////////
	assign trmt = tx_done && !tx_q_empty; 						// Start next transmit if TX queue not empty and last transmit is finished.
	assign tx_q_we = ioaddr == 2'b00 && !iocs_n && !iorw_n;		// Write to TX buffer when address is correct, chip enabled, and write enabled

	///////////////////////////////
	// RX Buffer control logic  //
	/////////////////////////////
	assign rx_q_re = ioaddr == 2'b00 && !iocs_n && iorw_n;		// Read from RX buffer when address is correct, chip enabled, and read enabled

	////////////////////////////////////////////
	// Instantiate Transmitter and tx_buffer //
	//////////////////////////////////////////
	UART_tx iTX(
		.clk(clk),
		.rst_n(rst_n),
		.TX(TX),
		.trmt(trmt),
		.tx_data(tx_data),
		.baud_div(div_buffer),  // allow baud rate control
		.tx_done(tx_done)
	);
	fifo iTX_BUFFER(
		.clk(clk),
		.rst_n(rst_n),
		.w_en(tx_q_we),
		.r_en(trmt),
		.in_data(databus),
		.q_full(tx_q_full),
		.q_empty(tx_q_empty),
		.out_data(tx_data),
		.contain_num(tx_used_num)
	);

	////////////////////////////////////////
	// Instantiate Receiver and rx_buffer//
	//////////////////////////////////////
	UART_rx iRX(
		.clk(clk),
		.rst_n(rst_n),
		.RX(RX),
		.rdy(rx_rdy),
		.clr_rdy(rx_rdy),       // clear in the next cycle of receiving rdy flag
		.baud_div(div_buffer),  // allow baud rate control
		.rx_data(rx_data)       // feed into the rx_queue
	);
	fifo iRX_BUFFER(
		.clk(clk),
		.rst_n(rst_n),
		.w_en(rx_rdy),          // enabled when a data is received from UART_rx
		.r_en(rx_q_re),
		.in_data(rx_data),		// data from UART_rx
		.q_full(),				// not used since fifo automatically rejects writes when it's full
		.q_empty(rx_q_empty),
		.out_data(rx_q_data),
		.contain_num(rx_used_num)
	);

endmodule
