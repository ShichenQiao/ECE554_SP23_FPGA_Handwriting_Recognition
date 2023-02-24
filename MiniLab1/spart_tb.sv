module spart_tb();
	reg  clk, rst_n;		// master clk and active low reset
	reg  iocs_n;			// active low chip select (decode address range)
    reg  iorw_n;			// high for read, low for write
	wire tx_q_full;			// indicates transmit queue is full
    wire rx_q_empty;		// indicates receive queue is empty
    reg  [1:0] ioaddr;		// Read/write 1 of 4 internal 8-bit registers
    wire [7:0] databus;		// bi-directional data bus
    wire TX;				// UART TX line
    reg  RX;				// UART RX line

	// Device under test
	spart iDUT(
		.clk(clk),
		.rst_n(rst_n),
		.iocs_n(iocs_n),
		.iorw_n(iorw_n),
		.tx_q_full(tx_q_full),
		.rx_q_empty(rx_q_empty),
		.ioaddr(ioaddr),
		.databus(databus),
		.TX(TX),
		.RX(RX)
    );

	// specify number of iterations of randomly interleaved read and write at random baud rate from baud_div_exp below (for TEST 8)
	parameter int RANDOM_TEST_ITERATION = 30;
	logic [2:0] rand_baud_idx;
	logic [7:0] rand_data;
	logic rand_rw_n;		// 1 for read, 0 for write
	// task to randomize test case
	task automatic get_random_test_case(ref [2:0] rand_baud_idx, ref [7:0] rand_data, ref rand_rw_n);
		// random() return 32 bit signed integer
		int randval = $random();
		rand_baud_idx = randval[2:0];
		rand_data = randval[10:3];
		rand_rw_n = randval[11];
	endtask

	int i;				// loop index

	reg  [7:0] stat_reg_exp;	// expected data of the status register
	reg  TB_data_stim_en;		// high when TB write data to DUT, low other wise
	reg  [7:0] data_stim;		// data to be sent from tb to DUT
	// put data_stim on the bi-directional data bus only if writting to DUT, high-Z otherwise
	assign databus = TB_data_stim_en ? data_stim : 8'hzz;

	logic spart_tx_done;		// indicating iDUT has sent a byte of data out
	assign spart_tx_done = iDUT.iTX.tx_done;

	// Memory Map
	localparam [1:0] DATABUFF = 2'b00;		// memory address for TX/RX buffer
	localparam [1:0] STATREGI = 2'b01;		// status register (read only)
	localparam [1:0] DBBUFFLO = 2'b10;		// DB (low) Baud rate division buffer low byte
	localparam [1:0] DBBUFFHI = 2'b11;		// DB (high) Baud rate division buffer high byte

	// Baud counter table (expected values for DB high and DB low register), assuming clk = 50MHz
	localparam [12:0] baud_div_exp [0:7] = '{
		13'h0036,			// baud = 921600
		13'h006C,			// baud = 460800
		13'h00D9,			// baud = 230400
		13'h01B2,			// baud = 115200 (default)
		13'h0364,			// baud = 57600
		13'h0516,			// baud = 38400
		13'h0A2C,			// baud = 19200
		13'h1458			// baud = 9600
	};
	reg [2:0] baud_table_idx;			// index into the table above

	// UART model used for testbench
	logic tb_rx_rdy;			// tb_rx_rdy asserted when byte received from DUT
	reg   tb_clr_rx_rdy;		// tb_rx_rdy can be cleared by this or new start bit
	wire  [7:0] tb_rx_data;		// data received from DUT
	reg   tb_trmt;				// trmt trigger a new UART transaction from TB to DUT
	reg   [7:0] tb_tx_data;		// data to be sent from TB to DUT
	wire  tb_tx_done;			// asserted when transaction from TB to DUT is done
	UART iUART(
		.clk(clk),
		.rst_n(rst_n),
		.RX(TX),			// testbench RX is DUT TX
		.TX(RX),			// testbench TX is DUT RX
		.rx_rdy(tb_rx_rdy),
		.clr_rx_rdy(tb_clr_rx_rdy),
		.rx_data(tb_rx_data),
		.trmt(tb_trmt),
		.tx_data(tb_tx_data),
		.tx_done(tb_tx_done),
		.baud_div(baud_div_exp[baud_table_idx])		// picking baud counter value from baud counter table above
	);

	initial begin
		clk = 1'b0;					// assumed to be 50MHz
		rst_n = 1'b0;				// only reset the DUT here once throughout this TB
		iocs_n = 1'b0;				// enable chip
		baud_table_idx = 3;			// default baud rate = 115200
		tb_trmt = 0;				// disable TB UART feedback to DUT
		@(posedge clk);
		@(negedge clk) rst_n = 1'b1;

		////////////////////////////////////////////////////////
		// Test 1: make sure baud rate is default to 115200  //
		//////////////////////////////////////////////////////

		// test DB High register, should get 8'h01
		iorw_n = 1'b1;				// read from spart
		TB_data_stim_en = 1'b0;		// TB is not writing to DUT
		ioaddr = DBBUFFHI;			// read DB High register
		@(posedge clk);
		if(databus !== {3'b000, baud_div_exp[3][12:8]}) begin
			$display("Test 1 ERROR: DB high register should be reset to 0x01 for baud = 115200");
			$stop();
		end

		// test DB Low register, should get 8'hB2
		@(negedge clk);
		ioaddr = DBBUFFLO;		// read DB Low register
		@(posedge clk);
		if(databus !== baud_div_exp[3][7:0]) begin
			$display("Test 1 ERROR: DB low register should be reset to 0xB2 for baud = 115200");
			$stop();
		end

		$display("Test 1 PASSED!");

		///////////////////////////////////////////////////////////
		// Test 2: make sure status register is reset to 8'h80  //
		/////////////////////////////////////////////////////////
		@(negedge clk);
		iorw_n = 1'b1;				// read from spart
		TB_data_stim_en = 1'b0;		// TB is not writing to DUT
		ioaddr = STATREGI;			// read status register
		@(posedge clk);
		if(databus !== 8'h80) begin
			$display("Test 2 ERROR: status buffer should reset to 8'h80");
			$stop();
		end

		$display("Test 2 PASSED!");

		//////////////////////////////////////////////////////////////////////////
		// Test 3: make sure DUT put high-Z on databus during writes to DUT    //
		//		   also test chip enable feature - when disabled, do nothing  //
		///////////////////////////////////////////////////////////////////////
		@(negedge clk);
		iorw_n = 1'b0;				// write to spart
		TB_data_stim_en = 1'b0;		// mute TB data on purpose to see if DUT put high-z on bus 
		ioaddr = DATABUFF;			// "write" to data buff (TX)
		@(posedge clk);
		if(databus !== 8'hzz) begin
			$display("Test 3 ERROR: DUT failed to put high-z on databus during writes to DUT");
			$stop();
		end
		// stop issuing more trash writes by disabling chip
		@(negedge clk) iocs_n = 1'b1;
		// wait until this "trash" transaction finish
		// at baud == 115200, clk = 50MHz, UART transaction should take 0x1B2 * 10 = 4340 cycles
		// giving 20 more cycles for other flops in the code path
		wait4sig(spart_tx_done, 4360);
		if(tb_rx_data !== 8'hzz) begin
			$display("Test 3 ERROR: DUT failed to put high-z on databus during writes to DUT");
			$stop();
		end
		// clear TB UART rx_rdy flag
		@(negedge clk) tb_clr_rx_rdy = 1'b1;
		@(negedge clk) tb_clr_rx_rdy = 1'b0;

		$display("Test 3 PASSED!");

		////////////////////////////////////////////////////////////////////////////
		// Test 4: test filling the TX queue to full (also watching status reg)  //
		//////////////////////////////////////////////////////////////////////////
		stat_reg_exp = 8'h80;			// both RX and TX buffer should remain empty here
		// perform 9 writes to fill the TX buffer
		for(i = 0; i < 9; i++) begin
			@(negedge clk);
			iocs_n = 1'b0;				// re-enable chip (disabled in previous test)
			iorw_n = 1'b0;				// write to spart
			TB_data_stim_en = 1'b1;		// TB is writing to DUT
			ioaddr = DATABUFF;			// write to data buff (TX)
			data_stim = 8'h01 << i;		// write 8'h01, 8'h02, 8'h04... 8'h80, 8'h00 in this order
			@(negedge clk);				// perform read to check status register in the next cycle
			iorw_n = 1'b1;				// read from spart
			TB_data_stim_en = 1'b0;		// TB is not writing to DUT
			ioaddr = STATREGI;			// read status register
			@(negedge clk);
			if(databus !== stat_reg_exp) begin
				$display("Test 4 ERROR: status buffer was not updated correctly during TX queue filling");
				$stop();
			end
			// advance to next expected value, -8'h10 means taking one space in TX queue, but no change yet to RX queue
			stat_reg_exp = stat_reg_exp - 8'h10;
		end
		// spart should be working on the first write and have 8 write requests filling up the TX buffer
		if(tx_q_full !== 1'b1) begin
			$display("Test 4 ERROR: tx_q_full not set properly");
			$stop();
		end

		$display("Test 4 PASSED!");

		//////////////////////////////////////////////////////////////
		// Test 5: check if correct data from Test4 were received  //
		////////////////////////////////////////////////////////////
		@(negedge clk);
		stat_reg_exp = 8'h00;		// at this point, TX buffer is full, spart is busy, and RX buffer is still empty
		iorw_n = 1'b1;				// read from spart
		TB_data_stim_en = 1'b0;		// TB is not writing to DUT
		ioaddr = STATREGI;			// reading from status register
		// check status register and flag
		@(posedge clk);
		// rx_q_empty should be set
		if(rx_q_empty !== 1'b1) begin
			$display("Test 5 ERROR: rx_q_empty not set properly");
			$stop();
		end
		// status register should have 8'h00
		if(databus !== stat_reg_exp) begin
			$display("Test 5 ERROR: status buffer was not updated correctly when TX buffer is full but RX buffer is empty");
			$stop();
		end
		// check each byte received from DUT and the status reg
		for(i = 0; i < 9; i++) begin
			// wait for tb_rx_rdy to see if DUT correctly sent the 9 bytes from Test 4
			wait4sig(tb_rx_rdy, 4360);
			if(tb_rx_data !== 8'h01 << i) begin		// data sent from DUT was 8'h01, 8'h02, 8'h04... 8'h80, 8'h00 in this order
				$display("Test 5 ERROR: incorrect data was received from the DUT");
				$stop();
			end
			// check if status reg is updated properly right after a byte received by DUT
			@(negedge clk);
			if(databus !== stat_reg_exp) begin
				$display("Test 5 ERROR: status buffer was not updated correctly during RX queue filling");
				$stop();
			end
			// advance to next expected value, +8'h11 means freeing up 1 space in TX buffer and getting 1 more entry in RX buffer
			stat_reg_exp = stat_reg_exp + 8'h10;
			// clear tb_rx_rdy and wait for next received data from the DUT
			@(negedge clk) tb_clr_rx_rdy = 1'b1;
			@(negedge clk) tb_clr_rx_rdy = 1'b0;
		end

		$display("Test 5 PASSED!");

		////////////////////////////////////
		// CHANGING BAUD RATE TO 921600  //
		//////////////////////////////////
		@(negedge clk);
		baud_table_idx = 0;			// update TB baud rate index (this change baud rate of TB UART)
		iorw_n = 1'b0;				// write to spart
		TB_data_stim_en = 1'b1;		// TB is writing to DUT
		ioaddr = DBBUFFHI;			// write to division buffer high reg first
		data_stim = {3'b000, baud_div_exp[baud_table_idx][12:8]};		// write high byte
		@(negedge clk);
		ioaddr = DBBUFFLO;			// write to division buffer low reg next
		data_stim = baud_div_exp[baud_table_idx][7:0];					// write low byte

		////////////////////////////////////////////////////////////////////////////
		// Test 6: test filling the RX queue to full (also watching status reg)  //
		//////////////////////////////////////////////////////////////////////////
		stat_reg_exp = 8'h81;		// TX buffer should be all open, RX buffer should start to increase as the following loop goes
		// send 9 bytes to iDUT, first 8 enter RX buffer, the 9th one should be lost
		for(i = 0; i < 9; i++) begin
			@(negedge clk);
			iorw_n = 1'b1;				// read from spart
			ioaddr = STATREGI;			// poll status register
			TB_data_stim_en = 1'b0;		// TB is not writing to DUT
			tb_tx_data = i[7:0];		// send 8'h00 through 8'h08 to DUT, one per iteration
			tb_trmt = 1'b1;				// send 1 byte
			@(negedge clk)tb_trmt = 1'b0;				// disable TB UART feedback to DUT
			@(posedge tb_tx_done);
			if(databus !== stat_reg_exp) begin
				$display("Test 6 ERROR: status register was not updated correctly during RX queue filling");
				$stop();
			end
			if(i < 7)				// the 9th byte should not enter the RX buffer
				stat_reg_exp = stat_reg_exp + 1;
		end

		$display("Test 6 PASSED!");

		//////////////////////////////////////////////////////////////////////////
		// Test 7: verify correct data from Test 6 are received by DUT,		   //
		//		   also check status reg while poping bytes out of RX buffer  //
		///////////////////////////////////////////////////////////////////////
		stat_reg_exp = 8'h87;		// TX buffer should be all open, RX buffer should start to decrease as the following loop goes
		// RX buffer should hold 8'h00 through 8'h07
		for(i = 0; i < 8; i++) begin
			@(negedge clk);
			iorw_n = 1'b1;				// read from spart
			ioaddr = DATABUFF;			// read from RX buffer
			TB_data_stim_en = 1'b0;		// TB is not writing to DUT
			@(posedge clk);
			if(databus !== i[7:0]) begin
				$display("Test 7 ERROR: incorrect data received by iDUT");
				$stop();
			end
			@(negedge clk);
			ioaddr = STATREGI;			// read from status register
			@(posedge clk);
			if(databus !== stat_reg_exp) begin
				$display("Test 7 ERROR: status register not updated properly when entries are popped out");
				$stop();
			end
			stat_reg_exp = stat_reg_exp - 1;
		end
		// after the 8th iteration, RX buffer should be empty, indicating 9th byte is lost
		if(rx_q_empty !== 1'b1) begin
			$display("Test 7 ERROR: RX buffer should be empty after 8 reads");
			$stop();
		end

		$display("Test 7 PASSED!");

		/////////////////////////////////////////////////////////////////////////////////
		// Test 8: test random, interleaved reads and writes at different baud rates  //
		///////////////////////////////////////////////////////////////////////////////
		for(int i = 0; i < RANDOM_TEST_ITERATION; i++) begin
			get_random_test_case(rand_baud_idx, rand_data, rand_rw_n);
			
			// change baud rate
			@(negedge clk);
			baud_table_idx = rand_baud_idx;		// update TB UART baud rate
			iorw_n = 1'b0;						// write to spart
			TB_data_stim_en = 1'b1;				// TB is writing to DUT
			ioaddr = DBBUFFHI;					// write to division buffer high reg first
			data_stim = {3'b000, baud_div_exp[baud_table_idx][12:8]};		// write high byte
			@(negedge clk);
			ioaddr = DBBUFFLO;					// write to division buffer low reg next
			data_stim = baud_div_exp[baud_table_idx][7:0];					// write low byte

			// poll status register
			@(negedge clk);
			iorw_n = 1'b1;				// read from spart
			TB_data_stim_en = 1'b0;		// TB is not writing to DUT
			ioaddr = STATREGI;			// read from status register
			
			if(rand_rw_n) begin			// test read
				// TB UART send one random byte to DUT
				@(negedge clk);
				tb_tx_data = rand_data;
				tb_trmt = 1'b1;
				@(negedge tb_tx_done);
				tb_trmt = 1'b0;
				// wait until data is received by iDUT, read it from RX buffer
				@(negedge rx_q_empty);
				@(negedge clk);
				ioaddr = DATABUFF;			// read from RX buffer
				@(posedge clk);
				if(databus !== rand_data) begin
					$display("Test 8 ERROR: wrong data received by DUT");
					$stop();
				end
			end
			else begin					// or test write
				@(negedge clk);
				iorw_n = 1'b0;				// write to spart
				TB_data_stim_en = 1'b1;		// TB is writing to DUT
				ioaddr = DATABUFF;			// write to data buff (TX)
				data_stim = rand_data;		// write rand_data
				
				// poll status register
				@(negedge clk);
				iorw_n = 1'b1;				// read from spart
				TB_data_stim_en = 1'b0;		// TB is not writing to DUT
				ioaddr = STATREGI;			// read from status register
				
				// wait until TB UART received rand byte, check content
				@(posedge tb_rx_rdy);
				if(tb_rx_data !== rand_data) begin
					$display("Test 8 ERROR: incorrect data was received from the DUT");
					$stop();
				end
				
				// clear tb_rx_rdy
				@(negedge clk) tb_clr_rx_rdy = 1'b1;
				@(negedge clk) tb_clr_rx_rdy = 1'b0;
			end
		end

		$display("Test 8 PASSED! %d random read/write of random data at random baud (8 possible rates) executed.", RANDOM_TEST_ITERATION);

		$display("ALL TESTS PASSED!!!");
		$stop();
	end

	// task to check timeouts of waiting the posedge of a given status signal
	task automatic wait4sig(ref sig, input int clks2wait);
		fork
			begin: timeout
				repeat(clks2wait) @(posedge clk);
				$display("ERROR: timed out waiting for sig in wait4sig");
				$stop();
			end
			begin
				@(posedge sig)
				disable timeout;
			end
		join
	endtask
	
	always
		#5 clk = ~clk;

endmodule
