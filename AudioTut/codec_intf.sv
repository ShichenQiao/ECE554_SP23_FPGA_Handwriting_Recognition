module codec_intf(clk,rst_n,ADCDAT,lft_out,rht_out,LRCLK,BCLK,MCLK,DACDAT,lft_in,rht_in,valid);

  input clk,rst_n;		// 50MHz clock and asynch active low reset
  input ADCDAT;			// serial data out from CODEC
  input [15:0] lft_out;	// processed audio data from digital core going out to left channel
  input [15:0] rht_out;	// processed audio data from digital core going out to right channel
  output reg LRCLK;		// Left/right_n clock, determines sample rate 48.828kHz
  output BCLK;			// serial clock for CODEC interface.  1.5625MHz
  output MCLK;			// main clock to CODEC, 12.5MHz
  output DACDAT;		// Serial datat in to the CODEC (output from this block)
  output [15:0] lft_in;	// Left raw audio data in parallel format coming in from CODEC
  output [15:0] rht_in;	// right raw audio data in parallel format coming in from CODEC
  output reg valid;		// valid signal, informs digital core that new audio data is valid

  ///////////////////////////////////////////////
  // Define any internal signals of type wire //
  /////////////////////////////////////////////
  wire LRCLK_early_riseing, LRCLK_falling, LRCLK_transitioning;
  wire set_valid;
  wire BCLK_rising, BCLK_falling; 
  
  //////////////////////////////////
  // define any registers needed //
  ////////////////////////////////
  reg [9:0] clk_cnt;		// need a 10-bit counter to create the various 
                            // clocks from 50MHz
  reg [15:0] shft_reg_out;	// shift register that feeds DACDAT to the CODEC 
  reg [15:0] shft_reg_in;	// shift register that capture ADCDAT from CODEC
  reg [15:0] lft_in;		// lft data comes in first and must be buffered, 
                            // rht data can come direct from shft_reg
  reg [15:0] lft_buffer;	// used to double buffer lft data from core
  reg [15:0] rht_buffer;	// used to double buffer rht data from core

  
  ///////////////////////////////////////////////////
  // Clock divider for generating LRCLK_early,BCLK,MCLK //
  /////////////////////////////////////////////////
  always_ff @(posedge clk, negedge rst_n)
    if (!rst_n)
      clk_cnt <= 10'h200;		// LRCLK_early needs to start high, and is MSB of this counter
    else
      clk_cnt <= clk_cnt + 1;
	
  assign LRCLK_early = clk_cnt[9];	// 50MHz/1024 = 48.828kHz sample clock
  assign BCLK = clk_cnt[4];		// 50MHz/32 = 1.5625MHz serial clock
  assign MCLK = clk_cnt[1];		// 50HMz/4 = 12.5MHz clock to drive CODEC
  //////////////////////////////////////////////
  // Delay LRCLK for hold time spec of CODEC //
  ////////////////////////////////////////////
  always_ff @(posedge clk, negedge rst_n)
    if (!rst_n)
	  LRCLK <= 1'b1;
	else
	  LRCLK <= LRCLK_early;
  
  /////////////////////////////////////////////////////////////
  // setup some signals regarding pending LRCLK_early transitions //
  ///////////////////////////////////////////////////////////
  assign LRCLK_transitioning = &clk_cnt[8:0];	// if lower bits full we know about to toggle MSB
  assign LRCLK_rising = LRCLK_transitioning & ~LRCLK_early;
  assign LRCLK_falling = LRCLK_transitioning & LRCLK_early;
  
  ///////////////////////////////////////////////////////////
  // Since shft_reg is shifted on BCLK fall it is good to //
  // have a signal that indicates when that is coming.   //
  ////////////////////////////////////////////////////////
  assign BCLK_rising = ~BCLK & &clk_cnt[3:0];
  assign BCLK_falling = BCLK & &clk_cnt[3:0];
  
  /////////////////////////////////////////
  // valid timing is known from clk_cnt //
  ///////////////////////////////////////
  assign set_valid = ~LRCLK_early & &clk_cnt[8:5] & BCLK_rising;
  
  always_ff @(posedge clk, negedge rst_n)
    if (!rst_n)
	  valid <= 1'b0;
	else if (set_valid)
	  valid <= 1'b1;
	else if (LRCLK_rising)
	  valid <= 1'b0;
 
  ///////////////////////////////////////////////////////////
  // Infer flops for double buffering audio out from core //
  /////////////////////////////////////////////////////////
  always_ff @(posedge clk)
    if (set_valid) begin
	  lft_buffer <= lft_out;
	  rht_buffer <= rht_out;
	end
  
  //////////////////////////////////////////////////////
  // Infer output shift register, shift on BCLK fall //
  ////////////////////////////////////////////////////
  always_ff @(posedge clk)
    if (LRCLK_rising)
	  shft_reg_out <= lft_buffer;
	else if (LRCLK_falling)
	  shft_reg_out <= rht_buffer;
	else if (BCLK_falling)
	  shft_reg_out <= {shft_reg_out[14:0],1'b0};
  assign DACDAT = shft_reg_out[15];
  
  //////////////////////////////////////////////////////
  // Infer input shift register, shifts on BCLK rise //
  ////////////////////////////////////////////////////
  always_ff @(posedge clk)
	if (BCLK_rising)
	  shft_reg_in <= {shft_reg_in[14:0],ADCDAT};
  
  /////////////////////////////////////////////
  // Infer capture buffer of lft from CODEC //
  ///////////////////////////////////////////
  always_ff @(posedge clk)
    if (LRCLK_falling)
	  lft_in <= shft_reg_in;		// buffer left input (to core) data
  assign rht_in = shft_reg_in;		// right input (to core) data can come straight 
  

endmodule