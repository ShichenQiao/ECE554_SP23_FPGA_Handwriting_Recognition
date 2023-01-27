module I2C24Wrt(clk,rst_n,data16,wrt,done,err,SCL,SDA);

  ////////////////////////////////////////////////
  // Implements an I2C master that can only perform
  // 24-bit write transactios.
  ////////////////////////////////////////////////
  
  input clk,rst_n;		// 50MHz clk, and asynch active low reset
  input [15:0] data16;	// 16-bit data portion of 24-bit packet
  input wrt;			// pulse high for 1 clk to initiate write
  output reg done;		// indicates transaction complete
  output reg err;		// error occurred slave did not ACK (NACK)
  output SCL;			// I2C clock	
  inout SDA;			// open drain output
  
  localparam SLV_ADDR = 7'b0011010;
  
  typedef enum reg[2:0] {IDLE,ADDR,ACK1,HIGH_BYTE,ACK2,LOW_BYTE,ACK3,STOP} state_t;
  state_t state, nxt_state;		// declare state flops
  
  reg [5:0] clk_div;		// clock divider register for SCL
  reg [28:0] shft_reg;		// {start_bit,3*9 data bits,zero_bit}
  reg [3:0] bit_cntr;
  
  //// SM outputs ////
  logic rst_clk_div;
  logic set_done, init;
  logic set_err;			// slave did not ACK
  logic force_shft;
  logic rst_bit_cntr;

  /// declare internal signals ///
  wire shft,scl_mid;
  
  //////////////////////////////////////
  // Implement clock divider for SCL //
  ////////////////////////////////////  
  always_ff @(posedge clk, negedge rst_n)
    if (!rst_n)
	  clk_div <= 6'h30;		// SCL high and a ways from falling
	else if (rst_clk_div)
	  clk_div <= 6'h30;
	else
	  clk_div <= clk_div + 1;
	  
  assign SCL = clk_div[5];	// div 64 so 781kHz with 50MHz clock
  assign shft = (clk_div==6'h0F) ? 1'b1: 1'b0;	// shift 1/2 way through SCL low phase
  assign scl_mid = (clk_div==6'h2F) ? 1'b1 : 1'b0;	// last shift is mid SCL high (stop bit)
  
  /////////////////////////////////////
  // Implement shifter holding data //
  ///////////////////////////////////
  always_ff @(posedge clk, negedge rst_n)
    if (!rst_n)
	  shft_reg <= '1;
    else if (init)
	  shft_reg <= {1'b0,SLV_ADDR,1'b0,1'b1,data16[15:8],1'b1,data16[7:0],1'b1,1'b0};
	else if (shft | force_shft)
	  shft_reg <= {shft_reg[27:0],1'b1};
 
  assign SDA = (shft_reg[28]) ? 1'bz : 1'b0;	// Open drain driver for SDA 
	
  /////////////////////
  // Implement bit counter //
  //////////////////////////
  always_ff @(posedge clk)
    if (rst_bit_cntr)
      bit_cntr <= 4'h0;
    else if (shft)
      bit_cntr <= bit_cntr + 1;	
	
  ////////////////////////
  // Infer state flops //
  //////////////////////  
  always_ff @(posedge clk, negedge rst_n)
    if (!rst_n)
	  state <= IDLE;
	else
	  state <= nxt_state;
	  
  always_comb begin
    rst_clk_div = 0;
	set_done = 0;
	set_err = 0;
	init = 0;
	rst_bit_cntr = 0;
	force_shft = 0;
	nxt_state = state;
	
	case (state)
	  IDLE : begin
	    rst_clk_div = 1;	// hold SCL high in IDLE
	    if (wrt) begin
		  init = 1;
		  rst_bit_cntr = 1;
		  nxt_state = ADDR;
		end
	  end
	  ADDR : begin
	    if (bit_cntr==4'h9)
		  nxt_state = ACK1;
	  end
	  ACK1 : begin
	    if (scl_mid & SDA) begin
		  set_err = 1;		// slave did not acknowledge
		  set_done = 1;
		  nxt_state = IDLE;
		end else if (shft) begin
		  rst_bit_cntr = 1;
		  nxt_state = HIGH_BYTE;
		end
	  end
	  HIGH_BYTE : begin
	  	if (bit_cntr==4'h8)
		  nxt_state = ACK2;
	  end
	  ACK2 : begin
	    if (scl_mid & SDA) begin
		  set_err = 1;		// slave did not acknowledge
		  set_done = 1;
		  nxt_state = IDLE;
		end else if (shft) begin
		  rst_bit_cntr = 1;
		  nxt_state = LOW_BYTE;
		end
	  end	  
	  LOW_BYTE : begin
	  	if (bit_cntr==4'h8)
		  nxt_state = ACK3;
	  end
	  ACK3 : begin
	    if (scl_mid & SDA) begin
		  set_err = 1;		// slave did not acknowledge
		  set_done = 1;
		  nxt_state = IDLE;
		end else if (shft) begin
		  rst_bit_cntr = 1;
		  nxt_state = STOP;
		end
	  end
      STOP : begin
	    if (scl_mid) begin
		  force_shft = 1;
		  set_done = 1;
		  nxt_state = IDLE;
		end
      end	  
	endcase 
  end
  
	  
  ////////////////////////////////////
  // Implement set/reset done flop //
  //////////////////////////////////
  always_ff @(posedge clk, negedge rst_n)
    if (!rst_n)
	  done <= 1'b0;
	else if (init)
	  done <= 1'b0;
	else if (set_done)
	  done <= 1'b1;
	  
  ///////////////////////////
  // Implement error flop //
  /////////////////////////
  always_ff @(posedge clk, negedge rst_n)
    if (!rst_n)
	  err <= 1'b0;
	else if (init)
	  err <= 1'b0;
	else if (set_err)
	  err <= 1'b1;

endmodule	  
	  
  