module AudioScale(clk,rst_n,aud_vld,volume,lft_in,rht_in,lft_out,rht_out);

  input clk,rst_n;
  input signed [15:0] lft_in;
  input signed [15:0] rht_in;
  input aud_vld;
  input [11:0] volume;
  output reg [15:0] lft_out;
  output reg [15:0] rht_out;
  
  wire signed [27:0] prod_lft;		// intermediate of scaling.
  wire signed [27:0] prod_rht;		// intermediate of scaling.
  
  ///////////////////////////////
  // Scale by volume from A2D //
  /////////////////////////////
  /// Ohh rats!! I had a 50/50 chance of wiring the pots correct
  /// Beauty of FPGA is you can correct mistakes like that 
  /// scale by 12'hFFF - volume instead of volume
  assign prod_lft = lft_in*$signed(12'hFFF - {1'b0,volume});
  assign prod_rht = rht_in*$signed(12'hFFF - {1'b0,volume});

  
  ///////////////////////////////////////
  // Only update audio out on aud_vld //
  /////////////////////////////////////
  always_ff @(posedge clk, negedge rst_n)
    if (!rst_n) begin
	  lft_out <= 16'h0000;
	  rht_out <= 16'h0000;
	end else if (aud_vld) begin
	  lft_out <= prod_lft[27:12];	// div by 2048
	  rht_out <= prod_rht[27:12];	// div by 2048
	end
  
endmodule