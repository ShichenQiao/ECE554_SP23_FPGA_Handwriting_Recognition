module A2D_intf(clk,rst_n,val0,CONVST,SCLK,MOSI,MISO);
  //////////////////////////////////////////////////
  // This module is designed to read channel 0   //
  // of a LTC2308 ADC over and over again and   //
  // present the 12-bit reading on signal val0 //
  //////////////////////////////////////////////

  input clk,rst_n;				// 50MHz clock and active low asynch reset
  input MISO;					// Serial input from A2D (Master In Slave Out)
  output reg [11:0] val0;		// value of channel 0
  output CONVST;				// actully the SS_n signal
  output SCLK,MOSI;				// SPI master signals
  
  typedef enum reg[1:0] {WAIT,FIRST,READ,CONV} state_t;
  state_t state, nxt_state;
  
  wire [15:0] rd_data;		// data read from SPI interface.  Lower 12-bits form res (result of A2D conv)
  wire [15:0] cmd;
  wire done;

  /////////////////
  // SM outputs //
  ///////////////
  logic wrt, update;
  
	  
  /////////////////////////////////
  // timer reg for initial wait //
  ///////////////////////////////
  reg [11:0] timer;
  
  always_ff @(posedge clk, negedge rst_n)
    if (!rst_n)
	  timer <= 12'h000;
	else
	  timer <= timer + 1;
  
  //////////////////////////////
  // assign cmd sent via SPI //
  ////////////////////////////
  assign cmd = 16'h8800;	// single ended conv of CH0
			   
  ////////////////////////////
  // Implement state flops //
  //////////////////////////
  always_ff @(posedge clk, negedge rst_n)
    if (!rst_n)
	  state <= WAIT;
	else
	  state <= nxt_state;
	  
  ///////////////////////////////////////
  // Implement state transition logic //
  /////////////////////////////////////
  always_comb begin
    update = 0;
	wrt = 0;
	nxt_state = state;
	case (state)
	  WAIT:					// kick off fist conversion
	    if (&timer) begin
		  nxt_state = FIRST;
		  wrt = 1;
		end
	  FIRST:				// Throw away first conversion
	    if (&timer) begin
		  nxt_state = READ;
		  wrt = 1;
		end
	  READ: begin			// First valid read occurs
	    if (done) begin
		  nxt_state = CONV;
		  update = 1;
		end 
	  end
	  CONV: begin			// kick off next conv
	    if (&timer) begin
		  nxt_state = READ;
		  wrt = 1;
		end
	  end
	endcase
  end
  
  //////////////////////////////////////////////
  // Implement holding registers for results //
  ////////////////////////////////////////////
  always_ff @(posedge clk, negedge rst_n)
    if (!rst_n)
	  val0 <= 12'h000;
	else if (update)
	  val0 <= rd_data[15:4];		// 12-bit result in MSBs

	  
  ///////////////////////////////////////////////
  // Instantiate SPI master for A2D interface //
  /////////////////////////////////////////////
  SPI_M iSPI(.clk(clk),.rst_n(rst_n),.SS_n(CONVST),.SCLK(SCLK),.MISO(MISO),.MOSI(MOSI),.wrt(wrt),
             .done(done),.rd_data(rd_data),.cmd(cmd));
   
  
endmodule
  