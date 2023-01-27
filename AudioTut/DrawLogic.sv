module DrawLogic(clk,rst_n,aud_vld,lft_in,rht_in,xpix,ypix,VGA_G,VGA_B,VGA_R);

  input clk,rst_n;
  input aud_vld;
  input signed [15:0] lft_in;
  input signed [15:0] rht_in;
  input [9:0] xpix;
  input [8:0] ypix;
  output [7:0] VGA_G,VGA_B,VGA_R;
  
  wire signed [15:0] abs_lft,abs_rht;		// 16-bit square of lft/rht audio
  wire set_queue_full;				// once queue full tail_ptr increments
  wire [16:0] lft_data,rht_data;			// data out of queues to graph
  wire [6:0] ptr;					// read address into queues
  wire vld_rise;
  
  reg [24:0] lft_accum;				// used for average of 512 samples to put in queue
  reg [24:0] rht_accum;
  reg [8:0] smpl_cnt;				// count of 512 samples for averaging
  reg [6:0] head_ptr,tail_ptr;	    // circular queue pointers
  reg queue_full;					// once queue full tail_ptr increments
  reg aud_vld_ff;					// flopped version of aud_vld for edge detect
  
  
  ///////////////////////////////////////////////////////////
  // Human hearing is proportional to square of amplitude //
  /////////////////////////////////////////////////////////
  //assign abs_lft = $signed(lft_in[15:4])*$signed(lft_in[15:4]);
  //assign abs_rht = $signed(rht_in[15:4])*$signed(rht_in[15:4]);
  assign abs_lft = (lft_in[15]) ? -lft_in : lft_in;
  assign abs_rht = (rht_in[15]) ? -rht_in : rht_in;
  
  always_ff @(posedge clk, negedge rst_n)
    if (!rst_n)
	  aud_vld_ff <= 1'b0;
	else
	  aud_vld_ff <= aud_vld;
	  
  assign vld_rise = aud_vld & ~aud_vld_ff;
  
  always_ff @(posedge clk, negedge rst_n)
    if (!rst_n)
	  smpl_cnt <= 9'h000;
	else if (vld_rise)
	  smpl_cnt <= smpl_cnt + 1;
	  
  always_ff @(posedge clk, negedge rst_n)
    if (!rst_n) begin
	  lft_accum <= 25'h0000000;
	  rht_accum <= 25'h0000000;
	end else if ((vld_rise) && (&smpl_cnt)) begin
	  lft_accum <= 25'h0000000;
	  rht_accum <= 25'h0000000;	
	end else if (vld_rise) begin
	  lft_accum <= lft_accum + abs_lft;
	  rht_accum <= rht_accum + abs_rht;
	end
	
  always_ff @(posedge clk, negedge rst_n)
    if (!rst_n)
	  head_ptr <= 7'h00;
	else if ((&smpl_cnt) && (vld_rise))
	  head_ptr <= (head_ptr==7'd119) ? 7'h00 : head_ptr + 1;
  
  assign set_queue_full = (head_ptr==7'hd119) ? 1'b1 : 1'b0;

  always_ff @(posedge clk, negedge rst_n)
    if (!rst_n)
      queue_full <= 1'b0;
    else if (set_queue_full)
      queue_full <= 1'b1;
	  
  always_ff @(posedge clk, negedge rst_n)
    if (!rst_n)
	  tail_ptr <= 7'h00;
	else if ((&smpl_cnt) && (vld_rise) && (queue_full))
	  tail_ptr <= (tail_ptr==7'd119) ? 7'h00 : tail_ptr + 1;
	  
  assign ptr = (head_ptr>ypix[8:2]) ? head_ptr - ypix[8:2] : 7'd119 - (ypix[8:2]-head_ptr);
	  
  DPRAM120x16 iLFTQueue(.clk(clk),.we(&smpl_cnt & vld_rise),.waddr(head_ptr),.wdata(lft_accum[24:9]),
             .raddr(ptr), .rdata(lft_data));
  DPRAM120x16 iRHTQueue(.clk(clk),.we(&smpl_cnt & vld_rise),.waddr(head_ptr),.wdata(rht_accum[24:9]),
             .raddr(ptr), .rdata(rht_data));
			 
  always_comb begin
    if (xpix<lft_data[12:3]) 
	  VGA_R = 8'h20 + {xpix,1'b1};
	else if (xpix>(10'd640-rht_data[12:3]))
	  VGA_R = 8'h20 + (10'd640-xpix);
	else
	  VGA_R = 8'h00;
	  
    if (xpix<lft_data[12:3]) 
	  VGA_G = 8'hA0 - xpix;
	else if (xpix>(10'd640-rht_data[12:3]))
	  VGA_G = 8'hA0 - (10'd640-xpix);
	else
	  VGA_G = 8'h00;
	
	VGA_B = 8'h30;
  end
  
endmodule 
	