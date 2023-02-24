module UART_tx(
	input clk, rst_n,		// 50MHz system clock & asynch active low reset
	input trmt,				// asserted for 1 clock to initiate transmission
	input [7:0]tx_data,		// byte to transmit
    input [12:0] baud_div,	// Modify baud rate
	output TX,				// serial data output
	output logic tx_done	// asserted when byte is done transmitting, and stays high till next byte transmitted.
);

	logic init;					// SM output to initiate a transmission
	logic transmitting;			// SM output indicating a UART transmission is ongoing
	logic set_done;				// SM output to set tx_done
	logic shift;				// asserted when ready to shift out next bit
	logic [8:0]tx_shft_reg;		// output of the shift register
	logic [12:0]baud_cnt;		// output of the baud counter
	logic [3:0]bit_cnt;			// output of the bit counter

	typedef enum logic {IDLE, TRAN} state_t;
	state_t state, nxt_state;

	// the shift register
	always_ff @(posedge clk, negedge rst_n)
		if(!rst_n)
			tx_shft_reg <= 9'h1FF;								// asynch set the shift register
		else
			if(init)
				tx_shft_reg <= {tx_data, 1'b0};					// append the data with a start bit
			else if(shift)
				tx_shft_reg <= {1'b1, tx_shft_reg[8:1]};		// shift in a 1
			
	assign TX = tx_shft_reg[0];									// shift out the LSB of tx_shft_reg as TX output

	// the baud counter
	always_ff @(posedge clk)
		if(init|shift)
			baud_cnt <= baud_div;								// reset the baud counter if init or shift is asserted
		else if(transmitting)
			baud_cnt <= baud_cnt - 13'h0001;					// count up when transmitting

	assign shift = (baud_cnt == 13'h0000);						// assert shift when baud_cnt reaches 2604 clks

	// the bit counter
	always_ff @(posedge clk)
		if(init)
			bit_cnt <= 4'h0;									// reset the bit counter if init is asserted
		else if(shift)
			bit_cnt <= bit_cnt + 4'h1;							// count up when shifted a bit

	// SM state register
	always_ff @(posedge clk, negedge rst_n)
		if(!rst_n)
			state <= IDLE;
		else
			state <= nxt_state;
			
	// control SM
	always_comb begin
		// default all outputs to prevent unintended latches
		nxt_state = state;
		init = 1'b0;
		transmitting = 1'b0;
		set_done = 1'b0;
		
		case(state)
			TRAN: begin
				transmitting = 1'b1;
				if(bit_cnt == 4'd10) begin						// finish transmission when all 10 bits are transmitted
					set_done = 1'b1;
					nxt_state = IDLE;
				end
			end
			default:	// is IDLE
				if(trmt) begin									// wait until trmt is asserted to begin transmission
					init = 1'b1;
					nxt_state = TRAN;
				end
		endcase
	end

	// SR flop generating tx_done, set_done is S, init is R
	always_ff @(posedge clk, negedge rst_n)
		if(!rst_n)
			tx_done <= 1'b1;
		else if(init)
			tx_done <= 1'b0;
		else if(set_done)
			tx_done <= 1'b1;

endmodule
